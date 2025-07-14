#!/usr/bin/env bash

set -euo pipefail

MANPAGE_NAME="git-automerge.1"

# List of executables to install from bin/
BIN_FILES=(
  "git-automerge"
)

BIN_DIR="/usr/local/bin"
MAN_DIR="/usr/local/share/man/man1"

echo "📦 Installing automerge scripts from ./bin ..."

# Check for root permissions
if [[ $EUID -ne 0 ]]; then
  echo "⚠️  This script must be run as root to install to $BIN_DIR and $MAN_DIR"
  echo "💡 Try: sudo $0"
  exit 1
fi

# Function to download a file from GitHub raw URL
download_file() {
  # Change these to your repo info
  GITHUB_USER="git-automerge"
  GITHUB_REPO="automerge"
  GITHUB_BRANCH="main"  # or your default branch

  local file_path=$1
  local dest_path=$2
  local url="https://raw.githubusercontent.com/$GITHUB_USER/$GITHUB_REPO/$GITHUB_BRANCH/$file_path"
  echo "⬇️ Downloading $url ..."
  if command -v curl >/dev/null; then
    curl -fsSL "$url" -o "$dest_path"
  elif command -v wget >/dev/null; then
    wget -qO "$dest_path" "$url"
  else
    echo "❌ Neither curl nor wget is installed."
    exit 1
  fi
  chmod +x "$dest_path"
}

for file in "${BIN_FILES[@]}"; do
  dest="$BIN_DIR/$file"
  download_file "bin/$file" "$dest"
  echo "✅ Installed $file to $dest"
done

# Install man page
echo "📘 Installing man page to $MAN_DIR..."
MANPAGE_FILE="/tmp/$MANPAGE_NAME"
download_file "$MANPAGE_NAME" "$MANPAGE_FILE"
install -m 0644 "$MANPAGE_FILE" "$MAN_DIR/$MANPAGE_NAME"
echo "🔄 Updating man database..."
mandb >/dev/null

echo "✅ Installation complete. Try:"
echo "   git automerge --help"
