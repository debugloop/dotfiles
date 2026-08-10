/**
 * fork-window — fork the current session into a new Kitty window.
 *
 * `/fork-window [text]` Forks the current session into a NEW session opened in
 *                 a fresh Kitty window (the ctrl+shift+enter `new_window`
 *                 bind), with an appended system-prompt note telling the forked
 *                 agent it is a parallel branch. Optional text becomes the
 *                 first message in the fork.
 *
 * Note: pi's native `/fork` and `/tree` branch in place within the current
 * window. This command is the only way to spin a fork off into a separate
 * parallel window. The pi CLI can only fork a whole session file (`--fork`),
 * not from a selected tree entry, so per-entry forking stays a native in-window
 * operation.
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
	pi.registerCommand("fork-window", {
		description:
			"Fork the current session into a new Kitty window as an independent branch. `/fork-window [first message]`.",
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
					notify(ctx, `Failed to open forked window: ${err.message}`, "error");
				});
				child.unref();
				notify(ctx, "Opened fork in a new Kitty window.", "info");
			} catch (err) {
				notify(
					ctx,
					`Failed to open forked window: ${err instanceof Error ? err.message : String(err)}`,
					"error",
				);
			}
		},
	});
}
