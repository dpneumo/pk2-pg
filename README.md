# pk2-pg
Passkeeper2 postgresql server:

https://cloud.digitalocean.com

Login

Droplets tab -> Create -> Droplet menu item

Choices:

    CentOS 7.4
    Standard Sizes, $10/mo
    Datacenter NYC1
    Private networking
    SSH keys: root-laptop, loco-laptop
    1 Droplet: pk2-db
    Add Tags: passkeeper2, dbserv

#### Then:

SSH to root@<server-ipaddress>

    yum -y update && yum -y install git

    cd /opt && git clone https://github.com/dpneumo/pk2-pg.git
    chown -R loco:loco pk2-pg

    cd pk2-pg && chmod 755 *.sh && chmod 755 **/*.sh

    # git global env vars will be set for each user
    cat data/git_global_env_vars > /etc/profile.d/git.sh
    chmod 0644 /etc/profile.d/git.sh

    ./config_server.sh  # Will ask for new password for user 'loco'

    exit

SSH to loco@<server-ipaddress>

    cd /opt/pk2-pg

    git update-index --add --chmod=+x **/*.sh
    ./scripts/git.sh
    git commit -m "make our scripts executable and tell git about it"
    git push

    sudo ./scripts/iptables.sh
    sudo ./scripts/postgres.sh

    exit # Re-login to assure env vars are picked up

#### postgres login users

    # superuser:
    sudo -i -u postgres

    # regular user: can add roles and create dbs
    sudo -i -u mitch

#### TO DO:

  * Establish backup/replication strategies.
  * Change /var/lib/pgsql/10/data/postgresql.conf to listen on *
  * Whenever the client or server internal addresses change,
      MUST change firewall and pg_hba.conf to match


### config_server.sh
This script does the initial setup of the server.
* Nano, expect and tcl are installed.
* A user (loco) is created with sudo privileges.
* SSH is setup to allow key authentication and disallow password authentication.
* SSH root login is disallowed.
* sshd is restarted and enabled for start at boot.

### git.sh
* Initialize git for the loco user

### iptables.sh
Set up iptables
* Install iptables
* Install iptables rules and make them permanent
* Turn off firewalld and turn on iptables
* Setup iptables logging

### postgres.sh
Set up postgresql
* Install postgresql
* Install our pg_hba.conf
* Restart postgresql and set to start on reboot
