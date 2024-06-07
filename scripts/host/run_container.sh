#!/bin/bash
#
# ABSTRACT: Script para executar o container 
#
# - O nome do container e a porta serao definidos pelo argumento da linha de comando
# - O container sera executado em background (--detach)
#
# Porque convinha que aquele, por cuja causa e por quem todas as coisas
# existem, conduzindo muitos filhos a gloria, aperfeicoasse, por meio de
# sofrimentos, o Autor da salvacao deles. Hebreus 2.10

# Functions >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

function main () {

    # Parameters >>>>>>>>>>>
    container_type="$1"
    container_memory="$2"
    image_name="$3"
    run_policy="$4"
    container_name="$5"
    # <<<<<<<<<<<<<<<<<<<<<<<

    docker inspect --type=image $image_name
    if [ "$?" != "0" ]; then
        echo "ERRO: Imagem ${image_name} nao localizada..."
        exit 1
    fi

    host_name=$(hostname)
    memory_size="$container_memory"
    memory_swappiness=0
    app_root_dir=$(get_root_dir)
    nr='/nr/nx'

    if [ ! -e "$app_root_dir" ]; then
        echo "ERRO: Nao encontrou o dir ROOT: ${app_root_dir}"
        exit 1
    fi            

    case "$container_type" in
        dev)
            shared_memory_size='1g'
            conf_file="${app_root_dir}/etc/nginx.dev.conf"
            ;;
        *)
            echo "ERRO: Opcao desconhecida: $container_type"
            echo "ERRO: Nao subiu o container"
            ;;
    esac

    if [ ! -e "$conf_file" ]; then
        echo "ERRO: Nao encontrou o arquivo CONF: ${conf_file}"
        exit 1
    fi

    exec docker run \
        --security-opt='seccomp=unconfined' \
        --security-opt='apparmor=unconfined' \
        --memory="$memory_size" \
        --memory-swap="$memory_size" \
        --memory-swappiness="$memory_swappiness" \
        --shm-size="$shared_memory_size" \
        --volume="${app_root_dir}/etc/csh.cshrc":'/etc/csh.cshrc' \
        --volume="$conf_file":'/etc/nginx/nginx.conf:ro' \
        --volume="${app_root_dir}/etc/certs":'/etc/nginx/certs' \
        --volume="$nr":'/nr' \
        --volume="${app_root_dir}":"${app_root_dir}" \
        --volume="/home/circuibras/storage":"/usr/share/nginx/html/storage" \
        --net='host' \
        --hostname="$host_name" \
        --ipc='host' \
        --init \
        --detach \
        "$run_policy" \
        --name="$container_name" \
        "$image_name"
}


function get_root_dir () {
    script_path="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
    echo "$(dirname $(dirname ${script_path}))"
}


function usage() { 
    echo "Usage: $0 [-n <container name>] [-t <dev|pd|test>] [-m <memory usage percentage: 10, 75...>] [-i <image>] [-r]" 1>&2; 
    exit 1; 
}

# <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

# Main >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

run_policy_arg='--restart=always'
while getopts ":n:p:t:m:i:r" o; do
    case "${o}" in
        n)
            container_name=${OPTARG}
            ;;
        t)
            t=${OPTARG}
            ((t == "dev" || t == "test" || t == "pd")) || usage
            ;;
        m)
            memory_percentage=${OPTARG}
            echo "$memory_percentage" | egrep '^[0-9]+[.]?[0-9]*$' >/dev/null
            test $? -eq 0 || usage            
            if [ $(echo "($memory_percentage < 1) || ($memory_percentage > 99.0)" | bc -l) -eq 1 ]; then
                echo "Range invalido para a memoria: ${memory_percentage}"
                usage
            fi
            physical_memory=$(free -g | grep -oP '\d+' | head -n 1)
            container_memory_value=$(echo "scale=2; ${physical_memory} * (${memory_percentage} / 100.0)" | bc -l | sed 's/^\./0./')
            container_memory="${container_memory_value}g"
            ;;
        i)
            i=${OPTARG}
            ;;
        r)
            run_policy_arg='--rm'
            ;;
        *)
            usage
            ;;
    esac
done
shift $((OPTIND-1))

if [ -z "${container_name}" ] || \
    [ -z "${t}" ] || \
    [ -z "${container_memory}" ] || \
    [ -z "${i}" ] || \
    [ -z "${run_policy_arg}" ] ; then

    usage
fi

main $t $container_memory $i $run_policy_arg $container_name

# <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

# EOF
