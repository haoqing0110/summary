package main

import (
	_ "net/http/pprof"
	"testing"
	"time"
)

func BenchmarkCreateManagedClusterDynamicInformer(b *testing.B) {
	CreateManagedClusterDynamicInformer()
	time.Sleep(1 * time.Second)
}

func BenchmarkCreateManagedClusterClusterInformer(b *testing.B) {
	CreateManagedClusterClusterInformer()
	time.Sleep(1 * time.Second)
}
