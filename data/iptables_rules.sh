#!/bin/bash
# iptables rules script

# Constants
 WAN_IF="eth0"
 MAN_IP="0.0.0.0/0"

 PVT_IF="eth1"
 LAN_IP="10.136.0.0/16"

# Flush all current rules from iptables (ignores mangle, raw and security tables)
 iptables -F
 iptables -X
 iptables -t nat -F
 iptables -t nat -X

# Create user defined tables ###############
 iptables -N wan_in
 iptables -N wan_out
 iptables -N lan_in
 iptables -N lan_out

 iptables -N ssh_in

 iptables -N dns_in
 iptables -N dns_out
 iptables -N dhcp_in
 iptables -N dhcp_out
 iptables -N ntp_in
 iptables -N ntp_out
 iptables -N icmp_in
 iptables -N icmp_out
 iptables -N logging

# Default policies #########################
 iptables -P INPUT DROP
 iptables -P FORWARD DROP
 iptables -P OUTPUT DROP


# INPUT chain ##############################
 iptables -A INPUT -i lo     -j ACCEPT
 iptables -A INPUT -i WAN_IF -j wan_in
 iptables -A INPUT -i LAN_IF -j lan_in

 # WAN In chain #############################
 # Server
 iptables -A wan_in -p tcp --dport 22    -j ssh_in
 # Client
 iptables -A wan_in -p tcp --sport 53    -j dns_in
 iptables -A wan_in -p udp --sport 53    -j dns_in
 iptables -A wan_in -p udp --sport 67:68 -j dhcp_in
 iptables -A wan_in -p udp --sport 123   -j ntp_in
 #Logging
 iptables -A wan_in -j logging


 # LAN In chain ############################
 # Server
 iptables -A lan_in -p tcp --dport 5432          -j ACCEPT
 # Client
 iptables -A lan_in -p icmp                      -j icmp_in
 # Logging
 iptables -A lan_in -j logging


# OUTPUT chain #############################
 iptables -A OUTPUT -o lo -j ACCEPT
 iptables -A OUTPUT -o WAN_IF -j wan_out
 iptables -A OUTPUT -o LAN_IF -j lan_out

 # WAN Out chain ###########################
 # Server
 iptables -A wan_out -m state --state ESTABLISHED -j ACCEPT
 # Client
 iptables -A wan_out -p tcp --dport 53 -j dns_out
 iptables -A wan_out -p udp --dport 53 -j dns_out
 iptables -A wan_out -p udp --dport 67:68 -j dhcp_out
 iptables -A wan_out -p udp --dport 123 -j ntp_out
 # Logging
 iptables -A wan_out -j logging

 # LAN Out chain ###########################
 # Server
 iptables -A lan_out -m state --state ESTABLISHED -j ACCEPT
 # Client
 iptables -A lan_out -p icmp                      -j icmp_out
 #Logging
 iptables -A lan_out -j logging


# FORWARD chain ############################
 iptables -A FORWARD -j logging


# Service chains ###########################
# ssh_in chains (server)
 # Only accept SSH from an external Management ip address
 # Replace the following with management specific rules.
 iptables -A ssh_in  -s "$MAN_IP" -p tcp --dport 22 -m state --state NEW,ESTABLISHED -j ACCEPT

# dns_* chains (client)
 iptables -A dns_out -p udp --dport 53 -m state --state NEW,ESTABLISHED -j ACCEPT
 iptables -A dns_out -p tcp --dport 53 -m state --state NEW,ESTABLISHED -j ACCEPT
 iptables -A dns_in  -p udp --sport 53 -m state --state ESTABLISHED -j ACCEPT
 iptables -A dns_in  -p tcp --sport 53 -m state --state ESTABLISHED -j ACCEPT

# dhcp_* chains (client)
 iptables -A dhcp_out -p udp -m udp --dport 67:68 -m state --state NEW,ESTABLISHED -j ACCEPT
 iptables -A dhcp_in  -p udp -m udp --sport 67:68 -m state --state ESTABLISHED -j ACCEPT

# ntp_* chains (client)
 iptables -A ntp_out -p udp --dport 123 -m state --state NEW,ESTABLISHED -j ACCEPT
 iptables -A ntp_in  -p udp --sport 123 -m state --state ESTABLISHED -j ACCEPT

# icmp_* chains
 iptables -A icmp_in  -p icmp -m icmp --icmp-type 0 -j ACCEPT
 iptables -A icmp_in  -p icmp -m icmp --icmp-type 3 -j ACCEPT
 iptables -A icmp_in  -p icmp -m icmp --icmp-type 8 -j ACCEPT
 iptables -A icmp_in  -p icmp -m icmp --icmp-type 11 -j ACCEPT
 iptables -A icmp_in  -p icmp -m icmp --icmp-type 12 -j ACCEPT
 iptables -A icmp_out -p icmp -m icmp --icmp-type 8 -j ACCEPT

# logging chain
 #Skip these
 iptables -A icmp_in -j DROP
 iptables -A INPUT -m state --state INVALID -j DROP
 #Log all else
 iptables -A logging -m limit --limit 2/min --limit-burst 10 \
          -j LOG --log-prefix "IPTables-Dropped: " --log-level 4


# Save settings ############################
 /sbin/service iptables save

# List rules ###############################
 printf "\n\nFILTER table\n"
 iptables -L -v --line-numbers
 printf "\n\nNAT table\n"
 iptables -t nat -L -v --line-numbers
EOF
