## Setup environment

### Create [GKE](https://console.cloud.google.com/)

Requires k8s 1.29.3+, reduce node to 1 and change machine type to e2-standard-2.

Access from Google Cloud Shell
```bash
gcloud container clusters get-credentials cluster-1 --zone us-central1-c --project gc-acm-dev
```

### Join GKE cluser to OCM
This is not a necessary step if you do not want GKE to be managed by OCM.

- Follow [Start the control plane](https://open-cluster-management.io/getting-started/installation/start-the-control-plane/) prepare hub cluster.
- Export ca.crt on the hub from `ConfigMap` `kube-root-ca.crt`.
- Follow [Register a cluster](https://open-cluster-management.io/getting-started/installation/register-a-cluster/) register the GKE to the hub.

```bash
clusteradm join \
    --hub-token <your token data> \
    --hub-apiserver <your hub cluster endpoint> \
    --wait \
    --cluster-name "gke" \ 
    --singleton \
    --ca-file=ca.crt \
    --context ${CTX_MANAGED_CLUSTER}
```

### [Create GPU Nodepool](https://cloud.google.com/kubernetes-engine/docs/how-to/provisioningrequest)

```bash
gcloud beta container node-pools create nvidia-t4s \
    --cluster=cluster-1 \
    --location=us-central1-c \
     --enable-queued-provisioning \
    --accelerator type=nvidia-tesla-t4,count=1,gpu-driver-version=latest \
    --enable-autoscaling  \
    --num-nodes=0   \
    --total-max-nodes 2  \
    --location-policy=ANY  \
    --reservation-affinity=none  \
    --no-enable-autorepair \
    --machine-type=n1-standard-4
```

### [Create Job with Kueue](https://cloud.google.com/kubernetes-engine/docs/how-to/provisioningrequest#for_jobs_with_kueue)

- Install Kueue on the GKE. This step can be done from OCM hub.

```bash
git clone https://github.com/GoogleCloudPlatform/ai-on-gke
cd ai-on-gke/tutorials-and-examples/workflow-orchestration/dws-examples
kubectl apply --server-side -f ./kueue-manifests.yaml
kubectl create -f ./dws-queues.yaml
```

- Create a job request GPU. This step can be done from OCM hub.

```bash
kubectl create -f ./job.yaml
```

- Check the result

```bash
$ kubectl get nodes
NAME                                       STATUS   ROLES    AGE   VERSION
gke-cluster-1-default-pool-36509703-88xd   Ready    <none>   10m   v1.29.3-gke.1282001
gke-cluster-1-nvidia-t4s-0512d537-mjzk     Ready    <none>   54s   v1.29.3-gke.1282001 // dynamic provisioned GPU node
$ kubectl get workload
NAME                   QUEUE             ADMITTED BY         AGE
job-sample-job-7f173   dws-local-queue   dws-cluster-queue   4m5s
$ kubectl get localqueue
NAME              CLUSTERQUEUE        PENDING WORKLOADS   ADMITTED WORKLOADS
dws-local-queue   dws-cluster-queue   0                   1
$ kubectl get clusterqueue
NAME                COHORT   PENDING WORKLOADS
dws-cluster-queue            0
$ kubectl get  provreq 
NAME                              ACCEPTED   PROVISIONED   FAILED   AGE
job-sample-job-7f173-dws-prov-1   True       True          False    4m18s
```

### Ref 
- [Dynamic Workload Scheduler and Kueue (Get High-Demand GPUs)](https://www.youtube.com/watch?v=Q60n3Hhrqas&t=340s)
- [Install kubectl and configure cluster access](https://cloud.google.com/kubernetes-engine/docs/how-to/cluster-access-for-kubectl#install_plugin)
- [Install GKE auth plugin for DEB/RPM based system](https://cloud.google.com/blog/products/containers-kubernetes/kubectl-auth-changes-in-gke)