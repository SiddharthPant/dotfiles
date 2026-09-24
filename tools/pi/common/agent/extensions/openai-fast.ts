import type { ExtensionAPI, ExtensionContext } from "@earendil-works/pi-coding-agent";

const SUPPORTED_MODELS = new Set([
	"gpt-5.5",
	"gpt-5.6-sol",
	"gpt-5.6-terra",
	"gpt-5.6-luna",
	"gpt-6-astra",
	"gpt-6-luna",
	"gpt-6-sol",
]);
const states = new WeakMap<object, boolean>();

type Eligibility = { eligible: true } | { eligible: false; reason: string };

function getEligibility(ctx: ExtensionContext): Eligibility {
	const model = ctx.model;
	if (!model) return { eligible: false, reason: "no model is selected" };
	if (model.provider !== "openai-codex" || model.api !== "openai-codex-responses") {
		return { eligible: false, reason: "the selected model is not an OpenAI Codex model" };
	}
	if (!SUPPORTED_MODELS.has(model.id)) {
		return { eligible: false, reason: "the selected model is not supported by Fast mode" };
	}
	if (!ctx.modelRegistry.isUsingOAuth(model)) {
		return { eligible: false, reason: "ChatGPT OAuth authentication is required" };
	}
	return { eligible: true };
}

function isPayload(payload: unknown): payload is Record<string, unknown> {
	return typeof payload === "object" && payload !== null && !Array.isArray(payload);
}

function isEnabled(ctx: ExtensionContext): boolean {
	return states.get(ctx.sessionManager) ?? false;
}

function updateStatus(ctx: ExtensionContext): void {
	if (!ctx.hasUI) return;
	ctx.ui.setStatus("openai-fast", isEnabled(ctx) && getEligibility(ctx).eligible ? "fast" : undefined);
}

export default function (pi: ExtensionAPI) {
	pi.on("session_start", (_event, ctx) => {
		states.set(ctx.sessionManager, false);
		updateStatus(ctx);
	});

	pi.on("model_select", (_event, ctx) => updateStatus(ctx));

	pi.on("before_provider_request", (event, ctx) => {
		updateStatus(ctx);
		if (!isEnabled(ctx) || !getEligibility(ctx).eligible || !isPayload(event.payload)) return;
		if (event.payload.model !== ctx.model?.id || "service_tier" in event.payload) return;
		return { ...event.payload, service_tier: "priority" };
	});

	pi.registerCommand("fast", {
		description: "Toggle OpenAI Codex Fast mode for this session",
		handler: async (args, ctx) => {
			if (args.trim()) {
				ctx.ui.notify("Usage: /fast", "warning");
				return;
			}

			const enabled = !isEnabled(ctx);
			states.set(ctx.sessionManager, enabled);
			updateStatus(ctx);

			const eligibility = getEligibility(ctx);
			const status = enabled ? "enabled" : "disabled";
			const reason = enabled && !eligibility.eligible ? `, but inactive: ${eligibility.reason}` : "";
			ctx.ui.notify(`OpenAI Codex Fast mode ${status}${reason}.`, enabled && !eligibility.eligible ? "warning" : "info");
		},
	});
}
