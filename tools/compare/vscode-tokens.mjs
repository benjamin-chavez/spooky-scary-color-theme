// Tokenizes each sample the way VS Code does, using the theme JSON and the grammars
// bundled inside the VS Code app, and writes per-character colors to out/vscode.
import fs from "node:fs";
import path from "node:path";
import { createRequire } from "node:module";
import { fileURLToPath } from "node:url";
import { parse as parseJsonc } from "jsonc-parser";

const here = path.dirname(fileURLToPath(import.meta.url));
const require = createRequire(import.meta.url);
// Both packages are CommonJS, so load them through require for stable named exports.
const vsctm = require("vscode-textmate");
const oniguruma = require("vscode-oniguruma");
const repoRoot = path.resolve(here, "../..");
const themePath = path.join(here, "reference/Spooky Scary Color Theme-color-theme.json");
const extensionsDir =
  process.env.VSCODE_EXTENSIONS_DIR ??
  "/Applications/Visual Studio Code.app/Contents/Resources/app/extensions";
const samplesDir = path.join(here, "samples");
const outDir = path.join(here, "out/vscode");

const scopeByExtension = {
  ".js": "source.js",
  ".ts": "source.ts",
  ".tsx": "source.tsx",
  ".html": "text.html.basic",
  ".css": "source.css",
  ".json": "source.json",
  ".md": "text.html.markdown",
  ".py": "source.python",
  ".lua": "source.lua",
};

function loadGrammarIndex() {
  if (!fs.existsSync(extensionsDir)) {
    throw new Error(`VS Code extensions directory not found: ${extensionsDir}`);
  }
  const byScope = new Map();
  const injections = new Map();
  for (const extension of fs.readdirSync(extensionsDir)) {
    const packagePath = path.join(extensionsDir, extension, "package.json");
    if (!fs.existsSync(packagePath)) continue;
    const manifest = JSON.parse(fs.readFileSync(packagePath, "utf8"));
    for (const grammar of manifest.contributes?.grammars ?? []) {
      byScope.set(grammar.scopeName, path.join(extensionsDir, extension, grammar.path));
      for (const target of grammar.injectTo ?? []) {
        if (!injections.has(target)) injections.set(target, []);
        injections.get(target).push(grammar.scopeName);
      }
    }
  }
  return { byScope, injections };
}

function blendOverBackground(color, background) {
  const lower = color.toLowerCase();
  if (lower.length !== 9) return lower;
  const alpha = parseInt(lower.slice(7, 9), 16) / 255;
  const channel = (offset) => {
    const fg = parseInt(lower.slice(offset, offset + 2), 16);
    const bg = parseInt(background.slice(offset, offset + 2), 16);
    return Math.round(bg + (fg - bg) * alpha).toString(16).padStart(2, "0");
  };
  return `#${channel(1)}${channel(3)}${channel(5)}`;
}

async function createRegistry(theme, grammarIndex) {
  const wasmPath = path.join(path.dirname(require.resolve("vscode-oniguruma")), "onig.wasm");
  await oniguruma.loadWASM(fs.readFileSync(wasmPath).buffer);
  const onigLib = Promise.resolve({
    createOnigScanner: (patterns) => new oniguruma.OnigScanner(patterns),
    createOnigString: (text) => new oniguruma.OnigString(text),
  });
  return new vsctm.Registry({
    onigLib,
    theme,
    loadGrammar: async (scopeName) => {
      const grammarPath = grammarIndex.byScope.get(scopeName);
      if (!grammarPath) return null;
      return vsctm.parseRawGrammar(fs.readFileSync(grammarPath, "utf8"), grammarPath);
    },
    getInjections: (scopeName) => grammarIndex.injections.get(scopeName),
  });
}

const FONT_STYLE_MASK = 0b00000000000000000111100000000000;
const FOREGROUND_MASK = 0b00000000111111111000000000000000;
const FONT_STYLE_OFFSET = 11;
const FOREGROUND_OFFSET = 15;

function tokenizeSample(grammar, colorMap, editorBackground, editorForeground, text) {
  const lines = text.split("\n");
  if (lines.at(-1) === "") lines.pop();
  let ruleStack = vsctm.INITIAL;
  return lines.map((line) => {
    const result = grammar.tokenizeLine2(line, ruleStack);
    ruleStack = result.ruleStack;
    const runs = [];
    for (let index = 0; index < result.tokens.length; index += 2) {
      const start = result.tokens[index];
      const metadata = result.tokens[index + 1];
      const end = index + 2 < result.tokens.length ? result.tokens[index + 2] : line.length;
      if (end <= start) continue;
      const foregroundIndex = (metadata & FOREGROUND_MASK) >>> FOREGROUND_OFFSET;
      const fontStyle = (metadata & FONT_STYLE_MASK) >>> FONT_STYLE_OFFSET;
      runs.push({
        s: start,
        e: end,
        fg: blendOverBackground(colorMap[foregroundIndex] ?? editorForeground, editorBackground),
        b: (fontStyle & 2) !== 0,
        i: (fontStyle & 1) !== 0,
        u: (fontStyle & 4) !== 0,
      });
    }
    return { text: line, runs };
  });
}

// Debug mode: node vscode-tokens.mjs --scopes sample.js 12 prints each token's scope stack
// and resolved color on that line, which is how a disputed row gets settled.
async function printScopes(registry, colorMap, editorBackground, editorForeground, sample, lineNumber) {
  const scopeName = scopeByExtension[path.extname(sample)];
  const grammar = await registry.loadGrammar(scopeName);
  const lines = fs.readFileSync(path.join(samplesDir, sample), "utf8").split("\n");
  let ruleStack = vsctm.INITIAL;
  let ruleStack2 = vsctm.INITIAL;
  for (let index = 0; index < lines.length; index++) {
    const line = lines[index];
    const scoped = grammar.tokenizeLine(line, ruleStack);
    const binary = grammar.tokenizeLine2(line, ruleStack2);
    ruleStack = scoped.ruleStack;
    ruleStack2 = binary.ruleStack;
    if (index + 1 !== lineNumber) continue;
    for (const token of scoped.tokens) {
      let metadata = 0;
      for (let b = 0; b < binary.tokens.length; b += 2) {
        if (binary.tokens[b] <= token.startIndex) metadata = binary.tokens[b + 1];
      }
      const foregroundIndex = (metadata & FOREGROUND_MASK) >>> FOREGROUND_OFFSET;
      const color = blendOverBackground(colorMap[foregroundIndex] ?? editorForeground, editorBackground);
      const text = JSON.stringify(line.slice(token.startIndex, token.endIndex));
      console.log(`${color}  ${text.padEnd(24)} ${token.scopes.slice(1).join(" ")}`);
    }
  }
}

async function main() {
  const themeJson = parseJsonc(fs.readFileSync(themePath, "utf8"));
  const editorBackground = themeJson.colors["editor.background"].toLowerCase();
  const editorForeground = themeJson.colors["editor.foreground"].toLowerCase();
  const theme = {
    name: themeJson.name,
    settings: [
      { settings: { foreground: editorForeground, background: editorBackground } },
      ...themeJson.tokenColors,
    ],
  };
  const registry = await createRegistry(theme, loadGrammarIndex());
  const colorMap = registry.getColorMap();
  if (process.argv[2] === "--scopes") {
    await printScopes(registry, colorMap, editorBackground, editorForeground, process.argv[3], Number(process.argv[4]));
    return;
  }
  fs.mkdirSync(outDir, { recursive: true });

  for (const sample of fs.readdirSync(samplesDir).sort()) {
    const scopeName = scopeByExtension[path.extname(sample)];
    if (!scopeName) continue;
    const grammar = await registry.loadGrammar(scopeName);
    if (!grammar) throw new Error(`No grammar for ${scopeName}`);
    const text = fs.readFileSync(path.join(samplesDir, sample), "utf8");
    const lines = tokenizeSample(grammar, colorMap, editorBackground, editorForeground, text);
    fs.writeFileSync(path.join(outDir, `${sample}.json`), JSON.stringify({ sample, lines }));
    console.log(`vscode  ${sample}: ${lines.length} lines`);
  }
}

main().catch((error) => {
  console.error(error);
  process.exit(1);
});
