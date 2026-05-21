#!/usr/bin/env bats
# Tests for: rerere config option

load 'helpers/setup'
load 'helpers/fixtures'

@test "rerere: false (default) leaves rerere.enabled untouched after the run" {
  full_setup
  create_feature_branch "feature/a"
  cd "$WORK_DIR"
  cp "$BATS_TEST_DIRNAME/fixtures/configs/minimal.yaml" automerge-config.yaml

  # Ensure rerere.enabled is NOT set before
  git config --local --unset rerere.enabled 2>/dev/null || true

  run git-automerge --env=staging
  [ "$status" -eq 0 ]

  # rerere.enabled should still be unset after the run
  rerere_val=$(git config --local rerere.enabled 2>/dev/null || echo "unset")
  [ "$rerere_val" = "unset" ]
}

@test "rerere: true enables rerere during the run" {
  full_setup
  create_feature_branch "feature/a"
  cd "$WORK_DIR"
  cp "$BATS_TEST_DIRNAME/fixtures/configs/rerere.yaml" automerge-config.yaml

  run git-automerge --env=staging
  [ "$status" -eq 0 ]
  [[ "$output" == *"rerere enabled"* ]]
}

@test "rerere: true restores previous value (was unset) after the run" {
  full_setup
  create_feature_branch "feature/a"
  cd "$WORK_DIR"
  cp "$BATS_TEST_DIRNAME/fixtures/configs/rerere.yaml" automerge-config.yaml
  git config --local --unset rerere.enabled 2>/dev/null || true

  run git-automerge --env=staging
  [ "$status" -eq 0 ]

  rerere_val=$(git config --local rerere.enabled 2>/dev/null || echo "unset")
  [ "$rerere_val" = "unset" ]
}

@test "rerere: true restores previous value (was false) after the run" {
  full_setup
  create_feature_branch "feature/a"
  cd "$WORK_DIR"
  cp "$BATS_TEST_DIRNAME/fixtures/configs/rerere.yaml" automerge-config.yaml
  git config --local rerere.enabled false

  run git-automerge --env=staging
  [ "$status" -eq 0 ]

  rerere_val=$(git config --local rerere.enabled 2>/dev/null || echo "unset")
  [ "$rerere_val" = "false" ]
}
