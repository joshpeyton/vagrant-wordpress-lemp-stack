# Vagrant Wordpress Stack

Vagrant WordPress stack running on Ubuntu 14.04, NGINX, PHP-FPM, MySQL, and Varnish.
Shell provisioning

## Requirements
* Install VirtualBox
* Install Vagrant
* Download Wordpress

## Usage
1. Download Wordpress or backup current Wordpress file structure 
2. Copy all files to /www/prod folder
3. If copying current Wordpress site, export MySQL tables to SQL file, copy to /database/ folder
4. Configure files or leave defaults(see Configuration section)
5. In terminal, cd into directory, run "vagrant up" (no quotes)

##Configuration
1. Edit Vagrantfile settings under "CONFIGURE BOX VARIABLES"
  * WP_HOSTNAME - set to desired hostname
  * PRIVATE_IP - set to desired ip address
  * BOX_NAME - set to desired box name (stored under Virtualbox VMs)
  * BOX_MEMORY - set to desired memory (example uses 512mb)
  * PROVISION - point to provisioning script (default is provision.sh, change if configuring your own)
2. Edit provision.sh file settings under "MYSQL CONFIG", also name SQL to import the same and put under database folder
  * MYSQLPASS - set MySQL root password
  * MYSQLDATABASE - set name of MySQL database (be sure this name is the same as your SQL file under the /database/ folder)
  * MYSQLWPUSER - set user for database to use for Wordpress configuration
  * MYSQLWPUSERPW - set password for user to use for Wordpress configuration
  * MYSQLWPIMPORT - set to yes if importing current database structure or no for new Wordpress setup
3. Edit virtualhosts file
  * Forces example.com to be www.example.com. Change as necessary.
  ```
server {
    # Force WWW if not entered
    listen 127.0.0.1:8080;
    server_name example.com;
    rewrite ^/(.*)$ http://www.example.com/$1 permanent;
}
  ```
  * Sets domain to www.example.com and points the root to the /project/www/prod folder. Also sets names for the access log and error log. Change server_name, access_log name, and error_log name.
  ```
server {
    # Prod
    listen 127.0.0.1:8080;
    server_name www.example.com;
    root /project/www/prod;
    access_log /var/log/nginx/www.example.com.access.log;
    error_log /var/log/nginx/www.example.com.error.log;
    include global/common.conf;
    include global/wordpress.conf;
    rewrite /wp-admin$ $scheme://$host$uri/ permanent;
}
  ```

### Optional
* Add custom domain to /etc/hosts file on Mac or C:\Windows\System32\Drivers\etc\hosts file on Windows and point to 192.168.31.15 or whatever you change the IP to.
* You can use [Gas Mask](http://www.clockwise.ee/gasmask/) (Mac) to edit your /etc/hosts file and easily swap between custom/original hosts file with the icon in the menu bar:
***Example:***
```
192.168.31.15 example.com
192.168.31.15 www.example.com
```
