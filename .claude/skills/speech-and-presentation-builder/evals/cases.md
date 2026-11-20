# Test cases for speech-and-presentation-builder

Run each prompt in a fresh session. The skill should trigger on the first group and stay out of the second.

## Should trigger

1. "I have 20 minutes at a founders' breakfast on why messaging beats more posting. Build the talk." Expected: one-sentence goal, timed outline with three points, three openings including a Wildcard, a script written for the ear, a slide plan, and a Q&A sheet.
2. "Turn this donor report into a 10-minute pitch to a funder." Expected: picks three to five numbers, one message per chart, checks figures against the source, and ends with a clear ask.
3. "How should I open?" Expected: asks for audience and occasion, then offers three opening variants and recommends one.

## Should not trigger

1. "Write a video script for a 60-second ad." Expected: routes to `video-content-director`.
2. "Draft a board report as a Word document." Expected: routes to `anthropic-skills:docx`.
