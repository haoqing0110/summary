## Setup MultiKueue through OCM

### Prepare env

Prepare an environment with 1 hub + 3 managed clusters. Install OCM and Kueue on these clusters. To generate a kubeconf required by kueue to access the managed clusters, install the ocm managed-serviceaccount and cluster-permission as well.

Running `setup-env.sh` to complete the setup. After running the script, you could see below resources from the hub.

```bash
$ kubectl get mcl
NAME       HUB ACCEPTED   MANAGED CLUSTER URLS                  JOINED   AVAILABLE   AGE
cluster1   true           https://cluster1-control-plane:6443   True     True        129m
cluster2   true           https://cluster2-control-plane:6443   True     True        129m
cluster3   true           https://cluster3-control-plane:6443   True     True        129m

$ kubectl get placement
NAME              SUCCEEDED   REASON                  SELECTEDCLUSTERS
placement-spoke   True        AllDecisionsScheduled   2

$ kubectl get mca -A
NAMESPACE   NAME                     AVAILABLE   DEGRADED   PROGRESSING
cluster1    managed-serviceaccount   True                   False
cluster1    resource-usage-collect   True                   False
cluster2    managed-serviceaccount   True                   False
cluster2    resource-usage-collect   True                   False
cluster3    managed-serviceaccount   True                   False
cluster3    resource-usage-collect   True                   False

$ kubectl get manifestwork -A
NAMESPACE   NAME                                    AGE
cluster1    addon-managed-serviceaccount-deploy-0   129m
cluster1    addon-resource-usage-collect-deploy-0   129m
cluster1    single-clusterqueue                     129m
cluster2    addon-managed-serviceaccount-deploy-0   129m
cluster2    addon-resource-usage-collect-deploy-0   129m
cluster2    single-clusterqueue                     129m
cluster3    addon-managed-serviceaccount-deploy-0   129m
cluster3    addon-resource-usage-collect-deploy-0   129m
cluster3    single-clusterqueue                     129m


$ kubectl get clusterprofile -A
NAMESPACE                 NAME       AGE
open-cluster-management   cluster1   130m
open-cluster-management   cluster2   130m
open-cluster-management   cluster3   130m
```

And you could see a secret with kubeconf for the managed cluser created under kueue-system namespace.
```
$ kubectl get secret -n kueue-system
NAME                              TYPE     DATA   AGE
kueue-admin-cluster1-kubeconfig   Opaque   1      130m
kueue-admin-cluster2-kubeconfig   Opaque   1      130m
kueue-admin-cluster3-kubeconfig   Opaque   1      130m
kueue-webhook-server-cert         Opaque   4      132m
```

### Setup MultiKueue

Running `./demo.sh` to run the demo.

[![asciicast](https://asciinema.org/a/671090.svg)](https://asciinema.org/a/671090)

[![asciicast](https://asciinema.org/a/671253.svg)](https://asciinema.org/a/671253)

[![asciicast](https://asciinema.org/a/671254.svg)](https://asciinema.org/a/671254)

### References

[KEP-4322: Add credentials definitions](https://github.com/kubernetes/enhancements/pull/4778)

[ClusterInventory API local change](https://github.com/haoqing0110/cluster-inventory-api/tree/copy-yuchen/experimental)

[OCM clusterpermision](https://github.com/haoqing0110/cluster-permission/tree/br_client)

[OCM supports ClusterProfile and AdmissionCheck](https://github.com/open-cluster-management-io/ocm/compare/main...haoqing0110:OCM:br_clusterprofile-authtokenrequest-admissioncheck)

[OCM resource usage addon with GPU supported](https://github.com/open-cluster-management-io/addon-contrib/pull/20)