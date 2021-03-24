#!/bin/bash
#set -euo pipefail
IFS=$'\n\t'

set -e -o pipefail

export rev=${1:?revolution}  
export scw=${2:-*}

echo -e "\033[33mscript-wide data selection: rev=$rev scw=$scw\033[0m"

export INTEGRAL_DATA=${INTEGRAL_DATA:-${TMPDIR:-/tmp}/integral}

echo -e "\033[33mscript-wide INTEGRAL_DATA store: $INTEGRAL_DATA\033[0m"

poke_file=${INTEGRAL_DATA}/poke-$$-$RANDOM

if touch $poke_file; then
    echo "can write to $INTEGRAL_DATA, good"
    rm -fv $poke_file
else
    echo -e "\033[31mcan NOT write to $INTEGRAL_DATA, NOT good\033[0m"
    exit 1
fi

export local_data_root=${INTEGRAL_DATA}/
export scw_data_root="$local_data_root/scw"

echo "local_data_root=${local_data_root}"
echo "scw_data_root=${scw_data_root}"

export lockfile=$HOME/isdc-download-lock

function lock() {
	while [ -s $lockfile ]; do
		echo "found lockfile, waiting..."
		ls -l $lockfile
		sleep 1
	done
        echo "locked-by-$$-$(date)" > $lockfile
}

function unlock() {
	[ -s $lockfile ] && rm -fv $lockfile
}


function download_no_matter_what_it_takes() {
    echo > stats.yaml

    data_kind=${data_kind:-cons}

    echo -e "\033[0mrequested: rev=$rev scw=$scw with data kind $data_kind"

    exit_if_already_have

    if [ ${dry_run:-no} == "yes" ]; then
        echo "dry run!"
    else
        if [ "${DDA_ALLOW_SSH:-no}" == "yes" ]; then
            download_isdc_ssh
        else
            download_heasarc
        fi

        echo "Download of data from revolution ${rev} finished"
        echo "-------------------------------------------------------"

        ls -l $scw_data_root/$rev/$scw*/* 

        [ "${filelist:-}" == "" ] || (ls $scw_data_root/$rev/$scw*/* > $filelist)
    fi
}

function exit_if_already_have() {
    mkdir -p $scw_data_root
    cd $scw_data_root

    if [ -s $scw_data_root/$rev/$scw*/isgri_events.fits* ] && [ -s $scw_data_root/$rev/$scw*/swg.fits* ]; then
        echo -e "\033[32malready found data! Download canceled\033[0m"
        exit 0
    fi
}

# https://www.isdc.unige.ch/integral/archive#DataRelease
# some methods of querying data need interaction by email, which is not suitable here
# luckily, heasarc does not do that
# 


function download_heasarc() {
    flag=""

    echo -e "\033[31mdownload_heasarc_t_start: $(date +%s)\033[0m" >> stats.yaml
    cd $local_data_root
    

    #for sub_path in "scw/${rev}/rev.001" "aux/adp/ref" "scw/${rev}/${scw}" "aux/adp/${rev}.001"; do
    for sub_path in "scw/${rev}/rev.001" "scw/${rev}/${scw}" "aux/adp/${rev}.001"; do
        echo -e "\033[32m downloading ${sub_path}\033[0m"

        completion_marker=${sub_path}/completed

        if [ -s $completion_marker ]; then
            echo -e "\033[31m already available ${sub_path}, found $PWD/$completion_marker\033[0m"
            # TODO: add expiration? aux/adp/ref will expire sometimes. other things - rarely
        else
            echo -e "\033[1;33m actually downloading ${sub_path}\033[0m"
            #--show-progress # not in some
            wget \
                -q \
                --no-parent -nH --no-check-certificate --cut-dirs=3 \
                -r -l0 -c -N -np -R 'index*' -R '.*log.*' -R '*txt' \
                -R 'raw' \
                -erobots=off --retr-symlinks \
                    https://heasarc.gsfc.nasa.gov/FTP/integral/data/$sub_path/
            # raw maybe needed, I think not?
            echo "$HOSTNAME $DATE" > $completion_marker
            echo -e "\033[1;32m DONE downloading ${sub_path}\033[0m"
        fi
    done
    echo "download_heasarc_t_stop: $(date +%s)" >> stats.yaml
    cd $INTEGRAL_DATA
}

function test_isgri_events() {
    echo "not complete"
    if [ -s $scw_data_root/$rev/$scw/isgri_events.fits ] || [ -s $scw_data_root/$rev/$scw/isgri_events.fits.gz ]; then
        exit 1
    fi
}
    
function download_aux_bundle() {
    echo "not complete"
    rm -fv ${rev}_revdir.tgz
    wget -c http://www.apc.univ-paris7.fr/Downloads/astrog/savchenk/archive_pack/${rev}_revdir.tgz
    tar xzvf ${rev}_revdir.tgz
}

function download_isdc_ssh() {
    if [ "$data_kind" == "nrt" ]; then
        remote_data_root="pvphase/nrt/ops/scw"
        remote_aux_root="arc/FTP/arc_distr/NRT/public"
        scwver="000"
        cd_scw=6
        cd_aux=7
    else
        remote_data_root="arc/rev_3/scw"
        remote_aux_root="arc/rev_3"
        scwver="001"
        cd_scw=4
        cd_aux=4
    fi



    echo "Data will be downloaded in:"
    pwd

    echo "-------------------------------------------------------"
    echo "Starting download of data from ${remote_data_root}"


    mkdir -vp $scw_data_root/$rev
    cd $scw_data_root/$rev


    echo "in the "`pwd`

    export ssh_access_point=${ssh_access_point:-savchenk@transfer01.isdc.unige.ch}


    echo -e "\033[32m downloading arc/rev_3/aux/adp/ref\033[0m"
    mkdir -pv $local_data_root/aux/adp/ref
    rsync -avu --exclude '*revno_*_log*' ${ssh_access_point}:/isdc/arc/rev_3/aux/adp/ref/ $local_data_root/aux/adp/ref/

    echo -e "\033[32m downloading ${rev}/rev.${scwver}/\033[0m"
    mkdir -pv $local_data_root/scw/${rev}/rev.${scwver}/
    rsync -avu --exclude 'raw' ${ssh_access_point}:/isdc/${remote_data_root}/${rev}/rev.${scwver}/ $local_data_root/scw/${rev}/rev.${scwver}/

    echo -e "\033[32m downloading aux/adp/${rev}.${scwver}\033[0m"
    mkdir -pv $local_data_root/aux/adp/${rev}.${scwver}/
    rsync -avu ${ssh_access_point}:/isdc/${remote_aux_root}/aux/adp/${rev}.${scwver}/ $local_data_root/aux/adp/${rev}.${scwver}/
    
    echo -e "\033[32m downloading ${rev}/${scw}.${scwver}\033[0m"
    mkdir -pv $local_data_root/scw/${rev}/
    rsync -avu ${ssh_access_point}:/isdc/${remote_data_root}/${rev}/${scw}.${scwver} $local_data_root/scw/${rev}

    chmod +rX -R $local_data_root/aux/adp/${rev}.${scwver}/ $local_data_root/scw/${rev} $local_data_root/scw/${rev}/rev.${scwver}/

    mkdir -p $scw_data_root/../aux/adp
    cd $scw_data_root/../aux/adp
    chmod +w .



}

function download_ic_isdc_ssh() {
    icversion=${1:-default}

    export ssh_access_point=${ssh_access_point:-savchenk@transfer01.isdc.unige.ch}

    echo -e "\033[32m downloading IC\033[0m"
    mkdir -pv $local_data_root/ic/
    rsync -avu --exclude '*revno_*_log*' ${ssh_access_point}:/unsaved/astro/savchenk/osa11/ic-collection/$icversion/ic/ $local_data_root/ic/

    echo -e "\033[32m downloading IDX\033[0m"
    mkdir -pv $local_data_root/idx/
    rsync -avu --exclude '*revno_*_log*' ${ssh_access_point}:/unsaved/astro/savchenk/osa11/ic-collection/$icversion/idx/ $local_data_root/idx/

    chmod +rX -R $local_data_root/{ic,idx}

    mkdir -p $scw_data_root/../aux/adp
    cd $scw_data_root/../aux/adp
    chmod +w .

}

function download_cat_isdc_ssh() {
    export ssh_access_point=${ssh_access_point:-savchenk@transfer01.isdc.unige.ch}

    echo -e "\033[32m downloading CAT/HEC\033[0m"
    mkdir -pv $local_data_root/cat/hec
    rsync -avu  ${ssh_access_point}:/isdc/arc/rev_3/cat/hec/ $local_data_root/cat/hec/

    chmod +rX -R $local_data_root/{ic,idx}

    mkdir -p $scw_data_root/../aux/adp
    cd $scw_data_root/../aux/adp
    chmod +w .

}

function download_ftp() {
    echo "not complete"
    #wget -m -nH --reject-regex '.*log.*' -R '*txt' --cut-dirs=${cd_scw} ftp://isdcarc.unige.ch/$remote_data_root/$rev/rev.${scwver} ftp://isdcarc.unige.ch/$remote_data_root/$rev/$scw 
    #wget -c -m -nH --cut-dirs=${cd_aux} -R '*txt' ftp://isdcarc.unige.ch/$remote_aux_root/aux/adp/${rev}.${scwver}
}

function test_at_exit() {
    [ -s $scw_data_root/$rev/$scw*/isgri_events.fits* ] || exit 1
    [ -s $scw_data_root/$rev/$scw*/swg.fits* ] || exit 1
}


### do this!

lock

trap unlock INT
trap unlock TERM
trap unlock EXIT

if [ "$rev" == "ic" ]; then
    download_ic_isdc_ssh
elif [ "$rev" == "cat" ]; then
    download_cat_isdc_ssh
else
    download_no_matter_what_it_takes
fi

unlock

test_at_exit

