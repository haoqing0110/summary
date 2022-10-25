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

p "Extend the multicluster scheduling capabilities with placement"

pe "clusteradm get clusters"
pe "clusteradm get clustersets"

p "Deploy customized score addon resource-usage-collect"
pe "git clone git@github.com:JiahaoWei-RH/resource-usage-collect.git"
pe "cd resource-usage-collect"
pe "make deploy"
pe "kubectl get pods -n open-cluster-management | grep resource-usage-collect-controller"
pe "kubectl get pods -n default | grep resource-usage-collect-agent"
pe "kubectl get addonplacementscore -A"
#pe "kubectl get addonplacementscore -n cluster1 resource-usage-score -oyaml"
pe "kubectl get addonplacementscore -A -o=jsonpath='{range .items[*]}{.metadata.namespace}{\"\t\"}{.status.scores}{\"\n\"}{end}'"


p "Select 1 clusters with highest customized score cpuratio."
pe "cat placement3.yaml"
pe "kubectl create -f placement3.yaml -n ${NS}"
pe "kubectl get placement -n ${NS}"
pe "kubectl describe -f placement3.yaml -n ${NS} | grep Events -A 10"
pe "kubectl get placementdecision -n ${NS}"
pe "kubectl describe placementdecision placement3-decision-1 -n ${NS} | grep Status -A 10"

clear
