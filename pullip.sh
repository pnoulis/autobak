#!/bin/bash

set -o errexit

SED=/usr/bin/sed
GREP=/usr/bin/grep

main() {
    local hostsfile=$1
    local ip=$2
    local hostname=$3
    local aliases=${@:4}


    [[ -z "${hostsfile}" ]] && fatal "Missing 1st argument -> \$hostsfile"
    [[ -z "${ip}" ]] && fatal "Missing 2nd argument -> \$ip"
    [[ -z "${hostname}" ]] && fatal "Missing 3rd argument -> \$hostname"

    print "Attempting to update ${hostsfile} -> ${ip} ${hostname} ${aliases}"
    [[ ! -f $hostsfile ]] && fatal "Missing hosts file -> ${hostsfile}"
    [[ ! -w $hostsfile ]] && fatal "Missing write permission -> ${hostsfile}"

    if ! $GREP --quiet $hostname $hostsfile; then
        print "\n${ip} ${hostname} ${aliases} # puship AUTO UPDATE: $(date) " >> $hostsfile
    else

        local current_ip=$($GREP $hostname $hostsfile | cut -d' ' -f1)
        if [[ "$current_ip" == "$ip" ]]; then
            print "${hostsfile} already contains the most up to date IP"
            exit 0
        fi

        $SED -E -i "s#^.*[[:space:]]?${hostname}.*\$#${ip} ${hostname} ${aliases} \# puship AUTO UPDATE: $(date) #" $hostsfile
    fi

    print "Successfully updated ${hostsfile}"
}

print() {
    echo -e "${0}: $@"
}

debugv() {
    echo $1:"${!1}"
}

fatal() {
    echo "$0:" "$@"
    exit 1
}

main "$@"
