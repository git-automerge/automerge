#!/usr/bin/env bats
# Tests for: --no-conflict-strategy flag behaviour

load 'helpers/setup'
load 'helpers/fixtures'

@test "--no-conflict-strategy prints the documented notice at the top of the run" {
  full_setup
  create_feature_branch "feature/a"
  cd "$WORK_DIR"
  cp "$BATS_TEST_DIRNAME/fixtures/configs/minimal.yaml" automerge-config.yaml

  run git-automerge --env=staging --no-conflict-strategy
  [ "$status" -eq 0 ]
  [[ "$output" == *"--no-conflict-strategy set"* ]]
}

@test "--no-conflict-strategy suppresses the conflict_strategy notice even when strategy is configured" {
  full_setup
  create_feature_branch "feature/a"
  cd "$WORK_DIR"
  cat > automerge-config.yaml <<'YAML'
conflict_strategy: theirs

envs:
  staging:
    base: main
    branches:
      - feature/*
YAML

  run git-automerge --env=staging --no-conflict-strategy
  [ "$status" -eq 0 ]
  # The "Conflict strategy:" notice must NOT appear
  [[ "$output" != *"Conflict strategy:"* ]]
}

@test "--no-conflict-strategy with a conflicting branch prompts for resolution instead of auto-resolving" {
  full_setup
  create_conflicting_branches
  cd "$WORK_DIR"
  cat > automerge-config.yaml <<'YAML'
conflict_strategy: theirs

envs:
  staging:
    base: main
    branches:
      - branch-conflict-*
YAML

  # Without --no-conflict-strategy, theirs would auto-resolve silently.
  # With it, the script hits a real conflict and prompts — we abort to keep the test fast.
  run bash -c 'echo "abort" | git-automerge --env=staging --no-conflict-strategy'
  [ "$status" -ne 0 ]
  # Must have hit the conflict prompt path, not auto-resolved
  [[ "$output" == *"Merge conflict detected"* ]] || [[ "$output" == *"Automerge aborted"* ]]
}
