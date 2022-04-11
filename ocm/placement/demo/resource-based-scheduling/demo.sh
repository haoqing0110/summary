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
c1=cluster1
c2=cluster2
c3=cluster3

kubectl delete managedcluster ${c1} ${c2} ${c3}
clustertool --create -n demo-hq -c ${c1}
clustertool --create -n demo-hq -c ${c2}
clustertool --update -n demo-hq -c ${c1} -r "4,4,100Mi,100Mi"
clustertool --update -n demo-hq -c ${c2} -r "5,10,200Mi,1000Mi"
kubectl delete -f placement1.yaml

# hide the evidence
clear
p "Deploy an application on 1 cluster whose allocatable memory is larger than others"
p "The env has below managed clusters"
kubectl get managedcluster --selector=cluster.open-cluster-management.io/clusterset=demo-hq
p "Check the cluster resources"
kubectl get managedcluster --selector=cluster.open-cluster-management.io/clusterset=demo-hq -o json | jq -r '[.items[] | {name:.metadata.name, allocatable:.status.allocatable, capacity:.status.capacity}]'
pe "cat placement1.yaml"
pe "kubectl create -f placement1.yaml"
pe "kubectl get placement -n demo-hq"
pe "kubectl describe placement -n demo-hq"
pe "kubectl get placementdecision -n demo-hq -oyaml"

p "What will happen if a new cluster added?"
clear
echo "What will happen if a new cluster added?"
p "Add a new cluster with 300Mi memory"
clustertool --create -n demo-hq -c ${c3}
clustertool --update -n demo-hq -c ${c3} -r "10,10,300Mi,300Mi"
p "The env has below managed clusters"
kubectl get managedcluster --selector=cluster.open-cluster-management.io/clusterset=demo-hq
p "Check the cluster resources"
kubectl get managedcluster --selector=cluster.open-cluster-management.io/clusterset=demo-hq -o json | jq -r '[.items[] | {name:.metadata.name, allocatable:.status.allocatable, capacity:.status.capacity}]'
pe "kubectl describe placement -n demo-hq"
pe "kubectl get placementdecision -n demo-hq -oyaml"

p "How to keep the decision steady?"
clear
echo "How to keep the decision steady?"
pe "cat placement1-new.yaml"
pe "kubectl apply -f placement1-new.yaml"
p "Increase cluster2 to 400Mi memory"
clustertool --update -n demo-hq -c ${c2} -r "10,10,400Mi,1000Mi"
p "Check the cluster resources"
kubectl get managedcluster --selector=cluster.open-cluster-management.io/clusterset=demo-hq -o json | jq -r '[.items[] | {name:.metadata.name, allocatable:.status.allocatable, capacity:.status.capacity}]'
pe "kubectl describe placement -n demo-hq"
pe "kubectl get placementdecision -n demo-hq -oyaml"
pe "kubectl delete -f placement1-new.yaml"
