# Decisions

Decisions Tom has made, newest first. Written by `/learn`. One entry per decision; update an entry rather than adding a near-copy.

Entry format:

```
## YYYY-MM-DD: short title
- Venture: which one, or "all"
- Decision: what was chosen
- Over: the alternatives considered
- Why: the reason, with evidence
- Revisit if: what would reopen it
```

## 2026-11-06: Back up the Skills OS to a private GitHub repo
- Venture: all
- Decision: Keep `Desktop\OS` under Git and push it to the private repo `github.com/SpeakPower-commits/skills-os`, on Tom's personal account (formerly `cuepointe`). Commits use a repo-local identity: Tom Otieno with his Gmail. `.gitignore` keeps out machine-local state: `.claude/settings.local.json`, `registry/.fingerprint`, `registry/installed.json` and session worktrees. The generated registry files stay in, for their history.
- Over: A repo under the CuePointe organisation named in the brief; organisation members can see private repos, and `cuepointe` turned out to be Tom's own account, now renamed. OneDrive, which is the UBF work account. Git on this PC only, which would be lost with the PC.
- Why: The Desktop isn't synced, and agent edits to skills need to be undoable. Tom chose the private personal repo and the commit identity himself on 2026-11-06.
- Outcome: The first push was on 2026-11-06. Local and GitHub `main` matched at `ebb6245`, a logged-out check after the push returned 404 (private), and a credential scan of everything pushed was clean. The repo was first created public, and the push waited until Tom made it private.
- How to use: After changes, run `git add -A`, `git commit -m "what changed"` and `git push` in the folder, as the README's "Backup" section says. Confirm a remote is private before the first push to it.
- Revisit if: the repo stops being private, or the OS moves to a synced drive.

## 2026-11-06: POLSSE angles belong to one SpeakPower pillar
- Venture: SpeakPower
- Decision: POLSSE sub-angles (Politics, Law, Security, Socioeconomics and related) rotate through the Public Speaking / Storytelling pillar only.
- Over: Applying POLSSE angles across all four pillars, which `speakpower-comms-strategist` used to say.
- Why: Tom's own call, made in the OS interview. It matches `social-media-manager`.
- Applied to: the OS copy of `speakpower-comms-strategist`. The claude.ai original still says "each with POLSSE sub-angles".
- Revisit if: the content calendar starts using POLSSE elsewhere.

## 2026-11-06: Install Node.js for local agent tools
- Venture: all
- Decision: Install Node.js LTS on this PC so the Playwright and Chrome DevTools MCP servers can run for agents.
- Over: Keeping the PC install-free and relying on the Claude app's built-in browser for browser automation and page diagnosis.
- Why: Tom asked for both tools, and both need Node. His standard against local installs covers how his production systems are built and deployed (browser-only). It does not cover agent tooling, so his deliverables stay browser-buildable.
- Revisit if: Node causes maintenance trouble, or hosted versions of both tools appear.
- Outcome:
  - The standard install failed because it needs administrator rights, which Tom's account doesn't have.
  - Tom then chose a portable install. Node.js 26.13.0 now sits in `%LOCALAPPDATA%\Programs\nodejs` and is on his user PATH. Its hash was verified against nodejs.org's SHASUMS256.
  - Both servers show "Connected" in `claude mcp list`.

## 2026-09-23: Ten operating commands
- Venture: all
- Decision: The OS interface is `/think`, `/research`, `/analyze`, `/build`, `/campaign`, `/audit`, `/measure`, `/decide`, `/learn` and `/portfolio`.
- Over: not recorded
- Why: Tom's own spec, `Desktop\Initial Operating Command.docx` (dated 2026-09-23).
- Revisit if: a recurring request has no command that fits.
