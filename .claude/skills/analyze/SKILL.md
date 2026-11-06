---
name: analyze
description: Inspect project data such as spreadsheets, exports, databases or connector data to find what is actually going on. Use for "look at this data", "what does this sheet tell us", trends, anomalies, segment breakdowns or data quality checks.
argument-hint: "[data source and question]"
---

# /analyze: inspect project data

OS home: `C:\Users\tom.otieno\Desktop\OS`. Outside that folder, read `AGENTS.md` and `registry/ROUTES.md` there first.

Request: $ARGUMENTS

Skills: the `/analyze` row of `registry/ROUTES.md`. For a large dataset, hand it to the `analyst` agent.

## Method

1. **Locate and understand.** Name the file, sheet, table or connector. Confirm what each field means before drawing conclusions from it.
2. **Validate first.** Check row counts, missing values, duplicates, date ranges and units. Report problems before analysing around them.
3. **Hypothesis.** State what you expect to find and what result would disprove it.
4. **Analyse.** Use the routed data skill. Show the formula, query or method used, so Tom can rerun it.
5. **Separate vanity metrics from business metrics.** Followers and views are not leads, revenue or retention.

## Deliver

- Findings ranked by impact. Each gives the number, how it was computed and its main caveat.
- A chart only where it makes the point faster than a table.
- The next question worth asking.

Keep data on this machine unless Tom approves sending it somewhere.
