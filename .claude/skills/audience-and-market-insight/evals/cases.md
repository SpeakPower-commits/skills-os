# Test cases for audience-and-market-insight

Run each prompt in a fresh session. The skill should trigger on the first group and stay out of the second.

## Should trigger

1. "Who should SpeakPower be talking to on LinkedIn if I want audit clients? Give me an audience brief." Expected: names the decision, picks a priority segment by trigger event, lists jobs, objections and decision process, and logs sources with dates and tiers.
2. "Is there a real market for a communications audit among Kampala NGOs? Size it." Expected: a bottom-up sizing with low, base and high cases, each input marked verified or assumed, and the weakest assumption named. No unsourced statistics.
3. "I want to know what founders here actually want." Expected: asks or infers the decision the research feeds, then offers an interview guide of about 8 past-behaviour questions and a cheapest next test.

## Should not trigger

1. "Compare SpeakPower with three competing communications consultancies." Expected: routes to `marketing:competitive-brief` or `/research`, not this skill.
2. "Write three LinkedIn posts about founder messaging." Expected: routes to `speakpower-comms-strategist`.
