#!/bin/bash
# Stumble Guys quick launch script for Mac
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Check if Godot is in /Applications or PATH
if command -v godot &> /dev/null; then
    GODOT_BIN="godot"
elif [ -d "/Applications/Godot.app" ]; then
    GODOT_BIN="/Applications/Godot.app/Contents/MacOS/Godot"
else
    echo "Godot not found in PATH or /Applications."
    echo "Please ensure Godot 4 is installed."
    exit 1
fi

echo "Launching Stumble Guys with $GODOT_BIN..."
"$GODOT_BIN" --path "$SCRIPT_DIR"
