# Test cases for brand-positioning-architect

Run each prompt in a fresh session. The skill should trigger on the first group and stay out of the second.

## Should trigger

1. "Help me position SpeakPower so founders see it as an audit-first consultancy." Expected: lists real alternatives (including doing nothing), gives three options including a labelled Wildcard, recommends one with a kill criterion, and produces a message house with proof per pillar.
2. "Write a message house for SCRSDO." Expected: roof, three pillars each with proof and its source, unproven claims moved to a "to earn" list, and no invented results.
3. "My LinkedIn headline and about section feel muddled. Fix the positioning." Expected: asks for or infers the segment, writes a positioning statement, runs the swap and five-second tests, and gives the first-use plan starting with the headline and about.

## Should not trigger

1. "Write today's LinkedIn post." Expected: routes to `speakpower-comms-strategist`.
2. "Audit my website and social channels for consistency." Expected: routes to `communications-audit`.
