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
kubectl delete -f managed-serviceaccount-0.4.1.yaml
kubectl delete -f managed-serviceaccount-0.4.2.yaml
kubectl delete -f managed-serviceaccount-0.4.3.yaml
clusteradm clusterset bind global --namespace default
kubectl label managedcluster cluster3 canary=true
kubectl apply -f placement-all.yaml
clear

p "The environment has 3 managed clusters."
pe "kubectl get managedclusters --show-labels"
p "Example addon managed-serviceaccount is deployed on the hub."
pe "kubectl get cma"
pe "kubectl get cma managed-serviceaccount -oyaml"
pe "kubectl get mca -A"
pe "kubectl get addontemplate"
pe "kubectl get addontemplate managed-serviceaccount-0.4.0 -oyaml"
pe "kubectl get pods -A"
pe ""
clear

p "Case 1: fresh install add-on agents with install strategy"
pe "cat cma-fresh-install.yaml"
pe "oc get placement  placement-all -oyaml"
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
pe "kubectl apply -f cma-update-all.yaml"
pe "kubectl get cma managed-serviceaccount -oyaml"
pe "kubectl get mca -A -ojson | jq '.items[] | .metadata.namespace, .status.configReferences[]'"

pe "kubectl apply -f managed-serviceaccount-0.4.1.yaml"
pe "kubectl get cma managed-serviceaccount -oyaml"
pe "kubectl get mca -A -ojson | jq '.items[] | .metadata.namespace, .status.configReferences[]'"
pe ""

clear
p "Case 3: progressive per cluster when config changes"
pe "cat cma-progressive.yaml"
pe "kubectl apply -f cma-progressive.yaml"
pe "kubectl get cma managed-serviceaccount -oyaml"
pe "kubectl get mca -A -ojson | jq '.items[] | .metadata.namespace, .status.configReferences[]'"

pe "kubectl apply -f managed-serviceaccount-0.4.2.yaml"
pe "kubectl get cma managed-serviceaccount -oyaml"
pe "kubectl get mca -A -ojson | jq '.items[] | .metadata.namespace, .status.configReferences[]'"
pe ""

clear
p "Case 4: progressive per group when config changes"
pe "cat cma-progressive-per-group.yaml"
pe "kubectl apply -f cma-progressive-per-group.yaml"
pe "kubectl get cma managed-serviceaccount -oyaml"
pe "kubectl get mca -A -ojson | jq '.items[] | .metadata.namespace, .status.configReferences[]'"

pe "kubectl apply -f managed-serviceaccount-0.4.3.yaml"
pe "kubectl get cma managed-serviceaccount -oyaml"
pe "kubectl get mca -A -ojson | jq '.items[] | .metadata.namespace, .status.configReferences[]'"
pe ""

clear
