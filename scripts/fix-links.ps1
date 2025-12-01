param(
  [string]$Root = "c:\\Users\\eduardosouza\\Desktop\\Site_WC_copia\\mirror"
)

Get-ChildItem -Path $Root -Recurse -Filter *.html | ForEach-Object {
  $p = $_.FullName
  $html = Get-Content -Path $p -Raw
  $updated = $html
  $updated = $updated -replace 'href="//', 'href="/'
  $updated = $updated -replace "href='//", "href='/"
  $updated = $updated -replace 'src="//', 'src="/'
  $updated = $updated -replace "src='//", "src='/"
  $updated = $updated -replace "//wp-content/", "/wp-content/"
  if($updated -ne $html){ Set-Content -Path $p -Value $updated -Encoding UTF8 }
}
Write-Host "Links corrigidos em arquivos HTML sob: $Root" -ForegroundColor Cyan
