
#!/bin/bash

FILES="v1beta1-default.yaml
v1beta2-default.yaml
v1beta1-default-binding.yaml
v1beta2-default-binding.yaml
"

for f in $FILES
do
    echo "$ cat $f"
    cat $f
    echo "$ oc create -f $f"
    oc create -f $f
done

echo "$ kubectl get mclset"
oc get mclset

echo "$ kubectl get mclset default-v1 -oyaml | kubectl neat"
kubectl get mclset default-v1 -oyaml | kubectl neat
echo "$ kubectl get mclset default-v2 -oyaml | kubectl neat"
kubectl get mclset default-v2 -oyaml | kubectl neat

echo "$ kubectl get mclsetbinding"
oc get mclsetbinding

echo "$ kubectl get mclsetbinding default-v1 -oyaml | kubectl neat"
kubectl get mclsetbinding default-v1 -oyaml | kubectl neat
echo "$ kubectl get mclsetbinding default-v2 -oyaml | kubectl neat"
kubectl get mclsetbinding default-v2 -oyaml | kubectl neat

oc get managedclusterset.v1beta1.cluster.open-cluster-management.io default-v1 -oyaml | kubectl neat
oc get managedclusterset.v1beta1.cluster.open-cluster-management.io default-v2 -oyaml | kubectl neat
oc get managedclusterset.v1beta2.cluster.open-cluster-management.io default-v1 -oyaml | kubectl neat
oc get managedclusterset.v1beta2.cluster.open-cluster-management.io default-v2 -oyaml | kubectl neat
oc get managedclustersetbinding.v1beta1.cluster.open-cluster-management.io global-v1  -oyaml | kubectl neat
oc get managedclustersetbinding.v1beta1.cluster.open-cluster-management.io global-v2  -oyaml | kubectl neat
oc get managedclustersetbinding.v1beta2.cluster.open-cluster-management.io global-v1  -oyaml | kubectl neat
oc get managedclustersetbinding.v1beta2.cluster.open-cluster-management.io global-v2  -oyaml | kubectl neat



