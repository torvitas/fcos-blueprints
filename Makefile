COREOS_STREAM ?= stable
COREOS_VERSION ?= 37.20221225.3.0
COREOS_IMAGE ?= fedora-coreos-$(COREOS_VERSION)-qemu.x86_64.qcow2
COREOS_URL ?= https://builds.coreos.fedoraproject.org/prod/streams/$(COREOS_STREAM)/builds/$(COREOS_VERSION)/x86_64/$(COREOS_IMAGE).xz

GOTEST = gotestsum --format testname

export TF_VAR_libvirt_uri = qemu:///system
export TF_VAR_coreos_image = $(COREOS_IMAGE)

# modules = $(wildcard modules/*)
modules = modules/podman

.PHONY: test
test: bootstrap
	$(MAKE) -j5 $(modules)

.PHONY: $(modules)
$(modules):
	cd $@/test && go clean -testcache && gotestsum .

.PHONY: bootstrap
bootstrap: test/bootstrap/$(COREOS_IMAGE)
	cd test/bootstrap && terraform init
	cd test/bootstrap && terraform apply -auto-approve

test/bootstrap/$(COREOS_IMAGE):
	curl $(COREOS_URL) | xzcat > test/bootstrap/$(COREOS_IMAGE)
