# Converts ..\article.md into ..\article.html (blog-ready body plus preview styling).
# Run: powershell -ExecutionPolicy Bypass -File build-html.ps1
param([string]$Root = $PSScriptRoot)

$md  = [System.IO.Path]::GetFullPath((Join-Path $Root '..\article.md'))
$out = [System.IO.Path]::GetFullPath((Join-Path $Root '..\article.html'))
$text = [System.IO.File]::ReadAllText($md, [System.Text.Encoding]::UTF8)
$text = [regex]::Replace($text, '(?s)<!--.*?-->', '')
$lines = $text -split "\r?\n"

function ConvertTo-Inline([string]$s) {
  $s = [System.Net.WebUtility]::HtmlEncode($s)
  $s = [regex]::Replace($s, '\*\*(.+?)\*\*', '<strong>$1</strong>')
  $s = [regex]::Replace($s, '\*(.+?)\*', '<em>$1</em>')
  return $s
}

$body = New-Object System.Collections.Generic.List[string]
$title = ''
for ($i = 0; $i -lt $lines.Count; $i++) {
  $l = $lines[$i].Trim()
  if ($l -eq '') { continue }
  if ($l -match '^# (.+)$')  { $title = $Matches[1]; $body.Add('<h1>' + (ConvertTo-Inline $Matches[1]) + '</h1>'); continue }
  if ($l -match '^## (.+)$') { $body.Add('<h2>' + (ConvertTo-Inline $Matches[1]) + '</h2>'); continue }
  if ($l -match '^!\[(.*?)\]\((.*?)\)$') {
    $alt = $Matches[1]; $src = $Matches[2]
    $j = $i + 1
    while ($j -lt $lines.Count -and $lines[$j].Trim() -eq '') { $j++ }
    if ($j -lt $lines.Count -and $lines[$j].Trim() -match '^\*Alt text: (.+)\*$') { $alt = $Matches[1]; $i = $j }
    $altEnc = [System.Net.WebUtility]::HtmlEncode($alt)
    $body.Add("<figure><img src=""$src"" alt=""$altEnc"" loading=""lazy""></figure>")
    continue
  }
  $body.Add('<p>' + (ConvertTo-Inline $l) + '</p>')
}

$titleEnc = [System.Net.WebUtility]::HtmlEncode($title)
$html = @"
<!doctype html>
<html lang="en"><head><meta charset="utf-8">
<meta name="viewport" content="width=device-width,initial-scale=1">
<title>$titleEnc</title>
<style>
:root{--navy:#0D172A;--gold:#F2B720;--ink:#1E2433;--cream:#FBF6EA}
*{box-sizing:border-box}
body{margin:0;background:var(--cream);color:var(--ink);font:19px/1.65 Georgia,'Times New Roman',serif}
article{max-width:720px;margin:0 auto;padding:48px 20px 80px}
h1,h2{font-family:Bahnschrift,'Segoe UI',Arial,sans-serif;color:var(--navy);line-height:1.12;letter-spacing:-.005em}
h1{font-size:40px;margin:0 0 24px}
h2{font-size:28px;margin:52px 0 12px;padding-top:6px;border-top:4px solid var(--gold);display:inline-block}
p{margin:0 0 18px}
strong{color:var(--navy)}
figure{margin:32px -20px}
figure img{display:block;width:100%;height:auto;border-radius:10px}
@media (min-width:800px){figure{margin:32px -60px}}
</style></head><body><article>
$($body -join "`n")
</article></body></html>
"@
[System.IO.File]::WriteAllText($out, $html, (New-Object System.Text.UTF8Encoding($false)))
"Wrote $out"
