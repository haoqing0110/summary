## Setup MultiKueue through OCM

### Prepare env

Prepare an environment with 1 hub + 2 managed clusters. Install OCM and Kueue on these clusters. To generate a kubeconf required by kueue to access the managed clusters,
install the ocm managed-serviceaccount and cluster-permission as well.

Running `setup-env.sh` to complete the setup. After running the script, you could see below resources from the hub.

```bash
$ kubectl get mcl
NAME            HUB ACCEPTED   MANAGED CLUSTER URLS                       JOINED   AVAILABLE   AGE
cluster1        true           https://cluster1-control-plane:6443        True     True        15m
cluster2        true           https://cluster2-control-plane:6443        True     True        14m
local-cluster   true           https://local-cluster-control-plane:6443   True     True        15m

$ kubectl get placement
NAME              SUCCEEDED   REASON                  SELECTEDCLUSTERS
placement-all     True        AllDecisionsScheduled   3
placement-spoke   True        AllDecisionsScheduled   2

$ kubectl get mca -A
NAMESPACE   NAME                     AVAILABLE   DEGRADED   PROGRESSING
cluster1    managed-serviceaccount   True                   False
cluster2    managed-serviceaccount   True                   False

$ kubectl get manifestwork -A
NAMESPACE       NAME                                    AGE
cluster1        addon-managed-serviceaccount-deploy-0   15m
cluster1        jobset-0.5.1                            15m
cluster1        kueue-0.7.1                             15m
cluster2        addon-managed-serviceaccount-deploy-0   15m
cluster2        jobset-0.5.1                            15m
cluster2        kueue-0.7.1                             15m
local-cluster   jobset-0.5.1                            15m
local-cluster   kueue-0.7.1                             15m

```

### Setup MultiKueue

Running `setup-multikueue.sh` to complete the setup. Or you can follow the below steps manually.

1. On the hub cluster, enable the multiqueue feature gates.

```bash
kubectl config use-context ${hubctx}

kubectl patch deployment kueue-controller-manager -n kueue-system --type='json' -p='[{"op": "replace", "path": "/spec/template/spec/containers/0/args", "value": ["--config=/controller_manager_config.yaml", "--zap-log-level=2", "--feature-gates=MultiKueue=true"]}]' --context ${hubctx}
```

2. Deploy queue resources to the managed clusters throught ocm manifestworkreplicaset.

```bash
kubectl apply -f single-clusterqueue-setup-mwrs.yaml
```

3. Request cluster permission and generate kubeconfigs for each managed cluster from hub.

```bash
cd authtokenrequest
./create-multikueue-kubeconfig-from-hub.sh ${c1}
./create-multikueue-kubeconfig-from-hub.sh ${c2}
cd -
```

After that, you could see a secret with kubeconf for the managed cluser created under kueue-system namespace.
```
$ kubectl get secret -n kueue-system
NAME                        TYPE     DATA   AGE
cluster1-secret             Opaque   1      22m
cluster2-secret             Opaque   1      22m
kueue-webhook-server-cert   Opaque   4      23m
```

4. On the hub cluster, create a sample multikueue.

```bash
kubectl apply -f multikueue-setup.yaml
```

Wait for about 60s and check the kueue status.
```bash
kubectl get clusterqueues cluster-queue -o jsonpath="{range .status.conditions[?(@.type == \"Active\")]}CQ - Active: {@.status} Reason: {@.reason} Message: {@.message}{'\n'}{end}"
kubectl get admissionchecks sample-multikueue -o jsonpath="{range .status.conditions[?(@.type == \"Active\")]}AC - Active: {@.status} Reason: {@.reason} Message: {@.message}{'\n'}{end}"
kubectl get multikueuecluster multikueue-test-worker1 -o jsonpath="{range .status.conditions[?(@.type == \"Active\")]}MC - Active: {@.status} Reason: {@.reason} Message: {@.message}{'\n'}{end}"
kubectl get multikueuecluster multikueue-test-worker2 -o jsonpath="{range .status.conditions[?(@.type == \"Active\")]}MC - Active: {@.status} Reason: {@.reason} Message: {@.message}{'\n'}{end}"
```

5. Deploy a job.

```bash
kubectl create -f job.yaml --context ${hubctx}
```

On the managed clusters, verify the job should be scheduled to one of them and get running.

```bash
kubectl get workload --context kind-cluster1 --watch
kubectl get workload --context kind-cluster2 --watch
```