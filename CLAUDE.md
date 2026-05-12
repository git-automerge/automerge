# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

`git-automerge` is a single-file bash CLI tool (`bin/git-automerge`) that automates merging multiple remote branches into a temporary branch, tagging the result, pushing it to origin, and cleaning up. It is invoked as a git subcommand: `git automerge`.

## Running and testing

There are no automated tests. To test the script manually, run it from within a git repo that has an `automerge-config.yaml`:

```bash
# Install local changes
cp bin/git-automerge /usr/local/bin/git-automerge

# Run directly without installing
bash bin/git-automerge --env=staging
bash bin/git-automerge init
```

Dependencies required locally: `git`, `bash` 4+, `yq` (mikefarah/yq).

## Architecture

Everything meaningful lives in `bin/git-automerge`. There are no libraries, modules, or helper scripts — it is a self-contained bash script.

Supporting files:
- `automerge-config.yaml.example` — reference config for users
- `entrypoint.sh` — Docker entrypoint; writes `$AUTOMERGE_CONFIG` env var to a file then execs the script
- `Dockerfile` — Alpine-based image with git, bash, curl, yq; copies `bin/` and `entrypoint.sh`
- `install.sh` — downloads the script and man page from GitHub and installs to `/usr/local/bin`
- `git-automerge.1` — man page (troff format)
- `VERSION` — single-line semver string; kept in sync with the hardcoded `VERSION=` at the top of `bin/git-automerge`

## Script execution flow

1. If `$1 == init`, write an example config and exit.
2. Print the hardcoded `VERSION` variable.
3. `git fetch --all`
4. Read local `automerge-config.yaml`; if `config_source` is set, fetch that file via `git show` and use it instead.
5. Parse `--env=` flag or prompt user to select from YAML-defined environments.
6. Extract `base`, `branches[]`, and `tag_prefix` for the selected env.
7. List remote branches; match against the env's patterns (supports `*` wildcards using bash `=~`).
8. Create `automerge_<env>_<timestamp>` temp branch from `origin/<base>`.
9. Merge each matched branch with optional `-X` strategy flags; on conflict (or unresolvable conflict), pause and prompt user to resolve interactively.
10. Push either a tag (`<prefix><env>-<timestamp>`) or the temp branch, based on `push_mode`.
11. `cleanup()` trap restores original branch and deletes the temp branch and local tag.

## Key config fields (`automerge-config.yaml`)

| Field | Default | Notes |
|---|---|---|
| `config_source` | — | `origin/branch:path` — fetches remote config via `git show` |
| `push_mode` | `tag` | `tag` or `branch` |
| `cleanup_remote` | `tag` | Set to `yes`/`true`/`1` to delete remote tag or branch after push |
| `envs.<name>.base` | required | Branch used to create the temp merge branch |
| `envs.<name>.branches` | required | List of patterns (supports `*`) matched against remote branch names |
| `envs.<name>.tag_prefix` | `"automerge-"` | `false` = no prefix, omitted = default prefix |
| `conflict_strategy` | — | `ours`, `theirs`, `ours+whitespace`, `theirs+whitespace`, `whitespace`; settable globally or per-env (per-env wins) |
| `rerere` | `false` | Enables `git rerere` for the run; resolutions are recorded and auto-replayed on future runs |

## Things to keep in mind

- The script uses `set -eo pipefail`. Errors abort immediately.
- The `cleanup` function is registered with `trap ... EXIT` but is also called explicitly before cleanup-remote logic runs — so it fires twice on success (idempotent by design).
- `CLEANUP_REMOTE` vs `CLEANUP_MODE`: there is a bug in the current script where the YAML key is `cleanup_remote` but the variable checked is `$CLEANUP_MODE` (never set). Fix: use `CLEANUP_REMOTE` consistently.
- `.tmp_automerge-config.yaml` should be in `.gitignore` for any repo using this tool (noted in README).
- When bumping the version, update both the `VERSION="..."` line in `bin/git-automerge` and the `VERSION` file — they must stay in sync.
- The man page version string (`git-automerge 1.0`) should also be kept in sync.