#!/usr/bin/env bash

########################
# include the magic
########################
. ../demo-magic.sh


########################
# Configure the options
########################

#
# speed at which to simulate typing. bigger num = faster
#
# TYPE_SPEED=20

#
# custom prompt
#
# see http://www.tldp.org/HOWTO/Bash-Prompt-HOWTO/bash-prompt-escape-sequences.html for escape sequences
#
DEMO_PROMPT="${GREEN}➜ ${CYAN}\W "

# text color
# DEMO_CMD_COLOR=$BLACK

# clean env

# prepare ocm env
# curl -sSL https://raw.githubusercontent.com/open-cluster-management-io/OCM/main/solutions/setup-dev-environment/local-up.sh | bash
export KUBECONFIG="/root/.kube/config"

hubctx="kind-hub"
c1ctx="kind-cluster1"
c2ctx="kind-cluster2"
c3ctx="kind-cluster3"
kubectl config use-context ${hubctx}
./addon.sh
kubectl delete -f managed-serviceaccount-0.6.1.yaml
kubectl delete -f managed-serviceaccount-0.6.2.yaml
kubectl delete -f managed-serviceaccount-0.6.3.yaml
kubectl delete -f managed-serviceaccount-0.6.4.yaml
kubectl delete -f managed-serviceaccount-0.6.5.yaml
clusteradm clusterset bind global --namespace default
kubectl label managedcluster cluster3 canary=true
kubectl apply -f placement-all.yaml

kubectl patch deployment -n open-cluster-management klusterlet -p '{"spec": {"replicas": 0}}' --context ${c1ctx}
kubectl patch deployment -n open-cluster-management klusterlet -p '{"spec": {"replicas": 0}}' --context ${c2ctx}
kubectl patch deployment -n open-cluster-management klusterlet -p '{"spec": {"replicas": 0}}' --context ${c3ctx}
kubectl patch deployment -n open-cluster-management-agent klusterlet-work-agent -p '{"spec": {"replicas": 1}}' --context ${c1ctx}
kubectl patch deployment -n open-cluster-management-agent klusterlet-work-agent -p '{"spec": {"replicas": 1}}' --context ${c2ctx}
kubectl patch deployment -n open-cluster-management-agent klusterlet-work-agent -p '{"spec": {"replicas": 1}}' --context ${c3ctx}

clear

function check_addon() {
    pe "kubectl get cma managed-serviceaccount -oyaml"
    pe "kubectl get mca -A -ojson | jq '.items[] | .metadata.namespace, .status.configReferences[]' | grep addontemplates -B 12"
    
    p "enable klusterlet-work-agent on managedcluster ${1}"
    kubectl patch deployment -n open-cluster-management-agent klusterlet-work-agent -p '{"spec": {"replicas": 1}}' --context ${1}
    pe "kubectl get mca -A -ojson | jq '.items[] | .metadata.namespace, .status.configReferences[]' | grep addontemplates -B 12"
    
    p "enable klusterlet-work-agent on managedcluster ${2}"
    kubectl patch deployment -n open-cluster-management-agent klusterlet-work-agent -p '{"spec": {"replicas": 1}}' --context ${2}
    pe "kubectl get mca -A -ojson | jq '.items[] | .metadata.namespace, .status.configReferences[]' | grep addontemplates -B 12"
    
    p "enable klusterlet-work-agent on managedcluster ${3}"
    kubectl patch deployment -n open-cluster-management-agent klusterlet-work-agent -p '{"spec": {"replicas": 1}}' --context ${3}
    pe "kubectl get mca -A -ojson | jq '.items[] | .metadata.namespace, .status.configReferences[]' | grep addontemplates -B 12"
    
    pe "kubectl get cma managed-serviceaccount -oyaml"
}

function disable_work() {
    p "disable klusterlet-work-agent on managedcluster"
    kubectl patch deployment -n open-cluster-management-agent klusterlet-work-agent -p '{"spec": {"replicas": 0}}' --context ${c1ctx}
    kubectl patch deployment -n open-cluster-management-agent klusterlet-work-agent -p '{"spec": {"replicas": 0}}' --context ${c2ctx}
    kubectl patch deployment -n open-cluster-management-agent klusterlet-work-agent -p '{"spec": {"replicas": 0}}' --context ${c3ctx}
}

p "The environment has 3 managed clusters."
pe "kubectl get managedclusters --show-labels"
p "Example addon managed-serviceaccount is deployed on the hub."
pe "kubectl get cma"
pe "kubectl get cma managed-serviceaccount -oyaml"
pe "kubectl get mca -A"
pe "kubectl get pods -A"
pe "kubectl get addontemplate"
pe "kubectl get addontemplate managed-serviceaccount-0.6.0 -oyaml"
pe ""
clear

p "Case 1: fresh install add-on agents with install strategy"
pe "cat cma-fresh-install.yaml"
pe "oc get placement placement-all -oyaml"
pe "oc get placementdecision placement-all-decision-1 -oyaml"
pe "oc get placementdecision placement-all-decision-2 -oyaml"
pe "kubectl apply -f cma-fresh-install.yaml"
pe "kubectl get cma managed-serviceaccount -oyaml"
pe "kubectl get mca -A"
pe "kubectl get mca -A -ojson | jq '.items[] | .metadata.namespace, .status.configReferences[]'"
pe ""

clear
p "Case 2: update all the add-on agents when config changes"
pe "cat cma-update-all.yaml"
disable_work
pe "kubectl apply -f cma-update-all.yaml"
pe "kubectl apply -f managed-serviceaccount-0.6.1.yaml"
check_addon ${c1ctx} ${c2ctx} ${c3ctx}
pe ""

clear
p "Case 3: progressive per cluster when config changes"
pe "cat cma-progressive.yaml"
disable_work
pe "kubectl apply -f cma-progressive.yaml"
pe "kubectl apply -f managed-serviceaccount-0.6.2.yaml"
check_addon ${c3ctx} ${c1ctx} ${c2ctx}
pe ""

clear
p "Case 4: progressive per group when config changes"
pe "cat cma-progressive-per-group.yaml"
disable_work
pe "kubectl apply -f cma-progressive-per-group.yaml"
pe "kubectl apply -f managed-serviceaccount-0.6.3.yaml"
check_addon ${c3ctx} ${c1ctx} ${c2ctx}
pe ""

clear
p "Case 5: progressive with minSuccessTime"
pe "cat cma-progressive-minsuccesstime.yaml"
pe "kubectl apply -f cma-progressive-minsuccesstime.yaml"
pe "kubectl apply -f managed-serviceaccount-0.6.4.yaml"
pe "kubectl get cma managed-serviceaccount -oyaml"
pe "kubectl get mca -A -ojson | jq '.items[] | .metadata.namespace, .status.configReferences[]' | grep addontemplates -B 12"
pe ""

clear
p "Case 6: progressive with maxFailures"
pe "cat cma-progressive-maxfailures-1.yaml"
disable_work
pe "kubectl apply -f cma-progressive-maxfailures-1.yaml"
pe "kubectl apply -f managed-serviceaccount-0.6.5.yaml"
pe "kubectl get cma managed-serviceaccount -oyaml"
pe "kubectl get mca -A -ojson | jq '.items[] | .metadata.namespace, .status.configReferences[]' | grep addontemplates -B 12"
pe ""

