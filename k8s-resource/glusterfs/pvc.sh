#!/bin/bash
rmdir /tmp/pvc/
mkdir /tmp/pvc/
for ((i=1;i<=51;i++)); 
do 
   # your-unix-command-here
  echo $i
  echo "
  apiVersion: v1
  kind: PersistentVolumeClaim
  metadata:
    name: glusterpvc$i
  spec:
    accessModes:
      - ReadWriteOnce
    resources:
      requests:
        storage: 1Gi
    storageClassName: glusterfs3
  " > /tmp/pvc/pvc$i.yaml
  kubectl create -f /tmp/pvc/pvc$i.yaml
done
