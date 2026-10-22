#!/usr/bin/env bash
# Self-test for this repository: every negative fixture must FAIL with exactly the diagnostics
# listed in its expected.txt - same codes, same number of distinct locations, nothing else.
#
# Usage: verify-fixtures.sh [csharp|rust|docs|all] [--tsv FILE]
#
# expected.txt format:
#   # rule: ASY-001            (several IDs allowed when one fixture proves several rules)
#   # mechanism: compiler | analyzer | msbuild-guard | formatter | scan
#   # summary: one line
#   CODE [COUNT]    one line per diagnostic code; COUNT = distinct locations (default 1).
#                   Counting proves every banned symbol / lint in a multi-violation fixture fires.
set -euo pipefail

repo="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
lang="all"
tsv=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    csharp|rust|docs|all) lang="$1"; shift ;;
    --tsv) tsv="$2"; shift 2 ;;
    *) echo "Usage: $0 [csharp|rust|docs|all] [--tsv FILE]" >&2; exit 2 ;;
  esac
done

export DOTNET_CLI_UI_LANGUAGE=en DOTNET_NOLOGO=1 DOTNET_CLI_TELEMETRY_OPTOUT=1
passed=0
failed=0
[[ -n "$tsv" ]] && printf 'language\tfixture\trule\tmechanism\texpected\tactual\tresult\n' > "$tsv"

meta() { sed -n "s/^# $1: //p" "$2/expected.txt"; }
# Normalised tokens: CODE for one occurrence, CODE*N for N distinct locations.
expected_codes() {
  grep -v '^#' "$1/expected.txt" | tr -d '\r' | sed '/^$/d' \
    | awk '{ n = ($2 == "" ? 1 : $2); print (n == 1 ? $1 : $1 "*" n) }' | sort
}
# stdin: "LOCATION CODE" lines (duplicates collapse), stdout: normalised tokens.
count_codes() {
  sed '/^$/d' | sort -u | awk '{ n[$NF]++ } END { for (c in n) print (n[c] == 1 ? c : c "*" n[c]) }' | sort
}
join() { paste -sd' ' -; }

# record LANG DIR "LOCATION CODE"-LINES EXIT_CODE
record() {
  local lang="$1" dir="$2" actual="$3" rc="$4"
  local name expected result
  name="$(basename "$dir")"
  expected="$(expected_codes "$dir" | join)"
  actual="$(printf '%s\n' "$actual" | count_codes | join)"
  if [[ "$rc" -eq 0 ]]; then
    result="FAIL (fixture passed; it must fail)"
  elif [[ "$actual" != "$expected" ]]; then
    result="FAIL (diagnostics differ)"
  else
    result="PASS"
  fi
  if [[ "$result" == PASS ]]; then passed=$((passed + 1)); else failed=$((failed + 1)); fi
  printf '%-6s %-55s %-28s %s\n' "$lang" "$name" "[$expected]" "$result"
  [[ "$result" == PASS ]] || printf '       actual: [%s] exit=%s\n' "$actual" "$rc"
  if [[ -n "$tsv" ]]; then
    printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\n' "$lang" "$name" "$(meta rule "$dir")" "$(meta mechanism "$dir")" \
      "$expected" "$actual" "$result" >> "$tsv"
  fi
}

scan_fixture() {
  local lang="$1" dir="$2" out rc=0
  out="$("$repo/scripts/scan-suppressions.sh" "$dir" 2>&1)" || rc=$?
  record "$lang" "$dir" "$(sed -nE 's/^(.*): error ([A-Z][A-Z0-9]*):.*/\1 \2/p' <<<"$out")" "$rc"
}

# Language-neutral fixtures (fixtures/negative): ADR format (DOC-001).
verify_docs() {
  local dir out rc
  for dir in "$repo"/fixtures/negative/*/; do
    dir="${dir%/}"
    rc=0
    out="$("$repo/scripts/check-adrs.sh" "$dir" 2>&1)" || rc=$?
    record docs "$dir" "$(sed -nE 's/^(.*): error ([A-Z][A-Z0-9]*):.*/\1 \2/p' <<<"$out")" "$rc"
  done
}

verify_csharp() {
  command -v dotnet >/dev/null || { echo "dotnet unavailable" >&2; exit 127; }
  local dir out rc
  for dir in "$repo"/csharp/fixtures/negative/*/; do
    dir="${dir%/}"
    if [[ "$(meta mechanism "$dir")" == scan ]]; then scan_fixture csharp "$dir"; continue; fi
    rc=0
    out="$(dotnet build "$dir/Fixture.csproj" --no-incremental -nologo -clp:NoSummary 2>&1)" || rc=$?
    # Uncoded MSBuild errors ("error :") are reported as UNCODED so they can never match.
    record csharp "$dir" "$(sed -nE 's/^ *(.*[^ ]) ?: error ([A-Z][A-Z0-9]*):.*/\1 \2/p
                                     s/^ *(.*[^ ]) ?: error :.*/\1 UNCODED/p' <<<"$out")" "$rc"
  done
}

verify_rust() {
  command -v cargo >/dev/null || { echo "cargo unavailable" >&2; exit 127; }
  command -v jq >/dev/null || { echo "jq unavailable" >&2; exit 127; }
  local dir name out rc
  check_lint_drift
  for dir in "$repo"/rust/fixtures/negative/*/; do
    dir="${dir%/}"
    name="$(basename "$dir")"
    case "$(meta mechanism "$dir")" in
      scan) scan_fixture rust "$dir"; continue ;;
      formatter)
        rc=0
        (cd "$dir" && cargo fmt -- --check) >/dev/null 2>&1 || rc=$?
        record rust "$dir" "$([[ $rc -eq 1 ]] && echo "$name rustfmt")" "$rc"
        continue ;;
    esac
    rc=0
    # Run from rust/ so rustup honours rust/rust-toolchain.toml.
    out="$(cd "$repo/rust" && cargo clippy --locked -p "neg-$name" --all-targets \
            --message-format=json -- -D warnings 2>/dev/null)" || rc=$?
    record rust "$dir" "$(jq -r 'select(.reason == "compiler-message") | .message
        | select(.level == "error" and (.message | test("^aborting due to") | not))
        | "\(.spans[0].file_name // "-"):\(.spans[0].line_start // 0):\(.spans[0].column_start // 0) \(.code.code // "UNCODED")"' \
        <<<"$out" | tr -d '\r')" "$rc"
  done
}

# rust/Cargo.toml carries a copy of workspace-lints.toml so the fixtures use the shipped lints.
check_lint_drift() {
  local strip='/^\[workspace\.lints/,$ { /^[[:space:]]*(#|$)/d; p; }'
  if diff <(sed -nE "$strip" "$repo/rust/workspace-lints.toml" | tr -d '\r') \
          <(sed -nE "$strip" "$repo/rust/Cargo.toml" | tr -d '\r') >/dev/null; then
    passed=$((passed + 1))
    printf '%-6s %-55s %-28s %s\n' rust "lint-drift (workspace-lints.toml == Cargo.toml)" "" PASS
  else
    failed=$((failed + 1))
    printf '%-6s %-55s %-28s %s\n' rust "lint-drift (workspace-lints.toml == Cargo.toml)" "" FAIL
  fi
}

# CHANGELOG.md's latest release must match EngineeringStandardsVersion (see VERSIONING.md).
check_version() {
  local changelog props
  changelog="$(grep -m1 -oE '^## \[[0-9]+\.[0-9]+\.[0-9]+\]' "$repo/CHANGELOG.md" | tr -d '#[] ')"
  props="$(sed -n 's:.*<EngineeringStandardsVersion>\(.*\)</EngineeringStandardsVersion>.*:\1:p' \
    "$repo/csharp/EngineeringStandards.props")"
  if [[ -n "$changelog" && "$changelog" == "$props" ]]; then
    passed=$((passed + 1)); printf '%-6s %-55s %-28s %s\n' all "version (CHANGELOG == props)" "[$props]" PASS
  else
    failed=$((failed + 1)); printf '%-6s %-55s %-28s %s\n' all "version (CHANGELOG == props)" "[$changelog/$props]" FAIL
  fi
}
check_version

# The baseline profile must report the same violations as warnings without failing the build.
check_baseline() {
  local lang="$1" label="$2" expected="$3" rc=0 out actual
  shift 3
  out="$("$@" 2>&1)" || rc=$?
  if [[ "$lang" == csharp ]]; then
    actual="$(sed -nE 's/^ *(.*[^ ]) ?: warning ([A-Z][A-Z0-9]*):.*/\1 \2/p' <<<"$out" | count_codes | join)"
  else
    actual="$(jq -r 'select(.reason == "compiler-message") | .message | select(.level == "warning" and .code != null)
        | "\(.spans[0].file_name):\(.spans[0].line_start):\(.spans[0].column_start) \(.code.code)"' <<<"$out" \
        | tr -d '\r' | count_codes | join)"
  fi
  if [[ $rc -eq 0 && "$actual" == "$expected" ]]; then
    passed=$((passed + 1)); printf '%-6s %-55s %-28s %s\n' "$lang" "$label" "[$expected]" PASS
  else
    failed=$((failed + 1)); printf '%-6s %-55s %-28s %s\n' "$lang" "$label" "[$expected]" FAIL
    printf '       actual warnings: [%s] exit=%s\n' "$actual" "$rc"
  fi
  if [[ -n "$tsv" ]]; then
    printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\n' "$lang" "$label" "profile" "profile" "$expected" "$actual" \
      "$([[ $rc -eq 0 && "$actual" == "$expected" ]] && echo PASS || echo FAIL)" >> "$tsv"
  fi
}

[[ "$lang" == docs || "$lang" == all ]] && verify_docs
if [[ "$lang" == csharp || "$lang" == all ]]; then
  verify_csharp
  check_baseline csharp "profile-baseline (api-001-wall-clock warns, exit 0)" "RS0030*5" \
    dotnet build "$repo/csharp/fixtures/negative/api-001-wall-clock/Fixture.csproj" --no-incremental -nologo \
    -clp:NoSummary -p:EngineeringStandardsProfile=baseline
fi
if [[ "$lang" == rust || "$lang" == all ]]; then
  verify_rust
  rust_baseline_clippy() { (cd "$repo/rust" && cargo clippy --locked -p neg-err-001-unwrap --message-format=json 2>/dev/null); }
  check_baseline rust "profile-baseline (err-001-unwrap warns, exit 0)" "clippy::unwrap_used" rust_baseline_clippy
fi

echo "negative fixtures: $passed passed, $failed failed"
[[ $failed -eq 0 ]]
