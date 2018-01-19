################# iptables #################
# Setup for iptables install
yum update -y

# Install iptables
yum install -y iptables-services

# Create iptables rules script
# Copy iptables_rules to /home/loco/iptables_mod.sh
bash -c "cat ./data/iptables_rules >> /home/loco/iptables_mod.sh ;"

# Set permissions on iptables_mod.sh & execute it
chown loco:loco /home/loco/iptables_mod.sh
chmod +x /home/loco/iptables_mod.sh
. /home/loco/iptables_mod.sh

# Save the modified iptables rules for use on restart
iptables-save

# Stop & hide firewalld. Start iptables
systemctl stop firewalld && systemctl start iptables
systemctl mask firewalld
systemctl enable iptables

# Log iptables to its own log file
bash -c "cat <<'EOF' > /etc/rsyslog.d/20-iptables.conf;
:msg, startswith, 'IPTables-Dropped: '' -/var/log/iptables.log
& ~
EOF"

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
