# Job-fit matrix

How the evidence in this portfolio maps to the roles I am targeting. "Gap" is honest: it names what I have not
done in production and what I would do about it.

## 1. Senior Data Visualization Engineer (digital retail, Vancouver)

| They ask for | Evidence | Where |
|---|---|---|
| Automated, distributed, self-serve analytical interfaces | StockSync Pro: five-channel command panel, purchase guides, weekly automated emails to people who never open a dashboard; ICL: 20+ dashboards for 200+ users published as apps with department-level access | CS-03, CS-07 |
| Design principles, intuitive and interactive visualizations | The purchase-guide rules (one status rule for the whole app, a missing metric shows the reason and never 0, the math parcel by parcel), the Bipsio design track (audit, information architecture, direction boards, tokens, surfaces, validation at four widths in two themes) | CS-03, CS-07, Method |
| Lead the design process: sketches, wireframes, UX scenarios, mockups | Property-page redesign: proposal with a 10 s / 2 min / 20 min hierarchy, a mock reviewed by the stakeholder on video, a 41-point triage (24 accepted, 11 accepted with a change, 3 declined, 3 deferred), 65 build tickets, all merged | CS-06, CS-07 |
| Drive adoption, proactive monitoring and support | Weekly push reports, a cost monitor (Snowflake, Fivetran, Dagster, AWS) and a monthly client report with a validation gate; a quality-eval gate as a required check | CS-01, CS-03, CS-06 |
| Lead the product management cycle | Specs (requirements, design, tasks) in the repository; contracts with SemVer and changelogs; a triage protocol for stakeholder feedback | CS-02, Method |
| Mentorship, training, collaboration | Lead of a five-person team; house rules per directory that agents and people both read; runbooks and postmortems the team writes and reads | Playbook |
| Tableau, Looker, Power BI | Power BI (PL-300), Streamlit in Snowflake, React dashboards. **Gap:** Tableau and Looker in production. Plan: rebuild the StockSync command panel in Looker Studio and Tableau Public over the reference stack's Gold layer | reference-stack |
| Cloud, large data volumes, SQL | Snowflake, Iceberg on S3, semantic views, single-scan aggregations that cut warehouse compute 75 to 85 % | CS-01, CS-04 |
| Digital or marketing analytics | Amazon Ads, Shopify, Walmart and Target channel analytics; Magento e-commerce; customer RFM segmentation and churn narratives | CS-03, CS-04 |

## 2. Data Platform Engineer, Microsoft Fabric (Whitby)

| They ask for | Evidence | Gap |
|---|---|---|
| Bronze/silver/gold, incremental loads, CDC, watermarking, MERGE | dbt incremental merge with a 3-day lookback; Airbyte CDC to Iceberg; Snowflake Stream sensors; shadow builds | Delta MERGE on Fabric specifically: the reference stack adds a PySpark variant of Silver |
| Power BI semantic models, DAX, reports | PL-300; the TheraICE suite; Gold tables shaped for Power BI (schema cached, no breaking change without the matching Power BI change) | None |
| Git workflows, PRs, code review, AI-assisted engineering | The whole playbook | None |
| Validate transformed data against legacy sources | Shadow-build zero-diff gate; before/after counts in every PR that moves rows; contract verification against the warehouse | None |
| Fabric / Databricks / Synapse / Snowflake | Snowflake daily; Databricks and Redshift as sources; Redshift retired with a snapshot | Fabric hands-on: DP-600 and a port of the reference stack to a Fabric trial |

## 3. Business Analyst, Data Warehouse and BI Reporting (wealth management)

| They ask for | Evidence | Gap |
|---|---|---|
| User stories, data specs, acceptance criteria | EARS requirements where every AC names its test; `contract.yml` as the single source | None |
| Source-to-target mapping, profiling, data quality | Bronze 1:1 mirrors with explicit columns, Silver business rules, dbt_expectations, freshness | None |
| Business Objects, Tableau | Power BI, Streamlit, React | Tool gap; the method transfers |
| Confluence, Jira, Visio, modelling tools | Linear, ClickUp, Mermaid diagrams in the repository, dbt docs | Minor |
| Wealth management | None | Sector gap |

## 4. Data and Database Analyst (St. John's)

Strong fit on the substance (databases, dashboards, eliminating manual entry, training users: ICL cut manual
processes 60 %, Siemens 70 %). The posting asks for examples of databases, spreadsheets and dashboards built:
CS-03, CS-07 and the reference stack are those examples. Over-qualified on scope; on-site in Newfoundland.

## 5. CX Intelligence Analyst (Agilent)

Partial fit: survey and CRM analytics, Qualtrics and Voice-of-Customer programs are not my background. What
transfers: integrating CRM, operational and business datasets, dashboards, predictive modelling (Cortex ML
forecasts and anomaly detection), text analytics (LLM extraction with grounding). Apply only with a tailored
narrative; not a primary target.

## 6. Data Engineer, streaming (Vancouver)

Partial fit: Python, SQL, PostgreSQL, Docker, GitHub Actions, data quality, idempotency and replay are daily
work (Laboris collectors, the Bipsio dispatcher, dbt). **Gaps:** Apache Flink and Kafka in production,
Kubernetes, Java. Not a primary target unless the stack is negotiable.

## 7. ILI Data Analyst Level III (Novitech)

Not a fit: the role needs a Level III in-line inspection qualification and four years of MFL data analysis.
