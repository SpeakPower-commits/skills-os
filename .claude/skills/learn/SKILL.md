---
name: learn
description: Store a validated lesson or decision in the OS knowledge base, and turn repeated lessons into skill improvements. Use for "remember this", "log this decision", "we learned", "note for next time" or "update the playbook".
argument-hint: "[the lesson or decision]"
---

# /learn: store validated lessons and decisions

OS home: `C:\Users\tom.otieno\Desktop\OS`. Outside that folder, read `AGENTS.md` and `registry/ROUTES.md` there first.

Request: $ARGUMENTS

The knowledge base lives in the OS home: `knowledge/DECISIONS.md` and `knowledge/LESSONS.md`. For bulk cleanup, hand it to the `librarian` agent.

## Method

1. **Classify.** Is it a decision (Tom chose X), a lesson (evidence showed X), or a skill change (a skill should behave differently)?
2. **Validate.** A lesson needs evidence: an outcome, a test result or Tom's explicit statement. If it has none, do not store it. Say what would validate it.
3. **Deduplicate.** Search both files first. Update an existing entry rather than adding a near-copy, and flag any entry this contradicts.
4. **Record** using the entry format at the top of the file. Use absolute dates.
5. **Compound.** If the lesson changes how an owned skill in `.claude/skills/` should work, propose the exact edit and wait for Tom's OK. If the same workflow keeps recurring, propose a new skill with `os.cmd new <name>`.

## Deliver

- What was stored, and where.
- Any contradiction found.
- Any proposed skill edit, shown as a diff.
