# AI-001 - Humans read and own every change

**Intent.** AI tools are good at language and shallow exploration and confidently wrong at specifics.
Whatever the level of assistance, a named human must be able to read, explain and take
responsibility for every line that is merged. "99% correct" code that nobody has read is not
acceptable. Assistance levels are declared, so reviewers know how closely to look.

**Assistance levels** (after No Boilerplate's draft *AI Permissions* model):

| Level | Meaning |
| --- | --- |
| `none` | No AI involvement |
| `read` | AI consulted (questions, explanations, research); the human wrote the change |
| `write` | AI generated parts of the change; the human reviewed and edited every line |
| `execute` | An agent produced the change autonomously; the human reviewed every line before merge |

**Enforcement.** Convention: the pull request template asks for the level and for the author's
confirmation that they have read and understood the full diff. AI agents follow
`agents/AGENTS.md` and never merge or publish on their own. Commits produced with an agent carry a
`Co-Authored-By` trailer.

**Not adopted.** No Boilerplate's content policy (no AI-written scripts) targets creative work; this
standard only regulates review and ownership of code.
