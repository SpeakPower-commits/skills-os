---
name: build
description: Plan or implement a software solution, from a new feature or system to a bug fix or architecture decision, under Tom's serverless engineering standards. Use for "build", "fix", "add a feature", "design the system", "should this use Supabase", or any code change.
argument-hint: "[what to build or fix, and where]"
---

# /build: plan or implement a software solution

OS home: `C:\Users\tom.otieno\Desktop\OS`. Outside that folder, read `AGENTS.md` and `registry/ROUTES.md` there first.

Request: $ARGUMENTS

Skills: always load `serverless-engineering-standards` first. Then use the rest of the `/build` row of `registry/ROUTES.md`. For a large build, hand it to the `engineer` agent.

## Method

1. **Pin the scope.** Is this a plan only, or implementation too? Which system and repo? What does "done" look like? Ask once if it is unclear.
2. **Choose the architecture** with the decision table in the standards. State trade-offs plainly, not as caveats.
3. **Build in small, verified steps.** A bug fix touches only the bug. A design change needs Tom's agreement first.
4. **Test.** Run it if you can. Otherwise give the exact browser steps Tom uses to confirm it works.
5. **Review** against the standards' checklist before handing back.

## Deliver

- The change itself.
- Plain-language setup instructions written for Tom months from now.
- Trade-offs made.
- What was tested and what was not.

Never commit secrets. Flag any token reachable from browser code.
