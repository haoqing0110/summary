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
NS="demohq"
c1="cluster-hq-1"
c2="cluster-hq-2"
#kubectl delete ns $(oc get managedcluster | awk '{print $1}')
export KUBECONFIG="/root/.kube/config"
kubectl delete placement -n ${NS} $(kubectl get placement -n ${NS} | awk '{print $1}')
kubectl delete managedcluster ${c1}
kubectl delete managedcluster ${c2}

kubectl create ns ${NS}
clustertool --create -c ${c1} -n ${NS}
clustertool --create -c ${c2} -n ${NS}
#kubectl patch managedcluster ${c1} -p '{"spec":{"taints":[{"effect":"NoSelect","key":"cluster.open-cluster-management.io/unreachable"}]}}' --type=merge
#kubectl patch managedcluster ${c2} -p '{"spec":{"taints":[{"effect":"NoSelect","key":"cluster.open-cluster-management.io/unreachable"}]}}' --type=merge
kubectl label managedclusters ${c1} purpose=test
kubectl label managedclusters ${c2} purpose=dev

clear 
p "The environment has 2 managed clusters bound to namespace ${NS}."
pe "clusteradm get clusters"
pe "clusteradm get clustersets"
pe "kubectl get managedclusters --show-labels"
p ""

p "There is a placement with incorrect label selector and prioritizer configuration."
pe "cat placement.yaml"
pe "kubectl create -f placement.yaml -n ${NS}"
pe "kubectl get placement -n ${NS}"
pe "kubectl describe placement -n ${NS}"

p "Let's fix the label selector configuration error."
pe "kubectl patch placement -n ${NS} demo1 -p '{\"spec\": {\"predicates\": [{\"requiredClusterSelector\": {\"labelSelector\": {\"matchExpressions\": [{\"key\": \"purpose\",\"operator\": \"In\",\"values\": [\"test\"]}]}}}]}}' --type=merge"
pe "kubectl get placement -n ${NS}"
pe "kubectl describe placement -n ${NS}"

p "Let's fix the prioritizer configuration error."
pe "kubectl patch placement -n ${NS} demo1 -p '{\"spec\": {\"prioritizerPolicy\": {\"configurations\": [{\"scoreCoordinate\": {\"builtIn\": \"Steady\",\"type\": \"BuiltIn\"},\"weight\": 3}],\"mode\": \"Exact\"}}}' --type=merge"
pe "kubectl get placement -n ${NS}"
pe "kubectl describe placement -n ${NS}"
pe "kubectl get placementdecision -n ${NS} -oyaml"
p ""

clear 

