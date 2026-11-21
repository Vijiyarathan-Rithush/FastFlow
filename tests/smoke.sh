#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
scratch="$(mktemp -d)"
trap 'rm -rf -- "$scratch"' EXIT
export FASTFLOW_CONFIG="$scratch/config"

git init -q --bare "$scratch/remote"
git init -q -b main "$scratch/repo"
cd "$scratch/repo"
git config user.name 'FastFlow tests'
git config user.email 'fastflow@example.invalid'
git remote add origin "$scratch/remote"

ff() { bash "$script_dir/ff.sh" "$@"; }
reject() {
    if ff "$@"; then
        printf 'Expected ff %s to fail\n' "$*" >&2
        exit 1
    fi
}

ff --help
printf 'test\n' > tracked.txt
git add tracked.txt
reject push 'main is protected'
printf 'touch "%s"\n' "$scratch/should-not-exist" > "$FASTFLOW_CONFIG"
reject push 'invalid config leaves protection enabled'
test ! -e "$scratch/should-not-exist"
ff enable main
git commit -qm 'Initial commit'
ff new feature
printf 'changed\n' >> tracked.txt
printf 'local only\n' > local.txt
reject push 'nothing staged'
git add tracked.txt
ff push 'Update tracked file'
test "$(git ls-tree --name-only HEAD)" = tracked.txt
test "$(git rev-parse HEAD)" = "$(git --git-dir="$scratch/remote" rev-parse refs/heads/feature)"
git switch --detach --quiet
reject undo
reject hard
