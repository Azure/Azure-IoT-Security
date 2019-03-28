# Add-SecurityModulesForAllDevicesInIotHub

## SYNOPSIS
This script will create and populate a security module for each device in the given IoT hub.

In case the security module already exists for a device, it isn't changed.

Please notice that the script needs to be rerun every time a new device is connected to the IoT hub.

## SYNTAX

```
Add-SecurityModulesForAllDevicesInIotHub.ps1 [-IotHubConnectionString] <String>
 [<CommonParameters>]
```

## DESCRIPTION
The security module will include the initial configuration for the security agent.

For details on initial twin configuration see [Security module twin](/security_module_twin/azureiotsecurity_default.json).

## EXAMPLES

```
Add-SecurityModulesForAllDevicesInIotHub.ps1 -IotHubConnectionString "HostName=my-iot-hub.azure-devices.net;SharedAccessKeyName=iothubowner;SharedAccessKey=key" 
```

## PARAMETERS

### -IotHubConnectionString
A connection string for a shrared access policy with 'RegistryWrite' and 'ServiceConnect' permissions

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```