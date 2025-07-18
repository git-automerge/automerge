# Git AutoMerge

[![Website](https://img.shields.io/badge/site-git--automerge.github.io-blue?logo=githubpages)](https://git-automerge.github.io/)

**Git AutoMerge** is a CLI tool to automate merging multiple remote Git branches into a temporary branch, tagging that branch with an environment-specific tag, pushing the tag to origin, and cleaning up afterward.

---

## Features

- Reads configuration from a YAML file defining multiple environments
- Supports read the configuration YAML from origin default branch
- Supports wildcard patterns for included remote branches to merge
- Creates a temporary branch from a base branch before merging
- Tags the merge commit with an environment name and timestamp
- Pushes the tag to the remote repository
- Automatically cleans up the temporary branch and local tag
- Supports optional customizable tag prefix per environment

---

## Installation

Via curl
```bash
curl -sSL https://raw.githubusercontent.com/git-automerge/automerge/main/install.sh | sudo bash
```

Via wget
```bash
wget -qO - https://raw.githubusercontent.com/git-automerge/automerge/main/install.sh | sudo bash
```

Download directly
```bash
curl -L https://github.com/git-automerge/automerge/blob/main/bin/git-automerge -o /usr/local/bin/git-automerge
chmod +x /usr/local/bin/git-automerge
```

## Usage

```bash
git automerge --help
```

## Configuration Example (automerge-config.yaml)

Create a automerge-config.yaml file in your project root with this structure:
```yaml
config_source: origin/main:automerge-config.yaml # Optional; Read config from remote branch

staging:
  base: main
  branches:
    - "bugfix/*"
  tag_prefix: "prod-"      # Optional; Default is "automerge-" if empty or false, no prefix used

feature:
  base: develop
  branches:
    - "feature/*"
  tag_prefix: false # omitted here; no prefix will be used
```


## The script will:

- Check your working directory is clean.
- Fetch all remote branches.
- Create a temporary branch from the base branch.
- Merge all matching remote branches.
- Tag the commit with a timestamp and environment name.
- Push the tag to the remote.
- Clean up local temporary branch and tag, and restore your original branch.

```mermaid
---
config:
  theme: redux
  layout: dagre
---
flowchart LR
 cliStage(["git automerge --env=staging"]) --> envStage
 cliProd(["git automerge --env=production"]) --> envProd

 subgraph envStage["Env Staging"]
    direction LR
    stageMain(["main"]) --> stagingAutomerge["automerge-***"]
    stageFeature1(["feature/1"]) --> stagingAutomerge
    stageFeature2(["feature/1"]) --> stagingAutomerge
  end
 
 subgraph envProd["Env Production"]
    direction LR
    prodMain(["main"]) --> prodAutomerge["automerge-***"]
    prodFeature1(["feature/1"]) --> prodAutomerge
    prodFeature2(["feature/1"]) --> prodAutomerge
  end

stagingAutomerge -.-> pipeline
prodAutomerge -.-> pipeline
```
