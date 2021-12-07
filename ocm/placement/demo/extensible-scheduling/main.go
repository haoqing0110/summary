package main

import (
	"flag"
	"fmt"

	clusterv1client "github.com/haoqing0110/api/client/cluster/clientset/versioned"

	"k8s.io/client-go/kubernetes"
	"k8s.io/client-go/rest"
)

var restConfig *rest.Config

var kubeClient kubernetes.Interface
var clusterClient clusterv1client.Interface

var scalar, duration int64

func init() {
	flag.Int64Var(&scalar, "scalar", 1, "scalar value")
	flag.Int64Var(&duration, "duration", 1, "duration")
}

func main() {
	flag.Parse()

	if err := initKubeRealEnv(); err != nil {
		fmt.Printf("Failed: %s \n", err)
	}

	if err := UpdateScalar(scalar, duration); err != nil {
		fmt.Printf("%s \n", err)
	}
}

func initKubeRealEnv() error {
	var err error
	//kubeconfig := os.Getenv("KUBECONFIG")

	// setup kubeclient and clusterclient
	/*if restConfig, err = clientcmd.BuildConfigFromFlags("", kubeconfig); err != nil {
		return err
	}
	if kubeClient, err = kubernetes.NewForConfig(restConfig); err != nil {
		return err
	}
	if clusterClient, err = clusterv1client.NewForConfig(restConfig); err != nil {
		return err
	}
	*/
	return err
}

func UpdateScalar(scalar, duration int64) error {
	/*	var err error
		var mc *clusterapiv1.ManagedCluster

		if mc, err = clusterClient.ClusterV1().ManagedClusters().Get(context.Background(), clusterName, metav1.GetOptions{}); err != nil {
			return err
		}

		mc.Status = clusterapiv1alpha1.M{
			Allocatable: allocatable,
			Capacity:    capacity,
			Conditions:  []metav1.Condition{},
		}

		if _, err = clusterClient.ClusterV1().ManagedClusters().UpdateStatus(context.Background(), mc, metav1.UpdateOptions{}); err != nil {
			return err
		}

		fmt.Printf("Updated Cluster %s resources \n", clusterName)
	*/
	return nil
}
