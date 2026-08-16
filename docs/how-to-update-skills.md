# How to update Study Coach skills in Claude Projects

This guide is for the **parent** (who maintains the GitHub bundle) and the **student** (who uses one Claude Project per subject). Run through it together once; after that, the student can refresh instructions on their own when you say a bundle update is ready.

## What lives where

| What | Where | Updates when |
|------|--------|--------------|
| Pedagogy (skills, voice, phases) | This repo under `coach/` | Parent pushes to GitHub |
| Subject memory (`course.md`, `routine.md`, `state.md`, `log.md`) | Inside each Claude Project | Student pastes after sessions |

The skill repo never holds live student progress—only blank `_template/` files for setup.

## Routine update (most common)

Use this when the bundle changed (wording, pedagogy, new phase rules) but the student’s subject Project is already set up.

1. **Get the latest bundle** (parent or student with access):
   - **Git:** `git pull origin main`
   - **Release package:** download `study-coach-skill-<version>.zip` from [Releases](https://github.com/roopakparikh/mylearning/releases), unzip, and use the `coach/` folder inside (optional: verify the `.sha256` file).
   Publishing a Release automatically builds and attaches that zip via GitHub Actions.

2. **Open the composed export** at `coach/exports/project-instructions.md`. This file is the full paste target for Claude Project instructions (voice + orchestrator + setup + all phases).

3. **For each subject Project** (e.g. `Study Coach — Bio`, `Study Coach — Chem`):
   - Open the Project in Claude.
   - Go to **Project settings → Instructions**.
   - Select all, replace with the full contents of `coach/exports/project-instructions.md`.
   - Save. Do **not** re-upload knowledge files unless something in `course.md` scaffolding intentionally changed.

4. **Do not replace `state.md` or `routine.md`** with blank templates from `_template/`. Those files hold the student’s schedule, exam dates, mastery edge, and session history. Refreshing instructions alone does not touch them.

5. **Smoke test** in one Project: run `/coach` on a familiar topic and confirm behavior matches the update (e.g. new mode wording). Then repeat instruction paste for other subject Projects.

## When to run `/coach:setup` vs instruction-only refresh

| Situation | What to do |
|-----------|------------|
| Bundle tweak (pedagogy, voice, phase procedures) | **Instruction-only refresh** — paste `project-instructions.md` only |
| New subject (first time) | **`/coach:setup <subject>`** in a new Project — get kit files + checklist |
| Need to regenerate `course.md` scaffold for a subject | **`/coach:setup`** — update scaffolding fields; preserve `state.md` / `routine.md` unless resetting |
| Deliberate reset of progress or schedule | **`/coach:setup`** with explicit reset confirmation — only then replace `state.md` / `routine.md` |

**Rule of thumb:** If the Project already exists and memory files are good, never re-run setup just because the bundle updated. Paste instructions only.

## How the parent teaches the student (one-time walkthrough)

1. **Explain the split:** “Skills live in GitHub; your grades, weak topics, and schedule live in each Project’s knowledge files.”
2. **Show where instructions live:** Open `coach/exports/project-instructions.md` and the Project settings Instructions field side by side.
3. **Walk through one refresh:** Parent pulls GitHub → student copies export → paste → save. Confirm `state.md` and `routine.md` were not touched.
4. **Show what not to do:** Do not upload `_template/state.md` or `_template/routine.md` over existing files unless starting over on purpose.
5. **Practice `/coach:setup` once** on a demo subject (`bio-demo`) so the checklist is familiar; real subjects use the same flow.
6. **Leave a bookmark:** Student keeps this doc and the Project name pattern `Study Coach — <Subject>`.

After this walkthrough, the student’s ongoing job when you announce an update: paste new instructions into each subject Project. You handle GitHub; they handle Claude.

## If behavior feels wrong after an update

- Confirm instructions were fully replaced (not partially pasted).
- Check that knowledge files still contain personal content in `state.md` / `routine.md`.
- Re-read the [design spec](superpowers/specs/2026-08-16-study-coach-design.md) section on bundle vs Project memory.
- Run manual tests in [coach-v1 manual tests](superpowers/manual-tests/coach-v1.md), especially case 6 (instruction refresh without memory wipe).
