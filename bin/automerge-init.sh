#!/usr/bin/env bash

CONFIG_FILE="config.yaml"

if [[ -f "$CONFIG_FILE" ]]; then
  echo "⚠️ $CONFIG_FILE already exists. Aborting."
  exit 1
fi

cat > "$CONFIG_FILE" <<EOF
# Example configuration for git automerge

staging:
  base: main
  branches:
    - hotfix/*
  tag_prefix: false

feature:
  base: main
  branches:
    - feature/*
# if no tag_prefix default 'automerge-' is used

EOF

echo "✅ Example $CONFIG_FILE created in the current directory."
