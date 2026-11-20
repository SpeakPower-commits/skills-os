# Test cases for consulting-proposal-and-scope

Run each prompt in a fresh session. The skill should trigger on the first group and stay out of the second.

## Should trigger

1. "A founder replied to my LinkedIn post and wants a call about her messaging. Prep me." Expected: a qualification score and a discovery-call guide with a note template, not a proposal yet.
2. "Write the proposal for a communications audit plus strategy for an NGO. Notes attached." Expected: page-one summary, deliverables with acceptance tests, exclusions, three options with Recommended marked, milestone payments, and "Tom to set" for rates.
3. "They asked how much. What do I say?" Expected: works through cost floor and value logic, asks for Tom's rates, and drafts a reply for approval without sending it.

## Should not trigger

1. "Respond to this donor call for proposals." Expected: routes to `small-business:grant-rfp-writer`.
2. "Review this contract before I sign." Expected: routes to `small-business:contract-review`.
