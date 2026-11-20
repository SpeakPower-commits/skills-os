# Makes the two human images used in the Word/PDF edition from Tom's own files.
#   05-cover-photo.jpg  wide banner cropped from SpeakPower Ads\SP Ad image.jpg
#   06-author-tom.png   circular crop of Tom's own photo (20250313_152357.jpg)
# Run: powershell -ExecutionPolicy Bypass -File prep-photos.ps1
param([string]$Root = $PSScriptRoot)
Add-Type -AssemblyName System.Drawing

$ads = 'C:\Users\tom.otieno\Desktop\SpeakPower\Graphics & Ads\SpeakPower Ads'
$imagesDir = [System.IO.Path]::GetFullPath((Join-Path $Root '..\images'))

function Get-Upright([string]$path) {
  $img = [System.Drawing.Bitmap]::FromFile($path)
  if ($img.PropertyIdList -contains 0x0112) {
    $o = [int]$img.GetPropertyItem(0x0112).Value[0]
    $map = @{ 3 = 'Rotate180FlipNone'; 6 = 'Rotate90FlipNone'; 8 = 'Rotate270FlipNone' }
    if ($map.ContainsKey($o)) { $img.RotateFlip([System.Drawing.RotateFlipType]::($map[$o])) }
  }
  return $img
}

# --- cover banner ---
$src = Get-Upright (Join-Path $ads 'SP Ad image.jpg')
$cropW = $src.Width; $cropH = 900; $cropY = 70
$outW = 2048; $outH = [int]($outW * $cropH / $cropW)
$bmp = New-Object System.Drawing.Bitmap $outW, $outH
$g = [System.Drawing.Graphics]::FromImage($bmp)
$g.InterpolationMode = 'HighQualityBicubic'
$g.DrawImage($src, (New-Object System.Drawing.Rectangle 0, 0, $outW, $outH), (New-Object System.Drawing.Rectangle 0, $cropY, $cropW, $cropH), [System.Drawing.GraphicsUnit]::Pixel)
$gold = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(242, 183, 32))
$g.FillRectangle($gold, 0, $outH - 18, $outW, 18)
$g.Dispose()
$jpg = [System.Drawing.Imaging.ImageCodecInfo]::GetImageEncoders() | Where-Object { $_.MimeType -eq 'image/jpeg' }
$ep = New-Object System.Drawing.Imaging.EncoderParameters 1
$ep.Param[0] = New-Object System.Drawing.Imaging.EncoderParameter ([System.Drawing.Imaging.Encoder]::Quality), 90L
$bmp.Save((Join-Path $imagesDir '05-cover-photo.jpg'), $jpg, $ep)
"cover: ${outW}x${outH}"
$bmp.Dispose(); $src.Dispose()

# --- author portrait ---
$tom = Get-Upright (Join-Path $ads '20250313_152357.jpg')
"tom source: $($tom.Width)x$($tom.Height)"
$size = 600
$bmp = New-Object System.Drawing.Bitmap $size, $size, ([System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
$g = [System.Drawing.Graphics]::FromImage($bmp)
$g.SmoothingMode = 'AntiAlias'; $g.InterpolationMode = 'HighQualityBicubic'
$path = New-Object System.Drawing.Drawing2D.GraphicsPath
$path.AddEllipse(0, 0, $size, $size)
$g.SetClip($path)
$g.DrawImage($tom, (New-Object System.Drawing.Rectangle 0, 0, $size, $size), (New-Object System.Drawing.Rectangle 560, 0, 1400, 1400), [System.Drawing.GraphicsUnit]::Pixel)
$g.ResetClip()
$pen = New-Object System.Drawing.Pen ([System.Drawing.Color]::FromArgb(242, 183, 32)), 16
$g.DrawEllipse($pen, 8, 8, $size - 16, $size - 16)
$g.Dispose()
$bmp.Save((Join-Path $imagesDir '06-author-tom.png'), [System.Drawing.Imaging.ImageFormat]::Png)
$bmp.Dispose(); $tom.Dispose()
Get-ChildItem $imagesDir | Where-Object { $_.Name -match '^0[56]' } | Select-Object Name, Length
