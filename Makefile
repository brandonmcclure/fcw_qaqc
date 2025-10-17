REGISTRY_NAME := ghcr.io/
REPOSITORY_NAME := brandonmcclure/
IMAGE_NAME := fcw_qaqc
TAG := :v1.0

# Run Options
getcommitid:
	$(eval COMMITID = $(shell git log -1 --pretty=format:"%H"))

getbranchname:
	$(eval BRANCH_NAME = $(shell echo "$$(git branch --show-current)" | sed 's/\//./g'))

get_file_safe_image_name:
	$(eval IMAGE_TAR_FILE_NAME = $(shell echo "$(IMAGE_NAME)" | sed 's/\//./g').tar)

build: IMAGE_NAME = fcw_qaqc
build: getcommitid getbranchname
	docker build -t $(REGISTRY_NAME)$(REPOSITORY_NAME)$(IMAGE_NAME)$(TAG) -t $(REGISTRY_NAME)$(REPOSITORY_NAME)$(IMAGE_NAME):$(BRANCH_NAME) -t $(REGISTRY_NAME)$(REPOSITORY_NAME)$(IMAGE_NAME):$(BRANCH_NAME)_$(COMMITID) .

build_multiarch:
	docker buildx build -t $(REGISTRY_NAME)$(REPOSITORY_NAME)$(IMAGE_NAME)$(TAG) --platform $(PLATFORMS) .

run: build
	docker run -it --rm -v $$(pwd):/mnt $(REGISTRY_NAME)$(REPOSITORY_NAME)$(IMAGE_NAME)$(TAG)

run_it: build
	docker run -it --rm --entrypoint=/bin/bash -v $$(pwd):/mnt $(REGISTRY_NAME)$(REPOSITORY_NAME)$(IMAGE_NAME)$(TAG)

package: get_file_safe_image_name
	docker save $(REGISTRY_NAME)$(REPOSITORY_NAME)$(IMAGE_NAME)$(TAG) -o $(IMAGE_TAR_FILE_NAME)

size:
	docker inspect -f "{{ .Size }}" $(REGISTRY_NAME)$(REPOSITORY_NAME)$(IMAGE_NAME)$(TAG)
	docker history $(REGISTRY_NAME)$(REPOSITORY_NAME)$(IMAGE_NAME)$(TAG)

publish:
	docker login; docker push $(REGISTRY_NAME)$(REPOSITORY_NAME)$(IMAGE_NAME)$(TAG); docker logout

build_rstudio: IMAGE_NAME = fcw_qaqc_rstudio
build_rstudio: getcommitid getbranchname
	docker build -f Dockerfile.rstudio -t $(REGISTRY_NAME)$(REPOSITORY_NAME)$(IMAGE_NAME)$(TAG) -t $(REGISTRY_NAME)$(REPOSITORY_NAME)$(IMAGE_NAME):$(BRANCH_NAME) -t $(REGISTRY_NAME)$(REPOSITORY_NAME)$(IMAGE_NAME):$(BRANCH_NAME)_$(COMMITID) .
build_34: IMAGE_NAME = fcw_qaqc_3_4
build_34: getcommitid getbranchname
	docker build -f Dockerfile.3.4 -t $(REGISTRY_NAME)$(REPOSITORY_NAME)$(IMAGE_NAME)$(TAG) -t $(REGISTRY_NAME)$(REPOSITORY_NAME)$(IMAGE_NAME):$(BRANCH_NAME) -t $(REGISTRY_NAME)$(REPOSITORY_NAME)$(IMAGE_NAME):$(BRANCH_NAME)_$(COMMITID) .
# Check the stdout for the password to log into rstudio. the user is "rstudio"
# Your local code repo is mounted to /mnt in the container. You can load the project and develop from here
run_rstudio: IMAGE_NAME = fcw_qaqc_rstudio
run_rstudio: build_rstudio
	docker run --rm -it -p 127.0.0.1:8787:8787 -v $$(pwd):/mnt/src $(REGISTRY_NAME)$(REPOSITORY_NAME)$(IMAGE_NAME)$(TAG)