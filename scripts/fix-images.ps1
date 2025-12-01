param(
  [string]$Root = "c:\\Users\\eduardosouza\\Desktop\\Site_WC_copia\\mirror"
)

function Exists([string]$root, [string]$url){ if([string]::IsNullOrWhiteSpace($url)){ return $false } if($url.StartsWith('/')){ return Test-Path (Join-Path $root ($url.TrimStart('/'))) } else { return $false } }

Get-ChildItem -Path $Root -Recurse -Filter *.html | ForEach-Object {
  $p = $_.FullName
  $html = Get-Content -Path $p -Raw
  $updated = $html
  # Reescrever CDN do TrustIndex para arquivo local se existir
  $updated = $updated -replace 'https://cdn\.trustindex\.io/assets/platform/Google/logo\.svg', '/assets/platform/Google/logo.svg'

  # Limpar srcset removendo URLs inexistentes
  $pattern = "(?is)srcset\s*=\s*[`"']([^`"']+)[`"']"
  $updated = [regex]::Replace($updated, $pattern, {
    param($m)
    $orig = $m.Groups[1].Value
    $parts = $orig.Split(',') | ForEach-Object { $_.Trim() }
    $kept = @()
    foreach($part in $parts){
      $url = ($part.Split(' ')[0])
      if((Exists $Root $url)){ $kept += $part }
    }
    $new = ($kept -join ', ')
    return 'srcset="' + $new + '"'
  })

  if($updated -ne $html){ Set-Content -Path $p -Value $updated -Encoding UTF8 }
}
Write-Host "Imagens corrigidas: srcset saneado e CDN TrustIndex reescrito" -ForegroundColor Cyan
