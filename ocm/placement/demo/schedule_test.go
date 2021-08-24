package demo

import (
	"context"
	"fmt"

	"github.com/onsi/ginkgo"
	"github.com/onsi/gomega"
	corev1 "k8s.io/api/core/v1"
	"k8s.io/apimachinery/pkg/api/resource"
	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
	"k8s.io/apimachinery/pkg/util/rand"

	apiequality "k8s.io/apimachinery/pkg/api/equality"
	clusterapiv1 "open-cluster-management.io/api/cluster/v1"
	clusterapiv1alpha1 "open-cluster-management.io/api/cluster/v1alpha1"
	"open-cluster-management.io/placement/test/integration/util"
)

const (
	clusterSetLabel = "cluster.open-cluster-management.io/clusterset"
	placementLabel  = "cluster.open-cluster-management.io/placement"
)

var _ = ginkgo.Describe("Schedule", func() {
	var namespace string
	var placementName string
	var clusterName string
	var clusterSet1Name string
	var suffix string
	var err error
	var num int64

	ginkgo.BeforeEach(func() {
		num += 1
		suffix = rand.String(5)
		namespace = fmt.Sprintf("ns-%s-%d", suffix, num)
		placementName = fmt.Sprintf("placement-%s", suffix)
		clusterName = fmt.Sprintf("cluster-%s", suffix)
		clusterSet1Name = fmt.Sprintf("clusterset-%s-%d", suffix, num)

		// create testing namespace
		ns := &corev1.Namespace{
			ObjectMeta: metav1.ObjectMeta{
				Name: namespace,
			},
		}
		_, err := kubeClient.CoreV1().Namespaces().Create(context.Background(), ns, metav1.CreateOptions{})
		gomega.Expect(err).ToNot(gomega.HaveOccurred())
	})

	ginkgo.AfterEach(func() {
		err := kubeClient.CoreV1().Namespaces().Delete(context.Background(), namespace, metav1.DeleteOptions{})
		gomega.Expect(err).ToNot(gomega.HaveOccurred())
	})

	assertPlacementDecisionCreated := func(placement *clusterapiv1alpha1.Placement) {
		ginkgo.By("Check if placementdecision is created")
		gomega.Eventually(func() bool {
			pdl, err := clusterClient.ClusterV1alpha1().PlacementDecisions(namespace).List(context.Background(), metav1.ListOptions{
				LabelSelector: placementLabel + "=" + placement.Name,
			})
			if err != nil {
				return false
			}
			if len(pdl.Items) == 0 {
				return false
			}
			for _, pd := range pdl.Items {
				if controlled := metav1.IsControlledBy(&pd.ObjectMeta, placement); !controlled {
					return false
				}
			}
			return true
		}, eventuallyTimeout, eventuallyInterval).Should(gomega.BeTrue())
	}

	assertNumberOfDecisions := func(placementName string, desiredNOD int) {
		ginkgo.By("Check the number of decisions in placementdecisions")
		gomega.Eventually(func() bool {
			pdl, err := clusterClient.ClusterV1alpha1().PlacementDecisions(namespace).List(context.Background(), metav1.ListOptions{
				LabelSelector: placementLabel + "=" + placementName,
			})
			if err != nil {
				return false
			}
			actualNOD := 0
			for _, pd := range pdl.Items {
				actualNOD += len(pd.Status.Decisions)
			}
			return actualNOD == desiredNOD
		}, eventuallyTimeout, eventuallyInterval).Should(gomega.BeTrue())
	}

	assertClusterNamesOfDecisions := func(placementName string, desiredClusters []string) {
		ginkgo.By(fmt.Sprintf("Check the cluster names of placementdecisions %s", placementName))
		gomega.Eventually(func() bool {
			pdl, err := clusterClient.ClusterV1alpha1().PlacementDecisions(namespace).List(context.Background(), metav1.ListOptions{
				LabelSelector: placementLabel + "=" + placementName,
			})
			if err != nil {
				return false
			}
			actualClusters := []string{}
			for _, pd := range pdl.Items {
				for _, d := range pd.Status.Decisions {
					actualClusters = append(actualClusters, d.ClusterName)
				}
			}
			ginkgo.By(fmt.Sprintf("Expect %v, but got %v", desiredClusters, actualClusters))
			return apiequality.Semantic.DeepEqual(desiredClusters, actualClusters)
		}, eventuallyTimeout*2, eventuallyInterval).Should(gomega.BeTrue())
	}

	assertPlacementStatus := func(placementName string, numOfSelectedClusters int, satisfied bool) {
		ginkgo.By("Check the status of placement")
		gomega.Eventually(func() bool {
			placement, err := clusterClient.ClusterV1alpha1().Placements(namespace).Get(context.Background(), placementName, metav1.GetOptions{})
			if err != nil {
				return false
			}
			status := metav1.ConditionFalse
			if satisfied {
				status = metav1.ConditionTrue
			}
			if !util.HasCondition(
				placement.Status.Conditions,
				clusterapiv1alpha1.PlacementConditionSatisfied,
				"",
				status,
			) {
				return false
			}
			return placement.Status.NumberOfSelectedClusters == int32(numOfSelectedClusters)
		}, eventuallyTimeout, eventuallyInterval).Should(gomega.BeTrue())
	}

	assertBindingClusterSet := func(clusterSetName string) {
		ginkgo.By("Create clusterset/clustersetbinding")
		clusterset := &clusterapiv1alpha1.ManagedClusterSet{
			ObjectMeta: metav1.ObjectMeta{
				Name: clusterSetName,
			},
		}
		_, err = clusterClient.ClusterV1alpha1().ManagedClusterSets().Create(context.Background(), clusterset, metav1.CreateOptions{})
		gomega.Expect(err).ToNot(gomega.HaveOccurred())

		csb := &clusterapiv1alpha1.ManagedClusterSetBinding{
			ObjectMeta: metav1.ObjectMeta{
				Namespace: namespace,
				Name:      clusterSetName,
			},
			Spec: clusterapiv1alpha1.ManagedClusterSetBindingSpec{
				ClusterSet: clusterSetName,
			},
		}
		_, err = clusterClient.ClusterV1alpha1().ManagedClusterSetBindings(namespace).Create(context.Background(), csb, metav1.CreateOptions{})
		gomega.Expect(err).ToNot(gomega.HaveOccurred())
	}

	assertCreatingPlacement := func(name string, noc *int32, nod int, prefertype clusterapiv1alpha1.ClusterResourcePreferenceType, clusterResourceNames []clusterapiv1alpha1.ClusterResource) {
		ginkgo.By(fmt.Sprintf("Create placement %s", name))
		placement := &clusterapiv1alpha1.Placement{
			ObjectMeta: metav1.ObjectMeta{
				Namespace: namespace,
				Name:      name,
			},
			Spec: clusterapiv1alpha1.PlacementSpec{
				NumberOfClusters: noc,
			},
		}
		if prefertype != "" && clusterResourceNames != nil {
			placement.Spec.ClusterResourcePreference = &clusterapiv1alpha1.ClusterResourcePreference{
				Type:             prefertype,
				ClusterResources: clusterResourceNames,
			}
		}

		placement, err = clusterClient.ClusterV1alpha1().Placements(namespace).Create(context.Background(), placement, metav1.CreateOptions{})
		gomega.Expect(err).ToNot(gomega.HaveOccurred())

		assertPlacementDecisionCreated(placement)
		assertNumberOfDecisions(placementName, nod)
		if noc != nil {
			assertPlacementStatus(placementName, nod, nod == int(*noc))
		}
	}

	assertCreatingPlacementDecision := func(name string, clusterNames []string) {
		ginkgo.By(fmt.Sprintf("Create placementdecision %s", name))
		placementDecision := &clusterapiv1alpha1.PlacementDecision{
			ObjectMeta: metav1.ObjectMeta{
				Namespace: namespace,
				Name:      name,
				Labels: map[string]string{
					placementLabel: name,
				},
			},
		}
		placementDecision, err = clusterClient.ClusterV1alpha1().PlacementDecisions(namespace).Create(context.Background(), placementDecision, metav1.CreateOptions{})

		clusterDecisions := []clusterapiv1alpha1.ClusterDecision{}
		for _, clusterName := range clusterNames {
			clusterDecisions = append(clusterDecisions, clusterapiv1alpha1.ClusterDecision{
				ClusterName: clusterName,
			})
		}

		placementDecision.Status.Decisions = clusterDecisions
		placementDecision, err = clusterClient.ClusterV1alpha1().PlacementDecisions(namespace).UpdateStatus(context.Background(), placementDecision, metav1.UpdateOptions{})
		gomega.Expect(err).ToNot(gomega.HaveOccurred())
	}

	assertCreatingClustersWithNames := func(clusterSetName string, managedClusterNames []string) {
		ginkgo.By(fmt.Sprintf("Create %d clusters", len(managedClusterNames)))
		for _, name := range managedClusterNames {
			cluster := &clusterapiv1.ManagedCluster{
				ObjectMeta: metav1.ObjectMeta{
					GenerateName: "cluster-",
					Labels: map[string]string{
						clusterSetLabel: clusterSetName,
					},
					Name: name,
				},
			}
			ginkgo.By(fmt.Sprintf("Create cluster %s", name))
			_, err = clusterClient.ClusterV1().ManagedClusters().Create(context.Background(), cluster, metav1.CreateOptions{})
			gomega.Expect(err).ToNot(gomega.HaveOccurred())
		}
	}

	assertUpdatingClusterWithClusterResources := func(managedClusterName string, res []string) {
		ginkgo.By(fmt.Sprintf("Updating ManagedClusters %s cluster resources", managedClusterName))

		mc, err := clusterClient.ClusterV1().ManagedClusters().Get(context.Background(), managedClusterName, metav1.GetOptions{})
		gomega.Expect(err).ToNot(gomega.HaveOccurred())

		allocatable := map[clusterapiv1.ResourceName]resource.Quantity{}
		capacity := map[clusterapiv1.ResourceName]resource.Quantity{}

		allocatable[clusterapiv1.ResourceCPU], err = resource.ParseQuantity(res[0])
		gomega.Expect(err).ToNot(gomega.HaveOccurred())
		allocatable[clusterapiv1.ResourceMemory], err = resource.ParseQuantity(res[2])
		gomega.Expect(err).ToNot(gomega.HaveOccurred())
		capacity[clusterapiv1.ResourceCPU], err = resource.ParseQuantity(res[1])
		gomega.Expect(err).ToNot(gomega.HaveOccurred())
		capacity[clusterapiv1.ResourceMemory], err = resource.ParseQuantity(res[3])
		gomega.Expect(err).ToNot(gomega.HaveOccurred())

		mc.Status = clusterapiv1.ManagedClusterStatus{
			Allocatable: allocatable,
			Capacity:    capacity,
			Conditions:  []metav1.Condition{},
		}
		_, err = clusterClient.ClusterV1().ManagedClusters().UpdateStatus(context.Background(), mc, metav1.UpdateOptions{})
		gomega.Expect(err).ToNot(gomega.HaveOccurred())
	}

	ginkgo.It("Should schedule successfully based on most allocatable to capacity ratio CPU", func() {
		// cluster settings
		clusterNames := []string{
			clusterName + "-1",
			clusterName + "-2",
			clusterName + "-3",
		}
		clusterResources := make([][]string, len(clusterNames))
		clusterResources[0] = []string{"10", "10", "50Mi", "100Mi"}
		clusterResources[1] = []string{"9", "10", "80Mi", "100Mi"}
		clusterResources[2] = []string{"7", "10", "90Mi", "100Mi"}

		// placement settings
		clusterResourceNames := []clusterapiv1alpha1.ClusterResource{
			{ResourceName: clusterapiv1alpha1.ClusterResourceNameNameCPU},
			{ResourceName: clusterapiv1alpha1.ClusterResourceNameMemory},
		}

		//Creating the clusters with resources
		assertBindingClusterSet(clusterSet1Name)
		assertCreatingClustersWithNames(clusterSet1Name, clusterNames)
		for i, name := range clusterNames {
			assertUpdatingClusterWithClusterResources(name, clusterResources[i])
		}

		//Checking the result of the placement
		assertCreatingPlacement(placementName, noc(2), 2, clusterapiv1alpha1.ClusterResourcePreferenceTypeMostAllocatableToCapacityRatio, clusterResourceNames[0:1])
		assertClusterNamesOfDecisions(placementName, []string{clusterNames[0], clusterNames[1]})
	})

	ginkgo.It("Should schedule successfully based on most allocatable memory", func() {
		// cluster settings
		clusterNames := []string{
			clusterName + "-1",
			clusterName + "-2",
			clusterName + "-3",
		}
		clusterResources := make([][]string, len(clusterNames))
		clusterResources[0] = []string{"10", "10", "50Mi", "100Mi"}
		clusterResources[1] = []string{"9", "10", "80Mi", "100Mi"}
		clusterResources[2] = []string{"7", "10", "90Mi", "100Mi"}

		// placement settings
		clusterResourceNames := []clusterapiv1alpha1.ClusterResource{
			{ResourceName: clusterapiv1alpha1.ClusterResourceNameNameCPU},
			{ResourceName: clusterapiv1alpha1.ClusterResourceNameMemory},
		}

		//Creating the clusters with resources
		assertBindingClusterSet(clusterSet1Name)
		assertCreatingClustersWithNames(clusterSet1Name, clusterNames)
		for i, name := range clusterNames {
			assertUpdatingClusterWithClusterResources(name, clusterResources[i])
		}

		//Checking the result of the placement
		assertCreatingPlacement(placementName, noc(2), 2, clusterapiv1alpha1.ClusterResourcePreferenceTypeMostAllocatable, clusterResourceNames[1:2])
		assertClusterNamesOfDecisions(placementName, []string{clusterNames[1], clusterNames[2]})
	})

	ginkgo.It("Should re-schedule successfully successfully once a new cluster (cluster resource) added", func() {
		// cluster settings
		clusterNames := []string{
			clusterName + "-1",
			clusterName + "-2",
			clusterName + "-3",
		}
		clusterResources := make([][]string, len(clusterNames))
		clusterResources[0] = []string{"10", "10", "50Mi", "100Mi"}
		clusterResources[1] = []string{"9", "10", "80Mi", "100Mi"}
		clusterResources[2] = []string{"7", "10", "90Mi", "100Mi"}

		// placement settings
		clusterResourceNames := []clusterapiv1alpha1.ClusterResource{
			{ResourceName: clusterapiv1alpha1.ClusterResourceNameNameCPU},
			{ResourceName: clusterapiv1alpha1.ClusterResourceNameMemory},
		}

		//Creating the clusters with resources
		assertBindingClusterSet(clusterSet1Name)
		assertCreatingClustersWithNames(clusterSet1Name, clusterNames)
		for i, name := range clusterNames {
			assertUpdatingClusterWithClusterResources(name, clusterResources[i])
		}

		//Checking the result of the placement
		assertCreatingPlacement(placementName, noc(2), 2, clusterapiv1alpha1.ClusterResourcePreferenceTypeMostAllocatableToCapacityRatio, clusterResourceNames)
		assertClusterNamesOfDecisions(placementName, []string{clusterNames[1], clusterNames[2]})

		ginkgo.By("Adding a new cluster with resources")
		clusterNames = append(clusterNames, clusterName+"-4")
		newClusterResources := []string{"10", "10", "100Mi", "100Mi"}
		assertCreatingClustersWithNames(clusterSet1Name, clusterNames[3:4])
		assertUpdatingClusterWithClusterResources(clusterNames[3], newClusterResources)

		//Checking the result of the placement
		assertClusterNamesOfDecisions(placementName, []string{clusterNames[1], clusterNames[3]})

	})

	ginkgo.It("Should re-schedule successfully once another placementdecisions created and cluster resource reduces", func() {
		// cluster settings
		clusterNames := []string{
			clusterName + "-1",
			clusterName + "-2",
			clusterName + "-3",
		}
		clusterResources := make([][]string, len(clusterNames))
		clusterResources[0] = []string{"10", "10", "50Mi", "100Mi"}
		clusterResources[1] = []string{"9", "10", "80Mi", "100Mi"}
		clusterResources[2] = []string{"7", "10", "90Mi", "100Mi"}

		// placement settings
		clusterResourceNames := []clusterapiv1alpha1.ClusterResource{
			{ResourceName: clusterapiv1alpha1.ClusterResourceNameNameCPU},
			{ResourceName: clusterapiv1alpha1.ClusterResourceNameMemory},
		}

		//Creating the clusters with resources
		assertBindingClusterSet(clusterSet1Name)
		assertCreatingClustersWithNames(clusterSet1Name, clusterNames)
		for i, name := range clusterNames {
			assertUpdatingClusterWithClusterResources(name, clusterResources[i])
		}

		//Checking the result of the placement
		assertCreatingPlacement(placementName, noc(2), 2, clusterapiv1alpha1.ClusterResourcePreferenceTypeMostAllocatableToCapacityRatio, clusterResourceNames)
		assertClusterNamesOfDecisions(placementName, []string{clusterNames[1], clusterNames[2]})

		ginkgo.By("Adding fake placement decisions and update cluster resources")
		assertCreatingPlacementDecision(placementName+"-1", []string{clusterNames[1]})
		assertUpdatingClusterWithClusterResources(clusterNames[1], []string{"5", "10", "30Mi", "100Mi"})

		//Checking the result of the placement
		assertClusterNamesOfDecisions(placementName, []string{clusterNames[0], clusterNames[2]})
	})
})

func noc(n int) *int32 {
	noc := int32(n)
	return &noc
}
