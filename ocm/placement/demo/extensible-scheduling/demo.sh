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
KUBECONFIG="/root/kind.config"
scoretool --clean --resource-name demo1
scoretool --clean --resource-name demo2
kubectl delete managedcluster $(oc get managedcluster | awk '{print $1}')
kubectl delete -f  ./ -n demo1
kubectl delete -f  ./ -n demo2

# hide the evidence
kubectl create ns ${NS}
kubectl create ns cluster1
kubectl create ns cluster2
kubectl create ns cluster3
clustertool --create -c cluster1 -n ${NS}
clustertool --create -c cluster2 -n ${NS}
clustertool --create -c cluster3 -n ${NS}

clear
p "Placment extensible scheduling demo. Users could use scores in AddOnPlacementScore to select clusters."
p "Precondition 1: The environment has 3 managed clusters."
pe "kubectl get managedclusters"

p "Precondition 2: A controller is maintaining the AddOnPlacementScore CRs for the 3 clusters."
p "scoretool --resource-name demo1 --interval 30"
pe "kubectl get AddOnPlacementScore -A"
pe "kubectl get AddOnPlacementScore -A -oyaml"
pe "kubectl get addonplacementscore -A -o=jsonpath='{range .items[*]}{.metadata.namespace}{\"\\t\"}{.status.scores}{\"\\n\"}{end}'"

p "Case 1: I want to select 2 clusters with highest customized score cpuratio."
pe "cat demo1-1.yaml"
pe "kubectl create -f demo1-1.yaml -n ${NS}"
pe "kubectl describe -f demo1-1.yaml -n ${NS} | grep Events -A 10"
pe "kubectl describe placementdecision demo1-1-decision-1 -n ${NS} | grep Status -A 10"
p "Placement reschedule every 5 minutes (in this demo is 30s)"
cmd
cmd
cmd
cmd
cmd
cmd
cmd
cmd
cmd
cmd

p "Case 2: I want to select 2 clusters with highest customized score cpuratio and keep the decision steady."
pe "cat demo1-2.yaml"
pe "kubectl create -f demo1-2.yaml -n ${NS}"
pe "kubectl get -f demo1-2.yaml -n ${NS} -oyaml"
pe "kubectl describe -f demo1-2.yaml -n ${NS} | grep Events -A 10"
pe "kubectl describe placementdecision demo1-2-decision-1 -n ${NS} | grep Status -A 10"
cmd
cmd
cmd
cmd
cmd
cmd
cmd
cmd
cmd
cmd

p "Case 3: I want to select 1 cluster with lowest customized score cpuratio."
pe "cat demo1-3.yaml"
pe "kubectl create -f demo1-3.yaml -n ${NS}"
pe "kubectl describe -f demo1-3.yaml -n ${NS} | grep Events -A 10"
pe "kubectl describe placementdecision demo1-3-decision-1 -n ${NS} | grep Status -A 10"

pe "- end -"

clear
#kubectl delete managedcluster $(oc get managedcluster | awk '{print $1}')
#kubectl delete -f  ./ -n ${NS}
#NS="demo2"
#kubectl delete -f  ./ -n ${NS}
#kubectl create ns ${NS}
#kubectl create ns primary
#kubectl create ns backup
#clustertool --create -c primary -n ${NS}
#clustertool --create -c backup -n ${NS}
#
#clear
#p "Case 2: Disaster recovery workload could be automatically switched to an avaliable cluster."
#p "The environment has 2 managed clusters, one is primary and one is backup."
#pe "kubectl get managedclusters"
#
#p "A controller is maintaining the AddOnPlacementScore CRs for the 2 clusters."
#p "scoretool --resource-name demo2 --clusters primary,backup --scores 100,1 --interval 30"
#
#pe "kubectl get AddOnPlacementScore -A"
#pe "kubectl get AddOnPlacementScore -A -oyaml"
#
#p "I want my workload running one the primary cluster."
#pe "cat demo2.yaml"
#pe "kubectl create -f demo2.yaml -n ${NS}"
#pe "kubectl describe -f demo2.yaml -n ${NS}"
#pe "kubectl describe placementdecision demo2 -n ${NS}"
#
#p "Primary cluster is down."
#pe "kubectl label clusters"
#
#p "My workload switched to backup automatically."
#pe "kubectl describe placementdecision demo2 -n ${NS}"
#
