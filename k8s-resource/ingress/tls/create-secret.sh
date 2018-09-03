#!/bin/bash
# openssl genrsa -out ing-tls.key 4096
# openssl req -new -key ing-tls.key -out ing-tls.csr -subj "/CN=my-ing"
# openssl x509 -req -days 36500 -in ing-tls.csr -signkey ing-tls.key -out ing-tls.crt
kubectl create secret tls ing-tls-secret --cert=ing-tls.crt --key=ing-tls.key
