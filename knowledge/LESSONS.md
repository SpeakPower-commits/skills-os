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
