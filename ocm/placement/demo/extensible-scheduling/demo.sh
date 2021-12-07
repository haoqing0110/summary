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
kubectl delete managedcluster cluster1 cluster2 cluster3
kubectl delete ns cluster1 cluster2 cluster3 demo

# hide the evidence
clear
NS="demo"
oc create ns ${NS}
oc create ns cluster1
oc create ns cluster2
oc create ns cluster3
clustertool --create -c cluster1 -n ${NS}
clustertool --create -c cluster2 -n ${NS}
clustertool --create -c cluster3 -n ${NS}
p "Case 1: Users could use scores in AddOnPlacementScore to select clusters."
p "The environment has 3 managed clusters."
pe "oc get managedclusters"

p "A controller is maintaining the AddOnPlacementScore CRs for the 3 clusters."
p "scoretool --crname demo"

pe "oc get AddOnPlacementScore -A"
pe "oc get AddOnPlacementScore -A -oyaml"

p "I want to select 2 clusters with highest customized score cpuratio."
pe "cat placement1.yaml"
pe "oc create -f placement1.yaml -n ${NS}"
pe "oc describe -f placement1.yaml -n ${NS}"
pe "oc describe placementdecision placement1 -n ${NS}"

p "I want to select 1 clusters with lowest customized score cpuratio."
pe "cat placement2.yaml"
pe "oc create -f placement2.yaml -n ${NS}"
pe "oc describe -f placement2.yaml -n ${NS}"
pe "oc describe placementdecision placement2 -n ${NS}"

clear
oc delete -f placement1.yaml -n ${NS}
oc delete -f placement2.yaml -n ${NS}
oc delete managedcluster cluster1
oc delete managedcluster cluster2
oc delete managedcluster cluster3
oc create ns primary
oc create ns backup
clustertool --create -c primary -n ${NS}
clustertool --create -c backup -n ${NS}
p "Case 2: Disaster recovery workload could be automatically switched to an avaliable cluster."
p "The environment has 2 managed clusters, one is primary and one is backup."
pe "oc get managedclusters"

p "A controller is maintaining the AddOnPlacementScore CRs for the 2 clusters."
p "scoretool --crname dr --clusters primary,backup --scores 100,0"

pe "oc get AddOnPlacementScore -A"
pe "oc get AddOnPlacementScore -A -oyaml"

p "I want my workload running one the primary cluster."
pe "cat placement3.yaml"
pe "oc create -f placement3.yaml -n ${NS}"
pe "oc describe -f placement3.yaml -n ${NS}"
pe "oc describe placementdecision placement3 -n ${NS}"

p "Primary cluster is down."
pe "oc label clusters"

p "My workload switched to backup automatically."
pe "cat placement1.yaml"
pe "oc create -f placement1.yaml"
pe "oc get placementdecision"
