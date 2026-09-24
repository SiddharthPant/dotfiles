import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

export default function (pi: ExtensionAPI) {
	pi.registerCommand("exit", {
		description: "Exit pi",
		handler: async (_args, ctx) => ctx.shutdown(),
	});

	pi.on("input", async (event, ctx) => {
		if (!["exit", ":q"].includes(event.text.trim())) return { action: "continue" };
		ctx.shutdown();
		return { action: "handled" };
	});
}
