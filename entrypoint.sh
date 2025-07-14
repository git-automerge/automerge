#!/bin/sh

if [ -n "$AUTOMERGE_CONFIG" ]; then
  echo "$AUTOMERGE_CONFIG" > automerge-config.yaml
fi

exec git-automerge "$@"