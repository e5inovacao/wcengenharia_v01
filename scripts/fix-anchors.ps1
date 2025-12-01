param(
  [string]$File = "c:\\Users\\eduardosouza\\Desktop\\Site_WC_copia\\mirror\\index.html"
)

$html = Get-Content -Path $File -Raw

# Ajustar hrefs do menu
$html = $html -replace 'href=\s*"/#home"', 'href="/#home"'
$html = $html -replace 'href=\s*"#quemsomos"', 'href="#quem-somos"'
$html = $html -replace 'href=\s*"#serviços"', 'href="#servicos"'
$html = $html -replace 'href=\s*"#contato"', 'href="#contato"'

# Inserir ids nas seções
$html = [regex]::Replace($html, '(<div\s+class="[^"]*elementor-element-0d98571[^"]*"\s+)', '$1id="home" ')
$html = [regex]::Replace($html, '(<div\s+class="[^"]*elementor-element-c9db46c[^"]*"\s+)', '$1id="servicos" ')
$html = [regex]::Replace($html, '(<div\s+class="[^"]*elementor-element-bfdf9a3[^"]*"\s+)', '$1id="quem-somos" ')
$html = [regex]::Replace($html, '(<div\s+class="[^"]*elementor-element-f10b7db[^"]*"\s+)', '$1id="contato" ')

Set-Content -Path $File -Value $html -Encoding UTF8
Write-Host "Âncoras e ids corrigidos em: $File" -ForegroundColor Cyan
