### openssl
```
openssl ciphers -V FIPS
```
```
openssl s_client -tls1_2 -connect hostip:port
openssl s_client -connect hostip:port
```
### golang
```
sudo apt-get update
sudo apt-get -y upgrade
sudo curl -O https://storage.googleapis.com/golang/go1.9.2.linux-amd64.tar.gz
sudo tar -xvf go1.9.2.linux-amd64.tar.gz

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
check endpoint
```
export endpoint=<Endpoint IP address>

etcdctl3 --endpoints=https://${endpoint}:4001  member list
etcdctl3 --endpoints="https://${endpoint}:4001" endpoint health
etcdctl3 --endpoints="https://${endpoint}:4001" --write-out=table endpoint status
etcdctl3 --endpoints="https://${endpoint}:4001" defrag
```
remove/add etcd member
```
set etcd.json to --initial-cluster-state=existing
etcdctl3 --endpoints="https://${endpoint}:4001" member remove f0f3d76c8bf22bca
etcdctl3 --endpoints="https://${endpoint}:4001" member add etcdxxxxx --peer-urls="https://xxxxxx:2380"
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
