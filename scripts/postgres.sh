################# postgresql #################
yum update -y

cp data/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo
echo "Installed our CentOS-Base.repo additions for PG"

yum -y install https://download.postgresql.org/pub/repos/yum/10/redhat/rhel-7-x86_64/pgdg-centos10-10-2.noarch.rpm
echo "Installed PGDB RPM file"

yum -y install postgresql10-server.x86_64 postgresql10-contrib.x86_64
/usr/pgsql-10/bin/postgresql-10-setup initdb
echo "Installed postgresql"

cp data/pg_hba.conf /var/lib/pgsql/10/data/pg_hba.conf
chown postgres:postgres /var/lib/pgsql/10/data/pg_hba.conf
echo "Installed our pg_hba.conf"

systemctl start postgresql-10.service
systemctl enable postgresql-10.service
echo "Started and boot enabled postgresql"

sudo -u postgres createuser --createdb --createrole --no-superuser "mitch"
echo "Created postgres user 'mitch'"

sudo -u postgres createuser --createdb --no-login --no-createrole --no-superuser "minerva"
echo "Created postgres user 'minerva'"
