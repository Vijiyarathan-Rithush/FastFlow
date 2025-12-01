#!/bin/bash
# Author: Vijiyarathan Rithush
# Date: 01/12/2025
# Desc: Installing FastFlow (ff)

set -euo pipefail

echo "Installing FastFlow (ff)..."

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_FF="$SCRIPT_DIR/ff.sh"      
TARGET_DIR="$HOME/bin"
TARGET_FF="$TARGET_DIR/ff"

if [[ ! -f "$SOURCE_FF" ]]; then
    echo "Error: 'ff.sh' not found in $SCRIPT_DIR"
    echo "Make sure ff.sh is in the same directory as this installer."
    exit 1
fi

mkdir -p "$TARGET_DIR"

if [[ -f "$TARGET_FF" ]]; then
    echo "Updating existing ff in $TARGET_DIR..."
else
    echo "Installing ff to $TARGET_DIR..."
fi

cp "$SOURCE_FF" "$TARGET_FF"
chmod +x "$TARGET_FF"

if ! grep -q 'export PATH="$HOME/bin:$PATH"' "$HOME/.bashrc" 2>/dev/null; then
    echo 'export PATH="$HOME/bin:$PATH"' >> "$HOME/.bashrc"
    echo "Added ~/bin to PATH in .bashrc"
fi

echo "Installation complete!"
echo "Restart your terminal or run: source ~/.bashrc"
echo "You can now use: ff <command>"
