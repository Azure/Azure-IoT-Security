<#
.SYNOPSIS
    This script will create and populate a security module for each device in the given IoT hub
    In case the security module already exists for a device, it isn't changed.
    Please notice that the script needs to be rerun every time a new device is connected to the IoT hub.

.DESCRIPTION
    The security module will include the initial configuration for the security agent
    Initial configuration is described in the script README file

.EXAMPLE
    Add-SecurityModulesForAllDevicesInIotHub.ps1 -IotHubConnectionString "HostName=my-iot-hub.azure-devices.net;SharedAccessKeyName=iothubowner;SharedAccessKey=key"
#>

#######################################################################################################################################
# SCRIPT PARAMETERS
#######################################################################################################################################
param
(
    [Parameter(Mandatory=$true)]
    [string]
    $IotHubConnectionString
)

#######################################################################################################################################
# CONSTANTS
#######################################################################################################################################
$SECURITY_MODULE_NAME = "azureiotsecurity"
$AGENT_CONFIGURATION_SECTION_NAME = "azureiot*com^securityAgentConfiguration^1*0*0"

#######################################################################################################################################
# HELPER FUNCTIONS
#######################################################################################################################################
function ParseConnectionString($connectionString) {
    if (!($connectionString -match "HostName=([^;]*);SharedAccessKeyName=([^;]*);SharedAccessKey=([^;]*)")) {
        throw "Invalid connection string '$connectionString'. Please enter a connection string in the format of 'HostName=[HostName];SharedAccessKeyName=[SharedAccessKeyName];SharedAccessKey=[SharedAccessKey]'"
    }

    return @{
                hubUri = $Matches[1]
                policyName = $Matches[2]
                key = $Matches[3]
            }
}

function CreateToken($iotHubConnectionParameters) {
    [System.TimeSpan]$fromEpochStart = [System.DateTime]::UtcNow - (New-Object System.DateTime -ArgumentList 1970, 1, 1)
    $expiry = [System.Convert]::ToString([int]$fromEpochStart.TotalSeconds + (60 * 60 * 10))
    $stringToSign = [System.Net.WebUtility]::UrlEncode($iotHubConnectionParameters.hubUri) + "`n" + $expiry
    $hmac = New-Object System.Security.Cryptography.HMACSHA256 -ArgumentList @(,([System.Convert]::FromBase64String($iotHubConnectionParameters.key)))
    $signature = [System.Convert]::ToBase64String($hmac.ComputeHash([System.Text.Encoding]::UTF8.GetBytes($stringToSign)))
    $token = [System.String]::Format([System.Globalization.CultureInfo]::InvariantCulture, "SharedAccessSignature sr={0}&sig={1}&se={2}&skn={3}", [System.Net.WebUtility]::UrlEncode($iotHubConnectionParameters.hubUri), [System.Net.WebUtility]::UrlEncode($signature), $expiry, $iotHubConnectionParameters.policyName)

    return $token
}

function CreateQuery($queryString, $token, $hubUri) {
    return @{ queryString = $queryString; continuationToken = ""; token = $token; hubUri = $hubUri; hasMoreResults = $true }
}

function Query_GetMoreResults($query) {
    $body = "{""query"": ""$($query.queryString)"" }"
    $headers = @{"Authorization" = $query.token; "x-ms-continuation" = $query.continuationToken}
    
    try {
        $response = Invoke-WebRequest -Method Post -Headers $headers -ContentType "application/json; charset=utf-8" -Uri "https://$($query.hubUri)/devices/query?api-version=2018-06-30" -Body $body
        $query.continuationToken = $response.Headers["x-ms-continuation"]
        if ($query.continuationToken -eq "" -or $query.continuationToken -eq $null) {
            $query.hasMoreResults = $false
        }

        return $response.Content
    }
    catch {
        throw "Got an error while trying to execute query. Message:$($_.Exception.Message)"
    }
}

function CreateAndPopulateSecurityModuleForDevice($deviceId, $hubUri, $token) {
    # Create the module
    $requestJson = @{
        deviceId = $deviceId
        moduleId = $SECURITY_MODULE_NAME
    }
    $body = ConvertTo-Json -Depth 10 $requestJson
    $headers = @{"Authorization" = $token}
    try {
        Invoke-WebRequest -Method Put -Headers $headers -ContentType "application/json; charset=utf-8" -Uri "https://$hubUri/devices/$deviceId/modules/$($SECURITY_MODULE_NAME)?api-version=2018-06-30" -Body $body
    }
    catch {
        if ($_.Exception.Response.StatusCode -ne 409) {
            Write-Error "Got an error while trying to create security module for device '$deviceId'. Message:$($_.Exception.Message)" 
            return $false
        }
    }
    
    # Populate the module
    $requestJson = @{
        deviceId = $deviceId
        moduleId = $SECURITY_MODULE_NAME
        tags = @{
            securityGroup = "default"
        }
        properties = @{
            desired = @{
                $AGENT_CONFIGURATION_SECTION_NAME = @{
                    highPriorityMessageFrequency = "PT7M"
                    lowPriorityMessageFrequency = "PT5H"
                    snapshotFrequency = "PT13H"
                    maxLocalCacheSizeInBytes = "2560000"
                    maxMessageSizeInBytes = "204800"
                    eventPriorityConnectedHardware = "Low"
                    eventPriorityListeningPorts = "High"
                    eventPriorityProcessCreate = "Low"
                    eventPriorityProcessTerminate = "Low"
                    eventPrioritySystemInformation = "Low"
                    eventPriorityLocalUsers = "High"
                    eventPriorityLogin = "High"
                    eventPriorityConnectionCreate = "Low"
                    eventPriorityFirewallConfiguration = "Low"
                    eventPriorityOSBaseline = "Low"
                    eventPriorityDiagnostic = "Low"
                    eventPriorityConfigurationError = "Low"
                    eventPriorityDroppedEventsStatistics = "Low"
                    eventPriorityMessageStatistics = "Low"
                }
            }    
        }
    }

    $body = ConvertTo-Json -Depth 10 $requestJson
    $headers = @{"Authorization" = $token}
    try {
        Invoke-WebRequest -Method Patch -Headers $headers -ContentType "application/json; charset=utf-8" -Uri "https://$hubUri/twins/$deviceId/modules/$($SECURITY_MODULE_NAME)?api-version=2018-06-30" -Body $body
    }
    catch {
        Write-Error "Got an error while trying to populate security module for device '$deviceId'. Message: $($_.Exception.Message)" 
        return $false
    }   

    return $true
}

function GetDevicesWithSecurityModule($hubUri, $token) {
    $res = @()
    $queryString = "SELECT deviceId FROM devices.modules WHERE moduleId = '$SECURITY_MODULE_NAME' and IS_DEFINED(properties.desired.[[$AGENT_CONFIGURATION_SECTION_NAME]])"
    $query = CreateQuery -queryString $queryString -token $token -hubUri $hubUri
    do {
        $queryResult = Query_GetMoreResults -query $query
        $res += (ForEach-Object -InputObject (ConvertFrom-Json $queryResult) {$_.DeviceId})
    } while ($query.hasMoreResults)

    return ,$res 
}

#######################################################################################################################################
# MAIN
#######################################################################################################################################
$iotHubConnectionParameters = ParseConnectionString -connectionString $IotHubConnectionString
$token = CreateToken -iotHubConnectionParameters $iotHubConnectionParameters
$devicesWithSecurityModule = GetDevicesWithSecurityModule -hubUri $iotHubConnectionParameters.hubUri -token $token

$queryString = "SELECT deviceId FROM devices"
$query = CreateQuery -queryString $queryString -token $token -hubUri $iotHubConnectionParameters.hubUri

$successfulModuleCreateOperations = 0
$unSuccessfulModuleCreateOperations = 0

do {
    $queryResult = Query_GetMoreResults -query $query
    $devices = (ForEach-Object -InputObject (ConvertFrom-Json $queryResult) {$_.DeviceId})
    $devicesWithoutModule = $devices | where {!($devicesWithSecurityModule.Contains($_))}
    foreach ($device in $devicesWithoutModule) {
        if (CreateAndPopulateSecurityModuleForDevice -deviceId $device -hubUri $iotHubConnectionParameters.hubUri -token $token) {
            $successfulModuleCreateOperations += 1
        }
        else {
            $unSuccessfulModuleCreateOperations += 1
        }
    }
} while ($query.hasMoreResults)

Write-Host "Statistics:"
Write-Host "Number of devices that already have a security module: $($devicesWithSecurityModule.Count)"
Write-Host "Number of modules that was created successfully: $successfulModuleCreateOperations"
Write-Host "Number of modules that wasn't created successfully: $unSuccessfulModuleCreateOperations"