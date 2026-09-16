SHELL := $(shell which bash)
SELF  := $(patsubst %/,%,$(dir $(abspath $(firstword $(MAKEFILE_LIST)))))

NAME := debian

#RELEASE  := bookworm
#VERSION  := 20260909-2596
#ARTIFACT := debian-12-generic-amd64-$(VERSION).qcow2
#CHECKSUM := 84946d6e2f55b1e8dcc114efc059f13882bd2ccdf36852126a13a0aa4a4ce0efee945406b78280e5942096639edc2a3ced20b70c12d9c7c7366ce364ba47a0ff

RELEASE  := trixie
VERSION  := 20260831-2587
ARTIFACT := debian-13-generic-amd64-$(VERSION).qcow2
CHECKSUM := 5a069019420fb9441ad4f8004c661fadb747edd5662ca54a17c8f923dee7d717e21dbdaa4ba72d6fce7f920e0217f0a9af382298a7d46ed4bc9dc33ac19181b6

CPUS      ?= 1
MEMORY    ?= 2048
DISK_SIZE ?= 10240

PACKER             := $(SELF)/../../bin/packer
PACKER_PLUGIN_PATH := $(SELF)/../../bin
PACKER_LOG         ?= 1
HEADLESS           ?= true

define CLOUD_CONFIG_YML
#cloud-config
users:
- name: debian
  plain_text_passwd: asd
  lock_passwd: false
  sudo: ALL=(ALL) NOPASSWD:ALL
  shell: /bin/bash
ssh_pwauth: true
endef

define PACKERFILE_HCL
source "qemu" "$(NAME)" {
  accelerator = "kvm"

  disk_image   = true
  iso_url      = "https://cloud.debian.org/images/cloud/$(RELEASE)/$(VERSION)/$(ARTIFACT)"
  iso_checksum = "$(CHECKSUM)"

  memory    = "$(MEMORY)"
  disk_size = "$(DISK_SIZE)"

  qemuargs = [
    ["-cpu", "host"],
    ["-smp", "cpus=$(CPUS)"],
    ["-cdrom", "$(SELF)/.cache/$(ARTIFACT).iso"],
    ["-serial", "stdio"],
  ]

  ssh_username = "debian"
  ssh_password = "asd"

  output_directory = "$(SELF)/.cache/output/"
  vm_name          = "packer-$(NAME).qcow2"

  headless = $(HEADLESS)
}
build {
  sources = ["source.qemu.$(NAME)"]
  provisioner "shell" {
    execute_command = "sudo {{.Vars}} bash {{.Path}}"
    scripts = [
      "remote-exec/01-basics.sh",
      "remote-exec/02-kernel.sh",
      "remote-exec/98-apparmor.sh",
      "remote-exec/99-fixes.sh",
    ]
  }
}
endef

export

.PHONY: all

all: build

$(SELF)/.cache/cloud-config.yml:
	install -d $(SELF)/.cache/ && echo "$$CLOUD_CONFIG_YML" >$@

$(SELF)/.cache/$(ARTIFACT).iso: $(SELF)/.cache/cloud-config.yml
	cloud-localds $@ $^

.PHONY: build

build: $(SELF)/.cache/output/packer-$(NAME).qcow2

$(SELF)/.cache/output/packer-$(NAME).qcow2: $(SELF)/.cache/$(ARTIFACT).iso Makefile $(wildcard $(SELF)/remote-exec/*.sh)
	if ! [[ -e $(SELF)/.cache/build.pkr.hcl ]]; then ln -s /dev/stdin $(SELF)/.cache/build.pkr.hcl; fi
	$(PACKER) build -force $(SELF)/.cache/build.pkr.hcl <<< "$$PACKERFILE_HCL"

.PHONY: clean

clean:
	-rm -rf $(SELF)/.cache/
