#!/usr/bin/env bash

: "${PFBUS:=$1}"
: "${PFBUS:=40}"

set -o errexit -o pipefail

type -p cat devlink gawk install modprobe printf udevadm &>/dev/null

# ---

if ! [[ -f /usr/sbin/devlink.bin ]]; then
    install -o 0 -g 0 -m u=rwx,go=rx /usr/sbin/devlink /usr/sbin/devlink.bin
fi

install -o 0 -g 0 -m u=rwx,go=rx /dev/fd/0 /usr/sbin/devlink <<'BASH'
#!/usr/bin/env bash
set -o errexit -o pipefail

read -r -d '#' AWK_GSUB_I <<'AWK'
{
    while (match($0, /pci\/0000:([0-9a-fA-F]{2}):00\.0/, a)) {
        d = strtonum("0x" a[1])
        $0 = substr($0, 1, RSTART - 1) "netdevsim/netdevsim" d substr($0, RSTART + RLENGTH)
    }
    print; fflush()
}#
AWK

read -r -d '#' AWK_GSUB_O <<'AWK'
{
    while (match($0, /netdevsim\/netdevsim([0-9]+)/, a)) {
        h = sprintf("%02x", a[1])
        $0 = substr($0, 1, RSTART - 1) "pci/0000:" h ":00.0" substr($0, RSTART + RLENGTH)
    }
    print; fflush()
}#
AWK

if [[ "$#" -gt 0 ]]; then
    mapfile -t ARGS < <(printf "%s\n" "$@" | gawk "$AWK_GSUB_I")
else
    ARGS=()
fi

/usr/sbin/devlink.bin "${ARGS[@]}" \
    > >(gawk "$AWK_GSUB_O") \
    2> >(gawk "$AWK_GSUB_O" >&2)
BASH

# ---

install -o 0 -g 0 -m u=rwx,go=rx /dev/fd/0 /var/tmp/switchdevmock-netdevsim.sh <<'BASH'
#!/usr/bin/env bash

: "${PFBUS:=$1}"

set -o errexit -o pipefail

exec >>/var/log/switchdevmock-netdevsim.log 2>&1

printf -v IID '%d' "0x$PFBUS"

modprobe netdevsim

if ! devlink.bin dev show "netdevsim/netdevsim$IID"; then
    echo "$IID 1" >/sys/bus/netdevsim/new_device
else
    cat "/sys/bus/pci/devices/0000:$PFBUS:00.0/sriov_numvfs" >"/sys/bus/netdevsim/devices/netdevsim$IID/sriov_numvfs"
fi
BASH

# ---

printf -v IID '%d' "0x$PFBUS"

install -o 0 -g 0 -m u=rw,go=r /dev/fd/0 "/etc/udev/rules.d/95-switchdevmock-$PFBUS.rules" <<EOF
SUBSYSTEM=="net", ACTION=="add", ENV{ID_NET_DRIVER}=="netdevsim", ENV{ID_NET_NAME_PATH}=="eni${IID}np*", \\
    NAME="%E{ID_NET_NAME_PATH}"

SUBSYSTEM=="pci", ACTION=="add", ENV{DRIVER}=="virtio-pci", ENV{ID_PATH}=="pci-0000:$PFBUS:00.[01]", \\
    RUN+="/var/tmp/switchdevmock-netdevsim.sh $PFBUS"
EOF

udevadm control --reload-rules
