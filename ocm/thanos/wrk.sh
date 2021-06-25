#/bin/bash
DOMAIN="https://multicloud-console.apps.obs-china-aws-4616-64sjs.dev05.red-chesterfield.com/observability-query"
HEAD="Authorization: Bearer sha256~lVh8Jqq8ytq6f_pItMBMltFjKLYz4br5Y1khArkSr6c"
#DOMAIN="${DOMAIN:-http://observability-thanos-query-frontend.open-cluster-management-observability.svc:9090}"

if [[ -z "${HEAD}" ]]; then
  curl ${DOMAIN}/api/v1/query\?query\=count\(workqueue_depth\)
  # raw data
  wrk -t1 -c1 -d10m --latency ${DOMAIN}/api/v1/query\?query\=workqueue_depth
  wrk -t5 -c5 -d10m --latency ${DOMAIN}/api/v1/query\?query\=workqueue_depth
  wrk -t10 -c10 -d10m --latency ${DOMAIN}/api/v1/query\?query\=workqueue_depth
  
  # filter
  wrk -t1 -c1 -d10m --latency --timeout 20s "${DOMAIN}/api/v1/series?match[]=workqueue_depth{namespace=\"default\"}"
  wrk -t5 -c5 -d10m --latency --timeout 20s "${DOMAIN}/api/v1/series?match[]=workqueue_depth{namespace=\"default\"}"
  wrk -t10 -c10 -d10m --latency --timeout 20s "${DOMAIN}/api/v1/series?match[]=workqueue_depth{namespace=\"default\"}"
  
  # aggregation hourly
  wrk -t1 -c1 -d10m --latency --timeout 20s ${DOMAIN}/api/v1/query\?query\=rate\(workqueue_depth\[60m\]\)
  wrk -t5 -c5 -d10m --latency --timeout 20s ${DOMAIN}/api/v1/query\?query\=rate\(workqueue_depth\[60m\]\)
  wrk -t10 -c10 -d10m --latency --timeout 20s ${DOMAIN}/api/v1/query\?query\=rate\(workqueue_depth\[60m\]\)

  # aggregation daily
  wrk -t1 -c1 -d10m --latency --timeout 20s ${DOMAIN}/api/v1/query\?query\=rate\(workqueue_depth\[24h\]\)
  wrk -t5 -c5 -d10m --latency --timeout 20s ${DOMAIN}/api/v1/query\?query\=rate\(workqueue_depth\[24h\]\)
  wrk -t10 -c10 -d10m --latency --timeout 20s ${DOMAIN}/api/v1/query\?query\=rate\(workqueue_depth\[24h\]\)
else 
  curl -k -H "$HEAD" ${DOMAIN}/api/v1/query\?query\=count\(workqueue_depth\)
  # raw data
  wrk -t1 -c1 -d10m --latency -H "$HEAD" ${DOMAIN}/api/v1/query\?query\=workqueue_depth
  wrk -t5 -c5 -d10m --latency -H "$HEAD" ${DOMAIN}/api/v1/query\?query\=workqueue_depth
  wrk -t10 -c10 -d10m --latency -H "$HEAD" ${DOMAIN}/api/v1/query\?query\=workqueue_depth
  
  # filter
  wrk -t1 -c1 -d10m --latency --timeout 20s -H "$HEAD" "${DOMAIN}/api/v1/series?match[]=workqueue_depth{namespace=\"default\"}"
  wrk -t5 -c5 -d10m --latency --timeout 20s -H "$HEAD" "${DOMAIN}/api/v1/series?match[]=workqueue_depth{namespace=\"default\"}"
  wrk -t10 -c10 -d10m --latency --timeout 20s -H "$HEAD" "${DOMAIN}/api/v1/series?match[]=workqueue_depth{namespace=\"default\"}"
  
  # aggregation daily
  wrk -t1 -c1 -d10m --latency --timeout 20s -H "$HEAD" ${DOMAIN}/api/v1/query\?query\=rate\(workqueue_depth\[60m\]\)
  wrk -t5 -c5 -d10m --latency --timeout 20s -H "$HEAD" ${DOMAIN}/api/v1/query\?query\=rate\(workqueue_depth\[60m\]\)
  wrk -t10 -c10 -d10m --latency --timeout 20s -H "$HEAD" ${DOMAIN}/api/v1/query\?query\=rate\(workqueue_depth\[60m\]\)

  # aggregation hourly
  wrk -t1 -c1 -d10m --latency --timeout 20s -H "$HEAD" ${DOMAIN}/api/v1/query\?query\=rate\(workqueue_depth\[24h\]\)
  wrk -t5 -c5 -d10m --latency --timeout 20s -H "$HEAD" ${DOMAIN}/api/v1/query\?query\=rate\(workqueue_depth\[24h\]\)
  wrk -t10 -c10 -d10m --latency --timeout 20s -H "$HEAD" ${DOMAIN}/api/v1/query\?query\=rate\(workqueue_depth\[24h\]\)
fi

