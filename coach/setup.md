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
