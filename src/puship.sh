#!/bin/bash

usage() {
    cat<<EOF
NAME
    ${0} - Shares the WAN IP of the network gateway with a remote host.

SYNOPSIS
    ${0} {remote_host_uri}
EOF
}

set -o errexit

CURL=IN_CURL
SSH=IN_SSH
IP=IN_IP
EDITHOSTS=IN_EDITHOSTS
REMOTE_URI=IN_PROXY_LOGIN_USERNAME@IN_PROXY_HOSTNAME
REMOTE_PORT=IN_PROXY_PORT
REMOTE_HOSTSFILE=IN_PROXY_HOSTSFILE
LOCAL_HOSTNAME=IN_HOST_BACKUP_HOSTNAME
LOCAL_ALIASES=IN_HOST_BACKUP_ALIASES
DEBUG=

main() {
    print "[$(date)] Attempting to push IP..."
    local_ip_wan="$(get_router_wan_ip)"
    local_ip_lan="$(get_host_ip)"
    local_hostname="$(hostname)"

    debugv REMOTE_URI
    debugv REMOTE_HOSTSFILE
    debugv LOCAL_HOSTNAME
    debugv LOCAL_ALIASES
    debugv local_ip_wan
    debugv local_ip_lan
    debugv local_hostname

    update_remote_hostsfile
}

update_remote_hostsfile() {
    $SSH -p "$REMOTE_PORT" "$REMOTE_URI" \
         "$EDITHOSTS '${local_ip_wan}' '${local_hostname}' \
         '${LOCAL_HOSTNAME}' '${LOCAL_ALIASES}' \
         --hostsfile='$REMOTE_HOSTSFILE'"
}

get_router_wan_ip() {
    echo "$($CURL -s https://ipinfo.io/ip)"
}

get_host_ip() {
    echo "$($IP addr | grep -i 'wlo1' | awk '/inet/ {print $2}')"
}

true() {
    if [[ "${!1}" == true ]] || [[ "${!1}" != false && "${!1}" != '' ]]; then
        return 0
    else
        return 1
    fi
}
false() {
    if [[ "${!1}" == false || "${!1}" == "" ]]; then
        return 0
    else
        return 1
    fi
}
debugv() {
    if true DEBUG; then
        echo $1:"${!1}"
    else
        return 0
    fi
}
print() {
    echo -e "${0}: $@"
}
fatal() {
    print "$@"
    exit 1
}
main "$@"
