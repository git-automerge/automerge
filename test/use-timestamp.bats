#!/usr/bin/env bats
# Tests for: use_timestamp config option

load 'helpers/setup'
load 'helpers/fixtures'

@test "use_timestamp: false produces a stable tag name without a timestamp" {
  full_setup
  create_feature_branch "feature/a"
  cd "$WORK_DIR"
  cp "$BATS_TEST_DIRNAME/fixtures/configs/use-timestamp-tag.yaml" automerge-config.yaml

  run git-automerge --env=staging
  [ "$status" -eq 0 ]
  run git ls-remote --tags "$ORIGIN_DIR" "refs/tags/automerge-staging"
  [ -n "$output" ]
}

@test "use_timestamp: false with tag reruns successfully, replacing the existing tag" {
  full_setup
  create_feature_branch "feature/a"
  cd "$WORK_DIR"
  cp "$BATS_TEST_DIRNAME/fixtures/configs/use-timestamp-tag.yaml" automerge-config.yaml

  run git-automerge --env=staging
  [ "$status" -eq 0 ]

  run git-automerge --env=staging
  [ "$status" -eq 0 ]

  tag_count=$(git ls-remote --tags "$ORIGIN_DIR" "refs/tags/automerge-staging" | wc -l)
  [ "$tag_count" -eq 1 ]
}

@test "use_timestamp: false with push_mode branch reruns successfully, replacing the existing branch" {
  full_setup
  create_feature_branch "feature/a"
  cd "$WORK_DIR"
  cp "$BATS_TEST_DIRNAME/fixtures/configs/use-timestamp-branch.yaml" automerge-config.yaml

  run git-automerge --env=staging
  [ "$status" -eq 0 ]

  run git-automerge --env=staging
  [ "$status" -eq 0 ]

  branch_count=$(git ls-remote --heads "$ORIGIN_DIR" "refs/heads/automerge_staging" | wc -l)
  [ "$branch_count" -eq 1 ]
}
