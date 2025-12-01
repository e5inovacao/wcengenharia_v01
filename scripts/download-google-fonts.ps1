param(
    [string]$CssUrl,
    [string]$OutDir = "c:\\Users\\eduardosouza\\Desktop\\Site_WC_copia\\mirror\\assets\\fonts",
    [int]$TimeoutSec = 30
)

function Ensure-Dir([string]$path){ if(!(Test-Path $path)){ New-Item -ItemType Directory -Path $path | Out-Null } }
function Download-File([string]$url, [string]$dest){ try{ Invoke-WebRequest -Uri $url -OutFile $dest -UseBasicParsing -TimeoutSec $TimeoutSec -ErrorAction Stop; return $true } catch { Write-Host "Falha: $url => $dest - $($_.Exception.Message)" -ForegroundColor Yellow; return $false } }

if([string]::IsNullOrWhiteSpace($CssUrl)){ Write-Error "Informe CssUrl"; exit 1 }
Ensure-Dir $OutDir
$cssPath = Join-Path $OutDir "roboto.css"
Invoke-WebRequest -Uri $CssUrl -OutFile $cssPath -UseBasicParsing -TimeoutSec $TimeoutSec
$css = Get-Content -Path $cssPath -Raw

$pattern = "url\((https?:\/\/[^\)]+)\)"
$m = [regex]::Matches($css, $pattern)
foreach($item in $m){
    $fontUrl = $item.Groups[1].Value
    $name = [IO.Path]::GetFileName([Uri]$fontUrl)
    $dest = Join-Path $OutDir $name
    if(!(Test-Path $dest)){
        Download-File $fontUrl $dest | Out-Null
    }
}

Write-Host "Fonts baixadas em: $OutDir | CSS: $cssPath" -ForegroundColor Cyan
