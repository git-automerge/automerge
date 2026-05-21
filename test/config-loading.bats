#!/usr/bin/env bats
# Tests for: config file loading, config_source, dirty worktree

load 'helpers/setup'
load 'helpers/fixtures'

@test "errors out when no local config is found" {
  full_setup
  cd "$WORK_DIR"
  # no automerge-config.yaml

  run git-automerge --env=staging
  [ "$status" -ne 0 ]
  [[ "$output" == *"not found"* ]]
}

@test "loads local config when config_source is unset" {
  full_setup
  create_feature_branch "feature/a"
  cd "$WORK_DIR"
  cp "$BATS_TEST_DIRNAME/fixtures/configs/minimal.yaml" automerge-config.yaml

  run git-automerge --env=staging
  [ "$status" -eq 0 ]
  [[ "$output" == *"Config loaded"* ]]
}

@test "loads remote config when config_source points to a valid ref/file" {
  full_setup
  create_feature_branch "feature/a"
  cd "$WORK_DIR"

  # Commit a remote config on main in the bare origin
  cat > /tmp/remote-config.yaml <<'YAML'
envs:
  staging:
    base: main
    branches:
      - feature/*
YAML
  cp /tmp/remote-config.yaml "$WORK_DIR/remote-config.yaml"
  git -C "$WORK_DIR" add remote-config.yaml
  git -C "$WORK_DIR" commit -m "chore: add remote config" >/dev/null 2>&1
  git -C "$WORK_DIR" push origin main >/dev/null 2>&1
  git -C "$WORK_DIR" fetch --all >/dev/null 2>&1

  # Local config points to the remote file
  cp "$BATS_TEST_DIRNAME/fixtures/configs/config-source.yaml" automerge-config.yaml

  run git-automerge --env=staging
  [ "$status" -eq 0 ]
  [[ "$output" == *"Config loaded"* ]]
}

@test "falls back to local config when config_source points to missing file" {
  full_setup
  create_feature_branch "feature/a"
  cd "$WORK_DIR"

  # Local config references a remote file that does not exist
  cat > automerge-config.yaml <<'YAML'
config_source: origin/main:nonexistent-config.yaml

envs:
  staging:
    base: main
    branches:
      - feature/*
YAML

  run git-automerge --env=staging
  [ "$status" -eq 0 ]
  [[ "$output" == *"Skip loading config"* ]]
}

@test "errors out when working tree is dirty" {
  full_setup
  cd "$WORK_DIR"
  cp "$BATS_TEST_DIRNAME/fixtures/configs/minimal.yaml" automerge-config.yaml
  # Stage a change so git diff HEAD is non-empty
  echo "dirty" >> base.txt
  git add base.txt

  run git-automerge --env=staging
  [ "$status" -ne 0 ]
  [[ "$output" == *"not clean"* ]]
}
