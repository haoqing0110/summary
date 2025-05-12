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
# ./local-up.sh
export KUBECONFIG=/root/.kube/config
clusteradm clusterset bind global --namespace default

# Label cluster1 with test=true
kubectl delete -f ./
kubectl label managedcluster cluster1 openshiftVersion=4.16.0
kubectl label managedcluster cluster2 openshiftVersion=4.17.0

clear 
pe "kubectl get mcl --show-labels"
# Show the basic placements
p "1. The user can select clusters by version listed in ManagedCluster labels, status.version or status.clusterClaims."
pe "cat placement-version1.yaml"
pe "kubectl apply -f placement-version1.yaml"
pe "clusteradm get placements -otable"

p "2. The user can use CEL Standard macros and Standard functions to select clusters."
pe "cat placement-version2.yaml"
pe "kubectl apply -f placement-version2.yaml"
pe "clusteradm get placements -otable"

pe "cat placement-version3.yaml"
pe "kubectl apply -f placement-version3.yaml"
pe "clusteradm get placements -otable"

p "3. The user can use CEL to select clusters by AddonPlacementScore."
pe "cat placement-score.yaml"
pe "kubectl apply -f placement-score.yaml"
pe "clusteradm get placements -otable"

p "4. Invalid CEL expressions."
pe "cat placement-invalid.yaml"
pe "kubectl apply -f placement-invalid.yaml"
pe "kubectl get placement -n default placement-invalid -o yaml"
pe "clusteradm get placements -otable"
pe ""

kubectl delete -f ./
kubectl label managedcluster cluster1 openshiftVersion-"
kubectl label managedcluster cluster2 openshiftVersion-"