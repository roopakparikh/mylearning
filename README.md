# Study Coach

https://github.com/vasanthsreeram/Alvarmethod

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

### Release package

Publishing a [GitHub Release](https://github.com/roopakparikh/mylearning/releases) runs a workflow that:

1. Regenerates `coach/exports/project-instructions.md`
2. Validates the bundle
3. Uploads `study-coach-skill-<version>.zip` (and a `.sha256` checksum) as **Release assets**

Download the zip from the release page, unzip, then paste `exports/project-instructions.md` from the unzipped `study-coach/` folder into each Claude Project (see [docs/how-to-update-skills.md](docs/how-to-update-skills.md)). The same zip is valid for Claude skill upload: `SKILL.md` is at the top of `study-coach/`, with YAML frontmatter.

Build the same zip locally:

```bash
./scripts/bundle_coach_skill.sh v0.1.0
# → dist/study-coach-skill-0.1.0.zip
```
