sudo yum -y install postgresql-server postgresql-contrib
sudo postgresql-setup initdb

# Fix /var/lib/pgsql/data/pg_hba.conf
#bash -c "cat ../data/pg_hba.conf >> /var/lib/pgsql/data/pg_hba.conf ;"
cat ../data/pg_hba.conf >> /var/lib/pgsql/data/pg_hba.conf

sudo systemctl start postgresql
sudo systemctl enable postgresql

sudo -i -u postgres
createuser --createdb --no-login --nocreaterole --no-superuser
