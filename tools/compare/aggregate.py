#!/usr/bin/env python3
"""Groups a diff.mjs table by sample and color pair so a round's review reads in one screen."""
import collections, sys
rows = open(sys.argv[1]).read().splitlines()
agg = collections.OrderedDict()
for r in rows:
    if not r.startswith('sample.'):
        continue
    sample = r[:12].strip(); text = r[17:51].strip(); vs = r[51:77].strip(); nv = r[77:].strip()
    entry = agg.setdefault((sample, vs, nv), [0, []])
    entry[0] += 1
    if len(entry[1]) < 7:
        entry[1].append(text)
for (s, vs, nv), (n, ex) in sorted(agg.items(), key=lambda kv: (kv[0][0], -kv[1][0])):
    print(f"{s:12}{n:4}  vs={vs:22} nv={nv:22} {' '.join(ex)[:110]}")
