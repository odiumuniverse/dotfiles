import { diffWords } from "@oh-my-pi/pi-natives";
import {
	getCurrentThemeName,
	getLanguageFromPath,
	highlightCode,
	isLightTheme,
	replaceTabs,
	type Theme,
	visibleWidth,
	wrapTextWithAnsi,
} from "@oh-my-pi/pi-tui";
import { type ToolRenderer, toolRenderers } from "@oh-my-pi/pi-tui/tools";
import { sanitizeText } from "@oh-my-pi/pi-utils";

// Claude Code edit diff look: `  12 +code` rows on full-width tinted bands, syntax colors kept.
// Only the finished result card is restyled; omp's streaming preview draws its own diff.

type Rgb = [number, number, number];
type Marker = "+" | "-" | " ";
type Range = [number, number];
type RenderDiff = (diffText: string, options?: { filePath?: string }) => string;

interface Row {
	marker: Marker;
	num?: number;
	text: string;
	painted: string;
	ranges: Range[];
}

interface Band {
	line: string;
	word: string;
	mark: string;
}

// Palette of Claude Code's color-diff module.
const DARK = { addLine: [2, 40, 0], addWord: [4, 71, 0], addMark: [80, 200, 80], delLine: [61, 1, 0], delWord: [92, 2, 0], delMark: [220, 90, 90] } satisfies Record<string, Rgb>;
const LIGHT = { addLine: [220, 255, 220], addWord: [178, 255, 178], addMark: [36, 138, 61], delLine: [255, 220, 220], delWord: [255, 199, 199], delMark: [207, 34, 46] } satisfies Record<string, Rgb>;
// Claude drops word emphasis when more than this share of a line pair changed.
const WORD_DIFF_MAX_RATIO = 0.4;

const DIM = "\x1b[2m";
const UNDIM = "\x1b[22m";
const FG_DEFAULT = "\x1b[39m";
const RESET = "\x1b[0m";
const CSI = /\x1b\[[0-9;:]*[A-Za-z]/y;

const fg = ([r, g, b]: Rgb) => `\x1b[38;2;${r};${g};${b}m`;
const bg = ([r, g, b]: Rgb) => `\x1b[48;2;${r};${g};${b}m`;

let bandsTheme: string | undefined;
let bandsCache: Record<"+" | "-", Band> | undefined;

function bands(): Record<"+" | "-", Band> {
	const name = getCurrentThemeName();
	if (!bandsCache || bandsTheme !== name) {
		const p = isLightTheme(name) ? LIGHT : DARK;
		bandsTheme = name;
		bandsCache = {
			"+": { line: bg(p.addLine), word: bg(p.addWord), mark: fg(p.addMark) },
			"-": { line: bg(p.delLine), word: bg(p.delWord), mark: fg(p.delMark) },
		};
	}
	return bandsCache;
}

function parseLine(line: string): { marker: Marker; num?: number; content: string } | undefined {
	const m = /^([+-\s])(\s*\d+)\|(.*)$/.exec(line) ?? /^([+-\s])(?:(\s*\d+)\s)?(.*)$/.exec(line);
	if (!m) return undefined;
	const marker = m[1] === "+" || m[1] === "-" ? m[1] : " ";
	return { marker, num: m[2] ? Number.parseInt(m[2], 10) : undefined, content: m[3] ?? "" };
}

// omp numbers removed and context rows by the old file; Claude numbers every row by its position in the new one.
function parse(diffText: string): (Row | string)[] {
	const items: (Row | string)[] = [];
	let delta = 0;
	let removeBase: number | undefined;
	for (const line of sanitizeText(diffText).split("\n")) {
		const parsed = parseLine(line);
		if (!parsed) {
			const trimmed = line.trim();
			items.push(trimmed === "..." || trimmed === "…" ? "" : trimmed && line);
			continue;
		}
		if (parsed.marker === " " && (parsed.content === "..." || parsed.content === "…")) {
			items.push("");
			continue;
		}
		const { marker, num, content } = parsed;
		let shown = num;
		if (marker === "-") {
			removeBase ??= delta;
			if (num !== undefined) shown = num + removeBase;
			delta--;
		} else {
			removeBase = undefined;
			if (marker === "+") delta++;
			else if (num !== undefined) shown = num + delta;
		}
		const text = replaceTabs(content);
		items.push({ marker, num: shown, text, painted: text, ranges: [] });
	}
	return items;
}

function highlightRegion(rows: Row[], lang: string | undefined, theme: Theme): void {
	if (!lang || rows.length === 0) return;
	const oldSide = rows.filter(r => r.marker !== "+");
	const newSide = rows.filter(r => r.marker !== "-");
	const oldLines = highlightCode(oldSide.map(r => r.text).join("\n"), lang, theme);
	const newLines = highlightCode(newSide.map(r => r.text).join("\n"), lang, theme);
	oldSide.forEach((r, i) => {
		if (r.marker === "-") r.painted = oldLines[i] ?? r.text;
	});
	newSide.forEach((r, i) => {
		r.painted = newLines[i] ?? r.text;
	});
}

function markWords(rows: Row[]): void {
	for (let i = 0; i < rows.length; ) {
		if (rows[i].marker !== "-") {
			i++;
			continue;
		}
		const removed: Row[] = [];
		while (rows[i]?.marker === "-") removed.push(rows[i++]);
		const added: Row[] = [];
		while (rows[i]?.marker === "+") added.push(rows[i++]);
		for (let k = 0; k < Math.min(removed.length, added.length); k++) {
			pairWords(removed[k], added[k]);
		}
	}
}

function pairWords(removed: Row, added: Row): void {
	const delRanges: Range[] = [];
	const addRanges: Range[] = [];
	let o = 0;
	let a = 0;
	let changed = 0;
	for (const part of diffWords(removed.text, added.text)) {
		const len = part.value.length;
		if (part.removed) {
			delRanges.push([o, o + len]);
			o += len;
			changed += len;
		} else if (part.added) {
			addRanges.push([a, a + len]);
			a += len;
			changed += len;
		} else {
			o += len;
			a += len;
		}
	}
	if (changed > WORD_DIFF_MAX_RATIO * (removed.text.length + added.text.length)) return;
	removed.ranges = delRanges;
	added.ranges = addRanges;
}

// Lay the band under already highlighted text: word ranges get the brighter tint, resets get the band back.
function paintBand(text: string, band: Band, ranges: Range[]): string {
	let out = "";
	let col = 0;
	let r = 0;
	let inWord = false;
	for (let i = 0; i < text.length; ) {
		CSI.lastIndex = i;
		const esc = text[i] === "\x1b" ? CSI.exec(text) : null;
		if (esc) {
			out += esc[0];
			const params = esc[0].slice(2, -1).split(";");
			if (esc[0].endsWith("m") && params.some(p => p === "" || p === "0" || p === "49")) {
				out += inWord ? band.word : band.line;
			}
			i += esc[0].length;
			continue;
		}
		while (r < ranges.length && col >= ranges[r][1]) r++;
		const want = r < ranges.length && col >= ranges[r][0];
		if (want !== inWord) {
			inWord = want;
			out += want ? band.word : band.line;
		}
		out += text[i];
		i++;
		col++;
	}
	return out;
}

function renderRow(row: Row, numWidth: number, width: number): string[] {
	const gutterWidth = numWidth + 2;
	const gutter = ` ${(row.num?.toString() ?? "").padStart(numWidth)} `;
	const band = row.marker === " " ? undefined : bands()[row.marker];
	const body = band ? paintBand(row.painted, band, row.ranges) : row.painted;
	const avail = width > 0 ? Math.max(1, width - gutterWidth - 1) : 0;
	const segments = avail > 0 ? wrapTextWithAnsi(body, avail) : [body];
	return segments.map((seg, i) => {
		const g = i === 0 ? gutter : " ".repeat(gutterWidth);
		if (!band) return `${DIM}${g} ${UNDIM}${seg}${RESET}`;
		const pad = avail > 0 ? " ".repeat(Math.max(0, avail - visibleWidth(seg))) : "";
		return `${band.line}${band.mark}${g}${row.marker}${FG_DEFAULT}${seg}${band.line}${pad}${RESET}`;
	});
}

function renderClaudeDiff(diffText: string, filePath: string | undefined, width: number, theme: Theme): string {
	const items = parse(diffText);
	const lang = filePath ? getLanguageFromPath(filePath) : undefined;
	let region: Row[] = [];
	const flush = () => {
		highlightRegion(region, lang, theme);
		markWords(region);
		region = [];
	};
	let numWidth = 1;
	for (const item of items) {
		if (typeof item === "string") {
			flush();
			continue;
		}
		region.push(item);
		if (item.num !== undefined) numWidth = Math.max(numWidth, String(item.num).length);
	}
	flush();

	return items
		.flatMap(item => {
			if (typeof item !== "string") return renderRow(item, numWidth, width);
			if (item === "") return [`${DIM}${" ".repeat(numWidth)}…${RESET}`];
			return [`${DIM}${replaceTabs(item)}${RESET}`];
		})
		.join("\n");
}

// The edit card reads `renderContext.renderDiff` at draw time; feed it ours, sized to the card's inner width.
function withClaudeDiff(base: ToolRenderer): ToolRenderer {
	return {
		...base,
		renderResult(result, options, theme, args) {
			let width = 0;
			let fnWidth = -1;
			let fn: RenderDiff | undefined;
			// A new function per width makes the card drop its width-blind rendered-diff cache on resize.
			const renderDiff = (): RenderDiff => {
				if (!fn || fnWidth !== width) {
					const w = width;
					fnWidth = w;
					fn = (text, o) => renderClaudeDiff(text, o?.filePath, w, theme);
				}
				return fn;
			};
			const proxied = new Proxy(options, {
				get(target, key) {
					const value = Reflect.get(target, key);
					return key === "renderContext" ? { ...value, renderDiff: renderDiff() } : value;
				},
			});
			const component = base.renderResult(result, proxied, theme, args);
			if (component) {
				const render = component.render.bind(component);
				component.render = (w: number) => {
					width = Math.max(1, w - 2);
					return render(w);
				};
			}
			return component;
		},
	};
}

// The registry outlives a /reload; wrap omp's original, not the previous load's wrapper.
const BASE = Symbol.for("claude-diff.base");

export default function () {
	for (const name of ["edit", "apply_patch"]) {
		const current = toolRenderers[name] as (ToolRenderer & { [BASE]?: ToolRenderer }) | undefined;
		if (!current) continue;
		const base = current[BASE] ?? current;
		toolRenderers[name] = Object.assign(withClaudeDiff(base), { [BASE]: base });
	}
}
