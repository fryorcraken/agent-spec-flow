# branch-names Specification

## Purpose

Defines the branch and worktree names the flow uses and which of them may reach the remote. Consumers' branch protection, CI triggers and cleanup scripts key off these names.

## Requirements

### Requirement: One piece branch per piece

Each piece MUST have exactly one task branch, named `piece/<name>`, where `<name>` is the name of its OpenSpec change. Its worktree MUST be `.claude/worktrees/piece-<name>`, created with `git worktree add --no-track` from `origin/<default-branch>`.

#### Scenario: The piece branch has no upstream

- **WHEN** the runner creates the piece worktree
- **THEN** `git config --get-regexp "^branch\.piece/<name>"` prints nothing

### Requirement: Only the piece branch reaches the remote

`piece/<name>` MUST be the only branch the flow pushes. It MUST be pushed only by the `dev-writer` and the `closer`, and only by refspec to `refs/heads/piece/<name>`. Agents MUST NOT push the default branch.

#### Scenario: An agent's branch stays local

- **WHEN** any dispatched agent finishes
- **THEN** no `worktree-agent-<id>` ref exists on the remote

### Requirement: Agent branches are named by the harness and reported

Each dispatched agent MUST work on its own branch in its own worktree under `.claude/worktrees/`, named by the harness (`worktree-agent-<id>`), and MUST report that name as read from `git rev-parse --abbrev-ref HEAD`.

#### Scenario: The report names the branch

- **WHEN** an agent hands back
- **THEN** its report contains the branch name `git rev-parse --abbrev-ref HEAD` printed in its worktree

### Requirement: One pull request per piece

Each piece MUST have exactly one pull request, with head `piece/<name>` and base the default branch, opened by the `dev-writer` at the end of its first pass and merged by squash.

#### Scenario: The findings pass reuses the PR

- **WHEN** the `dev-writer` acts on findings
- **THEN** `gh pr list --head piece/<name>` returns one row before and after its push
