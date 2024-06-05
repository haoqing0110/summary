#!/bin/bash
kubectl apply -f $1 --dry-run=client -o yaml | sed "s|NUM|${2}|g" | kubectl apply -f -
