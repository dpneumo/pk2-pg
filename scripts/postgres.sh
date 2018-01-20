################# postgresql #################
yum update -y

yum -y install postgresql-server postgresql-contrib
postgresql-setup initdb

cp data/pg_hba.conf /var/lib/pgsql/data/pg_hba.conf

systemctl start postgresql
systemctl enable postgresql

sudo -u postgres createuser --createdb --no-login --no-createrole --no-superuser "minerva"

