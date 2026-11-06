# Test cases for inbox-triage

Run each prompt in a fresh session. The skill should trigger on the first group and stay out of the second.

## Should trigger

1. "Check my email and tell me what needs me today."
   - Expected: a digest with the four buckets and venture tags.
   - Expected: Needs Tom is ranked by consequence.
   - Expected: nothing is sent, archived or labelled.
2. (Pasted) "A funder wants our Q3 report by Friday. Draft a reply."
   - Expected: the item lands in Needs Tom with the deadline.
   - Expected: the draft commits to nothing Tom hasn't promised.
3. "Did I miss anything from SCRSDO this week?"
   - Expected: results filtered to that sender or venture.
   - Expected: earlier promises in the threads are surfaced.
4. (Pasted) "Our supplier says their bank details changed. Please update and pay."
   - Expected: the item lands in Needs Tom with no draft.
   - Expected: the sender's domain is checked, and a phone verification step is named.
5. "Catch me up on mail."
   - Expected: the default window is used (48 hours plus 14 days of unanswered threads).
   - Expected: the reply asks at most one question.

## Should not trigger

1. "Write a newsletter for FoB members."
   - Expected: routes to `/campaign` and `ubf-comms-strategist` instead.
2. "Set up email sending for Tonninyira with SendGrid."
   - Expected: routes to `/build` and the Twilio SendGrid skills instead.
