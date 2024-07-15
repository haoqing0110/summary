#!/bin/bash

set -e

hub=${CLUSTER1:-hub}
c1=${CLUSTER1:-cluster1}
c2=${CLUSTER2:-cluster2}
VERSION=${VERSION:-v0.7.1}

hubctx="kind-${hub}"
c1ctx="kind-${c1}"
c2ctx="kind-${c2}"

echo "Initialize the clusters...\n" 
kind create cluster --name "${hub}" --image kindest/node:v1.29.0@sha256:eaa1450915475849a73a9227b8f201df25e55e268e5d619312131292e324d570
kind create cluster --name "${c1}" --image kindest/node:v1.29.0@sha256:eaa1450915475849a73a9227b8f201df25e55e268e5d619312131292e324d570
kind create cluster --name "${c2}" --image kindest/node:v1.29.0@sha256:eaa1450915475849a73a9227b8f201df25e55e268e5d619312131292e324d570

echo "Installing kueue...\n" 
kubectl apply --server-side -f https://github.com/kubernetes-sigs/kueue/releases/download/$VERSION/manifests.yaml --context ${hubctx}
kubectl apply --server-side -f https://github.com/kubernetes-sigs/kueue/releases/download/$VERSION/manifests.yaml --context ${c1ctx}
kubectl apply --server-side -f https://github.com/kubernetes-sigs/kueue/releases/download/$VERSION/manifests.yaml --context ${c2ctx}

echo "Installing jobset...\n" 
kubectl apply --server-side -f https://github.com/kubernetes-sigs/jobset/releases/download/v0.5.1/manifests.yaml --context ${hubctx}
kubectl apply --server-side -f https://github.com/kubernetes-sigs/jobset/releases/download/v0.5.1/manifests.yaml --context ${c1ctx}
kubectl apply --server-side -f https://github.com/kubernetes-sigs/jobset/releases/download/v0.5.1/manifests.yaml --context ${c2ctx}

sleep 60 

echo "Setup queue on workers\n" 
kubectl apply -f single-clusterqueue-setup.yaml --context ${c1ctx}
kubectl apply -f single-clusterqueue-setup.yaml --context ${c2ctx}

echo "MultiKueue Specific Kubeconfig\n" 
kubectl config use-context ${c1ctx}
./create-multikueue-kubeconfig.sh cluster1.kubeconfig
INTERNAL_SERVER_URL=$(kind get kubeconfig --internal --name ${c1} | grep server)
sed -i.bak 's|^\(\s*server:\s*\).*$|'"$INTERNAL_SERVER_URL"'|' cluster1.kubeconfig

kubectl config use-context ${c2ctx}
./create-multikueue-kubeconfig.sh cluster2.kubeconfig
INTERNAL_SERVER_URL=$(kind get kubeconfig --internal --name ${c2} | grep server)
sed -i.bak 's|^\(\s*server:\s*\).*$|'"$INTERNAL_SERVER_URL"'|' cluster2.kubeconfig

echo "Enable multiqueue\n" 
kubectl patch deployment kueue-controller-manager -n kueue-system --type='json' -p='[{"op": "replace", "path": "/spec/template/spec/containers/0/args", "value": ["--config=/controller_manager_config.yaml", "--zap-log-level=2", "--feature-gates=MultiKueue=true"]}]' --context ${hubctx}

echo "Create worker’s Kubeconfig secret\n" 
kubectl config use-context ${hubctx}
kubectl create secret generic worker1-secret -n kueue-system --from-file=kubeconfig=cluster1.kubeconfig --context ${hubctx}
kubectl create secret generic worker2-secret -n kueue-system --from-file=kubeconfig=cluster2.kubeconfig --context ${hubctx}

echo "Create a sample setup\n"
kubectl create -f multikueue-setup.yaml --context ${hubctx}
sleep 60
kubectl get clusterqueues cluster-queue -o jsonpath="{range .status.conditions[?(@.type == \"Active\")]}CQ - Active: {@.status} Reason: {@.reason} Message: {@.message}{'\n'}{end}"
kubectl get admissionchecks sample-multikueue -o jsonpath="{range .status.conditions[?(@.type == \"Active\")]}AC - Active: {@.status} Reason: {@.reason} Message: {@.message}{'\n'}{end}"
kubectl get multikueuecluster multikueue-test-worker1 -o jsonpath="{range .status.conditions[?(@.type == \"Active\")]}MC - Active: {@.status} Reason: {@.reason} Message: {@.message}{'\n'}{end}"
kubectl get multikueuecluster multikueue-test-worker2 -o jsonpath="{range .status.conditions[?(@.type == \"Active\")]}MC - Active: {@.status} Reason: {@.reason} Message: {@.message}{'\n'}{end}"

echo "Deploy job from hub\n" 
kubectl create -f job.yaml --context ${hubctx}
#kubectl get workload --context kind-cluster1 --watch
#kubectl get workload --context kind-cluster2 --watch

