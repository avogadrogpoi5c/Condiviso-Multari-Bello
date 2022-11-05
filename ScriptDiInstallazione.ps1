$apiUrl = "https://store.rg-adguard.net/api/GetFiles"

$productUrl = "https://apps.microsoft.com/store/detail/windows-terminal/9N0DX20HK701" # metti qui il link del programma da scaricare

$downloadFolder = Join-Path $env:TEMP "StoreDownloads"
if(!(Test-Path $downloadFolder -PathType Container)) {
    New-Item $downloadFolder -ItemType Directory -Force
}

$body = @{
    type = 'url'
    url  = $productUrl
    ring = 'RP'
    lang = 'en-US'
}

$raw = Invoke-RestMethod -Method Post -Uri $apiUrl -ContentType 'application/x-www-form-urlencoded' -Body $body

$raw | Select-String '<tr style.*<a href=\"(?<url>.*)"\s.*>(?<text>.*)<\/a>' -AllMatches|
 % { $_.Matches } |
 % { 
    $url = $_.Groups[1].Value
    $text = $_.Groups[2].Value
    Write-Host $text

    if($text -match "_(x86|x64|neutral).*appx(|bundle)$") {
        $downloadFile = Join-Path $downloadFolder $text
        if(!(Test-Path $downloadFile)) {
            Invoke-WebRequest -Uri $url -OutFile $downloadFile
        }
    }
}
