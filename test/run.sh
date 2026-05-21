#!/usr/bin/env bash
# Entrypoint: installs bats helpers if needed, then runs the full suite.
set -eo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BATS_LIB="$SCRIPT_DIR/bats_libs"

install_bats_libs() {
  echo "📦 Installing bats helper libraries..."
  mkdir -p "$BATS_LIB"

  if [[ ! -d "$BATS_LIB/bats-support" ]]; then
    git clone --depth 1 https://github.com/bats-core/bats-support.git "$BATS_LIB/bats-support" >/dev/null 2>&1
  fi
  if [[ ! -d "$BATS_LIB/bats-assert" ]]; then
    git clone --depth 1 https://github.com/bats-core/bats-assert.git  "$BATS_LIB/bats-assert"  >/dev/null 2>&1
  fi
}

# Check for bats
if ! command -v bats &>/dev/null; then
  echo "❌ bats-core is not installed. Install it with:"
  echo "   brew install bats-core   # macOS"
  echo "   apt-get install bats     # Debian/Ubuntu"
  exit 1
fi

# Check for yq (required by git-automerge itself)
if ! command -v yq &>/dev/null; then
  echo "❌ yq is not installed. Install it with:"
  echo "   brew install yq          # macOS"
  echo "   snap install yq          # Ubuntu"
  exit 1
fi

install_bats_libs

export BATS_LIB_PATH="$BATS_LIB"

echo "🧪 Running git-automerge test suite..."
bats --tap "$SCRIPT_DIR"/*.bats
