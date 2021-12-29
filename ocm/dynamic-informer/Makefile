image: build-image push-image

.PHONY: build-image
build-image: 
	docker build -f Dockerfile . -t quay.io/haoqing/myclient:latest-di21-fix

.PHONY: push-image
push-image: 
	 docker push quay.io/haoqing/myclient:latest-di21-fix
