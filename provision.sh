#!/bin/bash

#-------------------------EDIT BELOW HERE---------------------------------------
#MYSQL CONFIG

  #Set default root password
  MYSQLPASS="1234"

  #Set to database name
  MYSQLDATABASE="example_db"

  #Set database user for wordpress 
  MYSQLWPUSER="example_user"

  #Set database user password for wordpress
  MYSQLWPUSERPW="password"

  #Import existing Wordpress Database-- yes or no
  MYSQLWPIMPORT="yes"

#-------------------------DO NOT EDIT BELOW HERE--------------------------------
#-------------------------UNLESS YOU KNOW WHAT YOU'RE DOING---------------------
 

echo "Provisioning Server..."
export DEBIAN_FRONTEND=noninteractive

sudo apt-get update

# Update Bash to fix Bash Bug
sudo apt-get install --only-upgrade bash

# Set MySQL Password-- replace 1234 with whatever password you want
debconf-set-selections <<< "mysql-server mysql-server/root_password password ${MYSQLPASS}"
debconf-set-selections <<< "mysql-server mysql-server/root_password_again password ${MYSQLPASS}"

# Install MySQL and PHP MySQL
sudo apt-get install -y -q -f mysql-server php5-mysql

# If MySQL is installed, go through the various imports and service tasks.
exists_mysql="$(service mysql status)"
if [[ "mysql: unrecognized service" != "${exists_mysql}" ]]; then
  # MySQL gives us an error if we restart a non running service, which
  # happens after a `vagrant halt`. Check to see if it's running before
  # deciding whether to start or restart.
  if [[ "mysql stop/waiting" == "${exists_mysql}" ]]; then
    echo "### Starting MySQL ###"
    service mysql start
  else
    echo "### Restarting MySQL ###"
    service mysql restart
  fi

  # MySQL Tasks
  #
  # Check if database file exists-- put mysql file in database folder and change filename
  if [[ ! -d /var/lib/mysql/${MYSQLDATABASE} ]]; then
    #mysql -u root -p1234 -e 'drop database ${MYSQLDATABASE};'

    # Create Database Name
    mysql -u root -p${MYSQLPASS} -e "create database ${MYSQLDATABASE}; GRANT ALL PRIVILEGES ON ${MYSQLDATABASE}.* TO ${MYSQLWPUSER}@localhost IDENTIFIED BY '${MYSQLWPUSERPW}'"; 
    echo -e "\n### MySQL Database created ###"

    #Check if importing existing Wordpress DB
    if [ "$MYSQLWPIMPORT" == "yes" ]; then

      #Check for SQL file under "database" folder
      if [[  -f /var/www/database/${MYSQLDATABASE}.sql ]]; then
        # Import Database-- replace 1234 with password, set database name, set database path
        mysql -u root -p${MYSQLPASS} ${MYSQLDATABASE} < /var/www/database/${MYSQLDATABASE}.sql

        echo -e "\n### Importing MySQL database tables ###"
      else
        echo -e "\n### No SQL file found, please add SQL file to databases folder ###"
      fi
    else
      echo -e "\n### Not importing database, use Wordpress Configuration or MySQL software ###"
    fi
  else
    echo -e "\n### Database already exists, skipping ###"
  fi

else
  echo -e "\n### MySQL is not installed. No databases imported ###"
fi
# End if MySQL is installed

# Install Nginx & PHP-FPM
sudo apt-get update
sudo apt-get install -y -q -f nginx
sudo apt-get install -y -q -f php5-fpm

# Start Nginx
sudo service nginx start

# Restart PHP-FPM
sudo service php5-fpm restart

#Create global nginx conf files for server block
  if [[ ! -d /etc/nginx/global ]]; then
    # Create global directory
    sudo mkdir /etc/nginx/global
    echo "### Creating /etc/nginx/global directory ###"
  fi

  # Copy Nginx global conf files over
  sudo cp /project/config/common.conf /etc/nginx/global/common.conf
  sudo cp /project/config/wordpress.conf /etc/nginx/global/wordpress.conf
  echo "### Creating/overwriting global conf files conf files ###"

  # Overwrite Nginx default virtualhosts
  sudo cp /project/config/virtualhosts /etc/nginx/sites-available/default

  # Overwrite Nginx nginx.conf
  sudo cp /project/config/nginx.conf /etc/nginx/nginx.conf

#End create global nginx conf files

# Overwrite PHP.ini file
sudo cp /project/config/php.ini /etc/php5/fpm/php.ini

# Install Varnish Cache
sudo apt-get install -y -q -f varnish

# Copy Varnish configs over
sudo cp /project/config/varnish /etc/default/varnish
sudo cp /project/config/varnishdefault.vcl /etc/varnish/default.vcl

# Change ownership of files to www-data
sudo chown -R www-data:www-data /project/www

# Restart PHP-FPM, Nginx & Varnish
sudo service php5-fpm restart
sudo service nginx restart
sudo service varnish restart

# UFW Firewall Rules & Enable
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow ssh
sudo ufw allow www
sudo ufw --force enable

echo "### NOTE: SSH into server and sudo nano /etc/php5/fpm/php.ini. change cgi.fix_pathinfo=1 to 0 ###"