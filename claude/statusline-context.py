#!/usr/bin/env python3
# Reads the Claude Code statusline JSON on stdin, walks the session transcript
# backwards to the most recent main-chain assistant turn, and prints context
# window usage: "ctx 18% · 36k/200k". Silent (exit 0, no output) if anything
# is missing, so the wrapper can just append whatever it gets.
import sys, json

LIMIT = 200000

try:
    tp = json.load(sys.stdin).get("transcript_path")
    lines = open(tp).read().splitlines()
except Exception:
    sys.exit(0)

tot = 0
for line in reversed(lines):
    try:
        e = json.loads(line)
    except Exception:
        continue
    m = e.get("message")
    if isinstance(m, dict) and m.get("usage") and not e.get("isSidechain"):
        u = m["usage"]
        tot = (u.get("input_tokens", 0)
               + u.get("cache_creation_input_tokens", 0)
               + u.get("cache_read_input_tokens", 0))
        break

if not tot:
    sys.exit(0)

pct = tot * 100 // LIMIT
color = "32" if pct < 50 else ("33" if pct < 80 else "31")
sys.stdout.write("\033[01;%smctx %s%% · %sk/%sk\033[00m"
                 % (color, pct, tot // 1000, LIMIT // 1000))
