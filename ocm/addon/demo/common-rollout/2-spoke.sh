#!/bin/bash

cd $(dirname ${BASH_SOURCE})

set -e

hub=${CLUSTER1:-kind}
c1=${CLUSTER1:-cluster1}
c2=${CLUSTER2:-cluster2}
c3=${CLUSTER2:-cluster3}

hubctx="kind-${hub}"
c1ctx="kind-${c1}"
c2ctx="kind-${c2}"
c3ctx="kind-${c3}"

#kind create cluster --name "${hub}"
kind create cluster --name "${c1}"
kind create cluster --name "${c2}"
kind create cluster --name "${c3}"

echo "Initialize the ocm hub cluster\n"
clusteradm init --wait --context ${hubctx}
joincmd=$(clusteradm get token --context ${hubctx} | grep clusteradm)

echo "Join cluster1 to hub\n"
$(echo ${joincmd} --force-internal-endpoint-lookup --wait --context ${c1ctx} | sed "s/<cluster_name>/$c1/g")

echo "Join cluster2 to hub\n"
$(echo ${joincmd} --force-internal-endpoint-lookup --wait --context ${c2ctx} | sed "s/<cluster_name>/$c2/g")

echo "Join cluster3 to hub\n"
$(echo ${joincmd} --force-internal-endpoint-lookup --wait --context ${c3ctx} | sed "s/<cluster_name>/$c3/g")

echo "Accept join of cluster1 and cluster2, cluster3"
clusteradm accept --context ${hubctx} --clusters ${c1},${c2},${c3} --wait

kubectl get managedclusters --all-namespaces --context ${hubctx}
