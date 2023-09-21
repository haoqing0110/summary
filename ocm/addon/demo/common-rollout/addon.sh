#!/usr/bin/env bash

cd /root/go/src/open-cluster-management.io/managed-serviceaccount
helm uninstall -n open-cluster-management-addon managed-serviceaccount
helm install \
   -n open-cluster-management-addon --create-namespace \
   managed-serviceaccount charts/managed-serviceaccount/ \
   --set tag=latest \
   --set featureGates.ephemeralIdentity=true \
   --set enableAddOnDeploymentConfig=true \
   --set hubDeployMode=AddOnTemplate
cd -
