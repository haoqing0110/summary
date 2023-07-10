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
KUBECONFIG="/root/.kube/config"
clusteradm clusterset bind global --namespace default
#./delete.sh 310
#./create.sh 310
#./labels.sh 1 10 prod-canary-west=true
#./labels.sh 11 20 prod-canary-east=true

function play() {
	pe "cat $1.yaml"
	pe "kubectl apply -f $1.yaml"
	pe "kubectl get placement $1 -ojson | jq '.status.decisionGroups[]'"
	pe "kubectl get placementdecision -l cluster.open-cluster-management.io/placement=$1 -ojson | jq '.items[] | .metadata.name, .metadata.labels '"
}


clear
p "Placment strategy demo."
pe "clusteradm get clustersets -otable"
pe "kubectl get managedcluster -l prod-canary-west=true"
pe "kubectl get managedcluster -l prod-canary-east=true"

p "Case 1: placement has 2 decisionGroups defined."
play placement1

p "Case 2: placement has 2 decisionGroups defined, and want to group the rest of clusters with length 150."
play placement2

p "Case 3: placement does not have any decisionGroups defined."
play placement3

p "Case 4: placement does not have any decisionGroups defined, but want to group the clusters with length 150."
play placement4

pe "- end -"

clear
