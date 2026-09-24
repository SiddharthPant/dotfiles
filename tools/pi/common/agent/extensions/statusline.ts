import type { ExtensionAPI, ExtensionContext } from "@earendil-works/pi-coding-agent";

type TokenEvent = { time: number; tokens: number };

type MessageUpdate = {
	assistantMessageEvent?: {
		type: string;
		delta?: string;
		partial?: { usage?: { output?: number } };
	};
};

const WINDOW_MS = 1_000;
const MIN_SPAN_MS = 100;

function countFallbackTokens(text: string): number {
	// Approximate tokens when the provider has not reported a cumulative count.
	const matches = text.match(/\w+|[^\s\w]/g);
	return matches?.length ?? 0;
}

function showSpeed(ctx: ExtensionContext, tps: number): void {
	let color: "error" | "warning" | "success" | "accent" = "error";
	if (tps >= 45) color = "accent";
	else if (tps >= 30) color = "success";
	else if (tps >= 15) color = "warning";
	ctx.ui.setStatus("local-token-speed", `${ctx.ui.theme.fg("muted", "⚡")} ${ctx.ui.theme.fg(color, `${tps.toFixed(1)} tok/s`)}`);
}

export default function (pi: ExtensionAPI) {
	let events: TokenEvent[] = [];
	let activeContext: ExtensionContext | undefined;
	let countedProviderOutput = 0;
	let streamTokens = 0;
	let streamStartedAt = 0;

	const reset = () => {
		events = [];
		countedProviderOutput = 0;
		streamTokens = 0;
		streamStartedAt = Date.now();
	};

	const record = (ctx: ExtensionContext, tokens: number) => {
		if (tokens <= 0) return;
		const now = Date.now();
		streamTokens += tokens;
		events.push({ time: now, tokens });
		events = events.filter((event) => event.time >= now - WINDOW_MS);

		const windowTokens = events.reduce((sum, event) => sum + event.tokens, 0);
		const elapsed = Math.max(now - events[0].time, MIN_SPAN_MS);
		showSpeed(ctx, (windowTokens * 1_000) / elapsed);
	};

	pi.on("session_start", async (_event, ctx) => {
		activeContext = ctx;
		ctx.ui.setWidget("portable-statusline", undefined);
		ctx.ui.setStatus("local-token-speed", undefined);
	});

	pi.on("agent_start", () => reset());

	pi.on("message_update", (event: MessageUpdate, ctx) => {
		const update = event.assistantMessageEvent;
		if (!update) return;
		if (update.type !== "text_delta" && update.type !== "thinking_delta") return;

		activeContext = ctx;
		const reportedOutput = update.partial?.usage?.output;
		if (reportedOutput !== undefined && reportedOutput > countedProviderOutput) {
			const increment = reportedOutput - countedProviderOutput;
			countedProviderOutput = reportedOutput;
			record(ctx, increment);
		} else {
			// Match pi-token-speed's default direct counting: one token per stream delta.
			// Use a text estimate when a delta contains multiple token-like pieces.
			record(ctx, Math.max(1, countFallbackTokens(update.delta ?? "")));
		}
	});

	pi.on("agent_end", () => {
		if (!activeContext || streamTokens === 0) return;
		const elapsed = Math.max((Date.now() - streamStartedAt) / 1_000, 0.1);
		showSpeed(activeContext, streamTokens / elapsed);
	});

	pi.on("session_shutdown", () => {
		if (activeContext) activeContext.ui.setStatus("local-token-speed", undefined);
		activeContext = undefined;
	});
}
