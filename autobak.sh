#!/usr/bin/env bash

# Log
exec > >(tee -a "/var/local/cron/autobak.log") 2>&1
printf "\n\n[%s]\n" "$(date)"

# Exit on error
set -o errexit

# Arguments
hdd_id=bak1
source_user=pnoul

usage() {
    cat<<EOF
Usage: ${0} [OPTION]...
EOF
}

main() {
    parse_args "$@"
    set -- "${POSARGS[@]}"

    # Gather target storage medium information
    debugv hdd_id
    parlabel=$hdd_id
    debugv parlabel
    pardevpath=$(realpath -e /dev/disk/by-partlabel/${parlabel})
    debugv pardevpath
    partype=$(lsblk --noheadings --nodeps -o PARTTYPE ${pardevpath})
    debugv partype
    parname="$(lsblk -dno PARTTYPENAME ${pardevpath})"
    debugv parname
    tbltype="$(lsblk -dno PTTYPE ${pardevpath})"
    debugv tbltype
    hdd=${parlabel}:${pardevpath}
    debug hdd

    # Mount the hard drive
    mountpoint="$(lsblk -dno MOUNTPOINT ${pardevpath})"
    if [[ "$mountpoint" == "" ]]; then
        echo "Attempting to mount ${hdd}"
        mountpoint=/mnt/${parlabel}
        if findmnt --noheadings --mountpoint ${mountpoint} &>/dev/null; then
            fatal "Unfree mountpoint:${mountpoint}"
        fi
        mount --verbose --mkdir --target=${mountpoint} ${pardevpath}
    fi
    debugv mountpoint

    # Rsync everything under /home/{target_user}
    debugv source_user
    source_path=/home/${source_user}
    debugv source_path
    hostname=$(hostname)
    debugv hostname
    destination_path=${mountpoint}/${source_user}@${hostname}
    debugv destination_path
    rsync --cvs-exclude --archive --human-readable \
          --mkpath --verbose \
          ${source_path} ${destination_path}/
    umount --verbose ${mountpoint}
}


parse_args() {
    declare -ga POSARGS=()
    while (($# > 0)); do
        case "${1:-}" in
            -h | --help)
                usage
                exit 0
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

    echo "${arg:-}"
    return $toshift
}

quote() {
    echo \'"$@"\'
}

debug() {
    [ ! $DEBUG ] && return
    echo "$@" >&2
}

fatal() {
    echo $0: "$@" >&2
    exit 1
}

debugv() {
    echo $1:"${!1}"
}


main "$@"
