### openssl
```
openssl ciphers -V FIPS
```
```
openssl s_client -tls1_2 -connect hostip:port
openssl s_client -connect hostip:port
openssl x509 -text -in kubecfg.crt
```
check pem
```
openssl x509 -in certificate.pem -text -noout
openssl x509 -in certificate.der -inform der -text -noout
```
check cert
```
openssl x509 -in /etc/cfc/conf/ca.crt  -text -noout
```
check all the cert under dir
```
#!/bin/bash
function read_dir(){
for file in `ls $1`
do
if [ -d $1"/"$file ]
then
read_dir $1"/"$file
else
#cat $1"/"$file | openssl x509 -text
openssl crl2pkcs7 -nocrl -certfile  $1"/"$file | openssl pkcs7 -print_certs -text
fi
done
}

read_dir ./
```
check key
```
openssl rsa -in mykey.key -text -noout
```
### check server supported CipherSuites
```
docker run --network=host --rm -it nablac0d3/sslyze --regular 127.0.0.1:4001
docker run --network=host --rm -it quay.io/haoqing/ssl:latest --regular 127.0.0.1:4001
rpm -vhU https://nmap.org/dist/nmap-7.92-1.x86_64.rpm
nmap --script ssl-enum-ciphers -p 4001 127.0.0.1
nmap -Pn -sS -p4001 --script ssl-enum-ciphers 172.16.191.235
```
### golang
```
sudo apt-get update
sudo apt-get -y upgrade
sudo curl -O https://storage.googleapis.com/golang/go1.13.linux-amd64.tar.gz
sudo tar -xvf go1.13.linux-amd64.tar.gz

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
### api-server
```
kubectl api-resources --verbs=list --namespaced -o name
```
```
kubectl api-resources --verbs=list --namespaced -o name | xargs -n 1 kubectl get --show-kind --show-all --ignore-not-found -n <terminating-namespace>
```
### rbac
```
kubectl auth can-i create image --namespace richhall
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
compact
```
export endpoint=172.29.214.11:4001
$ rev=$(etcdctl3 --endpoints=${endpoint} endpoint status --write-out="json" | egrep -o '"revision":[0-9]*' | egrep -o '[0-9].*')
etcdctl3 --endpoints=${endpoint} compact $rev
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
[benchmark](https://github.com/etcd-io/etcd/tree/master/tools/benchmark)
```
go get go.etcd.io/etcd/tools/benchmark
```
```
alias benchmark="benchmark --cacert /etc/cfc/conf/etcd/ca.pem --cert /etc/cfc/conf/etcd/client.pem --key /etc/cfc/conf/etcd/client-key.pem"
```
write
```
export endpoint=172.16.188.54:4001
benchmark --endpoints=${endpoint} --target-leader --conns=1 --clients=1 put --key-size=8 --sequential-keys --total=10000 --val-size=256
benchmark --endpoints=${endpoint} --target-leader  --conns=100 --clients=1000 put --key-size=8 --sequential-keys --total=100000 --val-size=256
```
```
export endpoints=xxx:4001,xxx:4001,xxx:4001
benchmark --endpoints=${endpoints} --conns=100 --clients=1000 put --key-size=8 --sequential-keys --total=100000 --val-size=256
```
read
```
export endpoints=xxx:4001,xxx:4001,xxx:4001
benchmark --endpoints=${endpoints} --conns=1 --clients=1 range YOUR_KEY --consistency=l --total=10000
benchmark --endpoints=${endpoints} --conns=1 --clients=1 range YOUR_KEY --consistency=s --total=10000
/registry/services/endpoints/kube-system/kube-scheduler
```
```
export endpoints=xxx:4001,xxx:4001,xxx:4001
benchmark --endpoints=${endpoints} --conns=100 --clients=1000 range YOUR_KEY --consistency=l --total=100000
benchmark --endpoints=${endpoints} --conns=100 --clients=1000 range YOUR_KEY --consistency=s --total=100000
```
[fio](https://www.ibm.com/cloud/blog/using-fio-to-tell-whether-your-storage-is-fast-enough-for-etcd)
```
wget https://github.com/axboe/fio/archive/fio-3.14.tar.gz
tar -zxvf fio-3.14.tar.gz
cd fio-fio-3.14
./configure
make
make install
```
```
fio --rw=write --ioengine=sync --fdatasync=1 --directory=/var/lib/etcd/ --size=22m --bs=2300 --name=mytest
```
metrics
```
curl -L https://xxx:4001/metrics --cacert "/etc/cfc/conf/etcd/ca.pem" --cert "/etc/cfc/conf/etcd/client.pem" --key "/etc/cfc/conf/etcd/client-key.pem"
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
https://www.ibm.com/support/knowledgecenter/SSBS6K_3.2.0/apis/k8s_api.html
```
kubectl -n kube-system get secret |grep default
kubectl -n kube-system get secret default-token-7s7xz -o yaml
echo xxx | base64 -d
curl -k -H "Authorization:Bearer $ID_TOKEN"  https://<Cluster Master Host>:<Kubernetes API Port>/api/v1/namespaces/default/pods

cloudctl tokens
kubectl auth can-i get image --namespace default
```
