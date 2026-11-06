# Lessons

Validated lessons, newest first. Written by `/learn`. A lesson needs evidence: an outcome, a test or Tom's explicit statement. When a lesson changes how a skill should work, the skill gets updated and the entry says so.

Entry format:

```
## YYYY-MM-DD: short title
- Venture: which one, or "all"
- Lesson: what is now known
- Evidence: what proved it
- Applied to: skill or process updated, or "not yet"
```

## 2026-11-06: First live /inbox run: the OS boots and routes correctly
- Venture: all
- Lesson: In a fresh desktop session the boot chain works end to end.
  - The SessionStart hook printed "Skills OS online", and the four CLAUDE.md imports were in context.
  - `/inbox` and `inbox-triage` loaded through the Skill tool from `~/.claude/skills`, with full descriptions in the listing. `chief-of-staff` was listed.
  - `os status` reported 9 of 9 tools ready. Playwright and chrome-devtools connected within the first minute, so no further restart was needed.
  - The Gmail connector searched, read threads, and listed labels and drafts.
- Evidence: Live run on 2026-11-06.
- Applied to: nothing needed.

## 2026-11-06: Two weeks of Tom's Gmail held no correspondence, and the decisions sat in service notices
- Venture: all
- Lesson:
  - Mail for every venture arrives in thomasotieno583@gmail.com, so an empty result is real, not a routing gap. All 181 inbox threads from 23 Oct to 6 Nov were automated, and the newest sent mail is from 12 Sep 2026.
  - Every decision in the run came from a service notice:
    - a Supabase project still paused;
    - Canva Pro cancelled ten days after a $15 charge;
    - a Google sign-in to an app outside Tom's Supabase organisation.
  - The skill's bucket table files notifications under Handled. Scan them for pauses, cancellations, charges and new sign-ins before counting them.
  - The digest's closing question ("which drafts to save or send") had nothing to ask. A run with no drafts should close on the top decision instead.
- Evidence:
  - Gmail connector, 2026-11-06. The newest `in:sent` thread is from 2026-09-12.
  - None of the 181 inbox threads since 23 Oct came from a person, and neither did anything in spam or archived mail.
  - Tom's statement, recorded in OWNER.md on 2026-11-06, that all venture mail arrives in this Gmail.
- Applied to: `inbox-triage` 1.1.0, with Tom's OK on 2026-11-06. Step 4 now scans service notices, and step 6 now covers a run with no drafts.

## 2026-11-06: Check a system alert against the live system before ranking it
- Venture: UBF/FoB
- Lesson: Alert emails go stale in both directions.
  - The 2 Nov email "Friends-of-Biodiversity has been paused" was already resolved: the project is ACTIVE_HEALTHY.
  - UBF-Procurement-System has had no email since July, yet it is still paused. The 90-day unpause window in Supabase's 11 Jul email ended around 9 Oct.
  - One read-only connector call reversed the ranking.
- Evidence: Supabase connector `list_projects`, plus Supabase's emails of 11 Jul and 2 Nov 2026.
- Applied to: `inbox-triage` 1.1.0, step 4, with Tom's OK on 2026-11-06.

## 2026-11-06: The os command is not reachable the way the docs say
- Venture: all
- Lesson:
  - Neither `os` nor `os.cmd` is on PATH. Agent shells also set `NoDefaultCurrentDirectoryInExePath=1`, so `cmd /c os.cmd` fails even inside the OS folder.
  - The hook says `os find <words>` and AGENTS.md says `os.cmd ...`. Only `.\os.cmd` inside the OS folder, or the full path, actually runs. From any other project, no form in the docs works.
- Evidence: 2026-11-06. `cmd /c "os.cmd status"` returned "not recognized", `Get-Command os, os.cmd` found nothing, and `.\os.cmd status` ran.
- Applied to: AGENTS.md and the boot message in `os.ps1`, with Tom's OK on 2026-11-06.
  - AGENTS.md now has an `OS home:` line and the run forms the agents already use.
  - The boot message now prints the full path.
  - `os rehome` and `os check` now cover AGENTS.md.

## 2026-11-06: os scan can mark working Node tools as not ready
- Venture: all
- Lesson:
  - `Test-Requirement 'node'` in `os.ps1` only checks whether `npx` is on the PATH of the process running the scan.
  - A scan run where Node isn't on PATH writes "set up, but needs node to run" into TOOLS.md, even when the servers work.
  - Sessions in the OS folder import TOOLS.md through CLAUDE.md, so a wrong status there steers agents away from playwright and chrome-devtools.
- Evidence: 2026-11-06.
  - TOOLS.md in snapshot commit `fbef39e`, regenerated at 13:04, gives that status for both tools.
  - In this session, `.\os.cmd tools` reported both as "set up; no sign-in needed", and `npx` resolved to `C:\Users\tom.otieno\AppData\Local\Programs\nodejs\npx.ps1`.
  - Both MCP servers loaded their tools.
- Applied to: `Test-Requirement` in `os.ps1`, with Tom's OK on 2026-11-06.
  - It now also reads the saved user and machine PATH, which is where `cmd /c npx` resolves in a freshly started app.
  - With Node removed from the process PATH, `os tools` still reported both tools ready.
  - TOOLS.md was regenerated and shows them as ready.

## 2026-11-06: Gmail connector: page by date, not by category
- Venture: all
- Lesson:
  - `category:` filters were applied unreliably. `category:primary` returned Updates-tab threads, while `-category:primary` returned 3.
  - Date windows (`after:`/`before:`) with `pageSize` 50 were complete, and `THREAD_VIEW_IDS_ONLY` gives exact counts cheaply.
  - A 50-thread summary page can exceed the tool-output limit, in which case it is saved to a file. PowerShell `ConvertFrom-Json` parses it; this PC has no jq or Python.
  - The connector withholds automated Anthropic account emails (sign-in links) and returns them as empty threads. Count them; don't chase them.
  - Two Gmail servers load in sessions: the claude.ai connector, which also has send, forward and trash tools, and the small-business plugin's server, which has no send tool. tools.json doesn't say which one `gmail` means.
- Evidence: Live run on 2026-11-06.
- Applied to: `inbox-triage` 1.1.0 step 3, and the `auth` field of the `gmail` entry in `registry/tools.json`, with Tom's OK on 2026-11-06.

## 2026-11-06: The venture map misses the repos that send most of Tom's mail
- Venture: all
- Lesson:
  - Most mail comes from GitHub repos under the `SpeakPower-commits` account: SpeakPower, Kampala-School-Portal, claude-central-agent (GRIOT) and Friends-of-Biodiversity.
  - PROJECTS.md lists neither Kampala-School-Portal nor claude-central-agent, and it calls CuePointe Tom's GitHub organisation.
  - PROJECTS.md also says UBF Procurement runs flat-file on GitHub, yet a Supabase project "UBF-Procurement-System" exists.
  - Triage could not tag Kampala-School-Portal to a venture.
- Evidence: GitHub notification senders and Supabase `list_projects` on 2026-11-06, compared with `portfolio/PROJECTS.md`.
- Applied to: not yet. Needs Tom to say which venture each repo belongs to.

## 2026-11-06: This PC needs user-folder installs
- Venture: all
- Lesson:
  - Tom's PC is domain-joined, and he is a standard user. Installers that need administrator rights (MSI, winget machine scope) fail at the Windows prompt.
  - Portable tools unpacked into his user folder do run; company policy did not block `node.exe` there.
- Evidence: On 2026-11-06, the winget install of Node.js failed with installer code 1602, and `whoami /groups` showed no Administrators membership. The portable `node.exe --version` then ran.
- Applied to: `context/OWNER.md`. For future tools, prefer hosted MCP servers first, portable installs second, and ask IT third.

## 2026-11-06: Test MCP servers with the Claude CLI, not a homemade client
- Venture: all
- Lesson: To check whether an MCP server works, run `claude mcp list`. It uses the same client code as real sessions. A hand-written PowerShell 5.1 stdio client got no replies from servers that were in fact healthy.
- Evidence: On 2026-11-06, the PowerShell handshake timed out for both local servers, while `claude mcp list` showed both Connected.
- Applied to: not yet. A future `os tools test` could wrap `claude mcp list`.

## 2026-11-05: Agents cannot see most skill descriptions
- Venture: all
- Lesson: With about 300 skills installed, the skill listing that agents receive shows most skills as a bare name with no description. This included Tom's own `ubf-comms-strategist`, `video-content-director` and `serverless-engineering-standards`. Agents therefore cannot reliably pick the right skill from the listing alone.
- Evidence: Observed in the session listing on 2026-11-05. The Claude Code docs cap the listing at about 1% of the context window.
- Applied to: the OS routing in `registry/ROUTES.md` and the `os.cmd find` search.

## 2026-11-05: Owned skills pointed at paths that do not exist here
- Venture: all
- Lesson: `social-media-manager` and `video-content-director` loaded other skills from `/mnt/skills/user/...`, a sandbox path that does not exist on this machine. `social-media-manager` also said SpeakPower had no dedicated skill, although `speakpower-comms-strategist` exists.
- Evidence: Read both files on 2026-11-05.
- Applied to: the OS copies in `.claude/skills/`, which now refer to skills by name. `os.cmd check` now flags sandbox paths. The claude.ai originals are unchanged.
