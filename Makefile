COREOS_STREAM ?= stable
COREOS_VERSION ?= 37.20221225.3.0
COREOS_IMAGE ?= fedora-coreos-$(COREOS_VERSION)-qemu.x86_64.qcow2
COREOS_URL ?= https://builds.coreos.fedoraproject.org/prod/streams/$(COREOS_STREAM)/builds/$(COREOS_VERSION)/x86_64/$(COREOS_IMAGE).xz // editorconfig-checker-disable-line
# Using a hidden file prevents terratest from copying it to temporary folders
COREOS_IMAGE_FILE ?= .tmp/$(COREOS_IMAGE)

GOTEST = gotestsum --format testname

export TF_VAR_libvirt_uri = qemu:///system
export TF_VAR_coreos_image = $(COREOS_IMAGE_FILE)

modules = $(wildcard modules/*)

.PHONY: test
test: bootstrap
	$(MAKE) --jobs=6 $(modules)

.PHONY: $(modules)
$(modules):
	cd $@/test && go clean -testcache && $(GOTEST)

.PHONY: bootstrap
bootstrap: test/bootstrap/$(COREOS_IMAGE_FILE) test/bootstrap/.terraform
	cd test/bootstrap && terraform apply -auto-approve

test/bootstrap/.terraform:
	cd test/bootstrap && terraform init

test/bootstrap/$(COREOS_IMAGE_FILE):
	mkdir -p test/bootstrap/$(dir $(COREOS_IMAGE_FILE))
	curl $(COREOS_URL) | xzcat > test/bootstrap/$(COREOS_IMAGE_FILE)
