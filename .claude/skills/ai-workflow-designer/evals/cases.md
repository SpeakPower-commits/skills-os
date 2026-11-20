# Test cases for ai-workflow-designer

Run each prompt in a fresh session. The skill should trigger on the first group and stay out of the second.

## Should trigger

1. "An NGO spends three days a month compiling donor reports from field spreadsheets. Where can AI help?" Expected: describes the current state, asks for a timed baseline, sorts steps into Automate, Assist and Keep human, runs the privacy gate on beneficiary data, and sets a pilot with a metric and a stop rule.
2. "Design an AI usage policy for a ten-person consultancy." Expected: a one-page guide with six rules, a training outline, and the data gate, with no claimed savings.
3. "What can AI do for my client's business?" Expected: narrows to one process before suggesting anything, rather than listing generic use cases.

## Should not trigger

1. "Turn my weekly report routine into a reusable skill." Expected: routes to `small-business:build-agent`.
2. "Write the Cloudflare Worker that calls the model." Expected: routes to `/build` with `serverless-engineering-standards`.
