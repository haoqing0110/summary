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
KUBECONFIG="/root/.kube/config"
kubectl delete placement -n ${NS} $(kubectl get placement -n ${NS} | awk '{print $1}')
kubectl patch managedcluster ${c1} -p '{"spec":{"taints":[]}}' --type=merge
kubectl patch managedcluster ${c2} -p '{"spec":{"taints":[]}}' --type=merge
kubectl delete addonplacementscore -n ${c1} resource-usage-score
kubectl delete addonplacementscore -n ${c2} resource-usage-score
kubectl delete -f guestbook-app.yaml
clear

clear

p "Distribute argocd application to clusters with highest customized score cpuAvailable"

p "list ocm clusters"
pe "kubectl get mcl --show-labels"
p "list argocd registered clusters"
pe "argocd cluster list"

p "Deploy customized score addon resource-usage-collect"
pe "git clone git@github.com:open-cluster-management-io/addon-contrib.git"
pe "cd addon-contrib/resource-usage-collect-addon"
pe "make deploy"
pe "cd -"
pe "kubectl get pods -n open-cluster-management | grep resource-usage-collect-controller"
pe "kubectl --context kind-cluster1 get pods -n default | grep resource-usage-collect-agent"
pe "kubectl --context kind-cluster2 get pods -n default | grep resource-usage-collect-agent"
pe "kubectl get addonplacementscore -A"
pe "kubectl get addonplacementscore -n cluster1 resource-usage-score -oyaml"
pe "kubectl get addonplacementscore -A -o=jsonpath='{range .items[*]}{.metadata.namespace}{\"\t\"}{.status.scores}{\"\n\"}{end}'"
pe "kubectl --context kind-cluster1 get pods -A"
pe "kubectl --context kind-cluster2 get pods -A"

pe "cat placement4.yaml"
pe "kubectl apply -f placement4.yaml -n ${NS}"
pe "clusteradm get placements -otable"
pe "kubectl describe -f placement4.yaml -n ${NS} | grep Events -A 10"

pe "cat guestbook-app.yaml"
pe "kubectl apply -f guestbook-app.yaml"
pe "kubectl -n argocd get applicationsets"
pe "kubectl -n argocd get applications"
pe ""

kubectl patch managedcluster ${selected} -p '{"spec":{"taints":[]}}' --type=merge
kubectl delete placement -n ${NS} $(kubectl get placement -n ${NS} | awk '{print $1}')
kubectl delete -f guestbook-app.yaml
clear
