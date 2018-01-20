################# postgresql #################
yum update -y

yum -y install postgresql-server postgresql-contrib
postgresql-setup initdb

# Fix /var/lib/pgsql/data/pg_hba.conf
#bash -c "cat ../data/pg_hba.conf >> /var/lib/pgsql/data/pg_hba.conf ;"
cp data/pg_hba.conf /var/lib/pgsql/data/pg_hba.conf

systemctl start postgresql
systemctl enable postgresql

sudo -i -u postgres
createuser --createdb --no-login --no-createrole --no-superuser "minerva"
exit
