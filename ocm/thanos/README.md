# Debug Thanos Query API with Jaeger
1. Install Jaeger through OpenShift Operator.
2. Update Thanos components with below configuration.
```
        - |-
          --tracing.config=type: JAEGER
          config:
            service_name: "thanos-query-frontend"
            endpoint: "http://jaeger-all-in-one-inmemory-collector.jaeger.svc.cluster.local:14268/api/traces"
            reporter_log_spans: true
            sampler_param: 1
```
3. Run a query, eg. https://{ocm-domain}/observability-query/api/v1/query?query=rate(workqueue_depth[24h])
4. Check the traceID.
```
$ oc logs observability-thanos-query-frontend-6c7f467f49-nns8m
level=info ts=2021-07-07T06:09:42.785782775Z caller=factory.go:38 msg="loading tracing configuration"
level=info ts=2021-07-07T06:09:42.785905489Z caller=jaeger.go:44 msg="loading Jaeger tracing configuration from YAML"
level=info ts=2021-07-07T06:09:42.786210463Z caller=logger.go:18 msg="debug logging disabled"
level=info ts=2021-07-07T06:09:42.78622697Z caller=logger.go:18 msg="Initializing logging reporter\n"
level=info ts=2021-07-07T06:09:42.786265807Z caller=logger.go:18 msg="debug logging disabled"
level=info ts=2021-07-07T06:09:42.80390988Z caller=query_frontend.go:252 msg="starting query frontend"
level=info ts=2021-07-07T06:09:42.803963369Z caller=intrumentation.go:48 msg="changing probe status" status=ready
level=info ts=2021-07-07T06:09:42.804018861Z caller=intrumentation.go:60 msg="changing probe status" status=healthy
level=info ts=2021-07-07T06:09:42.804049272Z caller=http.go:62 service=http/server component=query-frontend msg="listening for requests and metrics" address=0.0.0.0:9090
level=info ts=2021-07-07T06:16:30.948432783Z caller=logger.go:18 msg="Reporting span 7aa6b2faae18a037:7aa6b2faae18a037:0000000000000000:1"
level=info ts=2021-07-07T06:29:27.461781147Z caller=logger.go:18 msg="Reporting span 2a2db9d3ee925b81:2a2db9d3ee925b81:0000000000000000:1"
level=info ts=2021-07-07T07:50:20.189515819Z caller=logger.go:18 msg="Reporting span 78e3f8b234b3e7f7:78e3f8b234b3e7f7:0000000000000000:1"
level=info ts=2021-07-07T09:29:16.266974234Z caller=logger.go:18 msg="Reporting span 65d13b14051b4592:65d13b14051b4592:0000000000000000:1"
level=info ts=2021-07-08T08:16:38.040417918Z caller=handler.go:159 org_id=anonymous traceID=55baf6ee9fad64c5 msg="slow query detected" method=POST host= path=/api/v1/query time_taken=7.679059997s param_query=rate(workqueue_depth[24h]),rate(workqueue_depth[24h])
level=info ts=2021-07-08T08:16:38.040477212Z caller=logger.go:18 msg="Reporting span 55baf6ee9fad64c5:55baf6ee9fad64c5:0000000000000000:1"
```
5. Search the traceID, for example `55baf6ee9fad64c5`, through Jaeger UI https://jaeger-all-in-one-inmemory-jaeger.apps.{base-domain}.

