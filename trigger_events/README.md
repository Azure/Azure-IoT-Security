# Trigger events

This script imitates malicious activity on the device.
Use the script for end to end validation of the agent.

# Prerequisites
In order to run the script you need to have netcat installed on your machine 
you can install it by `sudo apt-get install netcat`

# Usage
trigger_events.sh | flags
	--exploit - opens port 8888 on the device and starts listening to it
	--remidiate - closes port 8888 (only if port 8888 was opened with --exploit)
	--malicious - runs a fake malicious process on the device

!! The script must be run as root (sudo).

# What should I see?
When using the --exploit flag, a recommandation about the open port should pop up in the securty tab of your IoT hub.
The scripts outputs the communication on port 8888 to ./port8888.output file located in the script directory.
Using the --remidiate flag should supress the above recommandation.
If malicious flag is used, an alert should pop up in the securty tab of your IoT hub - letting the user know that a malicious process ran on the machine.