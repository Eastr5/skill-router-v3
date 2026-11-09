#!/usr/bin/env python3
"""Run the golden-set eval against a router (LLM + SKILL.md prompt).

Zero-dependency: stdlib only (urllib, yaml-free — golden.yaml is parsed with a
minimal built-in reader to avoid a PyYAML requirement).

Usage:
  python evals/run_eval.py --dry-run                 # print prompts, no API calls
  python evals/run_eval.py                           # run all 30 cases
  python evals/run_eval.py --category indirect       # one category only
  python evals/run_eval.py --limit 5                 # first N cases

Env:
  ROUTER_BASE_URL   OpenAI-compatible endpoint  (default https://api.openai.com/v1)
  ROUTER_API_KEY    API key                     (required unless --dry-run)
  ROUTER_MODEL      model name                  (default gpt-4o-mini)
  HTTPS_PROXY       optional proxy for API calls

Metrics: Top-1 (primary hit), Any-hit (primary or also_ok), per category.
"""
import argparse, json, os, re, sys, time, urllib.request
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
GOLDEN = ROOT / "evals" / "golden.yaml"
SKILL = ROOT / "skills" / "skill-router" / "SKILL.md"


def parse_golden(text):
    """Minimal reader for the subset of YAML used in golden.yaml."""
    cases, cur = [], None
    for raw in text.splitlines():
        line = raw.rstrip()
        if not line or line.lstrip().startswith("#"):
            continue
        if line.startswith("  - id:"):
            cur = {"id": line.split(":", 1)[1].strip()}
            cases.append(cur)
        elif cur is not None:
            m = re.match(r"\s+([a-z_]+):\s*(.*)$", line)
            if not m:
                continue
            key, val = m.group(1), m.group(2).strip()
            if key == "category" or (key == "expected" and "[" not in val):
                cur[key] = [val] if key == "expected" else val
            elif key == "expected":
                cur[key] = [x.strip() for x in val.strip("[]").split(",") if x.strip()]
            elif key == "also_ok":
                cur[key] = [x.strip() for x in val.strip("[]").split(",") if x.strip()]
            else:
                cur[key] = val
    return cases


SYSTEM = """You are the Skill Router. Below is your capability registry (the SKILL.md).
The user gives you a task. Decide which capability from the registry should handle it.
Reply with ONE JSON object and nothing else:
{"pick": "<capability name from the registry>", "confidence": 0.0-1.0}
If no capability fits and native tools suffice, use the Tool layer name (e.g. "Read", "RunCommand", "WebFetch").
If the right move is to clarify before choosing, use {"pick": "skill-router", ...}.
If nothing fits at all, use {"pick": "none", ...}."""


def build_prompt(case):
    return f"{SYSTEM}\n\n=== SKILL.md (registry) ===\n{SKILL.read_text(encoding='utf-8')}\n\n=== USER TASK ===\n{case['query']}"


def call_api(prompt, cfg):
    body = json.dumps({
        "model": cfg["model"],
        "messages": [{"role": "user", "content": prompt}],
        "temperature": 0,
    }).encode()
    req = urllib.request.Request(
        cfg["base"].rstrip("/") + "/chat/completions", data=body,
        headers={"Content-Type": "application/json", "Authorization": f"Bearer {cfg['key']}"})
    with urllib.request.urlopen(req, timeout=120) as r:
        data = json.loads(r.read())
    return data["choices"][0]["message"]["content"]


def norm(name):
    """MCP 注册名归一化：mcp_paper-search_* -> paper-search"""
    name = name.strip()
    if name.startswith("mcp_"):
        name = name[4:]
    if name.endswith("_*"):
        name = name[:-2]
    return name


def parse_pick(text):
    m = re.search(r'\{[^{}]*"pick"\s*:\s*"([^"]+)"[^{}]*\}', text, re.S)
    return norm(m.group(1)) if m else f"<unparseable: {text[:60]!r}>"


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--dry-run", action="store_true")
    ap.add_argument("--category", choices=["direct", "paraphrase", "indirect"])
    ap.add_argument("--limit", type=int)
    args = ap.parse_args()

    cases = parse_golden(GOLDEN.read_text(encoding="utf-8"))
    if args.category:
        cases = [c for c in cases if c["category"] == args.category]
    if args.limit:
        cases = cases[: args.limit]

    cfg = {"base": os.environ.get("ROUTER_BASE_URL", "https://api.openai.com/v1"),
           "key": os.environ.get("ROUTER_API_KEY", ""),
           "model": os.environ.get("ROUTER_MODEL", "gpt-4o-mini")}
    if not args.dry_run and not cfg["key"]:
        sys.exit("需要 ROUTER_API_KEY（或用 --dry-run 检查 prompt）")

    rows, ok1 = [], 0
    for c in cases:
        prompt = build_prompt(c)
        if args.dry_run:
            print(f"--- {c['id']} [{c['category']}] ---\n{prompt[:400]}...\n")
            continue
        try:
            pick = parse_pick(call_api(prompt, cfg))
        except Exception as e:  # noqa: BLE001
            pick = f"<error: {e}>"
        expect = c["expected"] + c.get("also_ok", [])
        pick_n, exp_n = norm(pick), [norm(x) for x in c["expected"]]
        any_n = [norm(x) for x in expect]
        hit1 = pick_n in exp_n
        hit_any = pick_n in any_n
        ok1 += hit1
        rows.append((c["id"], c["category"], pick, "/".join(c["expected"]), hit1, hit_any))
        time.sleep(0.5)

    if args.dry_run:
        return
    print(f"{'id':<5}{'cat':<11}{'pick':<28}{'expected':<30}top1 any")
    for r in rows:
        print(f"{r[0]:<5}{r[1]:<11}{r[2]:<28}{r[3]:<30}{'✓' if r[4] else '·'}   {'✓' if r[5] else '·'}")
    n = len(rows)
    print(f"\nTop-1: {ok1}/{n} = {ok1 / n:.1%}    Any-hit: {sum(r[5] for r in rows)}/{n} = {sum(r[5] for r in rows) / n:.1%}")
    for cat in ("direct", "paraphrase", "indirect"):
        sub = [r for r in rows if r[1] == cat]
        if sub:
            s = sum(r[4] for r in sub)
            print(f"  {cat:<11} Top-1 {s}/{len(sub)} = {s / len(sub):.1%}")


if __name__ == "__main__":
    main()
