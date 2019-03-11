### warning: setlocale: LC_CTYPE: cannot change locale (UTF-8): No such file or directory
```
vi /etc/environment

LANG=en_US.utf-8
LC_ALL=en_US.utf-8
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
```
### apt-get
install, upgrade, remove
```
apt-get update
apt -y -f install *.deb
apt-get remove -y --purge docker-ce
```
