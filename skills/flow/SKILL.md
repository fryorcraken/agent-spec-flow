---
name: flow
description: The specflow spec-driven flow — which document answers which question, the roles, the stage block, the findings format and the hand-over rules. Preloaded into every specflow role agent; the runner loads it before its first dispatch.
user-invocable: false
---

# The specflow flow

Role agents around [OpenSpec](https://openspec.dev)'s built-in `spec-driven`
schema: OpenSpec supplies the artifacts and their ordering, the agents do the
work. Everything below is addressed to the agent it names. The session that
dispatches agents is the **runner**, and its rules are the `specflow:run` skill.

## Words used throughout

- **`main`** means the repository's default branch, as
  `gh repo view --json defaultBranchRef` reports it.
- **`<owner>/<repo>`** means the repository slug, as
  `gh repo view --json nameWithOwner` reports it. Never take either from a
  config file or from memory.
- **A piece** is one unit of work: one issue, one branch `piece/<name>`, one
  PR, one OpenSpec change `openspec/changes/<name>/`.
- **The overlay** is `.claude/specflow/PROJECT.md`, this project's facts.

## Read the overlay before your first command

Read `.claude/specflow/PROJECT.md` in full before your first shell command. It
holds this project's facts: test layers and their commands, the build, the
mutation tool, the CI gates and what they cannot see, what never to commit,
hazards, extra stages and lessons. A `## <your role>` section, where present,
adds project rules for your role.

The overlay adds facts and role rules. It never overrides a specflow rule,
except by striking a stage under `## Extra stages`. Where specflow text names a
command, a layer or a gate as an example, the overlay's entry is the one to
use.

## The documents, and what each is for

| Document | Question | Where it ends up |
|---|---|---|
| GitHub Issues and Milestones | **What is not built yet** — the roadmap | github.com, not the working tree |
| `proposal.md` | Why this change, which capabilities it touches | `changes/archive/<date>-<name>/` |
| `openspec/specs/` | **What** the system does — the behaviour contract | `openspec/specs/`, current |
| `design.md` | **How**, and **why this approach** (Decisions) | `changes/archive/<date>-<name>/` |
| `tasks.md` | The ordered checklist | `changes/archive/<date>-<name>/` |
| `findings/<dimension>.md` | What each reviewer found, and what was done about it | **Deleted before merge** — durable reasoning moves to `design.md` first |

A change in flight lives in `openspec/changes/<name>/`, and its `specs/` holds a
**delta**. `openspec archive` merges the delta into `openspec/specs/` and moves
the folder to `changes/archive/<date>-<name>/`. To find a past decision, grep
the archive.

Archiving is the `closer`'s. It runs as a commit on the piece branch, before CI
and the merge. Its rules are the `specflow:openspec-archive` skill; read it
before you archive, not before you start.

Run `openspec --version` rather than believing any document about the CLI,
this one included.

### A spec never cites a GitHub issue number as though it were a section

Cite by requirement name, or restate the substance in one clause.

### Reasoning migrates to `design.md`; behaviour migrates to a spec

As a change lands, whatever reasoning or scope motivated it moves out of
wherever it was recorded — a GitHub issue, a conversation with the owner — and
into the document the table above names:

- **Behaviour → the spec.** Once a capability's requirements state it, the
  issue that asked for it can close.
- **Reasoning → `design.md`**, under Decisions.

Reasoning never goes in a spec.

**GitHub Issues and Milestones are the sole source of truth for scope and
roadmap.** Do not create a document that holds "what is not built yet" outside
the issue tracker.

## The roles

| Agent | Reads | Writes |
|---|---|---|
| `spec-writer` | the change's GitHub issue, `openspec/specs/` | `proposal.md`, `specs/`, the stage block |
| `dev-writer` | spec, the change's GitHub issue | `design.md`, `tasks.md`, code, tests-as-it-goes, **the PR** |
| `tester` | spec, inherited tests | the test suite |
| `spec-test-reviewer` | **spec + tests only** | findings |
| `design-reviewer` | code, `design.md`, the change's GitHub issue | findings |
| `code-reviewer` | code | findings |
| `closer` | `tasks.md`, `findings/`, CI, the PR | deletes `findings/`, the archive commit |

**Address the plugin's agents qualified: `specflow:<role>`**, for example
`specflow:code-reviewer`. Other plugins ship agents with similar names and
descriptions, and a project agent of the same name does not replace the
plugin's.

A project may add a role: a project agent plus a row under the overlay's
`## Extra stages`. A project never forks a specflow role.

The reviewers ask different questions:

- `code-reviewer` — **is this code correct, safe and well-shaped?**
- `spec-test-reviewer` — **do the tests pin what the spec requires, and can they
  fail?**
- `design-reviewer` — **did the code take the decisions that were recorded, and
  were the decisions worth recording recorded?**

**`code-reviewer` runs once per dimension** — correctness, security,
readability, architecture — and the dispatch names which. A small change can
take one instance covering all four. A full review is six agents.

**`spec-test-reviewer` never reads the implementation**, except the lines it
mutates.

**A change with no source diff still gets reviewed.** Agent instruction files,
config and prose are reviewable material.

## One piece of work is one branch and one PR

Every stage — spec, design, code, tests, review fixes — lands as **commits on
one remote branch, `piece/<name>`, under one PR**.

- Only `piece/<name>` is ever pushed. `origin/<anything-else>` is a mistake.
- A second PR on one piece is a mistake.
- `openspec archive` runs once, as a commit on the piece branch, inside the same
  PR.

### One writer at a time; reviewers in parallel

- **A piece has at most one `spec-writer`, `dev-writer` or `tester` running —
  one in total**, not one of each.
- **When review routes a spec gap, the fixer stops, the spec lands, and the
  fixer restarts against the new text.** A spec never moves while code is being
  written or reviewed against it.
- **Nothing writes the piece while `tester` runs.** It mutates implementation
  code it does not own.
- **Reviewers run in parallel, up to six**, each in its own worktree, each
  writing only its own findings file.

### Commits

The branch and worktree rules are the `specflow:worktree-discipline` skill.
In short: every dispatched agent commits to its own harness-named branch and
reports the name; the runner cherry-picks onto `piece/<name>`; only the
`dev-writer` and the `closer` push, and only by refspec to the remote piece ref.

**Never `git add -A`.** Commit named paths. Never commit what the overlay's
`## Never commit` lists, nor anything under `./tmp/` or `.claude/worktrees/`.

## Two files carry the state of a change

### The stage block in `tasks.md`

**`tasks.md` opens with a `## Stages` block**, written once by `spec-writer`,
unticked: one row per stage, then three rows the `closer` owns. The roster is
in the `spec-writer` agent, which writes it.

- **One row per agent instance, not per role.** `code-reviewer` has one row per
  dimension, each ticked by the instance that did it.
- **Each agent flips its own row and adds none.**
- **An unticked row with no agent running is a stage nobody is doing.**
- **A stage that does not apply is struck through with its reason, never
  deleted.** A struck row keeps its empty box: read the strike, not the box.
  `openspec archive` counts a struck row as incomplete and warns; that is
  expected.
- **A piece with no behaviour change still gets a change folder and a stage
  block.** Its spec row is struck through with that reason, and the change's
  `.openspec.yaml` declares `skip_specs: true` **alongside a `schema:` key** —
  on its own, the marker is reported as "not valid change metadata, so the
  marker is not honored".

### The findings files

**`findings/<dimension>.md`**, one file per reviewer — `correctness`,
`security`, `readability`, `architecture`, `spec-test`, `design-review`.
**Every finding is a checkbox**, written unticked by the reviewer:

```markdown
- [ ] **`dev-writer`** — `wire.rs:96` — what is wrong
      **Scenario:** inputs → wrong output. **Measured:** the number, if there is one.
```

Whoever acts on it flips the box and appends the outcome — **fixed** (with the
test that fails without it), **rejected** (with the argument), or **deferred**
(and where to) — without editing the reviewer's text. The `closer` deletes the
directory before merge, once no box is empty.

- **An unticked entry blocks the merge.** `grep -rn "^- \[ \]"` over the
  directory either returns lines or it does not.
- **The gate only sees checkboxes.** Before trusting an empty result, check
  every file has boxes at all: `grep -rc "^- \[" findings/` must be non-zero for
  each one.
- **Findings stay attributable.** A fixer that disagrees argues with the
  reviewer the entry names.
- **Never relay a finding through a brief.** Name the file.

Durable reasoning moves into `design.md` before the tracker is deleted.

## Handing over between agents

- **Read the files another agent wrote** — findings, `design.md`, `tasks.md`.
  An agent's report goes to the runner, not to you; anything the next agent
  needs must be in a file.
- **A brief points at the work; it does not contain it.** It names the piece,
  the piece branch and the file to read. It carries no worktree instructions,
  no `git -C <worktree>` and no `EnterWorktree`:

  > Act on the findings for `dev-writer` in
  > `openspec/changes/wire-request-envelope/findings/`. Piece branch
  > `piece/wire-request`. Commit to your own branch and say what it is called,
  > so the work can be cherry-picked onto the piece.

- **If you are writing out what a finding says, you have the wrong shape.**
  Reports work the same way in reverse: path, count, who each entry is for.
- **Continue an agent rather than starting a new one** when it still holds the
  worktree and measurements the work needs.
- **Write the dead end down.** An approach proven impossible goes in
  `design.md`, beside the decision it rules out.

The runner owns dispatching. The `dev-writer` opens the PR at the end of its
first pass. The `closer` owns the last three stage rows.

## Bash costs

Every agent follows the specflow block in `CLAUDE.md` — "How to work here, and
what Bash costs" — before its first shell command. Most often broken:

- **Never chain.** `cd somewhere && <command>` prompts even when `<command>` is
  allow-listed. One plain command per call; `cd` alone in its own call.
- **A long output is not a reason to pipe.** Run it plain and read the whole
  thing.
- **`gh` is free until you filter it.** No `--jq`; read the JSON.
- **`<producer> | grep -q` exits 141** when `grep -q` closes the pipe early and
  the producer dies of SIGPIPE. Use `[ "$(… | grep -c …)" -gt 0 ]`, which
  consumes all the output.

## Rules every role applies

- **Run the command before you write the number.** Any count, duration or
  quantity in a report, a task list, a doc comment or a commit message comes
  from a command run against the tree in front of you — `grep -c`, `git log -S`,
  the suite.
- **When you correct a stale number, measure it fresh.** Never apply the delta
  a reviewer quoted.
- **A test asserts against something the implementation did not produce** — a
  hardcoded expectation, or one derived independently. Three shapes that cannot
  fail for the reason they name:
  - comparing inputs that differ for an unrelated reason (`"ab"` against
    `"abc"` to prove a length prefix matters);
  - asserting a property of a library instead of the code (a hash moved after a
    byte changed);
  - asking the implementation what it wrote and agreeing
    (`assert_eq!(bytes[0], VERSION_1)`).
- **The mutation tool complements reading; it does not replace it.** The
  overlay's `## Mutation tool` names the tool and its blind spots.
- **Mark unspecified behaviour in the code.** When the spec is silent and the
  dev chooses, the test carries a `NO SPEC: <what was chosen>` comment.
- **Never write a scenario that cannot be tested.** Describe what is checkable,
  or say it is out of scope.
- **Read the GitHub issue and `openspec/specs/` fresh**, never from memory or a
  paraphrase.
- **Say what a gate cannot see** rather than reporting it as passed. The
  overlay's `## CI gates` and `## Test layers` record each gate's blind spots.
- **Design against silent failure.** The overlay's `## Hazards` lists where this
  project fails without an error.
- **Never report a result you did not obtain against the tree in question.**
