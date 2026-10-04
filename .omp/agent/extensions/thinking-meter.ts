import type {
	AssistantThinkingRenderContext,
	ExtensionAPI,
} from "@oh-my-pi/pi-coding-agent";
import { Text, type Theme } from "@oh-my-pi/pi-tui";

const BAR_WIDTH = 10;
const MIN_CHARS = 80;

export default function (pi: ExtensionAPI) {
	let enabled = process.env.OMP_THINKING_METER !== "0";
	// Renderers run on every repaint, so count blocks by their position in the message.
	const seen = new Set<string>();
	let maxChars = 0;

	const render = (context: AssistantThinkingRenderContext, activeTheme: Theme) => {
		const chars = context.text.trim().length;
		if (chars < MIN_CHARS) {
			return undefined;
		}
		const id = `${context.contentIndex}:${context.thinkingIndex}`;
		if (!seen.has(id)) {
			seen.add(id);
			maxChars = Math.max(maxChars, chars);
		}
		const filled = Math.max(1, Math.round((chars / maxChars) * BAR_WIDTH));
		const bar = `${"█".repeat(filled)}${"░".repeat(BAR_WIDTH - filled)}`;
		const parts = [
			`${chars.toLocaleString("en-US")} chars`,
			`~${Math.round(chars / 4).toLocaleString("en-US")} tok`,
			`#${seen.size}`,
			bar,
		];
		return new Text(activeTheme.fg("dim", ` thinking · ${parts.join(" · ")}`), 1, 0);
	};

	pi.registerAssistantThinkingRenderer((context, activeTheme) =>
		enabled ? render(context, activeTheme) : undefined,
	);

	pi.registerCommand("thinking-meter", {
		description: "Toggle the thinking-block metrics line",
		handler: async (_args, ctx) => {
			enabled = !enabled;
			ctx.ui.notify(`thinking meter ${enabled ? "on" : "off"}`, "info");
		},
	});
}