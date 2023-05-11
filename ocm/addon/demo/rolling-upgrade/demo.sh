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

# prepare ocm env
# curl -sSL https://raw.githubusercontent.com/open-cluster-management-io/OCM/main/solutions/setup-dev-environment/local-up.sh | bash
export KUBECONFIG="/root/.kube/config"
kubectl delete -f config-v1.yaml
kubectl delete -f config-v2.yaml
kubectl delete -f config-v3.yaml
kubectl delete -f config-v4.yaml
kubectl apply -f addonhubconfigs.crd.yaml
clusteradm clusterset bind global --namespace default
kubectl apply -f placement-all.yaml
kubectl apply -f placement-canary.yaml
#pe "git clone git@github.com:open-cluster-management-io/addon-framework.git"
pe "cd addon-framework"
pe "make undeploy-helloworld"
pe "make deploy-helloworld"
pe "cd .."
clear

p "add-on rolling upgrade demo."
p "The environment has 2 managed clusters."
pe "kubectl get managedclusters"
p "Example addon helloworld is running on the hub."
pe "kubectl get deploy -n open-cluster-management helloworld-controller"
pe "kubectl get clustermanagementaddon"
pe "kubectl get clustermanagementaddon helloworld -oyaml"
pe "kubectl get managedclusteraddon -A"
pe ""
clear

p "Case 1: fresh install add-on agents with install strategy"
p "Enable addon-manager-controller."
pe "cat cluster-manager.yaml"
pe "kubectl apply -f cluster-manager.yaml"
pe "kubectl get deploy -n open-cluster-management-hub cluster-manager-addon-manager-controller"

pe "cat cma-fresh-install.yaml"
pe "cat config-v1.yaml"
pe "clusteradm get placements -otable"
pe "kubectl apply -f cma-fresh-install.yaml"
pe "kubectl apply -f config-v1.yaml"
pe "kubectl get managedclusteraddon -A"
pe "kubectl get clustermanagementaddon helloworld -oyaml"
pe "kubectl get managedclusteraddon -A -o=jsonpath='{range .items[*]}{.metadata.namespace}{\"\\t\"}{.status.configReferences}{\"\\n\"}{end}'"
pe ""

clear
p "Case 2: update all the add-on agents when config changes"
pe "cat cma-update-all.yaml"
pe "kubectl apply -f cma-update-all.yaml"
pe "kubectl get clustermanagementaddon helloworld -oyaml"

pe "cat config-v2.yaml"
pe "kubectl apply -f config-v2.yaml"
pe "kubectl get clustermanagementaddon helloworld -oyaml"
pe "kubectl get managedclusteraddon -A -o=jsonpath='{range .items[*]}{.metadata.namespace}{\"\\t\"}{.status.configReferences}{\"\\n\"}{end}'"
pe ""

clear
p "Case 3: rolling upgrade the add-on agents when config changes"
pe "cat cma-rolling-upgrade.yaml"
pe "kubectl apply -f cma-rolling-upgrade.yaml"
pe "kubectl get clustermanagementaddon helloworld -oyaml"
pe "kubectl get managedclusteraddon -A -o=jsonpath='{range .items[*]}{.metadata.namespace}{\"\\t\"}{.status.configReferences}{\"\\n\"}{end}'"

pe "cat config-v3.yaml"
pe "kubectl apply -f config-v3.yaml"
pe "kubectl get clustermanagementaddon helloworld -oyaml"
pe "kubectl get managedclusteraddon -A -o=jsonpath='{range .items[*]}{.metadata.namespace}{\"\\t\"}{.status.configReferences}{\"\\n\"}{end}'"
pe ""

clear
p "Case 4: rolling upgrade the add-on agents on canary clusters first"
pe "cat cma-rolling-upgrade-with-test-step1.yaml"
pe "cat config-v4.yaml"
pe "clusteradm get placements -otable"
pe "kubectl apply -f cma-rolling-upgrade-with-test-step1.yaml"
pe "kubectl apply -f config-v4.yaml"
pe "kubectl get clustermanagementaddon helloworld -oyaml"
pe "kubectl get managedclusteraddon -A -o=jsonpath='{range .items[*]}{.metadata.namespace}{\"\\t\"}{.status.configReferences}{\"\\n\"}{end}'"

p "you can manually do some testing on the canary clusters"
p "if everything works fine, apply the config to all the clusters"
pe "cat cma-rolling-upgrade-with-test-step2.yaml"
pe "kubectl apply -f cma-rolling-upgrade-with-test-step2.yaml"
pe "kubectl get clustermanagementaddon helloworld -oyaml"
pe "kubectl get managedclusteraddon -A -o=jsonpath='{range .items[*]}{.metadata.namespace}{\"\\t\"}{.status.configReferences}{\"\\n\"}{end}'"
pe ""

clear
