#!/bin/sh
clear;
setenforce 0;
echo -e "====  \033[0;31mWelcome!\033[0m , This is \033[0;33mGitEA\033[0m Installer from \033[0;32mAriaData\033[0m  ===\n===========================================================";
read -r -p "Enter FQDN like mygit.ariadata.co : " GIT_FQDN;
read -r -p "Enter Password for MariaDB root User : " MariaDB_ROOT_PASSWORD;
yum install wget epel-release -y;
yum update -y;
sed -i 's/enforcing/disabled/g' /etc/selinux/config;
wget "https://raw.githubusercontent.com/ariadata/PHP-FPM_NginX_shell-installers/master/static-files/MariaDB-10.4_C7_x64.repo" -O /etc/yum.repos.d/MariaDB.repo;
wget "https://raw.githubusercontent.com/ariadata/PHP-FPM_NginX_shell-installers/master/static-files/nginx.repo" -O /etc/yum.repos.d/nginx.repo;
systemctl stop firewalld;
systemctl disable firewalld;
yum install unzip zip curl openssl nginx MariaDB-server MariaDB-client -y;
wget "https://raw.githubusercontent.com/ariadata/Shell-Installers/master/static/nginx_conf_d_gitea_C7_x64.conf" -O /etc/nginx/conf.d/gitea.conf;
sed -i "s/##GIT_FQDN##/$GIT_FQDN/g" /etc/nginx/conf.d/gitea.conf;
wget "https://raw.githubusercontent.com/ariadata/PHP-FPM_NginX_shell-installers/master/static-files/MariaDb_Config_my_cnf_C7_x64.cnf" -O /etc/my.cnf;
systemctl enable nginx.service;
systemctl enable mariadb.service;
service mariadb restart;
service nginx start;
yum update -y;
mysql_secure_installation <<EOF

y
y
$MariaDB_ROOT_PASSWORD
$MariaDB_ROOT_PASSWORD
y
y
y
y
EOF
mysql -u root -p$MariaDB_ROOT_PASSWORD -e "CREATE DATABASE gitea;"
yum install git -y;
groupadd --system gitea;
useradd gitea -g gitea --system --create-home --shell /bin/bash;
mkdir -p /var/lib/gitea/{custom,data,indexers,public,log};
mkdir /etc/gitea/;
wget "https://raw.githubusercontent.com/ariadata/Shell-Installers/master/static/gitea-pre-app_ini.conf" -O /etc/gitea/app.ini;
sed -i "s/##URL##/$GIT_FQDN/g" /etc/gitea/app.ini;
chown gitea:gitea /var/lib/gitea/{data,indexers,log};
chmod 750 /var/lib/gitea/{data,indexers,log};
chown -R root:gitea /etc/gitea;
chmod -R 770 /etc/gitea;
echo -e "\033[0;32mWait for Download Latest Version of gitea ... \033[0m";
curl -s https://api.github.com/repos/go-gitea/gitea/releases/latest  | grep browser_download_url  | grep '.*linux-amd64"'  | cut -d '"' -f 4  | wget -i - -O /usr/local/bin/gitea;
chmod +x /usr/local/bin/gitea;
wget "https://raw.githubusercontent.com/ariadata/Shell-Installers/master/static/gitea.service" -O /etc/systemd/system/gitea.service;
systemctl daemon-reload;
systemctl enable gitea;
systemctl restart gitea;
clear;
echo -e "==============================================\nGoto \033[31;1mhttp://$GIT_FQDN/install/\033[0m and Fill the Form Like Thease Data :";
echo -e "Database Type : \t\t\t\033[0;32mMySQL\033[0m";
echo -e "Host : \t\t\t\t\t\033[0;32m127.0.0.1:3306\033[0m";
echo -e "Username : \t\t\t\t\033[0;32mroot\033[0m";
echo -e "Password : \t\t\t\t\033[0;32m$MariaDB_ROOT_PASSWORD\033[0m";
echo -e "Database Name : \t\t\t\033[0;32mgitea\033[0m";
echo -e "Charset : \t\t\t\t\033[0;32mutf8\033[0m";
echo -e "Site Title : \t\t\t\t\033[0;33mAnyThing You Want\033[0m";
echo -e "Repository Root Path : \t\t\t\033[31;1mDo NOT Change This!\033[0m";
echo -e "Git LFS Root Path : \t\t\t\033[31;1mDo NOT Change This!\033[0m";
echo -e "Run As Username : \t\t\t\033[31;1mDo NOT Change This!\033[0m";
echo -e "SSH Server Domain : \t\t\t\033[0;32m$GIT_FQDN\033[0m";
echo -e "SSH Server Port : \t\t\t\033[0;32m22\033[0m";
echo -e "Gitea HTTP Listen Port : \t\t\033[0;32m3000\033[0m";
echo -e "Gitea Base URL : \t\t\t\033[0;32mhttp://$GIT_FQDN\033[0m";
echo -e "Log Path : \t\t\t\t\033[31;1mDo NOT Change This!\033[0m";
echo -e "===> Now Click On \033[0;34mEmail Settings\033[0m and Fill an SMTP Account There";
echo -e "===> Click On \033[0;34mServer and Third-Party Service Settings\033[0m and Fill Like These : ";
echo -e "Enable Local Mode : \t\t\t\033[31;1mUnChecked\033[0m";
echo -e "Disable Gravatar : \t\t\t\033[0;32mChecked\033[0m";
echo -e "Enable Federated Avatars : \t\t\033[31;1mUnChecked\033[0m";
echo -e "Enable OpenID Sign-In : \t\t\033[31;1mUnChecked\033[0m";
echo -e "Disable Self-Registration: \t\t\033[0;32mChecked\033[0m";
echo -e "Allow Registration Only Through External Services : \033[31;1mUnChecked\033[0m";
echo -e "Enable OpenID Self-Registration : \t\033[31;1mUnChecked\033[0m";
echo -e "Enable CAPTCHA : \t\t\t\033[31;1mUnChecked\033[0m";
echo -e "Require Sign-In to View Pages : \t\033[0;32mChecked\033[0m";
echo -e "Hide Email Addresses by Default : \t\033[31;1mUnChecked\033[0m";
echo -e "Allow Creation of Organizations by Default : \033[0;32mChecked\033[0m";
echo -e "Enable Time Tracking by Default : \t\033[0;32mChecked\033[0m";
echo -e "===> Click On \033[0;34mAdministrator Account Settings\033[0m and Fill Like These : ";
echo -e "Administrator Username : \t\t\033[0;33madministrator\033[0m";
echo -e "Password : \t\t\t\t\033[31;1mCustom Administrator Password\033[0m";
echo -e "Confirm Password : \t\t\t\033[31;1mCustom Administrator Password Again\033[0m";
echo -e "Email Address : \t\t\t\033[0;33mno-reply@$GIT_FQDN\033[0m";
echo -e "==============================================\n\033[0;33mEveryThing is Done! Your Git URL is : \033[0m \033[0;32mhttp://$GIT_FQDN\033[0m";
echo -e "\033[0;35mThanks For Using This Script By\033[0m \033[0;33mAriaData.Co\033[0m And Please Reboot System!";
#reboot;
