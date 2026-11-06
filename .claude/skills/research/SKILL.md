---
name: research
description: Gather and compare external evidence on a question, with dated sources and a confidence rating. Use for market scans, competitor checks, fact-finding, comparing vendors or options, and "what's out there on X".
argument-hint: "[question or topic]"
---

# /research: gather and compare external evidence

OS home: `C:\Users\tom.otieno\Desktop\OS`. Outside that folder, read `AGENTS.md` and `registry/ROUTES.md` there first.

Request: $ARGUMENTS

Skills: the `/research` row of `registry/ROUTES.md`. For a multi-source job, hand it to the `researcher` agent.

## Method

1. **Scope.** Restate the question in one line, name the decision it feeds, and set geography and time window. Default to Uganda and East Africa when the venture is local.
2. **Pick the source.** `anthropic-skills:deep-research` for multi-source questions. `exa:search` for the open web (it needs sign-in). `enterprise-search:search` for Tom's connected tools. A competitive-brief skill for competitors.
3. **Collect.** Prefer primary sources: UBOS, World Bank, regulators, company filings. Record the publisher and date of every source.
4. **Compare.** Put the claims or options side by side against the same criteria. Where sources disagree, say so; do not average them away.
5. **Rate confidence** as high, medium or low, with the reason.

## Deliver

- The answer first.
- A comparison table.
- Sources with publisher, date and link.
- Gaps, and what would close them.

Never fill a gap with an invented figure.
