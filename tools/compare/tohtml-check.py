#!/usr/bin/env python3
"""Cross-checks the harness resolver against Neovim's own :TOhtml rendering of a sample.
Usage: python3 tohtml-check.py sample.js [nvimOutDir]   (expects out/tohtml-<sample>.html)"""
import re, json, html, sys, os
here = os.path.dirname(os.path.abspath(__file__))
sample = sys.argv[1]
nvim_dir = sys.argv[2] if len(sys.argv) > 2 else os.path.join(here, 'out/nvim')
src = open(f'{here}/out/tohtml-{sample}.html').read()
styles = {}
for m in re.finditer(r'\.([\w-]+)\s*\{([^}]*)\}', src):
    c = re.search(r'color:\s*(#[0-9a-fA-F]{6})', m.group(2))
    styles[m.group(1)] = c.group(1).lower() if c else None
body_fg = re.search(r'body\s*\{[^}]*color:\s*(#[0-9a-fA-F]{6})', src).group(1).lower()
pre = re.search(r'<pre>\n?(.*?)</pre>', src, re.S).group(1)

stack = []  # spans can cross lines, so the open-span stack persists between lines

def expand(line):
    cells = []
    for tok in re.finditer(r'<span class="([^"]+)">|</span>|([^<]+)', line):
        if tok.group(1) is not None:
            stack.append(tok.group(1))
        elif tok.group(0) == '</span>':
            stack.pop()
        else:
            fg = body_fg
            for cls in stack:
                if styles.get(cls):
                    fg = styles[cls]
            cells += [fg] * len(html.unescape(tok.group(2)))
    return cells

res = json.load(open(f'{nvim_dir}/{sample}.json'))
lines = pre.split('\n')
mism = total = 0
for i, l in enumerate(res['lines']):
    th = expand(lines[i])
    mine = [None] * len(l['text'])
    for r in l['runs']:
        for c in range(r['s'], r['e']):
            mine[c] = r['fg']
    for c, ch in enumerate(l['text']):
        if ch.isspace():
            continue
        total += 1
        if c >= len(th) or th[c] != mine[c]:
            mism += 1
            if mism <= 10:
                print(f'line {i+1} col {c} {ch!r}: tohtml={th[c] if c < len(th) else None} resolver={mine[c]}')
print(f'{sample}: {mism} of {total} non-space characters differ between :TOhtml and the resolver')
