#!/bin/bash

# Log function call for debugging
echo "$(date): Triggering vpn_toggle.sh..." >>/tmp/vpn_toggle.log

# Check if openvpn is running
if pgrep openvpn >/dev/null; then
	echo "$(date): OpenVPN is running, attempting to stop it." >>/tmp/vpn_toggle.log
	#
	# Stop OpenVPN
	sudo killall openvpn

	if [ $? -eq 0 ]; then
		echo "$(date): Successfully stopped OpenVPN." >>/tmp/vpn_toggle.log
	else
		echo "$(date): Failed to stop OpenVPN." >>/tmp/vpn_toggle.log
	fi
else
	echo "$(date): OpenVPN is not running, attempting to start it." >>/tmp/vpn_toggle.log

	# Start OpenVPN
	sudo openvpn --config /home/daniel/.config/.openvpn/sdui-vpn-1.0.ovpn &

	if [ $? -eq 0 ]; then
		echo "$(date): Successfully started OpenVPN." >>/tmp/vpn_toggle.log
	else
		echo "$(date): Failed to start OpenVPN." >>/tmp/vpn_toggle.log
	fi
fi
