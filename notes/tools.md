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
