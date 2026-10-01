# agent-spec-flow

**specflow** is a Claude Code plugin for spec-driven, multi-agent development.
[OpenSpec](https://openspec.dev)'s `spec-driven` schema supplies the artifacts
(proposal, spec, design, tasks). specflow supplies role subagents that write and
review them, a runner that dispatches those agents, and a project manager.

This repository is the plugin's marketplace as well as the plugin itself.

## What a piece of work looks like

One GitHub issue becomes one **piece**: one branch `piece/<name>`, one PR, and
one OpenSpec change. The runner, an interactive session started with
`/specflow:run <issue#>`, dispatches the agents one stage at a time. Each agent
gets its own git worktree, and the runner cherry-picks its commits onto the
piece branch.

| Stage | Agent |
|---|---|
| proposal + spec + stage block | `specflow:spec-writer` |
| `design.md`, `tasks.md`, code, **the PR** | `specflow:dev-writer` |
| the test suite, each test shown able to fail | `specflow:tester` |
| review × 4 — correctness, security, readability, architecture | `specflow:code-reviewer` |
| review — do the tests pin the spec (never reads the code) | `specflow:spec-test-reviewer` |
| review — did the code take the recorded decisions | `specflow:design-reviewer` |
| findings gate, archive, CI, squash merge on the owner's word | `specflow:closer` |

`tasks.md` opens with a `## Stages` block, one row per agent instance, and every
reviewer finding is a checkbox under `findings/`. Both are plain text, so
`grep` can tell what is left to do and whether anything is still blocking the
merge.

## Requirements

- Claude Code, run from an interactive session.
- GitHub, with `gh` authenticated (`gh auth status`). Squash merge must be
  allowed.
- The [OpenSpec CLI](https://openspec.dev) (`openspec --version`).
- Branch protection on the default branch, and CI on `pull_request`.
  `/specflow:init` checks these and reports gaps. It never changes GitHub
  settings.

## Install

```
/plugin marketplace add fryorcraken/agent-spec-flow
/plugin install specflow@agent-spec-flow
```

Then, in the project's repository:

```
/specflow:init
```

This writes `.claude/settings.json` (`worktree.baseRef: "head"`, the marketplace
entry, `enabledPlugins`, and a base allowlist for `git`, `gh` and `openspec`),
the `.gitignore` rules, the overlay skeleton `.claude/specflow/PROJECT.md`, and a
version-stamped block in `CLAUDE.md`. It also runs `openspec init`. Afterwards:

1. Fill in every `TODO` in `.claude/specflow/PROJECT.md`: the project's test
   layers, build, mutation tool, CI gates and their blind spots, files never to
   commit, hazards, extra stages and lessons. `/specflow:run` refuses to start
   while any `TODO` remains.
2. Add the project's own test, build and lint commands to
   `permissions.allow`.
3. Commit what init wrote.

## Use

| Command | What it does |
|---|---|
| `/specflow:run <issue#>` | Starts the runner for one issue: preflight checks, the piece worktree, then every dispatch through to the `closer`. |
| `/specflow:pm` | The project manager role: scope into issues and milestones, dogfooding, sweeps. It writes no code. |
| `/specflow:sync` | Rewrites the specflow block in `CLAUDE.md` for the installed version. The runner warns when the stamp is behind. |
| `/specflow:init` | Sets up a repository, as above. |

## Customising

- **Project facts** live in the overlay, `.claude/specflow/PROJECT.md`. It may
  also carry a `## <role>` section with project rules for one role.
- **Extra roles**: add a project agent under `.claude/agents/` and a row for it
  under the overlay's `## Extra stages`.
- **Skipping a stage**: list it struck through, with its reason, under
  `## Extra stages`.
- **Models and effort are fixed** by the plugin. Projects never fork a
  plugin role.

## Development

Use a local-directory marketplace and reload after each edit:

```
/plugin marketplace add /path/to/agent-spec-flow
/plugin install specflow@agent-spec-flow
/reload-plugins
```

For a one-off session, `claude --plugin-dir /path/to/agent-spec-flow` loads the
plugin without installing it.

Before a release:

```
claude plugin validate .claude-plugin/plugin.json
claude plugin validate .
sh scripts/check-version.sh
openspec validate --specs --strict
```

The version is semver, set in `.claude-plugin/plugin.json` and
`.claude-plugin/marketplace.json`. It is also repeated in the `CLAUDE.md` block
stamp (`skills/sync/SKILL.md`) and in `skills/run/SKILL.md`, because skills
cannot read the manifest at run time. `scripts/check-version.sh` fails when the
copies disagree.

This repository's own process: every change goes through a PR, with one reviewer
covering correctness, security, readability and architecture. `openspec/specs/`
specifies only the contracts consumers depend on: the stage block, the findings
format, the branch names and the overlay headings.

`DECISIONS.md` records why the plugin is shaped this way. `LESSONS.md` keeps the
history behind each rule, for the maintainer only: the text agents read carries
only the rules.

## Licence

Dual-licensed under [MIT](LICENSE-MIT) or [Apache-2.0](LICENSE-APACHE-v2), at
your option.
