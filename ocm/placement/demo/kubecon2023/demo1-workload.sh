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
NS="argocd"
c1="cluster1"
c2="cluster2"
#kubectl delete ns $(oc get managedcluster | awk '{print $1}')
KUBECONFIG="/root/.kube/config"
kubectl delete placement -n ${NS} $(kubectl get placement -n ${NS} | awk '{print $1}')
kubectl delete -f guestbook-app.yaml
kubectl label managedclusters ${c1} purpose=test
kubectl label managedclusters ${c2} purpose=dev

clear 
p "Distribute argocd application with placement selected managed clusters"

p "list ocm clusters"
pe "kubectl get mcl --show-labels"
p "list argocd registered clusters"
pe "argocd cluster list"

pe "cat placement1.yaml"
pe "kubectl apply -f placement1.yaml -n ${NS}"
pe "clusteradm get placements -otable"

pe "cat guestbook-app.yaml"
pe "kubectl apply -f guestbook-app.yaml"
pe "kubectl -n argocd get applicationsets"
pe "kubectl -n argocd get applications"
pe "kubectl --context kind-cluster1 -n guestbook get pods"

pe "cat placement1-update.yaml"
pe "kubectl apply -f placement1-update.yaml -n ${NS}"
pe "clusteradm get placements -otable"
pe "kubectl -n argocd get applications"
pe "kubectl --context kind-cluster2 -n guestbook get pods"

pe ""
kubectl delete placement -n ${NS} $(kubectl get placement -n ${NS} | awk '{print $1}')
kubectl delete -f guestbook-app.yaml
clear
