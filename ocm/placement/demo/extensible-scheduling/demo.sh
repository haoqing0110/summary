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

# hide the evidence
clear

p "Case 1: Users could use scores in AddOnPlacementScore to select clusters."
p "The environment has 5 managed clusters."
pe "oc get managedclusters"

p "A controller is maintaining the AddOnPlacementScore CRs for the 5 clusters."
pe "oc get AddOnPlacementScore -A"
pe "oc get AddOnPlacementScore xxx -oyaml"
pe "oc get AddOnPlacementScore xxx yyy zzz -oyaml"

p "I want to select 3 clusters with highest customized score cpuratio."
pe "cat placement1.yaml"
pe "oc create -f placement1.yaml"
pe "oc get placementdecision"

p "I want to select 1 clusters with lowest customized score cpuratio."
pe "cat placement2.yaml"
pe "oc create -f placement2.yaml"
pe "oc get placementdecision"

clear
p "Case 2: Disaster recovery workload could be automatically switched to an avaliable cluster."
p "The environment has 2 managed clusters, one is primary and one is backup."
pe "oc get managedclusters"

p "A controller is maintaining the AddOnPlacementScore CRs for the 2 clusters."
pe "oc get AddOnPlacementScore -A"

p "Primary cluster has score 100, backup has score 0."
pe "oc get AddOnPlacementScore xxx yyy -oyaml"

p "I want my workload running one the primary cluster."
pe "cat placement1.yaml"
pe "oc create -f placement1.yaml"
pe "oc get placementdecision"

p "Primary cluster is down."
pe "oc label clusters"

p "My workload switched to backup automatically."
pe "cat placement1.yaml"
pe "oc create -f placement1.yaml"
pe "oc get placementdecision"
