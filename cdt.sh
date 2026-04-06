#!/bin/bash

OUTPUT_FILE="macos-defaults-$(date +%Y%m%d-%H%M%S).txt"

# Export mode: no arguments
if [ $# -eq 0 ]; then
    echo "Exporting all defaults to $OUTPUT_FILE..."
    defaults read > "$OUTPUT_FILE"
    echo "Done! File saved to: $OUTPUT_FILE"
    exit 0
fi

# Compare mode: file provided as argument
if [ ! -f "$1" ]; then
    echo "Error: File '$1' not found"
    exit 1
fi

echo "Comparing current defaults with $1..."
echo "Generating current defaults..."
TEMP_FILE=$(mktemp)
defaults read > "$TEMP_FILE"

echo ""
echo "=== DIFFERENCES ==="
echo ""
diff -u "$1" "$TEMP_FILE" | grep -E "^[\+\-]" | grep -v "^[\+\-][\+\-][\+\-]"

rm "$TEMP_FILE"
echo ""
echo "Legend: Lines starting with '-' are in the old file, '+' are in current system"