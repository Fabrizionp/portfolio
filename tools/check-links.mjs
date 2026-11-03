// Fails when a relative link or image in any Markdown file points to a path that does not exist.
import { readFileSync, readdirSync, statSync, existsSync } from "node:fs";
import { join, dirname, resolve } from "node:path";

const root = resolve(new URL("..", import.meta.url).pathname.replace(/^\/([A-Za-z]:)/, "$1"));
const files = [];
(function walk(d) {
  for (const n of readdirSync(d)) {
    if (n === ".git" || n === "node_modules") continue;
    const p = join(d, n);
    if (statSync(p).isDirectory()) walk(p); else if (n.endsWith(".md")) files.push(p);
  }
})(root);

let bad = 0, total = 0;
for (const f of files) {
  const text = readFileSync(f, "utf8");
  const re = /!?\[[^\]]*\]\(([^)\s]+)(?:\s+"[^"]*")?\)/g;
  let m;
  while ((m = re.exec(text))) {
    const target = m[1];
    if (/^(https?:|mailto:|#)/.test(target)) continue;
    total++;
    const path = join(dirname(f), decodeURIComponent(target.split("#")[0]));
    if (!existsSync(path)) { bad++; console.log(`MISSING  ${f.slice(root.length + 1)} -> ${target}`); }
  }
}
console.log(`${total} relative links checked, ${bad} missing`);
process.exit(bad ? 1 : 0);
