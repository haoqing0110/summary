## Steps
### Set up ocm environment

```bash
./local-up.sh
```
### Run the demo

```bash
./demo.sh
```

Press "Enter" to run the demo step by step. Expect output:

```bash
➜ balance-steady create 3 fake managed clusters, clusterset1, clusterset2
➜ balance-steady ./create-fake-mcl.sh 3
managedcluster.cluster.open-cluster-management.io/fakecluster1 created
managedcluster.cluster.open-cluster-management.io/fakecluster2 created
managedcluster.cluster.open-cluster-management.io/fakecluster3 created
➜ balance-steady clusteradm create clusterset clusterset1
Clusterset clusterset1 is created
➜ balance-steady clusteradm create clusterset clusterset2
Clusterset clusterset2 is created
➜ balance-steady clusteradm clusterset set clusterset1 --clusters fakecluster1,fakecluster2
Cluster fakecluster1 is set, from ClusterSet default to Clusterset clusterset1
Cluster fakecluster2 is set, from ClusterSet default to Clusterset clusterset1
➜ balance-steady clusteradm clusterset set clusterset2 --clusters fakecluster3
Cluster fakecluster3 is set, from ClusterSet default to Clusterset clusterset2
➜ balance-steady bind clusterset1 to default namespace
➜ balance-steady clusteradm clusterset bind clusterset1 --namespace default
Clusterset clusterset1 is bound to Namespace default
➜ balance-steady clusteradm get clustersets -otable
NAME          BOUND NAMESPACES   STATUS
clusterset1   default            2 ManagedClusters selected
clusterset2                      1 ManagedClusters selected
default                          No ManagedCluster selected
global                           3 ManagedClusters selected
➜ balance-steady clusteradm get clusters -otable
NAME           ACCEPTED   AVAILABLE   CLUSTERSET    CPU   MEMORY   KUBERNETES VERSION
fakecluster1   true                   clusterset1
fakecluster2   true                   clusterset1
fakecluster3   true                   clusterset2
```
```bash
➜ balance-steady create 3 placements, default has Steady and Balance prioritizers with weight 1
➜ balance-steady cat placement.yaml
#  clusteradm clusterset bind global --namespace default
apiVersion: cluster.open-cluster-management.io/v1beta1
kind: Placement
metadata:
  name: placementNUM
  namespace: default
spec:
  numberOfClusters: 1
# In this demo we create some faked managed clusters, to make them be selected by placement, add below toleratons.
  tolerations:
  - key: cluster.open-cluster-management.io/unreachable
    operator: Exists
  - key: cluster.open-cluster-management.io/unavailable
    operator: Exists
# prioritizerPolicy default mode is Additive mode with Steady and Balance prioritizers have the weight of 1.
# to increase the weight, can use Exact mode to define the prioritizers and weight explicitly.
#  prioritizerPolicy:
#    mode: Exact
#    configurations:
#      - scoreCoordinate:
#          builtIn: Balance
#        weight: 1
#      - scoreCoordinate:
#          builtIn: Steady
#        weight: 3
➜ balance-steady ./create-placement.sh placement.yaml 1
placement.cluster.open-cluster-management.io/placement1 created
➜ balance-steady ./create-placement.sh placement.yaml 2
placement.cluster.open-cluster-management.io/placement2 created
➜ balance-steady ./create-placement.sh placement.yaml 3
placement.cluster.open-cluster-management.io/placement3 created
➜ balance-steady clusteradm get placements -otable
NAME         STATUS   REASON              SELETEDCLUSTERS
placement1   False    Succeedconfigured   [fakecluster1]
placement2   False    Succeedconfigured   [fakecluster2]
placement3   False    Succeedconfigured   [fakecluster1]
➜ balance-steady bind clusterset2 to default namespace
➜ balance-steady clusteradm clusterset bind clusterset2 --namespace default
Clusterset clusterset2 is bound to Namespace default
➜ balance-steady clusteradm get placements -otable
NAME         STATUS   REASON              SELETEDCLUSTERS
placement1   False    Succeedconfigured   [fakecluster3]
placement2   False    Succeedconfigured   [fakecluster2]
placement3   False    Succeedconfigured   [fakecluster1]
➜ balance-steady placement decision changes when adding clusterset2
```
```bash
➜ balance-steady let's try to increase the Steady to weight 3
➜ balance-steady clean the placements and clusterset2 binding
➜ balance-steady clusteradm clusterset unbind clusterset2 --namespace default
Clusterset clusterset2 is unbind from namespace default
➜ balance-steady kubectl delete placement NAME
placement1
placement2
placement3
placement.cluster.open-cluster-management.io "placement1" deleted
placement.cluster.open-cluster-management.io "placement2" deleted
placement.cluster.open-cluster-management.io "placement3" deleted
Error from server (NotFound): placements.cluster.open-cluster-management.io "NAME" not found
➜ balance-steady create 3 placements, Steady with weight 3 and Balance with weight 1
➜ balance-steady cat placement2.yaml
#  clusteradm clusterset bind global --namespace default
apiVersion: cluster.open-cluster-management.io/v1beta1
kind: Placement
metadata:
  name: placementNUM
  namespace: default
spec:
  numberOfClusters: 1
# In this demo we create some faked managed clusters, to make them be selected by placement, add below toleratons.
  tolerations:
  - key: cluster.open-cluster-management.io/unreachable
    operator: Exists
  - key: cluster.open-cluster-management.io/unavailable
    operator: Exists
# prioritizerPolicy default mode is Additive mode with Steady and Balance prioritizers have the weight of 1.
# to increase the weight, can use Exact mode to define the prioritizers and weight explicitly.
  prioritizerPolicy:
    mode: Exact
    configurations:
      - scoreCoordinate:
          builtIn: Balance
        weight: 1
      - scoreCoordinate:
          builtIn: Steady
        weight: 3
➜ balance-steady ./create-placement.sh placement2.yaml 1
placement.cluster.open-cluster-management.io/placement1 created
➜ balance-steady ./create-placement.sh placement2.yaml 2
placement.cluster.open-cluster-management.io/placement2 created
➜ balance-steady ./create-placement.sh placement2.yaml 3
placement.cluster.open-cluster-management.io/placement3 created
➜ balance-steady clusteradm get placements -otable
NAME         STATUS   REASON              SELETEDCLUSTERS
placement1   False    Succeedconfigured   [fakecluster1]
placement2   False    Succeedconfigured   [fakecluster2]
placement3   False    Succeedconfigured   [fakecluster1]
➜ balance-steady bind clusterset2 to default namespace
➜ balance-steady clusteradm clusterset bind clusterset2 --namespace default
Clusterset clusterset2 is bound to Namespace default
➜ balance-steady clusteradm get placements -otable
NAME         STATUS   REASON              SELETEDCLUSTERS
placement1   False    Succeedconfigured   [fakecluster1]
placement2   False    Succeedconfigured   [fakecluster2]
placement3   False    Succeedconfigured   [fakecluster1]
➜ balance-steady placement decision keeps steady when adding clusterset2
➜ balance-steady create more placements
➜ balance-steady ./create-placement.sh placement2.yaml 4
placement.cluster.open-cluster-management.io/placement4 created
➜ balance-steady ./create-placement.sh placement2.yaml 5
placement.cluster.open-cluster-management.io/placement5 created
➜ balance-steady ./create-placement.sh placement2.yaml 6
placement.cluster.open-cluster-management.io/placement6 created
➜ balance-steady clusteradm get placements -otable
NAME         STATUS   REASON              SELETEDCLUSTERS
placement1   False    Succeedconfigured   [fakecluster1]
placement2   False    Succeedconfigured   [fakecluster2]
placement3   False    Succeedconfigured   [fakecluster1]
placement4   False    Succeedconfigured   [fakecluster3]
placement5   False    Succeedconfigured   [fakecluster2]
placement6   False    Succeedconfigured   [fakecluster3]
➜ balance-steady placement decision keeps balance and steady
```