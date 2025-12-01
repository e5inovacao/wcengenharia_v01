param(
    [string]$BaseUrl = "https://wcengenharia.eng.br",
    [string]$OutRoot = "c:\\Users\\eduardosouza\\Desktop\\Site_WC_copia\\mirror",
    [int]$MaxPages = 200,
    [int]$TimeoutSec = 30
)

function Ensure-Dir([string]$path){
    $dir = Split-Path -Parent $path
    if($dir -and !(Test-Path $dir)){
        New-Item -ItemType Directory -Path $dir | Out-Null
    }
}

function Map-UrlToLocalPath([string]$url, [string]$root){
    $u = [Uri]$url
    $path = $u.AbsolutePath
    if([string]::IsNullOrEmpty($path) -or $path -eq "/"){
        return (Join-Path $root "index.html")
    }
    # Remove trailing slash
    if($path.EndsWith('/')){ $path = $path.TrimEnd('/') }
    $fname = [IO.Path]::GetFileName($path)
    if([string]::IsNullOrEmpty($fname)){
        # Path sem arquivo: usar index.html dentro da pasta
        return (Join-Path $root (Join-Path ($path.TrimStart('/')) "index.html"))
    }
    # Se não tiver extensão, tratar como página e salvar como index.html na pasta
    if([string]::IsNullOrEmpty([IO.Path]::GetExtension($fname))){
        return (Join-Path $root (Join-Path ($path.TrimStart('/')) "index.html"))
    }
    return (Join-Path $root ($path.TrimStart('/')))
}

function Get-AbsoluteUrl([string]$base, [string]$link){
    try{
        if([string]::IsNullOrWhiteSpace($link)){ return $null }
        if($link.StartsWith('#')){ return $null }
        # Ignorar mailto, tel
        if($link -match '^(mailto:|tel:|javascript:)'){ return $null }
        $b = [Uri]$base
        $abs = New-Object Uri $b, $link
        return $abs.AbsoluteUri
    } catch { return $null }
}

function Is-SameHost([Uri]$a, [Uri]$b){
    return ($a.Host -eq $b.Host)
}

function Download-File([string]$url, [string]$dest){
    try{
        Ensure-Dir $dest
        Invoke-WebRequest -Uri $url -OutFile $dest -UseBasicParsing -TimeoutSec $TimeoutSec -ErrorAction Stop
        return $true
    } catch {
        Write-Host "Falha ao baixar: $url => $dest : $($_.Exception.Message)" -ForegroundColor Yellow
        return $false
    }
}

function Extract-Links([string]$html){
    $links = New-Object System.Collections.Generic.List[string]
    if([string]::IsNullOrEmpty($html)){ return $links }
    $pattern = "(?i)(?:href|src)=[`"']([^`"'#]+)[`"']"
    $matches = [regex]::Matches($html, $pattern)
    foreach($m in $matches){ $links.Add($m.Groups[1].Value) }
    return $links
}

function Rewrite-HostRefs-ToRoot([string]$html, [string]$baseHost){
    if([string]::IsNullOrEmpty($html)){ return $html }
    $html = $html -replace [regex]::Escape("https://$baseHost"), "/"
    $html = $html -replace [regex]::Escape("http://$baseHost"), "/"
    return $html
}

$baseUri = [Uri]$BaseUrl
Write-Host "Base: $BaseUrl" -ForegroundColor Cyan
if(!(Test-Path $OutRoot)){
    New-Item -ItemType Directory -Path $OutRoot | Out-Null
}

$visited = New-Object System.Collections.Generic.HashSet[string]
$queue = New-Object System.Collections.Queue
$queue.Enqueue($BaseUrl)

$pageCount = 0
while($queue.Count -gt 0 -and $pageCount -lt $MaxPages){
    $current = [string]$queue.Dequeue()
    if($visited.Contains($current)){ continue }
    $visited.Add($current) | Out-Null
    $pageCount++
    Write-Host "[${pageCount}] Baixando página: $current" -ForegroundColor Green
    try{
        $resp = Invoke-WebRequest -Uri $current -UseBasicParsing -TimeoutSec $TimeoutSec -ErrorAction Stop
        $html = $resp.Content
        # Salvar página
        $dest = Map-UrlToLocalPath $current $OutRoot
        $htmlLocal = Rewrite-HostRefs-ToRoot $html $baseUri.Host
        Ensure-Dir $dest
        Set-Content -Path $dest -Value $htmlLocal -Encoding UTF8

        # Extrair links
        $links = Extract-Links $html
        foreach($l in $links){
            $abs = Get-AbsoluteUrl $current $l
            if(!$abs){ continue }
            $absUri = [Uri]$abs
            $ext = [IO.Path]::GetExtension($absUri.AbsolutePath).ToLowerInvariant()
            $isAsset = $ext -in @('.css','.js','.jpg','.jpeg','.png','.gif','.svg','.webp','.ico','.woff','.woff2','.ttf','.otf','.mp4','.webm')
            if($isAsset){
                $destAsset = Map-UrlToLocalPath $abs $OutRoot
                if(!(Test-Path $destAsset)){
                    Download-File $abs $destAsset | Out-Null
                }
            } else {
                if(Is-SameHost $baseUri $absUri){
                    if(!$visited.Contains($abs)){
                        $queue.Enqueue($abs)
                    }
                }
            }
        }
    } catch {
        Write-Host "Erro ao baixar página: $current - $($_.Exception.Message)" -ForegroundColor Yellow
    }
}

Write-Host "Concluído. Páginas: $pageCount | Saída: $OutRoot" -ForegroundColor Cyan
