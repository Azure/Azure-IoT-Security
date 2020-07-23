# Trigger events

This script imitates malicious activity on the device.
Use the script for end to end validation of the agent.

# Prerequisites
In order to run the script you need to have netcat installed on your machine
you can install it by `sudo apt-get install netcat`

# Usage

```sh
trigger_events.sh | flags
	--exploit (?additional ports) - opens and listen to ports 8888 and additional ports on the device
		additional ports          - number of additional ports. i.e `-e 3` will open ports 8888,8889,8900"
	--remediate - closes port 8888 (only if port 8888 was opened with --exploit)
	--malicious - runs a fake malicious process on the device
```

!! The script must be run as root (sudo).

# What should I see?
When using the --exploit flag, a recommendation about the open port should pop up in the securty tab of your IoT hub.
The scripts outputs the communication on port 8888 to ./port8888.output file located in the script directory.
Using the --remediate flag should supress the above recommendation.
If malicious flag is used, an alert should pop up in the securty tab of your IoT hub - letting the user know that a malicious process ran on the machine.
