$EcowittCredential = Get-AutomationPSCredential -Name "creds-ecowitt"
$body = "account=" + $EcowittCredential.UserName.Replace("@","%40") + "&password=" + $EcowittCredential.GetNetworkCredential().Password
$auth = Invoke-WebRequest -Uri "https://webapi.www.ecowitt.net/user/site/login" -Method POST -Body $body -SessionVariable WebSession -UseBasicParsing

$header = @{
    'Cookie'="ousaite_language=english; ousaite_frompath=auth; $(($auth.Headers.'Set-Cookie').Split(";")[0]); ousaite_loginstatus=1"
}

$body2 = "uid=&type=1"
$getDevices = Invoke-RestMethod -Uri "https://webapi.www.ecowitt.net/index/get_devices" -Method Post -Headers $header -WebSession $WebSession -Body $body2

$deviceID = "device_id=$(($getDevices.device_list).id)"
$devices = Invoke-Restmethod -Uri "https://webapi.www.ecowitt.net/index/home" -Headers $header -Method POST -body $deviceID -WebSession $WebSession
$output = @()
$output += $devices.data.ch_temp_humidity1.title + " " + $devices.data.ch_temp_humidity1.data.temp1f.value + " " + $devices.data.ch_temp_humidity1.data.temp1f.time
$output += $devices.data.ch_temp_humidity2.title + " " + $devices.data.ch_temp_humidity2.data.temp2f.value + " " + $devices.data.ch_temp_humidity2.data.temp2f.time
$output = $output | Out-String

if ($devices.data.ch_temp_humidity1.data.temp1f.time -igt (get-date).AddMinutes(60) -and $devices.data.ch_temp_humidity2.data.temp2f.time -igt (get-date).AddMinutes(60) ) {
    #write-host "true"
    $output
}
Else {
    .\Email-Runbook.ps1 `
        -RunbookName "AzureAutomation-Ecowitt" `
        -MessageBody "$output"
}
