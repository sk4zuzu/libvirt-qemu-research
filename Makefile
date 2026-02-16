SHELL := $(shell which bash)
SELF  := $(patsubst %/,%,$(dir $(abspath $(firstword $(MAKEFILE_LIST)))))

SSH_OPTIONS := -o ForwardAgent=yes \
               -o StrictHostKeyChecking=no \
               -o GlobalKnownHostsFile=/dev/null \
               -o UserKnownHostsFile=/dev/null

define PACKER_TASKS_MAKE
.PHONY: $(1)-disk

$(1)-disk:
	cd $(SELF)/packer/$(1)/ && make build
endef

define LIBVIRT_QEMU_TASKS_MAKE
.PHONY: $(1)-apply $(1)-destroy

$(1)-apply:
	cd $(SELF)/$(1)/ && make $(1)-apply

$(1)-destroy:
	cd $(SELF)/$(1)/ && make $(1)-destroy $(1)-clean
endef

define SSH_TASKS_MAKE
.PHONY: $(1)-ssh

$(1)-ssh: $(1)-ssh10

$(1)-ssh%:
	@ssh $(SSH_OPTIONS) $(3)$$* $(2)
endef

.PHONY: all binaries b become

all:

binaries:
	make -f $(SELF)/Makefile.BINARIES

$(eval $(call PACKER_TASKS_MAKE,ubuntu))

$(eval $(call LIBVIRT_QEMU_TASKS_MAKE,u1q))
$(eval $(call LIBVIRT_QEMU_TASKS_MAKE,u1v))

b become:
	@: $(eval BECOME_ROOT := -t sudo -i)

$(eval $(call SSH_TASKS_MAKE,u1q,$$(BECOME_ROOT),ubuntu@10.3.10.))
$(eval $(call SSH_TASKS_MAKE,u1v,$$(BECOME_ROOT),ubuntu@10.3.11.))

.PHONY: ls clean

ls:
	@machinectl list

clean:
	-make clean -f $(SELF)/Makefile.BINARIES
	-cd $(SELF)/packer/ubuntu/ && make clean
	-cd $(SELF)/u1q/ && make u1q-clean
	-cd $(SELF)/u1v/ && make u1v-clean
