<#
.SYNOPSIS
    Powershell Function for sending a notification to a Microsoft Teams channel.
    https://www.thelazyadministrator.com/2018/12/11/post-inactive-users-as-a-microsoft-teams-message-with-powershell/
    http://mikeconjoice.com/2018/05/25/send-a-notification-to-microsoft-teams-via-powershell/
.DESCRIPTION
    This Powershell function can be used for sending a notification to a Microsoft Teams channel.
    The function takes the input from the $text variable and converts it to a compatible JSON payload to be delivered to the specified Microsoft Teams webhook.
.EXAMPLE
    PS C:\> Send-toTeams -webhook $channel -text "Hello World!"
    Sends the text "Hello World!" to the channel associated with the webhook stored in the $channel variable.
.PARAMETER webhook
    Specifies the URL of the Webhook provided by the Microsoft Teams Webhook Connector.
.PARAMETER text
    Specifies the text which you wish to be send to the Microsoft Teams channel.
#>
#    param (
#    [Parameter(Mandatory=$false)]$text,
#    [Parameter(Mandatory=$false)]$webhook
#    )
    
#Specify Install source / Version / Logging path
$source = "\\Servername\Share\Teams\"
$SourceVersion = "Teams-MDT-Notification"
$Version = "V1"
$logPath = "C:\windows\MDT"

#Sets working directory and begins Powershell transcript
Set-Location $source
Start-Transcript $logPath\$SourceVersion.$version.PSLog.Txt
    
    
    #Webhook URL
    if (!($webhook))
    {
        $webhook = "https://outlook.office.com/webhook/#####INSERT UNIQUE WEBHOOK URL#####"
    }

     if (!($text))
    {
        $text = "MDT - Image Run"
    }

    #Set ImageName
    If ($env:COMPUTERNAME -like "WIN16*ADMIN*")
    {$imagename = "ADMIN-2016"}
    If ($env:COMPUTERNAME -like "WIN16*HELP*")
    {$imagename = "HelpDesk-2016"}

    #Server 2012R2
    If ($env:COMPUTERNAME -like "WIN12*ADMIN*")
    {$imagename = "ADMIN-2012R2"}
    If ($env:COMPUTERNAME -like "WIN12*Fin*")
    {$imagename = "Finance-2012R2"}


    #Image on the left hand side, here I have a regular user picture
    $ItemImage = 'https://img.icons8.com/color/1600/circled-user-male-skin-type-1-2.png'

    #Defining Arrays
    $ArrayTable = New-Object 'System.Collections.Generic.List[System.Object]'

    $timestamp = get-date #-Format MM-dd-yy-HHmm
    $obj = [PSCustomObject]@{
		activityTitle = "Image Name: $($ImageName)"
		activitySubtitle = "Image Details: \\\ServerName\Share\LocationOfWhereYouAreSendingLogs"
		activityText  = "$($text)"
		activityImage = $ItemImage
		facts		  = @(
			@{
				name  = 'Timestamp:'
				value = "$($timestamp)"
			},
            @{
				name  = 'Computername:'
				value = "$($env:COMPUTERNAME)"
			},
            @{
				name  = 'fact3'
				value = "fact3 Info"
			}
        )
	}
    $ArrayTable.add($obj)
    
    $body = ConvertTo-Json -Depth 8 @{
	title = "MDT New Image - Notification"
	text  = "There are $($ArrayTable.Count) items in this array"
	sections = $ArrayTable
	
    }

    Invoke-RestMethod -Method post -ContentType 'Application/Json' -Body $body -Uri $webhook  


    Stop-Transcript
