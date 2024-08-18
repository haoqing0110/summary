#!/bin/bash
#Refer to https://github.com/songleo/songleo.github.io/blob/master/_posts/clusterpool-share.md
prefix=sf-prow-aws-ocp414-sno-us-east-1
#prefix=server-foundation-sno-lite
oc get ClusterClaim.hive.openshift.io

deploy_ns=$(oc describe -f $1 | grep Namespace | grep $prefix | awk '{print $2}')
kubeconfig_secret=$(oc get clusterdeployment -n ${deploy_ns} ${deploy_ns} -oyaml | grep adminKubeconfigSecretRef -A 1 | grep $prefix |  awk '{print $2}')
password_secret=$(oc get clusterdeployment -n ${deploy_ns} ${deploy_ns} -oyaml | grep adminPasswordSecretRef -A 1 | grep $prefix |  awk '{print $2}')

# get kubeconfig
oc get secret ${kubeconfig_secret} -n ${deploy_ns} -o 'go-template={{index .data "kubeconfig"}}' | base64 --decode > /tmp/kubeconfig
echo "kubeconfig stoted in /tmp/kubeconfig"
apiserver=$(oc --kubeconfig /tmp/kubeconfig cluster-info | grep 6443 | awk '{print $6}')

# get password
password=$(oc get secret ${password_secret} -n ${deploy_ns} -o yaml | grep password | head -n 1 | awk '{print $2}' | base64 -d)
username=$(oc get secret ${password_secret} -n ${deploy_ns} -o yaml | grep username | head -n 1 | awk '{print $2}' | base64 -d)
echo "oc login --username=$username --password=$password --server=$apiserver"
