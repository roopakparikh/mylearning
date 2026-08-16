# Study Coach (`/coach`) Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Ship a Claude-ready `coach/` skill bundle (`/coach` full loop + `/coach:setup` and `/coach:<phase>` sub-skills) with Project templates and update docs, matching the approved design spec.

**Architecture:** One markdown skill bundle in-repo. Parent `SKILL.md` orchestrates Probe → Orient → Plan → Teach → Check only when `/coach` is invoked. Each phase and setup is an independently executable sub-skill. Live subject memory lives only in Claude Projects; the bundle ships `_template/` copies via `/coach:setup`. A small structure validator script locks file/heading contracts so agents cannot ship an incomplete bundle.

**Tech Stack:** Markdown skill files for Claude Projects; Python 3 stdlib for `scripts/validate_coach_bundle.py`; GitHub repo for versioning.

**Spec:** `docs/superpowers/specs/2026-08-16-study-coach-design.md`

## Global Constraints

- Platform v1: Claude Projects only (no ChatGPT, NotebookLM, or web companion).
- Invocation names exact: `/coach`, `/coach:setup`, `/coach:probe`, `/coach:orient`, `/coach:plan`, `/coach:teach`, `/coach:check`.
- Full teaching loop runs only via `/coach`; phases must stop after their own work unless the user asks to continue.
- Subject memory (`course` / `routine` / `state` / `log`) must not be stored as live data under the skill repo—only `_template/` blanks.
- Skill updates must never instruct wiping Project `state.md` / `routine.md` by default.
- Tone: calm, non-jargony; prefer Project knowledge; say when unsure.
- Prefer smaller focused files; no TBD/placeholder sections in shipped skill text.

---

## File map

| Path | Responsibility |
|------|----------------|
| `coach/SKILL.md` | `/coach` orchestrator — modes, routing, full loop, when to skip/compress |
| `coach/voice.md` | Shared voice/tone rules included by all skills |
| `coach/setup.md` | `/coach:setup` — Project kit + checklist |
| `coach/phases/probe.md` | `/coach:probe` |
| `coach/phases/orient.md` | `/coach:orient` |
| `coach/phases/plan.md` | `/coach:plan` |
| `coach/phases/teach.md` | `/coach:teach` |
| `coach/phases/check.md` | `/coach:check` |
| `coach/_template/course.md` | Blank subject scaffold |
| `coach/_template/routine.md` | Blank routine with interview prompts |
| `coach/_template/state.md` | Blank mastery state |
| `coach/_template/log.md` | Blank session log |
| `coach/exports/project-instructions.md` | Composed paste target for Claude Project instructions |
| `docs/how-to-update-skills.md` | Parent teaches student how to refresh Projects from GitHub |
| `docs/superpowers/manual-tests/coach-v1.md` | Manual test script from spec |
| `scripts/validate_coach_bundle.py` | Structure + required-heading contract tests |

---

### Task 1: Bundle validator + empty scaffold

**Files:**
- Create: `scripts/validate_coach_bundle.py`
- Create: `coach/.gitkeep` (removed once real files exist — or create dirs via touching placeholders in later tasks)
- Test: run validator (fails until later tasks complete; Task 1 lands validator + expected path list only)

**Interfaces:**
- Consumes: nothing
- Produces: `validate_coach_bundle.py` exit 0 iff all required paths exist and contain required heading substrings defined in the script’s `REQUIRED` dict

- [ ] **Step 1: Write the validator with required paths and headings**

Create `scripts/validate_coach_bundle.py`:

```python
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
```

- [ ] **Step 2: Run validator — expect FAIL (missing files)**

Run: `python3 scripts/validate_coach_bundle.py`  
Expected: `FAIL` with multiple `MISSING` lines; exit code 1

- [ ] **Step 3: Commit validator**

```bash
git add scripts/validate_coach_bundle.py
git commit -m "test: add coach bundle structure validator"
```

---

### Task 2: Voice + Project knowledge templates

**Files:**
- Create: `coach/voice.md`
- Create: `coach/_template/course.md`
- Create: `coach/_template/routine.md`
- Create: `coach/_template/state.md`
- Create: `coach/_template/log.md`

**Interfaces:**
- Consumes: validator `REQUIRED` headings for these files
- Produces: shared voice rules; blank templates `/coach:setup` copies into Claude Project knowledge

- [ ] **Step 1: Write `coach/voice.md`**

```markdown
# Voice

You are a calm study coach for a college student who is not a CS major.
Prefer plain language. Short paragraphs. No jargon without a one-line gloss.

## Do

- Sound like a patient tutor, not a textbook or a hype bot.
- Check understanding with small questions.
- Prefer this Claude Project's knowledge files (`course.md`, `routine.md`, `state.md`, `log.md`, syllabus/notes) when present.
- Say when you are unsure; suggest verifying with lecture/textbook.
- Put struggle into the material, not into logistics.

## Don't

- Dump a whole chapter in one message.
- Shame "I don't know" answers.
- Invent citations or fake certainty.
- Jump to another subject that belongs in a different Claude Project.
- Wipe or blank `routine.md` / `state.md` unless the user explicitly confirms a reset.
```

- [ ] **Step 2: Write `_template/course.md`**

```markdown
# Course

## Subject
<!-- e.g. Biology 101 -->

## Goals this term
-

## Topic map
<!-- High-level units; fill during setup or from syllabus -->
-

## Common misconceptions
-

## Source notes
<!-- What was uploaded to this Project: syllabus, chapters, etc. -->
-
```

- [ ] **Step 3: Write `_template/routine.md`**

```markdown
# Routine

## Schedule
- Class / lab times:
- Typical homework nights:
- Exam / quiz dates:

## Study habits
- Preferred session length:
- Best time of day:
- Notes on how this student learns this subject:

## Preferences
- Full loop vs single phases when unsure:
- Homework: guide-first (default yes):
```

- [ ] **Step 4: Write `_template/state.md`**

```markdown
# State

## Current unit
Not probed yet.

## Strong
-

## Weak
-

## Next focus
-

## Last session
- Date:
- Outcome:
```

- [ ] **Step 5: Write `_template/log.md`**

```markdown
# Log

<!-- Append-only session lines: YYYY-MM-DD | topic | outcome | next focus -->
```

- [ ] **Step 6: Re-run validator**

Run: `python3 scripts/validate_coach_bundle.py`  
Expected: still FAIL, but voice + template paths no longer listed as MISSING (only skills / export missing)

- [ ] **Step 7: Commit**

```bash
git add coach/voice.md coach/_template/
git commit -m "feat(coach): add voice and Project knowledge templates"
```

---

### Task 3: Phase skills — probe, orient, plan

**Files:**
- Create: `coach/phases/probe.md`
- Create: `coach/phases/orient.md`
- Create: `coach/phases/plan.md`

**Interfaces:**
- Consumes: `voice.md` rules; Project `state.md` / `routine.md` / `course.md`
- Produces: standalone `/coach:probe`, `/coach:orient`, `/coach:plan` procedures with explicit stop conditions

- [ ] **Step 1: Write `coach/phases/probe.md`**

Must include headings required by validator. Core content:

```markdown
# /coach:probe

Read `voice.md` rules. Read Project `state.md`, `routine.md`, and `course.md` if present.

## Goal
Map the edge of the student's understanding for a stated topic or goal. Do not teach the full topic here.

## Procedure
1. Clarify the topic/goal in one line if unclear.
2. Ask a short sequence of graded questions (multiple choice or short answer), hardest-needed-first or binary-search style across prerequisites.
3. Treat "I don't know" as valid data; mark the gap; do not shame.
4. Skip areas already marked Strong in `state.md` unless the user asks to re-check.
5. Summarize: known / shaky / missing.

## Stop condition
Stop after the summary. Propose a brief `state.md` patch for Strong/Weak/Next focus if useful.
Do **not** auto-start Orient, Plan, Teach, or Check unless the user asks.
```

- [ ] **Step 2: Write `coach/phases/orient.md`**

```markdown
# /coach:orient

Read `voice.md`. Use `state.md` and `course.md` when present.

## Goal
Teach the **one core concept** for this session's goal so the destination clicks—before deep prerequisites or a full plan.

## Procedure
1. Name the core concept in plain language (1–3 short messages max for the explanation).
2. No prerequisite dump. If a blocking gap appears, give at most a tiny bridge or note it for Plan/Probe.
3. End with one confirmation check question.

## Stop condition
Stop after the confirmation check (and brief feedback on their answer).
Do **not** auto-start Plan/Teach unless asked.
```

- [ ] **Step 3: Write `coach/phases/plan.md`**

```markdown
# /coach:plan

Read `voice.md`, `state.md`, and any prior probe/orient context in-chat.

## Goal
Produce a clear learning path from current understanding to the goal.

## Procedure
1. State the goal and assumed starting point (from `state.md` or user).
2. List steps in plain language (optional mermaid dependency sketch).
3. Mark which steps are must-have vs optional for exam-soon if `routine.md` implies urgency.
4. Ask if the plan looks right before teaching—unless user said "just plan."

## Stop condition
Stop when the plan is delivered (and acknowledged if you asked).
Do **not** auto-start Teach unless asked.
```

- [ ] **Step 4: Run validator**

Run: `python3 scripts/validate_coach_bundle.py`  
Expected: FAIL only on remaining missing files (`teach`, `check`, `setup`, `SKILL`, `exports`)

- [ ] **Step 5: Commit**

```bash
git add coach/phases/probe.md coach/phases/orient.md coach/phases/plan.md
git commit -m "feat(coach): add probe, orient, and plan phase skills"
```

---

### Task 4: Phase skills — teach, check

**Files:**
- Create: `coach/phases/teach.md`
- Create: `coach/phases/check.md`

**Interfaces:**
- Consumes: plan or explicit topic; `state.md`
- Produces: `/coach:teach`, `/coach:check` with write-back format for state/log

- [ ] **Step 1: Write `coach/phases/teach.md`**

```markdown
# /coach:teach

Read `voice.md`. Prefer an existing plan in-chat or in `state.md` Next focus; else teach the user-stated topic.

## Goal
Advance understanding one reasoning step at a time.

## Procedure
1. Teach **one** reasoning step per message (or one tight micro-cluster if the user asked for a quick pass).
2. Invite questions; do not rush the whole plan.
3. For homework: guide with hints and structure; do not spoil the final answer until they attempt or explicitly ask you to verify/reveal.
4. After a step, optionally offer a tiny check or wait for "got it" / next.

## Stop condition
Stop when the user pauses, the requested step(s) are done, or they switch intent.
Do **not** silently run the entire remaining plan unless they asked for that.
```

- [ ] **Step 2: Write `coach/phases/check.md`**

```markdown
# /coach:check

Read `voice.md` and `state.md` (quiz weak spots if no topic given).

## Goal
Verify understanding with graded questions; calibrate memory.

## Procedure
1. Quiz on the stated topic, recent material, or Weak items in `state.md`.
2. Score plainly; explain misses briefly; offer a reteach pointer (suggest `/coach:teach` or continue if user wants).
3. If within ~48h of an exam per `routine.md`, bias toward high-yield items.

## Stop condition
Stop after feedback on the quiz set unless the user asks to continue.

## State update
Always end a meaningful check with copy-paste blocks:

## State update — replace Project file `state.md` with:
(full updated markdown)

## Log append — add to `log.md`:
- YYYY-MM-DD: topic; outcome; next focus
```

- [ ] **Step 3: Run validator**

Expected: FAIL only on `SKILL.md`, `setup.md`, `exports/project-instructions.md`

- [ ] **Step 4: Commit**

```bash
git add coach/phases/teach.md coach/phases/check.md
git commit -m "feat(coach): add teach and check phase skills"
```

---

### Task 5: `/coach:setup` skill

**Files:**
- Create: `coach/setup.md`

**Interfaces:**
- Consumes: `coach/_template/*`
- Produces: Project instructions pointer + four knowledge files + checklist; never creates Projects via API

- [ ] **Step 1: Write `coach/setup.md`**

```markdown
# /coach:setup

Initializer only. Do not run Probe/Orient/Plan/Teach/Check.

## Goal
Help the user stand up a Claude Project for one subject with the Coach bundle templates.

## Steps
1. Parse `<subject-name>` (ask if missing). Suggest Project title: `Study Coach — <Subject>`.
2. From `_template/`, produce customized drafts of `course.md`, `routine.md`, `state.md`, `log.md` (fill Subject; keep state as "Not probed yet" unless regenerating carefully).
3. If files already exist in context, update scaffolding fields but **do not** wipe `state.md` / `routine.md` personal content unless Reset policy applies.
4. Run a short interview (schedule, exams, study habits) and fill `routine.md`.
5. Point the user to paste composed instructions from `exports/project-instructions.md` (or assemble from `SKILL.md` + `voice.md` + `phases/*` + `setup.md`).
6. Emit checklist:
   - Create empty Claude Project named `Study Coach — <Subject>`
   - Paste Project instructions
   - Upload `course.md`, `routine.md`, `state.md`, `log.md`
   - Start a chat with `/coach` or a `/coach:<phase>` command

## Reset policy
If the user asks to re-run setup on an existing subject:
- Warn that templates can overwrite Project knowledge.
- Preserve `state.md` and `routine.md` by default.
- Only blank/replace them if the user explicitly confirms reset.
```

- [ ] **Step 2: Run validator**

Expected: FAIL only on `SKILL.md` and `exports/project-instructions.md`

- [ ] **Step 3: Commit**

```bash
git add coach/setup.md
git commit -m "feat(coach): add /coach:setup skill"
```

---

### Task 6: Parent orchestrator `/coach` + composed export

**Files:**
- Create: `coach/SKILL.md`
- Create: `coach/exports/project-instructions.md`

**Interfaces:**
- Consumes: all phase skills + setup + voice
- Produces: full-loop orchestration; single paste file for Claude Project instructions

- [ ] **Step 1: Write `coach/SKILL.md`**

Must include exact headings from validator. Content requirements:

```markdown
# /coach

Parent skill for Study Coach. Follow `voice.md`.

## When to use
- User invokes `/coach` or clearly wants a full learn session on a topic.
- Ambiguous "help me learn X" → this skill (full loop), not a single phase.

## Routing
| User intent | Skill |
|-------------|--------|
| Full learn / lost on topic / teach me properly | `/coach` (this file) |
| Set up subject Project | `/coach:setup` |
| Only quiz / only plan / only … | matching `/coach:<phase>` |

If user names a phase, defer to that phase skill and do not force the full loop.

## Full loop
Default recommended order (say briefly if you skip/compress a step):
1. Probe → 2. Orient → 3. Plan → 4. Teach → 5. Check → 6. State/log write-back

Read `routine.md` and `state.md` first. Skip Probe items already Strong unless re-check requested.

## Modes
- **Understand:** full loop.
- **Homework:** targeted probe/teach/check; guide-first; no instant spoil.
- **Exam:** if exam within ~48h in `routine.md`, shorter Orient, high-yield Plan, more Check.
- **What's next:** use state+routine; suggest next edge topic (may be a light plan).

## Independence note
Phases are independently executable via `/coach:*`. Only `/coach` owns full-loop orchestration. Sub-skills must not silently start the entire loop.
```

Expand each section with enough operational detail that Claude can run without the phase files alone—but still instruct “follow the matching phase skill text when executing that step.”

- [ ] **Step 2: Build `coach/exports/project-instructions.md`**

Concatenate in order with clear separators:

1. Title `# Study Coach` and one-liner that `/coach` and `/coach:*` commands apply  
2. Full contents of `voice.md`  
3. Full contents of `SKILL.md`  
4. Full contents of `setup.md`  
5. Each file under `phases/` in order probe, orient, plan, teach, check  

Header note at top:

```markdown
# Study Coach — Claude Project instructions

Paste this entire file into the Claude Project instructions for one subject.
Upload that subject's `course.md`, `routine.md`, `state.md`, and `log.md` as Project knowledge.
Invoke `/coach` for the full loop, or `/coach:setup` / `/coach:probe` / `/coach:orient` / `/coach:plan` / `/coach:teach` / `/coach:check` for a single skill.
```

Implementation tip: generate via a short shell snippet when writing the file so it cannot drift:

```bash
{
  echo '# Study Coach — Claude Project instructions'
  echo
  echo 'Paste this entire file into the Claude Project instructions for one subject.'
  echo 'Upload course.md, routine.md, state.md, and log.md as Project knowledge.'
  echo 'Commands: `/coach`, `/coach:setup`, `/coach:probe`, `/coach:orient`, `/coach:plan`, `/coach:teach`, `/coach:check`.'
  echo
  echo '---'
  cat coach/voice.md
  echo
  echo '---'
  cat coach/SKILL.md
  echo
  echo '---'
  cat coach/setup.md
  for f in probe orient plan teach check; do echo; echo '---'; echo; cat "coach/phases/$f.md"; done
} > coach/exports/project-instructions.md
```

- [ ] **Step 3: Run validator — expect PASS**

Run: `python3 scripts/validate_coach_bundle.py`  
Expected: `PASS: coach bundle structure OK` (exit 0)

- [ ] **Step 4: Commit**

```bash
git add coach/SKILL.md coach/exports/project-instructions.md
git commit -m "feat(coach): add /coach orchestrator and Project instructions export"
```

---

### Task 7: Docs — update guide + manual tests

**Files:**
- Create: `docs/how-to-update-skills.md`
- Create: `docs/superpowers/manual-tests/coach-v1.md`
- Modify: `README.md` (create if missing) with one-paragraph pointer to Coach + spec/plan links

**Interfaces:**
- Consumes: finished bundle + export path
- Produces: parent/student update playbook; manual QA checklist from spec

- [ ] **Step 1: Write `docs/how-to-update-skills.md`**

Include:
- Pull latest from GitHub
- Regenerate or copy `coach/exports/project-instructions.md` into each subject Project’s instructions
- Do **not** replace `state.md` / `routine.md` with blank templates
- When to run `/coach:setup` vs instruction-only refresh
- How parent teaches student this once

- [ ] **Step 2: Write `docs/superpowers/manual-tests/coach-v1.md`**

Checkbox cases matching spec:

1. `/coach:setup bio-demo` — kit + checklist clear  
2. `/coach` “lost on [topic]” — default phase order, one-step teach  
3. Each `/coach:<phase>` alone — stops after that phase; uses Project memory  
4. Homework paste — guide-first  
5. Exam in 48h in `routine.md` — compressed `/coach`  
6. Bundle tweak → refresh instructions only — memory untouched  

- [ ] **Step 3: Write/update root `README.md`**

Short: what this repo is; link to design spec, this plan, `coach/`, how-to-update, validator command.

- [ ] **Step 4: Run validator again**

Run: `python3 scripts/validate_coach_bundle.py`  
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add docs/how-to-update-skills.md docs/superpowers/manual-tests/coach-v1.md README.md
git commit -m "docs: add Coach update guide and v1 manual tests"
```

---

## Spec coverage checklist (author self-review)

| Spec requirement | Task |
|------------------|------|
| Skill bundle vs Claude Project memory split | 2, 5, 7 |
| `/coach` full loop only | 6 |
| Independent `/coach:*` phases | 3, 4, 6 |
| `/coach:setup` kit + reset policy | 5 |
| Probe → Orient → Plan → Teach → Check | 3, 4, 6 |
| Write-back `state.md` / `log.md` | 4 |
| Modes understand/homework/exam/what’s next | 6 |
| Voice / no fake certainty | 2 |
| Export Project instructions | 6 |
| How to update skills | 7 |
| Manual tests | 7 |
| No live `subjects/bio` under skill repo | 2, 5 (templates only) |

## Placeholder scan

No TBD/TODO in task bodies; validator headings are exact; file paths are exact.

---

## Execution handoff

Plan complete and saved to `docs/superpowers/plans/2026-08-16-study-coach.md`. Two execution options:

**1. Subagent-Driven (recommended)** — dispatch a fresh subagent per task, review between tasks, fast iteration  

**2. Inline Execution** — execute tasks in this session using executing-plans, batch execution with checkpoints  

Which approach?
