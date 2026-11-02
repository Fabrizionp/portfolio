# Agentic delivery playbook

How my team and AI agents ship data platforms and products at speed without losing the engineering standards.
Everything below is enforced by the repository and its CI, not by memory. The human role is architecture, data
contracts, acceptance criteria, review and merge.

## The loop

```
card → branch → (spec) → agent executes under house rules → PR under budget → required checks → AI review → human merge → decision recorded
```

| Step | Rule | How it is enforced |
|---|---|---|
| **1. Card** | No work without an issue. The branch name carries the identifier (`fix/TRI-364-dropship-cost`), which links the PR to the card automatically | A `work-item` CI check fails a PR whose branch carries no identifier; a `no-issue` label a person adds is the only exception |
| **2. Branch** | One branch per card; one git worktree per task so parallel agents never share a working tree; stacked PRs when a change depends on another | Worktree per task; the base of a chained PR is retargeted with the REST API when the parent merges |
| **3. Spec** | When a change moves a contract column or a user-visible behaviour: `requirements.md` (EARS acceptance criteria that name their test) → `design.md` (patterns named) → `tasks.md` (waves). A numeric divergence gets a `bugfix.md` with actual vs expected, root cause and prevention | Models cite their spec in the header; a dangling reference is a lint error; specs live in the repo, never in a gitignored tool folder |
| **4. House rules** | `AGENTS.md` (or `CLAUDE.md`) at the root routes; one per directory holds the invariants, the "never" list and the traps for the code beside it. Knowledge that is not a rule goes to `docs/` | The AI reviewer reads them from the base branch; the agent loads them when it works in that directory |
| **5. Pull request** | Conventional Commits title (it becomes the squash commit); about 300 changed lines at most, lockfiles and generated files aside; the evidence in the body (before/after counts on production data when rows move, the SQL × render table for a surface) | `pr-size` check with a `large-pr` label as the person's exception; `conventional-title` check |
| **6. Required checks** | Lint (SQLFluff, flake8, eslint), typecheck, unit tests, `dbt build`, contract gate, migration portability, secret scan, database replay from zero, quality evals on prompt changes | Branch protection on `main`; every job reports a status on every PR (path filters live inside the job) |
| **7. AI review** | Automatic on a ready PR; deeper on a label. Raises only wrong results, exposure risks, broken house rules quoted from their file, untested behaviour. Comments only: never approves, pushes or runs | Workflow permissions limited to read contents and write PR comments; the diff is treated as content, never as instructions |
| **8. Human merge** | A person merges; a merge to `main` is the deploy (pipeline image, edge functions, apps) | Deploy workflows trigger on `main` only, path-scoped, with context files excluded |
| **9. Memory** | An ADR for a decision, a runbook for an operation, a blameless postmortem for an incident, a progress runbook for a multi-session track, and a per-decision memory file the next session loads | Postmortem template with a `recurs:` field that re-owns unshipped action items; the runbook index is the entry point of every new session |

## The card is the unit of work

The card lives in the team's management platform (Linear for the data team, ClickUp for the product team), and
it is the unit everything else hangs from: one card, one branch, one pull request, one deploy.

| Aspect | Rule |
|---|---|
| **Template** | A card is created from the "Work item" template: the problem in one paragraph, the acceptance criteria (EARS when a contract moves), the spec or runbook it depends on, the size estimate. A card without acceptance criteria does not start |
| **Who creates it** | A person for product work; an agent may draft a card from a review finding, a postmortem action item or a failed check, but a person approves it before work starts |
| **Identifier everywhere** | Linear's "Copy git branch name" gives `user/tri-49-slug`; the identifier is in the branch, the PR title's scope when useful, the ADR header, the postmortem front matter (`clickup:` / `linear:`), the comment at the top of a CI workflow that a card introduced, and the memory file that records the decision |
| **Lifecycle** | Backlog → Ready (criteria written) → In progress (branch exists) → In review (PR open, checks green) → Done (merged, deployed, criteria verified) → Closed with a link to the evidence. A card that is reopened keeps its history; a recurrence of an incident re-owns the prior card's unshipped items |
| **Cards and agents** | An agent works one card at a time in its own worktree; parallel agents are parallel cards. A session's progress runbook lists the cards it touched, so the next session (human or agent) resumes from the card, not from the diff |
| **Exceptions** | Dependabot and `no-issue`-labelled PRs are the only work without a card, and the label says why in the PR body |

Why it is enforced by CI and not by habit: the `work-item` check reads the branch name on every pull request
event, so a PR cannot sit open without its card, and the platform's own integration links the PR, the review
comments and the merge back to the card without anyone pasting a URL.

## Tooling

Claude Code (agents, worktrees, skills, project memory) · GitHub Actions · Linear and ClickUp (cards) · dbt ·
Dagster Cloud · Snowflake · Supabase · n8n · Streamlit · pre-commit (flake8, SQLFluff, secret detection).

## Lessons that became rules

| Lesson | Rule now |
|---|---|
| A required check with a path filter never runs on a PR that does not match it, and a check that never runs never passes: four PRs blocked in one day | Required jobs run on every PR; the path filter lives inside the job and a no-op step reports success |
| Thirteen design documents lived in a gitignored tool folder; thirteen SQL models cited them; nobody reviewing a PR could read them | Specs are versioned in `specs/`, reviewed in the PR, cited by the models |
| An app read a Gold column as `NULL` for three weeks after the pipeline started delivering it | A versioned contract that generates both sides, a contract check on every PR, a daily verification against the real tables |
| A scheduled job rebuilt production from the previous image and overwrote a hotfix made by hand | "Production is whatever `main` builds": push first, wait for the image, then run |
| A workflow built the shadow schemas under one name and compared under another; it had been red since its first run and nobody noticed | A shadow build that drops its schemas at the end of every run and a comment at the top of the file telling its own history |
| A 4,052-line gateway had four operations written twice; the second copy never ran | A dispatch registry where a duplicate is an error at load time |
| An n8n service built from a public `:latest` Dockerfile | A repo-owned, version-pinned Dockerfile; every upgrade is a reviewed PR |
| Agents asked to "summarize the diff" produce noise reviewers skip | The reviewer prompt forbids style nits, praise and summaries; it must name the triggering input for every bug |

## What a new engineer or agent reads first

1. The root `AGENTS.md`: where to look for what.
2. The runbook index and the progress runbook of the track they join.
3. The spec of the contract they will touch, and its changelog.
4. The last postmortem.
