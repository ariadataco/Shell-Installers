#!/bin/sh
clear
echo -e "======= \e[32mNginX\033[0m + \e[32mPHP-FPM\033[0m + \e[32mMariaDB\033[0m By \e[36mAriaData.Co\033[0m  =======\n========================================================="
read -e -p $'Install \e[33mwebmin\033[0m on Port \e[33m10000\033[0m ? [\e[32my\033[0m|\e[31mn\033[0m] : ' -i "y" install_webmin
read -e -p $'Set \e[33mSSH Port\033[0m ? (for default Enter \e[33m22\033[0m ) : ' -i "22" ssh_port_number
read -e -p $'\e[33mSite Main Folder Name\033[0m ? ( without \e[33mwww\033[0m ) : ' -i "public_html" www_folder_name
read -e -p $'Enter \e[33mDomains by FQDN\033[0m ? ( seperate by \e[33mspace\033[0m , exp: \e[32mtest.com www.test.com\033[0m ) : \n' domains
read -e -p $'\n\e[33mPHP Version\033[0m ? [\e[33m71\033[0m|\e[33m72\033[0m|\e[33m73\033[0m|\e[33m74\033[0m] : ' -i "74" php_version
read -e -p $'\e[33mMariaDB Version\033[0m ? [\e[33m10.1\033[0m|\e[33m10.2\033[0m|\e[33m10.3\033[0m|\e[33m10.4\033[0m] : ' -i "10.4" mariadb_version
read -e -p $'\e[33mMariaDB root Password\033[0m : ' mariadb_root_password
read -e -p $'Install \e[33mPHPMyAdmin\033[0m ? [\e[32my\033[0m|\e[31mn\033[0m]: ' -i "y" pma_install
if [[ $pma_install =~ ^([Yy])$ ]]
then
	read -e -p $'Enter \e[33mPHPMyAdmin Folder Name\033[0m ? ( like \e[33mpma\033[0m ) : ' -i "pma$php_version" pma_folder_name
fi
############################ Start Shell Installing and Configs ############################
############################################################################################
cd /root/
########################################## SELinux and Firewalld
setenforce 0
sed -i 's/enforcing/disabled/g' /etc/selinux/config
systemctl stop firewalld
systemctl disable firewalld
########################################## Install wget + epel-release
yum install wget epel-release curl yum-utils zip unzip openssl git -y
rpm -Uvh https://rpms.remirepo.net/enterprise/remi-release-7.rpm
########################################## Install yum-axelget and configs
yum install yum-axelget -y
sed -i 's/maxconn=5/maxconn=10/g' /etc/yum/pluginconf.d/axelget.conf
########################################## Yum Deep Update!
yum clean all
yum update -y
########################################## SSH(d) : Disable UseDNS , Set Port , Enable keep_alive
echo $'\nUseDNS no' >> /etc/ssh/sshd_config
echo $'\nClientAliveInterval 30\nTCPKeepAlive yes\nClientAliveCountMax 99999' >> /etc/ssh/sshd_config
sed -i 's/#Port 22/Port '$ssh_port_number'/g' /etc/ssh/sshd_config
########################################## NTP
yum install ntp ntpdate ntp-doc -y
rm -f /etc/localtime
ln -s /usr/share/zoneinfo/Asia/Tehran /etc/localtime
systemctl restart ntpd
ntpdate ntp.ariadata.co
systemctl enable ntpd
########################################## webmin
if [[ $install_webmin =~ ^([Yy])$ ]]
then
	yum install perl perl-Net-SSLeay perl-IO-Tty perl-Encode-Detect perl-Data-Dumper -y
	wget --no-check-certificate "https://sourceforge.net/projects/webadmin/files/webmin/1.941/webmin-1.941-1.noarch.rpm/download" -O webmin.rpm
	rpm -U webmin.rpm
	rm -f webmin.rpm
fi
########################################## nginx
wget --no-check-certificate "https://raw.githubusercontent.com/ariadata/Shell-Installers/master/repo/nginx-latest.repo" -O /etc/yum.repos.d/nginx.repo
yum install nginx -y
mkdir -p /home/$www_folder_name
wget --no-check-certificate "https://raw.githubusercontent.com/ariadata/Shell-Installers/master/static/nginx_conf_C7_x64_sample.conf" -O /etc/nginx/conf.d/$www_folder_name'.conf'
sed -i "s/##domains##/$domains/g" /etc/nginx/conf.d/$www_folder_name'.conf'
sed -i 's/##domain_folder##/'$www_folder_name'/g' /etc/nginx/conf.d/$www_folder_name'.conf'
##### default index files
wget --no-check-certificate "https://raw.githubusercontent.com/ariadata/Shell-Installers/master/static/under_cunstruction.html" -O /usr/share/nginx/html/index.html
wget --no-check-certificate "https://raw.githubusercontent.com/ariadata/Shell-Installers/master/static/under_cunstruction.html" -O /home/$www_folder_name/index.html
wget --no-check-certificate "https://raw.githubusercontent.com/ariadata/Shell-Installers/master/static/php_info.php" -O /home/$www_folder_name/phpinfo.php
########################################## PHPMyAdmin LTS 4.9.3
if [[ $pma_install =~ ^([Yy])$ ]]
then
	mkdir -p /home/$www_folder_name/$pma_folder_name
	cd /home/$www_folder_name/$pma_folder_name
	wget --no-check-certificate "https://raw.githubusercontent.com/ariadata/Shell-Installers/master/static/pma493.tgz" -O pma.tgz
	tar xvzf pma.tgz
	#chmod 777 tmp -R
	rm -f pma.tgz
fi
chown -R nginx:nginx /home/
########################################## MariaDB and Configs
cd /root/
wget --no-check-certificate "https://raw.githubusercontent.com/ariadata/Shell-Installers/master/repo/MariaDB-10.x_dynamic_C7_x64.repo" -O /etc/yum.repos.d/MariaDB.repo
sed -i 's/##version##/'$mariadb_version'/g' /etc/yum.repos.d/MariaDB.repo
yum install MariaDB-server MariaDB-client -y
wget --no-check-certificate "https://raw.githubusercontent.com/ariadata/Shell-Installers/master/static/MariaDb_Config_my_cnf_C7_x64.cnf" -O /etc/my.cnf
systemctl start mariadb
# from mariadb 10.4 and above suggest linux socket connect in mysql_secure_installation
if [[ $mariadb_version = "10.1" || $mariadb_version = "10.2" || $mariadb_version = "10.3" ]]
then
mysql_secure_installation <<EOF

y
$mariadb_root_password
$mariadb_root_password
y
y
y
y
EOF
else
mysql_secure_installation <<EOF

y
y
$mariadb_root_password
$mariadb_root_password
y
y
y
y
EOF
fi
########################################## PHP-FPM and Configs
cd /root/
yum-config-manager --enable remi-php$php_version
yum install php-fpm php-cli php-gd php-imap php-mbstring php-mysqlnd php-odbc php-pear php-pear-DB php-pear-Date php-pear-File php-pear-HTTP-Request php-pear-Log php-pear-Mail php-pear-Mail-Mime php-pear-Net-SMTP php-pear-Net-Sieve php-pear-Net-Socket php-pecl-zip php-soap php-xml php-xmlrpc -y
wget --no-check-certificate "https://raw.githubusercontent.com/ariadata/Shell-Installers/master/static/www_php-fpm_C7_x64.conf" -O /etc/php-fpm.d/www.conf
chmod 777 /var/lib/php -R
########################################## Yum Deep Update!
yum clean all
yum update -y
##########################################
systemctl enable nginx mariadb php-fpm
systemctl restart nginx mariadb php-fpm
clear
echo -e "\n======================================================\n======== \e[32mInstallation Completed Successfully!\033[0m ========\n======================================================\n"
read -e -p $'Do You Want to \e[33mReboot System NOW\033[0m ? [\e[32my\033[0m|\e[31mn\033[0m] : ' -i "y" reboot_at_end
if [[ $reboot_at_end =~ ^([Yy])$ ]]
then
	reboot
	exit
fi
