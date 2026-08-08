#!/usr/bin/env bats
# Tests for: non-conflicting merges, tag creation, push, cleanup

load 'helpers/setup'
load 'helpers/fixtures'

@test "non-conflicting merges succeed and temp branch contains all commits" {
  full_setup
  create_feature_branch "feature/a"
  create_feature_branch "feature/b"
  cd "$WORK_DIR"
  cp "$BATS_TEST_DIRNAME/fixtures/configs/minimal.yaml" automerge-config.yaml

  run git-automerge --env=staging
  [ "$status" -eq 0 ]
  [[ "$output" == *"feature/a"* ]]
  [[ "$output" == *"feature/b"* ]]
}

@test "default tag is created and pushed to origin" {
  full_setup
  create_feature_branch "feature/a"
  cd "$WORK_DIR"
  cp "$BATS_TEST_DIRNAME/fixtures/configs/minimal.yaml" automerge-config.yaml

  run git-automerge --env=staging
  [ "$status" -eq 0 ]
  # Tag should exist on origin
  tag_count=$(git ls-remote --tags "$ORIGIN_DIR" | grep -c "automerge-staging-" || true)
  [ "$tag_count" -ge 1 ]
}

@test "default tag prefix 'automerge-' applied when tag_prefix is omitted" {
  full_setup
  create_feature_branch "feature/a"
  cd "$WORK_DIR"
  cp "$BATS_TEST_DIRNAME/fixtures/configs/minimal.yaml" automerge-config.yaml

  run git-automerge --env=staging
  [ "$status" -eq 0 ]
  [[ "$output" == *"automerge-staging-"* ]]
}

@test "temp branch is deleted locally after successful run" {
  full_setup
  create_feature_branch "feature/a"
  cd "$WORK_DIR"
  cp "$BATS_TEST_DIRNAME/fixtures/configs/minimal.yaml" automerge-config.yaml

  run git-automerge --env=staging
  [ "$status" -eq 0 ]
  temp_branches=$(git branch | grep "automerge_staging_" || true)
  [ -z "$temp_branches" ]
}
