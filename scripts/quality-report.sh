#!/usr/bin/env bash
# Runs every check and writes a Markdown report with per-step results, per-fixture results and a
# rule-coverage matrix derived from the fixtures that actually ran.
#
# Usage: quality-report.sh [OUT_DIR]     (default: reports)
# Exit status is non-zero when any step failed; the report is written either way.
set -uo pipefail

repo="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
out="${1:-reports}"
mkdir -p "$out/logs"
out="$(cd "$out" && pwd)"
cd "$repo" || exit 1

declare -a step_names=() step_results=() step_seconds=()
run_step() {
  local name="$1" log="$out/logs/$2.log"; shift 2
  local start=$SECONDS rc=0
  echo "==> $name"
  "$@" >"$log" 2>&1 || rc=$?
  step_names+=("$name")
  step_seconds+=($((SECONDS - start)))
  if [[ $rc -eq 0 ]]; then step_results+=("PASS"); else step_results+=("FAIL (exit $rc, see logs/$(basename "$log"))"); fi
  echo "    ${step_results[-1]}"
}

run_step "C# positive: build, test, format" csharp-positive bash scripts/quality.sh csharp csharp/fixtures/positive/Positive.slnx
run_step "Rust positive: fmt, check, clippy, test" rust-positive bash scripts/quality.sh rust rust
run_step "Suppression scan (SUP-001)" scan bash scripts/scan-suppressions.sh --exclude '*/fixtures/negative' csharp rust scripts
run_step "ADR format (DOC-001)" adrs bash scripts/check-adrs.sh docs/adr
run_step "Negative fixtures (C#, Rust, docs)" fixtures bash scripts/verify-fixtures.sh all --tsv "$out/fixtures.tsv"

version() { "$@" 2>/dev/null | head -n1 | tr -d '\r' || echo "unavailable"; }
dotnet_sdk="$(version dotnet --version)"
rustc_v="$(cd rust && version rustc --version)"
clippy_v="$(cd rust && version cargo clippy --version)"
rustfmt_v="$(cd rust && version rustfmt --version)"
banned_v="$(sed -n 's:.*<BannedApiAnalyzersVersion[^>]*>\(.*\)</BannedApiAnalyzersVersion>.*:\1:p' csharp/EngineeringStandards.props)"
commit="$(git rev-parse --short HEAD 2>/dev/null || echo unknown)"
[[ -n "$(git status --porcelain 2>/dev/null)" ]] && commit="$commit (working tree modified)"

overall=PASS
for r in "${step_results[@]}"; do [[ "$r" == PASS ]] || overall=FAIL; done

{
  echo "# Quality report"
  echo
  echo "- Result: **$overall**"
  echo "- Generated: $(date -u '+%Y-%m-%d %H:%M UTC') on $(uname -s)"
  echo "- Commit: \`$commit\`"
  echo "- Toolchain: .NET SDK $dotnet_sdk, BannedApiAnalyzers $banned_v, $rustc_v, $clippy_v, $rustfmt_v"
  echo
  echo "## Steps"
  echo
  echo "| Step | Result | Seconds |"
  echo "| --- | --- | ---: |"
  for i in "${!step_names[@]}"; do
    echo "| ${step_names[$i]} | ${step_results[$i]} | ${step_seconds[$i]} |"
  done
  echo
  if [[ -s "$out/fixtures.tsv" ]]; then
    echo "## Negative fixtures"
    echo
    echo "Each fixture must fail with exactly the expected diagnostic codes."
    echo
    echo "| Language | Fixture | Rule | Mechanism | Expected | Actual | Result |"
    echo "| --- | --- | --- | --- | --- | --- | --- |"
    tail -n +2 "$out/fixtures.tsv" | awk -F'\t' '{ printf "| %s | `%s` | %s | %s | `%s` | `%s` | %s |\n", $1, $2, $3, $4, $5, $6, $7 }'
    echo
    echo "## Rule coverage (proven by passing negative fixtures)"
    echo
    echo "| Rule | C# | Rust |"
    echo "| --- | --- | --- |"
    for rule in $(grep -oE '^\| [A-Z]+-[0-9]+' policies/README.md | tr -d '| '); do
      cells=()
      for lang in csharp rust; do
        cell="$(awk -F'\t' -v r="$rule" -v l="$lang" '$1 == l && $3 == r && $7 == "PASS" { n[$4]++ }
          END { for (m in n) printf "%s%s (%d)", (s++ ? ", " : ""), m, n[m] }' "$out/fixtures.tsv")"
        cells+=("${cell:-convention / review only}")
      done
      echo "| $rule | ${cells[0]} | ${cells[1]} |"
    done
    echo
  fi
  echo "Logs: \`logs/\` next to this report."
} > "$out/quality-report.md"

echo "Report: $out/quality-report.md ($overall)"
[[ "$overall" == PASS ]]
