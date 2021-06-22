#/bin/bash
DOMAIN="http://observability-thanos-query-frontend.open-cluster-management-observability.svc:9090"

wrk -t1 -c1 -d15m --latency ${DOMAIN}/api/v1/query\?query\=workqueue_depth
wrk -t10 -c10 -d15m --latency ${DOMAIN}/api/v1/query\?query\=workqueue_depth
wrk -t100 -c100 -d15m --latency ${DOMAIN}/api/v1/query\?query\=workqueue_depth

wrk -t1 -c1 -d15m --latency "${DOMAIN}/api/v1/series?match[]=workqueue_depth{namespace="default"}"
wrk -t10 -c10 -d15m --latency "${DOMAIN}/api/v1/series?match[]=workqueue_depth{namespace="default"}"
wrk -t100 -c100 -d15m --latency "${DOMAIN}/api/v1/series?match[]=workqueue_depth{namespace="default"}"

wrk -t1 -c1 -d15m --latency ${DOMAIN}/api/v1/query\?query\=rate\(workqueue_depth\[24h\]\)
wrk -t10 -c10 -d15m --latency ${DOMAIN}/api/v1/query\?query\=rate\(workqueue_depth\[24h\]\)
wrk -t100 -c100 -d15m --latency ${DOMAIN}/api/v1/query\?query\=rate\(workqueue_depth\[24h\]\)
