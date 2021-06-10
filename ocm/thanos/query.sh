#!/bin/bash
#oc port-forward -n open-cluster-management-observability service/observability-thanos-query 9090 > /dev/null & 
#PID=$!

for i in $(seq 1 $1)
do
    curl http://localhost:9090/api/v1/query\?query\=\(workqueue_depth\) > /dev/null
    curl http://localhost:9090/api/v1/query\?query\=count\(workqueue_depth\)
#    sleep 1
done

#sudo kill -9 ${PID}
