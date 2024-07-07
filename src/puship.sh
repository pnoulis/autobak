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

CURL=/usr/bin/curl
SSH=/usr/bin/ssh
IP=/usr/bin/ip

main() {
    local remote_host_uri="$1"
    local edithosts_args="${@:2}"

    print "[$(date)] Attempting to push IP..."
    home_server_ip_wan=$(get_router_wan_ip)
    home_server_ip_lan=$(get_host_ip)
    home_server_hostname=$(hostname)
    run_edithosts
}

run_edithosts() {
    $SSH "$remote_host_uri" \
         "edithosts ${home_server_ip_wan} ${home_server_hostname}"
}

get_router_wan_ip() {
    echo $($CURL -s https://ipinfo.io/ip)
}

get_host_ip() {
    echo $($IP addr | grep -i 'wlo1' | awk '/inet/ {print $2}')
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
    if true debug; then
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


main
