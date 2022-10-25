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
KUBECONFIG="/root/.kube/config"
kubectl delete placement -n ${NS} $(kubectl get placement -n ${NS} | awk '{print $1}')
kubectl patch managedcluster ${c1} -p '{"spec":{"taints":[]}}' --type=merge
kubectl patch managedcluster ${c2} -p '{"spec":{"taints":[]}}' --type=merge
clusteradm clusterset bind default --namespace default

clear 
p "cluster maintenance with placement taints/tolerations"
pe "kubectl get managedclusters -A -o=jsonpath='{range .items[*]}{.metadata.name}{\"\\t\"}{.spec.taints}{\"\\n\"}{end}'"

pe "cat placement2.yaml"
pe "kubectl apply -f placement2.yaml -n ${NS}"
pe "kubectl get placement -n ${NS}"
pe "kubectl get placementdecision -n ${NS}"
pe "kubectl describe placementdecision placement2-decision-1 -n ${NS} | grep Status -A 10"

p "Set unreachable taint to the selected cluster"
selected=$(kubectl get placementdecision demo2-decision-1 -n ${NS} -o=jsonpath='{.status.decisions[0].clusterName}')
pe "kubectl patch managedcluster ${selected} -p '{\"spec\":{\"taints\":[{\"effect\":\"NoSelect\",\"key\":\"cluster.open-cluster-management.io/unreachable\"}]}}'" --type=merge
#pe "kubectl get managedclusters -A -o=jsonpath='{range .items[*]}{.metadata.name}{\"\\t\"}{.spec.taints}{\"\\n\"}{end}'"

p "User workload could be transferred to another available managed cluster after a tolerated time."
pe "kubectl describe placementdecision placement2-decision-1 -n ${NS} | grep Status -A 10"
pe "kubectl describe placementdecision placement2-decision-1 -n ${NS} | grep Status -A 10"
pe "kubectl describe placementdecision placement2-decision-1 -n ${NS} | grep Status -A 10"

kubectl patch managedcluster ${selected} -p '{"spec":{"taints":[]}}' --type=merge
clear
