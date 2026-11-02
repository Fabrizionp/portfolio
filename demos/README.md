# demos · two kinds of analytical surface, side by side

Three self-contained HTML pages, written for this portfolio on **synthetic data** (seeded generators, no client
rows, no brand marks), reproducing the design language of the production dashboards described in the case
studies. Open any file in a browser; no server, no dependencies. The screenshots in [`../assets/`](../assets/)
were rendered from these pages at 1,750 px with Playwright.

| Page | What it shows | The production original |
|---|---|---|
| [`sales-overview-powerbi.html`](sales-overview-powerbi.html) | **Analytical**: the executive first page. Five KPI tiles with one semantic colour per measure, month vs last year, channel share and growth, top SKUs with margin, orders and units by week. The reader explores; nothing tells them what to do | The Power BI suite of CS-07 (one design system across six reports) |
| [`sales-overview-streamlit.html`](sales-overview-streamlit.html) | **Analytical, operational cadence**: the same question for a retailer whose Gold rebuilds every 15 minutes. Period vs previous period on every card, an anomaly banner from the ML model, cross-filterable category and brand bars, product performance with arrows, geography | The Streamlit-in-Snowflake sales dashboard of CS-04 |
| [`command-panel-stocksync.html`](command-panel-stocksync.html) | **Actionable**: what to buy or transfer today, how much, why. Three purchasing channels and two transfer channels in one glance, then the purchase guide: lines, units, cases, pallets, the status rule, and an expanded row that shows the recommendation parcel by parcel with the Gold column each parcel came from | StockSync Pro of CS-03 |

## The difference, in one paragraph

A sales overview is read top to bottom, left to right, and its job is to make the next question easy to ask: a
tile, a trend, a breakdown, a table, with the same filters applied to everything. A command panel is read in
ten seconds, and its job is to end with an action: a number to order, a document to issue, and the reason the
number is what it is, so the planner can disagree with it. The first surface recalculates nothing and hides
nothing; the second one recalculates nothing either, and shows the math.

## Rules both pages follow

1. One truth per figure, with the source named (the Gold column, the comparison period).
2. One status rule for the whole product (Critical ≤ safety stock, Warning ≤ safety + lead time, OK above).
3. A missing metric shows "—" and the reason, never 0; a measured zero is a dimmed `0`.
4. Nothing is recalculated in the browser; the page reads the contract.
5. Everything visible in the ten-second read is actionable or explains an action.
