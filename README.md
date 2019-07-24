<img src="logo/logo.svg" align="right"
     title="Azure Security Center for IoT" width="100" height="158">
    
# Azure Security Center for IoT

## Samples repository

Azure Security Center for IoT provides reference architecture for security agents that log, process, aggregate, and send security data through IoT Hub.
Azure IoT security agents are designed to work in a constrained IoT environment, and are highly customizable in terms of values they provide when compared to the resources they consume.

Security agents support the following IoT solution features:
- Collect raw security events from the underlying OS (Linux, Windows). To learn more about available security data collectors, see [ASC for IoT agent configuration](https://aka.ms/iot-security-docs-config).
- Aggregate raw security events into messages sent through IoT hub.
- Authenticate with existing device identity, or a dedicated module identity. See [Security agent authentication methods](https://aka.ms/iot-security-docs-auth) to learn more.
- Configure remotely through use of the azureiotsecurity module twin. To learn more, see [Configure an ASC for IoT agent](https://aka.ms/iot-security-docs-config).

In this repository, you'll find useful scripts and snippets to get you started with Azure Security Center for IoT.

- _security_message_ - supported security event types, event schemas and event samples
- _securty_module_twin_ - security agent configuration through IoT Hub module twin, twin schema, defaults, and automation scripts
- _trigger_events_ - scripts to imitate malicious activity on an IoT device, in order to test and validate security agent proper behavior

Learn more about:

- Azure Security Center for IoT [security agents](https://aka.ms/iot-security-docs-agents)
- Azure Security Center for IoT security agent reference architecture for C, on [Github](https://aka.ms/iot-security-github-c)
- Azure Security Center for IoT security agent reference architecture for C#, on [Github](https://aka.ms/iot-security-github-cs)

## Contributing

This project welcomes contributions and suggestions.  Most contributions require you to agree to a
Contributor License Agreement (CLA) declaring that you have the right to, and actually do, grant us
the rights to use your contribution. For details, visit https://cla.microsoft.com.

When you submit a pull request, a CLA-bot will automatically determine whether you need to provide
a CLA and decorate the PR appropriately (e.g., label, comment). Simply follow the instructions
provided by the bot. You will only need to do this once across all repos using our CLA.

This project has adopted the [Microsoft Open Source Code of Conduct](https://opensource.microsoft.com/codeofconduct/).
For more information see the [Code of Conduct FAQ](https://opensource.microsoft.com/codeofconduct/faq/) or
contact [opencode@microsoft.com](mailto:opencode@microsoft.com) with any additional questions or comments.
