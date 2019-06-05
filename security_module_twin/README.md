# Security message twin

ASC for IoT provides reference architectures for security agents that monitor and collect data from IoT devices.
Agents can be easily configured through _desired_ twin properties in IoT hub. in a module twin named _azureiotsecurity_.

In this directory, you can find:

- _azureiotsecurity_default.json_ - default values for agent configuration
- _azureiotsecurity_schema.json_ - schema for security module twin, written in [JSON Schema](https://json-schema.org/) to allow for easy validation
- _azureiotsecurity_schema_dtdl.json - schema for security module twin, written in DTDL [DTDL](https://github.com/Azure/IoTPlugandPlay)
- _create_security_module_ - powershell script that creates and populates security module twin for each device in the iot hub

Note:
ASC for IoT agent currently does not support Azure PnP,
DTDL Schema is published for forward compatability

See also:

- ASC for IoT security agents on [Azure Docs](https://aka.ms/iot-security-docs-agents)
- ASC for IoT security agent reference architecture for C, on [Github](https://aka.ms/iot-security-github-c)
- ASC for IoT security agent reference architecture for C#, on [Github](https://aka.ms/iot-security-github-cs)
- IoT Hub desired twin properties on [Azure Docs](https://docs.microsoft.com/en-us/azure/iot-hub/iot-hub-devguide-device-twins#desired-property-example)