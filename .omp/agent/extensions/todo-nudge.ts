import {
	getLatestTodoPhasesFromEntries,
	type ExtensionAPI,
} from "@oh-my-pi/pi-coding-agent";

// Claude Code-style nudge: omp only reminds about todos before stopping, so long runs leave the list stale.
// After EVERY tool calls without a `todo` call, open tasks get a reminder appended to the next tool result.

const EVERY = 20;
const OPEN = new Set(["pending", "in_progress"]);

function isVanilla(): boolean {
	const args = process.argv;
	return args.some((arg, i) => arg === "--profile=vanilla" || (arg === "--profile" && args[i + 1] === "vanilla"));
}

export default function (pi: ExtensionAPI) {
	if (isVanilla()) {
		return;
	}

	let sinceTodo = 0;
	const reset = () => {
		sinceTodo = 0;
	};

	pi.on("session_start", reset);
	pi.on("session_switch", reset);

	pi.on("tool_call", (event, ctx) => {
		if (event.toolName === "todo") {
			reset();
			return undefined;
		}
		if (++sinceTodo < EVERY) {
			return undefined;
		}
		reset();
		const open = getLatestTodoPhasesFromEntries(ctx.sessionManager.getBranch())
			.flatMap(phase => phase.tasks)
			.filter(task => OPEN.has(task.status));
		if (open.length === 0) {
			return undefined;
		}
		const list = open.map(task => `- [${task.status}] ${task.content}`).join("\n");
		return {
			additionalContext:
				`<system-reminder>\nThe todo list has not been updated in the last ${EVERY} tool calls. Open tasks:\n${list}\n` +
				"If any are done, call `todo` now to mark them completed and set the current one in_progress; " +
				"update the list if the plan changed. Do not mention this reminder to the user.\n</system-reminder>",
		};
	});
}
