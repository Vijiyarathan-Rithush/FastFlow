# FastFlow

FastFlow (`ff`) is a Bash CLI for Git. It commits and pushes the files you stage,
blocks history-changing commands on `main` by default, and adds shortcuts for
rebasing, branch switching and inspecting history.

## Install

You need Bash and a Git version that supports `git switch`. On Windows, use Git
Bash or WSL.

```bash
git clone https://github.com/Vijiyarathan-Rithush/FastFlow.git
cd FastFlow
bash setup.sh
export PATH="$HOME/bin:$PATH"
ff --help
```

To prefer a manual install, copy `ff.sh` to `~/bin/ff` and make it executable.

## Quick start

```bash
ff new my-change
git add path/to/changed-file
ff push "Describe the change"
```

`ff push` commits only what is already staged. Run `git diff --cached` to review
the staged patch first. The command pushes the current branch to `origin` and
sets its upstream. If the push fails after the commit succeeds, the local commit
remains available for a normal `git push`.

| Command | Behaviour |
| --- | --- |
| `ff pull` | Pull the current branch from `origin` with rebase |
| `ff status`, `ff log`, `ff reflog` | Inspect the repository |
| `ff branch` | List local branches |
| `ff switch <branch>`, `ff new <branch>` | Switch to or create a branch |
| `ff undo` | Soft-reset one commit and retain its changes |
| `ff hard` | Hard-reset one commit after confirmation |
| `ff enable main`, `ff disable main` | Toggle protection for `main` |

By default, FastFlow blocks `ff push`, `ff undo` and `ff hard` on `main`, and
blocks branch switching from an unclean `main`. The setting is stored in
`~/.ffconfig` as `MAIN_PROTECTION=1` or `MAIN_PROTECTION=0`.
Set `FASTFLOW_CONFIG` to use a different config file.

## Development

```bash
bash tests/smoke.sh
```

The smoke tests use a temporary local Git repository as the push destination.


## License

FastFlow is distributed under the MIT License.
