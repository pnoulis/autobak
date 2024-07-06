#!/bin/bash

usage() {
    cat<<EOF
NAME
    ${0} - Appends a new host into hostsfile (by default /etc/hosts)

SYNOPSIS
    ${0} {IP_address} {canonical_hostname} [aliases...]

    --hostsfile <hostsfile>, --hostsfile=<hostsfile>
      Specify a different hostsfile other than /etc/hosts to append the
      HOST at.

    -f, --force
      If the HOST to be appended already exists, this forces the program
      to replace all existing instances with the new HOST.

    --host-syntax, --host-syntax=[ip,hostname,ip+hostname]
      Describes what constitutes a HOST.
      In the case of /ip/ the matching host pattern includes only IP_address.
      In the case of /hostname/ the pattern includes only canonical_hostname
      In the case of /ip+hostname/ the partern includes both IP_address and canonical_hostname

    -N, --dry-run
      Does not modify the hostsfile, instead it writes its output to stdout.

DESCRIPTION
    ${0} appends a new line representing a HOST in the specified hosts
    file. The syntax of a HOST is described in '$(man 5 hosts)'.

SEE ALSO
    hosts(5), hostname(1), hostname(7)
EOF
}

# bash
set -o errexit

# Options
hostsfile=/etc/hosts
host_syntax=ip+hostname
force=false
dryrun=false
debug=false

# Constants
AUTO_MSG="${0}: AUTO UPDATE ->"
SED=/usr/bin/sed
GREP=/usr/bin/grep

main() {
    parse_args "$@" >/dev/stdout
    set -- "${POSARGS[@]}"

    local ip=$1
    local hostname=$2
    local aliases=${@:3}
    make_host

    debugv hostsfile
    debugv ip
    debugv hostname
    debugv aliases
    debugv host
    false ip && fatal "Missing 1st argument -> IP_address"
    false hostname && fatal "Missing 2nd argument -> canonical_hostname"

    print "Attempting to update ${hostsfile}"

    [[ ! -f "${hostsfile:-}" ]] && fatal "Missing hosts file -> '${hostsfile}'"
    [[ ! -w "${hostsfile}" ]] && fatal "Missing write permission -> '${hostsfile}'"
    if ! host_exists; then
        add_host
    else
        print "Host already exists -> ${host}"
        false force && exit 0
        delete_host
        add_host
    fi

    print "Successfully updated ${hostsfile}"
}

make_host() {
    case "$host_syntax" in
        ip)
            host="${ip}"
            ;;
        hostname)
            host="${hostname}"
            ;;
        ip+hostname)
            host="${ip} ${hostname}"
            ;;
        *)
            fatal "Unrecognized host syntax -> '${host_syntax}'"
    esac
}
host_exists() {
    $GREP --quiet "${host}" "$hostsfile"
}

add_host() {
    print "Adding new host -> ${ip} ${hostname} ${aliases}"
    if true dryrun; then
        echo -e "\n# ${AUTO_MSG} $(date)\n${ip} ${hostname} ${aliases}"
    else
        echo -e "\n# ${AUTO_MSG} $(date)\n${ip} ${hostname} ${aliases}" >> "$hostsfile"
    fi
}

delete_host() {
    print "Deleting host -> ${host}"
    if true dryrun; then
        sed --null-data \
            --regexp-extended \
            "s#^(.*)\\n\# ${AUTO_MSG//./\.}[^\\n]*\\n${host}[^\\n]*\\n?(.*)\$#\1\2#" \
            "$hostsfile"
    else
        sed --null-data --in-place \
            --regexp-extended \
            "s#^(.*)\\n\# ${AUTO_MSG//./\.}[^\\n]*\\n${host}[^\\n]*\\n?(.*)\$#\1\2#" \
            "$hostsfile"
    fi
}

parse_args() {
    declare -ga POSARGS=()
    _param=yolo
    while (($# > 0)); do
        case "${1:-}" in
            --hostsfile | --hostsfile=*)
                parse_param "$@" || shift $?
                eval hostsfile="$_param"
                ;;
            -f | --force)
                force=true
                ;;
            --host-syntax | --host-syntax=*)
                parse_param "$@" || shift $?
                host_syntax="$_param"
                ;;
            -D | --debug)
                debug=true
                ;;
            -N | --dry-run)
                dryrun=true
                ;;
            -h | --help)
                usage
                exit 0
                ;;
            -v | --version)
                echo $VERSION
                ;;
            -[a-zA-Z][a-zA-Z]*)
                local i="${1:-}"
                shift
                local rest="$@"
                set --
                for i in $(echo "$i" | grep -o '[a-zA-Z]'); do
                    set -- "$@" "-$i"
                done
                set -- $@ $rest
                continue
                ;;
            --)
                shift
                POSARGS+=("$@")
                ;;
            -[a-zA-Z]* | --[a-zA-Z]*)
                fatal "Unrecognized argument ${1:-}"
                ;;
            *)
                POSARGS+=("${1:-}")
                ;;
        esac
        shift
    done
}

parse_param() {
    _param=
    local param arg
    local -i toshift=0

    if (($# == 0)); then
        return $toshift
    elif [[ "$1" =~ .*=.* ]]; then
        param="${1%%=*}"
        arg="${1#*=}"
    elif [[ "${2-}" =~ ^[^-].+ ]]; then
        param="$1"
        arg="$2"
        ((toshift++))
    fi


    if [[ -z "${arg-}" && ! "${OPTIONAL-}" ]]; then
        fatal "${param:-$1} requires an argument"
    fi

    _param="${arg:-}"
    return $toshift
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

print() {
    echo -e "${0}: $@"
}

debugv() {
    if true debug; then
        echo $1:"${!1}"
    else
        return 0
    fi
}

fatal() {
    print "$@"
    exit 1
}


main "$@"
