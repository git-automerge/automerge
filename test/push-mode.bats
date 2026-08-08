#!/usr/bin/env bats
# Tests for: push_mode tag vs branch

load 'helpers/setup'
load 'helpers/fixtures'

@test "push_mode: tag (default) pushes a tag, not the temp branch" {
  full_setup
  create_feature_branch "feature/a"
  cd "$WORK_DIR"
  cp "$BATS_TEST_DIRNAME/fixtures/configs/minimal.yaml" automerge-config.yaml

  run git-automerge --env=staging
  [ "$status" -eq 0 ]
  # A tag must exist on origin
  tag_count=$(git ls-remote --tags "$ORIGIN_DIR" | grep -c "staging-" || true)
  [ "$tag_count" -ge 1 ]
  # The temp branch must NOT persist on origin
  branch_count=$(git ls-remote --heads "$ORIGIN_DIR" | grep -c "automerge_staging_" || true)
  [ "$branch_count" -eq 0 ]
}

@test "push_mode: branch pushes the temp branch, not a tag" {
  full_setup
  create_feature_branch "feature/a"
  cd "$WORK_DIR"
  cp "$BATS_TEST_DIRNAME/fixtures/configs/push-mode-branch.yaml" automerge-config.yaml

  run git-automerge --env=staging
  [ "$status" -eq 0 ]
  # A remote branch automerge_staging_* must exist
  branch_count=$(git ls-remote --heads "$ORIGIN_DIR" | grep -c "automerge_staging_" || true)
  [ "$branch_count" -ge 1 ]
  # No tag should be pushed
  tag_count=$(git ls-remote --tags "$ORIGIN_DIR" | grep -c "staging-" || true)
  [ "$tag_count" -eq 0 ]
}
