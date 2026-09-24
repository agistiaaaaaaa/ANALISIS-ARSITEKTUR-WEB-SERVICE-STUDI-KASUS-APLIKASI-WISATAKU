# Buat file .docx (OOXML) tanpa Microsoft Word COM.
# Cara pakai:
#   powershell -ExecutionPolicy Bypass -File .\generate-docx.ps1

$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.IO.Compression
Add-Type -AssemblyName System.IO.Compression.FileSystem

$docsDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$outDocx = Join-Path $docsDir 'Tugas-1-Analisis-Arsitektur-Web-Service.docx'
$staging = Join-Path $docsDir '_docx_build'
$mdPath = Join-Path $docsDir 'Tugas-1-Analisis-Arsitektur-Web-Service.md'
$utf8 = New-Object System.Text.UTF8Encoding $false

function Write-Utf8NoBom([string]$path, [string]$content) {
  [System.IO.File]::WriteAllText($path, $content, $utf8)
}

function Encode-Xml([string]$text) {
  if ($null -eq $text) { return '' }
  return ($text -replace '&', '&amp;' -replace '<', '&lt;' -replace '>', '&gt;' -replace '"', '&quot;')
}

function New-Paragraph([string]$text, [string]$style = 'Normal') {
  $safe = Encode-Xml $text
  if ([string]::IsNullOrWhiteSpace($safe)) {
    return '<w:p><w:pPr><w:pStyle w:val="Normal"/></w:pPr></w:p>'
  }
  return @"
<w:p>
  <w:pPr><w:pStyle w:val="$style"/><w:spacing w:after="120"/></w:pPr>
  <w:r><w:t xml:space="preserve">$safe</w:t></w:r>
</w:p>
"@
}

function New-Heading([string]$text, [int]$level) {
  $style = if ($level -le 1) { 'Heading1' } elseif ($level -eq 2) { 'Heading2' } else { 'Heading3' }
  return (New-Paragraph $text $style)
}

function New-ImageParagraph([int]$relId, [long]$cx, [long]$cy, [string]$caption) {
  $img = @"
<w:p>
  <w:pPr><w:jc w:val="center"/><w:spacing w:before="120" w:after="60"/></w:pPr>
  <w:r>
    <w:drawing>
      <wp:inline distT="0" distB="0" distL="0" distR="0" xmlns:wp="http://schemas.openxmlformats.org/drawingml/2006/wordprocessingDrawing">
        <wp:extent cx="$cx" cy="$cy"/>
        <wp:docPr id="$relId" name="Image$relId"/>
        <a:graphic xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main">
          <a:graphicData uri="http://schemas.openxmlformats.org/drawingml/2006/picture">
            <pic:pic xmlns:pic="http://schemas.openxmlformats.org/drawingml/2006/picture">
              <pic:nvPicPr>
                <pic:cNvPr id="0" name="Image$relId"/>
                <pic:cNvPicPr/>
              </pic:nvPicPr>
              <pic:blipFill>
                <a:blip r:embed="rId$relId" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"/>
                <a:stretch><a:fillRect/></a:stretch>
              </pic:blipFill>
              <pic:spPr>
                <a:xfrm>
                  <a:off x="0" y="0"/>
                  <a:ext cx="$cx" cy="$cy"/>
                </a:xfrm>
                <a:prstGeom prst="rect"><a:avLst/></a:prstGeom>
              </pic:spPr>
            </pic:pic>
          </a:graphicData>
        </a:graphic>
      </wp:inline>
    </w:drawing>
  </w:r>
</w:p>
"@
  return ($img + (New-Paragraph $caption 'Caption'))
}

if (Test-Path $staging) { Remove-Item $staging -Recurse -Force }
New-Item -ItemType Directory -Force -Path (Join-Path $staging '_rels') | Out-Null
New-Item -ItemType Directory -Force -Path (Join-Path $staging 'word\_rels') | Out-Null
New-Item -ItemType Directory -Force -Path (Join-Path $staging 'word\media') | Out-Null

Copy-Item (Join-Path $docsDir 'assets\wisataku-arsitektur.png') (Join-Path $staging 'word\media\image1.png') -Force
Copy-Item (Join-Path $docsDir 'assets\screenshots\get-root.png') (Join-Path $staging 'word\media\image2.png') -Force
Copy-Item (Join-Path $docsDir 'assets\screenshots\get-destinasi.png') (Join-Path $staging 'word\media\image3.png') -Force
Copy-Item (Join-Path $docsDir 'assets\logo-stmik-lombok.png') (Join-Path $staging 'word\media\image4.png') -Force

Write-Utf8NoBom (Join-Path $staging '[Content_Types].xml') @'
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types">
  <Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/>
  <Default Extension="xml" ContentType="application/xml"/>
  <Default Extension="png" ContentType="image/png"/>
  <Override PartName="/word/document.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.document.main+xml"/>
  <Override PartName="/word/styles.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.styles+xml"/>
</Types>
'@

Write-Utf8NoBom (Join-Path $staging '_rels\.rels') @'
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">
  <Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument" Target="word/document.xml"/>
</Relationships>
'@

Write-Utf8NoBom (Join-Path $staging 'word\_rels\document.xml.rels') @'
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">
  <Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/styles" Target="styles.xml"/>
  <Relationship Id="rId10" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/image" Target="media/image1.png"/>
  <Relationship Id="rId2" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/image" Target="media/image2.png"/>
  <Relationship Id="rId3" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/image" Target="media/image3.png"/>
  <Relationship Id="rId4" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/image" Target="media/image4.png"/>
</Relationships>
'@

Write-Utf8NoBom (Join-Path $staging 'word\styles.xml') @'
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:styles xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">
  <w:style w:type="paragraph" w:default="1" w:styleId="Normal">
    <w:name w:val="Normal"/><w:qFormat/>
    <w:rPr><w:rFonts w:ascii="Calibri" w:hAnsi="Calibri"/><w:sz w:val="22"/></w:rPr>
  </w:style>
  <w:style w:type="paragraph" w:styleId="Heading1">
    <w:name w:val="heading 1"/><w:basedOn w:val="Normal"/><w:qFormat/>
    <w:pPr><w:spacing w:before="240" w:after="120"/></w:pPr>
    <w:rPr><w:b/><w:sz w:val="32"/><w:color w:val="243B53"/></w:rPr>
  </w:style>
  <w:style w:type="paragraph" w:styleId="Heading2">
    <w:name w:val="heading 2"/><w:basedOn w:val="Normal"/><w:qFormat/>
    <w:pPr><w:spacing w:before="200" w:after="100"/></w:pPr>
    <w:rPr><w:b/><w:sz w:val="26"/><w:color w:val="243B53"/></w:rPr>
  </w:style>
  <w:style w:type="paragraph" w:styleId="Heading3">
    <w:name w:val="heading 3"/><w:basedOn w:val="Normal"/><w:qFormat/>
    <w:pPr><w:spacing w:before="160" w:after="80"/></w:pPr>
    <w:rPr><w:b/><w:sz w:val="24"/><w:color w:val="243B53"/></w:rPr>
  </w:style>
  <w:style w:type="paragraph" w:styleId="Caption">
    <w:name w:val="Caption"/><w:basedOn w:val="Normal"/><w:qFormat/>
    <w:pPr><w:jc w:val="center"/><w:spacing w:after="160"/></w:pPr>
    <w:rPr><w:i/><w:sz w:val="18"/><w:color w:val="52606D"/></w:rPr>
  </w:style>
</w:styles>
'@

$md = Get-Content -Path $mdPath -Raw -Encoding UTF8
$lines = $md -split "`r`n|`n"
$body = New-Object System.Collections.Generic.List[string]
$skipNextCaption = $false
$passedCover = $false

# Cover page gaya STMIK Lombok (seperti contoh laporan kampus)
function New-Centered([string]$text, [string]$size = '28', [bool]$bold = $true, [string]$color = '000000') {
  $safe = Encode-Xml $text
  $b = if ($bold) { '<w:b/>' } else { '' }
  return @"
<w:p>
  <w:pPr><w:jc w:val="center"/><w:spacing w:after="60"/></w:pPr>
  <w:r><w:rPr>$b<w:rFonts w:ascii="Times New Roman" w:hAnsi="Times New Roman"/><w:sz w:val="$size"/><w:szCs w:val="$size"/><w:color w:val="$color"/></w:rPr><w:t xml:space="preserve">$safe</w:t></w:r>
</w:p>
"@
}

$body.Add((New-Centered 'LAPORAN PRAKTIKUM' '32' $true))
$body.Add((New-Centered 'TUGAS 1' '32' $true))
$body.Add((New-Centered 'ANALISIS ARSITEKTUR WEB SERVICE' '32' $true))
$body.Add((New-Centered 'STUDI KASUS APLIKASI WISATAKU' '32' $true))
$body.Add((New-Paragraph ''))
$body.Add((New-ImageParagraph 4 2700000 2070000 ''))
$body.Add((New-Centered 'Disusun oleh:' '28' $false))
$body.Add((New-Centered 'Baiq Agestia Cahya Ilami' '28' $true))
$body.Add((New-Centered 'NIM: TI21240005' '28' $true))
$body.Add((New-Paragraph ''))
$body.Add((New-Paragraph ''))
$body.Add((New-Centered 'PROGRAM STUDI TEKNIK INFORMATIKA' '26' $true))
$body.Add((New-Centered 'SEKOLAH TINGGI MANAJEMEN INFORMATIKA DAN KOMPUTER' '26' $true))
$body.Add((New-Centered 'STMIK LOMBOK' '26' $true))
$body.Add((New-Centered 'PRAYA' '26' $true))
$body.Add((New-Centered '2026' '26' $true))
$body.Add('<w:p><w:r><w:br w:type="page"/></w:r></w:p>')

function New-WordTable([string[][]]$rows) {
  if ($rows.Count -eq 0) { return '' }
  $cols = $rows[0].Count
  $colWidth = [Math]::Floor(9000 / [Math]::Max($cols, 1))
  $xml = '<w:tbl><w:tblPr><w:tblW w:w="9000" w:type="dxa"/><w:tblBorders><w:top w:val="single" w:sz="4" w:color="000000"/><w:left w:val="single" w:sz="4" w:color="000000"/><w:bottom w:val="single" w:sz="4" w:color="000000"/><w:right w:val="single" w:sz="4" w:color="000000"/><w:insideH w:val="single" w:sz="4" w:color="000000"/><w:insideV w:val="single" w:sz="4" w:color="000000"/></w:tblBorders></w:tblPr>'
  for ($r = 0; $r -lt $rows.Count; $r++) {
    $xml += '<w:tr>'
    for ($c = 0; $c -lt $rows[$r].Count; $c++) {
      $cell = $rows[$r][$c]
      $shd = if ($r -eq 0) { '<w:shd w:val="clear" w:color="auto" w:fill="F2F2F2"/>' } else { '' }
      $bold = if ($r -eq 0) { '<w:b/>' } else { '' }
      $xml += "<w:tc><w:tcPr><w:tcW w:w=`"$colWidth`" w:type=`"dxa`"/>$shd</w:tcPr><w:p><w:r><w:rPr>$bold<w:rFonts w:ascii=`"Times New Roman`" w:hAnsi=`"Times New Roman`"/><w:sz w:val=`"20`"/></w:rPr><w:t xml:space=`"preserve`">$cell</w:t></w:r></w:p></w:tc>"
    }
    $xml += '</w:tr>'
  }
  $xml += '</w:tbl><w:p/>'
  return $xml
}

for ($idx = 0; $idx -lt $lines.Count; $idx++) {
  $line = $lines[$idx].TrimEnd()

  if (-not $passedCover) {
    if ($line -match '^## BAB 1') {
      $passedCover = $true
    } else {
      continue
    }
  }

  if ($skipNextCaption -and $line -match '^\*\*Gambar') {
    $skipNextCaption = $false
    continue
  }

  if ($line -match '^!\[[^\]]*\]\(([^)]+)\)') {
    $src = $Matches[1]
    if ($src -like '*wisataku-arsitektur.svg*' -or $src -like '*wisataku-arsitektur.png*') {
      $body.Add((New-ImageParagraph 10 5486400 4937760 'Gambar 1. Arsitektur Web Service WisataKu'))
      $skipNextCaption = $true
    }
    elseif ($src -like '*get-root.png*') {
      $body.Add((New-ImageParagraph 2 5486400 1800000 'Gambar 2. Hasil pengujian GET /'))
      $skipNextCaption = $true
    }
    elseif ($src -like '*get-destinasi.png*') {
      $body.Add((New-ImageParagraph 3 5486400 1800000 'Gambar 3. Hasil pengujian GET /destinasi'))
      $skipNextCaption = $true
    }
    elseif ($src -like '*logo-stmik*') { continue }
    continue
  }

  if ($line -match '^# (.+)$') { $body.Add((New-Heading $Matches[1] 1)); continue }
  if ($line -match '^## (.+)$') { $body.Add((New-Heading $Matches[1] 1)); continue }
  if ($line -match '^### (.+)$') { $body.Add((New-Heading $Matches[1] 2)); continue }
  if ($line -eq '---') { continue }
  if ($line -match '^>\s?(.*)$') {
    $q = $Matches[1] -replace '\*\*', '' -replace '`', ''
    $body.Add((New-Paragraph $q))
    continue
  }
  if ($line -match '^```') { continue }

  if ($line -match '^\|') {
    $rows = @()
    while ($idx -lt $lines.Count -and $lines[$idx].TrimEnd() -match '^\|') {
      $rowLine = $lines[$idx].TrimEnd()
      if ($rowLine -notmatch '^[\|\s\-:]+$') {
        $cells = @()
        foreach ($c in $rowLine.Trim('|').Split('|')) {
          $cells += (Encode-Xml (($c.Trim() -replace '`','' -replace '\*\*','')))
        }
        $rows += ,$cells
      }
      $idx++
    }
    $idx--
    if ($rows.Count -gt 0) { $body.Add((New-WordTable $rows)) }
    continue
  }

  if ($line -match '^[-*] (.+)$') {
    $item = $Matches[1] -replace '\*\*', '' -replace '`', ''
    $body.Add((New-Paragraph ("- " + $item)))
    continue
  }
  if ($line -match '^\d+\. (.+)$') {
    $item = $line -replace '\*\*', '' -replace '`', ''
    $body.Add((New-Paragraph $item))
    continue
  }
  if ($line.Trim() -eq '') { continue }

  $clean = $line -replace '\*\*', '' -replace '`', ''
  if ($clean -match '^Tabel \d+') {
    $body.Add((New-Centered $clean '22' $true))
  } else {
    $body.Add((New-Paragraph $clean))
  }
}

$documentXml = @"
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:document
  xmlns:wpc="http://schemas.microsoft.com/office/word/2010/wordprocessingCanvas"
  xmlns:mc="http://schemas.openxmlformats.org/markup-compatibility/2006"
  xmlns:o="urn:schemas-microsoft-com:office:office"
  xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"
  xmlns:m="http://schemas.openxmlformats.org/officeDocument/2006/math"
  xmlns:v="urn:schemas-microsoft-com:vml"
  xmlns:wp14="http://schemas.microsoft.com/office/word/2010/wordprocessingDrawing"
  xmlns:wp="http://schemas.openxmlformats.org/drawingml/2006/wordprocessingDrawing"
  xmlns:w10="urn:schemas-microsoft-com:office:word"
  xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"
  xmlns:w14="http://schemas.microsoft.com/office/word/2010/wordml"
  xmlns:wpg="http://schemas.microsoft.com/office/word/2010/wordprocessingGroup"
  xmlns:wpi="http://schemas.microsoft.com/office/word/2010/wordprocessingInk"
  xmlns:wne="http://schemas.microsoft.com/office/word/2006/wordml"
  xmlns:wps="http://schemas.microsoft.com/office/word/2010/wordprocessingShape"
  xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main"
  xmlns:pic="http://schemas.openxmlformats.org/drawingml/2006/picture"
  mc:Ignorable="w14 wp14">
  <w:body>
    $($body -join "`n")
    <w:sectPr>
      <w:pgSz w:w="11906" w:h="16838"/>
      <w:pgMar w:top="1134" w:right="1134" w:bottom="1134" w:left="1134"/>
    </w:sectPr>
  </w:body>
</w:document>
"@

Write-Utf8NoBom (Join-Path $staging 'word\document.xml') $documentXml

if (Test-Path $outDocx) { Remove-Item $outDocx -Force }

# Buat ZIP/DOCX dengan path forward-slash agar kompatibel dengan Word
$zip = [System.IO.Compression.ZipFile]::Open($outDocx, [System.IO.Compression.ZipArchiveMode]::Create)
function Add-DocPart([string]$relative) {
  $src = Join-Path $staging ($relative -replace '/', '\')
  $entry = $zip.CreateEntry($relative, [System.IO.Compression.CompressionLevel]::Optimal)
  $inStream = [System.IO.File]::OpenRead($src)
  $outStream = $entry.Open()
  $inStream.CopyTo($outStream)
  $outStream.Dispose()
  $inStream.Dispose()
}
Add-DocPart '[Content_Types].xml'
Add-DocPart '_rels/.rels'
Add-DocPart 'word/document.xml'
Add-DocPart 'word/styles.xml'
Add-DocPart 'word/_rels/document.xml.rels'
Add-DocPart 'word/media/image1.png'
Add-DocPart 'word/media/image2.png'
Add-DocPart 'word/media/image3.png'
Add-DocPart 'word/media/image4.png'
$zip.Dispose()
Remove-Item $staging -Recurse -Force

$item = Get-Item $outDocx
Write-Output ("DOCX_OK " + $item.FullName + " size=" + $item.Length)
