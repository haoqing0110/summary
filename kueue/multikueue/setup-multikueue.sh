#!/bin/bash

set -e

hub=${CLUSTER1:-local-cluster}
c1=${CLUSTER1:-cluster1}
c2=${CLUSTER2:-cluster2}

hubctx="kind-${hub}"

kubectl config use-context ${hubctx}

echo "Enable multiqueue on the hub\n" 
kubectl patch deployment kueue-controller-manager -n kueue-system --type='json' -p='[{"op": "replace", "path": "/spec/template/spec/containers/0/args", "value": ["--config=/controller_manager_config.yaml", "--zap-log-level=2", "--feature-gates=MultiKueue=true"]}]' --context ${hubctx}

echo "Setup queue on the spoke\n" 
kubectl apply -f single-clusterqueue-setup-mwrs.yaml

echo "Setup MultiKueue Kubeconfigs from hub\n" 
cd authtokenrequest
./create-multikueue-kubeconfig-from-hub.sh ${c1}
./create-multikueue-kubeconfig-from-hub.sh ${c2}
cd -

echo "Create a sample multikueue on hub\n"
kubectl apply -f multikueue-setup.yaml --context ${hubctx}
sleep 60
kubectl get clusterqueues cluster-queue -o jsonpath="{range .status.conditions[?(@.type == \"Active\")]}CQ - Active: {@.status} Reason: {@.reason} Message: {@.message}{'\n'}{end}"
kubectl get admissionchecks sample-multikueue -o jsonpath="{range .status.conditions[?(@.type == \"Active\")]}AC - Active: {@.status} Reason: {@.reason} Message: {@.message}{'\n'}{end}"
kubectl get multikueuecluster multikueue-test-worker1 -o jsonpath="{range .status.conditions[?(@.type == \"Active\")]}MC - Active: {@.status} Reason: {@.reason} Message: {@.message}{'\n'}{end}"
kubectl get multikueuecluster multikueue-test-worker2 -o jsonpath="{range .status.conditions[?(@.type == \"Active\")]}MC - Active: {@.status} Reason: {@.reason} Message: {@.message}{'\n'}{end}"

echo "Deploy job from hub\n" 
kubectl create -f job.yaml --context ${hubctx}
#kubectl get workload --context kind-cluster1 --watch
#kubectl get workload --context kind-cluster2 --watch

