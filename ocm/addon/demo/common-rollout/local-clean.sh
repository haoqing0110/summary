#!/bin/bash

cd $(dirname ${BASH_SOURCE})

set -e

hub=${CLUSTER1:-hub}
c1=${CLUSTER1:-cluster1}
c2=${CLUSTER2:-cluster2}
c3=${CLUSTER3:-cluster3}

kind delete cluster --name "${hub}"
kind delete cluster --name "${c1}"
kind delete cluster --name "${c2}"
kind delete cluster --name "${c3}"
