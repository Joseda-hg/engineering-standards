#!/usr/bin/env bash
# DOC-001 - check Architecture Decision Records (Markdown, one decision per file).
#
# Usage: check-adrs.sh [DIR]     (default: docs/adr)
#
# Every NNNN-title.md file except 0000-template.md must contain the sections
# "## Status", "## Context", "## Decision" and "## Consequences", and the first line after
# "## Status" must start with Proposed, Accepted, Rejected, Deprecated or Superseded.
# Findings are printed as FILE:LINE: error ADR001: MESSAGE; exit 1 when any finding exists.
set -euo pipefail

dir="${1:-docs/adr}"
findings=0
shopt -s nullglob
for file in "$dir"/[0-9][0-9][0-9][0-9]-*.md; do
  [[ "$(basename "$file")" == 0000-* ]] && continue
  out="$(awk -v f="$file" '
    /^## Status[[:space:]]*$/ { seen["Status"] = 1; want_status = 1; next }
    /^## Context[[:space:]]*$/ { seen["Context"] = 1 }
    /^## Decision[[:space:]]*$/ { seen["Decision"] = 1 }
    /^## Consequences[[:space:]]*$/ { seen["Consequences"] = 1 }
    want_status && NF {
      want_status = 0
      if ($0 !~ /^(Proposed|Accepted|Rejected|Deprecated|Superseded)/)
        printf "%s:%d: error ADR001: status must start with Proposed, Accepted, Rejected, Deprecated or Superseded\n", f, FNR
    }
    END {
      split("Status Context Decision Consequences", required, " ")
      for (i = 1; i <= 4; i++)
        if (!seen[required[i]]) printf "%s:1: error ADR001: missing section \"## %s\"\n", f, required[i]
    }
  ' "$file")"
  if [[ -n "$out" ]]; then
    printf '%s\n' "$out"
    findings=$((findings + $(printf '%s\n' "$out" | grep -c .)))
  fi
done

if [[ $findings -gt 0 ]]; then
  echo "check-adrs: $findings finding(s)" >&2
  exit 1
fi
echo "check-adrs: ADRs well-formed"
