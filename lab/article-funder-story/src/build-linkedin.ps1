# Builds ..\linkedin-upload: plain-text article with image markers, plain-text feed post,
# and the images resized to files small enough to upload one at a time.
# Run: powershell -ExecutionPolicy Bypass -File build-linkedin.ps1
param([string]$Root = $PSScriptRoot)
Add-Type -AssemblyName System.Drawing

$art = [System.IO.Path]::GetFullPath((Join-Path $Root '..'))
$out = Join-Path $art 'linkedin-upload'
$imgOut = Join-Path $out 'images'
New-Item -ItemType Directory -Force -Path $imgOut | Out-Null

function Smart([string]$s) {
  $s = [regex]::Replace($s, '(^|[\s(\[])"', ('$1' + [char]0x201C))
  $s = $s.Replace('"', [string][char]0x201D)
  $s = [regex]::Replace($s, "(^|[\s(\[])'", ('$1' + [char]0x2018))
  return $s.Replace("'", [string][char]0x2019)
}
function Plain([string]$s) { return ($s -replace '\*\*', '' -replace '(?<!\*)\*(?!\*)', '') }

# ---------- images ----------
$map = [ordered]@{
  '1-cover.png'                 = @('01-hero.png', 1200)
  '2-two-studies.png'           = @('02-two-studies.png', 1200)
  '3-five-parts.png'           = @('03-five-parts.png', 1200)
  '4-before-after.png'         = @('04-before-after.png', 1080)
  'extra-cover-photo.jpg'       = @('05-cover-photo.jpg', 1200)
  'extra-author-photo.png'      = @('06-author-tom.png', 400)
}
foreach ($k in $map.Keys) {
  $srcPath = Join-Path $art ('images\' + $map[$k][0]); $w = $map[$k][1]
  $src = [System.Drawing.Image]::FromFile($srcPath)
  $h = [int]($src.Height * $w / $src.Width)
  $bmp = New-Object System.Drawing.Bitmap $w, $h, ([System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
  $g = [System.Drawing.Graphics]::FromImage($bmp)
  $g.InterpolationMode = 'HighQualityBicubic'; $g.SmoothingMode = 'HighQuality'
  $g.DrawImage($src, 0, 0, $w, $h); $g.Dispose()
  $dest = Join-Path $imgOut $k
  if ($k.EndsWith('.jpg')) {
    $enc = [System.Drawing.Imaging.ImageCodecInfo]::GetImageEncoders() | Where-Object { $_.MimeType -eq 'image/jpeg' }
    $ep = New-Object System.Drawing.Imaging.EncoderParameters 1
    $ep.Param[0] = New-Object System.Drawing.Imaging.EncoderParameter ([System.Drawing.Imaging.Encoder]::Quality), 88L
    $bmp.Save($dest, $enc, $ep)
  } else { $bmp.Save($dest, [System.Drawing.Imaging.ImageFormat]::Png) }
  $bmp.Dispose(); $src.Dispose()
}

# ---------- article text ----------
$md = [System.IO.File]::ReadAllText((Join-Path $art 'article.md'), [System.Text.Encoding]::UTF8)
$md = [regex]::Replace($md, '(?s)<!--.*?-->', '')
$lines = $md -split "\r?\n"
$names = @{ '01-hero.png' = '1-cover.png'; '02-two-studies.png' = '2-two-studies.png'; '03-five-parts.png' = '3-five-parts.png'; '04-before-after.png' = '4-before-after.png' }
$res = New-Object System.Collections.Generic.List[string]
$headings = New-Object System.Collections.Generic.List[string]
for ($i = 0; $i -lt $lines.Count; $i++) {
  $l = $lines[$i].Trim()
  if ($l -eq '') { continue }
  if ($l -match '^# (.+)$')  { $res.Add((Smart $Matches[1])); $res.Add(''); continue }
  if ($l -match '^## (.+)$') { $t = Smart $Matches[1]; $headings.Add($t); $res.Add($t); $res.Add(''); continue }
  if ($l -match '^!\[(.*?)\]\((.*?)\)$') {
    $f = Split-Path $Matches[2] -Leaf; $new = $names[$f]
    $j = $i + 1; while ($j -lt $lines.Count -and $lines[$j].Trim() -eq '') { $j++ }
    if ($j -lt $lines.Count -and $lines[$j].Trim() -match '^\*Alt text: ') { $i = $j }
    if ($f -eq '01-hero.png') { $res.Add("[COVER IMAGE: upload images\$new as the article cover. Delete this line.]") }
    else { $res.Add("[INSERT IMAGE: images\$new here. Delete this line after inserting.]") }
    $res.Add(''); continue
  }
  $res.Add((Smart (Plain $l))); $res.Add('')
}
$text = ($res -join "`r`n").TrimEnd() + "`r`n"
[System.IO.File]::WriteAllText((Join-Path $out '1-article-text.txt'), $text, (New-Object System.Text.UTF8Encoding($true)))

# ---------- feed post ----------
$fp = [System.IO.File]::ReadAllText((Join-Path $art 'linkedin-feed-post.md'), [System.Text.Encoding]::UTF8) -split "\r?\n"
$dash = @(); for ($i = 0; $i -lt $fp.Count; $i++) { if ($fp[$i].Trim() -eq '---') { $dash += $i } }
$body = ($fp[($dash[0] + 1)..($dash[1] - 1)] -join "`r`n").Trim() + "`r`n"
$body = $body.Replace("'", [string][char]0x2019)
[System.IO.File]::WriteAllText((Join-Path $out '2-feed-post.txt'), $body, (New-Object System.Text.UTF8Encoding($true)))

"Headings to set with the editor's Heading style:"; $headings | ForEach-Object { "  - $_" }
Get-ChildItem $imgOut | Select-Object Name, Length
$wc = ($text -split '\s+' | Where-Object { $_ -match '\w' -and $_ -notmatch '^\[|^images' }).Count
"Approx. words in text file (incl. markers): $wc"
