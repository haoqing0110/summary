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
kubectl delete -f guestbook-app.yaml
kubectl patch managedcluster ${c1} -p '{"spec":{"taints":[]}}' --type=merge
kubectl patch managedcluster ${c2} -p '{"spec":{"taints":[]}}' --type=merge

clear 
p "Distribute argocd application with placement taints/tolerations"

p "list ocm clusters"
pe "kubectl get mcl --show-labels"
p "list argocd registered clusters"
pe "argocd cluster list"

pe "cat placement2.yaml"
pe "kubectl apply -f placement2.yaml -n ${NS}"
pe "clusteradm get placements -otable"

pe "cat guestbook-app.yaml"
pe "kubectl apply -f guestbook-app.yaml"
pe "kubectl -n argocd get applicationsets"
pe "kubectl -n argocd get applications"
pe "kubectl --context kind-cluster1 -n guestbook get pods"

selected=$(kubectl get placementdecision guestbook-app-placement-decision-1 -n ${NS} -o=jsonpath='{.status.decisions[0].clusterName}')
p "Set unavailable taint to the ${selected}"
pe "kubectl patch managedcluster ${selected} -p '{\"spec\":{\"taints\":[{\"effect\":\"NoSelect\",\"key\":\"unavailable\"}]}}'" --type=merge
pe "kubectl get managedclusters -A -o=jsonpath='{range .items[*]}{.metadata.name}{\"\\t\"}{.spec.taints}{\"\\n\"}{end}'"

p "User workload could be transferred to another available managed cluster after a tolerated time."
pe "clusteradm get placements -otable"
pe "sleep 30"
pe "clusteradm get placements -otable"

pe "kubectl -n argocd get applications"
pe "kubectl --context kind-cluster2 -n guestbook get pods"

pe ""
kubectl patch managedcluster ${selected} -p '{"spec":{"taints":[]}}' --type=merge
kubectl delete placement -n ${NS} $(kubectl get placement -n ${NS} | awk '{print $1}')
kubectl delete -f guestbook-app.yaml

clear
