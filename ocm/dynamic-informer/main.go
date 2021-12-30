package main

import (
	"fmt"
	goruntime "runtime"
	"time"

	v1 "k8s.io/api/core/v1"
//	"k8s.io/apimachinery/pkg/api/meta"
	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
//	"k8s.io/apimachinery/pkg/runtime"
)

func main() {
	unleak()
}

func unleak() {
	store := make(map[string]*v1.Pod)
	var index int
	for {
		plist := generatePod(index)
		for _, pod := range plist.Items {
			store[pod.Name] = &pod
		}
		time.Sleep(time.Second * 2)
		index++
		goruntime.GC()
		fmt.Println("==unleak==", index, len(store))
	}
}

func leak() {
	store := make(map[string]*v1.Pod)
	var index int
	for {
		plist := generatePod(index)
		for i := 0; i < len(plist.Items); i++  {
			store[plist.Items[i].GetName()] = &plist.Items[i]
			//store[pod.Name] = &pod
		}
		time.Sleep(time.Second * 2)
		index++
		goruntime.GC()
		fmt.Println("==unleak==", index, len(store))
	}
}

/* func leak() {
	store := make(map[string]*v1.Pod)
	var index int
	var items []runtime.Object
	for {
		items = items[:0]
		plist := generatePod(index)
		meta.EachListItem(plist, func(obj runtime.Object) error {
			items = append(items, obj)
			return nil
		})
		for _, item := range items {
			pod := item.(*v1.Pod)
			store[pod.Name] = pod
		}
		time.Sleep(time.Second * 2)
		index++
		goruntime.GC()
		fmt.Println("==leak==", index, len(store))
	}
} */

func generatePod(num int) *v1.PodList {
	var plist v1.PodList
	for i := 0; i < 100000-num; i++ {
		pod := v1.Pod{
			ObjectMeta: metav1.ObjectMeta{
				Name: fmt.Sprintf("pod-%d", i),
			},
		}
		plist.Items = append(plist.Items, pod)
	}
	return &plist
}
