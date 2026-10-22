# 0001. Record architecture decisions

## Status

Accepted — 2026-10-22

## Context

Decisions about these standards (why a rule exists, why a recommendation was rejected, why a
toolchain is pinned) were scattered across commit messages and chat. Talking does not scale and is
impermanent; a decision that is not written down gets re-litigated. No Boilerplate's "Plain-Text
Team" argues for documentation-first, asynchronous teams that keep their knowledge as plain text
next to the work, citing Michael Nygard's ADR process.

## Decision

We will record each significant decision as an Architecture Decision Record in `docs/adr/`, as a
numbered Markdown file following `0000-template.md`. Records are immutable once accepted; a changed
decision gets a new record that supersedes the old one. `scripts/check-adrs.sh` (run by
`just quality`) checks the required sections and status.

## Consequences

- The reasoning behind each rule survives people and tools changing.
- Reviews can point to a record instead of repeating an argument.
- Small overhead per decision; trivial choices do not need a record.
