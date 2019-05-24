#!/bin/sh -e

# Thanks to: https://github.com/ttilberg/vagrant-rails-dev

# This configuration was originally grabbed from
#   https://wiki.postgresql.org/wiki/PostgreSQL_For_Development_With_Vagrant
#   and modified to be more friendly with vagrant and rails.

# This configuration was subsequently mangled by Kevin

# Edit the following to change the name of the database user that will be created:
APP_DB_USER=vagrant
APP_DB_PASS=vagrant

# Edit the following to change the name of the database that is created (defaults to the user name)
APP_DB_NAME=meta

# Edit the following to change the version of PostgreSQL that is installed
PG_VERSION=11.1

#Edit the following to control the number of threads for compilation, recommended max = processing cores * 1.5
THREADS=1

###########################################################
# Changes below this line are probably not necessary
###########################################################
print_db_usage () {
  echo "Your PostgreSQL database has been setup and can be accessed on your local machine on the forwarded port (default: 5432)"
  echo "  Host: localhost"
  echo "  Port: 5432"
  echo "  Database: $APP_DB_NAME"
  echo "  Username: $APP_DB_USER"
  echo "  Password: $APP_DB_PASS"
  echo ""
  echo "Admin access to postgres user via VM:"
  echo "  vagrant ssh"
  echo "  sudo su - postgres"
  echo ""
  echo "psql access to app database user via VM:"
  echo "  vagrant ssh"
  echo "  sudo su - postgres"
  echo "  PGUSER=$APP_DB_USER PGPASSWORD=$APP_DB_PASS psql -h localhost $APP_DB_NAME"
  echo ""
  echo "Env variable for application development:"
  echo "  DATABASE_URL=postgresql://$APP_DB_USER:$APP_DB_PASS@localhost:5432/$APP_DB_NAME"
  echo ""
  echo "Local command to access the database via psql:"
  echo "  PGUSER=$APP_DB_USER PGPASSWORD=$APP_DB_PASS psql -h localhost -p 5432 $APP_DB_NAME"
}

export DEBIAN_FRONTEND=noninteractive

PROVISIONED_ON=/etc/vm_provision_on_timestamp
if [ -f "$PROVISIONED_ON" ]
then
  echo "VM was already provisioned at: $(cat $PROVISIONED_ON)"
  echo "To run system updates manually login via 'vagrant ssh' and run 'apt-get update && apt-get upgrade'"
  echo ""
  print_db_usage
  exit
fi

#Begin new PG Installation
#Get prerequisites
apt update
apt install -y build-essential libsystemd-dev libreadline-dev zlib1g-dev libssl-dev
#Download and unpack
wget https://ftp.postgresql.org/pub/source/v$PG_VERSION/postgresql-$PG_VERSION.tar.gz
tar xzf postgresql-$PG_VERSION.tar.gz
cd postgresql-$PG_VERSION

#Configure and build
./configure --prefix=/app/postgresql$PG_VERSION --with-systemd --with-openssl
make world -j$THREADS
make install-world

#create systemd service
echo "[Unit]" > "/etc/systemd/system/postgresql.service"
echo "Description=PostgreSQL database server" >> "/etc/systemd/system/postgresql.service"
echo "Documentation=man:postgres(1)" >> "/etc/systemd/system/postgresql.service"
echo "" >> "/etc/systemd/system/postgresql.service"
echo "[Service]" >> "/etc/systemd/system/postgresql.service"
echo "Type=notify" >> "/etc/systemd/system/postgresql.service"
echo "User=postgres" >> "/etc/systemd/system/postgresql.service"
echo "ExecStart=/app/postgresql$PG_VERSION/bin/postgres -D /app/pgdbstor/db/" >> "/etc/systemd/system/postgresql.service"
echo "ExecReload=/bin/kill -HUP \$MAINPID" >> "/etc/systemd/system/postgresql.service"
echo "KillMode=mixed" >> "/etc/systemd/system/postgresql.service"
echo "KillSignal=SIGINT" >> "/etc/systemd/system/postgresql.service"
echo "TimeoutSec=0" >> "/etc/systemd/system/postgresql.service"
echo "" >> "/etc/systemd/system/postgresql.service"
echo "[Install]" >> "/etc/systemd/system/postgresql.service"
echo "WantedBy=multi-user.target" >> "/etc/systemd/system/postgresql.service"

systemctl daemon-reload

useradd postgres

mkdir -p /app/pgdbstor/db
chown -R postgres:postgres /app/pgdbstor

sudo -u postgres /app/postgresql$PG_VERSION/bin/initdb /app/pgdbstor/db

PG_CONF="/app/pgdbstor/db/postgresql.conf"
PG_HBA="/app/pgdbstor/db/pg_hba.conf"
PG_DIR="/app/pgdbstor/db"

# Edit postgresql.conf to change listen address to '*':
sed -i "s/#listen_addresses = 'localhost'/listen_addresses = '*'/" "$PG_CONF"

# Append to pg_hba.conf to add password auth:
echo "hostssl    all             all             all                     md5" >> "$PG_HBA"

# Explicitly set default client_encoding
echo "client_encoding = utf8" >> "$PG_CONF"

# Add postgres to the env
sed -i "s/.$/:\/app\/postgresql$PG_VERSION\/bin\"/" /etc/environment

export PATH=$PATH:/app/postgresql$PG_VERSION/bin

# Restart so that all new config is loaded:
service postgresql restart

echo "Creating $APP_DB_NAME user and development database"

cat << EOF | su - postgres -c psql
-- Create the database user:
CREATE USER $APP_DB_USER WITH PASSWORD '$APP_DB_PASS' SUPERUSER CREATEDB;

-- Create the database:
CREATE DATABASE $APP_DB_NAME WITH OWNER=$APP_DB_USER
                                  LC_COLLATE='en_US.utf8'
                                  LC_CTYPE='en_US.utf8'
                                  ENCODING='UTF8'
                                  TEMPLATE=template0;
EOF

sudo systemctl enable postgresql



# Tag the provision time:
date > "$PROVISIONED_ON"

echo "Successfully created PostgreSQL dev virtual machine."
echo ""
print_db_usage