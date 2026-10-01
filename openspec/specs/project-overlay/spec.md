# project-overlay Specification

## Purpose

Defines the project overlay, `.claude/specflow/PROJECT.md`: its location, its required headings, how unfilled headings are marked, and how the runner treats them. Every consumer writes this file, so its shape is a contract.

## Requirements

### Requirement: The overlay lives at a fixed, tracked path

A consumer's overlay MUST be `.claude/specflow/PROJECT.md` at the repository root, tracked by git. `/specflow:init` MUST write `.gitignore` rules that track it while ignoring the rest of `.claude/` except `settings.json` and `agents/`.

#### Scenario: Every worktree has the overlay

- **WHEN** an agent is dispatched into a fresh worktree of a consumer
- **THEN** `.claude/specflow/PROJECT.md` exists in that worktree

### Requirement: The overlay carries eight required headings

The overlay MUST contain these level-two headings: `## Test layers`, `## Build`, `## Mutation tool`, `## CI gates`, `## Never commit`, `## Hazards`, `## Extra stages`, `## Lessons`. Further level-two headings named after a role, such as `## dev-writer`, are permitted and hold rules for that role.

#### Scenario: Init writes every heading

- **WHEN** `/specflow:init` runs in a repository with no overlay
- **THEN** the overlay it writes contains all eight required headings

#### Scenario: Sync reports a missing heading

- **WHEN** `/specflow:sync` runs and the overlay lacks `## Hazards`
- **THEN** its report names `## Hazards` as missing and it does not add it

### Requirement: Unfilled headings hold TODO, and the runner refuses them

`/specflow:init` MUST write a line reading exactly `TODO` under each required heading. `/specflow:run` MUST refuse to dispatch any agent while any line of the overlay reads exactly `TODO`, and MUST name the headings that still hold one.

#### Scenario: A half-filled overlay

- **WHEN** the overlay's `## Mutation tool` still reads `TODO` and every other heading is filled
- **THEN** `/specflow:run` dispatches nothing and names `## Mutation tool`

#### Scenario: None is an answer

- **WHEN** `## Extra stages` reads `None.`
- **THEN** `/specflow:run` treats the heading as filled

### Requirement: Repository facts never come from the overlay

The repository slug and the default branch MUST be read from `gh repo view`, never from the overlay or any other config file.

#### Scenario: A renamed default branch

- **WHEN** the default branch is renamed on GitHub
- **THEN** no specflow file in the consumer needs editing for the flow to use the new name
