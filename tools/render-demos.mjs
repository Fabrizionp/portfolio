// Opens each demo page in a headless browser at 1,750 px and fails on any page error or console error.
// With --shoot it also writes the screenshots to assets/ (what the README embeds).
import { readdirSync } from "node:fs";
import { join, resolve } from "node:path";
import { chromium } from "playwright";

const root = resolve(new URL("..", import.meta.url).pathname.replace(/^\/([A-Za-z]:)/, "$1"));
const shoot = process.argv.includes("--shoot");
const out = {
  "sales-overview-powerbi.html": "sales-overview-powerbi-design.png",
  "sales-overview-streamlit.html": "sales-overview-streamlit-design.png",
  "command-panel-stocksync.html": "command-panel-purchase-guide.png",
};
const pages = readdirSync(join(root, "demos")).filter((n) => n.endsWith(".html"));
const browser = await chromium.launch();
let bad = 0;
for (const html of pages) {
  const page = await browser.newPage({ viewport: { width: 1750, height: 1000 }, deviceScaleFactor: 2 });
  const errors = [];
  page.on("pageerror", (e) => errors.push("pageerror: " + String(e).slice(0, 200)));
  page.on("console", (m) => { if (m.type() === "error" && !/tile|arcgis|net::ERR/i.test(m.text())) errors.push("console: " + m.text().slice(0, 200)); });
  await page.goto("file:///" + join(root, "demos", html).replace(/\\/g, "/"), { waitUntil: "load" });
  await page.waitForTimeout(shoot ? 5000 : 1500);
  if (shoot && out[html]) await page.screenshot({ path: join(root, "assets", out[html]), fullPage: true });
  console.log(errors.length ? "FAIL" : "OK  ", html, errors.join(" | "));
  if (errors.length) bad++;
  await page.close();
}
await browser.close();
console.log(`${pages.length} demo pages, ${bad} failing`);
process.exit(bad ? 1 : 0);
