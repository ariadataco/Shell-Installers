#!/bin/sh
systemctl disable firewalld
systemctl stop firewalld
echo $'\nUseDNS no' >> /etc/ssh/sshd_config
echo $'\nClientAliveInterval 30\nTCPKeepAlive yes\nClientAliveCountMax 99999' >> /etc/ssh/sshd_config
curl -o /root/.bashrc https://raw.githubusercontent.com/ariadata/Shell-Installers/master/static/bashrc.bashrc
yum install epel-release -y
yum install wget yum-axelget ntp ntpdate ntp-doc -y
sed -i 's/maxconn=5/maxconn=10/g' /etc/yum/pluginconf.d/axelget.conf
rm -f /etc/localtime
ln -s /usr/share/zoneinfo/Asia/Tehran /etc/localtime
systemctl restart ntpd
ntpdate ntp.ariadata.co
systemctl enable ntpd
systemctl restart ntpd
yum clean all
yum update -y