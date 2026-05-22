#!/usr/bin/env bash

set -o errexit -o nounset -o pipefail
set -x

install -o 0 -g 0 -m u=rw,go=r /dev/fd/0 /etc/systemd/system/rc-local.service <<'INI'
[Unit]
ConditionPathExists=/etc/rc.local

[Service]
Type=forking
ExecStart=/etc/rc.local start
TimeoutSec=0
StandardOutput=tty
RemainAfterExit=yes
SysVStartPriority=99

[Install]
WantedBy=multi-user.target
INI

install -o 0 -g 0 -m u=rwx,go=rx /dev/fd/0 /etc/rc.local <<'BASH'
#!/usr/bin/env bash
set -e
bash /var/tmp/switchdevmock.sh 30
bash /var/tmp/switchdevmock.sh 40
BASH

systemctl daemon-reload && systemctl enable rc-local.service

sync
