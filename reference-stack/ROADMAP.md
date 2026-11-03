# Reference stack · roadmap

A public, runnable reproduction of the patterns in the case studies, on synthetic data, written from scratch
for this portfolio (no client code). It exists so a reviewer can clone it and see the practices run, not just
read about them. Repository: `medallion-reference-stack` (separate, linked from here once published).

## Status

| Phase | Scope | State |
|---|---|---|
| 1 | Portfolio hub (this repository): case studies, practices, fit matrix | done |
| 2 | Medallion dbt project + Dagster + contract + CI gates | planned |
| 3 | Visualization layer: Streamlit purchase guide, Power BI semantic model (PBIP/TMDL), Looker Studio and Tableau Public rebuilds of the command panel | planned |
| 4 | PySpark variant of Silver and a Kafka → Iceberg micro-stream (Spark and streaming postings) | planned |

## Phase 2 · what gets built

```
medallion-reference-stack/
├── data/generate.py              # synthetic multi-channel e-commerce: orders, order lines, inventory snapshots, purchase orders, holidays
├── dbt/                          # one project, DuckDB by default, Snowflake profile included
│   ├── models/bronze/            # views, 1:1, explicit columns
│   ├── models/silver/            # incremental merge with 3-day lookback; dedup; business rules; ephemeral velocity
│   ├── models/gold/              # sales by channel, inventory velocity, reorder needs (the contract's tables)
│   ├── macros/                   # generate_schema_name, reorder engine as Template Method + channel config
│   └── tests/                    # dbt_utils + dbt_expectations: ranges, volumes, composite keys, recency, cross-table
├── specs/
│   ├── contracts/inventory-needs/{contract.yml, requirements.md, CHANGELOG.md, generated/}
│   └── features/configurable-sales-horizon/{requirements.md (EARS), design.md, tasks.md}
├── orchestration/                # Dagster definitions: dbt assets, schedule, a manifest-driven closure sensor (pure function + tests), failure alert
├── scripts/
│   ├── contract_sync.py          # contract.yml → dbt contracts + TypeScript types; `drift` mode fails on redeclared limits
│   └── shadow_diff.py            # builds base and new in two schemas on the same window, compares channel by channel
├── app/                          # Streamlit purchase guide reading the generated types (Phase 3)
└── .github/workflows/
    ├── lint.yml                  # sqlfluff · flake8 · pytest · dbt parse (no path filter: required)
    ├── build.yml                 # dbt build on DuckDB in CI, no secrets
    ├── contract.yml              # contract vs manifest; drift check
    ├── shadow-build.yml          # zero-diff gate on PRs touching the engine
    ├── pr-size.yml               # 300 counted lines; `large-pr` label as the exception
    ├── work-item.yml             # branch carries an issue id; `no-issue` label as the exception
    ├── conventional-title.yml
    └── ai-review.yml             # standard / deep by label; comments only; skipped without a key
```

## Acceptance criteria (EARS, each with its verification)

- **AC-1** The project SHALL build from a fresh clone with `uv sync && uv run dbt build` in under two minutes on
  a laptop. → verification: timed in CI's build job.
- **AC-2** WHEN a Gold column named in `contract.yml` is removed or retyped, the contract check SHALL fail the PR.
  → verification: a fixture PR in the test suite of `contract_sync.py`.
- **AC-3** WHEN the engine changes and the output does not, the shadow build SHALL report zero diff per channel;
  WHEN a number changes, it SHALL list the channel, the SKU count and the delta. → verification: two fixture
  commits in CI.
- **AC-4** IF a PR exceeds 300 counted lines without the `large-pr` label, THEN `pr-size` SHALL fail with the
  count. → verification: a fixture branch.
- **AC-5** The closure sensor SHALL select exactly the assets downstream of the changed table, traversing but
  not selecting ephemeral models. → verification: pytest over a stub manifest.
- **AC-6** The AI review job SHALL end with a notice and no cost when the key is absent. → verification: CI run
  on a fork.
- **AC-7** The README SHALL carry the same architecture diagram as CS-01 and a table of which case-study
  pattern each directory reproduces.

## Build plan

Each wave is one card, one branch, one PR, under the playbook. Agents execute; I review and merge.

1. Synthetic data generator + Bronze/Silver/Gold on DuckDB + tests (`build.yml` green).
2. Specs, contract and `contract_sync.py` (`contract.yml` green; generated types committed).
3. Reorder engine as a macro with a per-channel configuration; `shadow_diff.py` and its workflow.
4. Dagster definitions, closure sensor, tests (`lint.yml` green).
5. Governance workflows (`pr-size`, `work-item`, `conventional-title`, `ai-review`), README, diagrams.
6. Phase 3: the Streamlit guide, the Power BI model, the Looker Studio and Tableau Public rebuilds.
