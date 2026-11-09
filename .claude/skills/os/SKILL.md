---
name: os
description: Run and maintain the Skills OS. Covers status, finding the right skill among 300+, creating, promoting or retiring skills, classifying new plugins, adding agents and installing everything for all projects. Use for "which skill does X", "add a new skill", "new plugin installed", "OS health" or "make this work everywhere".
argument-hint: "[status | find <words> | new <name> | promote <name> | retire <name> | check | install]"
---

# /os: run the Skills OS

OS home: `C:\Users\tom.otieno\Desktop\OS`. The tool is `os.cmd` in that folder. From PowerShell, run `& '<OS home>\os.cmd' <verb>`. From Git Bash, run `'<OS home>/os.cmd' <verb>`.

Request: $ARGUMENTS (default: status)

Run the matching verb, then report its output plainly. Explain any error and its fix.

| Verb | What it does |
|---|---|
| `status` | One-screen health summary |
| `scan` | Rebuild the catalog after installing or updating plugins |
| `find <words>` | Search every skill; prints id and file path |
| `check` | Validate skills, agents and routes |
| `new <name>` | Start a draft skill in `lab/` |
| `promote <name>` | Validate a draft and make it live |
| `retire <name>` | Move a live skill to `archive/` |
| `install` / `uninstall` | Make commands, skills and agents available in every project, or undo it |
| `rehome` | Fix stored paths after the folder moves |

## New skill

1. Ask Tom three things: what it does, the phrases that should trigger it, and what it outputs.
2. Run `new <name>` and write `lab/<name>/SKILL.md` following `anthropic-skills:skill-creator`. Set `metadata.domain` and `metadata.command`.
3. Fill `evals/cases.md` with prompts that should and should not trigger it.
4. Run `promote <name>`. It refuses until no TODO placeholders remain and the evals exist.

## New plugin

`scan` logs it in `registry/changes.log`, and `check` warns that it is unclassified. Add it to `plugins` in `registry/routes.json`, decide any name collisions under `canonical`, then rescan.

## New connector added outside the OS

This covers a connector (MCP server) added through the Claude Desktop config, `claude mcp add`, or a project's `.mcp.json`.

- **What scan does:** logs it in `registry/changes.log`, flags it in `check`, `tools` and the session-start message, and lists it under "Connectors not yet registered" in `TOOLS.md`. It records only the name, where it is configured, and its host or package, never keys or settings.
- **What you do:**
  1. Ask Tom what the connector is for, and what agents must not do with it.
  2. Add an entry to `registry/tools.json` with `connect: "external"` and the same name. Fill in `use_for`, `not_for`, `fallback`, `auth`, `cost` and `approval`.
  3. If a command should use it, add it to that command's `tools` in `routes.json`.
  4. Run `scan` and `check`.
- **Not wanted:** if Tom doesn't want agents using the connector at all, remove it from the config it came from rather than registering it.

## New agent

1. Create `.claude/agents/<name>.md` with `name`, `description`, an optional `skills` list (OS skill names only) and a body that follows the existing agents.
2. If it owns a command, set that command's `agent` in `routes.json`.
3. Run `check`.

## Never

- Hand-edit `registry/skills.json`, `SKILLS.md`, `ROUTES.md` or `changes.log`.
- Edit skills under `AppData\Roaming\Claude`.
- Run `install`, `uninstall` or `retire` without Tom's OK.
