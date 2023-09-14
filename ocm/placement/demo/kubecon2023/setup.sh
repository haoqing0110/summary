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
hub="hub"
c1="cluster1"
c2="cluster2"
kind delete cluster --name $hub
kind delete cluster --name $c1
kind delete cluster --name $c2
KUBECONFIG="/root/.kube/config"

clear 
p "Setup the OCM clusters"
pe "curl -L https://raw.githubusercontent.com/open-cluster-management-io/ocm/main/solutions/deploy-argocd-apps/setup-ocm.sh | bash"

p "Install Argo CD"
pe "kubectl create namespace argocd"
pe "kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml"
p "Confirm that all pods are running."
pe "kubectl -n argocd get pods"

p "Integrate OCM with Argo CD"
pe "kubectl port-forward svc/argocd-server -n argocd 8080:443 &"
pe "curl -L https://raw.githubusercontent.com/open-cluster-management-io/ocm/main/solutions/deploy-argocd-apps/setup-argocd.sh | bash"
pe ""

clear
