#!/bin/bash
#
# ABSTRACT: Script para deploy do app
#
# "Mas ele foi traspassado pelas nossas transgressoes e moido pelas nossas
# iniquidades; o castigo que nos traz a paz estava sobre ele, e pelas
# suas pisaduras fomos sarados." Isaias 53.5


# Functions >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

function get_root_dir () {
    script_path="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
    echo "$(dirname $(dirname ${script_path}))"
}


function main () {
    app_root_dir=$(get_root_dir)
    rsync \
        -av \
        --delete \
        --exclude '.git' \
        --exclude '.gitignore' \
        --exclude '.vstags' \
        --exclude '.vscode' \
        --exclude 'tmp' \
        --exclude 'README.md' \
        "${app_root_dir}/" "${1}@${2}:${app_root_dir}/"
}


function usage() { 
    echo "Usage: $0 [-h <HOST>] [-u <USER>]" 1>&2;
    exit 1; 
}

# <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<


# Main >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

while getopts ":h:u:" o; do
    case "${o}" in
        h)
            h=${OPTARG}
            ;;
        u)
            u=${OPTARG}
            ;;
        *)
            usage
            ;;
    esac
done
shift $((OPTIND-1))

if [ -z "${h}" ] || [ -z "${u}" ] ; then
    usage
fi

main $u $h

# <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

# EOF
