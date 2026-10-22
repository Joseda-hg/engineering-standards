# DOC-001 - Decisions are written down, as plain text, next to the code

**Intent.** "The difference between science and screwing around is writing it down." Conversations
do not scale and are forgotten; decisions recorded in a durable, portable format can be read
asynchronously, linked, reviewed and superseded. Standardise on plain text (Markdown in the
repository) instead of churning through proprietary tools - a Ulysses pact against tool churn.

**Enforcement.**
- Architecture Decision Records live in `docs/adr/NNNN-title.md` (template `0000-template.md`).
- `scripts/check-adrs.sh` (`just adrs`, part of `just quality`) requires the Status, Context,
  Decision and Consequences sections and a valid status (`ADR001`), proven by a negative fixture.

**Conventions.** Accepted ADRs are immutable; a changed decision gets a new ADR that supersedes the old
one. Discussions happen in threaded, asynchronous places (issues, pull requests, discussions) and
their conclusions are written back into the repository.
