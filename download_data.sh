#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

rev=${1:?}  #revolution rev{$i} ($i: 0-9)
scw=${2:-*}
local_data_root=${INTEGRAL_DATA:-${TMPDIR:-/tmp}/integral-data/}
data_kind=${data_kind:-cons}

echo "requested: rev: $rev scw: $scw"

scw_data_root="$local_data_root/scw"

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

mkdir -p $scw_data_root
cd $scw_data_root

echo "Data will be downloaded in:"
pwd

echo "-------------------------------------------------------"
echo "Starting download of data from ${remote_data_root}"

#if [ -s $scw_data_root/$rev/$scw/isgri_events.fits ] || [ -s $scw_data_root/$rev/$scw/isgri_events.fits.gz ]; then
#    exit
#fi

mkdir -vp $scw_data_root/$rev
cd $scw_data_root/$rev

wget -m -nH --reject-regex '.*log.*' -R '*txt' --cut-dirs=${cd_scw} ftp://isdcarc.unige.ch/$remote_data_root/$rev/rev.${scwver} ftp://isdcarc.unige.ch/$remote_data_root/$rev/$scw 

mkdir -p $scw_data_root/../aux/adp
cd $scw_data_root/../aux/adp
chmod +w .

echo "will get revdir..."

wget -m -nH --cut-dirs=${cd_aux} -R '*txt' ftp://isdcarc.unige.ch/$remote_aux_root/aux/adp/${rev}.${scwver}


echo "Download of data from revolution ${rev} finished"
echo "-------------------------------------------------------"

ls -l $scw_data_root/$rev/$scw/* 

[ "${filelist:-}" == "" ] || (ls $scw_data_root/$rev/$scw/* > $filelist)
