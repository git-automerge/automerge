#!/usr/bin/env bash
# Helper functions that build git repos and configs needed by tests.
# Every function operates inside $TEST_DIR.

# ---------------------------------------------------------------------------
# create_origin  — bare repo that acts as the remote
# ---------------------------------------------------------------------------
create_origin() {
  ORIGIN_DIR="$TEST_DIR/origin.git"
  git init --bare "$ORIGIN_DIR" -b main >/dev/null 2>&1
  export ORIGIN_DIR
}

# ---------------------------------------------------------------------------
# create_working_repo  — clone of the bare remote; tests run from here
# ---------------------------------------------------------------------------
create_working_repo() {
  WORK_DIR="$TEST_DIR/work"
  git clone "$ORIGIN_DIR" "$WORK_DIR" >/dev/null 2>&1
  cd "$WORK_DIR"
  git config user.email "test@example.com"
  git config user.name "Test User"
  export WORK_DIR
}

# ---------------------------------------------------------------------------
# seed_base_branch  — commit an initial file on main and push to origin
# ---------------------------------------------------------------------------
seed_base_branch() {
  local branch="${1:-main}"
  cd "$WORK_DIR"
  echo "initial" > base.txt
  git add base.txt
  git commit -m "chore: initial commit" >/dev/null 2>&1
  git push origin "$branch" >/dev/null 2>&1
}

# ---------------------------------------------------------------------------
# create_feature_branch <name> [file] [content]
# Push a branch with one extra commit to origin.
# ---------------------------------------------------------------------------
create_feature_branch() {
  local branch="$1"
  local file="${2:-${branch//\//_}.txt}"
  local content="${3:-change from $branch}"

  cd "$WORK_DIR"
  git checkout -b "$branch" "origin/main" >/dev/null 2>&1
  echo "$content" > "$file"
  git add "$file"
  git commit -m "feat: $branch" >/dev/null 2>&1
  git push origin "$branch" >/dev/null 2>&1
  git checkout main >/dev/null 2>&1
}

# ---------------------------------------------------------------------------
# create_conflicting_branches  — two branches that both change the same line
# ---------------------------------------------------------------------------
create_conflicting_branches() {
  cd "$WORK_DIR"

  # branch-conflict-a
  git checkout -b branch-conflict-a "origin/main" >/dev/null 2>&1
  echo "side A" > conflict.txt
  git add conflict.txt
  git commit -m "feat: side A" >/dev/null 2>&1
  git push origin branch-conflict-a >/dev/null 2>&1
  git checkout main >/dev/null 2>&1

  # branch-conflict-b  (same file, different content → conflict when merged after A)
  git checkout -b branch-conflict-b "origin/main" >/dev/null 2>&1
  echo "side B" > conflict.txt
  git add conflict.txt
  git commit -m "feat: side B" >/dev/null 2>&1
  git push origin branch-conflict-b >/dev/null 2>&1
  git checkout main >/dev/null 2>&1
}

# ---------------------------------------------------------------------------
# create_whitespace_branch — branch that only re-indents a file
# ---------------------------------------------------------------------------
create_whitespace_branch() {
  cd "$WORK_DIR"

  # Put content on main first
  echo "line one" > ws.txt
  git add ws.txt
  git commit -m "chore: add ws.txt" >/dev/null 2>&1
  git push origin main >/dev/null 2>&1

  git checkout -b branch-whitespace "origin/main" >/dev/null 2>&1
  echo "  line one" > ws.txt   # leading spaces only
  git add ws.txt
  git commit -m "style: re-indent ws.txt" >/dev/null 2>&1
  git push origin branch-whitespace >/dev/null 2>&1
  git checkout main >/dev/null 2>&1
}

# ---------------------------------------------------------------------------
# write_config <dest_file> <yaml_content>
# ---------------------------------------------------------------------------
write_config() {
  local dest="$1"
  shift
  echo "$@" > "$dest"
}

# ---------------------------------------------------------------------------
# full_setup  — one-liner: create origin + clone + seed main
# ---------------------------------------------------------------------------
full_setup() {
  create_origin
  create_working_repo
  seed_base_branch
  git -C "$WORK_DIR" fetch --all >/dev/null 2>&1
}
