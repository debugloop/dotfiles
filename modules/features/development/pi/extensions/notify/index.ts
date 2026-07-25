/**
 * Desktop Notification Extension
 *
 * Emits a terminal bell (BEL, \x07) when the agent finishes and is waiting for
 * input. Terminals translate this into a window-urgency hint (taskbar/WM
 * attention flag) — no external dependencies, works across Ghostty, Kitty, etc.
 */

import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

/**
 * Ring the terminal bell to raise a window-urgency hint.
 */
const ringBell = (): void => {
	process.stdout.write("\x07");
};

export default function (pi: ExtensionAPI) {
	pi.on("agent_end", async () => {
		ringBell();
	});
}
