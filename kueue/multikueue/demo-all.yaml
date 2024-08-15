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
DEMO_PROMPT="${GREEN}➜ ${CYAN}\W "

# text color
# DEMO_CMD_COLOR=$BLACK

# clean env
kubectl delete -f ./
clusteradm clusterset unbind spoke --namespace kueue-system
kubectl delete multikueueconfig placement-demo2
kubectl delete multikueuecluster placement-demo2-cluster2 placement-demo2-cluster3
kubectl delete pod --context kind-cluster2 $(kubectl get pods | awk '{print $1}' --context kind-cluster2)
kubectl delete pod --context kind-cluster3 $(kubectl get pods | awk '{print $1}' --context kind-cluster3)
clear 

p "Demo1: Bridge the OCM and Kueue clusters via ClusterProfile."
p "OCM is installed with 1 hub cluster and 3 managed clusters."
pe "kubectl get mcl"

p "Kueue is also installed on these clusters."
pe "kubectl get pods -n kueue-system --context kind-hub"
pe "kubectl get pods -n kueue-system --context kind-cluster1"
p "cluster2 and cluster3 are the same, skip checking."

p "With ClusterProfile supported in OCM, these managed clusters are also registered as clusterprofiles."
pe "kubectl get clusterprofile -A"
pe "kubectl get clusterprofile -n open-cluster-management cluster1 -oyaml"

p "With Kueue supported in OCM, the clusterprofile status contains the credential to be consumed by Kueue."
pe "kubectl get clusterprofile -A -ojson | jq '.items[] | .metadata.name, .status.credentials[]'"
pe "kubectl get secret -n kueue-system"

p "MultiKueue can be easily set up with the help of the ClusterProfile API."
p "vim ./multikueue-setup-demo1.yaml"
pe "kubectl apply -f ./multikueue-setup-demo1.yaml"
pe "kubectl get multikueuecluster -A -ojson | jq '.items[] | .metadata.name, .status.conditions'"
pe "kubectl get admissionchecks -ojson | jq '.items[] | .metadata.name, .status.conditions'"
pe "kubectl get clusterqueues -ojson | jq '.items[] | .metadata.name, .status.conditions'"

p "Create a job to the MultiKueue."
pe "cat ./job-demo1.yaml"
pe "kubectl create -f ./job-demo1.yaml"
p "Check the workload on the managed clusters."
pe "kubectl get workload --context kind-cluster1"
pe "kubectl get workload --context kind-cluster2"
pe ""

kubectl delete -f multikueue-setup-demo1.yaml >/dev/null 2>&1
clear 

p "Demo2: Leverage OCM's advanced scheduling features with MultiKueue to intelligently place AI/ML jobs across clusters."

p "OCM implement an admissioncheck controller to automate the MultiKueue setup process, MultiKueueConfigs and MultiKueueClusters
are generated dynamically based on OCM placement decisions."

p "Demo2-1: Set MultiKueue for clusters with GPU type nvidia-tesla-t4."
p "vim ./multikueue-setup-demo2.yaml"
pe "cat ./placement-demo2-1.yaml"

pe "clusteradm clusterset bind spoke --namespace kueue-system"
pe "clusteradm get clustersets"
pe "kubectl apply -f ./placement-demo2-1.yaml"
pe "clusteradm get placements -otable"
p "Check the managed cluster labels, only cluster2 and cluster3 have nvidia-tesla-t4 label."
pe "kubectl get mcl --show-labels"

pe "kubectl apply -f ./multikueue-setup-demo2.yaml"
pe "kubectl get multikueueconfig"
pe "kubectl get multikueueconfig -oyaml"
pe "kubectl get multikueuecluster"
pe "kubectl get multikueuecluster -A -ojson | jq '.items[] | .metadata.name, .status.conditions'"
pe "kubectl get admissionchecks -ojson | jq '.items[] | .metadata.name, .status.conditions'"
pe "kubectl get clusterqueues -ojson | jq '.items[] | .metadata.name, .status.conditions'"

p "Create a job to the MultiKueue."
pe "cat ./job-demo2.yaml"
pe "kubectl create -f ./job-demo2.yaml"
p "Check the workload on the managed clusters."
pe "kubectl get workload --context kind-cluster2"
pe "kubectl get workload --context kind-cluster3"
pe ""

clear 

p "Demo2-2: Set MultiKueue dynamically based on cluster avaliable GPU."

p "More advanced multicluster scheduling features can bring to MultiKueue."
p "For example, with OCM resource usage collect addon installed, it scores clusters based on available GPU resource. With the resource changes, the selected clusters change."
p "With the change, MultiKueue can be set up dynamically to smart place AI/ML jobs to the clusters with most available GPU resources."

p ""
p "First, how the resource usage collect addon works?"
p "The resource usage collect addon agent is already installed."
pe "kubectl get mca -A"
pe "kubectl get pods -n open-cluster-management-agent-addon --context kind-cluster1"
p "cluster2 and cluster3 are the same, skip checking."

p "The cluster with more avaliable GPU has a higher addonplacementscore, score range is -100 to 100."
p "In this env, cluster1 has no GPU, cluster2 and cluster3 has 3 GPUs."
pe "kubectl get mcl -ojson | jq '.items[] | .metadata.name, .status.allocatable, .status.capacity'"
p "One the clusters with GPU, there's one workload running."
pe "kubectl get workload --context kind-cluster2"
pe "kubectl get workload --context kind-cluster3"
p "Check the addonplacementscore can see, cluster1 without GPU has score -100. For cluster2 and cluster3, the cluster with workload running has a lower score."
pe "kubectl get addonplacementscore -A -ojson | jq '.items[] | .metadata.name, .status.scores[2]'"

p "Update the existing placement in demo2-1 to select 1 cluster with most avaliable GPU."
pe "cat ./placement-demo2-2.yaml"
pe "kubectl apply -f ./placement-demo2-2.yaml"
pe "clusteradm get placements -otable"

kubectl patch admissioncheck placement-demo2 --type='json' -p='[{"op": "replace", "path": "/spec/retryDelayMinutes", "value": '"14"'}]' >/dev/null 2>&1

p "The placement decision changes, the MultiKueue update dynamically."
pe "kubectl get multikueueconfig placement-demo2 -ojson | jq '.spec'"

p "Create a job to the MultiKueue."
pe "cat ./job-demo2.yaml"
pe "kubectl create -f ./job-demo2.yaml"
p "Check the workload on the managed clusters."
pe "kubectl get workload --context kind-cluster2"
pe "kubectl get workload --context kind-cluster3"
pe ""
