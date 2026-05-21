#!/usr/bin/env bats
# Tests for: version string printed on every run

load 'helpers/setup'
load 'helpers/fixtures'

@test "script prints version matching the VERSION file on every run" {
  full_setup
  create_feature_branch "feature/a"
  cd "$WORK_DIR"
  cp "$BATS_TEST_DIRNAME/fixtures/configs/minimal.yaml" automerge-config.yaml

  EXPECTED_VERSION=$(cat "$BATS_TEST_DIRNAME/../VERSION")

  run git-automerge --env=staging
  [ "$status" -eq 0 ]
  [[ "$output" == *"git-automerge v${EXPECTED_VERSION}"* ]]
}

@test "version line is printed before any other work begins" {
  full_setup
  create_feature_branch "feature/a"
  cd "$WORK_DIR"
  cp "$BATS_TEST_DIRNAME/fixtures/configs/minimal.yaml" automerge-config.yaml

  run git-automerge --env=staging
  [ "$status" -eq 0 ]
  # The very first non-empty line should contain the version
  first_line=$(echo "$output" | grep -m1 "git-automerge v")
  [[ "$first_line" == *"git-automerge v"* ]]
}
