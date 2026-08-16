# Study Coach — Design Spec

**Date:** 2026-08-16  
**Status:** Draft for review  
**Platform (v1):** Claude (Projects)  
**Audience:** College student, non-CS major; parent maintains skill bundle and teaches updates

## Problem

Normal learning is inefficient: one course serves many students, and one student juggles many sources. Ideal is one trusted teacher interface fitted to one mind. We encode that as an AI Study Coach inspired by [How I Use AI to Learn Things](https://www.youtube.com/watch?v=kzcI5F4tGiU), adapted so a non-CS college student can use it inside Claude Projects they already understand.

## Goals

- Teach at the **edge of understanding** (don’t reteach what’s known; don’t jump ahead).
- Put struggle into the **material**, not logistics (planning, ordering, “what next”).
- Meet the student in **Claude**, per subject, with an invokable skill bundle.
- Support: understand lectures, homework with real understanding, exam prep, and “what should I study next.”
- Parent owns the skill bundle on GitHub; student owns subject memory inside each Claude Project.

## Non-goals (v1)

- NotebookLM integration (planned v2 as source binder)
- ChatGPT Custom GPT mirror
- Web companion / quiz app
- Programmatic Claude Project creation via API (not available for consumer Projects)
- Auto-editing Project knowledge files without the student pasting updates

## Core separation

| Concern | Where it lives | Who updates |
|--------|----------------|-------------|
| Pedagogy (skill bundle) | GitHub repo (`study-coach/`) | Parent; student learns to refresh Projects from it |
| Subject + personal memory | **Inside each Claude Project** | Student (and parent lightly); never stored as live data under the skill repo |

The skill repo must **not** contain a live `subjects/bio/` (or similar) tree for the student’s progress. Templates used at setup may live in the bundle; after setup, course/routine/state/log belong to the Project.

## Architecture

### Skill bundle (one bundle, many skills)

```
study-coach/
├── SKILL.md                 # Parent orchestrator
├── voice.md                 # Calm, non-jargony tutor tone
├── setup-study-coach.md     # Setup skill (initializer only)
├── phases/                  # Sub-skills invoked by parent
│   ├── probe.md
│   ├── orient.md
│   ├── plan.md
│   ├── teach.md
│   └── check.md
└── _template/               # Copied into a Claude Project at setup — not live memory
    ├── course.md
    ├── routine.md
    ├── state.md
    └── log.md
```

Plus repo docs (e.g. `docs/how-to-update-skills.md`) for the parent’s walkthrough with the student.

### Claude Project (per subject)

Example: Project name `Study Coach — Bio`

```
Project instructions  ← composed from SKILL.md + voice.md + phases/*
Project knowledge
├── course.md         ← subject scaffold / misconceptions / topic map
├── routine.md        ← THIS student's schedule & study habits for this subject
├── state.md          ← mastery edge, weak/strong topics, current unit
├── log.md            ← optional short session outcomes
└── (later) syllabus, lecture PDFs, notes
```

Chem (or any new subject) = **another Project** with its own knowledge files. Memory does not bleed across subjects.

### Setup skill

**Invocation:** `/setup-study-coach <subject-name>` (or equivalent natural language).

**Does:**

1. Create from `_template/` the four knowledge files customized for `<subject-name>`.
2. Optionally run a short interview and fill `routine.md`.
3. Emit **Project instructions** text (full bundle composition) ready to paste.
4. Emit a checklist: create empty Claude Project → paste instructions → upload the four files → start chatting.

**Does not:**

- Run the teaching loop.
- Create a Claude Project via API (impossible on consumer Claude today).
- Write live student memory into the skill GitHub repo.

### Bundle → Project sync (ongoing)

1. Parent updates bundle → push GitHub.
2. Student refreshes **Project instructions** from the new bundle.
3. Student does **not** replace `routine.md` / `state.md` with blank templates unless deliberately resetting.
4. Skill updates must never instruct wiping personal memory files by default.

## Teaching loop

Parent skill selects mode, reads Project `routine.md` + `state.md`, then runs:

1. **Probe** — Short graded questions to map the edge of understanding; skip what’s already solid in `state.md`. “I don’t know” is valid.
2. **Orient** — Teach the **one core concept** for this session’s goal (short; 1–3 messages). Not a full prerequisite dump. One confirmation check. Then proceed to Plan.
3. **Plan** — Path from probe map toward that core idea (and dependents). Plain-language step list; optional mermaid. Forces the model to reason before teaching.
4. **Teach** — **One reasoning step per message.** Wait for understanding / questions / check before advancing.
5. **Check** — Periodic quizzes; wrong → reteach or smaller step; right → continue.
6. **Write-back** — Propose updated `state.md` (and optional `log.md` line) for the student to paste into Project knowledge.

### Modes

| Mode | Behavior |
|------|----------|
| Understand | Full loop |
| Homework | Probe only what’s needed; guide without spoiling; check; answer after attempt (or when asked to verify) |
| Exam | If `routine.md` shows exam soon (e.g. ≤48h): shorter Orient, high-yield Plan, more Check |
| What’s next | Use `state.md` + `routine.md`; suggest next edge topic |

User-facing: **one Coach**. He does not invoke `/probe` etc. Phase files are sub-skills for orchestration and maintenance.

## Write-back contract

End of meaningful session (or after a solid check cluster), output a clearly marked block, e.g.:

```markdown
## State update — replace Project file `state.md` with:

(full updated markdown)

## Log append — add to `log.md`:

- YYYY-MM-DD: topic; outcome; next focus
```

Rules:

- Coach proposes; human pastes into Project knowledge.
- Normal sessions never wipe `routine.md`.
- Re-running setup warns before replacing templates; preserve `state`/`routine` unless user confirms reset.

## Trust & accuracy (bio/chem-friendly)

- Prefer Project knowledge (notes, syllabus) when present.
- If uncertain, say so; suggest verifying with textbook/lecture.
- No fake certainty. NotebookLM deferred to v2 for grounded multi-doc binder.

## Edge cases

| Situation | Behavior |
|-----------|----------|
| “Just explain quickly” | Light Orient; offer full loop; no textbook dump |
| “Give me the answer” | Guide + checks first; spoilers only after attempt or explicit ask |
| Off-subject question | Stay in this Project’s subject; point to the other subject Project |
| Bundle/Project drift | Version note in instructions; refresh from GitHub if behavior feels wrong |

## v1 deliverables

1. Skill bundle as specified above.
2. Composed export suitable for Claude Project instructions (or documented assembly steps).
3. `docs/how-to-update-skills.md` — parent teaches student how to pull updates into Projects.
4. Manual test script covering setup, full loop, homework, exam-soon, and instruction refresh without memory wipe.

## Success criteria

- Student can stand up a subject Project via setup + walkthrough.
- Confused-lecture chat runs Probe → Orient → Plan → Teach → Check without dumping everything at once.
- Homework help does not default to instant answers.
- Pasted `state.md` makes the next session start more calibrated.
- Parent can change pedagogy in the bundle and refresh Projects without destroying subject memory.

## Testing plan

1. Dry-run `/setup-study-coach bio-demo` — kit + checklist clear.
2. Scripted “lost on [topic]” — assert phase order and one-step teaching.
3. Homework paste — assert guided path, no instant spoil.
4. `routine.md` with exam in 48h — assert compressed mode.
5. Bundle tweak → refresh instructions only — assert behavior change; `state`/`routine` untouched.

## Future (explicitly later)

- NotebookLM as external source binder per subject.
- Optional ChatGPT export of the same bundle.
- Optional companion UI for quizzes / learning map.
- If Claude adds Project APIs, automate kit upload.

## Open decisions (resolved in brainstorming)

- Approach: shared skill bundle + Claude Project per subject (not standalone web app first).
- Orient phase between Probe and Plan: yes.
- Phase logic as sub-skills inside one bundle: yes.
- Subject memory under Claude Project, not under skill repo: yes.
- Default platform: Claude; ChatGPT not v1.
- Setup creates Project **templates/kit**, not API-created Projects: yes.
