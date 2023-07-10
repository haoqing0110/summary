#!/bin/bash
for((i=$1;i<=$2;i++))
do
	kubectl label managedcluster fakecluster${i} $3
done
