# Monthly Rolex Festival: proposal and plan

Draft, never live. Built 20 November 2026 from a chat a friend shared (recipes, one house sauce, combo pricing), checked against KCCA's own events checklist.

## Files

| File | What it is |
|---|---|
| `monthly-rolex-festival-proposal-and-plan.docx` | The Word document for the team. A4, 12 pages: 11 short sections (at a glance, decisions needed, menu and prices, budget, action plan, do and don't, roles, Kampala permits, risks, success measures, a Wildcard idea) and three appendices (recipes, shopping list for 100 Rolexes, sources and what is unchecked). |
| `monthly-rolex-festival-proposal-and-plan.pdf` | The same document exported by Microsoft Word, for sharing on WhatsApp. |
| `src/build-docx.js` | Builds the Word file. Needs the `docx` package: run `npm install docx --ignore-scripts` in an empty folder, set `NODE_PATH` to that folder's `node_modules`, then `node build-docx.js`. |
| `src/export-pdf.ps1` | Exports the PDF and a PNG of each page. Must run in 32-bit PowerShell (`%WINDIR%\SysWOW64\WindowsPowerShell\v1.0\powershell.exe`), because 64-bit PowerShell resolves Word automation to WPS Office. |

## What the team still has to supply (the yellow items in the document)

- Festival date and venue, expected crowd, and the total budget. None of these were in the research.
- A name for each role.
- Real costs: the test run replaces the UGX 5,000 to 6,000 per Rolex that the chat assumed.

## What was and was not checked

- **Checked:** KCCA events checklist (13 items, apply 14 working days before the event) and the text of the Public Order Management Act 2013, both read on 20 November 2026.
- **Not verified:** the Kampala Rolex prices in the chat, the UGX 5,000 to 6,000 cost, and the recipes. The chat's "UGX 48,000 to 51,000 if sold separately" does not add up from the prices it quotes (they total 55,000).
- **Not checked:** music licensing (UPRS) and tax. Both are flagged in the document.
- The assumption that this is a Rolex-led food festival comes from the pasted research. Confirm it.
