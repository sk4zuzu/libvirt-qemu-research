#!/usr/bin/env bash

: "${PFBUS:=$1}"
: "${PFBUS:=40}"

set -o errexit -o pipefail

type -p cat devlink find gawk install ln mkdir modprobe mount mountpoint printf rm systemctl touch udevadm &>/dev/null

printf -v IID '%d' "0x$PFBUS"

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
    cat "/sys/bus/pci/devices/0000:$PFBUS:00.0/sriov_numvfs" >"/sys/bus/netdevsim/devices/netdevsim$IID/sriov_numvfs"
fi
BASH

# ---

install -o 0 -g 0 -m u=rwx,go=rx /dev/fd/0 /var/tmp/switchdevmock-pci.sh <<'BASH'
#!/usr/bin/env bash

: "${PFBUS:=$1}"

set -o errexit -o pipefail

exec >>/var/log/switchdevmock-pci.log 2>&1

printf -v IID '%d' "0x$PFBUS"

SYS="/sys/bus/pci/devices/0000:$PFBUS:00.0"
SUS="/sus/bus/pci/devices/0000:$PFBUS:00.0"

if ! mountpoint "$SUS"; then
    mkdir -p "$SUS" && mount --rbind "$SYS" "$SUS" && mount --make-rprivate "$SUS"
fi

if ! mountpoint "$SYS"; then
    mount -t tmpfs tmpfs "$SYS"
fi

find -P "$SUS" -mindepth 1 -maxdepth 1 -printf '%y|%p|%l|%P\n' | while IFS='|' read -r TYPE FILE LINK NAME; do
    if [[ -e "$SYS/$NAME" ]]; then continue; fi
    case "$TYPE" in
        l) ln -s "$SYS/$LINK" "$SYS/$NAME" ;;
        d) mkdir "$SYS/$NAME" && mount --bind "$FILE" "$SYS/$NAME" ;;
        f) touch "$SYS/$NAME" && mount --bind "$FILE" "$SYS/$NAME" ;;
    esac
done

if ! [[ -e "$SYS/net" ]]; then
    ln -s "/sys/bus/netdevsim/devices/netdevsim$IID/net" "$SYS/net"
fi
BASH

# ---

install -o 0 -g 0 -m u=rw,g=r /dev/fd/0 -D /etc/systemd/system/systemd-udevd.service.d/override.conf <<'INI'
[Service]
PrivateMounts=no
MountFlags=shared
SystemCallFilter=
INI

systemctl daemon-reload
systemctl restart systemd-udevd.service

install -o 0 -g 0 -m u=rw,go=r /dev/fd/0 "/etc/udev/rules.d/98-switchdevmock-$PFBUS.rules" <<EOF
SUBSYSTEM=="net", ACTION=="add", ENV{ID_NET_DRIVER}=="netdevsim", ENV{ID_NET_NAME_PATH}=="eni${IID}np*", \\
    NAME="%E{ID_NET_NAME_PATH}"

SUBSYSTEM=="pci", ACTION=="add", ENV{DRIVER}=="virtio-pci", ENV{ID_PATH}=="pci-0000:$PFBUS:00.1", \\
    RUN+="/var/tmp/switchdevmock-netdevsim.sh $PFBUS", \\
    RUN+="/var/tmp/switchdevmock-pci.sh $PFBUS"
EOF

udevadm control --reload-rules
