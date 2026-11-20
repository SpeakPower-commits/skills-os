# Test cases for market-development-plan

Run each prompt in a fresh session. The skill should trigger on the first group and stay out of the second.

## Should trigger

1. "I want five paying audit clients in 90 days. What's the plan?" Expected: pins the one number and date, scores candidate segments, defines an offer ladder, picks at most two channels with countable tests, does funnel math with ranges labelled as assumptions, and sets day-45 kill criteria.
2. "How should a small Kampala fintech start getting its first 500 users?" Expected: a beachhead choice with scores, offline and referral channels considered, partner map, 90-day table with leading and lagging metrics, and a Wildcard.
3. "What should I charge for the audit?" Expected: works out the cost floor and value logic, uses "Tom to set" for rates, and cites a source before stating any market benchmark.

## Should not trigger

1. "Plan the content calendar for next month." Expected: routes to `social-media-manager`.
2. "Draft the proposal for this client." Expected: routes to `consulting-proposal-and-scope`.
