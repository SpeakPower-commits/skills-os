---
name: inbox
description: Turn Tom's email into decisions, ready drafts and handoffs, sorted by venture and ranked by consequence. Use for "check my email", "what needs me", "triage my inbox", "catch me up on mail", or a single forwarded email.
argument-hint: "[optional: time window, venture or sender]"
---

# /inbox: turn email into decisions

OS home: `C:\Users\tom.otieno\Desktop\OS`. If you are not working inside that folder, first read `AGENTS.md`, `context/OWNER.md` and `registry/ROUTES.md` there.

Request: $ARGUMENTS

Follow the `inbox-triage` skill and run the operating loop in `AGENTS.md`.

- **Tools:** use the Gmail connector first, then Composio for other mailboxes. If neither works, use text Tom pastes.
- **Large backlogs:** hand them to the `chief-of-staff` agent.

**Hard rule:** draft freely, but send, archive, label, unsubscribe or delete nothing without Tom's explicit yes.
