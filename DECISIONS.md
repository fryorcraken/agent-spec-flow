# agent-spec-flow: extraction decisions

Settled 2026-09-29 in a design interview. Source of the flow being extracted:
`~/src/rad/dialectica` — `.claude/agents/*.md` (README.md, RUNNER.md and 7 roles),
`CLAUDE.md` (generic sections), `docs/OPENSPEC-ARCHIVE.md`,
`docs/PROJECT-MANAGEMENT.md`, `.claude/settings.json`. Dialectica HEAD at
extraction start: `6a7e02b9`.

## What this is

A Claude Code plugin, `specflow`, packaging dialectica's spec-driven multi-agent
flow (OpenSpec `spec-driven` schema + role subagents) for reuse across projects.

## Decisions

| # | Area | Decision |
|---|---|---|
| 1 | Harness | Claude Code only. |
| 2 | Spec layer | OpenSpec. |
| 3 | Delivery | Claude Code plugin. The repo is both the marketplace and its only plugin. |
| 4 | Name / hosting / licence | Plugin `specflow` (agents addressed `specflow:<role>`), repo `agent-spec-flow`, GitHub, MIT + Apache-2.0. |
| 5 | Scope | The 7 roles, the flow (README), the runner, the OpenSpec archive doc, and the generic `CLAUDE.md` rules (Bash costs, worktrees + `--no-track`, `./tmp/` scratch, "don't write down what a command can answer", "the plugin is the owner's", engineering principles, tests-with-the-change, make-the-failure-visible). The project-manager role is generalised with dialectica milestone content removed. CI and branch-protection expectations are prerequisites init checks, not a CI template. |
| 6 | Forge | GitHub + `gh` are hard requirements for now. Squash merge is required. |
| 7 | Project specifics | One overlay at `.claude/specflow/PROJECT.md`. Required headings: `## Test layers` (command, what it can and cannot see), `## Build`, `## Mutation tool`, `## CI gates` (incl. blind spots), `## Never commit`, `## Hazards`, `## Extra stages`, `## Lessons` (upstream candidates). Optional `## <role>` subsections. Init writes `TODO` under each heading, and `/specflow:run` refuses to dispatch while any remain. Repo slug and default branch come from `gh repo view`, never from config. |
| 8 | Always-on rules | Plugins cannot inject context into every session or subagent. `/specflow:init` and `/specflow:sync` write a version-stamped block (`<!-- specflow:begin vX.Y.Z -->` … `<!-- specflow:end -->`) into the project's `CLAUDE.md` and rewrite only between the markers. The runner warns when the stamp is behind the installed plugin. |
| 9 | Shared agent text | Plugin skills preloaded through agent frontmatter `skills:`: `flow`, `worktree-discipline`, `openspec-archive`. No generator or build step. **Verify the preload works for plugin agents before building on it.** |
| 10 | Runner / PM | Skills `/specflow:run <issue#>` and `/specflow:pm`. The PM skill stays unreferenced by the coding roles. |
| 11 | Lessons | `LESSONS.md` is for the maintainer only; each story links to the rule it produced. Agent-facing text carries **rules only, no stories or reasons**, so rules must be written tight enough to stand alone. Domain lessons (Ed25519, QML, SDK panics) go to dialectica's overlay. |
| 12 | Customisation | Projects may add roles (a project agent plus an `## Extra stages` row). Stages are dropped only as struck rows with a reason. Projects never fork plugin roles. Models and effort are fixed in the plugin frontmatter. |
| 13 | Upstreaming | Agents never edit the plugin. A runner that finds a generic lesson asks the owner, then files an issue on agent-spec-flow. |
| 14 | Versioning | Semver in the manifest. Development uses a local-directory marketplace plus `/reload-plugins`. |
| 15 | Init | Writes into `.claude/settings.json`: `worktree.baseRef: "head"`, the marketplace entry, `enabledPlugins`, and a base allowlist for the workflow's own commands (`git`, `gh pr/run/issue/api`, `openspec`). Also writes `.gitignore` rules (ignore `.claude/*`, re-admit `settings.json`; ignore `tmp/`), the overlay skeleton and the `CLAUDE.md` block, and runs `openspec init`. Checks `gh auth` and branch protection and **reports** gaps; never changes GitHub settings. Stack commands are added to the allowlist by the owner. |
| 16 | Fixed conventions | `piece/<name>`, `./tmp/`, `.claude/worktrees/`, `findings/<dimension>.md`, `## Stages`. None are configurable. |
| 17 | v0.1.0 | Faithful extraction: split generic from dialectica-specific, no behaviour or format changes, so dialectica's in-flight changes keep working. Log improvements seen during extraction for v0.2+. |
| 18 | This repo's own process | PRs + one reviewer covering all four dimensions. OpenSpec specs only for the contracts consumers depend on: stage block, findings format, branch names, overlay headings. |
| 19 | History | Fresh repo; the first commit cites dialectica `6a7e02b9`. |

## Plugin facts relied on (from docs, 2026-09-29)

- Plugin agents are `<plugin>:<agent>`. A project `.claude/agents/<same-name>.md` does not shadow them; both load.
- Plugin agent frontmatter honours `model`, `effort`, `tools`, `skills`, `isolation: worktree`, `omitClaudeMd`. It ignores `hooks`, `permissionMode`, `mcpServers`.
- Plugin `settings.json` honours only `agent` and `subagentStatusLine`, so `worktree.baseRef` must live in the project's settings.
- No stable path to plugin files from `CLAUDE.md` `@import` (versioned cache dir).

## Verified during the v0.1.0 build (2026-09-30, Claude Code 2.1.284)

- **Decision 9's preload works for plugin agents.** A probe plugin's agent with
  `tools: Read` and `skills: [flowprobe]` or `skills: [probe:flowprobe]`
  reported a canary token that existed only in the skill; the same agent
  without `skills:` reported none. specflow uses the qualified form
  (`specflow:flow`).
- **`${CLAUDE_PLUGIN_ROOT}`, `${CLAUDE_SKILL_DIR}` and `$ARGUMENTS` expand in
  plugin skills.**
- **A plugin skill cannot read the plugin's own files** under
  `permissions.blockReadsOutsideWorkingDirectories`: `Read` of
  `${CLAUDE_PLUGIN_ROOT}/…` is refused, and a `` !`cat …` `` injection fails the
  whole skill. Measured with `--plugin-dir`. **From a marketplace install the
  cache (`~/.claude/plugins/cache/agent-spec-flow/specflow/0.1.0/`) is
  readable**, so the limit hits development and `--plugin-dir` users only.
  Consequence for the layout, kept because inline works in both cases: **no
  `templates/` directory.** The overlay skeleton
  and settings live inline in `skills/init/SKILL.md`, the `CLAUDE.md` block in
  `skills/sync/SKILL.md`, and `scripts/check-version.sh` keeps the repeated
  version honest. `LESSONS.md` § "Seen during extraction" logs this and the
  other deviations (`.gitignore` re-admits `.claude/specflow/` and
  `.claude/agents/`; `gh repo view` joins the base allowlist).

### Step 2, on a fresh repo through the local marketplace (2026-10-01)

Installed with `claude plugin install specflow@agent-spec-flow --scope local`
into a scratch repo whose `origin` pointed at dialectica, for read-only `gh`
answers only.

- **Preload from the install:** a dispatched `specflow:closer` saw the first
  heading of `flow`, `worktree-discipline` and `openspec-archive`, in order.
- **`/specflow:init`:** passed its preconditions, wrote `.gitignore`, the block,
  `openspec/`, `settings.json`, and the marketplace entry in
  `settings.local.json` (directory source). It reported the GitHub checks
  (protection ok, 0 required approvals, signing on) and changed nothing on
  GitHub. **Writes under `.claude/` are approval-gated by Claude Code even in
  acceptEdits mode** ("sensitive file"); in an interactive owner run that is a
  prompt per file, which is the intended gate.
- **`/specflow:run`:** refused with eight `TODO` headings listed; with the
  overlay filled and the stamp set to `v0.0.9`, warned and continued.
- **`/specflow:sync`:** moved the stamp `v0.0.9` → `v0.1.0`, left owner text
  above and below the markers untouched.
- **Isolation:** `specflow:design-reviewer` dispatched with
  `isolation: "worktree"` landed in `.claude/worktrees/agent-<id>` on
  `worktree-agent-<id>` at the dispatching session's HEAD.
- **Not tested: a full piece** (dev-writer push, PR, CI, closer merge). It needs
  a GitHub repo the flow may push to; that is dialectica's migration piece
  (step 3) or a sandbox repo the owner creates.

## Layout

```
.claude-plugin/{marketplace.json,plugin.json}
agents/{spec-writer,dev-writer,tester,code-reviewer,spec-test-reviewer,design-reviewer,closer}.md
skills/{flow,worktree-discipline,openspec-archive,init,sync,run,pm}/SKILL.md
scripts/check-version.sh   # replaces templates/ — see "Verified during the v0.1.0 build"
openspec/            # contract specs (decision 18)
LESSONS.md  README.md  LICENSE-MIT  LICENSE-APACHE-v2
```

## Order of work

1. Build v0.1.0 here: `git init`, layout, the `skills:` preload test first, then skills, agents, templates, `LESSONS.md`.
2. Test via the local marketplace on a fresh empty repo.
3. Dialectica migration piece, run by dialectica's own runner: write the overlay, replace the generic `CLAUDE.md` sections with the block, delete `.claude/agents/` and `docs/OPENSPEC-ARCHIVE.md`, generalise `docs/PROJECT-MANAGEMENT.md`, pin v0.1.0. **Needs the owner's explicit go-ahead** (dialectica's "`.claude/` is the owner's").
4. Publish to GitHub after dialectica completes one full piece on the plugin. **Needs the owner's confirmation.**
