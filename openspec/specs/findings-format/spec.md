# findings-format Specification

## Purpose

Defines the reviewers' findings files: where they live, how each finding is written, and how an outcome is recorded. The merge gate is a `grep` over these files, so their format is a contract with every consumer.

## Requirements

### Requirement: One findings file per reviewer dimension

Each reviewer MUST write its findings to `openspec/changes/<name>/findings/<dimension>.md`, where `<dimension>` is one of `correctness`, `security`, `readability`, `architecture`, `spec-test` or `design-review`. A reviewer MUST write only its own file.

#### Scenario: The design reviewer's file

- **WHEN** the `design-reviewer` reports
- **THEN** it writes `findings/design-review.md` and never `findings/design.md`

### Requirement: Every finding is an unticked checkbox naming who it is for

Each finding MUST be a Markdown list item starting `- [ ] ` followed by the bold, code-formatted name of the role it is for (`spec-writer`, `dev-writer` or `tester`), then the location, then what is wrong, with any further lines indented beneath it:

```markdown
- [ ] **`dev-writer`** — `wire.rs:96` — what is wrong
      **Scenario:** inputs → wrong output. **Measured:** the number, if there is one.
```

A finding MUST NOT be written as a heading or as prose outside a checkbox.

#### Scenario: The merge gate sees every finding

- **WHEN** a reviewer writes three findings
- **THEN** `grep -c "^- \[ \]" findings/<dimension>.md` prints `3`

### Requirement: An outcome is appended, never edited in

The agent acting on a finding MUST flip its box to `[x]` and append one of **Fixed** (with the commit and the test that fails without it), **Rejected** (with the argument) or **Deferred** (with where it now lives), below the reviewer's text. It MUST NOT edit the reviewer's text.

#### Scenario: A fixed finding

- **WHEN** the `dev-writer` fixes a finding
- **THEN** the line starts `- [x] **`dev-writer`**`, the reviewer's lines are unchanged, and a line beginning `**Fixed**` follows them

### Requirement: Findings block the merge until answered, then are deleted

The `closer` MUST NOT merge while `grep -rn "^- \[ \]"` over the findings directory returns any line, or while `grep -rc "^- \["` reports `0` for any file in it. Once both hold, the `closer` MUST delete the directory before archiving.

#### Scenario: A file with no boxes

- **WHEN** a findings file contains findings written as headings
- **THEN** `grep -rc "^- \["` reports `0` for it and the `closer` stops and reports the file
