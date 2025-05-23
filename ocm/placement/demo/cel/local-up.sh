#!/bin/bash

cd $(dirname ${BASH_SOURCE})

set -e

hub=${CLUSTER1:-hub}
c1=${CLUSTER1:-cluster1}
c2=${CLUSTER2:-cluster2}

hubctx="kind-${hub}"
c1ctx="kind-${c1}"
c2ctx="kind-${c2}"

kind create cluster --name "${hub}"
kind create cluster --name "${c1}"
kind create cluster --name "${c2}"

echo -e "Initialize the ocm hub cluster\n"
clusteradm init --bundle-version="latest"  --wait --context ${hubctx}
joincmd=$(clusteradm get token --context ${hubctx} | grep clusteradm)

echo -e "Join cluster1 to hub\n"
$(echo ${joincmd} --force-internal-endpoint-lookup --wait --context ${c1ctx} | sed "s/<cluster_name>/$c1/g")

echo -e "Join cluster2 to hub\n"
$(echo ${joincmd} --force-internal-endpoint-lookup --wait --context ${c2ctx} | sed "s/<cluster_name>/$c2/g")

echo -e "Accept join of cluster1 and cluster2\n"
clusteradm accept --context ${hubctx} --clusters ${c1},${c2} --wait

kubectl get managedclusters --all-namespaces --context ${hubctx}

kubectl config use-context ${hubctx}

echo "Install resource-usage-collect-addon"
git clone git@github.com:open-cluster-management-io/addon-contrib.git || true
cd addon-contrib/resource-usage-collect-addon
make deploy
cd -
rm -rf addon-contrib