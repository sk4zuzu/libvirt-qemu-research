#!/usr/bin/env bash

: "${TAP_DEV:=$1}"

set -x -o errexit -o nounset

type -p basename bridge ip &>/dev/null

IFS='.' read -r STEM _ <<< "$(basename $0)"
IFS='-' read -r _ VLAN_ID BR_DEV ACTION _ <<< "$STEM"

[[ -n "$TAP_DEV" && -n "$BR_DEV" && -n "$VLAN_ID" && -n "$ACTION" ]]

case "$ACTION" in
    up)
        ip link set "$BR_DEV" type bridge vlan_filtering 1

        ip link set "$TAP_DEV" up

        ip link set "$TAP_DEV" master "$BR_DEV"

        bridge vlan add dev "$TAP_DEV" vid "$VLAN_ID"

        bridge vlan add dev "$BR_DEV" vid "$VLAN_ID" self

        if [[ ! -d "/sys/class/net/$BR_DEV.$VLAN_ID" ]]; then
            ip link add link "$BR_DEV" name "$BR_DEV.$VLAN_ID" type vlan id "$VLAN_ID"

            ip link set "$BR_DEV.$VLAN_ID" up

            ip addr add "10.3.$VLAN_ID.1/24" dev "$BR_DEV.$VLAN_ID"
        fi
        ;;
    down)
        if [[ -d "/sys/class/net/$TAP_DEV" ]]; then
            ip link set "$TAP_DEV" down

            ip link delete "$TAP_DEV"
        fi
        ;;
    *)
        exit 1
        ;;
esac
