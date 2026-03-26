#!/usr/bin/env python3
"""
Export Claude Code session to markdown when session ends in ~/topscan/*.
Follows the ai-memory protocol from CLAUDE.md:
  - Filename: [N]-session-[date]-[repo].md
  - Content: Date/Session, Goal, Key Decisions & Actions, Unresolved Issues / Next Steps
"""
import json
import os
import re
import sys
from datetime import datetime
from pathlib import Path


TOPSCAN_ROOT = Path.home() / "topscan"
AI_MEMORY_DIR = TOPSCAN_ROOT / "ai-memory"
PROJECTS_DIR = Path.home() / ".claude" / "projects"


def find_session_file(session_id: str, cwd: str) -> Path | None:
    """Find the JSONL file for the given session_id."""
    sanitized = cwd.lstrip("/").replace("/", "-")
    project_dir = PROJECTS_DIR / ("-" + sanitized)

    if project_dir.exists():
        candidate = project_dir / f"{session_id}.jsonl"
        if candidate.exists():
            return candidate

    # Fallback: search all project dirs
    for d in PROJECTS_DIR.iterdir():
        if d.is_dir():
            candidate = d / f"{session_id}.jsonl"
            if candidate.exists():
                return candidate

    return None


def next_index(ai_memory_dir: Path) -> int:
    """Return the next available [N] index for ai-memory files."""
    max_n = 0
    for f in ai_memory_dir.glob("*.md"):
        m = re.match(r"^(\d+)-", f.name)
        if m:
            max_n = max(max_n, int(m.group(1)))
    return max_n + 1


def extract_text_blocks(content) -> list[str]:
    """Extract only plain text blocks from message content."""
    if isinstance(content, str):
        return [content] if content.strip() else []
    if isinstance(content, list):
        parts = []
        for block in content:
            if isinstance(block, dict) and block.get("type") == "text":
                text = block.get("text", "").strip()
                if text:
                    parts.append(text)
        return parts
    return []


def parse_session(jsonl_path: Path) -> dict:
    """Parse JSONL session into structured data."""
    user_messages = []
    assistant_texts = []
    cwd = ""
    git_branch = ""
    start_time = None
    end_time = None

    with open(jsonl_path, encoding="utf-8") as f:
        for line in f:
            line = line.strip()
            if not line:
                continue
            try:
                entry = json.loads(line)
            except json.JSONDecodeError:
                continue

            entry_type = entry.get("type")
            ts = entry.get("timestamp", "")

            if not cwd:
                cwd = entry.get("cwd", "")
            if not git_branch:
                git_branch = entry.get("gitBranch", "")

            if entry_type in ("user", "assistant"):
                msg = entry.get("message", {})
                content = msg.get("content", "")
                texts = extract_text_blocks(content)

                if ts:
                    if start_time is None:
                        start_time = ts
                    end_time = ts

                if entry_type == "user" and texts:
                    user_messages.append(" ".join(texts))
                elif entry_type == "assistant" and texts:
                    assistant_texts.extend(texts)

    return {
        "cwd": cwd,
        "git_branch": git_branch,
        "start_time": start_time,
        "end_time": end_time,
        "user_messages": user_messages,
        "assistant_texts": assistant_texts,
    }


def build_markdown(session: dict, session_id: str) -> tuple[str, str]:
    """Build markdown content following the ai-memory protocol."""
    cwd = session["cwd"]
    git_branch = session["git_branch"]
    start_time = session["start_time"]
    user_messages = session["user_messages"]
    assistant_texts = session["assistant_texts"]

    # Format date
    if start_time:
        try:
            dt = datetime.fromisoformat(start_time.replace("Z", "+00:00"))
            dt_local = dt.astimezone()
            header_date = dt_local.strftime("%Y-%m-%d %H:%M")
            file_date = dt_local.strftime("%Y-%m-%d")
        except Exception:
            header_date = start_time[:16]
            file_date = start_time[:10]
    else:
        now = datetime.now()
        header_date = now.strftime("%Y-%m-%d %H:%M")
        file_date = now.strftime("%Y-%m-%d")

    # Extract repo name from cwd
    repo = Path(cwd).name if cwd else "unknown"

    # Goal = first user message (trimmed)
    goal = user_messages[0].strip() if user_messages else "—"
    if len(goal) > 300:
        goal = goal[:300] + "…"

    # Key decisions = subsequent user messages as bullet points (they show what was done)
    decisions = []
    for msg in user_messages[1:]:
        msg = msg.strip()
        if msg and len(msg) > 5:
            short = msg if len(msg) <= 200 else msg[:200] + "…"
            decisions.append(f"- {short}")

    # Last user message as "next steps" hint (if it looks like a task/question)
    next_steps = "—"
    if len(user_messages) > 1:
        last = user_messages[-1].strip()
        if len(last) > 10:
            next_steps = last if len(last) <= 300 else last[:300] + "…"

    # Session info line
    session_info = f"`{cwd}`"
    if git_branch:
        session_info += f" / branch `{git_branch}`"

    lines = [
        f"# Session: {repo} — {header_date}",
        "",
        f"- **Date/Session:** {header_date}",
        f"- **Session ID:** `{session_id}`",
        f"- **Directory:** {session_info}",
        "",
        "---",
        "",
        "## Goal",
        "",
        goal,
        "",
        "---",
        "",
        "## Key Decisions & Actions",
        "",
    ]

    if decisions:
        lines.extend(decisions)
    else:
        lines.append("- (single-turn session, no follow-up actions recorded)")

    lines += [
        "",
        "---",
        "",
        "## Unresolved Issues / Next Steps",
        "",
        next_steps,
        "",
    ]

    return "\n".join(lines), file_date, repo


def main():
    try:
        data = json.load(sys.stdin)
    except json.JSONDecodeError:
        sys.exit(0)

    session_id = data.get("session_id", "")
    cwd = data.get("cwd", "")

    # Only run for topscan projects
    if not cwd.startswith(str(TOPSCAN_ROOT)):
        sys.exit(0)

    if not session_id:
        sys.exit(0)

    jsonl_path = find_session_file(session_id, cwd)
    if not jsonl_path:
        sys.exit(0)

    session = parse_session(jsonl_path)
    if not session["user_messages"]:
        sys.exit(0)

    markdown_text, file_date, repo = build_markdown(session, session_id)

    AI_MEMORY_DIR.mkdir(parents=True, exist_ok=True)

    n = next_index(AI_MEMORY_DIR)
    output_file = AI_MEMORY_DIR / f"{n}-session-{file_date}-{repo}.md"
    output_file.write_text(markdown_text, encoding="utf-8")


if __name__ == "__main__":
    main()
