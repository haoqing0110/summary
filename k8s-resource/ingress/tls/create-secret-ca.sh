#!/bin/bash
openssl genrsa -out ca.key 2048   
openssl req -new -key ca.key -out ca.csr  
openssl x509 -req -days 365 -in ca.csr -signkey ca.key -out ca.crt  

#mkdir demoCA/
#touch demoCA/index.txt
#cat demoCA/serial
#02
openssl genrsa -out ing-tls.key 2048
openssl req -new -key ing-tls.key -out ing-tls.csr -subj "/CN=xxx"
openssl ca -in ing-tls.csr -out ing-tls.crt -cert ca.crt -keyfile ca.key

kubectl create secret generic mtls-secret --from-file=tls.crt=ing-tls.crt --from-file=tls.key=ing-tls.key --from-file=ca.crt=ca.crt
