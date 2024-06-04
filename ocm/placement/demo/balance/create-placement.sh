#!/bin/bash
for((i=1;i<=$1;i++))
do
	kubectl apply -f placement.yaml --dry-run=client -o yaml | sed "s|NUM|${i}|g" | kubectl apply -f -
	sleep 1
done
