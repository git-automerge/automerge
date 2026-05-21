#!/usr/bin/env bats
# Tests for: remote branch pattern matching

load 'helpers/setup'
load 'helpers/fixtures'

@test "wildcard pattern matches all branches under the prefix" {
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

@test "literal pattern matches exact branch and ignores others" {
  full_setup
  create_feature_branch "feature/a"
  create_feature_branch "feature/b"
  cd "$WORK_DIR"
  cat > automerge-config.yaml <<'YAML'
envs:
  staging:
    base: main
    branches:
      - feature/a
YAML

  run git-automerge --env=staging
  [ "$status" -eq 0 ]
  [[ "$output" == *"feature/a"* ]]
  [[ "$output" != *"feature/b"* ]]
}

@test "multiple patterns combine without duplicates" {
  full_setup
  create_feature_branch "feature/a"
  create_feature_branch "hotfix/urgent"
  cd "$WORK_DIR"
  cat > automerge-config.yaml <<'YAML'
envs:
  staging:
    base: main
    branches:
      - feature/*
      - hotfix/*
YAML

  run git-automerge --env=staging
  [ "$status" -eq 0 ]
  [[ "$output" == *"feature/a"* ]]
  [[ "$output" == *"hotfix/urgent"* ]]
}

@test "symbolic ref origin/HEAD is skipped during matching" {
  full_setup
  create_feature_branch "feature/a"
  cd "$WORK_DIR"
  cp "$BATS_TEST_DIRNAME/fixtures/configs/minimal.yaml" automerge-config.yaml

  # origin/HEAD -> origin/main is a symbolic ref; the script should not crash
  run git-automerge --env=staging
  [ "$status" -eq 0 ]
}

@test "zero matches exits non-zero with descriptive message" {
  full_setup
  # No feature/* branches pushed
  cd "$WORK_DIR"
  cp "$BATS_TEST_DIRNAME/fixtures/configs/minimal.yaml" automerge-config.yaml

  run git-automerge --env=staging
  [ "$status" -ne 0 ]
  [[ "$output" == *"No branches matched"* ]]
}
