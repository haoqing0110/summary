SHELL :=/bin/bash

all: build
.PHONY: all

# Image URL to use all building/pushing image targets;
IMAGE ?= placement
IMAGE_TAG?=latest
IMAGE_REGISTRY ?= quay.io/open-cluster-management
IMAGE_NAME?=$(IMAGE_REGISTRY)/$(IMAGE):$(IMAGE_TAG)
KUBECTL?=kubectl
KUSTOMIZE?=$(PWD)/$(PERMANENT_TMP_GOPATH)/bin/kustomize
KUSTOMIZE_VERSION?=v3.5.4
KUSTOMIZE_ARCHIVE_NAME?=kustomize_$(KUSTOMIZE_VERSION)_$(GOHOSTOS)_$(GOHOSTARCH).tar.gz
kustomize_dir:=$(dir $(KUSTOMIZE))

GIT_HOST ?= open-cluster-management.io
BASE_DIR := $(shell basename $(PWD))
DEST := $(GOPATH)/src/$(GIT_HOST)/$(BASE_DIR)

# Add packages to do unit test
GO_TEST_PACKAGES :=./pkg/...

# This will call a macro called "build-image" which will generate image specific targets based on the parameters:
# $0 - macro name
# $1 - target suffix
# $2 - Dockerfile path
# $3 - context directory for image build
# It will generate target "image-$(1)" for building the image and binding it as a prerequisite to target "images".
$(call build-image,$(IMAGE),$(IMAGE_REGISTRY)/$(IMAGE),./Dockerfile,.)


build-e2e:
	go test -c .

test-e2e: build-e2e
	./demo.test -test.v -ginkgo.v

clean-e2e:
	$(RM) ./demo.test

clean:
	kubectl delete managedclustersets.cluster.open-cluster-management.io $(kubectl get managedclustersets.cluster.open-cluster-management.io | awk '{print $1}')
	kubectl delete ns $(kubectl get ns | grep ns | awk '{print $1}')
