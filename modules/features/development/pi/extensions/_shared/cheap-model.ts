/**
 * Shared helper: pick the cheapest usable model for a throwaway side task.
 *
 * Several extensions run small auxiliary completions (extracting questions,
 * summarizing a loop condition). Billing those to the main — often frontier —
 * model is wasteful, but hardcoding a model id per provider rots as soon as the
 * line-up or the provider changes.
 *
 * Instead we rank the *scoped* models on the current provider by price. The
 * scope is pi's `enabledModels` allowlist: the same list that populates the
 * `/model` picker. Honouring it means side tasks can only ever use a model the
 * user has already vetted, which keeps us clear of oddities that happen to be
 * cheap — unvetted proxy aliases with wrong metadata, or bargain models that
 * ignore "English only" and leak CJK text into a status widget.
 *
 * `ExtensionContext` exposes no settings accessor, so the allowlist is read
 * from settings.json on disk. That is the same file pi itself reads, resolved
 * via the SDK's own `getAgentDir()` rather than a guessed path.
 */

import { readFileSync } from "node:fs";
import { join } from "node:path";
import type { Api, Model } from "@earendil-works/pi-ai";
import { getAgentDir } from "@earendil-works/pi-coding-agent";
import type { ModelRegistry } from "@earendil-works/pi-coding-agent";

/**
 * pi's thinking-level suffixes. A scope entry may carry one (`provider/id:high`);
 * it selects a thinking level, not a model, so it is stripped before matching.
 */
const THINKING_SUFFIXES = new Set([
	"off",
	"minimal",
	"low",
	"medium",
	"high",
	"xhigh",
	"max",
]);

/** Strip a trailing `:<thinkingLevel>` from a scope pattern. */
function stripThinkingSuffix(pattern: string): string {
	const colonIdx = pattern.lastIndexOf(":");
	if (colonIdx === -1) return pattern;
	return THINKING_SUFFIXES.has(pattern.slice(colonIdx + 1))
		? pattern.slice(0, colonIdx)
		: pattern;
}

/**
 * Read `enabledModels` from user settings, or undefined when unset/empty.
 *
 * Read on demand rather than cached: `/model` can rewrite the allowlist mid
 * session, and a stale copy would silently keep using a model the user just
 * removed from scope. Any read or parse failure means "no scope" so a broken
 * settings file degrades to unscoped behaviour instead of breaking the caller.
 */
function readScopePatterns(): string[] | undefined {
	try {
		const raw = readFileSync(join(getAgentDir(), "settings.json"), "utf8");
		const patterns = (JSON.parse(raw) as { enabledModels?: unknown }).enabledModels;
		if (!Array.isArray(patterns)) return undefined;
		const usable = patterns.filter((p): p is string => typeof p === "string");
		return usable.length > 0 ? usable : undefined;
	} catch {
		return undefined;
	}
}

/**
 * Whether `model` is in scope. Patterns are matched case-insensitively against
 * both `provider/id` and bare `id`, so `*haiku*` works without a provider
 * prefix (mirroring `resolveModelScope` in pi).
 *
 * Only `*` and `?` are supported. pi runs scope patterns through minimatch,
 * which also has negation, brace expansion and character classes, but a model
 * id is a short flat `provider/id` string: the extra syntax has nothing to bind
 * to here, and depending on minimatch just for two wildcards is not worth an
 * npm dependency in this tree. A pattern using anything fancier simply will not
 * match, which degrades to "not in scope" rather than misbehaving.
 */
function isInScope(model: Model<Api>, patterns: string[]): boolean {
	const fullId = `${model.provider}/${model.id}`;
	return patterns.some((pattern) => {
		const glob = stripThinkingSuffix(pattern);
		// Escape regex metacharacters, then re-expand the two wildcards we honour.
		// `*` stops at `/` so `openai-codex/*` cannot leak across a provider.
		const source = glob
			.replace(/[.*+?^${}()|[\]\\]/g, "\\$&")
			.replace(/\\\*/g, "[^/]*")
			.replace(/\\\?/g, "[^/]");
		const re = new RegExp(`^${source}$`, "i");
		return re.test(fullId) || re.test(model.id);
	});
}

/**
 * Cheapest usable model on `currentModel`'s provider, or `currentModel` itself.
 *
 * Ranked by blended `input + output` price per million tokens. Side tasks are
 * single-shot with short input and output, so a plain sum is a fine proxy and
 * cache pricing is irrelevant — nothing shares a prefix with anything.
 *
 * Deliberate constraints:
 *   - Same provider only, so a side task never bills an account other than the
 *     one driving the session.
 *   - Scope-restricted when `enabledModels` is set (see module docs).
 *   - Zero-priced entries are skipped. On OpenAI-compatible proxies a zero cost
 *     means "no pricing metadata published", not "free", and those alias
 *     entries usually carry wrong context windows too.
 *   - Stops at `currentModel`: if nothing in scope is cheaper, reuse it rather
 *     than switching to something equally expensive.
 *
 * Auth is verified per candidate, so an in-scope model whose provider is not
 * authenticated is skipped rather than returned and failed on later.
 */
export async function selectCheapestModel(
	currentModel: Model<Api>,
	modelRegistry: ModelRegistry,
): Promise<Model<Api>> {
	const scope = readScopePatterns();

	const candidates = modelRegistry
		.getAvailable()
		.filter((model) => model.provider === currentModel.provider)
		.filter((model) => (model.cost?.input ?? 0) > 0 && (model.cost?.output ?? 0) > 0)
		.filter((model) => !scope || isInScope(model, scope) || model.id === currentModel.id)
		.sort((a, b) => a.cost.input + a.cost.output - (b.cost.input + b.cost.output));

	for (const model of candidates) {
		if (model.id === currentModel.id) break; // nothing cheaper in scope
		const auth = await modelRegistry.getApiKeyAndHeaders(model);
		if (auth.ok) return model;
	}

	return currentModel;
}
