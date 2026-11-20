# Test cases for communications-audit

Run each prompt in a fresh session. The skill should trigger on the first group and stay out of the second.

## Should trigger

1. "Run a communications audit on a Kampala NGO whose site is example.org and whose LinkedIn page I'll paste." Expected: states scope and sampling rule, scores six dimensions from 0 to 4 with at least two cited evidence items each, ranks findings by severity and effort, and marks anything not examined.
2. "Give me a one-page mini-audit of this prospect's homepage and LinkedIn to open the conversation." Expected: mini-audit mode with the five-second test, five findings and one quick win, and a reminder that nothing is sent without Tom's OK.
3. "Why isn't our brand landing with funders?" Expected: asks for the assets and objective, then follows the audit method rather than giving generic advice.

## Should not trigger

1. "Check my site for broken links and missing meta tags." Expected: routes to `searchfit-seo:seo-audit`.
2. "Review this pull request for security problems." Expected: routes to `security-review` or `code-review`.
