# Exports the .docx to PDF with real Microsoft Word, and writes a PNG of each page for checking.
# Must run in 32-bit PowerShell on this PC (64-bit resolves Word automation to WPS):
#   & "$env:WINDIR\SysWOW64\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -ExecutionPolicy Bypass -File export-pdf.ps1 -Docx <docx> -Pdf <pdf> -PagesDir <folder>
param([Parameter(Mandatory)][string]$Docx, [Parameter(Mandatory)][string]$Pdf, [string]$PagesDir)
Add-Type -AssemblyName System.Drawing

$word = New-Object -ComObject Word.Application
$word.Visible = $false
$word.DisplayAlerts = 0
"Word version: $($word.Version)"
$hadDocs = $word.Documents.Count
$doc = $null
try {
  $doc = $word.Documents.Open($Docx, $false, $true)
  $doc.Repaginate()
  $doc.Fields.Update() | Out-Null
  foreach ($s in $doc.Sections) { foreach ($f in $s.Footers) { $f.Range.Fields.Update() | Out-Null } }
  $doc.ExportAsFixedFormat($Pdf, 17)
  $n = $doc.ComputeStatistics(2)
  "Pages: $n"
  if ($PagesDir) {
    New-Item -ItemType Directory -Force -Path $PagesDir | Out-Null
    for ($i = 1; $i -le $n; $i++) {
      $bytes = $word.ActiveWindow.Panes.Item(1).Pages.Item($i).EnhMetaFileBits
      $ms = New-Object System.IO.MemoryStream (, [byte[]]$bytes)
      $mf = [System.Drawing.Image]::FromStream($ms)
      $W = 900; $H = [int]($W * $mf.Height / $mf.Width)
      $bmp = New-Object System.Drawing.Bitmap $W, $H
      $g = [System.Drawing.Graphics]::FromImage($bmp)
      $g.Clear([System.Drawing.Color]::White)
      $g.InterpolationMode = 'HighQualityBicubic'
      $g.DrawImage($mf, 0, 0, $W, $H)
      $g.Dispose()
      $bmp.Save((Join-Path $PagesDir ("page-{0:D2}.png" -f $i)), [System.Drawing.Imaging.ImageFormat]::Png)
      $bmp.Dispose(); $mf.Dispose(); $ms.Dispose()
    }
  }
} finally {
  if ($doc) { $doc.Close(0) }
  if ($hadDocs -eq 0) { $word.Quit() }
}
"PDF: $Pdf"
