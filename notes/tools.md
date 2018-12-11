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
#!/bin/bash
while true
do
  nc -vz 172.29.214.22 9000 2>&1 | grep "Connection refused"
done
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
