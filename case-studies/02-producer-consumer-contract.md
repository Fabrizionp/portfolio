# CS-02 · The contract between the pipeline and the app

**Role:** Architect and author of the spec system, the contract, the gates and the purchasing-engine rewrite.
**System:** the inventory engine of CS-01 (producer) and StockSync Pro of CS-03 (consumer).
**Period:** July to September 2026.

## Summary

The purchasing recipe lived in seven places: five near-identical SQL models (one per channel), an older copy, and
fragments re-implemented inside the app. The agreement between the pipeline and the app existed nowhere. I made
the recipe exist once, wrote the contract down as a versioned artifact that generates code on both sides, and put
an automated check on every change. The first run of the check found six real problems; by the end there were
zero.

| Before | After |
|---|---|
| 5 channel models, 1,783 lines of duplicated SQL | 1 engine (a macro with a per-channel configuration object) + 145 lines of channel files |
| A 4,052-line gateway with 71 `if` cases and 4 operations written twice (the second copy never ran) | A 118-line flow (authenticate, dispatch, respond) plus a handler registry where a duplicate is an error at load |
| A new Gold column ignored by the app for 3 weeks, shown as blank | A contract check on every PR, and a daily verification against the real tables |
| One business rule ("30 to 365 days of history") declared on both sides with a comment saying "change it there too" | The app derives its limits from the contract; `contract_sync.py drift` fails if it redeclares them |
| 29,600 units in the app vs 32,128 in the pipeline for the same SKU | One number, with its provenance, on every surface |

## How the contract works

```
specs/
├── contracts/inventory-needs-v2/
│   ├── contract.yml        # single source: 5 Gold tables, ~58 columns, types, semantics, consumer status
│   ├── requirements.md     # the problem, user stories, EARS acceptance criteria
│   ├── CHANGELOG.md        # SemVer on the contract, not the code
│   └── generated/          # dbt contracts + TypeScript types, regenerated, never hand-edited
├── features/<slug>/        # requirements.md · design.md · tasks.md
└── _bugfix/<slug>/         # actual vs expected, root cause, prevention
```

- **`contract.yml` is not documentation.** It generates the dbt `contract: enforced` blocks and the app's
  TypeScript types. Letting it drift breaks the build.
- **SemVer on semantics.** Changing the meaning of a column without moving it is MAJOR: when the coverage
  indicators switched to the same demand rate the purchase used (8.0.0), no column moved and the number changed
  in five channels. The changelog records what moved and what did not: `recommended_qty_final` was measured
  identical for every SKU in every channel before merge.
- **Two gates.** `contract` runs on every PR without credentials and compares the contract with the dbt manifest
  (required on `main`). `contract verify` runs daily against the warehouse and checks name, type and order on the
  built Gold tables and the shape of the app's seam views, because Snowflake freezes a `select *` view's column
  list at creation time. A failure there is an operational alarm, not a merge block.
- **Shadow build.** Any PR touching the inventory engine builds both sides on the same window, the PR's code and
  main's, in throwaway schemas, and compares channel by channel; comparing against production would mix data
  drift with the effect of the change. Indirect test selection is set to `cautious` so tests whose other parent is
  out of scope do not compile against tables that were never built. Schemas are dropped at the end of every run,
  including failures.

## The requirements discipline

Every feature that changes a Gold column or a planner-visible behaviour carries `requirements.md`, `design.md`
and `tasks.md`. Acceptance criteria are written in EARS and **each one names the test that proves it**:

> **AC-4 (unwanted)** IF `sales_horizon_days` is outside 30 to 365, THEN the pipeline SHALL clamp it to the
> limits and still report `window_source = 'CONFIGURED'`. → test: `expect_column_values_to_be_between(30, 365)`

> **AC-7 (zero-diff)** WHEN no SKU has a horizon configured, the output SHALL be identical to the build before
> the feature. → verification: `analyses/validate_sales_horizon_zero_diff.sql`

`design.md` names its patterns ("Template Method with a Configuration Object" is reviewable; "a macro that takes
the channel" is not). SQL models cite their spec in the header; a dangling reference is a CI error. The specs
live in the repository, not in a gitignored tool folder: thirteen design documents had been invisible to PR
reviewers and to the consuming repository until they were moved.

## The engine rewrite: a total is not a rate

The old formula estimated demand by averaging daily sales over one window (30 to 365 days, planner-chosen) and
stretching that rate flat across a 198-day coverage period. Demand is not flat, and the purchase is the thin
residue of two large numbers (about 447,000 units of demand against 806,000 available across 73 SKUs), so small
errors in the rate became large errors in the order. The rewrite sums what actually sold last year over the exact
months being covered, then adjusts for growth. The central-warehouse recommendation fell 17.8 % (16,681 to 13,720
units) because the old method double-counted demand that was not there. The plain-language explanation was written
for the planner before the code changed, and one business question only the client could answer (which channels
the main warehouse supplies) was escalated rather than guessed.

## Fit

Requirements engineering · data contracts · spec-driven development · dbt · analytics engineering · BI governance
