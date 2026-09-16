#!/usr/bin/env bash

policy_rc_d_disable() (echo "exit 101" >/usr/sbin/policy-rc.d && chmod a+x /usr/sbin/policy-rc.d)
policy_rc_d_enable()  (echo "exit 0"   >/usr/sbin/policy-rc.d && chmod a+x /usr/sbin/policy-rc.d)

export DEBIAN_FRONTEND=noninteractive

set -o errexit -o nounset -o pipefail
set -x

#gawk -i inplace -f- /etc/cloud/cloud.cfg <<'EOF'
#$1 == "apt_preserve_sources_list:" { $2 = "true"; found=1 }
#{ print }
#END { if (!found) print "apt_preserve_sources_list: true" >> FILENAME }
#EOF
#
#cat >/etc/apt/sources.list.d/ubuntu.sources <<EOF
#Types: deb
#URIs: http://ubuntu.task.gda.pl/ubuntu/
#Suites: noble noble-updates noble-backports
#Components: main universe restricted multiverse
#Signed-By: /usr/share/keyrings/ubuntu-archive-keyring.gpg
#
#Types: deb
#URIs: http://ubuntu.task.gda.pl/ubuntu/
#Suites: noble-security
#Components: main universe restricted multiverse
#Signed-By: /usr/share/keyrings/ubuntu-archive-keyring.gpg
#EOF

apt-get -q update -y

policy_rc_d_disable

apt-get -q remove -y --purge \
    unattended-upgrades

apt-get -q install -y --no-install-recommends \
    apt-transport-https \
    ca-certificates \
    curl \
    software-properties-common

apt-get -q install -y --no-install-recommends \
    gawk gcc \
    htop \
    iftop iproute2 \
    jq \
    make mc \
    net-tools netcat-traditional nethogs nmap \
    pv \
    socat \
    vim

apt-get -q install -y --no-install-recommends \
    driverctl \
    libhugetlbfs-bin \
    numactl

apt-get -q install -y \
    multipath-tools \
    nbd-client \
    open-iscsi \
    podman

policy_rc_d_enable

apt-get -q clean

sync
