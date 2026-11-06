---
name: decide
description: Compare options against explicit criteria and recommend one, with risks and kill criteria. Use for "should I", "which option", "X or Y", vendor or tool choices, hiring, pricing, go/no-go or build-vs-buy.
argument-hint: "[the decision and the options]"
---

# /decide: compare options and recommend one

OS home: `C:\Users\tom.otieno\Desktop\OS`. Outside that folder, read `AGENTS.md` and `registry/ROUTES.md` there first.

Request: $ARGUMENTS

Skills: the `/decide` row of `registry/ROUTES.md`. For a complex decision, hand it to the `strategist` agent.

## Method

1. **Frame.** State the decision, the deadline, who decides, and whether it can be reversed. Check `knowledge/DECISIONS.md` for earlier, related calls.
2. **Options.** At least three, including "do nothing" when it is a real option.
3. **Criteria.** Weight them. Use Tom's weights if given; otherwise state yours. Score each option with evidence.
4. **Risks.** For the leading option, list the risks and the kill criteria that would make you abandon it.
5. **Recommend one.** Say what new fact would change the recommendation.

## Deliver

- The recommendation first.
- The scoring table.
- Risks and kill criteria.
- The next step.

Once Tom decides, record it with `/learn` in `knowledge/DECISIONS.md`.
