// Compares out/vscode and a Neovim output directory character by character and prints the
// mismatches that known-differences.json does not explain. Exits 1 when any remain.
// Usage: node diff.mjs [nvimOutDir]
import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

const here = path.dirname(fileURLToPath(import.meta.url));
const vscodeDir = path.join(here, "out/vscode");
const nvimDir = process.argv[2] ? path.resolve(process.argv[2]) : path.join(here, "out/nvim");
const knownPath = path.join(here, "known-differences.json");
const known = fs.existsSync(knownPath) ? JSON.parse(fs.readFileSync(knownPath, "utf8")) : [];

function expand(line) {
  const cells = new Array(line.text.length);
  for (const run of line.runs) {
    const style = `${run.fg}${run.b ? " bold" : ""}${run.i ? " italic" : ""}${run.u ? " underline" : ""}`;
    for (let col = run.s; col < run.e; col++) cells[col] = style;
  }
  return cells;
}

function isKnown(row) {
  return known.some(
    (entry) =>
      (entry.sample === "*" || entry.sample === row.sample) &&
      entry.vscode === row.vscode &&
      entry.nvim === row.nvim &&
      (!entry.text || new RegExp(entry.text).test(row.text)),
  );
}

let totalCells = 0;
let mismatchedCells = 0;
const rows = [];
const excluded = [];

for (const file of fs.readdirSync(vscodeDir).sort()) {
  const vscode = JSON.parse(fs.readFileSync(path.join(vscodeDir, file), "utf8"));
  const nvimPath = path.join(nvimDir, file);
  if (!fs.existsSync(nvimPath)) {
    rows.push({ sample: vscode.sample, line: 0, text: "(missing nvim output)", vscode: "", nvim: "" });
    continue;
  }
  const nvim = JSON.parse(fs.readFileSync(nvimPath, "utf8"));
  vscode.lines.forEach((line, lineIndex) => {
    const expected = expand(line);
    const actual = expand(nvim.lines[lineIndex] ?? { text: line.text, runs: [] });
    let open = null;
    for (let col = 0; col <= line.text.length; col++) {
      totalCells += col < line.text.length ? 1 : 0;
      const differs = col < line.text.length && expected[col] !== (actual[col] ?? "(none)");
      if (differs) mismatchedCells++;
      const key = differs ? `${expected[col]}|${actual[col]}` : null;
      if (open && (!differs || open.key !== key)) {
        const row = {
          sample: vscode.sample,
          line: lineIndex + 1,
          text: line.text.slice(open.start, col),
          vscode: open.vscode,
          nvim: open.nvim,
        };
        (isKnown(row) ? excluded : rows).push(row);
        open = null;
      }
      if (differs && !open) {
        open = { key, start: col, vscode: expected[col], nvim: actual[col] ?? "(none)" };
      }
    }
  });
}

const pad = (value, width) => String(value).padEnd(width);
if (rows.length > 0) {
  console.log(pad("sample", 12) + pad("line", 5) + pad("text", 34) + pad("vscode", 26) + "nvim");
  for (const row of rows) {
    console.log(
      pad(row.sample, 12) + pad(row.line, 5) + pad(JSON.stringify(row.text).slice(0, 33), 34) +
        pad(row.vscode, 26) + row.nvim,
    );
  }
}
console.log(
  `\n${mismatchedCells} of ${totalCells} characters differ; ${rows.length} unexplained runs, ${excluded.length} known-difference runs`,
);
process.exit(rows.length > 0 ? 1 : 0);
