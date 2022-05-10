# pprof
1. import pprof in your main.go
```
diff --git a/cmd/controller/controller.go b/cmd/controller/controller.go
index eb07ca1..1cd7e92 100644
--- a/cmd/controller/controller.go
+++ b/cmd/controller/controller.go
@@ -5,6 +5,8 @@ package main
 import (
        "fmt"
        "math/rand"
+       "net/http"
+       _ "net/http/pprof"
        "os"
        "time"
 
@@ -14,6 +16,7 @@ import (
 
        "k8s.io/component-base/cli/flag"
        "k8s.io/component-base/logs"
+       "k8s.io/klog"
 
        "github.com/spf13/pflag"
 )
@@ -26,6 +29,10 @@ func main() {
        logs.InitLogs()
        defer logs.FlushLogs()
 
+       klog.Errorf("HTTP server starting")
+       go http.ListenAndServe("0.0.0.0:6060", nil)
+       klog.Errorf("HTTP server started")
+
        ctx := signals.SetupSignalHandler()
        if err := app.Run(s, ctx); err != nil {
                fmt.Fprintf(os.Stderr, "%v\n", err)
```
2. export your pod as a route
```
apiVersion: v1
kind: Service
metadata:
  name: ocm-controller
  namespace: multicluster-engine
spec:
  internalTrafficPolicy: Cluster
  ipFamilies:
  - IPv4
  ipFamilyPolicy: SingleStack
  ports:
  - port: 6060
    protocol: TCP
    targetPort: 6060
  selector:
    control-plane: ocm-controller
  sessionAffinity: None
  type: ClusterIP
```
```
apiVersion: route.openshift.io/v1
kind: Route
metadata:
  name: ocm-controller
  namespace: multicluster-engine
spec:
  host: pprof.apps.server-foundation-410-rbt5h.dev04.red-chesterfield.com
  port:
    targetPort: 6060
  to:
    kind: Service
    name: ocm-controller
    weight: 100
  wildcardPolicy: None
```
3. interact from cmd
```
➜  ~ go tool pprof  http://pprof.apps.server-foundation-410-rbt5h.dev04.red-chesterfield.com/debug/pprof/heap
Fetching profile over HTTP from http://pprof.apps.server-foundation-410-rbt5h.dev04.red-chesterfield.com/debug/pprof/heap
Saved profile in /Users/haoqing/pprof/pprof.controller.alloc_objects.alloc_space.inuse_objects.inuse_space.026.pb.gz
File: controller
Type: inuse_space
Time: May 10, 2022 at 10:30am (CST)
Entering interactive mode (type "help" for commands, "o" for options)
(pprof) top
Showing nodes accounting for 38.21MB, 84.38% of 45.28MB total
Showing top 10 nodes out of 145
      flat  flat%   sum%        cum   cum%
   12.01MB 26.53% 26.53%    12.01MB 26.53%  reflect.unsafe_NewArray
      10MB 22.09% 48.61%       10MB 22.09%  sigs.k8s.io/json/internal/golang/encoding/json.(*decodeState).literalStore
       3MB  6.63% 55.24%        3MB  6.63%  reflect.New
    2.56MB  5.66% 60.90%     2.56MB  5.66%  k8s.io/apimachinery/pkg/watch.(*Broadcaster).Watch.func1
    2.50MB  5.52% 66.42%     2.50MB  5.52%  reflect.mapassign
       2MB  4.42% 70.84%        2MB  4.42%  k8s.io/apimachinery/pkg/runtime.(*RawExtension).UnmarshalJSON
    1.57MB  3.47% 74.32%     2.59MB  5.73%  k8s.io/apimachinery/pkg/runtime.(*Scheme).AddKnownTypeWithName
    1.55MB  3.42% 77.74%     1.55MB  3.42%  k8s.io/apimachinery/pkg/watch.NewLongQueueBroadcaster
    1.51MB  3.33% 81.06%     1.51MB  3.33%  github.com/stolostron/multicloud-operators-foundation/pkg/utils.Mergesubjects
    1.50MB  3.32% 84.38%     1.50MB  3.32%  k8s.io/apimachinery/pkg/api/meta.(*DefaultRESTMapper).AddSpecific
(pprof)
(pprof) %
```
4. intercact from web
```
go tool pprof -http=:8080 /Users/haoqing/pprof/pprof.controller.alloc_objects.alloc_space.inuse_objects.inuse_space.026.pb.gz
```