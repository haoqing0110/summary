package main

import (
	"context"
	"flag"
	"fmt"
	"math/rand"
	"os"
	"strconv"
	"strings"
	"time"

	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
	"k8s.io/client-go/kubernetes"
	"k8s.io/client-go/rest"
	"k8s.io/client-go/tools/clientcmd"
	"k8s.io/klog/v2"
	clusterv1client "open-cluster-management.io/api/client/cluster/clientset/versioned"
	clusterapiv1alpha1 "open-cluster-management.io/api/cluster/v1alpha1"
)

var restConfig *rest.Config

var kubeClient kubernetes.Interface
var clusterClient clusterv1client.Interface

var clean bool
var resourceName string
var clusterNameStr string
var scoreStr string
var interval int

func init() {
	flag.BoolVar(&clean, "clean", false, "cluster name")

	flag.StringVar(&resourceName, "resource-name", "demo", "resource name")
	flag.StringVar(&clusterNameStr, "cluster-name", "", "cluster names")
	flag.StringVar(&scoreStr, "score", "", "cluster scores")
	flag.IntVar(&interval, "interval", 60, "update interval minutes")
}

func main() {
	flag.Parse()

	if err := initKubeRealEnv(); err != nil {
		fmt.Printf("Failed: %s \n", err)
	}

	// get cluster names
	clusterNames := getManagedClusterNames(clusterNameStr)

	// clean
	if clean {
		CleanClusterScores(clusterNames, resourceName)
		return
	}

	// create
	CreateClusterScores(clusterNames, resourceName)
	UpdateClusterScores(clusterNames, scoreStr, resourceName, interval)

	// update each interval
	ticker := time.NewTicker(time.Duration(interval) * time.Second)
	defer ticker.Stop()
	go func(t *time.Ticker) {
		for {
			<-t.C
			UpdateClusterScores(clusterNames, scoreStr, resourceName, interval)
		}
	}(ticker)

	time.Sleep(time.Duration(30) * time.Minute)
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

// create AddOnPlacementScores
func CreateClusterScores(clusterNames []string, resourceName string) {
	for _, c := range clusterNames {
		score := &clusterapiv1alpha1.AddOnPlacementScore{
			ObjectMeta: metav1.ObjectMeta{
				Namespace: c,
				Name:      resourceName,
			},
		}
		if _, err := clusterClient.ClusterV1alpha1().AddOnPlacementScores(c).Get(context.Background(), resourceName, metav1.GetOptions{}); err != nil {
			if _, err := clusterClient.ClusterV1alpha1().AddOnPlacementScores(c).Create(context.Background(), score, metav1.CreateOptions{}); err != nil {
				klog.Errorf("err: %s", err)
			} else {
				klog.Infof("created: %s in namespace %s", resourceName, c)
			}
		}
	}
}

// clean AddOnPlacementScores
func UpdateClusterScores(clusterNames []string, scoreStr, resourceName string, interval int) {
	// get cluster names
	scoreStrs := strings.Split(scoreStr, ",")

	// update scores periodically
	for i, c := range clusterNames {
		addOnPlacementScore, err := clusterClient.ClusterV1alpha1().AddOnPlacementScores(c).Get(context.Background(), resourceName, metav1.GetOptions{})
		if err != nil {
			klog.Errorf("err: %s", err)
		}

		if len(clusterNames) == len(scoreStrs) {
			intVar, _ := strconv.Atoi(scoreStrs[i])

			addOnPlacementScore.Status = clusterapiv1alpha1.AddOnPlacementScoreStatus{
				Conditions: []metav1.Condition{
					{
						Type:               "AddOnPlacementScoresUpdated",
						Status:             "True",
						Reason:             "AddOnPlacementScoresUpdated",
						Message:            "AddOnPlacementScores updated successfully",
						LastTransitionTime: metav1.NewTime(time.Now()),
					},
				},
				Scores: []clusterapiv1alpha1.AddOnPlacementScoreItem{
					{
						Name:  "customized",
						Value: int32(intVar),
					},
				},
				ValidUntil: &metav1.Time{Time: time.Now().Add(time.Duration(interval) * time.Minute)},
			}

		} else {
			addOnPlacementScore.Status = clusterapiv1alpha1.AddOnPlacementScoreStatus{
				Conditions: []metav1.Condition{
					{
						Type:               "AddOnPlacementScoresUpdated",
						Status:             "True",
						Reason:             "AddOnPlacementScoresUpdated",
						Message:            "AddOnPlacementScores updated successfully",
						LastTransitionTime: metav1.NewTime(time.Now()),
					},
				},
				Scores: []clusterapiv1alpha1.AddOnPlacementScoreItem{
					{
						Name:  "cpuratio",
						Value: int32(rand.Intn(100)),
					},
					{
						Name:  "memoryratio",
						Value: int32(rand.Intn(100)),
					},
				},
				ValidUntil: &metav1.Time{Time: time.Now().Add(time.Duration(interval) * time.Minute)},
			}
		}

		if _, err := clusterClient.ClusterV1alpha1().AddOnPlacementScores(c).UpdateStatus(context.Background(), addOnPlacementScore, metav1.UpdateOptions{}); err != nil {
			klog.Errorf("err: %s", err)
		} else {
			klog.Infof("updated: %s in namespace %s", resourceName, c)
		}
	}
}

// clean AddOnPlacementScores
func CleanClusterScores(clusterNames []string, resourceName string) {
	for _, c := range clusterNames {
		if err := clusterClient.ClusterV1alpha1().AddOnPlacementScores(c).Delete(context.Background(), resourceName, metav1.DeleteOptions{}); err != nil {
			klog.Errorf("err: %s", err)
		}
	}
}

func getManagedClusterNames(clustername string) []string {
	names := []string{}

	if len(clustername) > 0 {
		for _, c := range strings.Split(clustername, ",") {
			names = append(names, strings.Trim(c, " "))
		}
		return names
	}

	managedClusters, err := clusterClient.ClusterV1().ManagedClusters().List(context.Background(), metav1.ListOptions{})
	if err != nil {
		klog.Errorf("err: %s", err)
	}

	for _, c := range managedClusters.Items {
		names = append(names, c.Name)
	}

	return names
}
