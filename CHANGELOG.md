# Changelog

All notable changes to `ff` will be documented in this file.

## [0.1.0] - 2025-12-01

### Added

- Initial `ff` script:
  - `ff push <msg>` – auto `git add .`, commit, and `git push -u origin <branch>`.
  - `ff pull` – `git pull --rebase origin <current-branch>`.
  - `ff status` – `git status`.
  - `ff log` – `git log --oneline`.
  - `ff reflog` – `git reflog`.
  - `ff branch` – `git branch`.
  - `ff undo` – soft reset last commit (`git reset --soft HEAD~1`).
  - `ff hard` – hard reset to previous commit (`git reset --hard HEAD~1`, with confirmation).
  - `ff switch <branch>` – safe branch switching using `git switch`.
  - `ff new <branch>` – create and switch to a new branch using `git switch -c`.

- Main branch protection (enabled by default via `~/.ffconfig`):
  - `MAIN_PROTECTION=1` protects `main` from:
    - `ff push`
    - `ff undo`
    - `ff hard`
  - `ff enable main` / `ff disable main` to toggle.

- Safety checks:
  - Safe detection of current branch even before the first commit.
  - Prevention of switching off `main` with uncommitted changes when protection is enabled.
  - Guardrails around `undo`/`hard` requiring a previous commit to exist.


## [1.1.0] - 2025-12-01

### Added
- `ff new <branch>` to create and switch to a new branch.
- `ff switch <branch>` with safe switching checks.

### Fixed
- `ff push` now stages and commits correctly in fresh repos.
- Safer detection of current branch and previous commits.

## [1.0.0] - 2025-12-01

### Known issues
- Initial release with broken push behavior. Do not use.
