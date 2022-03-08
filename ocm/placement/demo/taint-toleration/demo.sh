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
NS="demo1"
#kubectl delete ns $(oc get managedcluster | awk '{print $1}')
KUBECONFIG="/root/.kube/config"
kubectl delete managedcluster $(kubectl get managedcluster | awk '{print $1}')
kubectl delete placement -n ${NS} $(kubectl get placement -n ${NS} | awk '{print $1}')

# hide the evidence
kubectl create ns ${NS}
kubectl create ns cluster1
kubectl create ns cluster2
kubectl create ns cluster3

kubectl apply -f cluster-maintaining/cluster1.yaml
clear 
p "Case 1: DO NOT schedule workload to clusters with taint."
pe "kubectl get managedclusters"
pe "kubectl get managedclusters -A -o=jsonpath='{range .items[*]}{.metadata.name}{\"\\t\"}{.spec}{\"\\n\"}{end}'"
pe "cat cluster-maintaining/placement1.yaml"
pe "kubectl apply -f cluster-maintaining/placement1.yaml -n ${NS}"
pe "kubectl get placement -n demo1"
pe "kubectl get placementdecision -n demo1"
p ""

p "Case 2: User could use toleration to schedule workload to clusters with taint."
p "Adding tolerations to placement"
pe "cat schedule-on-certain/placement1-new.yaml"
pe "kubectl apply -f schedule-on-certain/placement1-new.yaml -n ${NS}"
pe "kubectl get placement -n demo1"
pe "kubectl get placementdecision -n demo1"
pe "kubectl describe placementdecision demo1-decision-1 -n ${NS} | grep Status -A 10"
p ""

#kubectl delete -f schedule-on-certain/placement1-new.yaml
#kubectl apply -f eviction/cluster1.yaml
#kubectl apply -f eviction/cluster2.yaml
#kubectl apply -f eviction/cluster3.yaml
#clear
#p "Case 3: Immediate Eviction."
#p "When a managed cluster gets offline, the system can make applications deployed on this cluster to be transferred to another available managed cluster immediately."
#pe "kubectl get managedclusters"
#pe "kubectl get managedclusters -A -o=jsonpath='{range .items[*]}{.metadata.name}{\"\\t\"}{.spec}{\"\\n\"}{end}'"
#pe "cat eviction/placement3.yaml"
#pe "kubectl apply -f eviction/placement3.yaml -n ${NS}"
#pe "kubectl get placement -n demo1"
#pe "kubectl get placementdecision -n demo1"
#pe "kubectl describe placementdecision demo3-decision-1 -n ${NS} | grep Status -A 10"
#selected=$(kubectl get placementdecision demo3-decision-1 -n demo1  -o=jsonpath='{.status.decisions[0].clusterName}')
#git checkout eviction/cluster.yaml
#sed -i "s/PLACEHOLDER/${selected}/g" eviction/cluster.yaml
#p "Adding taints to ${selected}"
#pe "cat eviction/cluster.yaml"
#pe "kubectl apply -f eviction/cluster.yaml -n ${NS}"
#pe "kubectl get managedclusters -A -o=jsonpath='{range .items[*]}{.metadata.name}{\"\\t\"}{.spec}{\"\\n\"}{end}'"
#pe "kubectl describe placementdecision demo3-decision-1 -n ${NS} | grep Status -A 10"
#p ""
#clear
