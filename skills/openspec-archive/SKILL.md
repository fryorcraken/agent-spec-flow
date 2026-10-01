---
name: openspec-archive
description: How to archive an OpenSpec change in the specflow flow — what archive does, the delta-to-spec transformation and how to diff it, the traps that lose a requirement silently, archive order, and reading capabilities together. Preloaded into the closer; read before archiving, not before starting.
user-invocable: false
---

# Archiving an OpenSpec change

Read this when you are **archiving**: the `closer` does it, as a commit on the
piece branch, before CI and before the merge.

- **Archive before the merge, on the piece branch.** The code, the spec delta
  and its promotion land as one squashed commit under one PR.
- **Never archive after the merge.** That needs a direct push to `main`, which
  nobody makes.
- **Run `openspec --version`** rather than believing any document about the
  CLI, this one included.

## What archive does

While a change is in flight it lives in `openspec/changes/<name>/`, and its
`specs/` holds a **delta** (`## ADDED Requirements`, `## MODIFIED Requirements`,
`## REMOVED Requirements`). `openspec archive`:

1. **offers to merge the delta into `openspec/specs/`.** Take it. Declining
   archives without promoting the spec.
2. **moves the folder** to `openspec/changes/archive/<date>-<name>/`, dated
   today unless the name already carries a date, which is never stacked.

`proposal.md`, `design.md` and `tasks.md` are moved, not deleted.

- A change declaring `retire_capabilities: true` makes archive **delete** a
  spec instead of merging into it.
- **A change that declared `skip_specs: true` has no delta to promote.** Archive
  it with `--skip-specs`.
- **`archive` aborts and writes nothing if the target spec has no
  `## Purpose`.**

## The transformation, and diffing it

For a capability `openspec/specs/` does not yet hold, archive makes exactly two
edits:

1. prepend `# <capability> Specification` and a blank line;
2. rename `## ADDED Requirements` to `## Requirements`.

Everything else carries across byte-for-byte. **The CLI does not report what it
changed: diff the promoted file against the delta** and confirm those are the
only hunks.

## Traps none of the files show

- **Deltas vary in shape.** Some carry a `## Purpose`, some a title line and
  none, some open directly on `## ADDED Requirements`. Do not assume a Purpose.
- **A `MODIFIED` requirement replaces the WHOLE block, scenarios included.**
  Replacing the prose and keeping the old scenarios produces a requirement whose
  scenarios contradict it, with no error.
- **A `MODIFIED` heading that matches nothing stops the merge.** Check every
  heading against the target's actual `### Requirement:` lines, character for
  character, and report a miss rather than guessing.
- **A live spec can differ from its delta** where someone hand-edited it after
  the delta. Before using a past archive as a reference example, diff its delta
  against the live spec. The overlay's `## Hazards` names known bad examples.
- **`validate --strict` checks heading structure, not consistency.** It passes a
  spec that contradicts itself. Re-read the whole requirement after editing it.

**Archive in merge order, oldest first**, when more than one change is waiting:
a later `MODIFIED` applies to the text an earlier `ADDED` produced. Derive the
order from `git log --name-status --diff-filter=A -- openspec/changes`; never
from folder names. The archive date is the day you archive.

## The root comes from the cwd

Every command reports its root — `openspec list --json` ends with
`"root": {"path": …, "source": "nearest"}` — and "nearest" means it walks up
from the cwd to the first `openspec/`. There is no `--directory`, `-C` or
`--root`. `--store` takes a registered store id, not a path.

- **Check the reported root before concluding a change is missing or the CLI is
  broken.**
- **Do not call `EnterWorktree`** to fix a wrong root, and do not write
  `cd <dir> && openspec … <path>`.
- **If validation cannot run, say in the report that it did not run, and why.**

## Reading two capabilities together

- **Read every capability this change touches beside the others it touches.** A
  contradiction between two capabilities is invisible until they sit in one
  contract, and archiving is that moment.
- **A contradiction found there is resolved, never archived.** Resolving it is a
  spec change: the `closer` reports it to the runner, which routes it to the
  `spec-writer`.
- **One rule, one capability.** Where two capabilities assert the same rule,
  report it; which capability owns the rule is a design call, not the archive's.
  A capability that borders another's rule names that requirement and the
  boundary in its Purpose rather than restating it.

## Moving requirements between capabilities

When a second instance shows that requirements written for one capability are
about a general one, they move: `REMOVED` from the old spec and `ADDED` to the
new, **verbatim**, in one change. OpenSpec has no move or rename. Move only when
the generality is demonstrated, not predicted.
