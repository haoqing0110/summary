#!/bin/bash

cd $(dirname ${BASH_SOURCE})

set -e

hub=${CLUSTER1:-hub}
hubctx="kind-${hub}"
kind create cluster --name "${hub}"
echo "Initialize the ocm hub cluster\n"
clusteradm init --bundle-version="latest" --wait --context ${hubctx}

kubectl get managedclusters --all-namespaces --context ${hubctx}
