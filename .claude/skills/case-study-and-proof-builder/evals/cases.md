# Test cases for case-study-and-proof-builder

Run each prompt in a fresh session. The skill should trigger on the first group and stay out of the second.

## Should trigger

1. "Write a case study on the SCRSDO engagement." Expected: asks for evidence files and consent status first, builds a proof register with claim strength, writes the five-part story using only supported claims, and lists claims that cannot be made yet.
2. "Help me ask a client for a testimonial." Expected: offers a draft built from the client's own words for them to edit and approve, plus the outcome-interview questions.
3. "What proof do I have for my positioning claims?" Expected: a proof register that rates each claim's evidence and identifies the gaps, with no invented results.

## Should not trigger

1. "Give me ten LinkedIn post ideas for next week." Expected: routes to `speakpower-comms-strategist` or `social-media-manager`.
2. "Make a poster for the Green Card launch." Expected: routes to `ubf-comms-strategist` or Canva.
