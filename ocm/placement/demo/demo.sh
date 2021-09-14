#!/usr/bin/env bash

########################
# include the magic
########################
. ./demo-magic.sh


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
kubectl delete managedcluster hq1 hq2 hq3
clustertool --create -n demo -c hq1
clustertool --create -n demo -c hq2
clustertool --update -n demo -c hq1 -r "10,10,100Mi,1000Mi"
clustertool --update -n demo -c hq2 -r "2,10,200Mi,1000Mi"
kubectl delete -f placement1.yaml
kubectl delete -f placement2.yaml

# hide the evidence
clear

# print and execute: cd stuff
p "The env has below managed clusters"
kubectl get managedcluster --selector=cluster.open-cluster-management.io/clusterset=demo

p "Check the cluster resources"
kubectl get managedcluster --selector=cluster.open-cluster-management.io/clusterset=demo -o json | jq -r '[.items[] | {name:.metadata.name, allocatable:.status.allocatable, capacity:.status.capacity}]'
p "Deploy an application on 1 cluster whose allocatable to capacity ratio of CPU is larger than others"
pe "cat placement1.yaml"
pe "kubectl create -f placement1.yaml"
pe "kubectl get placement -n demo"
pe "kubectl describe placement -n demo"
pe "kubectl get placementdecision -n demo -oyaml"
pe "kubectl delete -f placement1.yaml"

clear
p "Check the cluster resources"
kubectl get managedcluster --selector=cluster.open-cluster-management.io/clusterset=demo -o json | jq -r '[.items[] | {name:.metadata.name, allocatable:.status.allocatable, capacity:.status.capacity}]'
p "Deploy an application on 1 cluster whose allocatable memory is larger than others"
pe "cat placement2.yaml"
pe "kubectl create -f placement2.yaml"
pe "kubectl get placement -n demo"
pe "kubectl describe placement -n demo"
pe "kubectl get placementdecision -n demo -oyaml"

p "What will happen if a new cluster added?"
clear
echo "What will happen if a new cluster added?"
p "Add a new cluster hq3 with 300Mi memory"
clustertool --create -n demo -c hq3
clustertool --update -n demo -c hq3 -r "10,10,300Mi,300Mi"
p "The env has below managed clusters"
kubectl get managedcluster --selector=cluster.open-cluster-management.io/clusterset=demo
p "Check the cluster resources"
kubectl get managedcluster --selector=cluster.open-cluster-management.io/clusterset=demo -o json | jq -r '[.items[] | {name:.metadata.name, allocatable:.status.allocatable, capacity:.status.capacity}]'
pe "kubectl describe placement -n demo"
pe "kubectl get placementdecision -n demo -oyaml"

p "How to keep the decision steady?"
clear
echo "How to keep the decision steady?"
pe "cat placement2-new.yaml"
pe "kubectl apply -f placement2-new.yaml"
p "Increase cluster hq2 to 400Mi memory"
clustertool --update -n demo -c hq2 -r "10,10,400Mi,1000Mi"
p "Check the cluster resources"
kubectl get managedcluster --selector=cluster.open-cluster-management.io/clusterset=demo -o json | jq -r '[.items[] | {name:.metadata.name, allocatable:.status.allocatable, capacity:.status.capacity}]'
pe "kubectl describe placement -n demo"
pe "kubectl get placementdecision -n demo -oyaml"
pe "kubectl delete -f placement2-new.yaml"
