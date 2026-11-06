# Skills OS

One place that runs your skills, tools and agents, for you and for every agent you use.

## How an agent works here

Every task runs through the same loop, which is written into `AGENTS.md`:

1. **Observe the goal:** what you want and what "done" looks like.
2. **Observe the context:** who you are and how you work (`context/OWNER.md`), the venture involved (`portfolio/PROJECTS.md`), and past decisions and lessons (`knowledge/`).
3. **Pick the skill:** the right one out of about 310, using `registry/ROUTES.md`.
4. **Think:** the skill's method, with assumptions, risks and the metric that proves success.
5. **Act:** with the tools in `registry/TOOLS.md`. Anything that sends, posts, pays, spends credits or deletes waits for your yes.
6. **Present:** the result first, then the evidence, then what needs your decision.

## Commands and agents

| Command | Agent | Starts with | Tools |
|---|---|---|---|
| `/think` | strategist | product-management:brainstorm | firecrawl |
| `/research` | researcher | deep-research | firecrawl, apify, composio |
| `/analyze` | analyst | data:analyze | apify, composio |
| `/build` | engineer | serverless-engineering-standards | playwright, chrome-devtools, browser |
| `/campaign` | comms-director | social-media-manager | higgsfield, canva, composio |
| `/audit` | auditor | operations:risk-assessment | chrome-devtools, firecrawl, playwright |
| `/measure` | analyst | product-management:metrics-review | composio, apify |
| `/decide` | strategist | operations:risk-assessment | firecrawl |
| `/learn` | librarian | productivity:memory-management | |
| `/portfolio` | strategist | enterprise-search:knowledge-synthesis | |
| `/inbox` | chief-of-staff | inbox-triage | gmail, composio |

`registry/ROUTES.md` is always the current version of this table.

## Tools

| Tool | For | How it connects | What you do once |
|---|---|---|---|
| Apify | Scraping at scale: leads, reviews, social, prices | Hosted; registered for all projects | Sign in when it first asks (needs an Apify account) |
| Firecrawl | Websites into clean text or structured data | Hosted; registered for all projects | Sign in when it first asks (needs a Firecrawl account) |
| Higgsfield | Generating images and video | Hosted; registered for all projects | Sign in when it first asks (needs a Higgsfield account) |
| Composio | Acting in 250+ apps | Already connected on claude.ai | Connect each app inside it when an agent gives you the link |
| Chrome DevTools | Diagnosing why a page is slow or broken | Runs on this PC; registered for all projects | Nothing. Uses its own Chrome profile, not yours |
| Playwright | Driving a browser through multi-step flows | Runs on this PC; registered for all projects | Nothing. Uses its own browser profile, not yours |
| Gmail, Canva | Mail and designs | Already connected on claude.ai | Nothing |

No API keys are stored anywhere: the hosted tools use browser sign-in.

Playwright and Chrome DevTools run on a portable Node.js in `AppData\Local\Programs\nodejs`. It was installed without administrator rights, because this work PC doesn't give you any. If IT ever installs Node.js properly, you can delete that folder and remove it from your PATH.

Check tools any time with `.\os tools`.

## Daily use

Open a Claude Code session, here or in any project, and type a command. For example:

- `/inbox`
- `/campaign SpeakPower audit offer, LinkedIn, November`

Or just ask in plain words. To check on the system, open a terminal in this folder and run:

```
.\os status
```

## Help agents know you

`context/OWNER.md` is what every agent reads about you. It has gaps marked **(Tom to fill)**: your top three goals, your VIP contacts, your business mailboxes, and three emails whose tone you liked. Filling those makes `/inbox` and every draft noticeably better.

## When something changes

| You did this | Do this |
|---|---|
| Installed or updated a plugin | Nothing. It is picked up at the next session. If it is new, `/os` asks you to classify it |
| Want a new skill | `/os new skill`, or run `.\os new my-skill-name` and fill in `lab\my-skill-name\` |
| Finished a draft skill | `.\os promote my-skill-name`. It refuses until the draft is complete and has test prompts |
| A skill is obsolete | `.\os retire my-skill-name`. It moves to `archive\` and is never deleted |
| Want a new tool | Add it to `registry\tools.json`, then run `.\os tools install` |
| Learned something worth keeping | `/learn ...`. Repeated lessons become skill improvements |
| Moved this folder | `.\os rehome` |

## Backup

This folder is a Git repository, so any change here can be undone. Pushing sends your commits to a private GitHub repo, so the work survives a lost PC.

After you or an agent change anything here, open a terminal in this folder and run:

```
git add -A
git commit -m "Say what changed"
git push
```

- **Check before you commit:** `git status` lists changed files and `git diff` shows the edits.
- **Throw away an edit you haven't committed:** `git restore <file>`.
- **Undo a committed change:** find it with `git log --oneline`, then run `git revert <id>`. That adds a commit reversing it, so nothing is lost.
- **Left out on purpose:** your Claude app approvals (`.claude/settings.local.json`) and this PC's install state (`registry/.fingerprint`, `registry/installed.json`), which `.\os scan` and `.\os install` rebuild.
- **On a new PC:** clone the repo into `Desktop\OS`, then run `.\os rehome`, `.\os install` and `.\os tools install`.

## Everywhere, not just here

Commands, skills and agents are installed in your personal Claude folder, so they work in every project. The connectors are registered for every project too. Always edit in this folder: each `.\os scan` copies your changes out. `.\os uninstall` and `.\os tools remove <name>` reverse the installs.

## What is in here

| Path | What it is | Edit by hand? |
|---|---|---|
| `AGENTS.md` | The operating loop and the rules every agent follows | Yes |
| `context/OWNER.md` | Who you are, for agents | Yes, please complete it |
| `.claude/skills/` | 12 commands and your 6 skills | Yes |
| `.claude/agents/` | 8 agents | Yes |
| `registry/routes.json` | Which skills and tools each command uses | Yes |
| `registry/tools.json` | Every tool: purpose, connection, sign-in, cost, approval rules | Yes |
| `registry/SKILLS.md`, `ROUTES.md`, `TOOLS.md`, `skills.json`, `changes.log` | Generated by `os scan` | No |
| `lab/` | Draft skills, not live | Yes |
| `knowledge/` | Decisions and lessons | Via `/learn` |
| `portfolio/PROJECTS.md` | Map of your ventures | Yes, please complete it |
| `os.cmd`, `os.ps1` | The tool. Plain Windows PowerShell, nothing to install | Rarely |

## Things to know

- **Your skills now live here.** The copies of your 5 claude.ai skills fix links that pointed at `/mnt/...` paths, which don't exist on this PC. The claude.ai originals are unchanged. `inbox-triage` is new and exists only here.
- **SpeakPower pillars are settled.** As of 2026-11-06, POLSSE angles rotate through the Public Speaking pillar only, and both SpeakPower skills now say so. The claude.ai original of `speakpower-comms-strategist` still has the old wording; update it there if you use it in chat.
- **Higgsfield's connector address** comes from third-party guides plus a live check, not from Higgsfield's own documentation, which I could not find.
- **Composio's Gmail is not connected.** Your Gmail connector covers `/inbox`; connect Gmail inside Composio only if you want it as a backup.
- **Name-clash picks** in `routes.json` are provisional.
