import {
	READ_ONLY_TOOL_NAMES,
	SEGMENTS,
	type ExtensionAPI,
	type ExtensionContext,
} from "@oh-my-pi/pi-coding-agent";
import { matchesKey, truncateToWidth, type Component } from "@oh-my-pi/pi-tui";

// shift+tab cycles: plan → yolo → accept edits → manual → plan.
// Plan is omp's own plan mode: the key falls through to app.plan.toggle (bound to shift+tab in keybindings.yml).
// Approval is a tool_call gate on top of tools.approvalMode: yolo, so bash always asks in edits/manual.
// shift+tab is a reserved key for registerShortcut, hence the raw input listener.
// Display: the status line "mode" segment shows the CC-style label (hook statuses lose color, setFooter is a no-op);
// goal/vibe/loop/prewalk keep omp's rendering. A widget above the status line shows the session name.

type Approval = "yolo" | "edits" | "manual";

const NEXT: Record<Approval, Approval> = { yolo: "edits", edits: "manual", manual: "yolo" };
const EDIT_TOOLS = new Set(["edit", "write", "ast_edit"]);
const WIDGET_KEY = "session-name";

// Claude Code's dark-theme colors.
// ponytail: dark theme only, add CC's light palette if omp ever runs on a light terminal.
const paint = (rgb: string, text: string) => `\x1b[38;2;${rgb}m${text}\x1b[39m`;
const PLAN_LABEL = paint("72;150;140", "⏸ plan mode on");
const LABEL: Record<Approval, string> = {
	yolo: paint("255;107;128", "⏵⏵ yolo mode on"),
	edits: paint("175;135;255", "⏵⏵ accept edits on"),
	manual: paint("153;153;153", "⏸ manual mode on"),
};

interface ModeSegmentContext {
	planMode?: { enabled?: boolean; paused?: boolean };
	prewalk?: { enabled?: boolean };
	goalMode?: { enabled?: boolean; paused?: boolean };
	vibeMode?: { enabled?: boolean };
	loopMode?: unknown;
}

interface ModeSegment {
	render(this: ModeSegment, ctx: ModeSegmentContext): { content: string; visible: boolean };
}

class SessionName implements Component {
	readonly #ctx: ExtensionContext;

	constructor(ctx: ExtensionContext) {
		this.#ctx = ctx;
	}

	render(width: number): readonly string[] {
		const name = this.#ctx.sessionManager.getSessionName()?.trim() || "untitled";
		return [truncateToWidth(` ${paint("215;119;87", name)}`, width)];
	}
}

function isVanilla(): boolean {
	const args = process.argv;
	return args.some((arg, i) => arg === "--profile=vanilla" || (arg === "--profile" && args[i + 1] === "vanilla"));
}

function planMode(ctx: ExtensionContext): string {
	const branch = ctx.sessionManager.getBranch();
	for (let i = branch.length - 1; i >= 0; i--) {
		const entry = branch[i];
		if (entry.type === "mode_change") {
			return entry.mode;
		}
	}
	return "none";
}

function preview(input: unknown): string {
	const text =
		typeof input === "object" && input !== null && "command" in input
			? String(input.command)
			: JSON.stringify(input);
	return text.length > 400 ? `${text.slice(0, 400)}…` : text;
}

export default function (pi: ExtensionAPI) {
	if (isVanilla()) {
		return;
	}

	let approval: Approval = "yolo";
	let unsubscribe: (() => void) | undefined;

	const mode = (SEGMENTS as unknown as Record<string, ModeSegment | undefined>).mode;
	if (mode) {
		const original = mode.render;
		mode.render = function (ctx) {
			if (ctx.planMode?.enabled) {
				return { content: PLAN_LABEL, visible: true };
			}
			if (ctx.prewalk?.enabled || ctx.goalMode?.enabled || ctx.goalMode?.paused || ctx.vibeMode?.enabled || ctx.loopMode) {
				// shift+tab still cycles approval here, so keep it visible next to omp's own label.
				const own = original.call(this, ctx);
				return { content: `${own.content}${paint("80;80;80", " · ")}${LABEL[approval]}`, visible: true };
			}
			return { content: LABEL[approval], visible: true };
		};
	}

	// No requestRender for extensions; a hook status update refreshes the status line (showHookStatus: false hides it).
	const repaint = (ctx: ExtensionContext) => ctx.ui.setStatus("approval", approval);

	const onShiftTab = (ctx: ExtensionContext) => {
		const current = planMode(ctx);
		if (current === "plan") {
			// Falls through: plan → plan_paused (omp may confirm the exit).
			approval = "yolo";
			return undefined;
		}
		if (current === "none" && approval === "manual") {
			// Falls through: none → plan.
			approval = "yolo";
			return undefined;
		}
		approval = NEXT[approval];
		repaint(ctx);
		// plan_paused also falls through to settle on none; goal/vibe only cycle approval.
		return current === "plan_paused" ? undefined : { consume: true };
	};

	const listen = (ctx: ExtensionContext) => {
		if (!ctx.hasUI || ctx.mode !== "tui") {
			return;
		}
		unsubscribe?.();
		unsubscribe = ctx.ui.onTerminalInput(data => (matchesKey(data, "shift+tab") ? onShiftTab(ctx) : undefined));
		ctx.ui.setWidget(WIDGET_KEY, () => new SessionName(ctx), { placement: "belowEditor" });
	};

	pi.on("session_start", (_event, ctx) => listen(ctx));
	pi.on("session_switch", (_event, ctx) => listen(ctx));

	pi.on("tool_call", async (event, ctx) => {
		if (approval === "yolo" || !ctx.hasUI || READ_ONLY_TOOL_NAMES.has(event.toolName) || planMode(ctx) === "plan") {
			return undefined;
		}
		if (approval === "edits" && EDIT_TOOLS.has(event.toolName)) {
			return undefined;
		}
		const allowed = await ctx.ui.confirm(`Allow ${event.toolName}?`, preview(event.input));
		return allowed ? undefined : { block: true, reason: `User denied ${event.toolName} (${approval} mode)` };
	});
}
