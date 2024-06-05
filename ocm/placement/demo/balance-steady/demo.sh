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
clusteradm clusterset unbind clusterset1 --namespace default
clusteradm clusterset unbind clusterset2 --namespace default
kubectl delete managedcluster $(oc get managedcluster | awk '{print $1}')
kubectl delete placement $(oc get placement | awk '{print $1}')

clear
p "create 3 fake managed clusters, clusterset1, clusterset2"
pe "./create-fake-mcl.sh 3"
pe "clusteradm create clusterset clusterset1"
pe "clusteradm create clusterset clusterset2"

pe "clusteradm clusterset set clusterset1 --clusters fakecluster1,fakecluster2"
pe "clusteradm clusterset set clusterset2 --clusters fakecluster3"

p "bind clusterset1 to default namespace"
pe "clusteradm clusterset bind clusterset1 --namespace default"
pe "clusteradm get clustersets -otable"
pe "clusteradm get clusters -otable"

p "create 3 placements, default has Steady and Balance prioritizers with weight 1"
pe "cat placement.yaml"
pe "./create-placement.sh placement.yaml 1"
pe "./create-placement.sh placement.yaml 2"
pe "./create-placement.sh placement.yaml 3"
pe "clusteradm get placements -otable"

p "bind clusterset2 to default namespace"
pe "clusteradm clusterset bind clusterset2 --namespace default"
pe "clusteradm get placements -otable"

p "placement decision changes when adding clusterset2"
p "let's try to increase the Steady to weight 3"

p "clean the placements and clusterset2 binding"
pe "clusteradm clusterset unbind clusterset2 --namespace default"
pe "kubectl delete placement $(oc get placement | awk '{print $1}')"

p "create 3 placements, Steady with weight 3 and Balance with weight 1"
pe "cat placement2.yaml"
pe "./create-placement.sh placement2.yaml 1"
pe "./create-placement.sh placement2.yaml 2"
pe "./create-placement.sh placement2.yaml 3"
pe "clusteradm get placements -otable"

p "bind clusterset2 to default namespace"
pe "clusteradm clusterset bind clusterset2 --namespace default"
pe "clusteradm get placements -otable"

p "placement decision keeps steady when adding clusterset2"

p "create more placements"
pe "./create-placement.sh placement2.yaml 4"
pe "./create-placement.sh placement2.yaml 5"
pe "./create-placement.sh placement2.yaml 6"
pe "clusteradm get placements -otable"
p "placement decision keeps balance and steady"

p ""
clear
