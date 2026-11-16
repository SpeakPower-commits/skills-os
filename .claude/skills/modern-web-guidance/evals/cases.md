# Test cases for modern-web-guidance

Run each prompt in a fresh session. The skill should trigger on the first group and stay out of the second.

## Should trigger

1. "Add a confirm-before-delete popup to the requisitions page in the Procurement system." Expected: loads `serverless-engineering-standards` first, then this skill. Searches something like `"confirmation modal dialog"`, retrieves a dialog guide, and builds on the native `<dialog>` element in plain HTML and JavaScript. Ends with a "Modern Web Guidance" section naming the guide id.
2. "The Tonninyira reviews table is unreadable on phones. Sort it out." Expected: searches `"responsive data table"`, retrieves `responsive-table`, and applies it without adding a library. Names the metric.
3. "The textarea on the PAR comments form should grow as people type." Expected: searches for auto-sizing form fields, retrieves `form-fields-automatically-fit-contents`, and ships the CSS feature with the fallback the guide gives.
4. "Go through the HR PAR front end and tell me what's outdated." Expected: runs the legacy scan, checks each finding against its keep and drop notes, and reports only. Says the scan covers about a fifth of the guides. Changes no code.
5. A vague version: "Is there a lighter way to do these tooltips?" Expected: one search such as `"tooltip on hover"`, a retrieved guide, and a recommendation that states the browser-support position and asks once about the browser floor if the answer depends on it.

## Should not trigger

1. "Write the row-level security policy for the reviews table in Supabase." Expected: routes to `serverless-engineering-standards` alone. No guide search.
2. "Run an SEO audit on the SpeakPower site." Expected: routes to `searchfit-seo:seo-audit` instead.
3. "Change the heading on the Green Card page to 'Join Friends of Biodiversity'." Expected: a copy-only edit, made directly with no guide search.
4. "Draft a LinkedIn post on why accessible websites win clients." Expected: routes to `speakpower-comms-strategist` instead.
5. "The Worker that sends the weekly digest is timing out. Find out why." Expected: routes to `engineering:debug` under the standards. No guide search.

## Checks that need no fresh session

These confirm the launcher itself. Run them from the skill folder.

1. `scripts\mwg.cmd --version` prints the pinned version.
2. `scripts\mwg.cmd search "light dismiss dialog"` returns a list whose first id is `light-dismiss-a-dialog`.
3. `scripts\mwg.cmd install` prints a refusal and exits with code 2.
