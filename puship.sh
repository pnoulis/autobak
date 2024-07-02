#!/bin/bash

set -o errexit

CURL=/usr/bin/curl
SSH=/usr/bin/ssh
IP=/usr/bin/ip
PULLIP=/home/pnoul/usr/src/pnoul/backup/pullip.sh

USERCONFROOTDIR=.
CONFIG_FILENAME=puship.conf
REMOTE_SERVER_IP=159.89.21.248
REMOTE_SERVER_HOSTNAME=localhost
REMOTE_SERVER_LOGIN=pnoul
REMOTE_SERVER_URI=${REMOTE_SERVER_LOGIN}@${REMOTE_SERVER_HOSTNAME}
HOME_SERVER_HOSTNAME_ALIAS=home_server
HOSTSFILE=~/hosts

main() {
    print "Attempting to distribute IP..."
    home_server_ip_wan=$(get_router_wan_ip)
    home_server_ip_lan=$(get_host_ip)
    home_server_hostname=$(hostname)
    run_pullip
    print "Done"
}

debugv() {
    echo $1:"${!1}"
}

fatal() {
    echo "$0:" "$@"
    exit 1
}

print() {
    echo -e "${0}: $@"
}

read_config() {
    for config in ${SYSCONFDIR}/puship.conf ${HOME}/${CONFIG_FILENAME}; do
        echo "Attempting to read configuration file: ${config}"
        [[ ! -f $config_path ]] && fatal "Missing config file -> ${config}"
    done
}

run_pullip() {
    $SSH ${REMOTE_SERVER_URI} "${PULLIP} ${HOSTSFILE} ${home_server_ip_wan} ${home_server_hostname} ${HOME_SERVER_HOSTNAME_ALIAS}"
}

get_router_wan_ip() {
    echo $($CURL -s https://ipinfo.io/ip)
}

get_host_ip() {
    echo $($IP addr | grep -i 'wlo1' | awk '/inet/ {print $2}')
}

main
