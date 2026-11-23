# Lessons

**For the maintainer only.** No agent reads this file. Agent-facing text carries
rules only; this file keeps the story behind each rule, so a rule can be
judged, tightened or retired by someone who knows what it cost.

Every story here comes from dialectica (`~/src/rad/dialectica`, extracted at
`6a7e02b9`), unless it says otherwise. Each entry links to the rule it produced.
When you change a rule, update its link here; when you retire a rule, move its
entry to "Retired" with the reason.

Domain lessons (cryptography, QML, the Logos SDK) are not here. They belong to
the project that learned them, in its overlay.

## The flow — `skills/flow/SKILL.md`

### Specs that cite issue numbers
**Rule:** [A spec never cites a GitHub issue number](skills/flow/SKILL.md#a-spec-never-cites-a-github-issue-number-as-though-it-were-a-section)

`openspec/specs/` is read on its own, and an issue can be edited, closed or
reworded at any time. One instance survived in dialectica's
`moderation-resolution` ("The deciding moderation is named"), inherited from its
delta and left alone by the sweep that found it: a sweep that also edits prose
is a sweep nobody can review.

### A spec that moved under the code
**Rule:** [One writer at a time](skills/flow/SKILL.md#one-writer-at-a-time-reviewers-in-parallel)

A scope was reworded while four reviewers read the code implementing it. Every
dispatch is cut from the runner's HEAD, so a second writer launched before the
first's commits are cherry-picked forks from a HEAD without them; the two
diverge with no git conflict, because they were never in the same tree. The
`tester` adds a third reason: it mutates code it does not own, so a concurrent
writer inherits the broken state or overwrites the restore.

### Reviewers reading each other's mutations
**Rule:** [Reviewers run in parallel, each in its own worktree](skills/flow/SKILL.md#one-writer-at-a-time-reviewers-in-parallel), and [code-reviewer: mutating only in your own worktree](agents/code-reviewer.md#mutating-is-allowed-and-only-in-your-own-worktree)

A reviewer running `cargo mutants` breaks dozens of lines. Two reviewers sharing
a tree read each other's breakage as the author's. It happened twice.

### Who removes a worktree
**Rule:** [Handing the tree back](skills/worktree-discipline/SKILL.md#handing-the-tree-back)

Ambiguity was destructive both ways: an agent that assumed it must make its own
tree mutated the piece's instead; one that assumed the tree was its to delete
could `--force`-remove state another finding cited, or leave a full repo copy
behind per dispatch. Since `git worktree remove` refuses the directory you stand
in, giving removal to the runner makes the invariant hold by construction. The
runner keeps a tree for re-checking a finding, comparing citations, or
recovering a mutation.

### The immutable PR head ref
**Rule:** [PR refs](skills/worktree-discipline/SKILL.md#pr-refs)

`PATCH /pulls/<n> -f head=…` returned 200 and ignored the field. The rename
endpoint auto-closed a PR whose head vanished; renaming onto an existing name
after deleting it recreated the ref at the old tip and dropped what the deleted
ref held. Six reviewers' findings were lost that way and recovered only from a
local reflog.

### Orphaned PRs
**Rule:** [Consolidating branches is not finished until the orphaned PRs are closed](skills/worktree-discipline/SKILL.md#pr-refs)

Folding a branch into the piece left its PR open, describing work that lived
elsewhere. The open-PR list stopped being a count of work in progress, which is
the only thing that makes a WIP limit checkable.

### Pushing `main`, the archive included
**Rule:** [Nobody pushes `main`](skills/worktree-discipline/SKILL.md#the-branches), and [Never archive after the merge](skills/openspec-archive/SKILL.md#archiving-an-openspec-change)

dialectica's `main` has `enforce_admins` on, and a direct push is rejected with
`GH006`. The archive commit reads as though it might be exempt, being
bookkeeping. Archiving after the merge would need exactly that push; archiving
before it keeps code and contract reverting together, and since archive moves
rather than deletes the change folder, the squash loses nothing.

### `git add -A`
**Rule:** [Commits](skills/flow/SKILL.md#commits)

Two reasons, not the same: sweeping up another agent's half-finished edit
corrupts the branch silently (the commit looks like yours), and a worktree
collects build output that is not yours to commit. The second is why the
project's list lives in the overlay's `## Never commit`.

### The stage block, and struck rows
**Rule:** [The stage block in `tasks.md`](skills/flow/SKILL.md#the-stage-block-in-tasksmd)

Before the block existed, one piece reached the edge of merge with zero
reviewers and another missing four, neither visible until someone asked. Rows
are one per agent instance so concurrent cherry-picks never touch the same line,
and a shared checkbox could not be ticked truthfully. A row is struck, not
deleted, because a deleted row and a skipped stage look identical; the struck
row keeps its empty box so `[x]` stays single-valued, at the price of
`openspec archive` warning about it.

### A piece with no change folder
**Rule:** [A piece with no behaviour change still gets a change folder and a stage block](skills/flow/SKILL.md#the-stage-block-in-tasksmd)

The first test-only piece reached review with no `openspec/changes/<name>/` at
all, so a reviewer had no row to tick, and said so. `skip_specs: true` on its own
was reported as "not valid change metadata, so the marker is not honored" — a
message that reads as a complaint about the marker rather than about the missing
`schema:` beside it.

### Findings written as headings
**Rule:** [The gate only sees checkboxes](skills/flow/SKILL.md#the-findings-files)

Forty findings, four of them high-severity defects, were written as headings.
`grep -rn "^- \[ \]"` reported the directory clean, and they read as done.

### A report that said ticked, with the box still open
**Rule:** [A box is ticked when the file says `- [x]`](skills/flow/SKILL.md#the-findings-files), the writers' pre-report check, and [the runner's check after a hand-back](skills/run/SKILL.md#dispatching); issue #11

In dialectica #179 a `dev-writer` pass fixed four findings and reported it had
"fixed and ticked" them. Under two of the boxes it had written "**Fixed** in the
commit that ticks this box", but after the runner cherry-picked the commit,
`git grep -n "^- \[ \]"` still showed those two as `- [ ]`: the outcome text was
written and the flip was not. A second pass was needed. Had the runner trusted
the report, the `closer` would have been dispatched on unticked boxes, or a
re-review asked to approve work whose record said otherwise. A writer that
appends the outcome and misses the flip passes every check it runs itself, so
the writer greps before reporting and the runner greps after.

### Findings relayed through a brief
**Rule:** [Never relay a finding through a brief](skills/flow/SKILL.md#the-findings-files), and [A brief points at the work](skills/flow/SKILL.md#handing-over-between-agents)

A paraphrase arrives without the evidence behind it: a wrong claim reached two
agents in one day that way. A report copied into the runner's context and
rewritten into the next brief also occupies it twice, crowding out the state the
runner exists to track.

### Writing dead ends down
**Rule:** [Write the dead end down](skills/flow/SKILL.md#handing-over-between-agents)

A reviewer that spends an afternoon proving an approach impossible has produced
a result worth as much as the review; unwritten, the next agent spends the same
afternoon.

### One reviewer, one dimension
**Rule:** [`code-reviewer` runs once per dimension](skills/flow/SKILL.md#the-roles)

Scanning for a reachable panic is a different reading of a file from scanning
for a function doing two jobs. One agent holding both becomes whichever it
started with.

### Clean reviews the closer could not see
**Rule:** [A review with no findings carries one box](skills/flow/SKILL.md#the-findings-files), issue #2

v0.1.0's reviewers said to report clean areas "in prose, not as boxes", and the
`closer` stopped on any findings file with zero boxes. A reviewer that found
nothing and followed its own instructions wrote a file the gate always rejected.
In dialectica it cost two extra reviewer dispatches (#173), each appending a
`## Gate record` section with one ticked box, and once the `closer` merged anyway
with four of six files box-less (#165), so the gate was not enforced. The gate
exists because forty findings once read as done when written as headings, so it
stays mechanical and the reviewers adapt: one ticked verdict box per clean file.

### The blind spec-test reviewer
**Rule:** [`spec-test-reviewer` never reads the implementation](skills/flow/SKILL.md#the-roles)

Someone who has read the code judges tests by what the code does — the exact
failure a spec exists to catch: a test that faithfully pins the wrong behaviour.

### Agents addressed by the wrong name
**Rule:** [Address the plugin's agents qualified](skills/flow/SKILL.md#the-roles)

In dialectica the rule was the opposite way round — "address this repo's agents
unqualified, `code-reviewer`, not `agent-skills:code-reviewer`" — because a
plugin shipped a similarly described reviewer carrying none of the repo's traps.
As a plugin, specflow's agents are the qualified ones, and a project agent of the
same name does not shadow them.

### No source diff, no review
**Rule:** [A change with no source diff still gets reviewed](skills/flow/SKILL.md#the-roles)

The flow's own adopting change in dialectica nearly shipped with the
`code-reviewer` step skipped entirely, on the grounds that it changed only
prose.

### The SIGPIPE gate
**Rule:** [`<producer> | grep -q` exits 141](skills/flow/SKILL.md#bash-costs)

`tar tzf … | grep -q` exits 141 under `pipefail`, because `grep -q` closes the
pipe at the first match. Under a bare `set -eu` it is invisible, so the gate
silently passes, and it turns into a spurious failure the moment anyone adds
`-o pipefail`. dialectica's release job carries the fix verbatim because a port
of it once reverted the fix.

### Fabricated numbers
**Rule:** [Run the command before you write the number](skills/flow/SKILL.md#rules-every-role-applies)

One sweep found six comments in a single file arguing from premises the code
disproved. The worst were quantities, because a quantity reads as measured:
*"wrong for two years"* in a repository five days old, written in the commit
titled "stop three comments from saying the wrong thing". A quoted delta can
introduce a second wrong claim while fixing the first, which is why a stale
number is re-measured rather than adjusted.

### Tests that could not fail
**Rule:** [A test asserts against something the implementation did not produce](skills/flow/SKILL.md#rules-every-role-applies), repeated in [tester](agents/tester.md#a-test-must-be-able-to-fail-for-the-reason-it-names) and [spec-test-reviewer](agents/spec-test-reviewer.md#2-can-each-test-actually-fail)

Three shipped: `"ab"` against `"abc"` passed with the length prefix deleted; a
mutated byte moving a hash passed with the field removed entirely, being a
property of SHA-256; `assert_eq!(bytes[0], VERSION_1)` passed when the constant
changed. dialectica's fix is a hardcoded known-answer test,
`identity.rs::the_wire_constants_are_pinned_to_known_answers`.

### Mutation testing's blind spot
**Rule:** [The mutation tool complements reading](skills/flow/SKILL.md#rules-every-role-applies)

`cargo mutants` found a real gap in 7 seconds (`Policy::to_byte` replaced by a
constant survived the suite) and could not see the defects above, because it
mutates functions, not `const` values.

### `NO SPEC:` markers
**Rule:** [Mark unspecified behaviour in the code](skills/flow/SKILL.md#rules-every-role-applies), and [dev-writer: when the spec is silent](agents/dev-writer.md#when-the-spec-is-silent-the-kind-of-decision-decides-where-it-goes)

Without a marker, a reasonable default the dev chose to keep moving becomes
permanent by accident, and nobody ever decides whether it was right.

### Structurally blind gates
**Rule:** [Say what a gate cannot see](skills/flow/SKILL.md#rules-every-role-applies)

`cargo fmt --check` did not follow path dependencies, so it never reached the
crate holding nearly all the logic; code behind a build-only `cfg` was not
compiled by `cargo test` at all. "Exit 0" on a gate that measured nothing is
worse than no gate. The specifics live in each project's `## CI gates`.

### Silent failure
**Rule:** [Design against silent failure](skills/flow/SKILL.md#rules-every-role-applies)

dialectica's host swallows UI errors: a view that fails to compile, a plugin
skipped for a missing manifest field and a binding evaluating to `undefined` all
present as "clicking does nothing". One type-name collision took out the whole
visual system with every gate green. That account belongs to dialectica's
overlay; the generic rule is that each project lists its silent-failure modes
under `## Hazards`.

## Worktrees and branches — `skills/worktree-discipline/SKILL.md`

### `EnterWorktree` from a dispatched agent
**Rule:** [A dispatched agent never calls `EnterWorktree`](skills/worktree-discipline/SKILL.md#how-you-got-your-tree-isolation-worktree)

Two probes in dialectica. A dispatched agent at the repository root was refused
outright (*"switching is only available to sessions whose working directory is
inside a worktree of this repository"*). One already isolated, crossing into
another worktree, appeared to succeed, and then every Bash call was refused for
resolving to "the shared checkout". The first refusal's message names the
precondition `isolation` establishes, which invites exactly the combination the
second probe measured failing. An agent improvising around a refusal reached for
`env -C` or `cd &&`, an approval click each.

### Isolation that did not take
**Rule:** [The arrival check](skills/worktree-discipline/SKILL.md#the-arrival-check)

An agent dispatched with `isolation: "worktree"` landed in the main checkout on
the piece branch. A mutating reviewer there would break the tree the runner's
HEAD points at, and an unrestored mutation would reach the owner's working tree.
The check lives in each agent's own instructions, not in the brief, because it is
a precondition on the agent's own tools and a brief the runner forgets to write
leaves the guard off exactly when it is needed.

### The missing `baseRef`
**Rule:** [`worktree.baseRef: "head"`](skills/worktree-discipline/SKILL.md#worktreebaseref-head), and [init § 2](skills/init/SKILL.md#2-gitignore)

While dialectica ignored `.claude/settings.json`, it reached no fresh checkout,
and nothing failed when it was absent: agents were silently cut from
`origin/main`. `.gitignore` now excludes `.claude/*` and re-admits the file by
name; `.claude/*` rather than `.claude/` because git never re-includes a file
whose parent directory is excluded.

### Wrong-tree success
**Rule:** [Tools that take their root from the cwd](skills/worktree-discipline/SKILL.md#tools-that-take-their-root-from-the-cwd)

`lgs basecamp build` from the wrong root reported a green build of code nobody
had written. A tool that refused would have been harmless.

### The bare push that landed on `main`
**Rule:** [The piece push](skills/worktree-discipline/SKILL.md#the-piece-push-dev-writer-and-closer-only), and the block's [worktrees](skills/sync/SKILL.md#the-block)

A bare `git push` landed commits directly on `main` more than once. The cause
was branch creation: `git worktree add <path> -b piece/<name> origin/main`
branches from a remote-tracking ref, so `branch.autoSetupMerge` wrote
`merge = refs/heads/main`. Measured: `git push origin piece/<name>` from such a
branch was rejected by branch protection *for `refs/heads/main`*. `git branch
-vv` printed `[origin/main]` in both the right and the wrong case, so it could
not serve as the check.

### A push gate that matched every piece
**Rule:** [Keep the pattern exact](skills/worktree-discipline/SKILL.md#the-piece-push-dev-writer-and-closer-only), issue #3

v0.1.0 told the `dev-writer` and `closer` to run `git config --get-regexp
"^branch\.piece"` and expect no output. Branch config lives in the repository's
shared `.git/config`, so the pattern matched every local piece branch that had an
upstream. In dialectica the `dev-writer` ran it as written, got lines for older
pieces and none for its own, and stopped without pushing or opening the PR; the
runner had to resume it. The narrow form the runner already used,
`^branch\.piece/<name>`, still prefix-matches `piece/<name>-v2`, so the fix ends
the pattern with `\.`: git prints each key as `branch.<name>.merge`.

### Unsigned commits reaching the merge
**Rule:** [Preflight 6](skills/run/SKILL.md#before-anything-preflight), [the `closer`'s "Signed commits"](agents/closer.md#signed-commits), and [a commit that will not sign does not stop you](skills/worktree-discipline/SKILL.md#committing-and-reporting); issues #4 and #8

Two dialectica pieces (#200 and #201) reached the merge on a branch whose
`main` requires signed commits, with every required check green and the PR
`BLOCKED`. GPG's passphrase prompt cannot be answered by an agent, so the owner
had authorised `git commit --no-gpg-sign` as a fallback. In #200, 19 of 23
commits were unsigned; the runner's cherry-picks create new commits, and the
fallback let unsigned ones through. In #201 the `closer` wrote two unsigned
commits itself (the archive commit and a merge of `main`) after its gpg-agent
cache had expired, because it runs longest and last. Both pieces needed a second
dispatch or an owner round-trip to re-sign and force-push, and a full extra CI
cycle. Nothing checked signing before the push, and v0.1.0 gave no way out
short of overriding its own "never force-push". The fix checks before every push
and documents the one recovery: `git rebase --force-rebase --gpg-sign`, because
a plain rebase of a branch already on `main` writes no commit and signs nothing
(measured), then a lease-pinned push to the piece ref, with the owner's say-so
each time.

The first version of the fix stopped the run at preflight, to have the owner
unlock the key, and stopped any agent whose commit would not sign. The owner
rejected that: a stop early in a piece costs the most, because every agent waits
on it, while a stop at the end costs one round-trip. Now agents carry on
unsigned (never by turning `commit.gpgsign` off), and the one wait is the
runner's request to unlock the key just before the `closer`, which signs the
whole branch in one pass.

### Checking out the piece branch
**Rule:** [The piece push](skills/worktree-discipline/SKILL.md#the-piece-push-dev-writer-and-closer-only)

`fatal: 'piece/<name>' is already used by worktree at …` arrived mid-archive, at
a step that read as routine. The refspec push never touches the local branch.

## Archiving — `skills/openspec-archive/SKILL.md`

### "openspec is not installed"
**Rule:** [Run `openspec --version`](skills/openspec-archive/SKILL.md#archiving-an-openspec-change)

dialectica's archive page once recorded the CLI as absent (exit 127). The
absence was real; the sentence outlived it, and "openspec is not installed"
reached five agents in one day.

### A reference example that was hand-edited
**Rule:** [A live spec can differ from its delta](skills/openspec-archive/SKILL.md#traps-none-of-the-files-show)

dialectica's `stoa-genesis` live spec differed from its delta by whole added
paragraphs and `SHALL` → `MUST` rewrites, landed in the same commit (`3dddf03`),
so no diff ever showed the hand edit. `2026-09-11-op-model` → `op-format` matched
exactly and is the example to derive the rule from.

### `validate --strict` passing contradictions
**Rule:** [`validate --strict` checks heading structure, not consistency](skills/openspec-archive/SKILL.md#traps-none-of-the-files-show)

Twice: a requirement whose prose admitted only a three-input derivation while a
restored scenario asserted two; and two readings of a null field both reaching
one field and disagreeing.

### Contradictions across capabilities
**Rule:** [Reading two capabilities together](skills/openspec-archive/SKILL.md#reading-two-capabilities-together)

`keystore` and `posting-capability` shipped in one change, each internally
consistent, jointly demanding that a wrong passphrase be told apart from a
tampered ciphertext — which an AEAD tag structurally cannot do. Each delta was
reviewed alone. Separately, `identity` and `op-format` both carried an
authenticity-is-not-authority requirement; `op-ordering` faced the same overlap,
declined to restate the rule and said so in its Purpose, which is the shape the
rule asks for.

## Agents — `agents/`

### Fixed models
The models and effort in each agent's frontmatter are dialectica's, unchanged.
Projects cannot override them (decision 12).

### The `dev-writer` guard evidence
**Rule:** [record what breaks without it](agents/dev-writer.md#when-the-spec-is-silent-the-kind-of-decision-decides-where-it-goes), and [design-reviewer: the mutation evidence](agents/design-reviewer.md#what-a-good-decisions-entry-contains)

Mutation evidence for a guard usually exists only in a commit message, and it is
what stops a future reader deleting a guard whose purpose is no longer obvious.
The dev is the only person who cheaply knows it.

### The PR opened early
**Rule:** [Open the PR early, because CI runs on the PR](agents/dev-writer.md#the-pr-is-yours-and-this-is-the-one-thing-you-push)

dialectica's workflows trigger on `pull_request` and pushes to `main`, never on a
piece-branch push. Without an early PR, the first news of the build arrived
after six reviewers had read the code.

### The dev's tests are the likeliest to pin what was built
**Rule:** [Hold them to the invariant more firmly than your own](agents/tester.md#you-inherit-the-devs-tests)

They were written by whoever wrote the code. A regression test watched failing
before its fix is the only proof the bug was real, which is why it may not be
removed.

### The `tester`'s missed restore
**Rule:** [Prove the implementation is untouched before you commit](agents/tester.md#scope)

One missed restore ships a deliberately broken line, and it will not fail the
tester's own suite: the tester mutated the code precisely so a test would catch
it, then restored the test's expectation to match.

### The recorded concession with the wrong mechanism
**Rule:** [Prefer reading the code over trusting the prose](agents/design-reviewer.md#what-a-good-decisions-entry-contains)

A `design.md` concession named a different, smaller mechanism than the code
actually had, so it described a smaller hole than existed. A separate
atomicity claim had no test behind it.

### Stale branches with no warning
**Rule:** [Step 2 — the stale-branch check](agents/closer.md#step-2--the-stale-branch-check)

Three PRs each carried ~690–705 deletions of files they never touched — seven
agent files, the archive doc, and three `## Purpose` sections without which
`openspec archive` aborts. `mergeStateStatus` reported `UNKNOWN` for all three,
not `BEHIND` or `DIRTY`, and a squash merge would have applied the deletions with
no conflict. After a correct merge, `git diff origin/main HEAD --stat` showed
6,871 deletions — a false alarm, because `origin/main` had moved on.

### The cancelled run
**Rule:** [Check `headSha`](agents/closer.md#step-4--watching-ci)

A closer watched the newest `in_progress` run to a failure — *"The operation was
canceled"* mid-build, no compile error — which was a run its own push had
cancelled moments earlier (`cancel-in-progress`). `gh pr checks` separately
reported "no checks reported on the '<branch>' branch" while CI was running and
passing.

### Merging without a human
**Rule:** [Step 6 — merging, and on whose authority](agents/closer.md#step-6--merging-and-on-whose-authority)

dialectica's protection required four green checks and a signed commit, but
`required_approving_review_count` was 0: nothing between the `closer` and `main`
asked a human. `gh pr merge --delete-branch` exited 1 after a successful merge
because the runner's worktree held the branch.

### The closer that waited
**Rule:** [Then return](agents/closer.md#your-report)

A closer that reports and keeps waiting holds a row in `ListAgents`, which is the
runner's evidence that the piece is being worked; the piece stalls looking busy.
The closer exists at all because watching a build consumes the runner's context,
the scarcest thing in the flow, while producing nothing.

## The runner — `skills/run/SKILL.md`

### Agents stalling on a prompt nobody could see
**Rule:** [Never poll a background command's output](skills/flow/SKILL.md#bash-costs), [the shell-rules paragraph in every brief](skills/run/SKILL.md#dispatching), and [a silent agent may be waiting on a prompt](skills/run/SKILL.md#is-an-agent-still-working); issue #14

In dialectica #199 a `code-reviewer` started a mutation run in the background,
then called `Monitor` with an `until grep -q … /tmp/…/tasks/<id>.output` loop.
The project blocks reads outside the working directories, so the loop raised a
prompt the agent sat on. Its five sibling reviewers took two to seventeen
minutes; it took about forty-two, and only after the owner saw the prompt and
declined it. The runner's message to stop was read only afterwards, because
queued messages arrive at an agent's next tool round. A `dev-writer` also showed
`running` with no commit and no reply to two status messages for forty-three
minutes, then for about nine hours across a night; whether that was a prompt or a
long run, the runner could not tell. v0.1.0's Bash rules covered `cd &&`, pipes,
`gh --jq` and `grep -q` exit 141, but not `Monitor`, `until` loops or the
harness's task output file, which are the natural thing to reach for while a long
command runs; and the brief template carried no shell rules, so each runner had
to remember to add them. One runner added them to the writers' briefs and
forgot the six reviewers'.

### A reviewer reporting `ListAgents` missing
**Rule:** [preflight 5](skills/run/SKILL.md#before-anything-preflight)

`ListAgents` and `ScheduleWakeup` exist only in an interactive main-loop session.
A reviewer sent to check the runner file could not see them and reported them as
missing — a fact about who dispatched it, not an error.

### A runner re-invoked after the merge
**Rule:** [Check whether the piece is finished](skills/run/SKILL.md#start-the-piece), issue #7

In dialectica #177 the runner schedules wakeups that re-enter `/specflow:run`,
and the owner can invoke it again. After the piece merged and its issue closed,
the skill was re-invoked twice more. Each time the whole text reloaded, starting
with "Start the piece", and the one thing between the runner and a second
worktree plus a `spec-writer` for a closed issue was a `gh pr list --state open`
that printed nothing about the piece and read like "no PR yet". A runner reading
top to bottom could reasonably have started over; the guard that stopped it was a
check the skill never mentioned.

### Changes with no stage block
**Rule:** [A change with no stage block is untracked, not done](skills/run/SKILL.md#rebuild-the-state-before-you-act-on-it)

The unticked-row grep returns nothing on a change with no block, which reads
exactly like every row ticked. Changes predating the rule answered `0`.

### An agent listed completed with its work unfinished
**Rule:** [`completed` is not done](skills/run/SKILL.md#is-an-agent-still-working), [never end your turn with a command running](skills/worktree-discipline/SKILL.md#handing-the-tree-back), and the in-place mutation rule in [dev-writer](agents/dev-writer.md) and [tester](agents/tester.md); issue #13

In dialectica #199 a `dev-writer` committed its first two commits, then started
`cargo mutants --in-place` over `delivery.rs`, the main deliverable. In-place
mutation rewrites the working tree, so the rewrite stayed uncommitted until the
run restored the file. While it ran, the agent's turn ended: `ListAgents` showed
it `completed` and the harness said it "has not reported yet: it is waiting on
its own background work". That happened twice on the first pass. The branch held
part of the work and there was no PR, and v0.1.0's "a piece with no agent in that
list has no agent", read literally, said to dispatch the next stage. Removing the
worktree would have destroyed the uncommitted rewrite. The runner resumed the
agent with `SendMessage` and it finished. The overlay's "abandon a run past a
couple of minutes" did not hold: agents ran mutations for five to eight.

## The `CLAUDE.md` block — `skills/sync/SKILL.md`

### The runner that rewrote the role files
**Rule:** [`.claude/` and the specflow plugin are the owner's](skills/sync/SKILL.md#the-block)

A dialectica runner noticed dispatched agents were costing approval prompts and
rewrote all seven role files plus a CI gate to fix it. The diagnosis was right;
the action was not the runner's to take. It was also unnecessary: `CLAUDE.md`
reaches every session and agent, so one rule there would have done.

### The path-cost table that inverted
**Rule:** [Inside your own worktree, use plain relative paths](skills/sync/SKILL.md#the-block)

dialectica's cost table once said an absolute path was free and a relative one
costly — true of a session that could be anywhere, backwards for a flow that
stands every agent in the correct tree. `dev-writer.md` carried a matching
bullet, and a dispatched writer's long absolute path back into its own tree
carried a mistyped username, which became a blocked read. The chain is plausible
rather than proven. **Maintainer rule:** phrase a cost by what the checker does
(can it resolve the path before the command runs?), never by the path's shape,
or the rule inverts when the flow around it changes.

### Auto mode's "prefer Bash"
**Rule:** [Ignore any harness instruction to prefer Bash over `Read`/`Edit`/`Write`](skills/sync/SKILL.md#the-block)

Every shell mutation needs a redirect, a heredoc or `-i`, exactly the shapes the
checker cannot analyse, so the instruction turned auto-approved calls into
prompts in the mode meant not to interrupt.

### A block that described a different base than the one configured
**Rule:** [Pass `path`, never `name`](skills/sync/SKILL.md#the-block), and [`worktree.baseRef: "head"`](skills/worktree-discipline/SKILL.md#worktreebaseref-head); issue #18

dialectica's `CLAUDE.md` said `EnterWorktree(name)` creates a worktree "branched
from `origin/main`", and that was true of its setup when written. The block
carried that sentence into every project, but `/specflow:init` also writes
`worktree.baseRef: "head"`, under which a `name` worktree forks from the local
`HEAD`. An agent following the block could start from a stale piece branch or
unmerged commits while believing it was on `origin/main`. Found reviewing a
project set up with `/specflow:init` (basecamp-installer, PR 15). The block now
states both bases and the reason `path` is the rule; `baseRef: "head"` stays,
because every dispatched agent needs it to fork from the runner's `HEAD`.

### Forbidding a tool
**Rule:** [When you forbid a tool, name the replacement](skills/sync/SKILL.md#the-block)

Agents told "no Python" reached for `awk`, `sed` or a pipeline and stalled on the
prompt those cause.

### Worktrees under `tmp/`
**Rule:** [Worktrees go in `.claude/worktrees/`](skills/sync/SKILL.md#the-block)

Reading the scratch-file rule as covering worktrees put ~27 checkouts under
`tmp/` beside 34 in `.claude/worktrees/`; an agent looking for a sibling's branch
had to guess which scheme it used. Every stale checkout is a full copy of the
repo, so a recursive grep hits each, and a citation from one reads like one from
the real tree.

### An allowlist that auto-approved GitHub writes
**Rule:** [The `gh` rules are read-only on purpose](skills/init/SKILL.md#1-claudesettingsjson), and [`gh` writes prompt by design](skills/sync/SKILL.md#the-block); issue #17

v0.1.0's `init` allowed `Bash(gh api *)` and `Bash(gh pr *)`. Neither is
read-only: `gh api` accepts `-X PUT/PATCH/DELETE` (branch protection, repository
settings) and `gh pr` covers merge and close. The overlay and the init skill both
say specflow never changes a GitHub setting, but the allowlist would approve one
with no prompt. Found reviewing a project set up with `/specflow:init`
(basecamp-installer, PR 15), where a session applied branch protection with
`gh api -X PUT` unprompted, under that rule, after the owner had asked for it.
Allow rules cannot exclude flags, so the fix pairs `Bash(gh api *)` with deny
rules on every flag that sets a method or a body. Tested 2026-11-21: a plain GET
runs; `-X`, `-XGET`, `--method`, `--field`, `-f`, `-F` and `--input` are denied;
`gh pr merge` and `gh pr close` are not allow-listed, so they prompt. **The first
version of the deny rules leaked**: `-f ` and `-F ` ended in a space, so the
attached form `-fper_page=1` (which pflag accepts, and which makes the call a
POST) ran. An independent review caught it, and a rerun against the original
rules confirmed it. The rules now match ` -f*` after a space and `-f*` right
after `api`, so the attached form and the flag-first position are denied, while a
branch name that merely contains `-f` (`fix-findings-tick`) still reads.

### Project skills, commands and hooks that no worktree had
**Rule:** [Track skills, commands and hooks](skills/init/SKILL.md#2-gitignore), and the [`project-overlay` spec](openspec/specs/project-overlay/spec.md); issue #19

v0.1.0's `.gitignore` template ignored `.claude/*` and re-included only
`settings.json`, `specflow/` and `agents/`, while the CLAUDE.md block describes
project skills and hooks under `.claude/` as owner-managed content. An
owner-approved project skill was therefore untracked, silently missing from every
dispatched worktree (cut from `HEAD`) and from fresh clones, with no error: the
same failure shape as the missing `baseRef`. Found in the same review.

## The project manager — `skills/pm/SKILL.md`

### PLAN.md
**Rule:** [Never maintain a roadmap document outside the issue tracker](skills/pm/SKILL.md#ground-truth-for-scope)

dialectica's `docs/PLAN.md` was a 4,000-line design document: a good record of
*why*, useless as a tracker, conflating what the project is with what ships
next. Its durable reasoning moved to `design.md` files, `CLAUDE.md` and specs;
its roadmap to Issues and Milestones.

### Prose mentions do not close issues
**Rule:** [dev-writer: close the issue through the PR](agents/dev-writer.md#when-the-spec-is-silent-the-kind-of-decision-decides-where-it-goes), and [pm sweep](skills/pm/SKILL.md#what-this-role-does)

dialectica's PRs had not consistently used closing keywords, so merged work left
issues open. The PM flagged it without editing `.claude/`; the owner added the
closing-keyword instruction to the `dev-writer`. The sweep stays, for PRs that
skip it.

## Seen during extraction — candidates for v0.2+

Kept here until they become issues on this repository.

1. **dialectica's README contradicted its own dispatch shape.** One paragraph
   said the runner creates each reviewer's worktree and names it in the
   dispatch, and that a reviewer not given a path stops; the agent files and
   `RUNNER.md` dispatch with `isolation: "worktree"` and no path. v0.1.0 keeps the
   isolation shape and drops the stale paragraph.
2. **`RUNNER.md` pointed at a README section that does not exist** ("Why the
   prohibition is written down anyway"). Nothing to carry.
3. **dialectica's `CLAUDE.md` table said archiving "runs after its PR merges"**,
   contradicting every other document. The migration replaces that table.
4. **`spec-test-reviewer` referred to a part 6 that did not exist.** v0.1.0 says
   "parts 1, 3, 4 and 5 … and the output".
5. **`isolation: worktree` in each agent's frontmatter** would make isolation
   automatic rather than depending on every dispatch carrying it. Plugin agents
   honour it. Not done in v0.1.0 to keep dispatch behaviour identical.
6. **Plugin skills cannot read their own files** under
   `permissions.blockReadsOutsideWorkingDirectories` (measured 2026-09-30, Claude
   Code 2.1.284, via `--plugin-dir`): `Read` on `${CLAUDE_PLUGIN_ROOT}/…` and
   `${CLAUDE_SKILL_DIR}/…` is refused, and a `` !`cat …` `` injection fails the
   whole skill. So the overlay skeleton and settings live inline in
   `skills/init/SKILL.md` and the block inline in `skills/sync/SKILL.md`, not in
   `templates/`; and the version appears in the block stamp and in
   `skills/run/SKILL.md` as well as the manifests. `scripts/check-version.sh`
   checks they agree. Re-tested 2026-10-01: a marketplace install's cache **is**
   readable, so `templates/` could return for installed users, but
   `--plugin-dir` development would then break. Kept inline.
7. **`.gitignore` re-admits `.claude/specflow/`**, beyond decision 15's
   `settings.json`. The overlay must be tracked or no agent worktree has it.
   `.claude/agents/` is re-admitted too, for project roles, and since #19 so are
   `skills/`, `commands/` and `hooks/`.
8. **`Bash(gh repo view *)`** is in the base allowlist, beyond decision 15's
   original list, because every role derives the slug and default branch from it.
   Since #17 the `gh` rules are read-only forms (decision 15).
9. **Not every harness build exposes `Grep` and `Glob` tools** (this extraction
   session had neither). The block's cost table names them as free.
10. **The reviewer ceiling is six**, but `## Extra stages` can add reviewers.
    Decide whether the ceiling counts them.
11. **`skills:` preload accepts both `flow` and `specflow:flow`** for a plugin
    agent (measured 2026-09-30). The qualified form is used, so a project skill
    named `flow` cannot be picked up instead — unverified which wins on a clash.
12. **The `closer` now stops on a cross-capability contradiction** found while
    archiving and routes it, through the runner, to the `spec-writer`.
    dialectica's archive page said such a sweep "should resolve it", which reads
    as the archiver editing specs; that contradicts "the `closer` decides
    nothing", so v0.1.0 takes the closer's side.
13. **`Bash(grep *)` and `Bash(pwd)`** join the base allowlist: the arrival check,
    the findings gate and the stage-block greps are the workflow's own commands.
14. **The runner reads findings filenames with `git ls-files`**, not `ls`, which
    the block prices at a click.
15. **The runner has no step to retire the piece worktree after merge.** It
    stands in that tree (`EnterWorktree`), and `git worktree remove` refuses the
    directory you are in. Inherited from dialectica; needs an `ExitWorktree`
    step, or a hand-off to the owner, in v0.2.
