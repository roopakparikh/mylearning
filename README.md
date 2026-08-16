# Study Coach

A Claude Projects skill bundle for one-on-one college study coaching: probe the edge of understanding, orient on one core idea, plan a path, teach step-by-step, and check with quizzes. One GitHub repo holds pedagogy (`coach/`); each subject lives in its own Claude Project with personal memory files (`course.md`, `routine.md`, `state.md`, `log.md`).

- **Design spec:** [docs/superpowers/specs/2026-08-16-study-coach-design.md](docs/superpowers/specs/2026-08-16-study-coach-design.md)
- **Implementation plan:** [docs/superpowers/plans/2026-08-16-study-coach.md](docs/superpowers/plans/2026-08-16-study-coach.md)
- **Skill bundle:** [coach/](coach/) — invoke `/coach`, `/coach:setup`, and `/coach:<phase>` in Project instructions built from [coach/exports/project-instructions.md](coach/exports/project-instructions.md)
- **Updating Projects after a bundle change:** [docs/how-to-update-skills.md](docs/how-to-update-skills.md)
- **Manual QA:** [docs/superpowers/manual-tests/coach-v1.md](docs/superpowers/manual-tests/coach-v1.md)

Validate bundle structure before shipping changes:

```bash
python3 scripts/validate_coach_bundle.py
```

Expected output: `PASS: coach bundle structure OK`
