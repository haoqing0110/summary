package main

import (
	"context"
	"flag"
	"fmt"
	"time"

	klog "k8s.io/klog/v2"

	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
	"k8s.io/client-go/tools/cache"
	"k8s.io/client-go/tools/clientcmd"
	clusterclient "open-cluster-management.io/api/client/cluster/clientset/versioned"
	workclient "open-cluster-management.io/api/client/work/clientset/versioned"
	workinformers "open-cluster-management.io/api/client/work/informers/externalversions"
	workinformer "open-cluster-management.io/api/client/work/informers/externalversions/work/v1"
	workapiv1 "open-cluster-management.io/api/work/v1"
)

// "cluster1-klusterlet",
var klusterletwork = "-klusterlet"

var addonworks = []string{
	//"addon-application-manager-deploy",
	//		"addon-cert-policy-controller-deploy",
	//		"addon-config-policy-controller-deploy",
	//		"addon-governance-policy-framework-deploy",
	//		"addon-iam-policy-controller-deploy",
	//		"addon-search-collector-deploy",
	"addon-work-manager-deploy",
}

type workGenRecorder struct {
	initGen      int64
	updateGen    genRecorder
	updateObsGen genRecorder
}

type genRecorder struct {
	gen        int64
	updateTime *time.Time
}

// WorkController record the generation and observedGeneration update time of
// manifestwork.
type WorkController struct {
	informerFactory workinformers.SharedInformerFactory
	workInformer    workinformer.ManifestWorkInformer
	workGenMap      map[string]*workGenRecorder
	updatedCount    int
}

// Run starts shared informers and waits for the shared informer cache to
// synchronize.
func (c *WorkController) Run(stopCh chan struct{}) error {
	// Starts all the shared informers that have been created by the factory so
	// far.
	c.informerFactory.Start(stopCh)
	// wait for the initial synchronization of the local cache.
	if !cache.WaitForCacheSync(stopCh, c.workInformer.Informer().HasSynced) {
		return fmt.Errorf("Failed to sync")
	}
	return nil
}

func (c *WorkController) workAdd(obj interface{}) {
	work := obj.(*workapiv1.ManifestWork)
	namespace := work.GetNamespace()
	name := work.GetName()
	// check conditions
	appliedIdx := -1
	for i, c := range work.Status.Conditions {
		if c.Type == workapiv1.WorkApplied {
			appliedIdx = i
		}
	}
	if appliedIdx < 0 {
		klog.Errorf("%s/%s condition is not ready", namespace, name)
		return
	}

	// init generation
	if i, ok := c.workGenMap[namespace+"/"+name]; ok {
		gen := work.GetGeneration()
		obsgen := work.Status.Conditions[appliedIdx].ObservedGeneration
		klog.Infof("WORK CREATED: %s/%s gen=%s, obsgen=%s", namespace, name, gen, obsgen)

		i.initGen = gen
	}
}

func (c *WorkController) workUpdate(old, new interface{}) {
	//oldWork := old.(*workapiv1.ManifestWork)
	newWork := new.(*workapiv1.ManifestWork)
	namespace := newWork.GetNamespace()
	name := newWork.GetName()
	// check conditions
	appliedIdx := -1
	for i, c := range newWork.Status.Conditions {
		if c.Type == workapiv1.WorkApplied {
			appliedIdx = i
		}
	}
	if appliedIdx < 0 {
		klog.Errorf("%s/%s condition is not ready", namespace, name)
		return
	}

	// watch and update gen updated time
	if i, ok := c.workGenMap[namespace+"/"+name]; ok {
		newgen := newWork.GetGeneration()
		newobsgen := newWork.Status.Conditions[appliedIdx].ObservedGeneration
		klog.Infof("WORK UPDATED: %s/%s gen=%s, obsgen=%s", namespace, name, newgen, newobsgen)

		if newgen != i.initGen && newgen != i.updateGen.gen {
			t := time.Now()
			i.updateGen.gen = newgen
			i.updateGen.updateTime = &t
		}
		if newobsgen == i.updateGen.gen && i.updateObsGen.updateTime == nil {
			t := time.Now()
			i.updateObsGen.gen = newobsgen
			i.updateObsGen.updateTime = &t
			c.updatedCount += 1
		}
	}

	if c.updatedCount == len(c.workGenMap) {
		c.print()
	}
}

func (c *WorkController) workDelete(obj interface{}) {
	work := obj.(*workapiv1.ManifestWork)
	klog.Infof("WORK DELETED: %s/%s", work.Namespace, work.Name)
}

func (c *WorkController) print() {
	var minStart, maxEnd *time.Time
	klog.Infof("namespace/work\tgeneration\tobservedGeneration\tgtime\tobstime\n")
	for k, v := range c.workGenMap {
		klog.Infof("%s\t%v\t%v\t%v\t%v\n", k, v.updateGen.gen, v.updateObsGen.gen, v.updateGen.updateTime.Format(time.UnixDate), v.updateObsGen.updateTime.Format(time.UnixDate))
		if minStart == nil || minStart.After(*v.updateGen.updateTime) {
			minStart = v.updateGen.updateTime
		}
		if maxEnd == nil || maxEnd.Before(*v.updateObsGen.updateTime) {
			maxEnd = v.updateObsGen.updateTime
		}
	}
	klog.Infof("start: %v\n", minStart.Format(time.UnixDate))
	klog.Infof("end: %v\n", maxEnd.Format(time.UnixDate))
}

// NewWorkController creates a WorkController
func NewWorkController(informerFactory workinformers.SharedInformerFactory, workGenMap map[string]*workGenRecorder) *WorkController {
	workInformer := informerFactory.Work().V1().ManifestWorks()

	c := &WorkController{
		informerFactory: informerFactory,
		workInformer:    workInformer,
		workGenMap:      workGenMap,
	}
	workInformer.Informer().AddEventHandler(
		// Your custom resource event handlers.
		cache.ResourceEventHandlerFuncs{
			// Called on creation
			AddFunc: c.workAdd,
			// Called on resource update and every resyncPeriod on existing resources.
			UpdateFunc: c.workUpdate,
			// Called on resource deletion.
			DeleteFunc: c.workDelete,
		},
	)
	return c
}

var kubeconfig string

func init() {
	flag.StringVar(&kubeconfig, "kubeconfig", "", "absolute path to the kubeconfig file")
}

func main() {
	flag.Parse()

	//init client
	config, err := clientcmd.BuildConfigFromFlags("", kubeconfig)
	if err != nil {
		klog.Fatal(err)
	}
	clusterclient, err := clusterclient.NewForConfig(config)
	if err != nil {
		klog.Fatal(err)
	}
	workclient, err := workclient.NewForConfig(config)
	if err != nil {
		klog.Fatal(err)
	}

	//init manifestwork map
	clusters, err := clusterclient.ClusterV1().ManagedClusters().List(context.Background(), metav1.ListOptions{})
	if err != nil {
		klog.Fatal(err)
	}
	workGenMap := map[string]*workGenRecorder{}
	for _, c := range clusters.Items {
		workGenMap[c.Name+"/"+c.Name+klusterletwork] = &workGenRecorder{}
		for _, addon := range addonworks {
			workGenMap[c.Name+"/"+addon] = &workGenRecorder{}
		}
	}
	klog.Infof("Init workGenMap: %v", workGenMap)

	//start watch
	factory := workinformers.NewSharedInformerFactory(workclient, 5*time.Minute)
	controller := NewWorkController(factory, workGenMap)
	stop := make(chan struct{})
	defer close(stop)
	err = controller.Run(stop)
	if err != nil {
		klog.Fatal(err)
	}
	select {}
}
