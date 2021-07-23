#!/bin/bash

###################################################################################
#
# Usage Example: ./upgrade-release.sh clusterlifecycle-state-metrics 2.4 2.5
#
###################################################################################

# REPO and VERSION
REPO=$1
OLD_VERSION=$2
NEW_VERSION=$3
REG_OLD_VERSION=${OLD_VERSION/\./\\\\\\\.}
REG_NEW_VERSION=${NEW_VERSION/\./\\\\\\\.}

# upgrade config
cd /root/go/src/github.com/openshift/release/ci-operator/config/open-cluster-management/${REPO}
cp open-cluster-management-${REPO}-release-${OLD_VERSION}.yaml open-cluster-management-${REPO}-release-${NEW_VERSION}.yaml
sed -i "s/${OLD_VERSION}/${NEW_VERSION}/g" open-cluster-management-${REPO}-main.yaml
sed -i "s/${OLD_VERSION}/${NEW_VERSION}/g" open-cluster-management-${REPO}-release-${NEW_VERSION}.yaml
sed -i '/disabled: true/d' open-cluster-management-${REPO}-release-${OLD_VERSION}.yaml

# upgrade job
cd /root/go/src/github.com/openshift/release/ci-operator/jobs/open-cluster-management/${REPO}
cp open-cluster-management-${REPO}-release-${OLD_VERSION}-postsubmits.yaml open-cluster-management-${REPO}-release-${NEW_VERSION}-postsubmits.yaml
cp open-cluster-management-${REPO}-release-${OLD_VERSION}-presubmits.yaml open-cluster-management-${REPO}-release-${NEW_VERSION}-presubmits.yaml
sed -i "s/${OLD_VERSION}/${NEW_VERSION}/g" open-cluster-management-${REPO}-main-postsubmits.yaml
sed -i "s/${OLD_VERSION}/${NEW_VERSION}/g" open-cluster-management-${REPO}-release-${NEW_VERSION}-postsubmits.yaml
sed -i "s/${REG_OLD_VERSION}/${REG_NEW_VERSION}/g" open-cluster-management-${REPO}-release-${NEW_VERSION}-postsubmits.yaml
sed -i "s/${OLD_VERSION}/${NEW_VERSION}/g" open-cluster-management-${REPO}-release-${NEW_VERSION}-presubmits.yaml
