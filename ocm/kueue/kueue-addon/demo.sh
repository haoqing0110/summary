#!/usr/bin/env bash

########################
# include the magic
########################
. ./demo-magic.sh

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
DEMO_PROMPT="${GREEN}➜ ${CYAN}\\W "

# text color
# DEMO_CMD_COLOR=$BLACK

# clean env - cleanup any previous demo resources
kubectl delete -f ./multikueue-setup-demo1.yaml >/dev/null 2>&1
kubectl delete -f ./multikueue-setup-demo2.yaml >/dev/null 2>&1  
kubectl delete -f ./placement-demo2-1.yaml >/dev/null 2>&1
kubectl delete -f ./placement-demo2-2.yaml >/dev/null 2>&1
kubectl delete job --context kind-hub $(kubectl get job --context kind-hub -o name 2>/dev/null | head -20) >/dev/null 2>&1
kubectl delete job --context kind-cluster1 $(kubectl get job --context kind-cluster1 -o name 2>/dev/null | head -20) >/dev/null 2>&1
kubectl delete job --context kind-cluster2 $(kubectl get job --context kind-cluster2 -o name 2>/dev/null | head -20) >/dev/null 2>&1
kubectl delete job --context kind-cluster3 $(kubectl get job --context kind-cluster3 -o name 2>/dev/null | head -20) >/dev/null 2>&1
clear

########################
# Demo Introduction
########################

p "Kueue-addon: OCM Integration with MultiKueue"
#p ""
#p "This demo showcases how the Kueue-addon integrates Open Cluster Management (OCM)"
#p "with Kueue's MultiKueue capabilities to:"
#p ""
#p "  📦 Automate MultiKueue setup and kubeconfig management"
#p "  🎯 Centralizes queue resource management from a single hub"
#p "  📊 Enhances multicluster scheduling for more intelligent workload placement"
#p ""
#p "Three scenarios will be demonstrated:"
#p "  1. Basic MultiKueue Setup via Kueue-addon"
#p "  2. Label-Based Workload Scheduling"
#p "  3. Dynamic Score-Based Scheduling"
#p ""

########################
# Prerequisites Check
########################

p "${YELLOW}Prerequisites: Verifying OCM and Kueue Installation"
p ""
p "First, let's verify that OCM is running with managed clusters."
pe "kubectl get managedclusters"

p ""
p "Check that the Kueue-addon is installed on managed clusters."
pe "kubectl get managedclusteraddon -A | grep kueue"

p ""
p "Verify Kueue is running on the hub cluster (Same for managed clusters)."
pe "kubectl get pods -n kueue-system"

p ""
p "OCM auto-generates kubeconfig secrets for MultiKueue to use."
pe "kubectl get secret -n kueue-system | grep multikueue"

p ""
p "The kueue-addon automatically creates MultiKueueCluster for all managed clusters."
pe "kubectl get multikueuecluster"
p ""

########################
# Demo 1: Basic MultiKueue Setup
########################

clear
p "Demo 1: Simplified MultiKueue Setup via Kueue-addon"
p ""
p "The Kueue-addon dramatically simplifies MultiKueue setup by:"
p "  • Automatically generating kubeconfig secrets for managed clusters"
p "  • Creating MultiKueueCluster resources via OCM integration"
p "  • Using default placement to connect to all available clusters"
p ""

p "Let's apply the basic MultiKueue configuration:"
pe "cat ./multikueue-setup-demo1.yaml"
pe "kubectl apply -f ./multikueue-setup-demo1.yaml"

p ""
p "Verify the MultiKueue environment is properly configured:"
pe "kubectl get multikueueconfig -ojson | jq '.items[] | .metadata.name, .spec.clusters'"
pe "kubectl get admissionchecks -ojson | jq '.items[] | .metadata.name, .status.conditions'"
pe "kubectl get clusterqueues -ojson | jq '.items[] | .metadata.name, .status.conditions'"

p ""
p "Submit a basic workload to test the MultiKueue setup:"
pe "cat ./job-demo1.yaml"
pe "kubectl create -f ./job-demo1.yaml"

p ""
p "Check workload distribution across managed clusters:"
pe "kubectl get workload --context kind-cluster1"
pe "kubectl get workload --context kind-cluster2"
pe "kubectl get workload --context kind-cluster3"

p ""
p "${CYAN}Demo 1 Complete: Basic MultiKueue setup successfully distributes workloads!"
p ""

# Cleanup Demo 1
kubectl delete -f ./multikueue-setup-demo1.yaml >/dev/null 2>&1
sleep 2

########################
# Demo 2: Label-Based Workload Scheduling
########################

clear
p "Demo 2: Label-Based Workload Scheduling with OCM Placement"
p ""
p "Now we'll demonstrate advanced scheduling using OCM Placement to:"
p "  • Select clusters with specific GPU capabilities"
p "  • Route GPU workloads only to appropriate hardware"
p "  • Leverage OCM's cluster labeling and selection"
p ""

p "Check which clusters have GPU resources (nvidia-tesla-t4):"
pe "kubectl get managedclusters --show-labels | grep accelerator"
pe "kubectl get managedcluster -ojson | jq '.items[] | {name: .metadata.name, gpu: .status.allocatable[\"nvidia.com/gpu\"]}'"

p ""
p "Create a placement that selects only GPU-enabled clusters:"
pe "cat ./placement-demo2-1.yaml"
pe "kubectl apply -f ./placement-demo2-1.yaml"

p ""
p "Verify the placement decision:"
pe "kubectl get placementdecision -n kueue-system -ojson | jq '.items[] | .metadata.name, .status.decisions[].clusterName'"

p ""
p "Apply MultiKueue configuration that uses this GPU-focused placement:"
pe "cat ./multikueue-setup-demo2.yaml"
pe "kubectl apply -f ./multikueue-setup-demo2.yaml"

p ""
p "Verify the MultiKueue config now targets only GPU clusters:"
pe "kubectl get multikueueconfig -ojson | jq '.items[] | .metadata.name, .spec.clusters'"
pe "kubectl get admissionchecks -ojson | jq '.items[] | .metadata.name, .status.conditions'"

p ""
p "Submit a GPU workload that requires nvidia GPU resources:"
pe "cat ./job-demo2.yaml"
pe "kubectl create -f ./job-demo2.yaml"

p ""
p "Verify the GPU job is scheduled only on GPU-enabled clusters:"
pe "sleep 3"
pe "kubectl get workload --context kind-cluster1"
pe "kubectl get workload --context kind-cluster2"
pe "kubectl get workload --context kind-cluster3"

p ""
p "${CYAN}Demo 2 Complete: GPU workloads are intelligently routed to appropriate hardware!"
p ""

########################
# Demo 3: Dynamic Score-Based Scheduling
########################

clear  
p "Demo 3: Dynamic Score-Based Scheduling with AddonPlacementScore"
p ""
p "The final demo shows OCM's most advanced scheduling capability:"
p "  • Dynamic cluster scoring based on real-time resource availability"
p "  • Automatic placement updates as resource usage changes"
p "  • Intelligent workload routing to optimal clusters"
p ""

p "Check current AddonPlacementScore to see GPU resource availability across clusters:"
pe "kubectl get addonplacementscore -A -ojson | jq '.items[] | {cluster: .metadata.name, gpuScore: .status.scores[5]}'"

p ""
p "Update the placement to use dynamic scoring - select 1 cluster with highest GPU score:"
pe "cat ./placement-demo2-2.yaml"
pe "kubectl apply -f ./placement-demo2-2.yaml"

p ""
p "Observe how the placement decision changes based on resource scores:"
pe "kubectl get placementdecision -n kueue-system -ojson | jq '.items[] | .metadata.name, .status.decisions[].clusterName'"
pe "kubectl get multikueueconfig -ojson | jq '.items[] | .metadata.name, .spec.clusters'"

p ""
p "Submit another GPU workload to the dynamically-selected optimal cluster:"
pe "kubectl create -f ./job-demo2.yaml"

p ""
p "Verify the workload goes to the cluster with the best GPU availability:"
pe "sleep 3"
pe "kubectl get workload --context kind-cluster2"
pe "kubectl get workload --context kind-cluster3"

p ""
p "${CYAN}Demo 3 Complete: Workloads are dynamically placed on optimal clusters!"
p ""

########################
# Demo Summary
########################

clear
