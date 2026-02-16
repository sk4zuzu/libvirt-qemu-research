#!/usr/bin/env bash

set -o errexit -o nounset -o pipefail
set -x

install -d /var/lib/swtpm-localca/

systemctl mask systemd-networkd-wait-online.service

sync
