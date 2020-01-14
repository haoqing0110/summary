#!/bin/bash
for ((i=1;i<=101;i++)); 
do 
   # your-unix-command-here
  echo $i
  kubectl delete -f /tmp/pvc/pvc$i.yaml
done
