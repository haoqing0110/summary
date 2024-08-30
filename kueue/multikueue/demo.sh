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
clusteradm clusterset bind spoke --namespace kueue-system
kubectl delete multikueueconfig placement-demo2
kubectl delete multikueuecluster placement-demo2-cluster2 placement-demo2-cluster3
kubectl delete job --context kind-hub $(kubectl get job --context kind-hub | awk '{print $1}')
kubectl delete job --context kind-cluster1 $(kubectl get job --context kind-cluster1 | awk '{print $1}')
kubectl delete job --context kind-cluster2 $(kubectl get job --context kind-cluster2 | awk '{print $1}')
kubectl delete job --context kind-cluster3 $(kubectl get job --context kind-cluster3 | awk '{print $1}')
kubectl delete pod --context kind-hub $(kubectl get pods --context kind-hub | awk '{print $1}')
kubectl delete pod --context kind-cluster1 $(kubectl get pods --context kind-cluster1 | awk '{print $1}')
kubectl delete pod --context kind-cluster2 $(kubectl get pods --context kind-cluster2 | awk '{print $1}')
kubectl delete pod --context kind-cluster3 $(kubectl get pods --context kind-cluster3 | awk '{print $1}')
clear 

p "Demo1: Bridge the OCM and Kueue clusters via ClusterProfile."
p "OCM is installed with 1 hub cluster and 3 managed clusters."
pe "kubectl get managedclusters"

p "Kueue is also installed on these clusters."
pe "kubectl get pods -n kueue-system --context kind-hub"
pe "kubectl get pods -n kueue-system --context kind-cluster1"
p "cluster2 and cluster3 are the same, skip checking."

p "With ClusterProfile supported in OCM, these managed clusters are also registered as clusterprofiles."
pe "kubectl get clusterprofile -A"
pe "kubectl get clusterprofile -n open-cluster-management cluster1 -oyaml"

p "The clusterprofile status contains the credential to be consumed by Kueue."
pe "kubectl get clusterprofile -A -ojson | jq '.items[] | .metadata.name, .status.credentials[]'"
pe "kubectl get secret -n kueue-system"

p "MultiKueue can be easily set up with the help of the ClusterProfile API."
pe "cat ./multikueue-setup-demo1.yaml | less"
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

p "Demo2-1: Deploy Kueue workloads (data analysis or AI/ML training jobs) on clusters with GPU type nvidia-tesla-t4."

p "OCM is installed with 1 hub cluster and 3 managed clusters."
pe "kubectl get managedclusters"

p "Kueue is also installed on these clusters."
pe "kubectl get pods -n kueue-system --context kind-hub"
pe "kubectl get pods -n kueue-system --context kind-cluster1"
p "cluster2 and cluster3 are the same, skip checking."

p "With ClusterProfile supported in OCM, these managed clusters are also registered as clusterprofiles."
pe "kubectl get clusterprofile -A"

p "The clusterprofile status contains the credential to be consumed by Kueue."
pe "kubectl get clusterprofile -A -ojson | jq '.items[] | .metadata.name, .status.credentials[]'"

p "Only cluster2 and cluster3 have 3 GPU with type nvidia-tesla-t4."
pe "kubectl get managedcluster --show-labels"
pe "kubectl get managedcluster -ojson |jq '.items[] |.metadata.name, .status.allocatable[\"nvidia.com/gpu\"]'"

p "Create placement to select clusters with GPU type nvidia-tesla-t4."
pe "cat ./placement-demo2-1.yaml"
pe "clusteradm clusterset bind spoke --namespace kueue-system"
pe "clusteradm get clustersets"
pe "kubectl apply -f ./placement-demo2-1.yaml"
pe "clusteradm get placements -otable"

p "Use this placement when creating Multikueue environment."
pe "cat ./multikueue-setup-demo2.yaml | less"
pe "kubectl apply -f ./multikueue-setup-demo2.yaml"
pe "kubectl get multikueueconfig"
pe "kubectl get multikueueconfig -oyaml"
pe "kubectl get multikueuecluster"
pe "kubectl get multikueuecluster -oyaml"
pe "kubectl get admissionchecks -ojson | jq '.items[] | .metadata.name, .status.conditions'"
pe "kubectl get clusterqueues -ojson | jq '.items[] | .metadata.name, .status.conditions'"

p "Create a job to this MultiKueue environment."
pe "cat ./job-demo2.yaml"
pe "kubectl create -f ./job-demo2.yaml"
p "Check the workload on the managed clusters."
pe "kubectl get workload --context kind-cluster2"
pe "kubectl get workload --context kind-cluster3"
pe ""

clear 

p "Demo2-2: Deploy Kueue workloads (data analysis or AI/ML training jobs) on clusters with most available GPU dynamically."

p "With the OCM Resource Usage Collect addon installed, clusters are scored based on their available GPU resources."
p "As GPU resource usage changes across clusters, the selected clusters update dynamically."
p "Additionally, MultiKueue can be configured to intelligently place AI/ML jobs on clusters with optimal GPU availability."

p ""
p "First, how does the resource usage collection addon work?"
p "The resource usage collect addon agent is already installed."
pe "kubectl get managedclusteraddon -A"
pe "kubectl get pods -n open-cluster-management-agent-addon --context kind-cluster1"
p "cluster2 and cluster3 are the same, skip checking."

p "The cluster with more avaliable GPU has a higher addonplacementscore, score range is -100 to 100."
p "One the clusters with GPU, there's one workload running."
pe "kubectl get workload --context kind-cluster2"
pe "kubectl get workload --context kind-cluster3"
p "Check the addonplacementscore can see, cluster1 without GPU has score -100. For cluster2 and cluster3, the cluster with workload running has a lower score."
pe "kubectl get addonplacementscore -A -ojson | jq '.items[] | .metadata.name, .status.scores[5]'"

p "Update the existing placement in demo2-1 to select 1 cluster with most avaliable GPU."
pe "cat ./placement-demo2-2.yaml"
pe "kubectl apply -f ./placement-demo2-2.yaml"
pe "clusteradm get placements -otable"

p "The placement decision changes, the MultiKueue update dynamically."
pe "kubectl get multikueueconfig placement-demo2 -ojson | jq '.spec'"

p "Create a job to the MultiKueue."
pe "cat ./job-demo2.yaml"
pe "kubectl create -f ./job-demo2.yaml"
p "Check the workload on the managed clusters."
pe "kubectl get workload --context kind-cluster2"
pe "kubectl get workload --context kind-cluster3"
pe ""
