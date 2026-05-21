#!/usr/bin/env bats
# Tests for: error conditions — missing keys, abort, pipefail

load 'helpers/setup'
load 'helpers/fixtures'

@test "missing 'base' in env config exits non-zero with descriptive message" {
  full_setup
  cd "$WORK_DIR"
  cp "$BATS_TEST_DIRNAME/fixtures/configs/invalid-env.yaml" automerge-config.yaml

  run git-automerge --env=broken
  [ "$status" -ne 0 ]
  [[ "$output" == *"Invalid environment config"* ]]
}

@test "missing 'branches' in env config exits non-zero with descriptive message" {
  full_setup
  cd "$WORK_DIR"
  cat > automerge-config.yaml <<'YAML'
envs:
  broken:
    base: main
YAML

  run git-automerge --env=broken
  [ "$status" -ne 0 ]
  [[ "$output" == *"Invalid environment config"* ]]
}

@test "conflict + user types 'abort' exits non-zero and restores original branch" {
  full_setup
  create_conflicting_branches
  cd "$WORK_DIR"
  cat > automerge-config.yaml <<'YAML'
envs:
  staging:
    base: main
    branches:
      - branch-conflict-*
YAML

  ORIG=$(git rev-parse --abbrev-ref HEAD)

  # Pipe "abort" when prompted
  run bash -c 'echo "abort" | git-automerge --env=staging'
  [ "$status" -ne 0 ]
  [[ "$output" == *"Automerge aborted"* ]]

  # Should be back on original branch
  current=$(git rev-parse --abbrev-ref HEAD)
  [ "$current" = "$ORIG" ]
}

@test "cleanup trap fires and removes temp branch on abort" {
  full_setup
  create_conflicting_branches
  cd "$WORK_DIR"
  cat > automerge-config.yaml <<'YAML'
envs:
  staging:
    base: main
    branches:
      - branch-conflict-*
YAML

  run bash -c 'echo "abort" | git-automerge --env=staging'
  [ "$status" -ne 0 ]

  temp_branches=$(git branch | grep "automerge_staging_" || true)
  [ -z "$temp_branches" ]
}
