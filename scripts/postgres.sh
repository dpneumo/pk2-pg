################# postgresql #################
yum update -y

yum -y install postgresql-server postgresql-contrib
postgresql-setup initdb
echo "Installed postgresql"

cp data/pg_hba.conf /var/lib/pgsql/data/pg_hba.conf
echo "Installed our pg_hba.conf"

systemctl start postgresql
systemctl enable postgresql
echo "Started and boot enabled postgresql"

sudo -u postgres createuser --createdb --createrole --no-superuser "mitch"
echo "Created postgres user 'mitch'"

sudo -u postgres createuser --createdb --no-login --no-createrole --no-superuser "minerva"
echo "Created postgres user 'minerva'"
