#!/bin/bash
PROJECT_NAME='sample_project'

sudo yum install -y unzip

# PHP7
sudo yum -y install epel-release.noarch
sudo rpm -Uvh http://rpms.famillecollet.com/enterprise/remi-release-7.rpm
sudo yum -y install --enablerepo=remi,remi-php70 php php-devel php-mbstring php-pdo php-gd php-mysql php-xml

# composer
curl -sS https://getcomposer.org/installer | php -- --install-dir=/tmp
sudo mv /tmp/composer.phar /usr/local/bin/composer

# MySQL5.7
sudo yum -y localinstall http://dev.mysql.com/get/mysql57-community-release-el7-7.noarch.rpm
sudo yum -y install mysql mysql-devel mysql-server mysql-utilities
sudo systemctl enable mysqld
sudo systemctl start mysqld


ADDED_LINE='!includedir /etc/mysql/conf.d/'
MYCNF='/etc/my.cnf'
sudo cat ${MYCNF} | grep -w "${ADDED_LINE}" > /dev/null 2>&1
if [ $? = 1 ]; then
  sudo sh -c "echo '' >> ${MYCNF}"
  sudo sh -c "echo ${ADDED_LINE} >> ${MYCNF}"
fi

MYCNFDIR='/etc/mysql/conf.d'
if [ ! -d "${MYCNFDIR}" ]; then
  sudo mkdir -p ${MYCNFDIR}
fi

sudo cp -f ./conf.d/mysql/my.cnf ${MYCNFDIR}/my.cnf
sudo systemctl restart mysqld

# httpd
sudo yum install -y httpd
sudo systemctl start httpd
sudo systemctl enable httpd
sudo cp -f ./conf.d/httpd/${PROJECT_NAME}.conf /etc/httpd/conf.d/${PROJECT_NAME}.conf

DOCROOT='/var/www/html'
if [ ! -d "${DOCROOT}" ]; then
  sudo mkdir -p ${DOCROOT}
fi

LOGDIR="/var/log/httpd/${PROJECT_NAME}"
if [ ! -d "${LOGDIR}" ]; then
  sudo mkdir -p ${LOGDIR}
fi

sudo chown vagrant:vagrant ${DOCROOT}
sudo systemctl restart httpd
