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
c1="cluster1"
c2="cluster2"
#kubectl delete ns $(oc get managedcluster | awk '{print $1}')
KUBECONFIG="/root/.kube/config"
kubectl delete placement -n ${NS} $(kubectl get placement -n ${NS} | awk '{print $1}')
kubectl delete managedcluster $(oc get managedcluster | awk '{print $1}')

kubectl create ns ${NS}
clustertool --create -c ${c1} -n ${NS}
clustertool --create -c ${c2} -n ${NS}
kubectl patch managedcluster ${c1} -p '{"spec":{"taints":[{"effect":"NoSelect","key":"cluster.open-cluster-management.io/unreachable"}]}}' --type=merge
kubectl patch managedcluster ${c2} -p '{"spec":{"taints":[{"effect":"NoSelect","key":"cluster.open-cluster-management.io/unreachable"}]}}' --type=merge

clear 
p "Case 1: DO NOT schedule workload to clusters with taint."
pe "kubectl get managedclusters"
pe "kubectl get managedclusters -A -o=jsonpath='{range .items[*]}{.metadata.name}{\"\\t\"}{.spec.taints}{\"\\n\"}{end}'"
pe "cat placement1.yaml"
pe "kubectl apply -f placement1.yaml -n ${NS}"
pe "kubectl get placement -n ${NS}"
pe "kubectl get placementdecision -n ${NS}"
p ""

p "Case 2: User could use toleration to schedule workload to clusters with taint."
pe "cat placement1-toleration.yaml"
pe "kubectl apply -f placement1-toleration.yaml -n ${NS}"
pe "kubectl get placement -n ${NS}"
pe "kubectl get placementdecision -n ${NS}"
pe "kubectl describe placementdecision demo1-decision-1 -n ${NS} | grep Status -A 10"
p ""

clear 
p "Case 3: User workload could be transferred to another available managed cluster after a tolerated time."
p "Clear the taint"
kubectl patch managedcluster ${c1} -p '{"spec":{"taints":[]}}' --type=merge
kubectl patch managedcluster ${c2} -p '{"spec":{"taints":[]}}' --type=merge
pe "kubectl get managedclusters -A -o=jsonpath='{range .items[*]}{.metadata.name}{\"\\t\"}{.spec.taints}{\"\\n\"}{end}'"

pe "cat placement2.yaml"
pe "kubectl apply -f placement2.yaml -n ${NS}"
pe "kubectl get placement -n ${NS}"
pe "kubectl get placementdecision -n ${NS}"
pe "kubectl describe placementdecision demo2-decision-1 -n ${NS} | grep Status -A 10"

p "Set unreachable taint to the selected cluster"
selected=$(kubectl get placementdecision demo2-decision-1 -n ${NS} -o=jsonpath='{.status.decisions[0].clusterName}')
kubectl patch managedcluster ${selected} -p '{"spec":{"taints":[{"effect":"NoSelect","key":"cluster.open-cluster-management.io/unreachable"}]}}' --type=merge
pe "kubectl get managedclusters -A -o=jsonpath='{range .items[*]}{.metadata.name}{\"\\t\"}{.spec.taints}{\"\\n\"}{end}'"

pe "kubectl describe placementdecision demo2-decision-1 -n ${NS} | grep Status -A 10"
pe "kubectl describe placementdecision demo2-decision-1 -n ${NS} | grep Status -A 10"
pe "kubectl describe placementdecision demo2-decision-1 -n ${NS} | grep Status -A 10"
