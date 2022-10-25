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
NS="default"
c1="cluster1"
c2="cluster2"
#kubectl delete ns $(oc get managedcluster | awk '{print $1}')
KUBECONFIG="/root/.kube/config"
kubectl delete placement -n ${NS} $(kubectl get placement -n ${NS} | awk '{print $1}')
kubectl delete manifestwork -n ${c1} my-first-work
kubectl delete manifestwork -n ${c2} my-first-work
kubectl label managedclusters ${c1} purpose=test
kubectl label managedclusters ${c2} purpose=dev
clusteradm clusterset bind default --namespace default

clear 
p "Distribute workload with placement selected managed clusters"

pe "kubectl get mcl --show-labels"
pe "clusteradm get clusters -otable"
pe "clusteradm get clustersets -otable"

pe "cat placement1.yaml"
pe "kubectl apply -f placement1.yaml -n ${NS}"
pe "kubectl get placement -n ${NS}"
pe "kubectl get placementdecision -n ${NS}"
pe "kubectl describe placementdecision placement1-decision-1 -n ${NS} | grep Status -A 10"
pe "clusteradm get placements -otable"

p "You can parse the selected clusters and then operate on the target clusters."
p "You can also integrate a high-level workload orchestrator with the placement decision to leverage its scheduling capabilities."

pe "cat work.yaml"
pe "clusteradm create work my-first-work -f work.yaml --placement default/placement1"
pe "kubectl get manifestwork -A"
pe "kubectl --context kind-cluster1 get pods -A"

pe "cat placement1-update.yaml"
pe "kubectl apply -f placement1-update.yaml -n ${NS}"
pe "clusteradm get placements -otable"

pe "clusteradm create work my-first-work -f work.yaml --placement default/placement1 --overwrite"
pe "kubectl get manifestwork -A"
pe ""

kubectl delete placement -n ${NS} $(kubectl get placement -n ${NS} | awk '{print $1}')
clear
