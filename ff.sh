#!/bin/bash
# Author: Vijiyarathan Rithush
# Date: 01/12/2025
# Desc: Automation of git functions with safety checks

RED="\033[0;31m"
GREEN="\033[0;32m"
YELLOW="\033[1;33m"
NC="\033[0m"

set -e

COMMAND=$1
ARGUMENT=$2

CONFIG_FILE="$HOME/.ffconfig"

if [ ! -f "$CONFIG_FILE" ]; then
    echo "MAIN_PROTECTION=1" > "$CONFIG_FILE"
fi

source "$CONFIG_FILE"

enforce_protection() {
    local CMD=$1
    local BRANCH=$(git rev-parse --abbrev-ref HEAD)

    PROTECTED_COMMANDS=("push" "undo" "hard")

    if [ "$BRANCH" = "main" ] && [ "$MAIN_PROTECTION" = "1" ]; then
        for BLOCKED in "${PROTECTED_COMMANDS[@]}"; do
            if [ "$CMD" = "$BLOCKED" ]; then
                echo -e "${RED}[ERROR] '$CMD' is blocked on main. Use 'ff disable main' to override.${NC}"
                exit 1
            fi
        done
    fi
}

safe_switch_check() {
    local BRANCH=$(git rev-parse --abbrev-ref HEAD)

    if [ "$BRANCH" = "main" ] && [ "$MAIN_PROTECTION" = "1" ]; then
        if ! git diff-index --quiet HEAD --; then
            echo -e "${RED}[ERROR] Cannot switch from main with uncommitted changes.${NC}"
            exit 1
        fi
    fi
}

if [ -z "$COMMAND" ]; then
    echo -e "${RED}[ERROR] No command provided.${NC}"
    exit 1
fi

case $COMMAND in

    enable)
        if [ "$ARGUMENT" = "main" ]; then
            echo "MAIN_PROTECTION=0" > "$CONFIG_FILE"
            echo -e "${GREEN}[INFO] Main protection DISABLED.${NC}"
        else
            echo -e "${RED}[ERROR] Unknown target: $ARGUMENT${NC}"
        fi
        ;;

    disable)
        if [ "$ARGUMENT" = "main" ]; then
            echo "MAIN_PROTECTION=1" > "$CONFIG_FILE"
            echo -e "${GREEN}[INFO] Main protection ENABLED.${NC}"
        else
            echo -e "${RED}[ERROR] Unknown target: $ARGUMENT${NC}"
        fi
        ;;

    push)
        enforce_protection "push"

        if git diff-index --quiet HEAD --; then
            echo -e "${YELLOW}[INFO] No changes to commit.${NC}"
            exit 0
        fi

        if [ -z "$ARGUMENT" ]; then
            echo -e "${RED}[ERROR] Commit message required.${NC}"
            exit 1
        fi

        git add -p
        git commit -m "$ARGUMENT"
        git push origin "$(git rev-parse --abbrev-ref HEAD)"
        echo -e "${GREEN}[SUCCESS] Changes pushed.${NC}"
        ;;

    pull)
        git pull --rebase origin "$(git rev-parse --abbrev-ref HEAD)"
        ;;

    log)
        git log --oneline
        ;;

    status)
        git status
        ;;

    reflog)
        git reflog
        ;;

    undo)
        enforce_protection "undo"
        git reset --soft HEAD~1
        echo -e "${YELLOW}[INFO] Undo successful (soft reset).${NC}"
        ;;

    hard)
        enforce_protection "hard"
        read -p "Are you sure? Hard reset discards all changes. (y/n): " confirm
        if [[ "$confirm" != "y" ]]; then
            echo -e "${YELLOW}[ABORTED] Hard reset cancelled.${NC}"
            exit 1
        fi
        git reset --hard HEAD~1
        ;;

    branch)
        git branch
        ;;

    switch)
        if [ -z "$ARGUMENT" ]; then
            echo -e "${RED}[ERROR] Branch name required.${NC}"
            exit 1
        fi

        safe_switch_check
        git switch "$ARGUMENT"
        ;;

    *)
        echo "Available commands:"
        echo "[COMMAND] enable main     -> Disable main protection"
        echo "[COMMAND] disable main    -> Enable main protection"
        echo "[COMMAND] push <msg>      -> Add/commit/push changes"
        echo "[COMMAND] pull            -> Pull changes (rebase)"
        echo "[COMMAND] status          -> Git status"
        echo "[COMMAND] log             -> Git log (oneline)"
        echo "[COMMAND] reflog          -> Full reflog"
        echo "[COMMAND] undo            -> Undo last commit (soft reset)"
        echo "[COMMAND] hard            -> Hard reset previous commit"
        echo "[COMMAND] branch          -> List branches"
        echo "[COMMAND] switch <branch> -> Safe branch switching"
        ;;
esac
