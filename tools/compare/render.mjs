// Writes out/html/<sample>.html showing VS Code colors on the left and Neovim on the right.
// Usage: node render.mjs sample.js [nvimOutDir]
import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

const here = path.dirname(fileURLToPath(import.meta.url));
const sample = process.argv[2];
if (!sample) {
  console.error("usage: node render.mjs <sample> [nvimOutDir]");
  process.exit(2);
}
const nvimDir = process.argv[3] ? path.resolve(process.argv[3]) : path.join(here, "out/nvim");
const vscode = JSON.parse(fs.readFileSync(path.join(here, "out/vscode", `${sample}.json`), "utf8"));
const nvim = JSON.parse(fs.readFileSync(path.join(nvimDir, `${sample}.json`), "utf8"));

const escape = (text) =>
  text.replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;");

function renderLines(doc) {
  return doc.lines
    .map((line) =>
      line.runs
        .map((run) => {
          const style = [
            `color:${run.fg}`,
            run.b ? "font-weight:bold" : "",
            run.i ? "font-style:italic" : "",
            run.u ? "text-decoration:underline" : "",
          ]
            .filter(Boolean)
            .join(";");
          return `<span style="${style}">${escape(line.text.slice(run.s, run.e))}</span>`;
        })
        .join("") || " ",
    )
    .join("\n");
}

const html = `<!doctype html><html><head><meta charset="utf-8"><title>${escape(sample)}</title>
<style>
body{margin:0;background:#23242b;color:#a361ff;font:13px/1.45 "JetBrains Mono","Menlo",monospace}
.wrap{display:grid;grid-template-columns:1fr 1fr;gap:0}
.pane{padding:12px 16px;overflow:auto}
.pane+.pane{border-left:1px solid #1b1d20}
h2{margin:0 0 8px;font:600 12px/1 system-ui;color:#808080;text-transform:uppercase;letter-spacing:.08em}
pre{margin:0;white-space:pre}
</style></head><body><div class="wrap">
<div class="pane"><h2>VS Code</h2><pre>${renderLines(vscode)}</pre></div>
<div class="pane"><h2>Neovim</h2><pre>${renderLines(nvim)}</pre></div>
</div></body></html>`;

const outDir = path.join(here, "out/html");
fs.mkdirSync(outDir, { recursive: true });
const outPath = path.join(outDir, `${sample}.html`);
fs.writeFileSync(outPath, html);
console.log(outPath);
