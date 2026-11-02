# CS-03 · StockSync Pro: an inventory intelligence product

**Role:** Product owner, architect and builder of the data product end to end (pipeline in CS-01, app, reports).
**Client named in my CV:** TheraICE. **Users:** the supply planner and the operations team.
**Stack:** React + TypeScript + shadcn on Supabase (auth, RLS, edge functions), Snowflake Gold through a single
gateway edge function, Recharts, automated email reports, AWS EC2 hosting.

## The question the product answers

Every week the planner has to decide, per SKU and per channel: **what to buy or transfer today, how much, what is
at risk, and whether the order document can be issued.** Before StockSync Pro that decision was made from five
marketplace exports and a spreadsheet, with no shared definition of "days of stock".

[![Command panel and purchase guide](../assets/command-panel-purchase-guide.png)](../assets/command-panel-purchase-guide.png)

*Synthetic-data reproduction of the Command Panel and the AWD Purchase Guide, with one row expanded to show
the math parcel by parcel. Source: [`demos/command-panel-stocksync.html`](../demos/command-panel-stocksync.html).*

## What it does

- **Command Panel**: one screen with the five channels (AWD central warehouse, Amazon FBA, Shopify, Target,
  Walmart): active SKUs, SKUs needing purchase, units to buy, units to transfer AWD → FBA and AWD → Shopify.
- **Purchase and transfer guides per channel**: velocity, stock by bucket (AWD / FBA / Main), days of stock with
  and without open orders, recommended quantity in units, master cases and pallets, projected days of stock at
  ETA, reorder date, ETA, holiday impact, status.
- **Configurable parameters per SKU**: safety stock (days or units), lead time, purchase frequency, order day of
  week, packout, sales horizon, pack relationships for bundles, a holiday calendar with shipping blackouts.
- **Weekly automated emails**: Layer 1 purchase orders (AWD → supplier), Layer 2 transfers (AWD → FBA, AWD →
  Main), status summary per channel. The team reads and acts; no dashboard knowledge required.
- **Roles and audit**: admin and user roles, row-level security on every table, an audit log, email recipients
  and schedules managed in-app.

## The redesign of the purchase guides (August 2026)

A first version had invented its own status words ("Late / Before next window / On cadence") on the same screen
where the dashboard said Critical / Warning / OK about the same SKUs. Two rulers for one question. The redesign
set the rules I now apply to every analytical surface:

1. **The page answers five questions, in this order:** what to order today and how much; what is at risk; can I
   issue the document; am I seeing everything; where did this number come from.
2. **One status rule for the whole app**, in one file: Critical (DOS ≤ safety stock), Warning (DOS ≤ safety +
   lead time), OK, and "No velocity" as the absence of an answer, not a fourth severity. The reorder date did
   not disappear: it became a column, *when* next to *how severe*, not instead of it.
3. **All SKUs, filtered by default to those needing an order.** The SKU that does not need an order yet still has
   a reorder date and a status, and that is what the planner looks at to pull an item forward to fill a pallet.
4. **A missing metric shows "—" and the reason, never 0.** A measured zero is a fact and is rendered as a dimmed
   `0`; cases and pallets show "—" when there is nothing to order.
5. **The expanded row shows the math parcel by parcel**, each parcel named with the Gold column it came from.
   For a SKU with nothing to order it becomes "why there is nothing to order yet".
6. **Nothing is recalculated in the client.** Units, cases, pallets and containers come from the Gold columns;
   the app is a reader of the contract (CS-02).

### Acceptance, measured

| # | Criterion | Verification | Result |
|---|---|---|---|
| AC1 | KPIs match the Gold in all five channels | SQL aggregation per channel × the real render | identical |
| AC2 | The status rule is the app's one rule | same file, same fallbacks as the dashboard | yes |
| AC3 | "No velocity" ≡ no DOS | `count_if(days_of_stock is null)` = `count_if(velocity_15d = 0)` in 5 views | equal in all |
| AC4 | "All SKUs" shows the date of SKUs with nothing to order | render with `?scope=all` | 58 SKUs, 12 with an order, 46 with a date |
| AC6 | What "Active only" hides is said | render default | "15 discontinued hidden (30 units)" |
| AC8 | A channel with nothing to buy is not an error | render Target | "Nothing to buy today" + link to All SKUs |
| AC10 | No slice breaks | 14 scenarios over 5 channels rendered on real rows | 14/14 |
| AC11 | CI gates | `tsc`, `deno check`, `eslint`, `vite build` | pass |

Until that month the app had no CI: type checks ran only if someone remembered. The redesign landed with a CI
that type-checks every edge function and the frontend and lints on every PR.

## Adoption and distribution

- The weekly email is the distribution channel for people who will never open the app.
- A monthly client report (CS-01) shows the cost of the platform per source and per month, with a validation gate
  so a narrative can never disagree with a table.
- The roadmap (conversational access over the Gold through a semantic layer and an embedded assistant) was
  scoped so that it needs no new data engineering: it reads the same contract.

## Fit

BI product · data visualization · self-serve analytics · requirements to acceptance · React · Supabase · Snowflake
