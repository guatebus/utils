#!/bin/bash

###########################################################################
# Provisioning script for a Symfony app - replace all uses of {{something}}
###########################################################################

export DEBIAN_FRONTEND=noninteractive

# package update
echo "deb http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list
wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add -

apt-get -y update
apt-get install -qy git vim screen htop curl wget software-properties-common
add-apt-repository -y ppa:mozillateam/firefox-next
add-apt-repository -y ppa:chris-lea/node.js
apt-get -y update
apt-get install -qy ant make python-setuptools
apt-get install -qy php5-fpm php5-gd php5 php5-cli php5-common php5-curl php5-intl php5-mysqlnd php-pear php5-json php5-xdebug php5-xsl
apt-get install -qy mysql-client mysql-server
apt-get install -qy apache2 libapache2-mod-php5 apache2-mpm-prefork
apt-get install -qy supervisor

# install browser testing tools
apt-get install -qy firefox google-chrome-beta openjdk-7-jre-headless nodejs
apt-get install -qy x11vnc xvfb
npm install -g selenium-standalone@2.38.0-2.7.0
apt-get install -qy xfonts-100dpi xfonts-75dpi xfonts-scalable xfonts-cyrillic

# install pip                                                  1
easy_install pip
pip install sphinx

# composer
curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin
echo 'export PATH=$PATH:/home/vagrant/.composer/vendor/bin' | tee -a /home/vagrant/.bashrc
echo 'export DISPLAY=:99' | tee -a /home/vagrant/.bashrc

echo '127.0.0.1 www.{{project_name}}.dev {{project_name}}.dev' | tee -a /etc/hosts

# PHP Configuration
echo "date.timezone=Europe/Amsterdam" | tee -a /etc/php5/cli/conf.d/99_{{organization_name}}.ini
echo "date.timezone=Europe/Amsterdam" | tee -a /etc/php5/fpm/conf.d/99_{{organization_name}}.ini
echo "date.timezone=Europe/Amsterdam" | tee -a /etc/php5/apache2/conf.d/99_{{organization_name}}.ini

# apache2
ln -s /home/vagrant/{{project_name}} /var/www/{{organization_name}}-{{project_name}}
cat <<EOF | tee /etc/apache2/sites-available/{{organization_name}}-{{project_name}}.conf
<VirtualHost *:80>
    ServerName {{project_name}}.dev
    ServerAlias www.{{project_name}}.dev

    DocumentRoot /var/www/{{organization_name}}-{{project_name}}/web
    <Directory /var/www/{{organization_name}}-{{project_name}}/web>
        # enable the .htaccess rewrites
        AllowOverride All
        Require all granted
    </Directory>

    ErrorLog /var/log/apache2/{{organization_name}}-{{project_name}}_error.log
    CustomLog /var/log/apache2/{{organization_name}}-{{project_name}}_access.log combined
</VirtualHost>
EOF
a2enmod rewrite
a2ensite {{organization_name}}-{{project_name}}
service apache2 reload

cat <<EOF > /etc/supervisor/conf.d/supervisord.conf
[supervisord]
nodaemon=false

[program:xvfb]
command=Xvfb :99 -shmem -screen 0 1366x768x16
stdout_logfile=/var/log/supervisor/%(program_name)s.log
stderr_logfile=/var/log/supervisor/%(program_name)s.log
environment=DISPLAY=":99"
autorestart=true

[program:x11vnc]
command=x11vnc -display :99 -N -forever
stdout_logfile=/var/log/supervisor/%(program_name)s.log
stderr_logfile=/var/log/supervisor/%(program_name)s.log
environment=DISPLAY=":99"
autorestart=true

[program:selenium]
command=start-selenium
stdout_logfile=/var/log/supervisor/%(program_name)s.log
stderr_logfile=/var/log/supervisor/%(program_name)s.log
autorestart=true
environment=DISPLAY=":99"
EOF

/etc/init.d/supervisor stop
/etc/init.d/supervisor start

cat <<EOF > /home/vagrant/.ssh/id_rsa
-----BEGIN RSA PRIVATE KEY-----
{{ ADD PRIVATE KEY HERE }}
-----END RSA PRIVATE KEY-----
EOF

cat <<EOF > /home/vagrant/.ssh/id_rsa.pub
{{ ADD PUBLIC KEY HERE }}
EOF
echo -e "Host github.com\n\tStrictHostKeyChecking no\n" > /home/vagrant/.ssh/config
echo -e "Host stage.{{organization_name}}.eu\n\tStrictHostKeyChecking no\n" > /home/vagrant/.ssh/config

rm -rf /tmp/*

su vagrant -c 'composer.phar global require --dev rhumsaa/jenkins-php=~1.3'
# this line should be the last
sudo -u vagrant /home/vagrant/{{project_name}}/bin/install