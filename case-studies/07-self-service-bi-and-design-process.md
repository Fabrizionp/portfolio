# CS-07 · Self-service BI and the design process

**Role:** BI architect and builder; Microsoft Certified Power BI Data Analyst Associate (PL-300).
**Where:** TheraICE (US e-commerce, 2024 to 2025), ICL South America (specialty minerals, 2023 to 2024), Siemens
Healthineers (2021 to 2022), and the Bipsio design track (2026).

## Summary

Thirty-plus dashboards for sales, inventory, marketing and executive teams, built on one design system per
client so a new page looks like the last one and a user who learned one learned all. Self-serve means the user
can answer the next question without a ticket: standardized filters, consistent KPI tiles, drill paths that keep
the context, apps published with department-level access.

## The TheraICE suite (Power BI)

Six reports on one design system: Amazon, Shopify, Target, Aesthetica (second brand), Inventory, Consolidated.

- **One shell**: a left rail with the channel pages, a sales-overview header, five KPI tiles (net sales, gross
  profit, orders, units, customers) with one semantic colour per measure across every report, a filters panel in
  a fixed position, and the brand mark where the eye expects it.
- **One semantic model per channel on the Gold tables of CS-01**, so a KPI means the same thing in the report, in
  StockSync Pro and in the weekly email.
- **Executive first, detail on demand**: the first page answers the week in five numbers and two charts; every
  tile drills to the SKU without leaving the filter context.

[![Sales overview in the Power BI design](../assets/sales-overview-powerbi-design.png)](../assets/sales-overview-powerbi-design.png)

*Synthetic-data reproduction of the suite's first page in its design language. Source:
[`demos/sales-overview-powerbi.html`](../demos/sales-overview-powerbi.html).*

The production shell, captured without data (brand marks replaced):

[![Power BI shell template](../assets/powerbi-shell-template-all-channels.jpg)](../assets/powerbi-shell-template-all-channels.jpg)

Report pages with client data stay private.

## ICL South America: 200 users, 20+ dashboards

- Reporting infrastructure for commercial and portfolio decisions in one of the largest specialty minerals
  companies: ETL in Azure SQL and Power Query that productionized collection, transformation and visualization,
  cutting manual processes by 60 %.
- A standardized theme and template so non-technical teams could build on it; apps published with
  department-level access instead of file sharing.
- At Siemens Healthineers, Power BI over SAP and operational data with Dataflows cut manual reporting by 70 %.

## The design process I run (2026, Bipsio design track)

The brief: an application a broker opens twenty times a day in a 1,750-px window, judged in ten seconds. The
track, in the order it ran, each step documented and reviewed:

| Step | What was produced |
|---|---|
| 1. Audit | Every surface screenshotted at 1,750 × 1,000 in light and dark by a script that signs in, visits each route and signs out; each surface scored with a "what works / what is slop / what is missing" table and a verdict out of 10 |
| 2. Information architecture | The routes, the home of each object, the shortcuts, the switcher |
| 3. Direction boards | Two boards (A and B) rendered; the direction settled as a blend with the reasons written down |
| 4. Design system | Tokens v2, the primitives re-skinned, the new primitives, one provenance language for every figure (source and date on hover) |
| 5. Surfaces | The shell, the chat, the property page (map first, the listing's own figures in the first paint, a score band, ten topics one line each), the rest of the app |
| 6. Validation | After-screens at four widths in both themes, a visual baseline with comparison, an accessibility and first-paint audit (0.85 s measured in production), the timed broker walk, the bundle check |
| 7. Fixes | A pull request per surface, each with its before and after |

The property-page redesign that followed (CS-06) started from a measured problem (16,904 px, the same figure
said in up to nine places against three comparison pools) and a stated hierarchy: what the buyer needs in ten
seconds, in two minutes, in twenty minutes. The mock was reviewed by the stakeholder on a recorded walk-through;
each point was weighed, not taken as given (accepted, accepted with a change, declined with the reason, deferred).

## Rules I apply to every analytical surface

1. Write the question the page answers before drawing anything; order the blocks by the reader's time.
2. One truth per figure: one home, one comparison set, provenance on hover.
3. One status rule for the whole product, in one file.
4. A missing metric shows "—" and the reason; a measured zero is a dimmed `0`.
5. Nothing is recalculated on the client; the surface reads the contract.
6. Validate against the warehouse (a SQL × render table) before calling a page done.
7. Distribute to the people who will not open the dashboard: a weekly email with the decisions, not the charts.
8. Monitor adoption and cost; a page nobody opens is a bug.

## Fit

Power BI · DAX · semantic models · self-serve BI · design systems · UX process · stakeholder review · accessibility
