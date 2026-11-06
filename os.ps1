# os.ps1 - control tool for the Skills OS.
# Runs on stock Windows PowerShell 5.1. No Python, Node or packages needed.
# Keep this file ASCII-only: PowerShell 5.1 misreads UTF-8 without a BOM.
# Normal entry point is os.cmd, which works under any execution policy.

param(
  [Parameter(Position = 0)][string]$Verb = 'status',
  [Parameter(Position = 1, ValueFromRemainingArguments = $true)][string[]]$Rest
)

$ErrorActionPreference = 'Stop'
try { [Console]::OutputEncoding = New-Object System.Text.UTF8Encoding($false) } catch { }

$OsHome = $PSScriptRoot
$P = @{
  LiveSkills = Join-Path $OsHome '.claude\skills'
  LiveAgents = Join-Path $OsHome '.claude\agents'
  Lab        = Join-Path $OsHome 'lab'
  Template   = Join-Path $OsHome 'lab\_template'
  Archive    = Join-Path $OsHome 'archive'
  Routes     = Join-Path $OsHome 'registry\routes.json'
  Catalog    = Join-Path $OsHome 'registry\skills.json'
  SkillsMd   = Join-Path $OsHome 'registry\SKILLS.md'
  RoutesMd   = Join-Path $OsHome 'registry\ROUTES.md'
  ChangeLog  = Join-Path $OsHome 'registry\changes.log'
  Installed  = Join-Path $OsHome 'registry\installed.json'
  Fingerprint = Join-Path $OsHome 'registry\.fingerprint'
  Tools      = Join-Path $OsHome 'registry\tools.json'
  ToolsMd    = Join-Path $OsHome 'registry\TOOLS.md'
  UserConfig = Join-Path $env:USERPROFILE '.claude.json'
  UserSkills = Join-Path $env:USERPROFILE '.claude\skills'
  UserAgents = Join-Path $env:USERPROFILE '.claude\agents'
  AuthCache  = Join-Path $env:USERPROFILE '.claude\mcp-needs-auth-cache.json'
}
# Frontmatter keys accepted outside Claude Code (claude.ai uploads reject anything else).
$PortableKeys = @('name', 'description', 'license', 'compatibility', 'metadata', 'allowed-tools')

# ---------------------------------------------------------------- file helpers

function Read-Text([string]$Path) { return [IO.File]::ReadAllText($Path, [Text.Encoding]::UTF8) }

function Write-Text([string]$Path, [string]$Text) {
  $dir = Split-Path -Parent $Path
  if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Force -Path $dir | Out-Null }
  [IO.File]::WriteAllText($Path, $Text, (New-Object Text.UTF8Encoding($false)))
}

function Get-TreeStamp([string]$Dir) {
  $parts = Get-ChildItem $Dir -Recurse -File | Sort-Object FullName | ForEach-Object {
    $_.FullName.Substring($Dir.Length) + '=' + (Get-FileHash $_.FullName -Algorithm MD5).Hash
  }
  return ($parts -join ';')
}

# ---------------------------------------------------------------- frontmatter

function Get-FmScalar([string]$Raw) {
  $v = $Raw.Trim()
  if ($v.Length -ge 2 -and $v[0] -eq '"' -and $v[$v.Length - 1] -eq '"') {
    $v = $v.Substring(1, $v.Length - 2)
    $v = $v.Replace('\n', ' ').Replace('\"', '"').Replace('\\', '\')
  } elseif ($v.Length -ge 2 -and $v[0] -eq "'" -and $v[$v.Length - 1] -eq "'") {
    $v = $v.Substring(1, $v.Length - 2).Replace("''", "'")
  }
  return $v.Trim()
}

function Complete-FmEntry([string]$First, $Kids) {
  $f = $First.Trim()
  $children = @($Kids | Where-Object { $_.Trim() -ne '' })
  if ($children.Count -eq 0) {
    if ($f -match '^\[(.*)\]$') {
      $items = @($Matches[1] -split ',' | ForEach-Object { Get-FmScalar $_ } | Where-Object { $_ })
      return , $items
    }
    return (Get-FmScalar $f)
  }
  if ($f -match '^[>|][+-]?$') {
    return ((($children | ForEach-Object { $_.Trim() }) -join ' ').Trim())
  }
  if ($f -eq '') {
    if ($children[0].TrimStart().StartsWith('- ')) {
      $items = @($children | ForEach-Object { Get-FmScalar ($_.TrimStart().Substring(2)) })
      return , $items
    }
    if ($children[0] -match '^\s+[A-Za-z0-9_.-]+:') {
      $map = @{}
      foreach ($c in $children) {
        if ($c -match '^\s+([A-Za-z0-9_.-]+):\s*(.*)$') { $map[$Matches[1]] = Get-FmScalar $Matches[2] }
      }
      return $map
    }
  }
  # Multi-line plain or quoted scalar.
  return (Get-FmScalar (($f + ' ' + (($children | ForEach-Object { $_.Trim() }) -join ' ')).Trim()))
}

function ConvertFrom-Frontmatter([string]$Text) {
  $out = @{}
  $lines = $Text -split "`r?`n"
  if ($lines.Count -lt 3 -or $lines[0].Trim() -ne '---') { return $out }
  $key = $null; $first = ''; $kids = New-Object System.Collections.ArrayList
  for ($i = 1; $i -lt $lines.Count; $i++) {
    $line = $lines[$i]
    if ($line.Trim() -eq '---') { break }
    if ($line -match '^([A-Za-z0-9_-]+):\s*(.*)$') {
      if ($key) { $out[$key] = Complete-FmEntry $first $kids }
      $key = $Matches[1]; $first = $Matches[2]; $kids = New-Object System.Collections.ArrayList
    } elseif ($key) {
      [void]$kids.Add($line)
    }
  }
  if ($key) { $out[$key] = Complete-FmEntry $first $kids }
  return $out
}

function ConvertTo-List($Value) {
  if ($null -eq $Value) { return @() }
  if ($Value -is [string]) { return @($Value -split ',' | ForEach-Object { $_.Trim() } | Where-Object { $_ }) }
  return @($Value)
}

# ---------------------------------------------------------------- routes

function Get-Routes {
  if (Test-Path $P.Routes) { return (Read-Text $P.Routes | ConvertFrom-Json) }
  return (New-Object psobject -Property @{ commands = $null; plugins = $null; skill_overrides = $null; canonical = $null; builtin = @() })
}

function Get-Prop($Obj, [string]$Name) {
  if ($null -eq $Obj) { return $null }
  $hit = $Obj.PSObject.Properties[$Name]
  if ($hit) { return $hit.Value }
  return $null
}

function Get-Classification($Routes, [string]$Id, [string]$Plugin, $Fm) {
  $meta = $Fm['metadata']
  if ($meta -is [hashtable] -and $meta['domain']) {
    return @{ domain = [string]$meta['domain']; command = [string]$meta['command'] }
  }
  $o = Get-Prop $Routes.skill_overrides $Id
  if ($o) { return @{ domain = [string]$o.domain; command = [string]$o.command } }
  $pl = Get-Prop $Routes.plugins $Plugin
  if ($pl) { return @{ domain = [string]$pl.domain; command = [string]$pl.command } }
  return @{ domain = 'unclassified'; command = '' }
}

# ---------------------------------------------------------------- catalog

function New-SkillRecord($File, [string]$Plugin, [string]$Version, [string]$Origin, [string]$Kind, $Routes, [string]$Id) {
  $text = Read-Text $File
  $fm = ConvertFrom-Frontmatter $text
  $dirName = Split-Path (Split-Path $File -Parent) -Leaf
  $name = [string]$fm['name']
  if (-not $name) { $name = $dirName }
  $resolved = $Id
  if (-not $resolved) { if ($Plugin) { $resolved = "${Plugin}:$name" } else { $resolved = $name } }
  $alias = ''
  if ($Plugin -and $dirName -ne $name -and $Kind -eq 'skill') { $alias = "${Plugin}:$dirName" }
  $class = Get-Classification $Routes $resolved $Plugin $fm
  $desc = ([string]$fm['description']) -replace '\s+', ' '
  if (-not $desc) {
    # No frontmatter description: fall back to the first line of prose so search still finds it.
    $body = $text
    if ($body.StartsWith('---')) { $body = $body -replace '(?s)^---.*?\n---', '' }
    foreach ($ln in ($body -split "`r?`n")) {
      $l = $ln.Trim()
      if ($l -and -not $l.StartsWith('#') -and -not $l.StartsWith('``````')) { $desc = ($l -replace '\*\*', ''); break }
    }
    if ($desc.Length -gt 300) { $desc = $desc.Substring(0, 300) }
  }
  if ($desc.Length -gt 1536) { $desc = $desc.Substring(0, 1536) }
  return [pscustomobject]@{
    id = $resolved; name = $name; alias = $alias; plugin = $Plugin; version = $Version
    origin = $Origin; kind = $Kind; domain = $class.domain; command = $class.command
    description = $desc; path = [string]$File; supersededBy = ''
  }
}

function New-AgentRecord($File, [string]$Plugin, [string]$Origin, [string]$Id) {
  $fm = ConvertFrom-Frontmatter (Read-Text $File)
  $name = [string]$fm['name']
  if (-not $name) { $name = [IO.Path]::GetFileNameWithoutExtension($File) }
  $resolved = $Id
  if (-not $resolved) { if ($Plugin) { $resolved = "${Plugin}:$name" } else { $resolved = $name } }
  $desc = ([string]$fm['description']) -replace '\s+', ' '
  if ($desc.Length -gt 600) { $desc = $desc.Substring(0, 600) }
  return [pscustomobject]@{
    id = $resolved; name = $name; plugin = $Plugin; origin = $Origin
    description = $desc; skills = @(ConvertTo-List $fm['skills']); path = [string]$File
  }
}

function Get-PluginDirs {
  $dirs = New-Object System.Collections.ArrayList
  $rpm = Join-Path $env:APPDATA 'Claude\rpm'
  if (Test-Path $rpm) {
    Get-ChildItem $rpm -Directory -Recurse -Depth 2 -Filter 'plugin_*' -ErrorAction SilentlyContinue |
      ForEach-Object { [void]$dirs.Add($_.FullName) }
  }
  $cache = Join-Path $env:USERPROFILE '.claude\plugins\cache'
  if (Test-Path $cache) {
    Get-ChildItem $cache -Recurse -Depth 4 -Filter 'plugin.json' -ErrorAction SilentlyContinue |
      Where-Object { $_.Directory.Name -eq '.claude-plugin' } |
      ForEach-Object { [void]$dirs.Add($_.Directory.Parent.FullName) }
  }
  return $dirs
}

function Get-InstalledEntries {
  if (Test-Path $P.Installed) {
    $m = Read-Text $P.Installed | ConvertFrom-Json
    return @($m.entries)
  }
  return @()
}

function Build-Catalog {
  $routes = Get-Routes
  $commandNames = @()
  if ($routes.commands) { $commandNames = @($routes.commands.PSObject.Properties.Name) }
  $commandNames += 'os'
  $skills = New-Object System.Collections.ArrayList
  $agents = New-Object System.Collections.ArrayList
  $plugins = New-Object System.Collections.ArrayList

  # Connectors still waiting for sign-in, keyed by plugin.
  $pending = @{}
  $pendingTotal = 0
  if (Test-Path $P.AuthCache) {
    try {
      $auth = Read-Text $P.AuthCache | ConvertFrom-Json
      foreach ($k in @($auth.PSObject.Properties.Name)) {
        $pendingTotal++
        if ($k -match '^plugin:([^:]+):(.+)$') {
          if (-not $pending.ContainsKey($Matches[1])) { $pending[$Matches[1]] = New-Object System.Collections.ArrayList }
          [void]$pending[$Matches[1]].Add($Matches[2])
        }
      }
    } catch { }
  }

  # Installed plugins.
  foreach ($dir in @(Get-PluginDirs)) {
    $mf = Join-Path $dir '.claude-plugin\plugin.json'
    if (-not (Test-Path $mf)) { continue }
    $pj = Read-Text $mf | ConvertFrom-Json
    $pname = [string]$pj.name
    $pver = [string]$pj.version
    $roots = @('skills')
    foreach ($r in @($pj.skills)) {
      if ($r -is [string]) { $roots += (($r -replace '^\./', '') -replace '/', '\').TrimEnd('\') }
    }
    $direct = 0; $refs = 0; $agentCount = 0
    $files = Get-ChildItem $dir -Recurse -Filter 'SKILL.md' -File -ErrorAction SilentlyContinue |
      Where-Object { $_.FullName -notmatch '\\node_modules\\' }
    foreach ($f in @($files)) {
      $rel = $f.Directory.FullName.Substring($dir.Length).TrimStart('\')
      $parent = ''
      if ($rel -match '\\') { $parent = Split-Path $rel -Parent }
      if (($roots -contains $parent) -or ($roots -contains $rel)) {
        [void]$skills.Add((New-SkillRecord $f.FullName $pname $pver 'plugin' 'skill' $routes ''))
        $direct++
      } else {
        $refId = "$pname/" + ($rel -replace '\\', '/')
        if ($rel -eq '') { $refId = "$pname/SKILL" }
        [void]$skills.Add((New-SkillRecord $f.FullName $pname $pver 'plugin' 'reference' $routes $refId))
        $refs++
      }
    }
    # Plugin slash commands (commands/*.md) are callable just like skills.
    $cmdDir = Join-Path $dir 'commands'
    if (Test-Path $cmdDir) {
      foreach ($c in @(Get-ChildItem $cmdDir -Recurse -Filter '*.md' -File)) {
        $cid = "${pname}:$($c.BaseName)"
        if (@($skills | Where-Object { $_.id -eq $cid }).Count -gt 0) { continue }
        $rec = New-SkillRecord $c.FullName $pname $pver 'plugin' 'skill' $routes $cid
        $rec.name = $c.BaseName
        $rec.alias = ''
        [void]$skills.Add($rec)
        $direct++
      }
    }
    $agentDir = Join-Path $dir 'agents'
    if (Test-Path $agentDir) {
      foreach ($a in @(Get-ChildItem $agentDir -Recurse -Filter '*.md' -File)) {
        $aid = ''
        if ($a.Name -eq 'AGENT.md') { $aid = "${pname}:$($a.Directory.Name):AGENT" }
        elseif ($a.Directory.FullName -ne $agentDir) { continue }
        [void]$agents.Add((New-AgentRecord $a.FullName $pname 'plugin' $aid))
        $agentCount++
      }
    }
    $wait = @()
    if ($pending.ContainsKey($pname)) { $wait = @($pending[$pname]) }
    [void]$plugins.Add([pscustomobject]@{
        name = $pname; version = $pver; skills = $direct; references = $refs; agents = $agentCount
        domain = (Get-Classification $routes '' $pname @{}).domain; connectorsPending = $wait
      })
  }

  # Skills on the claude.ai account, synced by the desktop app.
  $accountRoot = Join-Path $env:APPDATA 'Claude\local-agent-mode-sessions\skills-plugin'
  $accountStamp = @{}
  if (Test-Path $accountRoot) {
    $manifests = Get-ChildItem $accountRoot -Recurse -Depth 2 -Filter 'manifest.json' -File -ErrorAction SilentlyContinue
    foreach ($m in @($manifests)) {
      $mj = Read-Text $m.FullName | ConvertFrom-Json
      $byName = @{}
      foreach ($e in @($mj.skills)) { $byName[[string]$e.name] = $e }
      $skillRoot = Join-Path $m.Directory.FullName 'skills'
      if (-not (Test-Path $skillRoot)) { continue }
      foreach ($d in @(Get-ChildItem $skillRoot -Directory)) {
        $file = Join-Path $d.FullName 'SKILL.md'
        if (-not (Test-Path $file)) { continue }
        $origin = 'anthropic'
        $e = $byName[$d.Name]
        if ($e -and [string]$e.creatorType -eq 'user') {
          $origin = 'account'
          $accountStamp[$d.Name] = [string]$e.updatedAt
        }
        [void]$skills.Add((New-SkillRecord $file 'anthropic-skills' '' $origin 'skill' $routes ''))
      }
    }
  }

  # Personal skills and agents, minus the copies this OS installed there.
  $installed = @(Get-InstalledEntries)
  if (Test-Path $P.UserSkills) {
    foreach ($d in @(Get-ChildItem $P.UserSkills -Directory)) {
      if ($installed -contains "skills/$($d.Name)") { continue }
      $file = Join-Path $d.FullName 'SKILL.md'
      if (Test-Path $file) { [void]$skills.Add((New-SkillRecord $file '' '' 'personal' 'skill' $routes '')) }
    }
  }
  if (Test-Path $P.UserAgents) {
    foreach ($a in @(Get-ChildItem $P.UserAgents -Filter '*.md' -File)) {
      if ($installed -contains "agents/$($a.Name)") { continue }
      [void]$agents.Add((New-AgentRecord $a.FullName '' 'personal' ''))
    }
  }

  # The OS itself: commands and owned skills.
  $ownedNames = @()
  if (Test-Path $P.LiveSkills) {
    foreach ($d in @(Get-ChildItem $P.LiveSkills -Directory)) {
      $file = Join-Path $d.FullName 'SKILL.md'
      if (-not (Test-Path $file)) { continue }
      if ($commandNames -contains $d.Name) {
        [void]$skills.Add((New-SkillRecord $file '' '' 'os' 'command' $routes ''))
      } else {
        [void]$skills.Add((New-SkillRecord $file '' '' 'owned' 'skill' $routes ''))
        $ownedNames += $d.Name
      }
    }
  }
  if (Test-Path $P.LiveAgents) {
    foreach ($a in @(Get-ChildItem $P.LiveAgents -Filter '*.md' -File)) {
      [void]$agents.Add((New-AgentRecord $a.FullName '' 'os' ''))
    }
  }

  # Account copies of skills the OS now owns step aside.
  foreach ($s in $skills) {
    if ($s.origin -eq 'account' -and $ownedNames -contains $s.name) { $s.supersededBy = $s.name }
  }

  # Same short name offered by more than one source.
  $collisions = [ordered]@{}
  $groups = $skills | Where-Object { $_.kind -eq 'skill' -and -not $_.supersededBy } | Group-Object name | Where-Object { $_.Count -gt 1 } | Sort-Object Name
  foreach ($g in @($groups)) {
    $collisions[$g.Name] = @($g.Group | ForEach-Object { $_.id } | Sort-Object)
  }

  $sorted = @($skills | Sort-Object domain, id)
  return [pscustomobject]@{
    generated = (Get-Date).ToString('yyyy-MM-dd HH:mm')
    home = $OsHome
    counts = [pscustomobject]@{
      skills = @($sorted | Where-Object { $_.kind -eq 'skill' -and -not $_.supersededBy }).Count
      references = @($sorted | Where-Object { $_.kind -eq 'reference' }).Count
      commands = @($sorted | Where-Object { $_.kind -eq 'command' }).Count
      owned = @($sorted | Where-Object { $_.origin -eq 'owned' }).Count
      agents = @($agents).Count
      plugins = @($plugins).Count
      connectorsPending = $pendingTotal
    }
    plugins = @($plugins | Sort-Object name)
    skills = $sorted
    agents = @($agents | Sort-Object origin, id)
    collisions = $collisions
    accountStamps = $accountStamp
  }
}

function Get-Catalog {
  if (-not (Test-Path $P.Catalog)) { Invoke-Scan -Quiet }
  return (Read-Text $P.Catalog | ConvertFrom-Json)
}

# ---------------------------------------------------------------- generated docs

function ConvertTo-Cell([string]$Text, [int]$Max) {
  $t = ($Text -replace '\s+', ' ').Replace('|', '/').Trim()
  if ($t.Length -gt $Max) {
    $cut = $t.Substring(0, $Max)
    $lastSpace = $cut.LastIndexOf(' ')
    if ($lastSpace -gt ($Max / 2)) { $cut = $cut.Substring(0, $lastSpace) }
    $t = $cut.TrimEnd(' ', ',', ';') + '...'
  }
  return $t
}

function Write-SkillsDoc($Cat) {
  $b = New-Object Text.StringBuilder
  [void]$b.AppendLine('# Skill catalog')
  [void]$b.AppendLine()
  [void]$b.AppendLine("Generated by ``os scan`` on $($Cat.generated). Do not edit: change ``registry/routes.json`` or the skill itself, then rescan.")
  [void]$b.AppendLine()
  [void]$b.AppendLine("**$($Cat.counts.skills) callable skills**, $($Cat.counts.references) reference docs, $($Cat.counts.plugins) plugins, $($Cat.counts.agents) agents.")
  foreach ($g in @($Cat.skills | Where-Object { $_.kind -eq 'skill' -and -not $_.supersededBy } | Group-Object domain | Sort-Object Name)) {
    [void]$b.AppendLine()
    [void]$b.AppendLine("## $($g.Name) ($($g.Count))")
    [void]$b.AppendLine()
    [void]$b.AppendLine('| Skill | Via | What it does |')
    [void]$b.AppendLine('|---|---|---|')
    foreach ($s in @($g.Group | Sort-Object id)) {
      $via = ''
      if ($s.command) { $via = "/$($s.command)" }
      [void]$b.AppendLine("| ``$($s.id)`` | $via | $(ConvertTo-Cell $s.description 170) |")
    }
  }
  [void]$b.AppendLine()
  [void]$b.AppendLine('## Agents')
  [void]$b.AppendLine()
  [void]$b.AppendLine('| Agent | Source | What it does |')
  [void]$b.AppendLine('|---|---|---|')
  foreach ($a in @($Cat.agents)) {
    [void]$b.AppendLine("| ``$($a.id)`` | $($a.origin) | $(ConvertTo-Cell $a.description 170) |")
  }
  [void]$b.AppendLine()
  [void]$b.AppendLine('## Plugins')
  [void]$b.AppendLine()
  [void]$b.AppendLine('| Plugin | Version | Domain | Skills | Reference docs | Agents | Connectors waiting for sign-in |')
  [void]$b.AppendLine('|---|---|---|---|---|---|---|')
  foreach ($p2 in @($Cat.plugins)) {
    $wait = @($p2.connectorsPending).Count
    [void]$b.AppendLine("| $($p2.name) | $($p2.version) | $($p2.domain) | $($p2.skills) | $($p2.references) | $($p2.agents) | $wait |")
  }
  Write-Text $P.SkillsMd $b.ToString()
}

function Write-RoutesDoc($Cat, $Routes) {
  $known = @{}
  foreach ($s in @($Cat.skills)) { $known[$s.id] = $true; if ($s.alias) { $known[$s.alias] = $true } }
  foreach ($x in @($Routes.builtin)) { if ($x) { $known[[string]$x] = $true } }
  $fmt = {
    param($ids)
    $parts = @()
    foreach ($i in @($ids)) {
      if (-not $i) { continue }
      if ($known[[string]$i]) { $parts += "``$i``" } else { $parts += "``$i`` (MISSING)" }
    }
    return ($parts -join ', ')
  }
  $b = New-Object Text.StringBuilder
  [void]$b.AppendLine('# Routes')
  [void]$b.AppendLine()
  [void]$b.AppendLine('Generated from `registry/routes.json` by `os scan`. Edit that file, not this one.')
  [void]$b.AppendLine()
  [void]$b.AppendLine('| Command | Use it to | Agent | Start with | Then, if the job calls for it | Tools |')
  [void]$b.AppendLine('|---|---|---|---|---|---|')
  if ($Routes.commands) {
    foreach ($prop in $Routes.commands.PSObject.Properties) {
      $c = $prop.Value
      $toolCell = (@($c.tools) | Where-Object { $_ } | ForEach-Object { "``$_``" }) -join ', '
      [void]$b.AppendLine("| ``/$($prop.Name)`` | $($c.intent) | ``$($c.agent)`` | $(& $fmt $c.lead) | $(& $fmt $c.also) | $toolCell |")
    }
  }
  [void]$b.AppendLine()
  [void]$b.AppendLine('## When two skills share a name, use this one')
  [void]$b.AppendLine()
  if ($Routes.canonical) {
    foreach ($prop in ($Routes.canonical.PSObject.Properties | Sort-Object Name)) {
      [void]$b.AppendLine("- **$($prop.Name)**: ``$($prop.Value.use)``. $($prop.Value.why)")
    }
  }
  Write-Text $P.RoutesMd $b.ToString()
}

# ---------------------------------------------------------------- tools

function Get-Tools {
  if (Test-Path $P.Tools) { return (Read-Text $P.Tools | ConvertFrom-Json) }
  return $null
}

# MCP servers registered for all projects in ~/.claude.json. Read only; the Claude CLI does the writing.
function Get-UserMcpNames {
  if (-not (Test-Path $P.UserConfig)) { return @() }
  try {
    $j = Read-Text $P.UserConfig | ConvertFrom-Json
    if ($j.mcpServers) { return @($j.mcpServers.PSObject.Properties.Name) }
  } catch { }
  return @()
}

function Test-Requirement([string]$Req) {
  if ($Req -eq 'node') { return [bool](Get-Command npx -ErrorAction SilentlyContinue) }
  return $true
}

function Get-ToolState([string]$Name, $Tool, $UserMcp) {
  $missing = @(@($Tool.requires) | Where-Object { $_ -and -not (Test-Requirement ([string]$_)) })
  switch ([string]$Tool.connect) {
    'claude-code' {
      if ($UserMcp -contains $Name) {
        if ($missing.Count -gt 0) { return @{ ready = $false; text = "set up, but needs $($missing -join ', ') to run" } }
        if ([string]$Tool.auth -match '^OAuth') { return @{ ready = $true; text = 'set up; sign in on first use' } }
        return @{ ready = $true; text = 'set up; no sign-in needed' }
      }
      if ($missing.Count -gt 0) { return @{ ready = $false; text = "not set up: needs $($missing -join ', ') first" } }
      return @{ ready = $false; text = 'not set up: run os tools install' }
    }
    'claudeai' { return @{ ready = $true; text = 'claude.ai connector' } }
    'builtin' { return @{ ready = $true; text = 'built into the Claude app' } }
  }
  return @{ ready = $false; text = "unknown connect method '$($Tool.connect)'" }
}

function Get-ToolsNotReady {
  $tools = Get-Tools
  if (-not $tools) { return @() }
  $userMcp = @(Get-UserMcpNames)
  $out = @()
  foreach ($prop in $tools.tools.PSObject.Properties) {
    if (-not (Get-ToolState $prop.Name $prop.Value $userMcp).ready) { $out += $prop.Name }
  }
  return $out
}

function Find-ClaudeCli {
  $c = Get-Command claude -ErrorAction SilentlyContinue
  if ($c) { return $c.Source }
  $root = Join-Path $env:APPDATA 'Claude\claude-code'
  if (-not (Test-Path $root)) { return $null }
  $best = $null; $bestVer = [version]'0.0'
  foreach ($exe in @(Get-ChildItem $root -Recurse -Depth 2 -Filter 'claude.exe' -File -ErrorAction SilentlyContinue)) {
    $v = [version]'0.0'
    if ([version]::TryParse($exe.Directory.Parent.Name, [ref]$v) -and $v -gt $bestVer) { $best = $exe.FullName; $bestVer = $v }
  }
  return $best
}

function Write-ToolsDoc($Routes) {
  $tools = Get-Tools
  if (-not $tools) { return }
  $userMcp = @(Get-UserMcpNames)
  $usedBy = @{}
  if ($Routes.commands) {
    foreach ($prop in $Routes.commands.PSObject.Properties) {
      foreach ($t in @($prop.Value.tools)) {
        if (-not $t) { continue }
        if (-not $usedBy.ContainsKey([string]$t)) { $usedBy[[string]$t] = New-Object System.Collections.ArrayList }
        [void]$usedBy[[string]$t].Add("/$($prop.Name)")
      }
    }
  }
  $b = New-Object Text.StringBuilder
  [void]$b.AppendLine('# Tools')
  [void]$b.AppendLine()
  [void]$b.AppendLine('Generated from `registry/tools.json` by `os scan`; status is as of the last scan. Before relying on a tool, confirm its tools are loaded in your session. If they are not, say so and use the fallback.')
  [void]$b.AppendLine()
  [void]$b.AppendLine('| Tool | Use it for | Not for | If unavailable | Status | Used by |')
  [void]$b.AppendLine('|---|---|---|---|---|---|')
  foreach ($prop in $tools.tools.PSObject.Properties) {
    $t = $prop.Value
    $state = Get-ToolState $prop.Name $t $userMcp
    $users = ''
    if ($usedBy.ContainsKey($prop.Name)) { $users = (@($usedBy[$prop.Name]) -join ', ') }
    [void]$b.AppendLine("| ``$($prop.Name)`` | $(ConvertTo-Cell ([string]$t.use_for) 150) | $(ConvertTo-Cell ([string]$t.not_for) 90) | $(ConvertTo-Cell ([string]$t.fallback) 70) | $($state.text) | $users |")
  }
  [void]$b.AppendLine()
  [void]$b.AppendLine('Sign-in, costs and approval rules for each tool are in `registry/tools.json`. Live status: `os.cmd tools`.')
  Write-Text $P.ToolsMd $b.ToString()
}

function Invoke-ClaudeCli([string]$Cli, [string[]]$CliArgs) {
  # Native stderr must not turn into a terminating error under Stop.
  $prev = $ErrorActionPreference
  $ErrorActionPreference = 'Continue'
  try { $out = & $Cli @CliArgs 2>&1 } finally { $ErrorActionPreference = $prev }
  return ((($out | ForEach-Object { "$_" }) -join ' ') -replace '\s+', ' ').Trim()
}

function Invoke-Tools([string[]]$Words) {
  $sub = 'status'
  if ($Words -and @($Words).Count -gt 0) { $sub = ([string]$Words[0]).ToLower() }
  $tools = Get-Tools
  if (-not $tools) { throw 'registry/tools.json is missing.' }
  $userMcp = @(Get-UserMcpNames)
  if ($sub -eq 'status') {
    foreach ($prop in $tools.tools.PSObject.Properties) {
      $state = Get-ToolState $prop.Name $prop.Value $userMcp
      Write-Output ('{0,-16} {1}' -f $prop.Name, $state.text)
    }
    return
  }
  $cli = Find-ClaudeCli
  if (-not $cli) { throw 'Could not find the Claude Code program on this PC.' }
  if ($sub -eq 'install') {
    foreach ($prop in $tools.tools.PSObject.Properties) {
      $t = $prop.Value
      if ([string]$t.connect -ne 'claude-code') { continue }
      if ($userMcp -contains $prop.Name) { Write-Output "$($prop.Name): already set up"; continue }
      $missing = @(@($t.requires) | Where-Object { $_ -and -not (Test-Requirement ([string]$_)) })
      if ($missing.Count -gt 0) { Write-Output "$($prop.Name): skipped, needs $($missing -join ', ')"; continue }
      # PowerShell 5.1 strips bare double quotes from native arguments, so escape them.
      $json = ($t.server | ConvertTo-Json -Compress -Depth 5).Replace('"', '\"')
      Write-Output "$($prop.Name): $(Invoke-ClaudeCli $cli @('mcp', 'add-json', '--scope', 'user', $prop.Name, $json))"
    }
    Invoke-Scan -Quiet
    Write-Output 'New tools load in new sessions. Sign in to each one when it first asks, or with /mcp.'
    return
  }
  if ($sub -eq 'remove') {
    $name = ''
    if (@($Words).Count -gt 1) { $name = [string]$Words[1] }
    $t = Get-Prop $tools.tools $name
    if (-not $t -or [string]$t.connect -ne 'claude-code') { throw "'$name' is not a tool this OS sets up." }
    Write-Output (Invoke-ClaudeCli $cli @('mcp', 'remove', '--scope', 'user', $name))
    Invoke-Scan -Quiet
    return
  }
  throw "Unknown: os tools $sub. Use: os tools, os tools install, os tools remove <name>."
}

# ---------------------------------------------------------------- scan

function Write-Changes($Old, $New) {
  $lines = New-Object System.Collections.ArrayList
  $stamp = (Get-Date).ToString('yyyy-MM-dd HH:mm')
  if ($null -eq $Old) {
    [void]$lines.Add("$stamp  first scan: $($New.counts.skills) skills, $($New.counts.plugins) plugins, $($New.counts.agents) agents")
  } else {
    $oldIds = @($Old.skills | Where-Object { $_.kind -ne 'reference' } | ForEach-Object { $_.id })
    $newIds = @($New.skills | Where-Object { $_.kind -ne 'reference' } | ForEach-Object { $_.id })
    foreach ($i in $newIds) { if ($oldIds -notcontains $i) { [void]$lines.Add("$stamp  + skill   $i") } }
    foreach ($i in $oldIds) { if ($newIds -notcontains $i) { [void]$lines.Add("$stamp  - skill   $i") } }
    $oldPlugins = @{}
    foreach ($x in @($Old.plugins)) { $oldPlugins[[string]$x.name] = [string]$x.version }
    foreach ($x in @($New.plugins)) {
      $was = $oldPlugins[[string]$x.name]
      if ($null -eq $was) { [void]$lines.Add("$stamp  + plugin  $($x.name) $($x.version)") }
      elseif ($was -ne [string]$x.version) { [void]$lines.Add("$stamp  ~ plugin  $($x.name) $was -> $($x.version)") }
    }
    $oldAgents = @($Old.agents | ForEach-Object { $_.id })
    $newAgents = @($New.agents | ForEach-Object { $_.id })
    foreach ($i in $newAgents) { if ($oldAgents -notcontains $i) { [void]$lines.Add("$stamp  + agent   $i") } }
    foreach ($i in $oldAgents) { if ($newAgents -notcontains $i) { [void]$lines.Add("$stamp  - agent   $i") } }
  }
  if ($lines.Count -gt 0) {
    $existing = ''
    if (Test-Path $P.ChangeLog) { $existing = Read-Text $P.ChangeLog }
    Write-Text $P.ChangeLog ($existing + (($lines -join "`r`n") + "`r`n"))
  }
  return , @($lines)
}

# Cheap summary of everything a scan depends on. If it has not changed, a scan would not either.
function Get-Fingerprint {
  $parts = New-Object System.Collections.ArrayList
  foreach ($d in @(Get-PluginDirs)) {
    $mf = Join-Path $d '.claude-plugin\plugin.json'
    if (Test-Path $mf) { [void]$parts.Add("$d|" + (Get-Item $mf).LastWriteTimeUtc.Ticks) }
  }
  $accountRoot = Join-Path $env:APPDATA 'Claude\local-agent-mode-sessions\skills-plugin'
  if (Test-Path $accountRoot) {
    Get-ChildItem $accountRoot -Recurse -Depth 2 -Filter 'manifest.json' -File -ErrorAction SilentlyContinue |
      ForEach-Object { [void]$parts.Add("$($_.FullName)|$($_.LastWriteTimeUtc.Ticks)") }
  }
  foreach ($root in @($P.LiveSkills, $P.LiveAgents, $P.UserSkills, $P.UserAgents)) {
    if (Test-Path $root) {
      Get-ChildItem $root -Recurse -File -ErrorAction SilentlyContinue |
        ForEach-Object { [void]$parts.Add("$($_.FullName)|$($_.LastWriteTimeUtc.Ticks)") }
    }
  }
  foreach ($f in @($P.Routes, $P.Tools, $PSCommandPath)) {
    if ($f -and (Test-Path $f)) { [void]$parts.Add("$f|" + (Get-Item $f).LastWriteTimeUtc.Ticks) }
  }
  return ($parts -join "`n")
}

function Invoke-Scan {
  param([switch]$Quiet)
  $old = $null
  if (Test-Path $P.Catalog) { try { $old = Read-Text $P.Catalog | ConvertFrom-Json } catch { $old = $null } }
  $cat = Build-Catalog
  Write-Text $P.Catalog ($cat | ConvertTo-Json -Depth 6)
  # Round-trip so every reader sees the same shape.
  $cat = Read-Text $P.Catalog | ConvertFrom-Json
  $routes = Get-Routes
  Write-SkillsDoc $cat
  Write-RoutesDoc $cat $routes
  Write-ToolsDoc $routes
  $changes = Write-Changes $old $cat
  if (Test-Path $P.Installed) { Invoke-Install -Quiet }
  Write-Text $P.Fingerprint (Get-Fingerprint)
  $script:LastChanges = $changes
  if (-not $Quiet) {
    Write-Output "Scanned: $($cat.counts.skills) callable skills, $($cat.counts.references) reference docs, $($cat.counts.plugins) plugins, $($cat.counts.agents) agents."
    if ($old -and @($changes).Count -gt 0) { @($changes) | ForEach-Object { Write-Output "  $_" } }
    elseif ($old) { Write-Output '  No changes since the last scan.' }
  }
}

# ---------------------------------------------------------------- lint

function Get-SkillIssues([string]$Dir, [bool]$Portable, [bool]$Strict) {
  $issues = New-Object System.Collections.ArrayList
  $leaf = Split-Path $Dir -Leaf
  $file = Join-Path $Dir 'SKILL.md'
  if (-not (Test-Path $file)) { [void]$issues.Add("E $leaf has no SKILL.md"); return $issues.ToArray() }
  $text = Read-Text $file
  $fm = ConvertFrom-Frontmatter $text
  $name = [string]$fm['name']
  $desc = [string]$fm['description']
  if (-not $name) { [void]$issues.Add("E $leaf has no name in its frontmatter") }
  elseif ($name -cne $leaf) { [void]$issues.Add("E $leaf has name '$name'; name and folder must match") }
  if ($name -and $name -cnotmatch '^[a-z0-9]+(-[a-z0-9]+)*$') { [void]$issues.Add("E $leaf name must be lowercase words joined by hyphens") }
  if ($name -and $name.Length -gt 64) { [void]$issues.Add("E $leaf name is longer than 64 characters") }
  if (-not $desc) { [void]$issues.Add("E $leaf has no description, so no agent can discover it") }
  if ($desc.Length -gt 1024) { [void]$issues.Add("W $leaf description is $($desc.Length) characters; claude.ai uploads allow 1024") }
  if ($text -match '/mnt/skills|/mnt/user-data|/home/claude') { [void]$issues.Add("E $leaf refers to a sandbox path (/mnt or /home/claude) that agents on this machine cannot open") }
  if (($text -split "`n").Count -gt 500) { [void]$issues.Add("W $leaf SKILL.md is over 500 lines; move detail into references/") }
  if ($Portable) {
    foreach ($k in @($fm.Keys)) {
      if ($PortableKeys -notcontains $k) { [void]$issues.Add("W $leaf frontmatter key '$k' will be rejected by claude.ai uploads") }
    }
    $meta = $fm['metadata']
    if (-not ($meta -is [hashtable]) -or -not $meta['domain']) { [void]$issues.Add("W $leaf has no metadata.domain, so it depends on a routes.json entry") }
  }
  if ($Strict) {
    foreach ($f in @(Get-ChildItem $Dir -Recurse -File -Include '*.md')) {
      if ((Read-Text $f.FullName) -match 'TODO') { [void]$issues.Add("E $leaf still has TODO placeholders in $($f.Name)") }
    }
    if (-not (Test-Path (Join-Path $Dir 'evals\cases.md'))) { [void]$issues.Add("E $leaf has no evals/cases.md test prompts") }
  }
  return $issues.ToArray()
}

function Get-AllIssues($Cat, $Routes) {
  $issues = New-Object System.Collections.ArrayList
  $add = { param($m) [void]$issues.Add($m) }
  $commandNames = @()
  if ($Routes.commands) { $commandNames = @($Routes.commands.PSObject.Properties.Name) }
  $commandNames += 'os'

  # Live skills.
  if (Test-Path $P.LiveSkills) {
    foreach ($d in @(Get-ChildItem $P.LiveSkills -Directory)) {
      $isCommand = $commandNames -contains $d.Name
      foreach ($i in @(Get-SkillIssues $d.FullName (-not $isCommand) $false)) { & $add $i }
    }
  }

  # Every routed id must exist, because a dead route sends an agent nowhere.
  $known = @{}
  foreach ($s in @($Cat.skills)) { $known[$s.id] = $true; if ($s.alias) { $known[$s.alias] = $true } }
  foreach ($x in @($Routes.builtin)) { if ($x) { $known[[string]$x] = $true } }
  $agentNames = @($Cat.agents | ForEach-Object { $_.id })
  $toolsJson = Get-Tools
  $toolNames = @()
  if ($toolsJson -and $toolsJson.tools) { $toolNames = @($toolsJson.tools.PSObject.Properties.Name) }
  if ($Routes.commands) {
    foreach ($prop in $Routes.commands.PSObject.Properties) {
      if (-not (Test-Path (Join-Path $P.LiveSkills "$($prop.Name)\SKILL.md"))) { & $add "E /$($prop.Name) is routed but has no skill in .claude/skills" }
      if ($agentNames -notcontains [string]$prop.Value.agent) { & $add "E /$($prop.Name) names agent '$($prop.Value.agent)', which does not exist" }
      foreach ($id in (@($prop.Value.lead) + @($prop.Value.also))) {
        if ($id -and -not $known[[string]$id]) { & $add "E /$($prop.Name) routes to '$id', which is not installed" }
      }
      foreach ($tool in @($prop.Value.tools)) {
        if ($tool -and $toolNames -notcontains [string]$tool) { & $add "E /$($prop.Name) uses tool '$tool', which is not in registry/tools.json" }
      }
    }
  }
  if ($toolsJson -and $toolsJson.tools) {
    foreach ($prop in $toolsJson.tools.PSObject.Properties) {
      $t = $prop.Value
      if (@('claude-code', 'claudeai', 'builtin') -notcontains [string]$t.connect) { & $add "E tool '$($prop.Name)' has connect '$($t.connect)'; use claude-code, claudeai or builtin" }
      if ([string]$t.connect -eq 'claude-code' -and -not $t.server) { & $add "E tool '$($prop.Name)' connects through Claude Code but has no server entry" }
      if (-not $t.use_for) { & $add "E tool '$($prop.Name)' has no use_for, so agents cannot tell when to pick it" }
      $blob = ($t | ConvertTo-Json -Depth 6 -Compress)
      if ($blob -match '(?i)(api[_-]?key|token|secret|bearer)\s*["=:]\s*"?[A-Za-z0-9_\-]{16,}') { & $add "E tool '$($prop.Name)' looks like it contains a credential. Keys never go in tools.json" }
    }
  }
  if ($Routes.canonical) {
    foreach ($prop in $Routes.canonical.PSObject.Properties) {
      if (-not $known[[string]$prop.Value.use]) { & $add "E canonical pick for '$($prop.Name)' is '$($prop.Value.use)', which is not installed" }
    }
  }

  # Agent loadouts. Claude Code skips a missing skill silently, so catch it here.
  $liveNames = @()
  if (Test-Path $P.LiveSkills) { $liveNames = @(Get-ChildItem $P.LiveSkills -Directory | ForEach-Object { $_.Name }) }
  foreach ($a in @($Cat.agents | Where-Object { $_.origin -eq 'os' })) {
    $load = @($a.skills | Where-Object { $_ })
    if ($load.Count -gt 32) { & $add "E agent $($a.id) preloads more than 32 skills; only the first 32 load" }
    foreach ($s in $load) {
      if ($liveNames -notcontains [string]$s) { & $add "E agent $($a.id) preloads '$s', which is not a live OS skill. It would be skipped silently" }
      else {
        $fm = ConvertFrom-Frontmatter (Read-Text (Join-Path $P.LiveSkills "$s\SKILL.md"))
        if ([string]$fm['disable-model-invocation'] -eq 'true') { & $add "E agent $($a.id) preloads '$s', but that skill sets disable-model-invocation, which blocks preloading" }
      }
    }
  }

  # Anything new that nothing has classified yet.
  foreach ($p2 in @($Cat.plugins)) {
    if ($p2.domain -eq 'unclassified') { & $add "W plugin '$($p2.name)' is new and unclassified. Add it to the plugins section of registry/routes.json" }
  }
  $strays = @($Cat.skills | Where-Object { $_.kind -eq 'skill' -and $_.domain -eq 'unclassified' -and $_.plugin -ne '' })
  $strayPlugins = @($Cat.plugins | Where-Object { $_.domain -eq 'unclassified' } | ForEach-Object { $_.name })
  foreach ($s in $strays) {
    if ($strayPlugins -notcontains $s.plugin) { & $add "W skill '$($s.id)' has no domain. Add it to skill_overrides in registry/routes.json" }
  }
  foreach ($s in @($Cat.skills | Where-Object { $_.origin -eq 'owned' -and $_.domain -eq 'unclassified' })) {
    & $add "W owned skill '$($s.id)' has no domain"
  }

  # Name collisions that have no decision yet.
  foreach ($prop in $Cat.collisions.PSObject.Properties) {
    if (-not (Get-Prop $Routes.canonical $prop.Name)) {
      & $add "W '$($prop.Name)' exists in $($prop.Value -join ' and ') with no canonical pick"
    }
  }

  # Your own skills edited on claude.ai since they were imported here.
  if ($Cat.accountStamps) {
    foreach ($prop in $Cat.accountStamps.PSObject.Properties) {
      $file = Join-Path $P.LiveSkills "$($prop.Name)\SKILL.md"
      if (Test-Path $file) {
        $fm = ConvertFrom-Frontmatter (Read-Text $file)
        $meta = $fm['metadata']
        if ($meta -is [hashtable] -and $meta['source-updated'] -and [string]$meta['source-updated'] -ne [string]$prop.Value) {
          & $add "W $($prop.Name) changed on claude.ai ($($prop.Value)) after the OS copy was imported ($($meta['source-updated']))"
        }
      }
    }
  }

  # Commands and agents carry the OS location so they work from other projects.
  $homeFiles = @()
  if (Test-Path $P.LiveSkills) { $homeFiles += @(Get-ChildItem $P.LiveSkills -Recurse -Filter 'SKILL.md' -File) }
  if (Test-Path $P.LiveAgents) { $homeFiles += @(Get-ChildItem $P.LiveAgents -Filter '*.md' -File) }
  foreach ($f in $homeFiles) {
    $m = [regex]::Match((Read-Text $f.FullName), 'OS home: `([^`]+)`')
    if ($m.Success -and $m.Groups[1].Value -ne $OsHome) {
      & $add "W $($f.FullName) points at the old OS location. Run: os rehome"
    }
  }
  return $issues.ToArray()
}

function Invoke-Check {
  $cat = Get-Catalog
  $routes = Get-Routes
  $issues = @(Get-AllIssues $cat $routes)
  $errors = @($issues | Where-Object { $_.StartsWith('E ') })
  $warns = @($issues | Where-Object { $_.StartsWith('W ') })
  foreach ($e in $errors) { Write-Output "ERROR  $($e.Substring(2))" }
  foreach ($w in $warns) { Write-Output "warn   $($w.Substring(2))" }
  Write-Output "$($errors.Count) errors, $($warns.Count) warnings."
  if ($errors.Count -gt 0) { exit 1 }
}

# ---------------------------------------------------------------- find

function Invoke-Find([string[]]$Terms) {
  $words = @($Terms | ForEach-Object { $_ -split '\s+' } | Where-Object { $_ -and $_ -notin @('--all', '-all') } | ForEach-Object { $_.ToLower() })
  $all = @($Terms) -contains '--all' -or @($Terms) -contains '-all'
  if ($words.Count -eq 0) { Write-Output 'Usage: os find <words> [--all]'; return }
  $cat = Get-Catalog
  $routes = Get-Routes
  $canon = @{}
  if ($routes.canonical) { foreach ($prop in $routes.canonical.PSObject.Properties) { $canon[[string]$prop.Value.use] = $true } }
  $scored = foreach ($s in @($cat.skills)) {
    if ($s.supersededBy) { continue }
    if ($s.kind -eq 'reference' -and -not $all) { continue }
    $score = 0; $hits = 0
    $name = ([string]$s.name).ToLower(); $id = ([string]$s.id).ToLower(); $desc = ([string]$s.description).ToLower()
    foreach ($w in $words) {
      $hit = $false
      if ($name -eq $w) { $score += 12; $hit = $true }
      elseif ($name.Contains($w)) { $score += 6; $hit = $true }
      elseif ($id.Contains($w)) { $score += 3; $hit = $true }
      if ($desc.Contains($w)) { $score += 2; $hit = $true }
      if ($hit) { $hits++ }
    }
    if ($hits -eq 0) { continue }
    $score += ($hits * 4)
    if ($hits -eq $words.Count) { $score += 6 }
    if ($s.origin -eq 'owned') { $score += 4 }
    if ($canon[[string]$s.id]) { $score += 3 }
    [pscustomobject]@{ score = $score; rec = $s }
  }
  $top = @($scored | Sort-Object score -Descending | Select-Object -First 10)
  if ($top.Count -eq 0) { Write-Output "No skill matches: $($words -join ' ')"; return }
  foreach ($t in $top) {
    $s = $t.rec
    $via = ''
    if ($s.command) { $via = " -> /$($s.command)" }
    Write-Output "$($s.id)  [$($s.domain)$via]"
    Write-Output "  $(ConvertTo-Cell $s.description 170)"
    Write-Output "  $($s.path)"
  }
}

# ---------------------------------------------------------------- status and boot

function Invoke-Status {
  $cat = Get-Catalog
  $routes = Get-Routes
  $issues = @(Get-AllIssues $cat $routes)
  $errors = @($issues | Where-Object { $_.StartsWith('E ') }).Count
  $warns = @($issues | Where-Object { $_.StartsWith('W ') }).Count
  $lab = 0
  if (Test-Path $P.Lab) { $lab = @(Get-ChildItem $P.Lab -Directory | Where-Object { $_.Name -ne '_template' }).Count }
  $osAgents = @($cat.agents | Where-Object { $_.origin -eq 'os' }).Count
  $installed = 'this folder only'
  if (Test-Path $P.Installed) { $installed = 'every project (installed to ~/.claude)' }
  Write-Output "Skills OS   $OsHome"
  Write-Output "Last scan   $($cat.generated)"
  Write-Output "Commands    $($cat.counts.commands)"
  Write-Output "Your skills $($cat.counts.owned) live, $lab in the lab"
  Write-Output "Your agents $osAgents (plus $($cat.counts.agents - $osAgents) from plugins)"
  Write-Output "Catalog     $($cat.counts.skills) callable skills, $($cat.counts.references) reference docs, $($cat.counts.plugins) plugins"
  Write-Output "Connectors  $($cat.counts.connectorsPending) waiting for sign-in"
  $toolsJson = Get-Tools
  if ($toolsJson) {
    $toolTotal = @($toolsJson.tools.PSObject.Properties).Count
    $notReady = @(Get-ToolsNotReady)
    $toolLine = "Tools       $($toolTotal - $notReady.Count) of $toolTotal ready"
    if ($notReady.Count -gt 0) { $toolLine += "; not ready: $($notReady -join ', ') (details: os tools)" }
    Write-Output $toolLine
  }
  Write-Output "Available   $installed"
  Write-Output "Health      $errors errors, $warns warnings (details: os check)"
}

function Invoke-Boot {
  $script:LastChanges = @()
  $fresh = (Test-Path $P.Catalog) -and (Test-Path $P.Fingerprint) -and ((Read-Text $P.Fingerprint) -eq (Get-Fingerprint))
  if (-not $fresh) { Invoke-Scan -Quiet }
  $cat = Get-Catalog
  $routes = Get-Routes
  $issues = @(Get-AllIssues $cat $routes)
  $errors = @($issues | Where-Object { $_.StartsWith('E ') })
  $warns = @($issues | Where-Object { $_.StartsWith('W ') })
  Write-Output "Skills OS online: $($cat.counts.skills) callable skills, $($cat.counts.commands) commands, $($cat.counts.agents) agents. Route with registry/ROUTES.md; search with: os find <words>."
  foreach ($c in @($script:LastChanges | Select-Object -First 8)) { Write-Output "Changed: $c" }
  foreach ($e in @($errors | Select-Object -First 5)) { Write-Output "OS error: $($e.Substring(2))" }
  $unclassified = @($warns | Where-Object { $_ -match 'unclassified|no domain' })
  foreach ($w in @($unclassified | Select-Object -First 3)) { Write-Output "OS needs a decision: $($w.Substring(2))" }
  $notReady = @(Get-ToolsNotReady)
  if ($notReady.Count -gt 0) { Write-Output "Tools not ready: $($notReady -join ', '). Use their fallbacks in registry/TOOLS.md." }
}

# ---------------------------------------------------------------- lifecycle

function Assert-SkillName([string]$Name) {
  if (-not $Name) { throw 'A skill name is required.' }
  if ($Name -cnotmatch '^[a-z0-9]+(-[a-z0-9]+)*$') { throw "Skill names are lowercase words joined by hyphens, for example ubf-grant-writer. Got: $Name" }
  if ($Name.StartsWith('_')) { throw 'That name is reserved.' }
}

function Invoke-New([string]$Name) {
  Assert-SkillName $Name
  $target = Join-Path $P.Lab $Name
  if (Test-Path $target) { throw "lab/$Name already exists." }
  if (Test-Path (Join-Path $P.LiveSkills $Name)) { throw "'$Name' is already a live skill." }
  $cat = Get-Catalog
  $same = @($cat.skills | Where-Object { $_.name -eq $Name -and -not $_.supersededBy })
  Copy-Item $P.Template $target -Recurse
  foreach ($f in @(Get-ChildItem $target -Recurse -File)) {
    Write-Text $f.FullName ((Read-Text $f.FullName).Replace('{{name}}', $Name))
  }
  Write-Output "Created lab/$Name. It is a draft: no agent loads it until it is promoted."
  if ($same.Count -gt 0) { Write-Output "Heads up: '$Name' already exists as $(@($same | ForEach-Object { $_.id }) -join ', '). Check you are not duplicating it." }
  Write-Output "Next: fill in lab/$Name/SKILL.md and evals/cases.md, then run: os promote $Name"
}

function Invoke-Promote([string]$Name) {
  Assert-SkillName $Name
  $source = Join-Path $P.Lab $Name
  $target = Join-Path $P.LiveSkills $Name
  if (-not (Test-Path $source)) { throw "lab/$Name does not exist." }
  if (Test-Path $target) { throw "'$Name' is already live. Edit it there, or retire it first." }
  $issues = @(Get-SkillIssues $source $true $true)
  $errors = @($issues | Where-Object { $_.StartsWith('E ') })
  foreach ($i in $issues) { Write-Output "$($i.Substring(0, 1)) $($i.Substring(2))" }
  if ($errors.Count -gt 0) { Write-Output "Not promoted: fix the $($errors.Count) error(s) above."; exit 1 }
  Move-Item $source $target
  Invoke-Scan -Quiet
  Write-Output "$Name is live and in the catalog."
}

function Invoke-Retire([string]$Name) {
  Assert-SkillName $Name
  $source = Join-Path $P.LiveSkills $Name
  if (-not (Test-Path $source)) { throw "'$Name' is not a live skill." }
  $routes = Get-Routes
  $commandNames = @()
  if ($routes.commands) { $commandNames = @($routes.commands.PSObject.Properties.Name) }
  $commandNames += 'os'
  if ($commandNames -contains $Name) { throw "'$Name' is an OS command. Remove it from registry/routes.json first." }
  $refs = New-Object System.Collections.ArrayList
  foreach ($prop in @($routes.commands.PSObject.Properties)) {
    if ((@($prop.Value.lead) + @($prop.Value.also)) -contains $Name) { [void]$refs.Add("route /$($prop.Name)") }
  }
  $cat = Get-Catalog
  foreach ($a in @($cat.agents | Where-Object { $_.origin -eq 'os' })) {
    if (@($a.skills) -contains $Name) { [void]$refs.Add("agent $($a.id)") }
  }
  if ($refs.Count -gt 0) { Write-Output "Still in use by: $($refs -join ', '). Remove those references first."; exit 1 }
  $dest = Join-Path $P.Archive ("$Name-" + (Get-Date).ToString('yyyyMMdd'))
  if (Test-Path $dest) { $dest = "$dest-" + (Get-Date).ToString('HHmmss') }
  if (-not (Test-Path $P.Archive)) { New-Item -ItemType Directory -Force -Path $P.Archive | Out-Null }
  Move-Item $source $dest
  Invoke-Scan -Quiet
  Write-Output "$Name retired to archive/$(Split-Path $dest -Leaf). Nothing was deleted."
}

function Invoke-Rehome {
  $count = 0
  $files = @()
  if (Test-Path $P.LiveSkills) { $files += @(Get-ChildItem $P.LiveSkills -Recurse -Filter 'SKILL.md' -File) }
  if (Test-Path $P.LiveAgents) { $files += @(Get-ChildItem $P.LiveAgents -Filter '*.md' -File) }
  foreach ($f in $files) {
    $t = Read-Text $f.FullName
    $n = [regex]::Replace($t, 'OS home: `[^`]+`', { param($m) 'OS home: `' + $OsHome + '`' })
    if ($n -cne $t) { Write-Text $f.FullName $n; $count++ }
  }
  Invoke-Scan -Quiet
  Write-Output "Updated the OS location in $count file(s)."
}

# ---------------------------------------------------------------- install

function Invoke-Install {
  param([switch]$Quiet)
  $old = @(Get-InstalledEntries)
  $entries = New-Object System.Collections.ArrayList
  $conflicts = New-Object System.Collections.ArrayList
  $copied = 0
  foreach ($t in @($P.UserSkills, $P.UserAgents)) {
    if (-not (Test-Path $t)) { New-Item -ItemType Directory -Force -Path $t | Out-Null }
  }
  foreach ($d in @(Get-ChildItem $P.LiveSkills -Directory)) {
    $key = "skills/$($d.Name)"
    $target = Join-Path $P.UserSkills $d.Name
    if ((Test-Path $target) -and ($old -notcontains $key)) { [void]$conflicts.Add($key); continue }
    if ((Test-Path $target) -and ((Get-TreeStamp $d.FullName) -eq (Get-TreeStamp $target))) { [void]$entries.Add($key); continue }
    if (Test-Path $target) { Remove-Item $target -Recurse -Force }
    Copy-Item $d.FullName $target -Recurse
    [void]$entries.Add($key); $copied++
  }
  foreach ($a in @(Get-ChildItem $P.LiveAgents -Filter '*.md' -File)) {
    $key = "agents/$($a.Name)"
    $target = Join-Path $P.UserAgents $a.Name
    if ((Test-Path $target) -and ($old -notcontains $key)) { [void]$conflicts.Add($key); continue }
    if ((Test-Path $target) -and ((Get-FileHash $a.FullName -Algorithm MD5).Hash -eq (Get-FileHash $target -Algorithm MD5).Hash)) { [void]$entries.Add($key); continue }
    Copy-Item $a.FullName $target -Force
    [void]$entries.Add($key); $copied++
  }
  # Clean up only what this tool installed and the OS no longer has.
  $removed = 0
  foreach ($key in $old) {
    if ($entries -contains $key -or $conflicts -contains $key) { continue }
    $parts = $key -split '/', 2
    $base = $P.UserSkills
    if ($parts[0] -eq 'agents') { $base = $P.UserAgents }
    $target = Join-Path $base $parts[1]
    if (Test-Path $target) { Remove-Item $target -Recurse -Force; $removed++ }
  }
  Write-Text $P.Installed (([pscustomobject]@{ installedAt = (Get-Date).ToString('yyyy-MM-dd HH:mm'); entries = @($entries) }) | ConvertTo-Json -Depth 3)
  if (-not $Quiet) {
    Write-Output "Installed: $($entries.Count) items in ~/.claude ($copied copied, $removed removed)."
    foreach ($c in $conflicts) { Write-Output "Skipped $c because you already have your own there. Nothing was overwritten." }
  }
}

function Invoke-Uninstall {
  $count = 0
  foreach ($key in @(Get-InstalledEntries)) {
    $parts = $key -split '/', 2
    $base = $P.UserSkills
    if ($parts[0] -eq 'agents') { $base = $P.UserAgents }
    $target = Join-Path $base $parts[1]
    if (Test-Path $target) { Remove-Item $target -Recurse -Force; $count++ }
  }
  if (Test-Path $P.Installed) { Remove-Item $P.Installed -Force }
  Write-Output "Removed $count items from ~/.claude. This folder is unchanged."
}

# ---------------------------------------------------------------- dispatch

$usage = @'
os status             One-screen health summary (default)
os scan               Rebuild the catalog and routes from what is installed
os find <words>       Search every skill. Add --all to include reference docs
os check              Validate skills, agents, routes and tools. Exits 1 on errors
os tools              Show which tools (MCP connectors) are ready
os tools install      Register the OS's MCP connectors for every project
os tools remove <n>   Unregister one of them
os new <name>         Start a draft skill in lab/
os promote <name>     Validate a draft and make it live
os retire <name>      Move a live skill to archive/ (nothing is deleted)
os install            Make commands, skills and agents available in every project
os uninstall          Undo os install
os rehome             Update stored paths after moving this folder
'@

switch ($Verb.ToLower()) {
  'status' { Invoke-Status }
  'scan' { Invoke-Scan }
  'boot' { Invoke-Boot }
  'find' { Invoke-Find $Rest }
  'check' { Invoke-Check }
  'tools' { Invoke-Tools $Rest }
  'new' { Invoke-New ($Rest | Select-Object -First 1) }
  'promote' { Invoke-Promote ($Rest | Select-Object -First 1) }
  'retire' { Invoke-Retire ($Rest | Select-Object -First 1) }
  'install' { Invoke-Install }
  'uninstall' { Invoke-Uninstall }
  'rehome' { Invoke-Rehome }
  default { Write-Output $usage; if ($Verb -notin @('help', '-h', '--help', '/?')) { exit 2 } }
}
