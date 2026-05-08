SHELL := $(shell which bash)
SELF  := $(patsubst %/,%,$(dir $(abspath $(firstword $(MAKEFILE_LIST)))))

BASH   ?= doas bash
KILL   ?= doas kill
UNLINK ?= doas unlink
VIRSH  ?= doas virsh

PUBKEY ?= ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIF5ndznuZTNZ8u7FCYKgv6Q3/HUVxnaha3tPDUXPfIIw

define NETWORK_XML
<network>
  <name>r2q</name>
  <forward mode='nat'>
    <nat>
      <port start='1024' end='65535'/>
    </nat>
  </forward>
  <bridge name='r2q' stp='on' delay='0'/>
  <domain name='r2q.lh' localOnly='yes'/>
  <dns enable='yes'>
    <host ip='10.3.31.10'>
      <hostname>r2q10</hostname>
    </host>
    <host ip='10.3.31.20'>
      <hostname>r2q20</hostname>
    </host>
    <host ip='10.3.31.30'>
      <hostname>r2q30</hostname>
    </host>
  </dns>
  <ip address='10.3.31.1' netmask='255.255.255.0'>
  </ip>
</network>
endef

define RENDER_QEMU_CMD_MAKE
exec qemu-system-x86_64

-daemonize
-name 'guest=r2q$(1),debug-threads=on'

-accel 'kvm'
-no-user-config
-nodefaults
-rtc 'base=utc'
-boot 'strict=on'

-blockdev 'driver=file,filename=$(SELF)/.cache/r2q$(1).iso,node-name=libvirt-1-storage,read-only=on'
-device 'ide-cd,bus=ide.3,drive=libvirt-1-storage,id=sata0-0-3'

-machine 'pc-q35-10.1,usb=off,dump-guest-core=off,memory-backend=pc.ram,acpi=on'

-cpu 'host,migratable=on'
-smp '2,sockets=2,cores=1,threads=1'

-m 'size=$(2)'
-object 'memory-backend-file,id=pc.ram,size=$(2),mem-path=/dev/hugepages/r2q$(1),prealloc=on,share=on,x-use-canonical-path-for-ramblock-id=off'

-device 'pcie-root-port,id=pci.1,bus=pcie.0,addr=0x2,port=16,chassis=1,multifunction=on'
-device 'pcie-root-port,id=pci.2,bus=pcie.0,addr=0x2.0x1,port=17,chassis=2'
-device 'pcie-root-port,id=pci.3,bus=pcie.0,addr=0x2.0x2,port=18,chassis=3'
-device 'pcie-root-port,id=pci.4,bus=pcie.0,addr=0x2.0x3,port=19,chassis=4'
-device 'pcie-root-port,id=pci.5,bus=pcie.0,addr=0x2.0x4,port=20,chassis=5'
-device 'pcie-root-port,id=pci.6,bus=pcie.0,addr=0x2.0x5,port=21,chassis=6'
-device 'pcie-root-port,id=pci.7,bus=pcie.0,addr=0x2.0x6,port=22,chassis=7'
-device 'pcie-root-port,id=pci.8,bus=pcie.0,addr=0x2.0x7,port=23,chassis=8'

-fsdev 'local,security_model=passthrough,id=fsdev-fs0,path=/_shared'
-device 'virtio-9p-pci,id=fs0,fsdev=fsdev-fs0,mount_tag=_shared,bus=pci.1,addr=0x0'

-device 'qemu-xhci,id=usb,bus=pci.6,addr=0x0'

-blockdev 'driver=file,filename=$(SELF)/.cache/r2q$(1).qcow2,node-name=libvirt-2-storage,auto-read-only=on,discard=unmap'
-blockdev 'driver=qcow2,node-name=libvirt-2-format,read-only=off,file=libvirt-2-storage'
-device 'virtio-blk-pci,bus=pci.7,addr=0x0,drive=libvirt-2-format,id=virtio-disk0,bootindex=1'

-audiodev 'none,id=audio1'
-vnc "127.0.0.1:$$((1000 + $(1))),audiodev=audio1"
-device 'cirrus-vga,id=video0,bus=pcie.0,addr=0x1'

-device 'virtio-balloon-pci,id=balloon0,bus=pci.8,addr=0x0'

-netdev 'bridge,id=net0,br=r2q'
-netdev 'bridge,id=net1,br=r2q'

-device 'virtio-net-pci,netdev=net0,iommu_platform=on,disable-legacy=on,bus=pci.2,addr=0x0,mac=52:54:03:00:31:$(1),mq=on,vectors=6'
-device 'virtio-net-pci,netdev=net1,iommu_platform=on,disable-legacy=on,bus=pci.3,addr=0x0,mac=52:54:03:01:31:$(1),mq=on,vectors=6'

-netdev 'bridge,id=net2,br=r2q'
-netdev 'bridge,id=net3,br=r2q'
-netdev 'bridge,id=net4,br=r2q'
-netdev 'bridge,id=net5,br=r2q'

-device 'virtio-net-pci,netdev=net5,iommu_platform=on,disable-legacy=on,bus=pci.4,addr=0x0.0x3,sriov-pf=net2'
-device 'virtio-net-pci,netdev=net4,iommu_platform=on,disable-legacy=on,bus=pci.4,addr=0x0.0x2,sriov-pf=net2'
-device 'virtio-net-pci,netdev=net3,iommu_platform=on,disable-legacy=on,bus=pci.4,addr=0x0.0x1,sriov-pf=net2'
-device 'virtio-net-pci,id=net2,netdev=net2,iommu_platform=on,disable-legacy=on,bus=pci.4,addr=0x0.0x0'

-netdev 'bridge,id=net6,br=r2q'
-netdev 'bridge,id=net7,br=r2q'
-netdev 'bridge,id=net8,br=r2q'
-netdev 'bridge,id=net9,br=r2q'

-device 'virtio-net-pci,netdev=net9,iommu_platform=on,disable-legacy=on,bus=pci.5,addr=0x0.0x3,sriov-pf=net6'
-device 'virtio-net-pci,netdev=net8,iommu_platform=on,disable-legacy=on,bus=pci.5,addr=0x0.0x2,sriov-pf=net6'
-device 'virtio-net-pci,netdev=net7,iommu_platform=on,disable-legacy=on,bus=pci.5,addr=0x0.0x1,sriov-pf=net6'
-device 'virtio-net-pci,id=net6,netdev=net6,iommu_platform=on,disable-legacy=on,bus=pci.5,addr=0x0.0x0'

-device 'intel-iommu,caching-mode=on'
endef

define RENDER_USER_DATA_YML
#cloud-config
ssh_pwauth: false
users:
  - name: cloud-user
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
instance-id: 'r2q$(1)'
local-hostname: 'r2q$(1)'
endef

define RENDER_NETWORK_CONFIG_YML
version: 2
ethernets:
  eth0:
    dhcp4: false
    dhcp6: false
    addresses: ['10.3.31.$(1)/24']
    routes:
      - metric: 0
        to: '0.0.0.0/0'
        via: '10.3.31.1'
    nameservers:
      addresses: ['10.3.31.1']
      search: ['r2q.lh']
  eth1:
    dhcp4: false
    dhcp6: false
  eth2:
    dhcp4: false
    dhcp6: false
  eth3:
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
#    addresses: ['10.3.31.$(1)/24']
#    routes:
#      - metric: 0
#        to: '0.0.0.0/0'
#        via: '10.3.31.1'
#    nameservers:
#      addresses: ['10.3.31.1']
#      search: ['r2q.lh']
#endef

define QEMU_TASKS_MAKE
$(SELF)/.cache/r2q$(1).iso: _USER_DATA_YML = $$(call RENDER_USER_DATA_YML,$(1))
$(SELF)/.cache/r2q$(1).iso: _META_DATA_YML = $$(call RENDER_META_DATA_YML,$(1))
$(SELF)/.cache/r2q$(1).iso: _NETWORK_CONFIG_YML = $$(call RENDER_NETWORK_CONFIG_YML,$(1))
$(SELF)/.cache/r2q$(1).iso:
	install -d $(SELF)/.cache/
	cloud-localds $$@ /dev/fd/3 /dev/fd/4 -N /dev/fd/5 3<<< "$$$$_USER_DATA_YML" 4<<< "$$$$_META_DATA_YML" 5<<< "$$$$_NETWORK_CONFIG_YML"

$(SELF)/.cache/r2q$(1).qcow2: $(SELF)/../packer/redhat/.cache/output/packer-redhat.qcow2
	install -d $(SELF)/.cache/
	cp $$^ $$@

.PHONY: r2q$(1)-apply r2q$(1)-destroy

r2q$(1)-apply: _QEMU_CMD_SH = $$(strip $$(call RENDER_QEMU_CMD_MAKE,$(1),$(2)))
r2q$(1)-apply: $(SELF)/.cache/r2q$(1).qcow2 $(SELF)/.cache/r2q$(1).iso
	ps -ax --no-headers -wwo pid,cmd \
	| grep -m1 '^ *[0-9]* qemu-system-x86_64 -daemonize -name guest=r2q$(1),' \
	|| $(BASH) -s <<< "$$$$_QEMU_CMD_SH"

r2q$(1)-destroy:
	ps -ax --no-headers -wwo pid,cmd \
	| gawk '/^ *[0-9]* qemu-system-x86_64 -daemonize -name guest=r2q$(1),/ {print $$$$1}' \
	| xargs --no-run-if-empty -n1 -P1 $(KILL)
	-$(UNLINK) /dev/hugepages/r2q$(1)
endef

export

.PHONY: all

all:

r2q-apply: net-apply r2q20-apply r2q30-apply

r2q-destroy: r2q20-destroy r2q30-destroy net-destroy

$(eval $(call QEMU_TASKS_MAKE,20,8G))
$(eval $(call QEMU_TASKS_MAKE,30,8G))

.PHONY: net-apply net-destroy

net-apply:
	$(VIRSH) net-dumpxml r2q || $(VIRSH) net-define /dev/fd/0 <<< "$$NETWORK_XML"
	-$(VIRSH) net-start r2q

net-destroy:
	-$(VIRSH) net-destroy r2q
	-$(VIRSH) net-undefine r2q

.PHONY: r2q-clean

r2q-clean:
	-rm -rf $(SELF)/.cache/
