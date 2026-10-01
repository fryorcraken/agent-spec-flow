---
name: init
description: Set up a repository for specflow — project settings, .gitignore rules, the overlay skeleton, the CLAUDE.md block and OpenSpec — then check gh auth and branch protection and report gaps. Use only when the owner runs /specflow:init.
disable-model-invocation: true
---

# /specflow:init

Sets up the current repository for specflow. Running this command is the
owner's request to write the files below, and nothing else. **Never change a
GitHub setting**: check and report.

Use the `Read`, `Edit` and `Write` tools for every file. Run each shell command
as its own plain call, with no pipes, `&&` or redirects.

## 0. Preconditions

Run each, and stop with a report if any fails:

```
git rev-parse --show-toplevel
gh auth status
gh repo view --json nameWithOwner,defaultBranchRef
openspec --version
```

The repository root is the first line's answer; every path below is relative to
it. `<owner>/<repo>` and the default branch come from `gh repo view`, never from
a config file. A missing `openspec` is reported, and step 5 is skipped.

## 1. `.claude/settings.json`

Read the file if it exists and **merge** into it; never drop a key the owner
already has. Create it if absent. Afterwards it must carry:

```json
{
  "worktree": { "baseRef": "head" },
  "extraKnownMarketplaces": {
    "agent-spec-flow": { "source": <see below> }
  },
  "enabledPlugins": { "specflow@agent-spec-flow": true },
  "permissions": {
    "allow": [
      "Bash(git *)",
      "Bash(gh pr *)",
      "Bash(gh run *)",
      "Bash(gh issue *)",
      "Bash(gh api *)",
      "Bash(gh repo view *)",
      "Bash(openspec *)",
      "Bash(grep *)",
      "Bash(pwd)"
    ]
  }
}
```

- **Allow rules are appended** to any existing `permissions.allow`, without
  duplicates. Add no stack commands; the owner adds those.
- **The marketplace source** comes from `claude plugin marketplace list --json`,
  from the entry named `agent-spec-flow`:
  - `"source": "github"` → `{ "source": "github", "repo": "<its repo>" }` in
    `settings.json`.
  - `"source": "directory"` → `{ "source": "directory", "path": "<its path>" }`,
    written to `.claude/settings.local.json` instead, since a local path is
    machine-local; say so in the report. Any other local source: the same.
  - no such entry → write
    `{ "source": "github", "repo": "fryorcraken/agent-spec-flow" }` and say so.
- If `worktree.baseRef` already holds a value other than `"head"`, do not
  overwrite it; report it, because specflow agents then fork from the wrong
  base.

## 2. `.gitignore`

Ensure these lines are present, appending any that are missing under a comment
`# specflow`. Leave existing lines alone:

```
.claude/*
!.claude/settings.json
!.claude/specflow/
!.claude/agents/
tmp/
```

The overlay and project agents must be tracked so that every worktree has them.
If an existing rule ignores `.claude/` itself (a `.claude/` or `.claude` line
rather than `.claude/*`), report it: git never re-includes a file whose parent
directory is excluded, so the negations above would have no effect.

## 3. The overlay: `.claude/specflow/PROJECT.md`

**If the file exists, leave it untouched** and only report which required
headings it lacks. Otherwise write exactly:

```markdown
# specflow project overlay

<!--
Read in full by every specflow agent before its first shell command. It holds
this project's facts; it does not change specflow's rules. Replace each TODO.
"None." is a valid answer. /specflow:run refuses to dispatch while any line
reads TODO.

Optional: add a `## <role>` section (for example `## dev-writer` or
`## code-reviewer`) to give that role project-specific rules — typically the
project's security posture (what input is untrusted, where it is validated,
whether a crash is a denial of service) and its API conventions.
-->

## Test layers

<!-- One row per layer: the command that runs it (runnable from the repository
root, one plain command), what it can see, and what it structurally cannot. -->

TODO

## Build

<!-- The build command, where its output lands, and whether it resolves its root
from the cwd. -->

TODO

## Mutation tool

<!-- The mutation-testing command, how to scope it to the changed files, its
time budget, and what it cannot mutate. "None." if the project has none. -->

TODO

## CI gates

<!-- Each required check: what it runs, what triggers the workflow (for example
pull_request only), and its blind spots — what a green result does not prove. -->

TODO

## Never commit

<!-- The build output, symlinks and generated files a worktree collects that
must never be committed. `./tmp/` and `.claude/worktrees/` are already
excluded by specflow. -->

TODO

## Hazards

<!-- Where this project fails silently or misleadingly: tools that report
success from the wrong tree, wrappers to use instead of env prefixes, switches
that make a failure visible, constants that look invalid and are not. -->

TODO

## Extra stages

<!-- Rows spec-writer adds to every stage block, before the three closer rows,
each naming a project agent: `- [ ] <stage> — `<agent>``. A specflow stage this
project never runs is listed struck through with its reason:
`- [ ] ~~review: security — `code-reviewer`~~ — <reason>`. "None." if neither. -->

TODO

## Lessons

<!-- Lessons about specflow itself, each agreed with the owner and filed upstream
as an issue on fryorcraken/agent-spec-flow, with its link. "None." to start. -->

TODO
```

## 4. The `CLAUDE.md` block

Invoke the `specflow:sync` skill and follow it.

## 5. OpenSpec

If `openspec/` does not exist at the repository root, run:

```
openspec init --tools none --no-animation .
```

`--tools none` because specflow's agents drive OpenSpec through
`openspec instructions`, not through OpenSpec's own slash commands. If
`openspec/` exists, leave it and report `openspec validate --all` instead.

## 6. Check GitHub, and report — never change

Run each as its own plain call, and read the JSON:

```
gh api repos/<owner>/<repo>
gh api repos/<owner>/<repo>/branches/<default>/protection
```

Report each of these as **ok** or **gap**:

- **Squash merge is allowed** (`allow_squash_merge`). specflow requires it.
- **The default branch is protected** (the second call does not return 404).
- **Direct pushes are refused**, including for admins (`enforce_admins`).
- **Required status checks exist**, and `strict` is on.
- **A CI workflow runs on `pull_request`** — look in `.github/workflows/`.
- **Required approving reviews** — report the count. With 0, nothing but the
  `closer`'s question to the owner stands between green and `main`.
- **Signed commits required** — report it; the `closer` then treats a signing
  failure as stop-and-ask.

## 7. The report

List every file written or changed, every gap from step 6, and the owner's next
steps:

1. Replace every `TODO` in `.claude/specflow/PROJECT.md`.
2. Add the project's stack commands (test, build, lint, mutation) to
   `permissions.allow` in `.claude/settings.json`.
3. Review and commit `.claude/settings.json`, `.claude/specflow/PROJECT.md`,
   `.gitignore`, `CLAUDE.md` and `openspec/`.
4. Restart the session, or run `/reload-plugins`, then run
   `/specflow:run <issue#>` from an interactive session.

Do not commit anything yourself.
