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
c1=cluster1
c2=cluster2
#kubectl delete ns $(oc get managedcluster | awk '{print $1}')
KUBECONFIG="/root/.kube/config"

# hide the evidence
clusteradm clusterset bind default --namespace default
clusteradm delete work my-first-work --cluster cluster1
clusteradm delete work my-first-work --cluster cluster2
kubectl delete -f placement.yaml

clear
p "There are 2 ManagedCluster and a default ManagedClusterSet."
pe "clusteradm get clusters"
pe "clusteradm get clustersets"

p "Create a Placement placement1 to select the 2 clusters in default ManagedClusterSet."
pe "cat placement.yaml"
pe "kubectl create -f placement.yaml"

p "Use clusteradm to create ManifestWork my-first-work with Placement placement1."
pe "cat work.yaml"
pe "clusteradm create work my-first-work -f work.yaml --placement default/placement1"
pe "kubectl get manifestwork -A"

p "Update the Placement placement1 to select only 1 managed cluster."
pe "kubectl patch placement placement1 --patch '{\"spec\": {\"clusterSets\": [\"default\"],\"numberOfClusters\": 1}}' --type=merge"

p "Use clusteradm to reschedule ManifestWork my-first-work to the newly selected cluster."
pe "clusteradm create work my-first-work -f work.yaml --placement default/placement1 --overwrite"
pe "kubectl get manifestwork -A"

cmd
clear
