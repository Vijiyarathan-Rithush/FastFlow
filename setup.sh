#!/bin/bash
# Author: Vijiyarathan Rithush
# Date: 01/12/2025
# Desc: Installing FastFlow (ff)

echo "Installing FastFlow (ff)..."

mkdir -p "$HOME/bin"

cp ff "$HOME/bin/ff"
chmod +x "$HOME/bin/ff"

if ! grep -q 'export PATH="$HOME/bin:$PATH"' "$HOME/.bashrc"; then
    echo 'export PATH="$HOME/bin:$PATH"' >> "$HOME/.bashrc"
    echo "Added ~/bin to PATH in .bashrc"
fi

echo "Installation complete!"
echo "Restart your terminal or run: source ~/.bashrc"
echo "You can now use: ff <command>"
