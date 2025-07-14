#!/usr/bin/env bash

set -euo pipefail

SCRIPT_NAME="git-automerge"
MANPAGE_NAME="git-automerge.1"

BIN_DIR="/usr/local/bin"
MAN_DIR="/usr/local/share/man/man1"

echo "📦 Installing $SCRIPT_NAME..."

# Check for root permissions
if [[ $EUID -ne 0 ]]; then
  echo "⚠️  This script must be run as root to install to $BIN_DIR and $MAN_DIR"
  echo "💡 Try: sudo $0"
  exit 1
fi

# Install script
if [[ ! -f "$SCRIPT_NAME" ]]; then
  echo "❌ Cannot find $SCRIPT_NAME in current directory."
  exit 1
fi

echo "🔧 Copying $SCRIPT_NAME to $BIN_DIR..."
install -m 0755 "$SCRIPT_NAME" "$BIN_DIR/$SCRIPT_NAME"

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
