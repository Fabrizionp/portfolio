# Fabrizio Pescarmona · Data platform, BI and agentic delivery

[![checks](https://github.com/Fabrizionp/portfolio/actions/workflows/checks.yml/badge.svg)](https://github.com/Fabrizionp/portfolio/actions/workflows/checks.yml)
[![version](https://img.shields.io/github/v/tag/Fabrizionp/portfolio?label=version&color=1f5fa8)](CHANGELOG.md)
[![license](https://img.shields.io/badge/code-MIT-2bc4dd)](LICENSE)
[![content](https://img.shields.io/badge/content-CC%20BY%204.0-b48cf2)](LICENSE-CC-BY-4.0.txt)

**Data Team Lead and data solutions architect.** I architect, build and operate production data platforms and
data products: multi-client platforms on Snowflake (Medallion layers, dbt, Dagster, contracts and governance, CI/CD),
the BI and multi-tenant SaaS products on top of them, and the agentic delivery system that lets my team and AI
agents ship through governed pull requests. Founder of Laboris AI, a labor-litigation
data SaaS that uses LLMs for structured extraction.

This repository complements my CV with **evidence**: case studies with architecture, numbers and the practices
that made each system hold, the operating model I run my team on, and the plan for a runnable reference stack.

> CV: [linkedin.com/in/fabrizio-pescarmona](https://linkedin.com/in/fabrizio-pescarmona) ·
> fabrizionpcontato@gmail.com · São Paulo, Brazil · open to remote

---

## What I do, in four pillars

| Pillar | What it means in my work | Where to look |
|---|---|---|
| **Data platform engineering** | Medallion architecture (Bronze/Silver/Gold), dbt monorepos, Dagster orchestration with a CDC sensor, Iceberg lakehouse, Snowflake, CI/CD that deploys the pipeline and the apps | [CS-01](case-studies/01-multi-client-dbt-dagster-platform.md), [CS-04](case-studies/04-lakehouse-every-15-minutes.md) |
| **BI and data visualization products** | Translating a business question into a surface people adopt: KPI hierarchy, one truth per figure, self-serve filters, automated distribution, monitoring | [CS-03](case-studies/03-inventory-intelligence-product.md), [CS-07](case-studies/07-self-service-bi-and-design-process.md) |
| **Agentic delivery with engineering governance** | AI agents execute inside a governed repository: a card per task, a branch per card, pull requests under a size budget, required checks, AI review, human merge, decisions carried forward | [CS-06](case-studies/06-agentic-delivery-at-scale.md), [Playbook](practices/agentic-delivery-playbook.md) |
| **Requirements, contracts and design thinking** | Specs with EARS acceptance criteria that name their test, versioned producer/consumer contracts, acceptance tables, stakeholder review triage | [CS-02](case-studies/02-producer-consumer-contract.md), [Method](practices/requirements-and-design-thinking.md) |

---

## Two kinds of surface, side by side

The same data platform serves an **analytical** surface (explore, compare, drill) and an **actionable** one
(what to buy, how much, why). Both pages below are synthetic-data reproductions of production dashboards,
written for this portfolio; the sources are in [`demos/`](demos/README.md).

| Analytical · Sales Overview (Power BI design) | Actionable · Command Panel and Purchase Guide |
|---|---|
| [![Sales overview](assets/sales-overview-powerbi-design.png)](assets/sales-overview-powerbi-design.png) | [![Command panel](assets/command-panel-purchase-guide.png)](assets/command-panel-purchase-guide.png) |
| Five KPI tiles against last month, Today / MTD / YTD switches, hourly sales, category, fulfilment and brand bars, product and customer tables, a customer map. The reader explores. | Three purchasing channels and two transfer channels in one glance; then the lines to buy, the status rule, and the recommendation parcel by parcel with the Gold column each parcel came from. The reader acts. |

The same analytical question on a 15-minute lakehouse, in the Streamlit design language:
[![Sales overview, Streamlit](assets/sales-overview-streamlit-design.png)](assets/sales-overview-streamlit-design.png)

---

## Case studies

| # | Case study | One-line outcome |
|---|---|---|
| 01 | [Multi-client dbt + Dagster platform on Snowflake](case-studies/01-multi-client-dbt-dagster-platform.md) | 43 models, 241 dbt tests, 151 pytest tests, 11 CI/CD workflows with 6 required checks, one CDC sensor over six streams that rebuilds only the downstream closure of the table that changed |
| 02 | [The contract between the pipeline and the app](case-studies/02-producer-consumer-contract.md) | A versioned contract that generates the dbt column blocks, the dbt vars and the TypeScript types; a check on every PR and a daily verification against the warehouse; the first run found 6 real drifts, the last found 0; five copies of the purchasing engine became one (1,783 lines of channel SQL to one macro plus 145) |
| 03 | [StockSync Pro: an inventory intelligence product](case-studies/03-inventory-intelligence-product.md) | Five sales channels, SKU-level purchase and transfer recommendations, weekly automated emails; a purchase-guide redesign validated with 11 acceptance criteria and a SQL-versus-render table |
| 04 | [A lakehouse that rebuilds every 15 minutes](case-studies/04-lakehouse-every-15-minutes.md) | ERP + e-commerce CDC to S3 Iceberg read in place by Snowflake, dbt on ECS Fargate Spot starting ten minutes ahead of each Power BI refresh, Cortex ML forecasting and a text-to-SQL analyst, stuck ingestion detected in Snowflake and recovered by a Lambda with a circuit breaker |
| 05 | [Laboris AI: signals that trigger ingestion, in layers](case-studies/05-agentic-extraction-platform.md) | Public signals say which cases changed; reads escalate in cost only on a signal (public timeline → full file → filing PDFs → AI reading); 133 of 155 petitions published with grounding, liquidations reconciled to the cent, screens that state their own freshness |
| 06 | [Agentic delivery at scale](case-studies/06-agentic-delivery-at-scale.md) | 2,400+ commits and ~245 pull requests in five months on one product; 654 migrations replayed from zero on every PR that touches the database; AI review that comments but never approves; a quality-eval gate on prompt changes |
| 07 | [Self-service BI and the design process](case-studies/07-self-service-bi-and-design-process.md) | Power BI suites for a US e-commerce brand and a specialty minerals company with 200+ users; the design process from audit to boards, tokens, surfaces and validation at four widths |

## Practices

- [Agentic delivery playbook](practices/agentic-delivery-playbook.md): the operating model, step by step, with the rules that are enforced by CI rather than by memory, and the lessons that shaped them.
- [Requirements and design thinking](practices/requirements-and-design-thinking.md): how a need becomes a spec, a contract, a surface and an acceptance table.

## Reference stack (planned)

[`reference-stack/`](reference-stack/ROADMAP.md) will be the public, synthetic-data reproduction of the patterns above:
a dbt Medallion project (DuckDB locally, Snowflake-ready), Dagster definitions with a manifest-driven CDC sensor,
a versioned contract with generated types, and the CI gates (lint, build, contract, shadow build, PR size, work
item, AI review). Status and acceptance criteria are in the roadmap.

## Evidence policy

- Production code for clients is proprietary and stays private. What is public here: architecture, practices,
  measured outcomes, sanitized artifacts, and the reference stack I wrote to reproduce the patterns.
- Every number in a case study was measured in the system it describes (test counts, line counts, row counts,
  cost) and is dated where it matters.
- Client names appear only where they are already public in my CV; otherwise the client is described by sector.

## How this repository is maintained

Every change arrives by pull request with a Conventional Commits title, squash-merged, and the `checks` workflow
runs the three checks a reader would run by hand: relative links resolve, every Mermaid diagram parses and renders
in the real library, and the demo pages load without an error (`npm run check`). Versions and dates are in the
[changelog](CHANGELOG.md). Code is MIT; written content and diagrams are CC BY 4.0.
