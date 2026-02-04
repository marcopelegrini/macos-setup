#!/bin/bash

BEFORE=$(mktemp)
AFTER=$(mktemp)

echo "Capturing initial defaults..."
defaults read > "$BEFORE"

echo "Initial capture complete. Make your changes, then press Enter to continue..."
read -r

echo "Capturing current defaults..."
defaults read > "$AFTER"

echo -e "\n=== DIFFERENCES ==="
diff --unified=0 "$BEFORE" "$AFTER" | grep -v "^@\|^---\|^+++"

rm "$BEFORE" "$AFTER"