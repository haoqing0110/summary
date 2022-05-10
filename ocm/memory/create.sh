#!/bin/bash
for((i=1;i<=$1;i++))
do
	kubectl apply -f mc.yaml --dry-run=client -o yaml | sed "s|NUM|${i}|g" | kubectl apply -f -
done
