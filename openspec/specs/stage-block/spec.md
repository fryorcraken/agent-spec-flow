# stage-block Specification

## Purpose

Defines the `## Stages` block that opens every specflow change's `tasks.md`: its rows, their order, how a row is ticked or struck, and how a project's extra stages enter it. The runner and the `closer` read the block's state with `grep`, so its text is a contract with every consumer.

## Requirements

### Requirement: The block opens tasks.md with a fixed roster

A change's `tasks.md` MUST open with a `## Stages` heading followed by one checkbox row per stage, in this order and with this text:

```
- [ ] spec — `spec-writer`
- [ ] design + code — `dev-writer`
- [ ] tests — `tester`
- [ ] review: correctness — `code-reviewer`
- [ ] review: security — `code-reviewer`
- [ ] review: readability — `code-reviewer`
- [ ] review: architecture — `code-reviewer`
- [ ] review: spec-test — `spec-test-reviewer`
- [ ] review: design — `design-reviewer`
- [ ] findings all ticked, `findings/` deleted — `closer`
- [ ] `openspec validate --strict`, then `archive` — `closer`
- [ ] CI green, title/body checked, PR merged — `closer`
```

The `spec-writer` MUST write the block, unticked, before any other agent edits `tasks.md`.

#### Scenario: A new change carries the roster

- **WHEN** the `spec-writer` opens `tasks.md` for a change whose project declares no extra stages
- **THEN** the file starts with `## Stages` followed by exactly the twelve rows above, unticked, in that order

#### Scenario: The archive row precedes the merge row

- **WHEN** the block is written
- **THEN** the row naming `archive` appears above the row naming the merge

### Requirement: Each agent instance flips only its own row

An agent MUST tick only the row naming its own stage and, for `code-reviewer`, its own dimension. Agents other than the `spec-writer` MUST NOT add a row, and an agent MUST NOT tick a row on another agent's behalf.

#### Scenario: Four code-reviewer instances

- **WHEN** four `code-reviewer` instances each review one dimension
- **THEN** each ticks the one row naming its dimension, and no two edit the same line

### Requirement: A stage that does not apply is struck, not deleted

A row for a stage that does not apply MUST be struck through and keep its empty box, in the form `- [ ] ~~<row text>~~ — <reason>`. A row MUST NOT be deleted.

#### Scenario: A test-only piece

- **WHEN** a piece adds no behaviour and so has no spec delta
- **THEN** its spec row reads `- [ ] ~~spec — `spec-writer`~~ — ` followed by the reason
- **AND** the row still matches `^- \[ \]`

### Requirement: Every piece has a change folder and a block

A piece MUST have an `openspec/changes/<name>/` folder whose `tasks.md` carries the block, whether or not it changes behaviour. A change with no spec delta MUST declare `skip_specs: true` together with a `schema:` key in its `.openspec.yaml`.

#### Scenario: A docs-only piece

- **WHEN** a piece changes only documentation
- **THEN** `grep -c "^## Stages" openspec/changes/<name>/tasks.md` prints `1`
- **AND** its `.openspec.yaml` contains both `schema:` and `skip_specs: true`

### Requirement: Extra stages from the overlay enter above the closer rows

The `spec-writer` MUST copy each row listed under the overlay's `## Extra stages` into the block verbatim, directly above the first `closer` row. A struck row listed there MUST replace the matching roster row with the struck version.

#### Scenario: A project adds a stage

- **WHEN** the overlay's `## Extra stages` lists `- [ ] review: accessibility — `a11y-reviewer``
- **THEN** that row appears in the block immediately above `- [ ] findings all ticked, `findings/` deleted — `closer``

#### Scenario: A project never runs a stage

- **WHEN** the overlay's `## Extra stages` lists `- [ ] ~~review: security — `code-reviewer`~~ — no untrusted input`
- **THEN** the block's security row is that struck row, in the security row's position
