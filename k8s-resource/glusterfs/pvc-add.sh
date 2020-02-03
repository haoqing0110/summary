#!/bin/bash
#rmdir /tmp/pvc/
#mkdir /tmp/pvc/
for ((i=97;i<=99;i++)); 
do 
  echo $i
  kubectl create -f /tmp/pvc/pvc$i.yaml
  sleep 30
  kubectl get pvc glusterpvc$i
done
