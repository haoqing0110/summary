package main

import (
	"context"
	"flag"
	"fmt"
	"os"
	"strings"

	corev1 "k8s.io/api/core/v1"
	"k8s.io/apimachinery/pkg/api/resource"
	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
	"k8s.io/client-go/kubernetes"
	"k8s.io/client-go/rest"
	"k8s.io/client-go/tools/clientcmd"
	clusterv1client "open-cluster-management.io/api/client/cluster/clientset/versioned"
	clusterapiv1 "open-cluster-management.io/api/cluster/v1"
	clusterapiv1alpha1 "open-cluster-management.io/api/cluster/v1alpha1"
)

const (
	clusterSetLabel = "cluster.open-cluster-management.io/clusterset"
	placementLabel  = "cluster.open-cluster-management.io/placement"
)

var restConfig *rest.Config

var kubeClient kubernetes.Interface
var clusterClient clusterv1client.Interface

var namespace string
var cluster string
var rs string
var create, update bool

func init() {
	flag.BoolVar(&create, "create", false, "cluster name")
	flag.BoolVar(&update, "update", false, "cluster name")

	flag.StringVar(&namespace, "n", "", "namespace")
	flag.StringVar(&cluster, "c", "", "cluster name")
	flag.StringVar(&rs, "r", "10,10,100,100", "cluster name")
}

func main() {
	flag.Parse()

	if err := initKubeRealEnv(); err != nil {
		fmt.Printf("Failed: %s \n", err)
	}

	if create && len(namespace) > 0 && len(cluster) > 0 {
		if err := CreateNamespace(namespace); err != nil {
			fmt.Printf("%s \n", err)
		}
		if err := CreateClusterSetBinding(namespace, namespace); err != nil {
			fmt.Printf("%s \n", err)
		}
		if err := CreateCluster(cluster, namespace); err != nil {
			fmt.Printf("%s \n", err)
		}

	}

	if update && len(cluster) > 0 && len(rs) > 0 {
		r := strings.Split(rs, ",")
		if err := UpdateClusterWithResources(r, cluster); err != nil {
			fmt.Printf("%s \n", err)
		}
	}
}

func initKubeRealEnv() error {
	var err error
	kubeconfig := os.Getenv("KUBECONFIG")

	// setup kubeclient and clusterclient
	if restConfig, err = clientcmd.BuildConfigFromFlags("", kubeconfig); err != nil {
		return err
	}
	if kubeClient, err = kubernetes.NewForConfig(restConfig); err != nil {
		return err
	}
	if clusterClient, err = clusterv1client.NewForConfig(restConfig); err != nil {
		return err
	}
	return err
}

func CreateNamespace(namespace string) error {
	ns := &corev1.Namespace{
		ObjectMeta: metav1.ObjectMeta{
			Name: namespace,
		},
	}
	if _, err := kubeClient.CoreV1().Namespaces().Create(context.Background(), ns, metav1.CreateOptions{}); err != nil {
		return err
	}
	fmt.Printf("Namespace %s created \n", namespace)
	return nil
}

func CreateClusterSetBinding(clusterSetName, namespace string) error {
	clusterset := &clusterapiv1alpha1.ManagedClusterSet{
		ObjectMeta: metav1.ObjectMeta{
			Name: clusterSetName,
		},
	}
	if _, err := clusterClient.ClusterV1alpha1().ManagedClusterSets().Create(context.Background(), clusterset, metav1.CreateOptions{}); err != nil {
		fmt.Printf("ManagedClusterSets %s created failed: %s\n", clusterSetName, err)
	}
	fmt.Printf("ClusterSet %s created \n", clusterSetName)

	csb := &clusterapiv1alpha1.ManagedClusterSetBinding{
		ObjectMeta: metav1.ObjectMeta{
			Namespace: namespace,
			Name:      clusterSetName,
		},
		Spec: clusterapiv1alpha1.ManagedClusterSetBindingSpec{
			ClusterSet: clusterSetName,
		},
	}
	if _, err := clusterClient.ClusterV1alpha1().ManagedClusterSetBindings(namespace).Create(context.Background(), csb, metav1.CreateOptions{}); err != nil {
		fmt.Printf("ManagedClusterSetBindings %s created failed: %s\n", clusterSetName, err)
	}
	fmt.Printf("ClusterSetBinding %s created in namespace %s \n", clusterSetName, namespace)
	return nil
}

func CreateCluster(clusterName, clusterSetName string) error {
	cluster := &clusterapiv1.ManagedCluster{
		ObjectMeta: metav1.ObjectMeta{
			GenerateName: "cluster-",
			Labels: map[string]string{
				clusterSetLabel: clusterSetName,
			},
			Name: clusterName,
		},
	}
	if _, err := clusterClient.ClusterV1().ManagedClusters().Create(context.Background(), cluster, metav1.CreateOptions{}); err != nil {
		return err
	}

	fmt.Printf("Cluster %s created, belongs to ManagedClusterSet %s \n", clusterName, clusterSetName)
	return nil
}

func UpdateClusterWithResources(res []string, clusterName string) error {
	var err error
	var mc *clusterapiv1.ManagedCluster

	if mc, err = clusterClient.ClusterV1().ManagedClusters().Get(context.Background(), clusterName, metav1.GetOptions{}); err != nil {
		return err
	}

	allocatable := map[clusterapiv1.ResourceName]resource.Quantity{}
	capacity := map[clusterapiv1.ResourceName]resource.Quantity{}

	allocatable[clusterapiv1.ResourceCPU], err = resource.ParseQuantity(res[0])
	allocatable[clusterapiv1.ResourceMemory], err = resource.ParseQuantity(res[2])
	capacity[clusterapiv1.ResourceCPU], err = resource.ParseQuantity(res[1])
	capacity[clusterapiv1.ResourceMemory], err = resource.ParseQuantity(res[3])
	if len(res) >= 5 {
		capacity["core_worker"], err = resource.ParseQuantity(res[4])
	}
	if len(res) >= 6 {
		capacity["socket_worker"], err = resource.ParseQuantity(res[5])
	}

	mc.Status = clusterapiv1.ManagedClusterStatus{
		Allocatable: allocatable,
		Capacity:    capacity,
		Conditions:  []metav1.Condition{},
	}

	if _, err = clusterClient.ClusterV1().ManagedClusters().UpdateStatus(context.Background(), mc, metav1.UpdateOptions{}); err != nil {
		return err
	}

	fmt.Printf("Updated Cluster %s resources \n", clusterName)
	return nil
}
