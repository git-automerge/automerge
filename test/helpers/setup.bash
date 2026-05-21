#!/usr/bin/env bash
# Common setup/teardown and PATH wiring for all bats tests.

# Make git-automerge available as `git automerge`
export PATH="$BATS_TEST_DIRNAME/../bin:$PATH"

# Each test gets its own isolated temp directory.
setup() {
  TEST_DIR="$(mktemp -d)"
  export TEST_DIR
}

teardown() {
  rm -rf "$TEST_DIR"
}
