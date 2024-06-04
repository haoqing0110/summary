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
➜ balance kubectl get managedclusters
No resources found
➜ balance ./create-fake-mcl.sh 10
managedcluster.cluster.open-cluster-management.io/fakecluster1 created
managedcluster.cluster.open-cluster-management.io/fakecluster2 created
managedcluster.cluster.open-cluster-management.io/fakecluster3 created
managedcluster.cluster.open-cluster-management.io/fakecluster4 created
managedcluster.cluster.open-cluster-management.io/fakecluster5 created
managedcluster.cluster.open-cluster-management.io/fakecluster6 created
managedcluster.cluster.open-cluster-management.io/fakecluster7 created
managedcluster.cluster.open-cluster-management.io/fakecluster8 created
managedcluster.cluster.open-cluster-management.io/fakecluster9 created
managedcluster.cluster.open-cluster-management.io/fakecluster10 created
➜ balance kubectl get managedclusters
NAME            HUB ACCEPTED   MANAGED CLUSTER URLS   JOINED   AVAILABLE   AGE
fakecluster1    true                                           Unknown     25s
fakecluster10   true                                           Unknown     14s
fakecluster2    true                                           Unknown     24s
fakecluster3    true                                           Unknown     23s
fakecluster4    true                                           Unknown     22s
fakecluster5    true                                           Unknown     20s
fakecluster6    true                                           Unknown     19s
fakecluster7    true                                           Unknown     18s
fakecluster8    true                                           Unknown     17s
fakecluster9    true                                           Unknown     16s
➜ balance clusteradm clusterset bind global --namespace default
Clusterset global is already bound to Namespace default
➜ balance clusteradm get placements -otable
➜ balance ./create-placement.sh 10
placement.cluster.open-cluster-management.io/placement1 created
placement.cluster.open-cluster-management.io/placement2 created
placement.cluster.open-cluster-management.io/placement3 created
placement.cluster.open-cluster-management.io/placement4 created
placement.cluster.open-cluster-management.io/placement5 created
placement.cluster.open-cluster-management.io/placement6 created
placement.cluster.open-cluster-management.io/placement7 created
placement.cluster.open-cluster-management.io/placement8 created
placement.cluster.open-cluster-management.io/placement9 created
placement.cluster.open-cluster-management.io/placement10 created
➜ balance clusteradm get placements -otable
NAME          STATUS   REASON              SELETEDCLUSTERS
placement1    False    Succeedconfigured   [fakecluster1]
placement10   False    Succeedconfigured   [fakecluster9]
placement2    False    Succeedconfigured   [fakecluster10]
placement3    False    Succeedconfigured   [fakecluster2]
placement4    False    Succeedconfigured   [fakecluster3]
placement5    False    Succeedconfigured   [fakecluster4]
placement6    False    Succeedconfigured   [fakecluster5]
placement7    False    Succeedconfigured   [fakecluster6]
placement8    False    Succeedconfigured   [fakecluster7]
placement9    False    Succeedconfigured   [fakecluster8]
```
