FROM golang:1.19 AS builder
WORKDIR /go/src/open-cluster-management.io/rollingupgrade
COPY . .
ENV GO_PACKAGE open-cluster-management.io/rollingupgrade

RUN make build

FROM registry.access.redhat.com/ubi8/ubi-minimal:latest
ENV USER_UID=10001
# If proxy is added here to resolve build issue, remove it in the codes (E.g., call os.Unsetenv at main.go),
# or the codes will use it and cause an error, the container cannot be started.
COPY --from=builder /go/src/open-cluster-management.io/rollingupgrade/work-update-controller /

USER ${USER_UID}
