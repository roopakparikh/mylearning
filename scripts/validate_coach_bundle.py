#!/usr/bin/env python3
"""Validate coach/ skill bundle structure and required headings."""
from __future__ import annotations

import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
COACH = ROOT / "coach"

REQUIRED: dict[str, list[str]] = {
    "SKILL.md": ["# /coach", "## When to use", "## Full loop", "## Modes", "## Routing"],
    "voice.md": ["# Voice", "## Do", "## Don't"],
    "setup.md": ["# /coach:setup", "## Steps", "## Reset policy"],
    "phases/probe.md": ["# /coach:probe", "## Goal", "## Procedure", "## Stop condition"],
    "phases/orient.md": ["# /coach:orient", "## Goal", "## Procedure", "## Stop condition"],
    "phases/plan.md": ["# /coach:plan", "## Goal", "## Procedure", "## Stop condition"],
    "phases/teach.md": ["# /coach:teach", "## Goal", "## Procedure", "## Stop condition"],
    "phases/check.md": ["# /coach:check", "## Goal", "## Procedure", "## Stop condition", "## State update"],
    "_template/course.md": ["# Course", "## Subject", "## Topic map"],
    "_template/routine.md": ["# Routine", "## Schedule", "## Study habits"],
    "_template/state.md": ["# State", "## Current unit", "## Strong", "## Weak", "## Next focus"],
    "_template/log.md": ["# Log"],
    "exports/project-instructions.md": ["# Study Coach", "/coach"],
}

def main() -> int:
    errors: list[str] = []
    for rel, headings in REQUIRED.items():
        path = COACH / rel
        if not path.is_file():
            errors.append(f"MISSING {rel}")
            continue
        text = path.read_text(encoding="utf-8")
        if rel == "SKILL.md":
            if not text.startswith("---"):
                errors.append("SKILL.md must start with YAML frontmatter (---)")
            else:
                end = text.find("\n---", 3)
                fm = text[3:end] if end != -1 else ""
                if "name:" not in fm:
                    errors.append("SKILL.md frontmatter missing name:")
                if "description:" not in fm:
                    errors.append("SKILL.md frontmatter missing description:")
        for h in headings:
            if h not in text:
                errors.append(f"MISSING HEADING in {rel}: {h!r}")
    if errors:
        print("FAIL")
        for e in errors:
            print(f"  - {e}")
        return 1
    print("PASS: coach bundle structure OK")
    return 0

if __name__ == "__main__":
    sys.exit(main())
