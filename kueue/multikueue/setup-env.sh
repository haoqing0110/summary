#!/bin/bash

cd $(dirname ${BASH_SOURCE})

set -e

hub=${CLUSTER1:-local-cluster}
c1=${CLUSTER1:-cluster1}
c2=${CLUSTER2:-cluster2}

hubctx="kind-${hub}"
c1ctx="kind-${c1}"
c2ctx="kind-${c2}"

kind create cluster --name "${hub}" --image kindest/node:v1.29.0@sha256:eaa1450915475849a73a9227b8f201df25e55e268e5d619312131292e324d570
kind create cluster --name "${c1}" --image kindest/node:v1.29.0@sha256:eaa1450915475849a73a9227b8f201df25e55e268e5d619312131292e324d570
kind create cluster --name "${c2}" --image kindest/node:v1.29.0@sha256:eaa1450915475849a73a9227b8f201df25e55e268e5d619312131292e324d570

echo "Initialize the ocm hub cluster\n"
clusteradm init --feature-gates="ManifestWorkReplicaSet=true,ManagedClusterAutoApproval=true" --bundle-version="latest" --wait --context ${hubctx}
joincmd=$(clusteradm get token --context ${hubctx} | grep clusteradm)

echo "Join local-cluster\n"
$(echo ${joincmd} --force-internal-endpoint-lookup --wait --context ${hubctx} | sed "s/<cluster_name>/$hub/g")

echo "Join cluster1 to hub\n"
$(echo ${joincmd} --force-internal-endpoint-lookup --wait --context ${c1ctx} | sed "s/<cluster_name>/$c1/g")

echo "Join cluster2 to hub\n"
$(echo ${joincmd} --force-internal-endpoint-lookup --wait --context ${c2ctx} | sed "s/<cluster_name>/$c2/g")

echo "Accept join of local-cluster, cluster1 and cluster2"
clusteradm accept --context ${hubctx} --clusters ${hub},${c1},${c2} --wait

kubectl get managedclusters --all-namespaces --context ${hubctx}

kubectl config use-context ${hubctx}
clusteradm create clusterset spoke
clusteradm clusterset set spoke --clusters ${c1},${c2}
clusteradm clusterset bind spoke --namespace default
clusteradm clusterset bind global --namespace default

echo "Install managed-serviceaccount\n"
cd /root/go/src/open-cluster-management.io/managed-serviceaccount
helm uninstall -n open-cluster-management-addon managed-serviceaccount || true
helm install \
   -n open-cluster-management-addon --create-namespace \
   managed-serviceaccount charts/managed-serviceaccount/ \
   --set tag=latest \
   --set featureGates.ephemeralIdentity=true \
   --set enableAddOnDeploymentConfig=true \
   --set hubDeployMode=AddOnTemplate
cd -

echo "Install managed-serviceaccount mca, Kueue, Jobset\n"
kubectl create -f env/jobset-mwrs-0.5.1.yaml || true
kubectl create -f env/kueue-mwrs-0.7.1.yaml || true
kubectl apply -f env/mg-sa-cma-0.6.0.yaml || true
kubectl apply -f env/placement.yaml || true

echo "Install cluster-permission \n"
cd /root/go/src/open-cluster-management.io/cluster-permission
make install
make run