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

var update, clean bool
var interval int64
var clusters string
var scores string

func init() {
	flag.BoolVar(&clean, "clean", false, "cluster name")

	flag.StringVar(&clusters, "clusters", "", "cluster names")
	flag.StringVar(&scores, "scores", "", "cluster scores")
	flag.IntVar(&interval, "i", "", "update interval")
}

func main() {
	flag.Parse()

	if err := initKubeRealEnv(); err != nil {
		fmt.Printf("Failed: %s \n", err)
	}

	if clean {
		CleanClusterScores(clusters, interval)
		return
	}

	defer CleanClusterScores(clusters, interval)
	CreateAndUpdateClusterScores(clusters, scores, interval)

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

func CreateAndUpdateClusterScores(clusters, scores string, interval int64) {
	// create crs
	if managedclusters, err := clusterClient.ClusterV1alpha1().
		return err
	}

	// update scores periodically
}

func CleanClusterScores(clusters string, interval int64) {
	// clean crs
}
