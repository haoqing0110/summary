#!/usr/bin/env bash

hub=${CLUSTER1:-kind}
hubctx="kind-${hub}"

kind create cluster --name "${hub}"

kind load docker-image --name=kind quay.io/open-cluster-management/registration-operator:e2e
kind load docker-image --name=kind quay.io/open-cluster-management/registration:e2e
kind load docker-image --name=kind quay.io/open-cluster-management/work:e2e
kind load docker-image --name=kind quay.io/open-cluster-management/placement:e2e
kind load docker-image --name=kind quay.io/open-cluster-management/addon-manager:e2e

cd /root/go/src/open-cluster-management.io/ocm
IMAGE_TAG=e2e make deploy-hub
IMAGE_TAG=e2e make deploy-spoke-operator
cd -

cd /root/go/src/open-cluster-management.io/managed-serviceaccount
helm install \
   -n open-cluster-management-addon --create-namespace \
   managed-serviceaccount charts/managed-serviceaccount/ \
   --set tag=latest \
   --set featureGates.ephemeralIdentity=true \
   --set enableAddOnDeploymentConfig=true \
   --set hubDeployMode=AddOnTemplate
cd -
