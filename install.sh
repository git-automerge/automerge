#!/usr/bin/env bash

set -euo pipefail

MANPAGE_NAME="git-automerge.1"

BIN_DIR="/usr/local/bin"
MAN_DIR="/usr/local/share/man/man1"

echo "📦 Installing automerge scripts from ./bin ..."

# Check for root permissions
if [[ $EUID -ne 0 ]]; then
  echo "⚠️  This script must be run as root to install to $BIN_DIR and $MAN_DIR"
  echo "💡 Try: sudo $0"
  exit 1
fi

# Verify bin directory exists
if [[ ! -d ./bin ]]; then
  echo "❌ Directory 'bin' not found in current path."
  exit 1
fi

# Install all executable files from bin/
for file in ./bin/*; do
  if [[ -f "$file" && -x "$file" ]]; then
    echo "🔧 Installing $(basename "$file") to $BIN_DIR..."
    install -m 0755 "$file" "$BIN_DIR/$(basename "$file")"
  else
    echo "⚠️ Skipping non-executable or non-regular file: $file"
  fi
done

# Install man page
if [[ -f "$MANPAGE_NAME" ]]; then
  echo "📘 Installing man page to $MAN_DIR..."
  install -m 0644 "$MANPAGE_NAME" "$MAN_DIR/$MANPAGE_NAME"
  echo "🔄 Updating man database..."
  mandb >/dev/null
else
  echo "⚠️  No man page '$MANPAGE_NAME' found. Skipping manual installation."
fi

echo "✅ Installation complete. Try:"
echo "   git automerge --help"
