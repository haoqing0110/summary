### openssl
```
openssl ciphers -V FIPS
```
```
openssl s_client -tls1_2 -connect hostip:port
openssl s_client -connect hostip:port
openssl x509 -text -in kubecfg.crt
```
### check server supported CipherSuites
```
docker run --network=host --rm -it nablac0d3/sslyze --regular 127.0.0.1:4001
nmap --script ssl-enum-ciphers -p 4001 127.0.0.1
```
### golang
```
sudo apt-get update
sudo apt-get -y upgrade
sudo curl -O https://storage.googleapis.com/golang/go1.11.linux-amd64.tar.gz
sudo tar -xvf go1.11.linux-amd64.tar.gz

sudo mv go /usr/local
export PATH=$PATH:/usr/local/go/bin

go version
```
### agent on mac
```
ssh -CfNg -D 127.0.0.1:7777 username@hostip
```
```
ip:3128 root password
```
### wrk
tps
```
taskset -c 1 wrk -t 1 -c 300 -d 90s -H 'Connection: close' https://hostname/s1-tls/0.html``
```
qps
```
taskset -c 1 wrk -t 1 -c 300 -d 90s https://hostname/s1-tls
```
account
```
kubectl logs ing-nginx-tls-dfdf9c5f-cwf4d | wc -l
```
### curl & ab (http)
```
while :; do curl -s -k https://10.0.0.1/apis -w "status %{http_code} %{size_download}\\n" | grep status| ts; sleep 1; done
```
```
#!/bin/bash
while true
do
  ab -n 500000 -c 100 https://10.0.0.1/apis
done
```
short-Connection
```
while :; do curl -s http://hostname/s1 -w "status %{http_code} %{size_download}\\n" | grep status| ts; sleep 1; done
```
```
#!/bin/bash
while true
do
  ab -n 500000 -c 100 http://hostname/s1
done
```
### nc (tcp/udp)
```
1. 调低端口释放后的等待时间，默认为60s，修改为15~30s
sysctl -w net.ipv4.tcp_fin_timeout=30
2. 修改tcp/ip协议配置， 通过配置/proc/sys/net/ipv4/tcp_tw_resue, 默认为0，修改为1，释放TIME_WAIT端口给新连接使用
sysctl -w net.ipv4.tcp_timestamps=1
3. 修改tcp/ip协议配置，快速回收socket资源，默认为0，修改为1
sysctl -w net.ipv4.tcp_tw_recycle=1
```
```
while true; do nc -vz 172.29.214.19 9000 2>&1 | grep -v "succeeded"; done
```
### WebSocket
```
https://github.com/alexanderGugel/wsd
go get github.com/alexanderGugel/wsd
./wsd --url ws://hostname/ws
```
### dig (dns)
```
while true; do dig +tries=1 +time=0 @10.0.0.10 ing-nginx.kube-system.svc.cluster.local | grep "timed out" ;done
```
```
#!/bin/bash
while true
do
  dig +tries=1 +time=0 @10.0.0.10 ing-nginx.kube-system.svc.cluster.local | grep "timed out"
done
```
### etcd
get etcdctl
```
docker run --rm -v /usr/local/bin:/data <cluster_name>.icp:8500/ibmcom/etcd:v3.2.18 cp /usr/local/bin/etcdctl /data
alias etcdctl3="ETCDCTL_API=3 etcdctl --cacert=/etc/cfc/conf/etcd/ca.pem --cert=/etc/cfc/conf/etcd/client.pem --key=/etc/cfc/conf/etcd/client-key.pem"
```
check etcd cluster status
```
export endpoint=172.29.214.11:4001,172.29.214.12:4001,172.29.214.13:4001

etcdctl3 --endpoints=${endpoint} member list
etcdctl3 --endpoints=${endpoint} endpoint health
etcdctl3 --endpoints=${endpoint} --write-out=table endpoint status
```
defrag etcd
```
export endpoint=172.29.214.11:4001
etcdctl3 --endpoints="${endpoint}" defrag
```
remove/add etcd member
```
export endpoint=172.29.214.11:4001
set etcd.json to --initial-cluster-state=existing
etcdctl3 --endpoints="${endpoint}" member remove f0f3d76c8bf22bca
etcdctl3 --endpoints="${endpoint}" member add etcdxxxxx --peer-urls="https://xxxxxx:2380"
```
```
etcdctl3 --endpoints="${endpoint}" get / --prefix --keys-only
etcdctl3 --endpoints="${endpoint}" get /registry/configmaps/kube-system/helmrepo-json
etcdctl3 --endpoints="${endpoint}" put --debug k1 v1
curl -kv https://9.111.255.130:4001/v2/members --cert /etc/cfc/conf/etcd/client.pem --key /etc/cfc/conf/etcd/client-key.pem  --ciphers ECDHE-RSA-DES-CBC3-SHA
curl -kv https://9.111.255.166:2380/v2/members --cert /var/lib/etcd/fixtures/peer/cert.pem --key /var/lib/etcd/fixtures/peer/key.pem
```
k8s
```
kubectl api-resources
```
### JMeter
download https://jmeter.apache.org/download_jmeter.cgi
learning video https://www.youtube.com/playlist?annotation_id=annotation_916989029&feature=iv&list=PLhW3qG5bs-L-zox1h3eIL7CZh5zJmci4c&src_vid=M-iAXz8vs48
start JMeter
```
cd apache-jmeter-5.0/bin
sh jmeter.sh
```
### haproxy enable log
modify /etc/rsyslog.conf
```
# cat /etc/rsyslog.conf | grep -e udp -e haproxy
module(load="imudp")
input(type="imudp" port="514")
local3.*         /var/log/haproxy.log
local0.*         /var/log/haproxy.log
```
```
systemctl restart rsyslog
```
check haproxy log
```
cat /var/log/haproxy.log
```
health-check
```
listen icp-proxy
    bind :80,:443
    mode tcp
    option tcplog
    server server1 9.111.255.158 send-proxy check fall 3 rise 2
    server server2 9.111.255.35 send-proxy check fall 3 rise 2
```
### clean images
```
ansible all -i cluster/hosts --private-key=cluster/ssh_key -m shell -a "docker stop \$(docker ps -aq)"
ansible all -i cluster/hosts --private-key=cluster/ssh_key -m shell -a "docker rm \$(docker ps -aq)"
ansible all -i cluster/hosts --private-key=cluster/ssh_key -m shell -a "docker rmi \$(docker images -aq) --force"
```
### git tag
```
git push --delete origin v2.2.3
git tag --delete v2.2.3
git tag -a v2.2.3
git push origin v2.2.3
```
### git remove remote branch
```
git push origin --delete <branch_name>
```
### artifactory
```
curl -H 'X-JFrog-Art-Api: xxxx' -T xxx.patch "https://na.artifactory.swg-devops.com/artifactory/hyc-cloud-private-scratch-helm-local/3.1.2-patch/xxx.patch"
curl -H 'X-JFrog-Art-Api: xxxx' -T xxx.patch "https://na.artifactory.swg-devops.com/artifactory/hyc-cloud-private-scratch-helm-local/3.1.2-patch/xxx.patch"
curl -H 'X-JFrog-Art-Api: xxxx' -T xx.tar.gz "https://hyc-cloud-private-scratch-docker-local.artifactory.swg-devops.com/artifactory/hyc-cloud-private-scratch-helm-virtual/3.1.1-patch/rhel/amd64/xx.tar.gz"
```
```
hyc-cloud-private-integration-docker-local.artifactory.swg-devops.com/ibmcom/xxx-amd64:latest
```
