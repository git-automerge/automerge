#!/usr/bin/env bats
# Tests for: tag_prefix variants (false, custom, default)

load 'helpers/setup'
load 'helpers/fixtures'

@test "tag_prefix: false produces a tag without a prefix" {
  full_setup
  create_feature_branch "feature/a"
  cd "$WORK_DIR"
  cp "$BATS_TEST_DIRNAME/fixtures/configs/tag-prefix.yaml" automerge-config.yaml

  run git-automerge --env=no-prefix
  [ "$status" -eq 0 ]
  # Tag name should start with "no-prefix-" (env name), not "automerge-"
  tag_count=$(git ls-remote --tags "$ORIGIN_DIR" | grep -c "no-prefix-" || true)
  [ "$tag_count" -ge 1 ]
  # Must NOT contain "automerge-"
  bad_tag=$(git ls-remote --tags "$ORIGIN_DIR" | grep "automerge-" || true)
  [ -z "$bad_tag" ]
}

@test "custom tag_prefix is honoured" {
  full_setup
  create_feature_branch "feature/a"
  cd "$WORK_DIR"
  cp "$BATS_TEST_DIRNAME/fixtures/configs/tag-prefix.yaml" automerge-config.yaml

  run git-automerge --env=custom-prefix
  [ "$status" -eq 0 ]
  tag_count=$(git ls-remote --tags "$ORIGIN_DIR" | grep -c "release-custom-prefix-" || true)
  [ "$tag_count" -ge 1 ]
}

@test "default tag prefix 'automerge-' when tag_prefix is omitted" {
  full_setup
  create_feature_branch "feature/a"
  cd "$WORK_DIR"
  cp "$BATS_TEST_DIRNAME/fixtures/configs/tag-prefix.yaml" automerge-config.yaml

  run git-automerge --env=default-prefix
  [ "$status" -eq 0 ]
  tag_count=$(git ls-remote --tags "$ORIGIN_DIR" | grep -c "automerge-default-prefix-" || true)
  [ "$tag_count" -ge 1 ]
}
