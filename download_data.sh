#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

rev=${1:?}  #revolution rev{$i} ($i: 0-9)
scw=${2:-*}
local_data_root=${INTEGRAL_DATA:-${TMPDIR:-/tmp}/integral-data/}
data_kind=${data_kind:-cons}

echo "requested: rev: $rev scw: $scw"

secret=`cat /home/integral/.secret`

if [ "$data_kind" == "nrt" ]; then

    scw_data_root="$local_data_root/nrt/scw/"
    remote_data_root="pvphase/nrt/ops/scw/"

    mkdir -p $scw_data_root
    cd $scw_data_root

    echo "Data will be downloaded in:"
    pwd

    echo "-------------------------------------------------------"
    echo "Starting download of data from ${remote_data_root}"

    mkdir -vp $scw_data_root/$rev
    cd $scw_data_root/$rev
    #chmod -R +w $data_dir/$rev

    wget -m -nH --cut-dirs=6 ftp://$secret@isdcarc.unige.ch/$remote_data_root/$rev/$scw

    mkdir -p $scw_data_root/../aux/adp
    cd $scw_data_root/../aux/adp

    wget -m -nH --cut-dirs=7 ftp://$secret@isdcarc.unige.ch/arc/FTP/arc_distr/NRT/public/aux/adp/$rev*


    echo "Download of data from revolution ${rev} finished"
    echo "-------------------------------------------------------"

else
    echo "Data will be downloaded in:"

    scw_data_root=$local_data_root/rev_3/scw/
    mkdir -p $scw_data_root
    cd $scw_data_root
    pwd

    remote_data_root="/arc/rev_3/scw/"

    echo "-------------------------------------------------------"
    echo "Starting download of data from ${remote_data_root}"

    mkdir -p $scw_data_root/$rev
    chmod -R +w $scw_data_root/$rev/
    cd $scw_data_root/$rev

    pwd

    wget -m -nH --cut-dirs=6  ftp://$secret@isdcarc.unige.ch/$remote_data_root/$rev/$scw
    #wget -m -nH --cut-dirs=5 ftp://isdcarc.unige.ch/arc/FTP/arc_distr/CONS/public/scw/$rev/${scw:-*}

    #wget -m -nH --cut-dirs=4 ftp://isdcarc.unige.ch/arc/rev_3/scw/$rev/${scw:-*}/*


    mkdir -p $local_data_root/aux/adp                                                                                                                                                  
    cd $local_data_root/aux/adp                                                                                                                                                  

    wget -m -nH --cut-dirs=4 ftp://$secret@isdcarc.unige.ch/arc/rev_3/aux/adp/$rev*     

    echo "Download of data from revolution ${rev} finished"
    echo "-------------------------------------------------------"

fi

ls -l $scw_data_root/$rev/$scw/* 

[ "${filelist:-}" == "" ] || (ls $scw_data_root/$rev/$scw/* > $filelist)
