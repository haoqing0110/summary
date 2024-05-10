#!/bin/bash

set -e

hub=${CLUSTER1:-hub}
c1=${CLUSTER1:-cluster1}
c2=${CLUSTER2:-cluster2}

hubctx="kind-${hub}"
c1ctx="kind-${c1}"
c2ctx="kind-${c2}"

echo "Initialize the clusters...\n" 
kind create cluster --name "${hub}" --image kindest/node:v1.29.0@sha256:eaa1450915475849a73a9227b8f201df25e55e268e5d619312131292e324d570
kind create cluster --name "${c1}" --image kindest/node:v1.29.0@sha256:eaa1450915475849a73a9227b8f201df25e55e268e5d619312131292e324d570
kind create cluster --name "${c2}" --image kindest/node:v1.29.0@sha256:eaa1450915475849a73a9227b8f201df25e55e268e5d619312131292e324d570

echo "Installing kueue...\n" 
kubectl apply --server-side -f https://github.com/kubernetes-sigs/kueue/releases/download/v0.6.0/manifests.yaml --context ${hubctx}
kubectl apply --server-side -f https://github.com/kubernetes-sigs/kueue/releases/download/v0.6.0/manifests.yaml --context ${c1ctx}
kubectl apply --server-side -f https://github.com/kubernetes-sigs/kueue/releases/download/v0.6.0/manifests.yaml --context ${c2ctx}

echo "Installing jobset...\n" 
kubectl apply --server-side -f https://github.com/kubernetes-sigs/jobset/releases/download/v0.4.0/manifests.yaml --context ${hubctx}
kubectl apply --server-side -f https://github.com/kubernetes-sigs/jobset/releases/download/v0.4.0/manifests.yaml --context ${c1ctx}
kubectl apply --server-side -f https://github.com/kubernetes-sigs/jobset/releases/download/v0.4.0/manifests.yaml --context ${c2ctx}

echo "Enable multiqueue\n" 
kubectl patch deployment kueue-controller-manager -n kueue-system --type='json' -p='[{"op": "replace", "path": "/spec/template/spec/containers/0/args", "value": ["--config=/controller_manager_config.yaml", "--zap-log-level=2", "--feature-gates=MultiKueue=true"]}]' --context ${hubctx}

echo "Config multiqueue on hub\n" 
kind get kubeconfig --internal --name cluster1 > ~/.kube/config.cluster1
kind get kubeconfig --internal --name cluster2 > ~/.kube/config.cluster2
kubectl create secret generic worker1-secret -n kueue-system --from-file=kubeconfig=/root/.kube/config.cluster1 --context ${hubctx}
kubectl create secret generic worker2-secret -n kueue-system --from-file=kubeconfig=/root/.kube/config.cluster2 --context ${hubctx}

kubectl create -f queue.yaml --context ${hubctx}
#k get admissioncheck sample-multikueue -oyaml
#k get multikueueclusters.kueue.x-k8s.io multikueue-test-worker1 -oyaml
#k get multikueueclusters.kueue.x-k8s.io multikueue-test-worker2 -oyaml

echo "Mirror queue on worker\n" 
kubectl apply -f queue-worker.yaml --context ${c1ctx}
kubectl apply -f queue-worker.yaml --context ${c2ctx}

echo "Deploy job from hub\n" 
#kubectl get workload --context kind-cluster1 --watch
#kubectl get workload --context kind-cluster2 --watch
kubectl create -f job.yaml --context ${hubctx}

