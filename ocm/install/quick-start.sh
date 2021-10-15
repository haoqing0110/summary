#!/bin/bash

git clone https://github.com/open-cluster-management-io/registration-operator

## Cluster manager
export HUB_CLUSTER_NAME=hub
export CTX_HUB_CLUSTER=kind-hub
export HUB_KUBECONFIG=.hub-kubeconfig

# Create cluster
kind create cluster --name ${HUB_CLUSTER_NAME}
kubectl config use-context ${CTX_HUB_CLUSTER}

# Deploy hub
cd registration-operator
export KUBECONFIG=/root/.kube/config
make deploy-hub # make deploy-hub GO_REQUIRED_MIN_VERSION:= # if you see warnings regarding go version

## Klusterlet agent
export MANAGED_CLUSTER_NAME=cluster1
export CTX_MANAGED_CLUSTER=kind-cluster1

# Create cluster
kind create cluster --name ${MANAGED_CLUSTER_NAME}
kubectl config use-context ${CTX_MANAGED_CLUSTER}

# Deploy hub
cd registration-operator
kind get kubeconfig --name ${HUB_CLUSTER_NAME} --internal > ${HUB_KUBECONFIG}
make deploy-spoke # make deploy-spoke GO_REQUIRED_MIN_VERSION:= # if you see warnings regarding go version

# Approve
kubectl get csr --context ${CTX_HUB_CLUSTER}
kubectl get managedcluster --context ${CTX_HUB_CLUSTER}

CSR_NAME=$(kubectl get csr --context ${CTX_HUB_CLUSTER} | grep Pending | awk '{print $1}')
kubectl certificate approve ${CSR_NAME} --context ${CTX_HUB_CLUSTER}
kubectl patch managedcluster ${MANAGED_CLUSTER_NAME} -p='{"spec":{"hubAcceptsClient":true}}' --type=merge --context ${CTX_HUB_CLUSTER}
