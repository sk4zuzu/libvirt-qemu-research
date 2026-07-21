SHELL := $(shell which bash)
SELF  := $(patsubst %/,%,$(dir $(abspath $(firstword $(MAKEFILE_LIST)))))

VIRSH  ?= doas virsh
PUBKEY ?= ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIF5ndznuZTNZ8u7FCYKgv6Q3/HUVxnaha3tPDUXPfIIw

define NETWORK_XML
<network>
  <name>u1v</name>
  <forward mode='nat'>
    <nat>
      <port start='1024' end='65535'/>
    </nat>
  </forward>
  <bridge name='u1v' stp='on' delay='0'/>
  <domain name='u1v.lh' localOnly='yes'/>
  <dns enable='yes'>
    <host ip='10.3.11.10'>
      <hostname>u1v10</hostname>
    </host>
    <host ip='10.3.11.20'>
      <hostname>u1v20</hostname>
    </host>
    <host ip='10.3.11.30'>
      <hostname>u1v30</hostname>
    </host>
    <host ip='10.3.11.40'>
      <hostname>u1v40</hostname>
    </host>
    <host ip='10.3.11.50'>
      <hostname>u1v50</hostname>
    </host>
    <host ip='10.3.11.60'>
      <hostname>u1v60</hostname>
    </host>
  </dns>
  <ip address='10.3.11.1' netmask='255.255.255.0'>
  </ip>
</network>
endef

define RENDER_DOMAIN_XML
<domain type='kvm'>
  <name>u1v$(1)</name>
  <memory unit='MiB'>$(2)</memory>
  <memoryBacking>
    <hugepages/>
  </memoryBacking>
  <vcpu placement='static'>2</vcpu>
  <resource>
    <partition>/machine</partition>
  </resource>
  <os>
    <type arch='x86_64' machine='pc-q35-10.1'>hvm</type>
  </os>
  <features>
    <acpi/>
  </features>
  <cpu mode='host-passthrough' check='none' migratable='on'/>
  <clock offset='utc'/>
  <on_poweroff>destroy</on_poweroff>
  <on_reboot>restart</on_reboot>
  <on_crash>destroy</on_crash>
  <devices>
    <disk type='file' device='disk'>
      <driver name='qemu' type='qcow2'/>
      <source file='$(SELF)/.cache/u1v$(1).qcow2'/>
      <target dev='vda' bus='virtio'/>
      <boot order='1'/>
      <alias name='virtio-disk0'/>
      <address type='pci' domain='0x0000' bus='0x06' slot='0x00' function='0x0'/>
    </disk>
    <disk type='file' device='cdrom'>
      <driver name='qemu' type='raw'/>
      <source file='$(SELF)/.cache/u1v$(1).iso' index='1'/>
      <backingStore/>
      <target dev='sdd' bus='sata'/>
      <readonly/>
      <alias name='sata0-0-3'/>
      <address type='drive' controller='0' bus='0' target='0' unit='3'/>
    </disk>
    <controller type='usb' index='0' model='qemu-xhci'>
      <alias name='usb'/>
      <address type='pci' domain='0x0000' bus='0x05' slot='0x00' function='0x0'/>
    </controller>
    <controller type='sata' index='0'>
      <alias name='ide'/>
      <address type='pci' domain='0x0000' bus='0x00' slot='0x1f' function='0x2'/>
    </controller>
    <controller type='pci' index='0' model='pcie-root'>
      <alias name='pcie.0'/>
    </controller>
    <controller type='pci' index='1' model='pcie-root-port'>
      <model name='pcie-root-port'/>
      <target chassis='1' port='0x10'/>
      <alias name='pci.1'/>
      <address type='pci' domain='0x0000' bus='0x00' slot='0x02' function='0x0' multifunction='on'/>
    </controller>
    <controller type='pci' index='2' model='pcie-root-port'>
      <model name='pcie-root-port'/>
      <target chassis='2' port='0x11'/>
      <alias name='pci.2'/>
      <address type='pci' domain='0x0000' bus='0x00' slot='0x02' function='0x1'/>
    </controller>
    <controller type='pci' index='3' model='pcie-root-port'>
      <model name='pcie-root-port'/>
      <target chassis='3' port='0x12'/>
      <alias name='pci.3'/>
      <address type='pci' domain='0x0000' bus='0x00' slot='0x02' function='0x2'/>
    </controller>
    <controller type='pci' index='4' model='pcie-root-port'>
      <model name='pcie-root-port'/>
      <target chassis='4' port='0x13'/>
      <alias name='pci.4'/>
      <address type='pci' domain='0x0000' bus='0x00' slot='0x02' function='0x3'/>
    </controller>
    <controller type='pci' index='5' model='pcie-root-port'>
      <model name='pcie-root-port'/>
      <target chassis='5' port='0x14'/>
      <alias name='pci.5'/>
      <address type='pci' domain='0x0000' bus='0x00' slot='0x02' function='0x4'/>
    </controller>
    <controller type='pci' index='6' model='pcie-root-port'>
      <model name='pcie-root-port'/>
      <target chassis='6' port='0x15'/>
      <alias name='pci.6'/>
      <address type='pci' domain='0x0000' bus='0x00' slot='0x02' function='0x5'/>
    </controller>
    <controller type='pci' index='7' model='pcie-root-port'>
      <model name='pcie-root-port'/>
      <target chassis='7' port='0x16'/>
      <alias name='pci.7'/>
      <address type='pci' domain='0x0000' bus='0x00' slot='0x02' function='0x6'/>
    </controller>
    <controller type='pci' index='8' model='pcie-root-port'>
      <model name='pcie-root-port'/>
      <target chassis='8' port='0x17'/>
      <alias name='pci.8'/>
      <address type='pci' domain='0x0000' bus='0x00' slot='0x02' function='0x7'/>
    </controller>
    <filesystem type='mount' accessmode='passthrough'>
      <source dir='/stor'/>
      <target dir='stor'/>
      <alias name='fs0'/>
      <address type='pci' domain='0x0000' bus='0x01' slot='0x00' function='0x0'/>
    </filesystem>
    <interface type='network'>
      <source network='u1v' bridge='u1v'/>
      <model type='virtio'/>
      <alias name='net0'/>
      <address type='pci' domain='0x0000' bus='0x02' slot='0x00' function='0x0'/>
    </interface>
    <interface type='network'>
      <source network='u1v' bridge='u1v'/>
      <model type='virtio'/>
      <alias name='net1'/>
      <address type='pci' domain='0x0000' bus='0x03' slot='0x00' function='0x0'/>
    </interface>
    <interface type='network'>
      <source network='u1v' bridge='u1v'/>
      <model type='virtio'/>
      <alias name='net2'/>
      <address type='pci' domain='0x0000' bus='0x04' slot='0x00' function='0x0'/>
    </interface>
    <input type='mouse' bus='ps2'>
      <alias name='input0'/>
    </input>
    <input type='keyboard' bus='ps2'>
      <alias name='input1'/>
    </input>
    <graphics type='vnc' autoport='yes' listen='127.0.0.1'>
      <listen type='address' address='127.0.0.1'/>
    </graphics>
    <audio id='1' type='none'/>
    <video>
      <model type='cirrus' vram='16384' heads='1' primary='yes'/>
      <alias name='video0'/>
      <address type='pci' domain='0x0000' bus='0x00' slot='0x01' function='0x0'/>
    </video>
    <memballoon model='virtio'>
      <alias name='balloon0'/>
      <address type='pci' domain='0x0000' bus='0x07' slot='0x00' function='0x0'/>
    </memballoon>
  </devices>
</domain>
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
  - ['stor', '/stor', '9p', 'trans=virtio,version=9p2000.L,rw', '0', '0']
write_files:
  - path: /etc/sysctl.d/98-ip-forward.conf
    content: |
      net.ipv4.ip_forward = 1
runcmd:
  - sysctl -p /etc/sysctl.d/98-ip-forward.conf
endef

define RENDER_META_DATA_YML
instance-id: 'u1v$(1)'
local-hostname: 'u1v$(1)'
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
  eth2:
    dhcp4: false
    dhcp6: false
bridges:
  br0:
    interfaces: [enp2s0]
    dhcp4: false
    dhcp6: false
    macaddress: '52:54:03:00:11:$(1)'
    addresses: ['10.3.11.$(1)/24']
    routes:
      - metric: 0
        to: '0.0.0.0/0'
        via: '10.3.11.1'
    nameservers:
      addresses: ['10.3.11.1']
      search: ['u1v.lh']
endef

define DOMAIN_TASKS_MAKE
$(SELF)/.cache/u1v$(1).iso: _USER_DATA_YML = $$(call RENDER_USER_DATA_YML,$(1))
$(SELF)/.cache/u1v$(1).iso: _META_DATA_YML = $$(call RENDER_META_DATA_YML,$(1))
$(SELF)/.cache/u1v$(1).iso: _NETWORK_CONFIG_YML = $$(call RENDER_NETWORK_CONFIG_YML,$(1))
$(SELF)/.cache/u1v$(1).iso:
	install -d $(SELF)/.cache/
	cloud-localds $$@ /dev/fd/3 /dev/fd/4 -N /dev/fd/5 3<<< "$$$$_USER_DATA_YML" 4<<< "$$$$_META_DATA_YML" 5<<< "$$$$_NETWORK_CONFIG_YML"

$(SELF)/.cache/u1v$(1).qcow2: $(SELF)/../packer/ubuntu/.cache/output/packer-ubuntu.qcow2
	install -d $(SELF)/.cache/
	cp $$^ $$@

.PHONY: u1v$(1)-apply u1v$(1)-destroy

u1v-apply: u1v$(1)-apply

u1v$(1)-apply: _DOMAIN_XML = $$(call RENDER_DOMAIN_XML,$(1),$(2))
u1v$(1)-apply: $(SELF)/.cache/u1v$(1).qcow2 $(SELF)/.cache/u1v$(1).iso
	$(VIRSH) dumpxml u1v$(1) || $(VIRSH) define /dev/fd/0 <<< "$$$$_DOMAIN_XML"
	-$(VIRSH) start u1v$(1)

u1v$(1)-destroy:
	-$(VIRSH) destroy u1v$(1)
	-$(VIRSH) undefine u1v$(1)

u1v-destroy: u1v$(1)-destroy
endef

export

.PHONY: all

all:

.PHONY: u1v-apply u1v-destroy

u1v-apply: net-apply

$(eval $(call DOMAIN_TASKS_MAKE,10,2048))
$(eval $(call DOMAIN_TASKS_MAKE,20,3072))
$(eval $(call DOMAIN_TASKS_MAKE,30,3072))

u1v-destroy: net-destroy

.PHONY: net-apply net-destroy

net-apply:
	$(VIRSH) net-dumpxml u1v || $(VIRSH) net-define /dev/fd/0 <<< "$$NETWORK_XML"
	-$(VIRSH) net-start u1v

net-destroy:
	-$(VIRSH) net-destroy u1v
	-$(VIRSH) net-undefine u1v

.PHONY: u1v-clean

u1v-clean:
	-rm -rf $(SELF)/.cache/
