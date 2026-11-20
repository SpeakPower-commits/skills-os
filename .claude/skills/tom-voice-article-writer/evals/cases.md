# Test cases for tom-voice-article-writer

Run each prompt in a fresh session. The skill should trigger on the first group and stay out of the second.

## Should trigger

1. "Write me a 1,000-word article for LinkedIn and the blog on why NGOs' messages don't match across channels, in my voice." Expected: places it (Communication Audits, Strategy pillar), asks for or finds one real data point, drafts about 1,000 words in Tom's voice, builds graphics and all formats, lists unverified claims.
2. "I want another one like the audit article, this time about speaking through data." Expected: reuses the structure of the model piece, uses a real data point, offers a Wildcard.
3. "Write an article." Expected: offers three topics with a recommended one and a Wildcard, and asks once.

## Should not trigger

1. "Draft a LinkedIn post about my audit offer." Expected: routes to `speakpower-comms-strategist`.
2. "Write the communications audit report for SCRSDO." Expected: routes to `communications-audit`.
3. "Write UBF's annual newsletter piece on the five thematic areas." Expected: routes to `ubf-comms-strategist`.

## Checks on every output

- Word count within about 20 of the target, measured by script.
- Zero em dashes and none of the listed AI tells.
- No number appears that is not sourced or flagged.
- The LinkedIn folder keeps text and images separate.
