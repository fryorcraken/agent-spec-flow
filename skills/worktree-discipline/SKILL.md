---
name: worktree-discipline
description: How a specflow agent gets its own git worktree, checks it arrived, commits, reports its branch and hands the tree back; which branches exist and who may push them. Preloaded into every specflow role agent; the runner loads it before its first dispatch.
user-invocable: false
---

# Worktree and branch discipline

## The branches

| Branch | Worktree | Whose | Holds |
|---|---|---|---|
| `piece/<name>` | the runner's | the runner, and the PR | **the** task branch, and the only one ever pushed. Work reaches it two ways: the runner cherry-picks every agent's commits onto its local copy, and the `dev-writer` and `closer` push a refspec to the remote copy |
| `worktree-agent-<id>` | one per dispatch | one agent | **local only, named by the harness** — whatever that agent committed, cherry-picked onto the piece and never pushed |
| `main` | — | nobody | **no agent ever pushes here.** It takes commits through a PR only |

- **Every dispatched agent gets its own worktree and its own branch**, cut from
  the runner's HEAD. No agent stands in the piece's tree.
- **The branch name is the harness's.** Read it with
  `git rev-parse --abbrev-ref HEAD` and report it. Never predict it.
- **Cherry-pick, never merge**, onto the piece branch.
- **Nobody pushes `main`.** The archive commit is not an exception.
- **No `worktree-agent-<id>` ever reaches the remote.**

## How you got your tree: `isolation: "worktree"`

A dispatched agent arrives in its own worktree because the runner dispatched it
with `isolation: "worktree"`. Use plain relative paths; every Bash command runs
as written.

**A dispatched agent never calls `EnterWorktree`** — not as a first step, not
as a fallback.

| | Works? |
|---|---|
| a dispatched agent entering a **pre-existing** worktree (`EnterWorktree`) | **no** — refused at the repository root; from an isolated tree it appears to succeed and every Bash call is then refused |
| a dispatched agent placed in **its own** fresh worktree (`isolation`) | **yes** |
| a **session moving itself** into a worktree (`EnterWorktree`) | **yes** |

Do not improvise around a refusal with `env -C`, `cd &&` or `git -C`.

### The arrival check

Before your first write, mutation or commit, run each as its own call:

```
pwd
git rev-parse --abbrev-ref HEAD
```

**If the branch is `piece/<name>`, or the path is the repository root rather
than something under `.claude/worktrees/`, the isolation did not take. Stop and
report it.** Do not create or enter a tree yourself. Your agent file says what,
if anything, you may still do read-only.

### `worktree.baseRef: "head"`

Agents fork from the runner's HEAD only because the project's tracked
`.claude/settings.json` carries:

```json
{ "worktree": { "baseRef": "head" } }
```

Without it, agents are cut from `origin/main` and hold none of the piece's
commits, with no error. **If your tree is missing commits or files the piece
should hold, say so and name this setting.** Do not edit the file; it is the
owner's.

### Tools that take their root from the cwd

`openspec` resolves its root from the cwd and has no `-C`, `--directory` or
`--root`. The overlay's `## Build` and `## Hazards` name any project tool that
does the same. Run them plainly from your own tree.

**A wrong-tree success looks identical to a right-tree one.** Before trusting a
green build or a validation against a tree you have not verified, run the two
arrival-check commands.

## Committing and reporting

- **Before any git write, check the branch you are on has no upstream**:
  `git config --get-regexp "^branch\.<your-branch>"` prints nothing. If it
  prints a `merge` line, stop and say so.
- **Commit to your own branch**, the `worktree-agent-<id>` you are on.
- **Commit named paths. Never `git add -A`.**
- **Report the branch name** so the runner can cherry-pick it.
- **Push nothing**, unless you are the `dev-writer` or the `closer`, and then
  only as below.

### The piece push (`dev-writer` and `closer` only)

You cannot check out `piece/<name>`: it is checked out in the runner's worktree,
and git refuses (`fatal: 'piece/<name>' is already used by worktree at …`). Push
your tip to the remote piece ref by refspec instead:

```
git config --get-regexp "^branch\.piece"
git rev-parse --abbrev-ref HEAD
git push origin HEAD:refs/heads/piece/<name>
```

- **The `git config` check expects no output.** The piece branch is created with
  `git worktree add --no-track`, so it has no upstream. `merge refs/heads/main`
  coming back means it is configured to push to `main`: stop and say so.
- **`git branch -vv` is not the check.** It prints `[origin/main]` either way.
- **`HEAD` on the left**, never `piece/<name>`: the local piece ref is the
  runner's and does not carry your commits.

### PR refs

- **A PR's head ref is immutable.** `PATCH /pulls/<n> -f head=…` returns 200 and
  ignores the field; `--base` changes the target, not the source.
- **Never rename or re-point a branch with an open PR.** The rename endpoint
  auto-closes a PR whose head vanished, and renaming onto an existing name after
  deleting it drops whatever the deleted ref held. Open a new PR on the correct
  branch and close the old one, saying where the work went.
- **Consolidating branches is not finished until the orphaned PRs are closed.**
  Before closing one, prove it is contained:
  `git log --oneline origin/<orphan> --not origin/piece/<name>`. Empty means
  contained. Non-empty means fold it first; a cherry-picked commit shows here
  even when its content is in, so read the commits, not the count. Say in the
  closing comment where the work went, and keep the branch.

## Handing the tree back

- **You cannot remove your own worktree** — `git worktree remove` refuses the
  directory you are in. That refusal is not a permissions problem.
- **Removal is the runner's.** Your last act is to report your branch name and
  that your tree is ready to prune once your commits are picked.
- **Do not step out first.** There is no `ExitWorktree` step.
- **The stash stack is shared with every worktree.** Never bare `git stash` /
  `git stash pop`; set work aside with a throwaway WIP commit on your branch.
