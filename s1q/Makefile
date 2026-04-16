SHELL := $(shell which bash)
SELF  := $(patsubst %/,%,$(dir $(abspath $(firstword $(MAKEFILE_LIST)))))

BASH   ?= doas bash
KILL   ?= doas kill
UNLINK ?= doas unlink
VIRSH  ?= doas virsh

PUBKEY ?= ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIF5ndznuZTNZ8u7FCYKgv6Q3/HUVxnaha3tPDUXPfIIw

define NETWORK_XML
<network>
  <name>s1q</name>
  <forward mode='nat'>
    <nat>
      <port start='1024' end='65535'/>
    </nat>
  </forward>
  <bridge name='s1q' stp='on' delay='0'/>
  <domain name='s1q.lh' localOnly='yes'/>
  <dns enable='yes'>
    <host ip='10.3.20.10'>
      <hostname>s1q10</hostname>
    </host>
    <host ip='10.3.20.20'>
      <hostname>s1q20</hostname>
    </host>
    <host ip='10.3.20.30'>
      <hostname>s1q30</hostname>
    </host>
  </dns>
  <ip address='10.3.20.1' netmask='255.255.255.0'>
  </ip>
</network>
endef

define RENDER_QEMU_CMD_MAKE
exec qemu-system-x86_64

-daemonize
-name 'guest=s1q$(1),debug-threads=on'

-machine 'pc-q35-10.1,usb=off,dump-guest-core=off,memory-backend=pc.ram,acpi=on'
-accel 'kvm'
-cpu 'host,migratable=on'
-smp '2,sockets=2,cores=1,threads=1'
-no-user-config
-nodefaults
-rtc 'base=utc'
-boot 'strict=on'

-m 'size=$(2)B'
-object '{"size":$(2),"qom-type":"memory-backend-file","id":"pc.ram","mem-path":"/dev/hugepages/s1q$(1)","x-use-canonical-path-for-ramblock-id":false,"prealloc":true,"share":true}'

-device '{"driver":"pcie-root-port","port":16,"chassis":1,"id":"pci.1","bus":"pcie.0","multifunction":true,"addr":"0x2"}'
-device '{"driver":"pcie-root-port","port":17,"chassis":2,"id":"pci.2","bus":"pcie.0","addr":"0x2.0x1"}'
-device '{"driver":"pcie-root-port","port":18,"chassis":3,"id":"pci.3","bus":"pcie.0","addr":"0x2.0x2"}'
-device '{"driver":"pcie-root-port","port":19,"chassis":4,"id":"pci.4","bus":"pcie.0","addr":"0x2.0x3"}'
-device '{"driver":"pcie-root-port","port":20,"chassis":5,"id":"pci.5","bus":"pcie.0","addr":"0x2.0x4"}'
-device '{"driver":"pcie-root-port","port":21,"chassis":6,"id":"pci.6","bus":"pcie.0","addr":"0x2.0x5"}'
-device '{"driver":"pcie-root-port","port":22,"chassis":7,"id":"pci.7","bus":"pcie.0","addr":"0x2.0x6"}'
-device '{"driver":"pcie-root-port","port":23,"chassis":8,"id":"pci.8","bus":"pcie.0","addr":"0x2.0x7"}'
-device '{"driver":"qemu-xhci","id":"usb","bus":"pci.5","addr":"0x0"}'

-blockdev '{"driver":"file","filename":"$(SELF)/.cache/s1q$(1).qcow2","node-name":"libvirt-2-storage","auto-read-only":true,"discard":"unmap"}'
-blockdev '{"node-name":"libvirt-2-format","read-only":false,"driver":"qcow2","file":"libvirt-2-storage","backing":null}'
-device '{"driver":"virtio-blk-pci","bus":"pci.6","addr":"0x0","drive":"libvirt-2-format","id":"virtio-disk0","bootindex":1}'
-blockdev '{"driver":"file","filename":"$(SELF)/.cache/s1q$(1).iso","node-name":"libvirt-1-storage","read-only":true}'
-device '{"driver":"ide-cd","bus":"ide.3","drive":"libvirt-1-storage","id":"sata0-0-3"}'

-fsdev 'local,security_model=passthrough,id=fsdev-fs0,path=/_shared'
-device '{"driver":"virtio-9p-pci","id":"fs0","fsdev":"fsdev-fs0","mount_tag":"_shared","bus":"pci.1","addr":"0x0"}'

-audiodev '{"id":"audio1","driver":"none"}'
-vnc "127.0.0.1:$$((1000 + $(1))),audiodev=audio1"
-device '{"driver":"cirrus-vga","id":"video0","bus":"pcie.0","addr":"0x1"}'
-device '{"driver":"virtio-balloon-pci","id":"balloon0","bus":"pci.7","addr":"0x0"}'

-netdev '{"type":"bridge","id":"net0","br":"s1q"}'
-device '{"driver":"virtio-net-pci","netdev":"net0","iommu_platform":true,"disable-legacy":"on","bus":"pci.2","addr":"0x0","mac":"52:54:03:00:20:$(1)","mq":true,"vectors":6}'


-netdev '{"type":"bridge","id":"net8","br":"s1q"}'
-netdev '{"type":"bridge","id":"net7","br":"s1q"}'
-netdev '{"type":"bridge","id":"net6","br":"s1q"}'
-netdev '{"type":"bridge","id":"net5","br":"s1q"}'

-device '{"driver":"virtio-net-pci","netdev":"net8","iommu_platform":true,"disable-legacy":"on","bus":"pci.4","addr":"0x0.0x3","sriov-pf":"net5"}'
-device '{"driver":"virtio-net-pci","netdev":"net7","iommu_platform":true,"disable-legacy":"on","bus":"pci.4","addr":"0x0.0x2","sriov-pf":"net5"}'
-device '{"driver":"virtio-net-pci","netdev":"net6","iommu_platform":true,"disable-legacy":"on","bus":"pci.4","addr":"0x0.0x1","sriov-pf":"net5"}'
-device '{"driver":"virtio-net-pci","netdev":"net5","iommu_platform":true,"disable-legacy":"on","bus":"pci.4","addr":"0x0.0x0","id":"net5"}'


-netdev '{"type":"bridge","id":"net4","br":"s1q"}'
-netdev '{"type":"bridge","id":"net3","br":"s1q"}'
-netdev '{"type":"bridge","id":"net2","br":"s1q"}'
-netdev '{"type":"bridge","id":"net1","br":"s1q"}'

-device '{"driver":"virtio-net-pci","netdev":"net4","iommu_platform":true,"disable-legacy":"on","bus":"pci.3","addr":"0x0.0x3","sriov-pf":"net1"}'
-device '{"driver":"virtio-net-pci","netdev":"net3","iommu_platform":true,"disable-legacy":"on","bus":"pci.3","addr":"0x0.0x2","sriov-pf":"net1"}'
-device '{"driver":"virtio-net-pci","netdev":"net2","iommu_platform":true,"disable-legacy":"on","bus":"pci.3","addr":"0x0.0x1","sriov-pf":"net1"}'
-device '{"driver":"virtio-net-pci","netdev":"net1","iommu_platform":true,"disable-legacy":"on","bus":"pci.3","addr":"0x0.0x0","id":"net1"}'


-device '{"driver":"intel-iommu","caching-mode":true}'
endef

define RENDER_USER_DATA_YML
#cloud-config
ssh_pwauth: false
users:
  - name: opensuse
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
instance-id: 's1q$(1)'
local-hostname: 's1q$(1)'
endef

define RENDER_NETWORK_CONFIG_YML
version: 2
ethernets:
  eth0:
    dhcp4: false
    dhcp6: false
    addresses: ['10.3.20.$(1)/24']
    routes:
      - metric: 0
        to: '0.0.0.0/0'
        via: '10.3.20.1'
    nameservers:
      addresses: ['10.3.20.1']
      search: ['s1q.lh']
  eth1:
    dhcp4: false
    dhcp6: false
  eth2:
    dhcp4: false
    dhcp6: false
endef

#define RENDER_NETWORK_CONFIG_YML
#version: 2
#ethernets:
#  eth0:
#    dhcp4: false
#    dhcp6: false
#  eth1:
#    dhcp4: false
#    dhcp6: false
#  eth2:
#    dhcp4: false
#    dhcp6: false
#bridges:
#  br0:
#    interfaces: [eth0]
#    dhcp4: false
#    dhcp6: false
#    addresses: ['10.3.20.$(1)/24']
#    routes:
#      - metric: 0
#        to: '0.0.0.0/0'
#        via: '10.3.20.1'
#    nameservers:
#      addresses: ['10.3.20.1']
#      search: ['s1q.lh']
#endef

define QEMU_TASKS_MAKE
$(SELF)/.cache/s1q$(1).iso: _USER_DATA_YML = $$(call RENDER_USER_DATA_YML,$(1))
$(SELF)/.cache/s1q$(1).iso: _META_DATA_YML = $$(call RENDER_META_DATA_YML,$(1))
$(SELF)/.cache/s1q$(1).iso: _NETWORK_CONFIG_YML = $$(call RENDER_NETWORK_CONFIG_YML,$(1))
$(SELF)/.cache/s1q$(1).iso:
	install -d $(SELF)/.cache/
	cloud-localds $$@ /dev/fd/3 /dev/fd/4 -N /dev/fd/5 3<<< "$$$$_USER_DATA_YML" 4<<< "$$$$_META_DATA_YML" 5<<< "$$$$_NETWORK_CONFIG_YML"

$(SELF)/.cache/s1q$(1).qcow2: $(SELF)/../packer/opensuse/.cache/output/packer-opensuse.qcow2
	install -d $(SELF)/.cache/
	cp $$^ $$@

.PHONY: s1q$(1)-apply s1q$(1)-destroy

s1q$(1)-apply: _QEMU_CMD_SH = $$(strip $$(call RENDER_QEMU_CMD_MAKE,$(1),$(2)))
s1q$(1)-apply: $(SELF)/.cache/s1q$(1).qcow2 $(SELF)/.cache/s1q$(1).iso
	ps -ax --no-headers -wwo pid,cmd \
	| grep -m1 '^ *[0-9]* qemu-system-x86_64 -daemonize -name guest=s1q$(1),' \
	|| $(BASH) -s <<< "$$$$_QEMU_CMD_SH"

s1q$(1)-destroy:
	ps -ax --no-headers -wwo pid,cmd \
	| gawk '/^ *[0-9]* qemu-system-x86_64 -daemonize -name guest=s1q$(1),/ {print $$$$1}' \
	| xargs --no-run-if-empty -n1 -P1 $(KILL)
	-$(UNLINK) /dev/hugepages/s1q$(1)
endef

export

.PHONY: all

all:

s1q-apply: net-apply s1q10-apply s1q20-apply s1q30-apply

s1q-destroy: s1q10-destroy s1q20-destroy s1q30-destroy net-destroy

$(eval $(call QEMU_TASKS_MAKE,10,$(shell expr 2048 \* 1048576)))
$(eval $(call QEMU_TASKS_MAKE,20,$(shell expr 5120 \* 1048576)))
$(eval $(call QEMU_TASKS_MAKE,30,$(shell expr 5120 \* 1048576)))

.PHONY: net-apply net-destroy

net-apply:
	$(VIRSH) net-dumpxml s1q || $(VIRSH) net-define /dev/fd/0 <<< "$$NETWORK_XML"
	-$(VIRSH) net-start s1q

net-destroy:
	-$(VIRSH) net-destroy s1q
	-$(VIRSH) net-undefine s1q

.PHONY: s1q-clean

s1q-clean:
	-rm -rf $(SELF)/.cache/
