# Renders the HTML graphics in this folder to 2x PNGs in ..\images using headless Edge.
# Run: powershell -ExecutionPolicy Bypass -File render.ps1
param([string]$Root = $PSScriptRoot)
Add-Type -AssemblyName System.Drawing

$edge = 'C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe'
if (-not (Test-Path $edge)) { $edge = 'C:\Program Files\Microsoft\Edge\Application\msedge.exe' }
$profileDir = Join-Path $env:TEMP 'sp-render-profile'
$scale = 2

$jobs = @(
  @{ n = '01-hero';                 w = 1200; h = 627  },
  @{ n = '02-two-studies';          w = 1200; h = 675  },
  @{ n = '03-five-parts';           w = 1200; h = 1200 },
  @{ n = '04-before-after';         w = 1080; h = 1350 }
)

$imagesDir = [System.IO.Path]::GetFullPath((Join-Path $Root '..\images'))
New-Item -ItemType Directory -Force -Path $imagesDir | Out-Null

foreach ($j in $jobs) {
  $html = Join-Path $Root "$($j.n).html"
  $raw  = Join-Path $env:TEMP "$($j.n)-raw.png"
  $out  = Join-Path $imagesDir "$($j.n).png"
  $url  = ([System.Uri]$html).AbsoluteUri
  Remove-Item $raw -ErrorAction SilentlyContinue

  $edgeArgs = @(
    '--headless', '--disable-gpu', '--hide-scrollbars', '--no-first-run',
    "--user-data-dir=$profileDir",
    "--force-device-scale-factor=$scale",
    "--window-size=$($j.w),$($j.h + 200)",
    '--virtual-time-budget=4000',
    "--screenshot=$raw",
    $url
  )
  Start-Process -FilePath $edge -ArgumentList $edgeArgs -Wait -NoNewWindow
  if (-not (Test-Path $raw)) { Write-Error "No screenshot produced for $($j.n)"; continue }

  $src = [System.Drawing.Bitmap]::FromFile($raw)
  $cw = $j.w * $scale; $ch = $j.h * $scale
  if ($src.Width -lt $cw -or $src.Height -lt $ch) {
    Write-Error "$($j.n): raw is $($src.Width)x$($src.Height), need at least ${cw}x${ch}"
    $src.Dispose(); continue
  }
  $rect = New-Object System.Drawing.Rectangle 0, 0, $cw, $ch
  $crop = $src.Clone($rect, $src.PixelFormat)
  $crop.Save($out, [System.Drawing.Imaging.ImageFormat]::Png)
  "{0}: raw {1}x{2} -> {3}x{4}" -f $j.n, $src.Width, $src.Height, $crop.Width, $crop.Height
  $crop.Dispose(); $src.Dispose()
  Remove-Item $raw -ErrorAction SilentlyContinue
}
