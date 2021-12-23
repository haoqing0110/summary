package main

import (
	"net/http"
	_ "net/http/pprof"

	"context"
	"strconv"
	"unsafe"

	clusterclient "github.com/open-cluster-management/api/client/cluster/clientset/versioned"
	clusterinformers "github.com/open-cluster-management/api/client/cluster/informers/externalversions"
	mcv1 "github.com/open-cluster-management/api/cluster/v1"
	v1 "k8s.io/api/core/v1"
	"k8s.io/apimachinery/pkg/api/meta"
	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
	"k8s.io/apimachinery/pkg/apis/meta/v1/unstructured"
	"k8s.io/apimachinery/pkg/runtime"
	"k8s.io/apimachinery/pkg/runtime/schema"
	"k8s.io/client-go/dynamic"
	"k8s.io/client-go/dynamic/dynamicinformer"
	"k8s.io/client-go/rest"
	"k8s.io/client-go/tools/cache"
	"k8s.io/client-go/tools/clientcmd"
	"k8s.io/klog"
	"k8s.io/kube-state-metrics/pkg/metric"
	metricsstore "k8s.io/kube-state-metrics/pkg/metrics_store"
	koptions "k8s.io/kube-state-metrics/pkg/options"
	"k8s.io/kube-state-metrics/pkg/whiteblacklist"
)

var (
	descClusterInfoName          = "acm_managed_cluster_info"
	descClusterInfoHelp          = "Managed cluster information"
	descClusterInfoDefaultLabels = []string{"hub_cluster_id",
		"managed_cluster_id",
		"vendor",
		"cloud",
		"version",
		"available",
		"created_via",
		"core_worker",
		"socket_worker"}

	mcGVR = schema.GroupVersionResource{
		Group:    "cluster.open-cluster-management.io",
		Version:  "v1",
		Resource: "managedclusters",
	}

	restConfig *rest.Config
)

func init() {
	// local
	kubeconfig := "/root/.kube/config"
	restConfig, _ = clientcmd.BuildConfigFromFlags("", kubeconfig)

	// k8s
	// restConfig, _ = clientcmd.BuildConfigFromFlags("", "")
}

func main() {
	// CreateManagedClusterDynamicInformer()
	// CreateManagedClusterDynamicInformerWithUstructedStore()
	// CreateManagedClusterDynamicInformerWithStructedStore()
	CreateManagedClusterClusterInformer()

	http.ListenAndServe("0.0.0.0:6060", nil)
}

func CreateManagedClusterDynamicInformer() {
	// dynamic informer
	client := dynamic.NewForConfigOrDie(restConfig)

	sharedInformers := dynamicinformer.NewFilteredDynamicSharedInformerFactory(client, 0, v1.NamespaceAll, nil)
	informer := sharedInformers.ForResource(mcGVR)

	stopCh := make(chan struct{})
	go startWatchingManagedCluster(stopCh, informer.Informer())
}

func CreateManagedClusterDynamicInformerWithUstructedStore() {
	// dynamic informer
	client := dynamic.NewForConfigOrDie(restConfig)

	sharedInformers := dynamicinformer.NewFilteredDynamicSharedInformerFactory(client, 0, v1.NamespaceAll, nil)
	informer1 := sharedInformers.ForResource(mcGVR)

	stopCh := make(chan struct{})

	// store
	whiteBlackList, _ := whiteblacklist.New(koptions.MetricSet{}, koptions.MetricSet{})
	filteredMetricFamilies := metric.FilterMetricFamilies(whiteBlackList,
		getUnstructedManagedClusterInfoMetricFamilies(client))
	composedMetricGenFuncs := metric.ComposeMetricGenFuncs(filteredMetricFamilies)
	familyHeaders := metric.ExtractMetricFamilyHeaders(filteredMetricFamilies)
	store := metricsstore.NewMetricsStore(
		familyHeaders,
		composedMetricGenFuncs,
	)

	go startWatchingManagedClusterWithStore(stopCh, informer1.Informer(), store)
}

func CreateManagedClusterDynamicInformerWithStructedStore() {
	// dynamic informer
	client := dynamic.NewForConfigOrDie(restConfig)

	sharedInformers := dynamicinformer.NewFilteredDynamicSharedInformerFactory(client, 0, v1.NamespaceAll, nil)
	informer1 := sharedInformers.ForResource(mcGVR)

	stopCh := make(chan struct{})

	// cluster informer
	clusterclient, err := clusterclient.NewForConfig(restConfig)
	if err != nil {
		klog.Fatalf("cannot create clusterclient: %v", err)
	}
	// store
	whiteBlackList, _ := whiteblacklist.New(koptions.MetricSet{}, koptions.MetricSet{})
	filteredMetricFamilies := metric.FilterMetricFamilies(whiteBlackList,
		getStructedManagedClusterInfoMetricFamilies(clusterclient))
	composedMetricGenFuncs := metric.ComposeMetricGenFuncs(filteredMetricFamilies)
	familyHeaders := metric.ExtractMetricFamilyHeaders(filteredMetricFamilies)
	store := metricsstore.NewMetricsStore(
		familyHeaders,
		composedMetricGenFuncs,
	)

	go startWatchingManagedClusterWithStore(stopCh, informer1.Informer(), store)
}

func CreateManagedClusterClusterInformer() {
	// cluster informer
	clusterclient, err := clusterclient.NewForConfig(restConfig)
	if err != nil {
		klog.Fatalf("cannot create clusterclient: %v", err)
	}

	clusterinformers := clusterinformers.NewSharedInformerFactory(clusterclient, 0)
	informer1 := clusterinformers.Cluster().V1().ManagedClusters()

	stopCh := make(chan struct{})
	go startWatchingManagedCluster(stopCh, informer1.Informer())
}

func startWatchingManagedCluster(stopCh <-chan struct{}, s cache.SharedIndexInformer) {
	handlers := cache.ResourceEventHandlerFuncs{
		AddFunc: func(obj interface{}) {
			o, _ := meta.Accessor(obj)
			/*clusterclient, err := clusterclient.NewForConfig(restConfig)
			if err != nil {
				klog.Warningf("Add cluster client err: %s", err)
			}
			mc, err := clusterclient.ClusterV1().ManagedClusters().Get(context.Background(), o.GetName(), metav1.GetOptions{})
			if err != nil {
				klog.Warningf("Add Get err: %s", err)
			}

			mc.Spec.HubAcceptsClient = !mc.Spec.HubAcceptsClient
			clusterclient.ClusterV1().ManagedClusters().Update(context.Background(), mc, metav1.UpdateOptions{})
			if err != nil {
				klog.Warningf("Add Update err: %s", err)
			} */

			klog.Warningf("Add %s", o.GetName())
		},
		UpdateFunc: func(oldObj, obj interface{}) {
			o, _ := meta.Accessor(obj)
			klog.Warningf("Update %s", o.GetName())
		},
		DeleteFunc: func(obj interface{}) {
			o, _ := meta.Accessor(obj)
			klog.Warningf("Delete %s", o.GetName())
		},
	}
	s.AddEventHandler(handlers)
	s.Run(stopCh)
}

func startWatchingManagedClusterWithStore(stopCh <-chan struct{}, s cache.SharedIndexInformer, store *metricsstore.MetricsStore) {
	handlers := cache.ResourceEventHandlerFuncs{
		AddFunc: func(obj interface{}) {
			store.Add(obj)
			o, _ := meta.Accessor(obj)
			klog.Warningf("Add %s", o.GetName())
		},
		UpdateFunc: func(oldObj, obj interface{}) {
			store.Update(obj)
			o, _ := meta.Accessor(obj)
			klog.Warningf("Update %s", o.GetName())
		},
		DeleteFunc: func(obj interface{}) {
			store.Delete(obj)
			o, _ := meta.Accessor(obj)
			klog.Warningf("Delete %s", o.GetName())
		},
	}
	s.AddEventHandler(handlers)
	s.Run(stopCh)
}

func getUnstructedManagedClusterInfoMetricFamilies(client dynamic.Interface) []metric.FamilyGenerator {
	return []metric.FamilyGenerator{
		{
			Name: descClusterInfoName,
			Type: metric.Gauge,
			Help: descClusterInfoHelp,
			GenerateFunc: wrapManagedClusterInfoFunc(func(obj *unstructured.Unstructured) metric.Family {
				klog.Infof("unstructured size %d", unsafe.Sizeof(obj))
				mcU, errMC := client.Resource(mcGVR).Get(context.TODO(), obj.GetName(), metav1.GetOptions{})
				if errMC != nil {
					klog.Errorf("Error: %v", errMC)
					return metric.Family{Metrics: []*metric.Metric{}}
				}
				//				klog.Infof("mcU: %v", mcU)
				mc := &mcv1.ManagedCluster{}
				err := runtime.DefaultUnstructuredConverter.FromUnstructured(mcU.UnstructuredContent(), &mc)
				if err != nil {
					klog.Errorf("Error: %v", err)
					return metric.Family{Metrics: []*metric.Metric{}}
				}

				available := string(metav1.ConditionUnknown)
				createdVia := "Other"
				clusterID := mc.ObjectMeta.UID
				version := "4.9.1"
				core_worker, socket_worker := int64(1), int64(2)
				hubClusterID := mc.ObjectMeta.UID

				labelsValues := []string{
					string(hubClusterID),
					string(clusterID),
					string("OpenShift"),
					string("AWS"),
					version,
					available,
					createdVia,
					strconv.FormatInt(core_worker, 10),
					strconv.FormatInt(socket_worker, 10),
				}

				f := metric.Family{Metrics: []*metric.Metric{
					{
						LabelKeys:   descClusterInfoDefaultLabels,
						LabelValues: labelsValues,
						Value:       1,
					},
				}}
				klog.Infof("Returning %v", string(f.ByteSlice()))
				return f
			}),
		},
	}
}

func getStructedManagedClusterInfoMetricFamilies(clusterclient *clusterclient.Clientset) []metric.FamilyGenerator {
	return []metric.FamilyGenerator{
		{
			Name: descClusterInfoName,
			Type: metric.Gauge,
			Help: descClusterInfoHelp,
			GenerateFunc: wrapManagedClusterInfoFunc(func(obj *unstructured.Unstructured) metric.Family {
				klog.Infof("structured size %d", unsafe.Sizeof(obj))
				mc, err := clusterclient.ClusterV1().ManagedClusters().Get(context.Background(), obj.GetName(), metav1.GetOptions{})
				if err != nil {
					klog.Errorf("Error: %v", err)
					return metric.Family{Metrics: []*metric.Metric{}}
				}

				available := string(metav1.ConditionUnknown)
				createdVia := "Other"
				clusterID := mc.ObjectMeta.UID
				version := "4.9.1"
				core_worker, socket_worker := int64(1), int64(2)
				hubClusterID := mc.ObjectMeta.UID

				labelsValues := []string{
					string(hubClusterID),
					string(clusterID),
					string("OpenShift"),
					string("AWS"),
					version,
					available,
					createdVia,
					strconv.FormatInt(core_worker, 10),
					strconv.FormatInt(socket_worker, 10),
				}

				f := metric.Family{Metrics: []*metric.Metric{
					{
						LabelKeys:   descClusterInfoDefaultLabels,
						LabelValues: labelsValues,
						Value:       1,
					},
				}}
				klog.Infof("Returning %v", string(f.ByteSlice()))
				return f
			}),
		},
	}
}

func wrapManagedClusterInfoFunc(f func(obj *unstructured.Unstructured) metric.Family) func(interface{}) *metric.Family {
	return func(obj interface{}) *metric.Family {
		Cluster := obj.(*unstructured.Unstructured)

		metricFamily := f(Cluster)

		for _, m := range metricFamily.Metrics {
			m.LabelKeys = append([]string{}, m.LabelKeys...)
			m.LabelValues = append([]string{}, m.LabelValues...)
		}

		return &metricFamily
	}
}
