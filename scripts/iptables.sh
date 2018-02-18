#!/bin/bash

################# iptables #################
# Stop firewall(s)
systemctl is-active --quiet firewalld && systemctl stop firewalld
systemctl is-active --quiet iptables && systemctl stop iptables
echo "Stopped firewall (firewalld or iptables)"

# Setup for iptables install
yum update -y

# Install iptables
yum install -y iptables-services
echo "Installed iptables"

# Create iptables rules script
# Copy iptables_rules to /home/loco/iptables_mod.sh
bash -c "cat ./data/iptables_rules >> /home/loco/iptables_mod.sh ;"
echo "Created iptables_mod.sh"

# Set permissions on iptables_mod.sh & execute it
chown loco:loco /home/loco/iptables_mod.sh
chmod +x /home/loco/iptables_mod.sh
. /home/loco/iptables_mod.sh
echo "Executed iptables_mod.sh."

# Save the modified iptables rules for use on restart
iptables-save
echo "iptables modified rules have been saved."

# Start iptables
systemctl start iptables
echo "iptables has been started."
systemctl mask firewalld
systemctl enable iptables
echo "iptables start at boot has been enabled."

# Log iptables to its own log file
bash -c "cat <<'EOF' > /etc/rsyslog.d/20-iptables.conf;
:msg, startswith, 'IPTables-Dropped: '' -/var/log/iptables.log
& ~
EOF"
echo "Set iptables to log to iptables.log"

# Rotate the iptables log
bash -c "cat <<'EOF' > /etc/logrotate.d/iptables;
/var/log/iptables.log
{
  rotate 7
  daily
  missingok
  notifempty
  delaycompress
  compress
  postrotate
    invoke-rc.d rsyslog rotate > /dev/null
  endscript
}
EOF"
echo "Rotation of iptables log set up"
