#!/usr/bin/env bats
# Tests for: conflict_strategy values, per-env override, unknown strategy warning

load 'helpers/setup'
load 'helpers/fixtures'

# Helper: set up two conflicting branches and run with a given strategy
_run_with_strategy() {
  local strategy="$1"
  full_setup
  create_conflicting_branches
  cd "$WORK_DIR"
  cat > automerge-config.yaml <<YAML
conflict_strategy: ${strategy}

envs:
  staging:
    base: main
    branches:
      - branch-conflict-*
YAML
  run git-automerge --env=staging
}

@test "conflict_strategy: ours auto-resolves and prints strategy notice" {
  _run_with_strategy "ours"
  [ "$status" -eq 0 ]
  [[ "$output" == *"Conflict strategy: ours"* ]]
}

@test "conflict_strategy: theirs auto-resolves and prints strategy notice" {
  _run_with_strategy "theirs"
  [ "$status" -eq 0 ]
  [[ "$output" == *"Conflict strategy: theirs"* ]]
}

@test "conflict_strategy: ours+whitespace auto-resolves" {
  _run_with_strategy "ours+whitespace"
  [ "$status" -eq 0 ]
  [[ "$output" == *"Conflict strategy: ours+whitespace"* ]]
}

@test "conflict_strategy: theirs+whitespace auto-resolves" {
  _run_with_strategy "theirs+whitespace"
  [ "$status" -eq 0 ]
  [[ "$output" == *"Conflict strategy: theirs+whitespace"* ]]
}

@test "per-env conflict_strategy overrides global value" {
  full_setup
  create_conflicting_branches
  cd "$WORK_DIR"
  cp "$BATS_TEST_DIRNAME/fixtures/configs/conflict-strategy.yaml" automerge-config.yaml

  # per-env-override env has conflict_strategy: ours (global is theirs)
  run git-automerge --env=per-env-override
  [ "$status" -eq 0 ]
  [[ "$output" == *"Conflict strategy: ours"* ]]
}

@test "unknown conflict_strategy prints warning and does not abort" {
  full_setup
  create_feature_branch "feature/a"
  cd "$WORK_DIR"
  cat > automerge-config.yaml <<'YAML'
conflict_strategy: bogus-strategy

envs:
  staging:
    base: main
    branches:
      - feature/*
YAML

  run git-automerge --env=staging
  [ "$status" -eq 0 ]
  [[ "$output" == *"Unknown conflict_strategy"* ]]
}
