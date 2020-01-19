### warning: setlocale: LC_CTYPE: cannot change locale (UTF-8): No such file or directory
```
vi /etc/environment

LANG=en_US.utf-8
LC_ALL=en_US.utf-8
```
### perl: warning: Falling back to a fallback locale ("en_US.UTF-8").
```
$ locale
LANG=C
LANGUAGE=
LC_CTYPE=fi_FI.UTF-8
LC_NUMERIC="C"
LC_TIME="C"
LC_COLLATE=fi_FI.UTF-8
LC_MONETARY="C"
LC_MESSAGES=fi_FI.UTF-8
LC_PAPER="C"
LC_NAME="C"
LC_ADDRESS="C"
LC_TELEPHONE="C"
LC_MEASUREMENT="C"
LC_IDENTIFICATION="C"
LC_ALL=
```
```
$ sudo locale-gen "en_US.UTF-8"
Generating locales...
  en_US.UTF-8... done
Generation complete.

$ sudo dpkg-reconfigure locales
Generating locales...
  en_US.UTF-8... up-to-date
Generation complete.
```
### system information
```
uname -a
cat /etc/redhat-release
grep -Eqi "Ubuntu" /etc/issue || grep -Eq "Ubuntu" /etc/*-release
grep -Eqi "Red Hat Enterprise Linux Server" /etc/issue || grep -Eq "Red Hat Enterprise Linux Server" /etc/*-release
grep -Eqi "SUSE" /etc/issue || grep -Eq "SUSE" /etc/*-release
```
```
ip a
```
### systemctl
```
systemctl daemon-reload
systemctl restart docker
systemctl reset-failed
systemctl stop docker
```
### rpm
install, upgrade, remove
```
rpm -ivh --force *.rpm
rpm -Uvh --force *.rpm
rpm -e docker containerd docker-runc docker-libnetwork catatonit --allmatches
```
query
```
rpm -aq | grep mypackage
rpm -qp mypackage.rpm --provides
rpm -qp mypackage.rpm --requires
rpm -qpR mypackage.rpm
rpm -qp --scripts mypackage.rpm
```
### apt-get
install, upgrade, remove
```
apt-get update
apt -y -f install *.deb
apt-get remove -y --purge docker-ce
```
### shadowsocks
https://www.linode.com/docs/networking/vpn/create-a-socks5-proxy-server-with-shadowsocks-on-ubuntu-and-centos7/
```
sudo apt-get install python-pip python-m2crypto
sudo pip install shadowsocks
```
```
# cat /etc/shadowsocks.json
{
"server":"9.30.210.36",
"server_port":7777,
"local_port":1080,
"password":"Letmein123",
"timeout":600,
"method":"aes-256-cfb"
}
```
```
sudo ssserver -c /etc/shadowsocks.json -d start
```
```
sudo ssserver -d stop
```
```
sudo ssserver -c /etc/shadowsocks.json -d restart
```
```
# cat /etc/rc.local
/usr/bin/python /usr/local/bin/ssserver -c /etc/shadowsocks.json -d start
exit 0
```
```
iptables -4 -A INPUT -p tcp --dport 7777 -m comment --comment "Shadowsocks server listen port" -j ACCEPT
ufw allow proto tcp to 0.0.0.0/0 port 7777 comment "Shadowsocks server listen port"
```
```
firewall-cmd --permanent --zone=public --add-rich-rule='
    rule family="ipv4"
    port protocol="tcp" port="7777" accept'
firewall-cmd --reload
```
```
https://github.com/shadowsocks/ShadowsocksX-NG/releases
```
### system debug
system message
```
/var/log/messages
```
system info
```
top
```
```
df -h
df -i
```
```
lsof -p <pid>
0 0,6,12,18 * * * date >> /root/lsof.txt ; lsof -p 1433 >> /root/lsof.txt
```
```
# cat icp_io_corn.sh
#!/bin/bash
echo "==========================="`date`"==========================="
/usr/sbin/iotop -botqqqk --iter=5
iostat
```
```
*/10 * * * * /path/to/icp_io_corn.sh >> /var/log/icp_io.log 2>&1
```
```
# cat icp_net_corn.sh
#!/bin/bash
echo "==========================="`date`"==========================="
ping -c3 172.29.214.11
ping -c3 172.29.214.12
```
```
*/10 * * * * /path/to/icp_net_corn.sh >> /var/log/icp_net.log 2>&1
```
### docker issues
mkdir /sys/fs/cgroup/memory/kubepods/besteffort/pod2f526c27-8bb7-11e9-9ae7-00505681a97f: cannot allocate memory`, it's a kernel bug in 3.10.x. The issue was triggered because of high frequency of create/delete docker container on the node. See https://github.com/moby/moby/issues/29638, https://github.ibm.com/IBMPrivateCloud/roadmap/issues/23245
### api
https://www.ibm.com/support/knowledgecenter/SSBS6K_3.2.0/apis/access_api.html
