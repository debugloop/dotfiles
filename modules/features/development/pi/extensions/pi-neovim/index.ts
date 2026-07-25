import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { Type } from "typebox";

import { glob } from "glob";
import { inspect } from "node:util";
import { readFileSync } from "node:fs";

import * as os from "node:os";
import * as fs from "node:fs/promises";

import { msgpackRpcCall as callRpc } from "./rpc";

type ToolResult = { content: Array<{ type: "text"; text: string }>; details?: Record<string, unknown> };
type CodeActionCacheEntry = { server: string; action: unknown; clientId?: number };

const codeActionCache = new Map<string, CodeActionCacheEntry>();
let nextCodeActionId = 1;

const nvimPromptGuidelines = [
	"Prefer high-level Neovim tools over msgpack_rpc_call. Use raw RPC only as an escape hatch.",
	"High-level Neovim tool line numbers and columns are 1-based for the agent/user. Columns are byte columns unless a tool says otherwise.",
	"If you find multiple instances of Neovim, use pi-ask-user if available to let the user choose one.",
	"Call get_state_brief at the start of a turn before touching a Neovim buffer. Use get_state when cursor/selection/viewport/syntax context matters.",
	"If a file is loaded in Neovim, prefer buffer tools over disk tools so unsaved changes and undo are preserved.",
	"Use disk edit tools for unloaded files and broad patch-oriented changes; use Neovim tools for cursor/selection/viewport context, unsaved buffers, diagnostics, LSP, and undo integration.",
	"Saving Neovim buffers is allowed, but saves may trigger autoformat/autocmds; after saving, assume buffer contents, cursor positions, line numbers, diagnostics, and other editor state may have changed, then re-check state/diagnostics before further edits.",
];

const serverParam = Type.String({ description: "Neovim RPC socket path from discover_neovim/get_state_brief." });
const optionalBufferParam = Type.Optional(Type.Number({ description: "Neovim buffer number. Defaults to the current buffer." }));

const NVIM_LUA = readFileSync(new URL("./nvim.lua", import.meta.url), "utf8");

function nvimCall(server: string, fnName: string, args: unknown = {}, timeout = 10000): Promise<unknown> {
	return callRpc(
		server,
		"nvim_exec_lua",
		[
			`local source, fn_name, fn_args = ...
local chunk = assert(load(source, "pi-neovim.nvim.lua"))
local M = chunk()
local fn = assert(M[fn_name], "unknown pi-neovim lua function: " .. tostring(fn_name))
return fn(fn_args or {})`,
			[NVIM_LUA, fnName, args],
		],
		timeout,
	);
}

export default function (pi: ExtensionAPI) {
	pi.registerTool({
		name: "discover_neovim",
		label: "Discover Neovim",
		description: "Find running Neovim instances.",
		promptGuidelines: nvimPromptGuidelines,
		parameters: Type.Object({}),
		async execute(_, __, ___, ____, ctx) {
			ctx.ui.notify("[pi-neovim] Scanning for instances...", "info");

			const files = await glob([
				"/tmp/*nvim*",
				process.env.NVIM_LISTEN_ADDRESS || "",
				`${os.tmpdir()}/nvim.${os.userInfo().username}/*/nvim.*`,
				`/run/user/${process.getuid?.() || 1000}/*nvim*`,
				`${os.homedir()}/.cache/nvim/*`,
			]);

			const candidates = new Set<string>();
			for (const file of files) {
				try {
					const f = await fs.stat(file);
					if (f.isSocket()) candidates.add(file);
				} catch {
					// Ignore stale glob results.
				}
			}

			const verified = [];
			for (const socket of candidates) {
				try {
					const info: any = { socket };
					info.file = await callRpc(socket, "nvim_buf_get_name", [0], 1000).catch(() => "(no file)");
					info.cwd = await callRpc(socket, "nvim_call_function", ["getcwd", []], 1000).catch(() => "?");
					info.version = await callRpc(socket, "nvim_eval", ["matchstr(execute('version'), 'NVIM v\\zs\\d[^ \\n]*')"], 20000);
					verified.push(info);
				} catch (error) {
					ctx.ui.notify(`[pi-neovim] an error occurred: ${errorMessage(error)}`, "error");
				}
			}

			if (verified.length === 0) return textResult("No running Neovim instances found.");

			const formattedList = verified
				.map((s, i) => `${i + 1}. file: ${s.file}\n   cwd: ${s.cwd}\n   server: ${s.socket}\n   version: ${s.version}`)
				.join("\n\n");

			return {
				content: [{ type: "text", text: `Found ${verified.length} Neovim instance(s):\n\n${formattedList}` }],
				details: { servers: verified },
			};
		},
	});

	pi.registerTool({
		name: "get_state_brief",
		label: "Get Neovim State Brief",
		description: "Return cheap orientation for the current Neovim window: cwd, mode, current buffer, cursor, visible range, active selection coordinates, and loaded buffers.",
		promptGuidelines: nvimPromptGuidelines,
		parameters: Type.Object({ server: serverParam }),
		async execute(_, parameters) {
			const { server } = parameters as { server: string };
			const state = await nvimCall(server, "get_state_brief");
			const current = (state as any).current;
			return {
				content: [{ type: "text", text: `Neovim: ${current.file || "[No Name]"} at ${formatPos(current.cursor)}; visible lines ${current.visibleRange.startLine}-${current.visibleRange.endLine}.` }],
				details: { state },
			};
		},
	});

	pi.registerTool({
		name: "get_state",
		label: "Get Neovim State",
		description: "Return rich context for the current Neovim window: brief state plus visible text, surrounding cursor text, selection text, diagnostics, and Tree-sitter ancestry when available.",
		promptGuidelines: nvimPromptGuidelines,
		parameters: Type.Object({
			server: serverParam,
			contextLines: Type.Optional(Type.Number({ description: "Lines of context around the cursor. Defaults to 20." })),
		}),
		async execute(_, parameters) {
			const { server, contextLines = 20 } = parameters as { server: string; contextLines?: number };
			const state = await nvimCall(server, "get_state", { contextLines }, 10000);
			const current = (state as any).current;
			const selection = current.selection?.text ? ` Selection: ${current.selection.text.length} chars.` : "";
			const symbol = current.symbolAtCursor?.name || current.symbolAtCursor?.kind;
			return {
				content: [{ type: "text", text: `Neovim: ${current.file || "[No Name]"} at ${formatPos(current.cursor)}; visible lines ${current.visibleRange.startLine}-${current.visibleRange.endLine}.${symbol ? ` Symbol: ${symbol}.` : ""}${selection}` }],
				details: { state },
			};
		},
	});

	pi.registerTool({
		name: "read_buffer",
		label: "Read Neovim Buffer",
		description: "Read lines from a loaded Neovim buffer. Line numbers are 1-based; endLine is inclusive. Defaults to the current buffer and the whole file.",
		promptGuidelines: nvimPromptGuidelines,
		parameters: Type.Object({
			server: serverParam,
			buffer: optionalBufferParam,
			startLine: Type.Optional(Type.Number({ description: "1-based start line. Defaults to 1." })),
			endLine: Type.Optional(Type.Number({ description: "1-based inclusive end line. Defaults to the last line." })),
		}),
		async execute(_, parameters) {
			const result = await nvimCall((parameters as any).server, "read_buffer", parameters, 10000);
			const r = result as any;
			return { content: [{ type: "text", text: `Read ${r.lines.length} lines from ${r.file || `buffer ${r.buffer}`} (${r.startLine}-${r.endLine}).` }], details: r };
		},
	});

	pi.registerTool({
		name: "replace_buffer_range",
		label: "Replace Neovim Buffer Range",
		description: "Replace a 1-based inclusive line range in a loaded Neovim buffer. Use startLine=endLine+1 to insert before startLine.",
		promptGuidelines: nvimPromptGuidelines,
		parameters: Type.Object({
			server: serverParam,
			buffer: optionalBufferParam,
			startLine: Type.Number({ description: "1-based start line." }),
			endLine: Type.Number({ description: "1-based inclusive end line. Use startLine-1 for insertion." }),
			lines: Type.Array(Type.String(), { description: "Replacement lines without trailing newlines." }),
		}),
		async execute(_, parameters) {
			const r = (await nvimCall((parameters as any).server, "replace_buffer_range", parameters, 10000)) as any;
			return { content: [{ type: "text", text: `Replaced lines ${r.startLine}-${r.endLine} in ${r.file || `buffer ${r.buffer}`} with ${r.newLineCount} lines.` }], details: r };
		},
	});

	pi.registerTool({
		name: "replace_selection",
		label: "Replace Neovim Selection",
		description: "Replace the active visual selection in the current Neovim buffer.",
		promptGuidelines: nvimPromptGuidelines,
		parameters: Type.Object({ server: serverParam, text: Type.String({ description: "Replacement text." }) }),
		async execute(_, parameters) {
			const r = (await nvimCall((parameters as any).server, "replace_selection", parameters, 10000)) as any;
			return { content: [{ type: "text", text: `Replaced ${r.selection.mode} selection in ${r.file || `buffer ${r.buffer}`}.` }], details: r };
		},
	});

	pi.registerTool({
		name: "apply_text_edits",
		label: "Apply Neovim Text Edits",
		description: "Apply byte-column text edits to a loaded Neovim buffer. Lines and columns are 1-based; ranges are end-exclusive.",
		promptGuidelines: nvimPromptGuidelines,
		parameters: Type.Object({
			server: serverParam,
			buffer: optionalBufferParam,
			edits: Type.Array(Type.Any(), { description: "Edits shaped as {start:{line,column}, end:{line,column}, newText}." }),
		}),
		async execute(_, parameters) {
			const r = (await nvimCall((parameters as any).server, "apply_text_edits", parameters, 10000)) as any;
			return { content: [{ type: "text", text: `Applied ${r.editCount} text edits to ${r.file || `buffer ${r.buffer}`}.` }], details: r };
		},
	});

	pi.registerTool({
		name: "save_buffer",
		label: "Save Neovim Buffer",
		description: "Explicitly save a Neovim buffer. Defaults to the current buffer.",
		promptGuidelines: nvimPromptGuidelines,
		parameters: Type.Object({ server: serverParam, buffer: optionalBufferParam }),
		async execute(_, parameters) {
			const r = (await nvimCall((parameters as any).server, "save_buffer", parameters, 10000)) as any;
			return { content: [{ type: "text", text: `Saved ${r.file || `buffer ${r.buffer}`}.` }], details: r };
		},
	});

	pi.registerTool({
		name: "open_file",
		label: "Open File In Neovim",
		description: "Open a file in Neovim and optionally jump to a 1-based line/column.",
		promptGuidelines: nvimPromptGuidelines,
		parameters: Type.Object({
			server: serverParam,
			path: Type.String(),
			line: Type.Optional(Type.Number({ description: "1-based line." })),
			column: Type.Optional(Type.Number({ description: "1-based byte column." })),
		}),
		async execute(_, parameters) {
			const r = (await nvimCall((parameters as any).server, "open_file", parameters, 10000)) as any;
			return { content: [{ type: "text", text: `Opened ${r.file || (parameters as any).path} at ${formatPos(r.cursor)}.` }], details: r };
		},
	});

	pi.registerTool({
		name: "get_diagnostics",
		label: "Get Neovim Diagnostics",
		description: "Return diagnostics for a buffer or 1-based line range.",
		promptGuidelines: nvimPromptGuidelines,
		parameters: Type.Object({
			server: serverParam,
			buffer: optionalBufferParam,
			startLine: Type.Optional(Type.Number()),
			endLine: Type.Optional(Type.Number()),
		}),
		async execute(_, parameters) {
			const r = (await nvimCall((parameters as any).server, "get_diagnostics", parameters, 10000)) as any;
			return { content: [{ type: "text", text: diagnosticSummary(r) }], details: r };
		},
	});

	pi.registerTool({
		name: "rename_symbol",
		label: "Rename Neovim LSP Symbol",
		description: "Rename the LSP symbol at the cursor or supplied 1-based position and apply the returned workspace edit.",
		promptGuidelines: nvimPromptGuidelines,
		parameters: Type.Object({
			server: serverParam,
			newName: Type.String(),
			line: Type.Optional(Type.Number()),
			column: Type.Optional(Type.Number()),
		}),
		async execute(_, parameters) {
			const r = (await nvimCall((parameters as any).server, "rename_symbol", parameters, 20000)) as any;
			return { content: [{ type: "text", text: `Renamed symbol to ${JSON.stringify((parameters as any).newName)}; ${r.fileCount} files changed, ${r.editCount} edits.` }], details: r };
		},
	});

	pi.registerTool({
		name: "list_code_actions",
		label: "List Neovim Code Actions",
		description: "List LSP code actions at the cursor, active selection, or a supplied 1-based range. Use apply_code_action with a returned actionId.",
		promptGuidelines: nvimPromptGuidelines,
		parameters: Type.Object({
			server: serverParam,
			startLine: Type.Optional(Type.Number()),
			startColumn: Type.Optional(Type.Number()),
			endLine: Type.Optional(Type.Number()),
			endColumn: Type.Optional(Type.Number()),
		}),
		async execute(_, parameters) {
			const raw = (await nvimCall((parameters as any).server, "list_code_actions", parameters, 20000)) as any;
			const actions = (raw.actions || []).map((action: any) => {
				const actionId = `nvim-code-action-${nextCodeActionId++}`;
				codeActionCache.set(actionId, { server: (parameters as any).server, action: action.raw, clientId: action.clientId });
				return { ...action, actionId, raw: undefined };
			});
			const list = actions.map((a: any, i: number) => `${i + 1}. ${a.title}${a.kind ? ` [${a.kind}]` : ""} (${a.actionId})`).join("\n");
			return { content: [{ type: "text", text: actions.length ? `Found ${actions.length} code actions:\n${list}` : "Found 0 code actions." }], details: { ...raw, actions } };
		},
	});

	pi.registerTool({
		name: "apply_code_action",
		label: "Apply Neovim Code Action",
		description: "Apply a code action previously returned by list_code_actions.",
		promptGuidelines: nvimPromptGuidelines,
		parameters: Type.Object({ server: serverParam, actionId: Type.String() }),
		async execute(_, parameters) {
			const { server, actionId } = parameters as { server: string; actionId: string };
			const cached = codeActionCache.get(actionId);
			if (!cached || cached.server !== server) throw new Error(`Unknown code action id: ${actionId}`);
			const r = (await nvimCall(server, "apply_code_action", { action: cached.action, clientId: cached.clientId }, 20000)) as any;
			return { content: [{ type: "text", text: `Applied code action ${actionId}; ${r.fileCount} files changed, ${r.editCount} edits.` }], details: r };
		},
	});

	pi.registerTool({
		name: "format_buffer",
		label: "Format Neovim Buffer",
		description: "Format a buffer via Neovim LSP formatting. Defaults to the current buffer.",
		promptGuidelines: nvimPromptGuidelines,
		parameters: Type.Object({ server: serverParam, buffer: optionalBufferParam, timeoutMs: Type.Optional(Type.Number()) }),
		async execute(_, parameters) {
			const r = (await nvimCall((parameters as any).server, "format_buffer", parameters, 30000)) as any;
			return { content: [{ type: "text", text: `Formatted ${r.file || `buffer ${r.buffer}`}.` }], details: r };
		},
	});

	pi.registerTool({
		name: "organize_imports",
		label: "Organize Neovim Imports",
		description: "Run source.organizeImports code actions for the current buffer.",
		promptGuidelines: nvimPromptGuidelines,
		parameters: Type.Object({ server: serverParam, buffer: optionalBufferParam }),
		async execute(_, parameters) {
			const r = (await nvimCall((parameters as any).server, "organize_imports", parameters, 20000)) as any;
			return { content: [{ type: "text", text: `Organized imports in ${r.file || `buffer ${r.buffer}`}; applied ${r.actionCount} actions.` }], details: r };
		},
	});

	pi.registerTool({
		name: "add_virtual_texts",
		label: "Add Neovim Virtual Texts",
		description: "Add extmark virtual text annotations to a buffer. Lines are 1-based.",
		promptGuidelines: nvimPromptGuidelines,
		parameters: Type.Object({
			server: serverParam,
			buffer: optionalBufferParam,
			namespace: Type.Optional(Type.String({ description: "Namespace name. Defaults to pi-neovim." })),
			texts: Type.Array(Type.Any(), { description: "Annotations shaped as {line, text, hlGroup?, position?}. position: eol|right_align|above|overlay." }),
		}),
		async execute(_, parameters) {
			const r = (await nvimCall((parameters as any).server, "add_virtual_texts", parameters, 10000)) as any;
			return { content: [{ type: "text", text: `Added ${r.marks.length} virtual text annotations to ${r.file || `buffer ${r.buffer}`}.` }], details: r };
		},
	});

	pi.registerTool({
		name: "clear_virtual_texts",
		label: "Clear Neovim Virtual Texts",
		description: "Clear virtual text annotations created in a namespace. Defaults to the pi-neovim namespace and current buffer.",
		promptGuidelines: nvimPromptGuidelines,
		parameters: Type.Object({ server: serverParam, buffer: optionalBufferParam, namespace: Type.Optional(Type.String()) }),
		async execute(_, parameters) {
			const r = (await nvimCall((parameters as any).server, "clear_virtual_texts", parameters, 10000)) as any;
			return { content: [{ type: "text", text: `Cleared virtual text namespace ${r.namespace} in ${r.file || `buffer ${r.buffer}`}.` }], details: r };
		},
	});

	pi.registerTool({
		name: "msgpack_rpc_call",
		label: "MessagePack RPC Call",
		description: "Raw MessagePack-RPC escape hatch for Neovim. Quiet by default; full result is in details.raw.",
		promptGuidelines: [
			...nvimPromptGuidelines,
			"Raw Neovim API indexing follows Neovim's API, not the high-level tool convention.",
		],
		parameters: Type.Object({
			server: serverParam,
			method: Type.String({ description: "RPC API method, for example nvim_get_api_info." }),
			params: Type.Array(Type.Any(), { default: [] }),
			timeout: Type.Optional(Type.Number({ default: 10000 })),
			verbose: Type.Optional(Type.Boolean({ description: "If true, include an inspected form of the raw result in visible content." })),
		}),
		async execute(_, parameters) {
			const { server, method, params = [], timeout = 10000, verbose = false } = parameters as any;
			if (!server || !method) throw new Error("server and method are required");

			const raw = await callRpc(server, method, params, timeout);
			const summary = summarizeRawResult(raw);
			return {
				content: [{ type: "text", text: verbose ? inspect(raw, { depth: null, colors: false, maxArrayLength: null, maxStringLength: null }) : `RPC ${method} returned ${summary}.` }],
				details: { raw },
			};
		},
	});
}


function textResult(text: string): ToolResult {
	return { content: [{ type: "text", text }] };
}

function errorMessage(error: unknown): string {
	return error instanceof Error ? error.message : String(error);
}

function formatPos(pos: any): string {
	if (!pos) return "?:?";
	return `${pos.line}:${pos.column}`;
}

function summarizeRawResult(value: unknown): string {
	if (value == null) return String(value);
	if (typeof value === "string") return `${value.length} chars`;
	if (typeof value === "number" || typeof value === "boolean") return JSON.stringify(value);
	if (Array.isArray(value)) return `array (${value.length} items)`;
	if (typeof value === "object") return `object (${Object.keys(value as Record<string, unknown>).length} keys)`;
	return typeof value;
}

function diagnosticSummary(r: any): string {
	const counts = r.counts || {};
	const parts = ["error", "warning", "info", "hint"].filter((k) => counts[k]).map((k) => `${counts[k]} ${k}${counts[k] === 1 ? "" : "s"}`);
	return `${r.diagnostics?.length || 0} diagnostics in ${r.file || `buffer ${r.buffer}`}${parts.length ? `: ${parts.join(", ")}` : ""}.`;
}
