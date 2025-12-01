#!/bin/bash
# Author: Vijiyarathan Rithush
# Date: 01/12/2025
# Desc: Automation of git functions with safety checks

RED="\033[0;31m"
GREEN="\033[0;32m"
YELLOW="\033[1;33m"
NC="\033[0m"

set -euo pipefail

COMMAND="${1:-}"
ARGUMENT="${2:-}"

CONFIG_FILE="$HOME/.ffconfig"

# Default: protect main
if [[ ! -f "$CONFIG_FILE" ]]; then
    echo "MAIN_PROTECTION=1" > "$CONFIG_FILE"
fi

# shellcheck source=/dev/null
source "$CONFIG_FILE"

require_git_repo() {
    if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
        echo -e "${RED}[ERROR] Not inside a git repository.${NC}"
        exit 1
    fi
}

# True if there are any changes (tracked or untracked)
# Works even before the first commit (no HEAD)
has_changes() {
    [[ -n "$(git status --porcelain)" ]]
}

# True if there is at least one previous commit (i.e. at least 2 commits total)
has_prev_commit() {
    # Need HEAD to exist
    if ! git rev-parse --verify HEAD >/dev/null 2>&1; then
        return 1
    fi
    # Need HEAD~1 to exist
    git rev-parse --verify HEAD~1 >/dev/null 2>&1 || return 1
    return 0
}

# Get current branch safely
current_branch() {
    git branch --show-current 2>/dev/null || \
    git symbolic-ref --short HEAD 2>/dev/null || \
    echo ""
}

enforce_protection() {
    local subcmd="$1"

    require_git_repo

    local branch
    branch="$(current_branch)"

    # If we cant determine branch (detached/unborn), do nothing
    if [[ -z "$branch" ]]; then
        return 0
    fi

    local PROTECTED_COMMANDS=("push" "undo" "hard")

    # allow enable/disable regardless
    if [[ "$COMMAND" != "enable" && "$COMMAND" != "disable" ]]; then
        if [[ "$branch" == "main" && "${MAIN_PROTECTION:-1}" == "1" ]]; then
            for protected in "${PROTECTED_COMMANDS[@]}"; do
                if [[ "$subcmd" == "$protected" ]]; then
                    echo -e "${RED}[ERROR] '$subcmd' is blocked on main. Use 'ff disable main' to override.${NC}"
                    exit 1
                fi
            done
        fi
    fi
}

safe_switch_check() {
    require_git_repo

    local branch
    branch="$(current_branch)"

    if [[ -z "$branch" ]]; then
        return 0
    fi

    if [[ "$branch" == "main" && "${MAIN_PROTECTION:-1}" == "1" ]]; then
        if has_changes; then
            echo -e "${RED}[ERROR] Cannot switch from main with uncommitted changes.${NC}"
            exit 1
        fi
    fi
}

if [[ -z "$COMMAND" ]]; then
    echo -e "${RED}[ERROR] No command provided.${NC}"
    exit 1
fi

case "$COMMAND" in

    disable)
        if [[ "$ARGUMENT" == "main" ]]; then
            echo "MAIN_PROTECTION=0" > "$CONFIG_FILE"
            echo -e "${YELLOW}[INFO] Main protection DISABLED.${NC}"
        else
            echo -e "${RED}[ERROR] Unknown target: $ARGUMENT${NC}"
            exit 1
        fi
        ;;

    enable)
        if [[ "$ARGUMENT" == "main" ]]; then
            echo "MAIN_PROTECTION=1" > "$CONFIG_FILE"
            echo -e "${GREEN}[INFO] Main protection ENABLED.${NC}"
        else
            echo -e "${RED}[ERROR] Unknown target: $ARGUMENT${NC}"
            exit 1
        fi
        ;;

    push)
        enforce_protection "push"
        require_git_repo

        if [[ -z "$(git status --porcelain)" ]]; then
            echo -e "${YELLOW}[INFO] No changes to commit.${NC}"
            exit 0
        fi

        if [[ -z "$ARGUMENT" ]]; then
            echo -e "${RED}[ERROR] Commit message required.${NC}"
            exit 1
        fi

        branch="$(current_branch)"

        if [[ -z "$branch" ]]; then
            echo -e "${RED}[ERROR] Cannot determine current branch for push.${NC}"
            exit 1
        fi

        git add .

        # If nothing is staged after add, dont even try to commit
        if git diff --cached --quiet; then
            echo -e "${RED}[ERROR] Nothing staged to commit after git add .${NC}"
            exit 1
        fi

        git commit -m "$ARGUMENT"
        # -u so first push sets upstream for future pulls
        git push -u origin "$branch"
        echo -e "${GREEN}[SUCCESS] Changes pushed.${NC}"
        ;;

    pull)
        require_git_repo

        branch="$(current_branch)"

        if [[ -z "$branch" ]]; then
            echo -e "${RED}[ERROR] Cannot determine current branch for pull.${NC}"
            exit 1
        fi

        git pull --rebase origin "$branch"
        ;;

    log)
        require_git_repo
        git log --oneline
        ;;

    status)
        require_git_repo
        git status
        ;;

    reflog)
        require_git_repo
        git reflog
        ;;

    undo)
        enforce_protection "undo"
        require_git_repo

        if ! has_prev_commit; then
            echo -e "${RED}[ERROR] No previous commit to undo.${NC}"
            exit 1
        fi

        git reset --soft HEAD~1
        echo -e "${YELLOW}[INFO] Undo successful (soft reset).${NC}"
        ;;

    hard)
        enforce_protection "hard"
        require_git_repo

        if ! has_prev_commit; then
            echo -e "${RED}[ERROR] No previous commit to hard reset to.${NC}"
            exit 1
        fi

        read -p "Are you sure? Hard reset discards all changes. (y/n): " confirm
        if [[ "$confirm" != "y" ]]; then
            echo -e "${YELLOW}[ABORTED] Hard reset cancelled.${NC}"
            exit 1
        fi

        git reset --hard HEAD~1
        ;;

    branch)
        require_git_repo
        git branch
        ;;

    switch)
        if [[ -z "$ARGUMENT" ]]; then
            echo -e "${RED}[ERROR] Branch name required.${NC}"
            exit 1
        fi

        require_git_repo
        safe_switch_check

        git switch "$ARGUMENT"
        echo -e "${YELLOW}[INFO] Switched to branch '$ARGUMENT'.${NC}"
        ;;

    new)
        if [[ -z "$ARGUMENT" ]]; then
            echo -e "${RED}[ERROR] Branch name required for new branch.${NC}"
            exit 1
        fi

        require_git_repo
        safe_switch_check

        git switch -c "$ARGUMENT"
        echo -e "${YELLOW}[INFO] Created and switched to branch '$ARGUMENT'.${NC}"
        ;;

    *)
        echo "Available commands:"
        echo "  ff enable main      -> ENABLE main protection"
        echo "  ff disable main     -> DISABLE main protection"
        echo "  ff push <msg>       -> Add/commit/push changes"
        echo "  ff pull             -> Pull changes (rebase)"
        echo "  ff status           -> Git status"
        echo "  ff log              -> Git log (oneline)"
        echo "  ff reflog           -> Full reflog"
        echo "  ff undo             -> Undo last commit (soft reset)"
        echo "  ff hard             -> Hard reset previous commit"
        echo "  ff branch           -> List branches"
        echo "  ff switch <branch>  -> Switch to existing branch (safe)"
        echo "  ff new <branch>     -> Create and switch to new branch (safe)"
        ;;
esac
