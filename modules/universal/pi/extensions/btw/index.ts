/**
 * btw / thread — live side-channel commands for the main conversation.
 *
 * `/btw <text>`   Steer the running main agent. When the agent is mid-turn
 *                 (thinking / between tool calls) the text is queued with
 *                 deliverAs: "steer" and injected after the current assistant
 *                 step, so it is read without waiting for the turn to finish —
 *                 like Claude's `btw`. When the agent is idle it simply starts
 *                 a normal turn.
 *
 * `/thread [text]` Fork the current session into a NEW session opened in a
 *                 fresh Kitty window (the ctrl+shift+enter `new_window` bind),
 *                 with an appended system-prompt note telling the forked agent
 *                 it is a parallel branch. Optional text becomes the first
 *                 message in the fork.
 */

import { spawn } from "node:child_process";

import type {
	ExtensionAPI,
	ExtensionCommandContext,
} from "@earendil-works/pi-coding-agent";

// Note prepended to the forked session's system prompt so the agent understands
// its provenance. Kept short; the full context comes from the forked history.
const FORK_NOTE = [
	"You are running in a FORKED session: a new branch split off from a parallel",
	"conversation that is still live in another window. The history you were",
	"started with is a snapshot of that parent conversation at fork time.",
	"Work independently here — changes in this branch do not flow back to the",
	"parent, and the parent may diverge from you. Treat this as your own thread.",
].join(" ");

function notify(
	ctx: ExtensionCommandContext,
	message: string,
	level: "info" | "warning" | "error",
): void {
	if (ctx.hasUI) {
		ctx.ui.notify(message, level);
	}
}

export default function (pi: ExtensionAPI) {
	// ── /btw — steer the running main agent ────────────────────────────────
	pi.registerCommand("btw", {
		description:
			"Steer the running main agent with live input (read between tool calls / thinking). `/btw <text>`.",
		handler: async (args, ctx) => {
			const text = args.trim();
			if (!text) {
				notify(ctx, "Usage: /btw <text> — steers the running main agent.", "warning");
				return;
			}

			// sendUserMessage always triggers a turn. When the agent is streaming,
			// deliverAs: "steer" injects the message after the current assistant
			// step (between tool calls) instead of waiting for the turn to end.
			// When idle there is nothing to interleave with, so a plain turn is fine.
			if (ctx.isIdle()) {
				pi.sendUserMessage(text);
				notify(ctx, "Sent to main thread.", "info");
			} else {
				pi.sendUserMessage(text, { deliverAs: "steer" });
				notify(ctx, "Steering the running agent…", "info");
			}
		},
	});

	// ── /thread — fork the current session into a new Kitty window ─────────
	pi.registerCommand("thread", {
		description:
			"Fork the current session into a new Kitty window as an independent branch. `/thread [first message]`.",
		handler: async (args, ctx) => {
			const sessionFile = ctx.sessionManager.getSessionFile();
			if (!sessionFile) {
				notify(
					ctx,
					"No saved session to fork (session is ephemeral). Start a persistent session first.",
					"warning",
				);
				return;
			}

			const firstMessage = args.trim();

			// pi --fork <file> creates a NEW session seeded with this session's
			// history; --append-system-prompt injects the fork provenance note.
			const piArgs = ["--fork", sessionFile, "--append-system-prompt", FORK_NOTE];
			if (firstMessage) {
				piArgs.push(firstMessage);
			}

			// kitty spawns the new window (matching the ctrl+shift+enter new_window
			// bind); the pi binary is on PATH via the home-manager wrapper.
			try {
				const child = spawn("kitty", ["pi", ...piArgs], {
					cwd: ctx.cwd,
					detached: true,
					stdio: "ignore",
					env: process.env,
				});
				child.on("error", (err) => {
					notify(ctx, `Failed to open forked thread: ${err.message}`, "error");
				});
				child.unref();
				notify(ctx, "Opened forked thread in a new Kitty window.", "info");
			} catch (err) {
				notify(
					ctx,
					`Failed to open forked thread: ${err instanceof Error ? err.message : String(err)}`,
					"error",
				);
			}
		},
	});
}
