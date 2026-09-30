/**
 * clone-window — clone the active session path into a new Kitty window.
 *
 * `/clone-window [text]` creates a new session from the current tree position.
 * The parent session stays open. Optional text becomes the clone's first message.
 */

import { spawn } from "node:child_process";

import {
	SessionManager,
	type ExtensionAPI,
	type ExtensionCommandContext,
} from "@earendil-works/pi-coding-agent";

const CLONE_NOTE = [
	"You are running in a cloned session in another window.",
	"Its history is the parent session's active path at clone time.",
	"Continue independently because later messages do not sync between sessions.",
	"The clone starts in the same working directory unless you use a separate worktree.",
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
	pi.registerCommand("clone-window", {
		description:
			"Clone the active session path into a new Kitty window. `/clone-window [first message]`.",
		handler: async (args, ctx) => {
			await ctx.waitForIdle();

			const sessionFile = ctx.sessionManager.getSessionFile();
			const leafId = ctx.sessionManager.getLeafId();
			if (!sessionFile || !leafId) {
				notify(
					ctx,
					"No saved session path to clone. Complete one response first.",
					"warning",
				);
				return;
			}

			try {
				const cloneFile = SessionManager.open(sessionFile).createBranchedSession(leafId);
				if (!cloneFile) {
					throw new Error("Pi did not create a clone file");
				}

				const piArgs = [
					"--session",
					cloneFile,
					"--append-system-prompt",
					CLONE_NOTE,
				];
				const firstMessage = args.trim();
				if (firstMessage) {
					piArgs.push(firstMessage);
				}

				const child = spawn("kitty", ["pi", ...piArgs], {
					cwd: ctx.cwd,
					detached: true,
					stdio: "ignore",
					env: process.env,
				});
				child.on("error", (error) => {
					notify(ctx, `Failed to open cloned window: ${error.message}`, "error");
				});
				child.unref();
				notify(ctx, "Opened the clone in a new Kitty window.", "info");
			} catch (error) {
				notify(
					ctx,
					`Failed to clone the session: ${error instanceof Error ? error.message : String(error)}`,
					"error",
				);
			}
		},
	});
}
