# Copyright Contributors to the Open Cluster Management project

FROM registry.ci.openshift.org/open-cluster-management/builder:go1.17-linux AS builder

COPY ./ /app/
WORKDIR /app/
RUN GOFLAGS="" go build -o myclient ./cmd 

FROM registry.access.redhat.com/ubi8/ubi-minimal:latest

COPY --from=builder /app/myclient /usr/local/bin/myclient