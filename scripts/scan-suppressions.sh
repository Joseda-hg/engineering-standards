#!/usr/bin/env bash
# SUP-001 - report suppressions that do not carry a reason and a reference.
#
# Usage: scan-suppressions.sh [--exclude GLOB]... PATH...
#
# A "reference" is a tracker or policy identifier such as PEN-0040, ISSUE-12 or STATE-001
# (regex [A-Z][A-Z0-9]+-[0-9]+). Findings are printed as
#   FILE:LINE: error SUP001: MESSAGE
# and the script exits 1 when any finding is reported.
#
# This is a line-oriented scan, not a parser: it is a CI tripwire for review, documented as such
# in docs/rule-coverage.md. Rust attribute suppressions are enforced by Clippy instead
# (allow_attributes, allow_attributes_without_reason).
set -euo pipefail

excludes=()
paths=()
while [[ $# -gt 0 ]]; do
  case "$1" in
    --exclude) excludes+=("$2"); shift 2 ;;
    -h|--help) sed -n '2,13p' "$0"; exit 0 ;;
    *) paths+=("$1"); shift ;;
  esac
done
[[ ${#paths[@]} -gt 0 ]] || paths=(.)

prune=(-name .git -o -name bin -o -name obj -o -name target -o -name node_modules)
for pattern in "${excludes[@]+"${excludes[@]}"}"; do
  prune+=(-o -path "$pattern")
done

findings=0
report() {
  if [[ -n "$1" ]]; then
    printf '%s\n' "$1"
    findings=$((findings + $(printf '%s\n' "$1" | grep -c .)))
  fi
}

ref='[A-Z][A-Z0-9]+-[0-9]+'

while IFS= read -r -d '' file; do
  case "$file" in
    *.cs)
      report "$(awk -v ref="$ref" -v f="$file" '
        function flag(msg) { printf "%s:%d: error SUP001: %s\n", f, start, msg }
        # Multi-line [SuppressMessage(...)] attributes are joined until the closing ")]".
        pending != "" {
          pending = pending " " $0
          if ($0 ~ /\)[[:space:]]*\]/) {
            if (pending !~ "Justification[[:space:]]*=[[:space:]]*\"[^\"]*" ref) flag("SuppressMessage needs Justification = \"<reason> <REF-123>\"")
            pending = ""
          }
          next
        }
        { start = FNR }
        /^[[:space:]]*#pragma[[:space:]]+warning[[:space:]]+disable/ && $0 !~ "//.*" ref {
          flag("#pragma warning disable needs a trailing // <reason> <REF-123>")
        }
        /^[[:space:]]*#nullable[[:space:]]+disable/ && $0 !~ "//.*" ref {
          flag("#nullable disable needs a trailing // <reason> <REF-123>")
        }
        /(Unconditional)?SuppressMessage(Attribute)?[[:space:]]*\(/ {
          if ($0 ~ /\)[[:space:]]*\]/) {
            if ($0 !~ "Justification[[:space:]]*=[[:space:]]*\"[^\"]*" ref) flag("SuppressMessage needs Justification = \"<reason> <REF-123>\"")
          } else {
            pending = $0
          }
        }
      ' "$file")"
      ;;
    *.editorconfig|*.globalconfig)
      report "$(awk -v ref="$ref" -v f="$file" '
        /^[[:space:]]*[#;]/ { comment = comment " " $0; next }
        tolower($0) ~ /^[[:space:]]*dotnet_(analyzer_)?diagnostic\..*severity[[:space:]]*=[[:space:]]*(none|silent|suggestion)/ {
          if (comment !~ ref) printf "%s:%d: error SUP001: severity downgrade needs a preceding comment with <reason> <REF-123>\n", f, FNR
        }
        { comment = "" }
      ' "$file")"
      ;;
    *.csproj|*.props|*.targets)
      report "$(awk -v ref="$ref" -v f="$file" '
        /<(NoWarn|WarningsNotAsErrors)>/ {
          value = $0
          sub(/.*<(NoWarn|WarningsNotAsErrors)>/, "", value)
          sub(/<\/.*/, "", value)
          gsub(/\$\((NoWarn|WarningsNotAsErrors)\)|[;,[:space:]]/, "", value)
          if (value != "" && $0 !~ "<!--.*" ref && previous !~ "<!--.*" ref)
            printf "%s:%d: error SUP001: NoWarn/WarningsNotAsErrors entry needs an XML comment with <reason> <REF-123>\n", f, FNR
        }
        { previous = $0 }
      ' "$file")"
      ;;
    */Cargo.toml|Cargo.toml)
      report "$(awk -v f="$file" '
        /^\[package\]/ { package = 1 }
        /^\[lints\]/ { in_lints = 1; next }
        /^\[lints\./ { local_lints = 1; local_line = FNR }
        /^\[/ { in_lints = 0 }
        in_lints && /^[[:space:]]*workspace[[:space:]]*=[[:space:]]*true/ { inherits = 1 }
        END {
          if (local_lints) printf "%s:%d: error SUP001: crate-local [lints.*] tables bypass the workspace lints; use [lints] workspace = true\n", f, local_line
          else if (package && !inherits) printf "%s:1: error SUP001: crate does not inherit the workspace lints ([lints] workspace = true)\n", f
        }
      ' "$file")"
      ;;
  esac
done < <(find "${paths[@]}" \( "${prune[@]}" \) -prune -o -type f \
           \( -name '*.cs' -o -name '.editorconfig' -o -name '*.globalconfig' -o -name '*.csproj' \
              -o -name '*.props' -o -name '*.targets' -o -name 'Cargo.toml' \) -print0)

if [[ $findings -gt 0 ]]; then
  echo "scan-suppressions: $findings finding(s)" >&2
  exit 1
fi
echo "scan-suppressions: no unjustified suppressions"
