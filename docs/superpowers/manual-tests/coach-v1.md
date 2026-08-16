# Study Coach v1 — manual test checklist

Run these in a Claude Project with the composed instructions from `coach/exports/project-instructions.md` and the four knowledge files from `/coach:setup`. Mark each box when pass/fail is recorded.

**Prerequisites:** Project instructions pasted; `course.md`, `routine.md`, `state.md`, `log.md` uploaded; voice rules active.

---

## 1. Setup — `/coach:setup bio-demo`

- [ ] Invoke `/coach:setup bio-demo` (or natural language equivalent).
- [ ] Coach produces customized drafts of all four template files with subject **Bio Demo** (or similar).
- [ ] Coach emits a clear checklist: create Project → paste instructions → upload four files → start with `/coach` or a phase command.
- [ ] Coach does **not** run Probe/Orient/Plan/Teach/Check during setup.
- [ ] Reset policy is mentioned if files already exist (preserve `state.md` / `routine.md` by default).

**Pass criteria:** Kit + checklist are clear enough for a non-CS student to stand up a Project without extra docs.

---

## 2. Full loop — `/coach` “lost on [topic]”

- [ ] In a set-up Project, invoke `/coach` with something like: “I’m lost on [topic from course.md].”
- [ ] Coach reads `routine.md` and `state.md` before teaching.
- [ ] Default phase order appears: Probe → Orient → Plan → Teach → Check (coach may say if skipping/compressing).
- [ ] **Teach** uses one reasoning step per message (not a chapter dump).
- [ ] Session ends with a proposed `state.md` update block (and optional `log.md` append).

**Pass criteria:** Full loop runs without forcing a single phase skill; teaching is stepwise.

---

## 3. Independent phases — each `/coach:<phase>` alone

Run each invocation in a separate chat or after a clear “new session” boundary. Project memory (`state.md`, `routine.md`, `course.md`) should be read and referenced.

### `/coach:probe`
- [ ] Runs probe questions only; maps gaps.
- [ ] Stops after probe summary; does **not** auto-start Orient/Plan/Teach unless asked.
- [ ] May propose `state.md` insights.

### `/coach:orient`
- [ ] Teaches one core concept in 1–3 short messages.
- [ ] Stops after confirmation check; does not run full loop.

### `/coach:plan`
- [ ] Builds a plain-language learning path from current state + stated goal.
- [ ] Stops after plan; does not auto-teach.

### `/coach:teach`
- [ ] Teaches from existing plan or explicit topic; one step at a time.
- [ ] Stops when user pauses or step cluster is done; does not force Check.

### `/coach:check`
- [ ] Quizzes on stated topic or weak spots from `state.md`.
- [ ] Includes state/log write-back blocks.
- [ ] Stops after check; does not restart full loop.

**Pass criteria:** Each phase completes its own job and stops; none silently runs the entire `/coach` loop.

---

## 4. Homework — guide-first

- [ ] Paste a homework-style problem (no answer yet).
- [ ] Invoke `/coach` or `/coach:teach`.
- [ ] Coach guides with questions and small hints first.
- [ ] Coach does **not** drop the full solution immediately.
- [ ] Full answer or verification appears only after student attempt or explicit ask to verify/spoil.

**Pass criteria:** Guided path; no instant spoil by default.

---

## 5. Exam soon — compressed `/coach`

- [ ] Edit Project `routine.md` to show an exam within **48 hours** (e.g. “Bio midterm — tomorrow”).
- [ ] Invoke `/coach` on an exam-relevant topic.
- [ ] Coach acknowledges exam-soon mode (shorter Orient, high-yield Plan, more Check).
- [ ] Session is compressed vs a normal understand session (coach states what it is skipping/compressing).

**Pass criteria:** Exam mode behavior visible; not a full leisurely loop.

---

## 6. Bundle tweak — instructions only, memory untouched

- [ ] Note current contents of `state.md` and `routine.md` (e.g. weak topics, exam date, custom habits).
- [ ] Parent makes a small visible bundle change (e.g. one line in `coach/voice.md` or `coach/SKILL.md`) and regenerates `coach/exports/project-instructions.md`.
- [ ] Student replaces **Project instructions only** with the new export (per [how-to-update-skills.md](../../how-to-update-skills.md)).
- [ ] Student does **not** re-upload `_template/state.md` or `_template/routine.md`.
- [ ] New bundle behavior appears in chat (e.g. updated wording or rule).
- [ ] `state.md` and `routine.md` in Project knowledge are unchanged.

**Pass criteria:** Pedagogy updates via instructions; personal memory files intact.

---

## Sign-off

| Tester | Date | Project subject | Notes |
|--------|------|-----------------|-------|
| | | | |
