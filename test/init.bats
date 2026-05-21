#!/usr/bin/env bats
# Tests for: git automerge init

load 'helpers/setup'
load 'helpers/fixtures'

@test "init writes automerge-config.yaml when none exists" {
  mkdir -p "$TEST_DIR/repo" && cd "$TEST_DIR/repo"
  git init -b main >/dev/null 2>&1
  git config user.email "t@t.com" && git config user.name "T"
  echo "x" > x && git add x && git commit -m "c" >/dev/null 2>&1

  run git-automerge init
  [ "$status" -eq 0 ]
  [ -f "automerge-config.yaml" ]
  grep -q "envs:" automerge-config.yaml
}

@test "init prints success message" {
  mkdir -p "$TEST_DIR/repo" && cd "$TEST_DIR/repo"
  git init -b main >/dev/null 2>&1
  git config user.email "t@t.com" && git config user.name "T"
  echo "x" > x && git add x && git commit -m "c" >/dev/null 2>&1

  run git-automerge init
  [ "$status" -eq 0 ]
  [[ "$output" == *"automerge-config.yaml"* ]]
}

@test "init exits non-zero and does not overwrite existing config" {
  mkdir -p "$TEST_DIR/repo" && cd "$TEST_DIR/repo"
  git init -b main >/dev/null 2>&1
  git config user.email "t@t.com" && git config user.name "T"
  echo "x" > x && git add x && git commit -m "c" >/dev/null 2>&1
  echo "existing: true" > automerge-config.yaml

  run git-automerge init
  [ "$status" -ne 0 ]
  grep -q "existing: true" automerge-config.yaml
}

@test "init warns when config already exists" {
  mkdir -p "$TEST_DIR/repo" && cd "$TEST_DIR/repo"
  git init -b main >/dev/null 2>&1
  git config user.email "t@t.com" && git config user.name "T"
  echo "x" > x && git add x && git commit -m "c" >/dev/null 2>&1
  echo "existing: true" > automerge-config.yaml

  run git-automerge init
  [[ "$output" == *"already exists"* ]]
}
