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
kubectl delete managedcluster $(oc get managedcluster | awk '{print $1}')
kubectl delete placement $(oc get placement | awk '{print $1}')

clear
pe "kubectl get managedclusters"
pe "./create-fake-mcl.sh 10"
pe "kubectl get managedclusters"
pe "clusteradm clusterset bind global --namespace default"

pe "clusteradm get placements -otable"
pe "./create-placement.sh 10"
pe "clusteradm get placements -otable"

p ""
clear
