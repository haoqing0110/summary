#!/bin/bash

# Copyright 2024 The Kubernetes Authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

set -o errexit
set -o nounset
set -o pipefail

KUBECONFIG_OUT=${1:-kubeconfig}
MULTIKUEUE_SA=multikueue-sa
NAMESPACE=kueue-system
SA_SECRET_NAME=${MULTIKUEUE_SA}
TARGET_CLUSTER=${1}

function wait_secret() {
  set +e
  for((i=0;i<30;i++));
  do
    kubectl -n $1 get secret $2
    if [ 0 -eq $? ]; then
      break
    fi
    echo "sleep 1 second to wait secret $1/$2 to exist: $i"
    sleep 1
  done
  set -e
}

kubectl apply -f managedserviceaccount.yaml --dry-run=client -o yaml | sed "s|TARGET_CLUSTER|${1}|g" | kubectl apply -f -
kubectl apply -f clusterpermission.yaml --dry-run=client -o yaml | sed "s|TARGET_CLUSTER|${1}|g" | kubectl apply -f -

wait_secret ${TARGET_CLUSTER} ${SA_SECRET_NAME}

# Note: service account token is stored base64-encoded in the secret but must
# be plaintext in kubeconfig.
SA_TOKEN=$(kubectl get -n ${TARGET_CLUSTER} secrets/${SA_SECRET_NAME} -o "jsonpath={.data['token']}" | base64 -d)
CA_CERT=$(kubectl get -n ${TARGET_CLUSTER} secrets/${SA_SECRET_NAME} -o "jsonpath={.data['ca\.crt']}")

# Extract cluster IP from the current context
TARGET_CLUSTER_ADDR=$(kubectl get mcl/${1} -o "jsonpath={.spec.managedClusterClientConfigs[0].url}")

# Create the Kubeconfig file
echo "Writing kubeconfig in ${TARGET_CLUSTER}"
cat > ${KUBECONFIG_OUT} <<EOF
apiVersion: v1
clusters:
- cluster:
    certificate-authority-data: ${CA_CERT}
    server: ${TARGET_CLUSTER_ADDR}
  name: ${TARGET_CLUSTER}
contexts:
- context:
    cluster: ${TARGET_CLUSTER}
    user: ${MULTIKUEUE_SA}
  name: ${TARGET_CLUSTER}
current-context: ${TARGET_CLUSTER}
kind: Config
preferences: {}
users:
- name: ${MULTIKUEUE_SA}
  user:
    token: ${SA_TOKEN}
EOF

kubectl delete secret ${1}-secret -n ${NAMESPACE} || true
kubectl create secret generic ${1}-secret -n ${NAMESPACE} --from-file=kubeconfig=${KUBECONFIG_OUT}