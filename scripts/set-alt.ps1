param(
  [string]$Root = "c:\\Users\\eduardosouza\\Desktop\\Site_WC_copia\\mirror"
)

Get-ChildItem -Path $Root -Recurse -Filter *.html | ForEach-Object {
  $p = $_.FullName
  $html = Get-Content -Path $p -Raw
  $updated = $html
  $updated = $updated -replace 'alt=""', 'alt="Imagem"'
$updated = [regex]::Replace($updated, '(<img[^>]*src="/wp-content/uploads/2024/02/Design-sem-nome-69-150x150\.png"[^>]*?)alt="Imagem"', '$1alt="WC ENGENHARIA – logotipo"')
  if($updated -ne $html){ Set-Content -Path $p -Value $updated -Encoding UTF8 }
}
Write-Host "Alt tags atualizadas" -ForegroundColor Cyan
