# demos · two kinds of analytical surface, side by side

| Page | Kind | What it shows | Production original |
|---|---|---|---|
| [`sales-overview-powerbi.html`](sales-overview-powerbi.html) | **Analytical** | Five KPI tiles, one colour per measure, each against last month with a last-month box; Today / MTD / YTD and $ / GP / orders / units switches; hourly sales, month to date against last month; category, fulfilment and brand bars with share and growth; product and customer tables; a customer map | The Power BI design language of CS-07 |
| [`sales-overview-streamlit.html`](sales-overview-streamlit.html) | **Analytical, operational cadence** | The same question for a retailer whose Gold rebuilds every 15 minutes: every card against the previous period, an anomaly banner from the forecasting model, daily sales against the previous period, category, brand and fulfilment bars, product performance with arrows, geography | The Streamlit-in-Snowflake dashboard of CS-04 |
| [`command-panel-stocksync.html`](command-panel-stocksync.html) | **Actionable** | Three buying channels and two transfer channels at a glance, then the purchase guide: lines, units, cases, pallets, the status rule, blocked lines, and one row expanded to show the recommendation parcel by parcel with the Gold column of each parcel | StockSync Pro of CS-03 |

All three are self-contained HTML pages written for this portfolio on synthetic data (fixed or seeded rows, no
client rows, no brand marks); they open in a browser with no server or build step (the Power BI page fetches
Leaflet and its map tiles from the internet), reproduce the layout and the states of the production surfaces but
not their interactions, and are the source of the screenshots in [`../assets/`](../assets/), rendered at 1,750 px
with Playwright. The two kinds differ in their job: a sales overview is read top to bottom and makes the next
question easy to ask, with the same filters on everything; a command panel is read in ten seconds and ends in an
action (a number to order, a document to issue) with the math shown, so the planner can disagree with it. Both
follow the same rules: one truth per figure with its source named; one status rule (Critical at or below safety
stock, Warning at or below safety plus lead time, OK above); a missing metric shows a dash and the reason, never 0,
and a measured zero is a dimmed `0`; nothing is recalculated in the browser; everything in the ten-second read is
actionable or explains an action.
