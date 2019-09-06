 Param(
                [Parameter(Mandatory=$False)]
                [string]$ScanServer
                )

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$cred = Get-Credential

#Authentication Only (grabbing Token and WebSession for subsequent calls)
$body = @{'username' = $Cred.UserName; 'password' = $Cred.GetNetworkCredential().password} | ConvertTo-Json -Compress
$TokenResponse = Invoke-Webrequest -Uri "https://$scanserver/rest/token" -Method Post -ContentType 'application/json' -Body $body -Credential $cred -ErrorVariable "NessusLoginError" -SessionVariable Websession -Verbose
$content = $TokenResponse.Content | ConvertFrom-Json


#List All Scans
$ListAllScans = Invoke-Webrequest -Uri "https://$scanserver/rest/scan?filter=usable&fields=canUse%2CcanManage%2Cowner%2Cgroups%2CownerGroup%2Cstatus%2Cname%2CcreatedTime%2Cschedule%2Cpolicy%2Cplugin%2Ctype" -Method Get -Headers @{"X-SecurityCenter"="$($content.response.token)"} -ContentType 'application/json' -WebSession $Websession -ErrorVariable "NessusLoginError" -Verbose
$ListAllScansInfo = $ListAllScans.Content | ConvertFrom-Json
Write-Host "Listing All Scans:" -ForegroundColor Yellow
$ListAllScansInfo.response.usable | Sort Name| FT Name,ID

#ListAllAssets
$ListAllAssets = Invoke-Webrequest -Uri "https://$scanserver/rest/asset?filter=excludeAllDefined%2Cusable%2Cusable&fields=canUse%2CcanManage%2Cowner%2Cgroups%2CownerGroup%2Cstatus%2Cname%2Ctype%2Ctemplate%2Cdescription%2CcreatedTime%2CmodifiedTime%2CipCount%2Crepositories%2CtargetGroup%2Ctags%2Ccreator" -Method Get -Headers @{"X-SecurityCenter"="$($content.response.token)"} -ContentType 'application/json' -WebSession $Websession -ErrorVariable "NessusLoginError" -Verbose
$ListAllAssetsInfo = $ListAllAssets.Content | ConvertFrom-Json
Write-Host "Listing All Assets:" -ForegroundColor Yellow
$ListAllAssetsInfo.response.usable | Sort Name | FT Name,ID

#Insert value from a single entry in 'List All Scans' or 'List All Assets'
#$scanID = "015"
#$AssetID = "26"

#ListAssetTarget
$ListAssetTarget = Invoke-Webrequest -Uri "https://$scanserver/rest/asset/$($assetID)?fields=name%2Ctype%2Ctemplate%2CsourceType%2CviewableIPs%2CipCount%2Ctags%2Cdescription%2CcreatedTime%2CmodifiedTime%2CexcludeManagedIPs%2Cowner%2CownerGroup%2Cgroups%2CcanUse%2CcanManage%2CtypeFields" -Method Get -Headers @{"X-SecurityCenter"="$($content.response.token)"} -ContentType 'application/json' -WebSession $Websession -ErrorVariable "NessusLoginError" -Verbose
$ListAssetTargetInfo = $ListAssetTarget.Content | ConvertFrom-Json
Write-Host "Listing Asset Target:" -ForegroundColor Yellow
$ListAssetTargetInfo.response.typeFields.definedDNSNames


#Get Scan Info
$GetScan = Invoke-Webrequest -Uri "https://$scanserver/rest/scan/$scanID" -Method Get -Headers @{"X-SecurityCenter"="$($content.response.token)"} -ContentType 'application/json' -WebSession $Websession -ErrorVariable "NessusLoginError" -Verbose
$GetscanInfo = $GetScan.Content | ConvertFrom-Json
Write-Host "Displaying Scan Info:" -ForegroundColor Yellow
$GetscanInfo.response

#Start Scan
$ActivateScan = Invoke-Webrequest -Uri "https://$scanserver/rest/scan/$scanID/launch" -Method Post -Headers @{"X-SecurityCenter"="$($content.response.token)"} -ContentType 'application/json' -WebSession $Websession -ErrorVariable "NessusLoginError" -Verbose
$ActivateScanInfo = $ActivateScan.Content | ConvertFrom-Json
Write-Host "Starting Scan Result:" -ForegroundColor Yellow
$ActivateScanInfo.response.scanResult.resultType


#Edit Asset Target
$NewAssetName = "servername.domain.com"
$body = @{definedDNSNames = $($NewAssetName)} | ConvertTo-Json -Compress
$EditAsset = Invoke-Webrequest -Uri "https://$scanserver/rest/asset/$AssetID" -Method Patch -Headers @{"X-SecurityCenter"="$($content.response.token)"} -ContentType 'application/json' -Body $body -WebSession $Websession -ErrorVariable "NessusLoginError" -Verbose
$EditAssetInfo = $EditAsset.Content | ConvertFrom-Json
Write-Host "Editing Asset:" -ForegroundColor Yellow
$EditAssetInfo.response

#Download Scan Result
$ScanResultID = "InsertScanResultIDNumber"
$OutputLoc = "C:\Temp\$ScanResultID.zip"
$DownloadScanResult = Invoke-Webrequest -Uri "https://$scanserver/rest/scanResult/$ScanResultID/download" -Method Post -Headers @{"X-SecurityCenter"="$($content.response.token)"} -ContentType 'application/json' -WebSession $Websession -ErrorVariable "NessusLoginError" -Verbose -OutFile $OutputLoc
Write-Host "Downloading Scan Result:" -ForegroundColor Yellow
Write-host "Status Code: $($DownloadScanResult.StatusCode)"
$DownloadScanResult.RawContent | Out-File $OutputLoc
