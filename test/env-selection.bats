#!/usr/bin/env bats
# Tests for: --env= flag and interactive environment selection

load 'helpers/setup'
load 'helpers/fixtures'

@test "--env= selects the named env without prompting" {
  full_setup
  create_feature_branch "feature/a"
  cd "$WORK_DIR"
  cp "$BATS_TEST_DIRNAME/fixtures/configs/multi-env.yaml" automerge-config.yaml

  run git-automerge --env=staging
  [ "$status" -eq 0 ]
  [[ "$output" == *"Selected environment: staging"* ]]
}

@test "interactive prompt lists all envs in declaration order" {
  full_setup
  create_feature_branch "feature/a"
  cd "$WORK_DIR"
  cp "$BATS_TEST_DIRNAME/fixtures/configs/multi-env.yaml" automerge-config.yaml

  # Send "0" to select the first env (staging)
  run bash -c 'echo "0" | git-automerge'
  [ "$status" -eq 0 ]
  [[ "$output" == *"[0] staging"* ]]
  [[ "$output" == *"[1] hotfix"* ]]
}

@test "interactive prompt: selecting index 0 picks the first env" {
  full_setup
  create_feature_branch "feature/a"
  cd "$WORK_DIR"
  cp "$BATS_TEST_DIRNAME/fixtures/configs/multi-env.yaml" automerge-config.yaml

  run bash -c 'echo "0" | git-automerge'
  [ "$status" -eq 0 ]
  [[ "$output" == *"Selected environment: staging"* ]]
}

@test "invalid non-numeric selection exits with error" {
  full_setup
  cd "$WORK_DIR"
  cp "$BATS_TEST_DIRNAME/fixtures/configs/multi-env.yaml" automerge-config.yaml

  run bash -c 'echo "abc" | git-automerge'
  [ "$status" -ne 0 ]
  [[ "$output" == *"Invalid selection"* ]]
}

@test "out-of-range selection exits with error" {
  full_setup
  cd "$WORK_DIR"
  cp "$BATS_TEST_DIRNAME/fixtures/configs/multi-env.yaml" automerge-config.yaml

  run bash -c 'echo "99" | git-automerge'
  [ "$status" -ne 0 ]
  [[ "$output" == *"Invalid selection"* ]]
}
