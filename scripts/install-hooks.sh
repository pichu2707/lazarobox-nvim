#!/bin/bash
set -e

HOOKS_DIR="$(cd "$(dirname "$0")/git-hooks" && pwd)"
TARGET_DIR="$(cd "$(dirname "$0")/.." && pwd)/.git/hooks"

for hook in "$HOOKS_DIR"/*; do
	name=$(basename "$hook")
	ln -sf "$hook" "$TARGET_DIR/$name"
	chmod +x "$hook"
done

echo "✓ Hooks instalados"
