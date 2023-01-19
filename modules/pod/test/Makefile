.PHONY: ssh
ssh:
	ssh $$(terraform -chdir=fixtures output ip_address | tr --delete '"') -l core -i ../../../test/modules/libvirt/id_test
