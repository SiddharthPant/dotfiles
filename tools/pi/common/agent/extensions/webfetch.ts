/**
 * Web fetch for Pi: Jina Reader first (server-side JavaScript rendering, clean
 * markdown), direct HTTP fetch as fallback. Replaces the pi-web-access
 * fetch_content tool for reading pages.
 *
 * Optional Jina API key: JINA_API_KEY environment variable, or "jinaApiKey" in
 * ~/.pi/agent/web-search.json. Without a key the reader allows 20 requests/min.
 */

import { readFileSync } from "node:fs";
import { mkdtemp, writeFile } from "node:fs/promises";
import { homedir, tmpdir } from "node:os";
import { join } from "node:path";
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { Type } from "typebox";

const JINA_READER_URL = "https://r.jina.ai/";
const CONFIG_PATH = join(homedir(), ".pi", "agent", "web-search.json");
const MAX_CHARS = 30_000;
const MIN_USEFUL_CHARS = 100;
const JINA_TIMEOUT_MS = 45_000;
const DIRECT_TIMEOUT_MS = 20_000;
const USER_AGENT = "Mozilla/5.0 (compatible; pi-webfetch)";
const JINA_META_LINE = /^(title|url source|published time|description|keywords|warning)\s*:/i;

interface PageContent {
	title: string;
	text: string;
}

function normalizeUrl(input: string): string {
	const trimmed = input.trim();
	return /^https?:\/\//i.test(trimmed) ? trimmed : `https://${trimmed}`;
}

function withDeadline(timeoutMs: number, signal?: AbortSignal): AbortSignal {
	return signal ? AbortSignal.any([AbortSignal.timeout(timeoutMs), signal]) : AbortSignal.timeout(timeoutMs);
}

let cachedJinaKey: string | null | undefined;

function getJinaKey(): string | null {
	if (cachedJinaKey !== undefined) return cachedJinaKey;
	const fromEnv = process.env.JINA_API_KEY?.trim();
	if (fromEnv) return (cachedJinaKey = fromEnv);
	try {
		const parsed = JSON.parse(readFileSync(CONFIG_PATH, "utf8")) as { jinaApiKey?: unknown };
		cachedJinaKey = typeof parsed.jinaApiKey === "string" && parsed.jinaApiKey.trim() ? parsed.jinaApiKey.trim() : null;
	} catch {
		cachedJinaKey = null;
	}
	return cachedJinaKey;
}

/** Jina returns a "Title: ... / URL Source: ... / Markdown Content:" preamble; drop it. */
function stripJinaPreamble(body: string): string {
	const markerLine = body.search(/^[ \t]*markdown content:[ \t]*$/im);
	if (markerLine >= 0) {
		const nextLine = body.indexOf("\n", markerLine);
		return (nextLine >= 0 ? body.slice(nextLine + 1) : "").trim();
	}
	const lines = body.split("\n");
	if (/^(title|url source)\s*:/i.test(lines[0]?.trim() ?? "")) {
		let start = 0;
		while (start < lines.length && lines[start].trim() !== "" && JINA_META_LINE.test(lines[start].trim())) start++;
		return lines.slice(start).join("\n").trim();
	}
	return body.trim();
}

function firstHeading(text: string): string | null {
	return text.match(/^#{1,2}\s+(.+)$/m)?.[1]?.replace(/\*+/g, "").trim() || null;
}

function jinaTitle(body: string): string | null {
	return body.match(/^title:\s*(.+)$/im)?.[1]?.trim() || null;
}

function htmlToText(html: string): string {
	return html
		.replace(/<(script|style|template|svg|nav|footer|header|noscript|iframe)\b[\s\S]*?<\/\1>/gi, "")
		.replace(/<li\b[^>]*>/gi, "- ")
		.replace(/<\/(p|div|li|h[1-6]|tr|section|article)>/gi, "\n")
		.replace(/<br\s*\/?>/gi, "\n")
		.replace(/<[^>]+>/g, "")
		.replace(/&nbsp;/gi, " ")
		.replace(/&amp;/gi, "&")
		.replace(/&lt;/gi, "<")
		.replace(/&gt;/gi, ">")
		.replace(/&quot;/gi, '"')
		.replace(/&#x27;|&#3?9;/gi, "'")
		.replace(/[ \t]+\n/g, "\n")
		.replace(/\n{3,}/g, "\n\n")
		.trim();
}

async function fetchViaJina(url: string, signal?: AbortSignal): Promise<PageContent | null> {
	const key = getJinaKey();
	const response = await fetch(JINA_READER_URL + url, {
		headers: {
			Accept: "text/markdown",
			"X-No-Cache": "true",
			...(key ? { Authorization: `Bearer ${key}` } : {}),
		},
		signal: withDeadline(JINA_TIMEOUT_MS, signal),
	});
	if (!response.ok) return null;
	const body = await response.text();
	const text = stripJinaPreamble(body);
	if (text.length < MIN_USEFUL_CHARS) return null;
	return { title: firstHeading(text) ?? jinaTitle(body) ?? url, text };
}

async function fetchDirect(url: string, signal?: AbortSignal): Promise<PageContent> {
	const response = await fetch(url, {
		headers: {
			"User-Agent": USER_AGENT,
			Accept: "text/html,text/plain,application/json;q=0.9,*/*;q=0.8",
		},
		signal: withDeadline(DIRECT_TIMEOUT_MS, signal),
	});
	if (!response.ok) throw new Error(`HTTP ${response.status} ${response.statusText}`);
	const contentType = (response.headers.get("content-type") ?? "").toLowerCase();
	if (contentType && !/^(text\/|application\/(json|xml|xhtml))/.test(contentType)) {
		throw new Error(`unsupported content type: ${contentType.split(";")[0] || "unknown"}`);
	}
	const body = await response.text();
	if (contentType.includes("html") || contentType.includes("xml")) {
		const title = body.match(/<title[^>]*>([\s\S]*?)<\/title>/i)?.[1]?.replace(/\s+/g, " ").trim();
		return { title: title || url, text: htmlToText(body) };
	}
	return { title: url, text: body.trim() };
}

/** Cap the model-facing text and keep the full copy in a temp file for the read tool. */
async function boundContent(
	text: string,
	limit: number,
): Promise<{ text: string; truncated: boolean; totalChars: number; fullPath?: string }> {
	if (text.length <= limit) return { text, truncated: false, totalChars: text.length };
	const dir = await mkdtemp(join(tmpdir(), "pi-webfetch-"));
	const fullPath = join(dir, "content.md");
	await writeFile(fullPath, text, "utf8");
	return { text: text.slice(0, limit), truncated: true, totalChars: text.length, fullPath };
}

export default function (pi: ExtensionAPI) {
	pi.registerTool({
		name: "webfetch",
		label: "Web Fetch",
		description:
			`Fetch a URL and return it as markdown. Pages are fetched through the Jina Reader service ` +
			`(JavaScript rendering, 20 req/min without a key) with a direct HTTP fallback. ` +
			`Output is capped at ${MAX_CHARS} chars by default; when truncated, the full text is saved to a temp file to read.`,
		promptSnippet: "Use to fetch and read web pages.",
		parameters: Type.Object({
			url: Type.String({ description: "URL to fetch" }),
			maxChars: Type.Optional(
				Type.Integer({
					minimum: 1000,
					maximum: 200_000,
					description: `Maximum characters to return (default ${MAX_CHARS})`,
				}),
			),
		}),

		async execute(_toolCallId, params, signal) {
			if (!params.url.trim()) throw new Error("url is required");
			const url = normalizeUrl(params.url);
			const limit = params.maxChars ?? MAX_CHARS;

			let page: PageContent | null = null;
			let via: "jina" | "http" = "jina";
			try {
				page = await fetchViaJina(url, signal);
			} catch (err) {
				if (signal?.aborted) throw err;
				page = null;
			}
			if (!page) {
				via = "http";
				try {
					page = await fetchDirect(url, signal);
				} catch (err) {
					throw new Error(`Failed to fetch ${url}: ${err instanceof Error ? err.message : String(err)}`);
				}
			}

			const bounded = await boundContent(page.text, limit);
			const note = bounded.truncated
				? `\n\n---\nShowing ${limit} of ${bounded.totalChars} chars. Full content: ${bounded.fullPath} (read it with the read tool).`
				: "";

			return {
				content: [{ type: "text" as const, text: `# ${page.title}\n\n${bounded.text}${note}` }],
				details: {
					url,
					title: page.title,
					via,
					truncated: bounded.truncated,
					totalChars: bounded.totalChars,
					...(bounded.fullPath ? { fullPath: bounded.fullPath } : {}),
				},
			};
		},
	});
}
