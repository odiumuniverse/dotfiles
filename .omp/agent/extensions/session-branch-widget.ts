import type {
	ExtensionAPI,
	ExtensionContext,
	SessionTreeNode,
} from "@oh-my-pi/pi-coding-agent";
import { theme, type Theme } from "@oh-my-pi/pi-tui/theme";
import { truncateToWidth, type Component } from "@oh-my-pi/pi-tui";

const WIDGET_KEY = "session-branch";

interface Snapshot {
	name: string;
	sessionId: string;
	cwdLabel: string;
	branchEntries: number;
	tips: number;
	position: number;
	siblings: number;
}

interface LeafPlacement {
	position: number;
	siblings: number;
}

function findLeafPlacement(
	nodes: readonly SessionTreeNode[],
	leafId: string,
): LeafPlacement | undefined {
	for (const node of nodes) {
		const index = node.children.findIndex(child => child.entry.id === leafId);
		if (index !== -1) {
			return { position: index + 1, siblings: node.children.length };
		}
		const nested = findLeafPlacement(node.children, leafId);
		if (nested) {
			return nested;
		}
	}
	return undefined;
}

function countTips(nodes: readonly SessionTreeNode[]): number {
	let tips = 0;
	const stack = [...nodes];
	while (stack.length > 0) {
		const node = stack.pop();
		if (!node) {
			break;
		}
		if (node.children.length === 0) {
			tips += 1;
		} else {
			stack.push(...node.children);
		}
	}
	return tips;
}

function takeSnapshot(ctx: ExtensionContext): Snapshot {
	const manager = ctx.sessionManager;
	const leafId = manager.getLeafId();
	const tree = manager.getTree();
	const placement = leafId ? findLeafPlacement(tree, leafId) : undefined;
	return {
		name: manager.getSessionName()?.trim() || "untitled",
		sessionId: manager.getSessionId().slice(0, 8),
		cwdLabel: manager.getCwd().split("/").pop() || manager.getCwd(),
		branchEntries: manager.getBranch().length,
		tips: countTips(tree),
		position: placement?.position ?? 0,
		siblings: placement?.siblings ?? 0,
	};
}

function formatLine(activeTheme: Theme, snapshot: Snapshot): string {
	const segments = [activeTheme.fg("accent", snapshot.name)];
	if (snapshot.siblings > 0) {
		segments.push(
			activeTheme.fg(
				"borderAccent",
				`${activeTheme.tree.branch} ${snapshot.position}/${snapshot.siblings}`,
			),
		);
	}
	segments.push(
		activeTheme.fg("muted", `${snapshot.branchEntries} entries`),
		activeTheme.fg("muted", `${snapshot.tips} tip${snapshot.tips === 1 ? "" : "s"}`),
		activeTheme.fg("muted", snapshot.cwdLabel),
		activeTheme.fg("dim", snapshot.sessionId),
	);
	return ` ${segments.join(activeTheme.fg("border", " · "))}`;
}

/** Styles at render time, so a theme switch repaints with the active palette. */
class SessionBar implements Component {
	readonly #snapshot: Snapshot;

	constructor(snapshot: Snapshot) {
		this.#snapshot = snapshot;
	}

	render(width: number): readonly string[] {
		return [truncateToWidth(formatLine(theme, this.#snapshot), width)];
	}
}

export default function (pi: ExtensionAPI) {
	let enabled = true;

	const refresh = (ctx: ExtensionContext) => {
		if (!ctx.hasUI) {
			return;
		}
		const snapshot = takeSnapshot(ctx);
		if (!enabled) {
			ctx.ui.setWidget(WIDGET_KEY, undefined);
			return;
		}
		// RPC and ACP mount string arrays only; component factories are TUI-only.
		if (ctx.mode === "tui") {
			ctx.ui.setWidget(WIDGET_KEY, () => new SessionBar(snapshot), {
				placement: "belowEditor",
			});
			return;
		}
		ctx.ui.setWidget(WIDGET_KEY, [formatLine(theme, snapshot)], {
			placement: "belowEditor",
		});
	};

	pi.registerCommand("branchbar", {
		description: "Toggle the session/branch indicator below the editor",
		handler: async (_args, ctx) => {
			enabled = !enabled;
			refresh(ctx);
			ctx.ui.notify(`branch indicator ${enabled ? "on" : "off"}`, "info");
		},
	});

	pi.on("session_start", async (_event, ctx) => refresh(ctx));
	pi.on("session_switch", async (_event, ctx) => refresh(ctx));
	pi.on("session_branch", async (_event, ctx) => refresh(ctx));
	pi.on("session_tree", async (_event, ctx) => refresh(ctx));
	pi.on("turn_end", async (_event, ctx) => refresh(ctx));
	pi.on("session_shutdown", async (_event, ctx) => {
		ctx.ui.setWidget(WIDGET_KEY, undefined);
	});
}