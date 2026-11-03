// Parses and renders every ```mermaid block in the Markdown files with the real Mermaid library,
// so a diagram that GitHub would refuse to draw fails the check before it is published.
import { readFileSync, readdirSync, statSync } from "node:fs";
import { join, resolve } from "node:path";
import { chromium } from "playwright";

const MERMAID = "https://cdn.jsdelivr.net/npm/mermaid@11.4.1/dist/mermaid.esm.min.mjs";
const root = resolve(new URL("..", import.meta.url).pathname.replace(/^\/([A-Za-z]:)/, "$1"));
const files = [];
(function walk(d) {
  for (const n of readdirSync(d)) {
    if (n === ".git" || n === "node_modules") continue;
    const p = join(d, n);
    if (statSync(p).isDirectory()) walk(p); else if (n.endsWith(".md")) files.push(p);
  }
})(root);
const blocks = [];
for (const f of files) {
  const t = readFileSync(f, "utf8"); const re = /```mermaid\n([\s\S]*?)```/g; let m, i = 0;
  while ((m = re.exec(t))) blocks.push({ file: f.slice(root.length + 1), idx: ++i, code: m[1] });
}

const browser = await chromium.launch();
const page = await browser.newPage();
await page.goto("https://cdn.jsdelivr.net/npm/mermaid@11.4.1/package.json");
await page.setContent(`<html><body><script type="module">
  import mermaid from "${MERMAID}";
  mermaid.initialize({ startOnLoad: false, securityLevel: "loose" });
  window.check = async (code) => {
    try { await mermaid.parse(code); const { svg } = await mermaid.render("g" + Math.random().toString(36).slice(2), code); return { ok: true, len: svg.length }; }
    catch (e) { return { ok: false, err: String(e.message || e).slice(0, 300) }; }
  };
  window.ready = true;
</script></body></html>`);
await page.waitForFunction("window.ready === true", { timeout: 120000 });
let bad = 0;
for (const b of blocks) {
  const r = await page.evaluate((c) => window.check(c), b.code);
  console.log(r.ok ? "OK  " : "FAIL", b.file, "#" + b.idx, r.ok ? `(svg ${r.len} chars)` : r.err);
  if (!r.ok) bad++;
}
await browser.close();
console.log(`${blocks.length} diagrams, ${bad} failing`);
process.exit(bad ? 1 : 0);
