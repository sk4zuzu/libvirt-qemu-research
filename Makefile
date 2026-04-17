SHELL := $(shell which bash)
SELF  := $(patsubst %/,%,$(dir $(abspath $(firstword $(MAKEFILE_LIST)))))

SSH_OPTIONS := -o ForwardAgent=yes \
               -o StrictHostKeyChecking=no \
               -o GlobalKnownHostsFile=/dev/null \
               -o UserKnownHostsFile=/dev/null

CONFIRM := false

define PACKER_TASKS_MAKE
.PHONY: $(1)-disk

$(1)-disk:
	cd $(SELF)/packer/$(1)/ && make build
endef

define LIBVIRT_QEMU_TASKS_MAKE
.PHONY: $(1)-apply $(1)-destroy

$(1)-apply:
	$(2)
	cd $(SELF)/$(1)/ && make $(1)-apply

$(1)-destroy:
	$(2)
	cd $(SELF)/$(1)/ && make $(1)-destroy $(1)-clean
endef

define SSH_TASKS_MAKE
.PHONY: $(1)-ssh

$(1)-ssh: $(1)-ssh10

$(1)-ssh%:
	@ssh $(SSH_OPTIONS) $(3)$$* $(2)
endef

.PHONY: all binaries c confirm b become

all:

binaries:
	make -f $(SELF)/Makefile.BINARIES

$(eval $(call PACKER_TASKS_MAKE,alma))
$(eval $(call PACKER_TASKS_MAKE,debian))
$(eval $(call PACKER_TASKS_MAKE,opensuse))
$(eval $(call PACKER_TASKS_MAKE,redhat))
$(eval $(call PACKER_TASKS_MAKE,suse))
$(eval $(call PACKER_TASKS_MAKE,ubuntu))

c confirm:
	@: $(eval CONFIRM := true)

$(eval $(call LIBVIRT_QEMU_TASKS_MAKE,a1q,$$(CONFIRM)))
$(eval $(call LIBVIRT_QEMU_TASKS_MAKE,d1q,$$(CONFIRM)))
$(eval $(call LIBVIRT_QEMU_TASKS_MAKE,r1q,$$(CONFIRM)))
$(eval $(call LIBVIRT_QEMU_TASKS_MAKE,s1q,$$(CONFIRM)))
$(eval $(call LIBVIRT_QEMU_TASKS_MAKE,s2q,$$(CONFIRM)))
$(eval $(call LIBVIRT_QEMU_TASKS_MAKE,u1q,$$(CONFIRM)))
$(eval $(call LIBVIRT_QEMU_TASKS_MAKE,u1v,$$(CONFIRM)))
$(eval $(call LIBVIRT_QEMU_TASKS_MAKE,u2q,$$(CONFIRM)))

b become:
	@: $(eval BECOME_ROOT := -t sudo -i)

$(eval $(call SSH_TASKS_MAKE,a1q,$$(BECOME_ROOT),almalinux@10.3.50.))
$(eval $(call SSH_TASKS_MAKE,d1q,$$(BECOME_ROOT),debian@10.3.40.))
$(eval $(call SSH_TASKS_MAKE,r1q,$$(BECOME_ROOT),cloud-user@10.3.30.))
$(eval $(call SSH_TASKS_MAKE,s1q,$$(BECOME_ROOT),opensuse@10.3.20.))
$(eval $(call SSH_TASKS_MAKE,s2q,$$(BECOME_ROOT),suse@10.3.21.))
$(eval $(call SSH_TASKS_MAKE,u1q,$$(BECOME_ROOT),ubuntu@10.3.10.))
$(eval $(call SSH_TASKS_MAKE,u1v,$$(BECOME_ROOT),ubuntu@10.3.11.))
$(eval $(call SSH_TASKS_MAKE,u2q,$$(BECOME_ROOT),ubuntu@10.3.12.))

.PHONY: ls clean

ls:
	@machinectl list
	@ps -ax --no-headers -wwo comm,pid,cmd | gawk '$$1 != "grep" && $$3 ~ /qemu-system-/ {print $$2}'

clean:
	-make clean -f $(SELF)/Makefile.BINARIES
	-cd $(SELF)/packer/alma/ && make clean
	-cd $(SELF)/packer/debian/ && make clean
	-cd $(SELF)/packer/opensuse/ && make clean
	-cd $(SELF)/packer/redhat/ && make clean
	-cd $(SELF)/packer/suse/ && make clean
	-cd $(SELF)/packer/ubuntu/ && make clean
	-cd $(SELF)/a1q/ && make a1q-clean
	-cd $(SELF)/d1q/ && make d1q-clean
	-cd $(SELF)/r1q/ && make r1q-clean
	-cd $(SELF)/s1q/ && make s1q-clean
	-cd $(SELF)/s1q/ && make s2q-clean
	-cd $(SELF)/u1q/ && make u1q-clean
	-cd $(SELF)/u1v/ && make u1v-clean
	-cd $(SELF)/u2q/ && make u2q-clean
