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
