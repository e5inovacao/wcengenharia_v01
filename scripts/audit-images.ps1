param(
  [string]$Root = "c:\\Users\\eduardosouza\\Desktop\\Site_WC_copia\\mirror",
  [string]$BaseUrl = "https://wcengenharia.eng.br",
  [switch]$FixMissing
)

$supportedExt = @('.png','.jpg','.jpeg','.gif','.svg','.webp','.ico','.avif')
function Ensure-Dir([string]$path){ if(!(Test-Path $path)){ New-Item -ItemType Directory -Path $path | Out-Null } }
function Map-Local([string]$url){ if([string]::IsNullOrWhiteSpace($url)){ return $null } if($url.StartsWith('/')){ return (Join-Path $Root ($url.TrimStart('/'))) } else { return $null } }
function ToAbs([string]$url){ try { if([string]::IsNullOrWhiteSpace($url)){ return $null } if($url.StartsWith('/')){ return $BaseUrl + $url } else { return $url } } catch { return $null } }

function Extract-ImgRefs([string]$html){
  $refs = New-Object System.Collections.Generic.List[object]
  $imgPattern = "(?is)<img\s+[^>]*>"
  $imgs = [regex]::Matches($html, $imgPattern)
  foreach($im in $imgs){
    $tag = $im.Value
    $src = ([regex]::Match($tag, "src=\s*[`"']([^`"']+)[`"']")).Groups[1].Value
    $srcset = ([regex]::Match($tag, "srcset=\s*[`"']([^`"']+)[`"']")).Groups[1].Value
    $alt = ([regex]::Match($tag, "alt=\s*[`"']([^`"']*)[`"']")).Groups[1].Value
    $refs.Add([pscustomobject]@{ tag=$tag; src=$src; srcset=$srcset; alt=$alt })
  }
  return $refs
}

function Split-Srcset([string]$srcset){
  $list = New-Object System.Collections.Generic.List[string]
  if([string]::IsNullOrWhiteSpace($srcset)){ return $list }
  foreach($part in $srcset.Split(',')){
    $u = ($part.Trim().Split(' ')[0])
    if($u){ $list.Add($u) }
  }
  return $list
}

$report = @()
$htmlFiles = Get-ChildItem -Path $Root -Recurse -Filter *.html
foreach($file in $htmlFiles){
  $html = Get-Content -Path $file.FullName -Raw
  $refs = Extract-ImgRefs $html
  foreach($r in $refs){
    $items = New-Object System.Collections.Generic.List[string]
    if($r.src){ $items.Add($r.src) }
    foreach($u in (Split-Srcset $r.srcset)){ $items.Add($u) }
    foreach($u in $items){
      $local = Map-Local $u
      $exists = $false
      $pathCandidate = if($local){ $local } else { $u }
      $ext = [IO.Path]::GetExtension($pathCandidate).ToLowerInvariant()
      $supported = $supportedExt -contains $ext
      if($local){ $exists = Test-Path $local }
      $entry = [pscustomobject]@{ file=$file.FullName; tag=$r.tag; url=$u; local=$local; exists=$exists; ext=$ext; supported=$supported }
      $report += $entry
      if(!$exists -and $FixMissing){
        $abs = ToAbs $u
        if($abs){
          try{
            if($local){ Ensure-Dir $local }
            Invoke-WebRequest -Uri $abs -OutFile $local -UseBasicParsing -TimeoutSec 30 -ErrorAction Stop
            $entry.exists = (Test-Path $local)
          } catch {
            Write-Host "Falha ao baixar: $abs" -ForegroundColor Yellow
          }
        }
      }
    }
  }
}

$outJson = Join-Path $Root "audit-images.json"
$outTxt = Join-Path $Root "audit-images.txt"
$report | ConvertTo-Json -Depth 4 | Set-Content -Path $outJson -Encoding UTF8
$report | ForEach-Object { "$($_.exists)`t$($_.supported)`t$($_.ext)`t$($_.file)`t$($_.url)" } | Set-Content -Path $outTxt -Encoding UTF8
Write-Host "Relatório gerado: $outJson | $outTxt" -ForegroundColor Cyan
