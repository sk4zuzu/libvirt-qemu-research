SHELL := $(shell which bash)
SELF  := $(patsubst %/,%,$(dir $(abspath $(firstword $(MAKEFILE_LIST)))))

BASH  ?= doas bash
KILL  ?= doas kill
VIRSH ?= doas virsh

PUBKEY ?= ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIF5ndznuZTNZ8u7FCYKgv6Q3/HUVxnaha3tPDUXPfIIw

define NETWORK_XML
<network>
  <name>u1q</name>
  <forward mode='nat'>
    <nat>
      <port start='1024' end='65535'/>
    </nat>
  </forward>
  <bridge name='u1q' stp='on' delay='0'/>
  <domain name='u1q.lh' localOnly='yes'/>
  <dns enable='yes'>
    <host ip='10.3.10.10'>
      <hostname>u1q10</hostname>
    </host>
    <host ip='10.3.10.20'>
      <hostname>u1q20</hostname>
    </host>
    <host ip='10.3.10.30'>
      <hostname>u1q30</hostname>
    </host>
  </dns>
  <ip address='10.3.10.1' netmask='255.255.255.0'>
  </ip>
</network>
endef

define RENDER_QEMU_CMD_MAKE
exec qemu-system-x86_64

-daemonize
-name "guest=u1q$(1),debug-threads=on"

-machine 'pc-q35-10.1,usb=off,dump-guest-core=off,acpi=on'
-accel 'kvm'
-cpu 'host,migratable=on'
-m "size=$$(($(2) * 1024))k"
-smp '2,sockets=2,cores=1,threads=1'
-no-user-config
-nodefaults
-rtc 'base=utc'
-boot 'strict=on'

-device '{"driver":"pcie-root-port","port":16,"chassis":1,"id":"pci.1","bus":"pcie.0","multifunction":true,"addr":"0x2"}'
-device '{"driver":"pcie-root-port","port":17,"chassis":2,"id":"pci.2","bus":"pcie.0","addr":"0x2.0x1"}'
-device '{"driver":"pcie-root-port","port":18,"chassis":3,"id":"pci.3","bus":"pcie.0","addr":"0x2.0x2"}'
-device '{"driver":"pcie-root-port","port":19,"chassis":4,"id":"pci.4","bus":"pcie.0","addr":"0x2.0x3"}'
-device '{"driver":"pcie-root-port","port":20,"chassis":5,"id":"pci.5","bus":"pcie.0","addr":"0x2.0x4"}'
-device '{"driver":"pcie-root-port","port":21,"chassis":6,"id":"pci.6","bus":"pcie.0","addr":"0x2.0x5"}'
-device '{"driver":"pcie-root-port","port":22,"chassis":7,"id":"pci.7","bus":"pcie.0","addr":"0x2.0x6"}'
-device '{"driver":"pcie-root-port","port":23,"chassis":8,"id":"pci.8","bus":"pcie.0","addr":"0x2.0x7"}'
-device '{"driver":"qemu-xhci","id":"usb","bus":"pci.5","addr":"0x0"}'

-blockdev '{"driver":"file","filename":"$(SELF)/.cache/u1q$(1).qcow2","node-name":"libvirt-2-storage","auto-read-only":true,"discard":"unmap"}'
-blockdev '{"node-name":"libvirt-2-format","read-only":false,"driver":"qcow2","file":"libvirt-2-storage","backing":null}'
-device '{"driver":"virtio-blk-pci","bus":"pci.6","addr":"0x0","drive":"libvirt-2-format","id":"virtio-disk0","bootindex":1}'
-blockdev '{"driver":"file","filename":"$(SELF)/.cache/u1q$(1).iso","node-name":"libvirt-1-storage","read-only":true}'
-device '{"driver":"ide-cd","bus":"ide.3","drive":"libvirt-1-storage","id":"sata0-0-3"}'

-fsdev 'local,security_model=passthrough,id=fsdev-fs0,path=/_shared'
-device '{"driver":"virtio-9p-pci","id":"fs0","fsdev":"fsdev-fs0","mount_tag":"_shared","bus":"pci.1","addr":"0x0"}'

-audiodev '{"id":"audio1","driver":"none"}'
-vnc "127.0.0.1:$$((1000 + $(1))),audiodev=audio1"
-device '{"driver":"cirrus-vga","id":"video0","bus":"pcie.0","addr":"0x1"}'
-device '{"driver":"virtio-balloon-pci","id":"balloon0","bus":"pci.7","addr":"0x0"}'

-netdev '{"type":"bridge","id":"net0","br":"u1q"}'
-device '{"driver":"virtio-net-pci","netdev":"net0","bus":"pci.2","addr":"0x0"}'

-netdev '{"type":"bridge","id":"net3","br":"u1q"}'
-netdev '{"type":"bridge","id":"net2","br":"u1q"}'
-netdev '{"type":"bridge","id":"net1","br":"u1q"}'

-device '{"driver":"virtio-net-pci","netdev":"net3","bus":"pci.3","addr":"0x0.0x2","sriov-pf":"net1"}'
-device '{"driver":"virtio-net-pci","netdev":"net2","bus":"pci.3","addr":"0x0.0x1","sriov-pf":"net1"}'
-device '{"driver":"virtio-net-pci","netdev":"net1","bus":"pci.3","addr":"0x0.0x0","id":"net1"}'
endef

define RENDER_USER_DATA_YML
#cloud-config
ssh_pwauth: false
users:
  - name: ubuntu
    plain_text_passwd: asd
    lock_passwd: false
    sudo: ALL=(ALL) NOPASSWD:ALL
    shell: /bin/bash
    ssh_authorized_keys: ['$(PUBKEY)']
  - name: root
    lock_passwd: false
    ssh_authorized_keys: ['$(PUBKEY)']
growpart:
  mode: auto
  devices: [/]
mounts:
  - ['_shared', '/_shared', '9p', 'trans=virtio,version=9p2000.L,rw', '0', '0']
write_files:
  - path: /etc/sysctl.d/98-ip-forward.conf
    content: |
      net.ipv4.ip_forward = 1
runcmd:
  - sysctl -p /etc/sysctl.d/98-ip-forward.conf
endef

define RENDER_META_DATA_YML
instance-id: 'u1q$(1)'
local-hostname: 'u1q$(1)'
endef

define RENDER_NETWORK_CONFIG_YML
version: 2
ethernets:
  enp2s0:
    dhcp4: false
    dhcp6: false
  eth1:
    dhcp4: false
    dhcp6: false
bridges:
  br0:
    interfaces: [enp2s0]
    dhcp4: false
    dhcp6: false
    macaddress: '52:54:03:00:10:$(1)'
    addresses: ['10.3.10.$(1)/24']
    routes:
      - metric: 0
        to: '0.0.0.0/0'
        via: '10.3.10.1'
    nameservers:
      addresses: ['10.3.10.1']
      search: ['u1q.lh']
endef

define QEMU_TASKS_MAKE
$(SELF)/.cache/u1q$(1).iso: _USER_DATA_YML = $$(call RENDER_USER_DATA_YML,$(1))
$(SELF)/.cache/u1q$(1).iso: _META_DATA_YML = $$(call RENDER_META_DATA_YML,$(1))
$(SELF)/.cache/u1q$(1).iso: _NETWORK_CONFIG_YML = $$(call RENDER_NETWORK_CONFIG_YML,$(1))
$(SELF)/.cache/u1q$(1).iso:
	install -d $(SELF)/.cache/
	cloud-localds $$@ /dev/fd/3 /dev/fd/4 -N /dev/fd/5 3<<< "$$$$_USER_DATA_YML" 4<<< "$$$$_META_DATA_YML" 5<<< "$$$$_NETWORK_CONFIG_YML"

$(SELF)/.cache/u1q$(1).qcow2: $(SELF)/../packer/ubuntu/.cache/output/packer-ubuntu.qcow2
	install -d $(SELF)/.cache/
	cp $$^ $$@

.PHONY: u1q$(1)-apply u1q$(1)-destroy

u1q$(1)-apply: _QEMU_CMD_SH = $$(strip $$(call RENDER_QEMU_CMD_MAKE,$(1),$(2)))
u1q$(1)-apply: $(SELF)/.cache/u1q$(1).qcow2 $(SELF)/.cache/u1q$(1).iso
	ps -ax --no-headers -wwo pid,cmd \
	| grep -m1 '^ *[0-9]* qemu-system-x86_64 -daemonize -name guest=u1q$(1),' \
	|| $(BASH) -s <<< "$$$$_QEMU_CMD_SH"

u1q$(1)-destroy:
	ps -ax --no-headers -wwo pid,cmd \
	| gawk '/^ *[0-9]* qemu-system-x86_64 -daemonize -name guest=u1q$(1),/ {print $$$$1}' \
	| xargs --no-run-if-empty -n1 -P1 $(KILL)
endef

export

.PHONY: all

all:

u1q-apply: net-apply u1q10-apply u1q20-apply u1q30-apply

u1q-destroy: u1q10-destroy u1q20-destroy u1q30-destroy net-destroy

$(eval $(call QEMU_TASKS_MAKE,10,2048))
$(eval $(call QEMU_TASKS_MAKE,20,3072))
$(eval $(call QEMU_TASKS_MAKE,30,3072))

.PHONY: net-apply net-destroy

net-apply:
	$(VIRSH) net-dumpxml u1q || $(VIRSH) net-define /dev/fd/0 <<< "$$NETWORK_XML"
	-$(VIRSH) net-start u1q

net-destroy:
	-$(VIRSH) net-destroy u1q
	-$(VIRSH) net-undefine u1q

.PHONY: u1q-clean

u1q-clean:
	-rm -rf $(SELF)/.cache/
