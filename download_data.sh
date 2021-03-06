#!/bin/bash
#set -euo pipefail
IFS=$'\n\t'

set -x

export lockfile=$HOME/isdc-download-lock

function lock() {
	while [ -s $lockfile ]; do
		echo "found lockfile, waiting..."
		ls -l $lockfile
		sleep 1
	done
	echo $$ > $lockfile
}

function unlock() {
	rm -fv $lockfile
}

lock

trap unlock INT
trap unlock TERM
trap unlock EXIT

rev=${1:?revolution}  
scw=${2:-*}
local_data_root=${INTEGRAL_DATA:-${TMPDIR:-/tmp}/integral/data/rep_base_prod}
data_kind=${data_kind:-cons}

echo "requested: rev: $rev scw: $scw with data kind $data_kind"


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

[ -s $scw_data_root/$rev/$scw*/isgri_events.fits* ] && [ -s $scw_data_root/$rev/$scw*/swg.fits* ] && {
    echo "already found data"
    exit 0
}


echo "Data will be downloaded in:"
pwd

echo "-------------------------------------------------------"
echo "Starting download of data from ${remote_data_root}"

#if [ -s $scw_data_root/$rev/$scw/isgri_events.fits ] || [ -s $scw_data_root/$rev/$scw/isgri_events.fits.gz ]; then
#    exit
#fi

mkdir -vp $scw_data_root/$rev
cd $scw_data_root/$rev

#rm -fv ${rev}_revdir.tgz
#wget -c http://www.apc.univ-paris7.fr/Downloads/astrog/savchenk/archive_pack/${rev}_revdir.tgz
#tar xzvf ${rev}_revdir.tgz

echo "in the "`pwd`

export ssh_access_point=${ssh_access_point:-savchenk@login01.astro.unige.ch}

#wget -m -nH --reject-regex '.*log.*' -R '*txt' --cut-dirs=${cd_scw} ftp://isdcarc.unige.ch/$remote_data_root/$rev/rev.${scwver} ftp://isdcarc.unige.ch/$remote_data_root/$rev/$scw 

rsync -avu --exclude '*revno_*_log*' ${ssh_access_point}:/isdc/arc/rev_3/aux/adp/ref/ $local_data_root/aux/adp/ref/

echo "will get revdir..."
rsync -avu ${ssh_access_point}:/isdc/${remote_data_root}/${rev}/rev.${scwver}/ $local_data_root/scw/${rev}/rev.${scwver}/
rsync -avu ${ssh_access_point}:/isdc/${remote_data_root}/${rev}/${scw}.${scwver} $local_data_root/scw/${rev}

rsync -avu ${ssh_access_point}:/isdc/${remote_aux_root}/aux/adp/${rev}.${scwver}/ $local_data_root/aux/adp/${rev}.${scwver}/

chmod +rX -R $local_data_root/aux/adp/${rev}.${scwver}/ $local_data_root/scw/${rev} $local_data_root/scw/${rev}/rev.${scwver}/

mkdir -p $scw_data_root/../aux/adp
cd $scw_data_root/../aux/adp
chmod +w .

#rm -fv ${rev}_auxadpdir.tgz
#wget -c http://www.apc.univ-paris7.fr/Downloads/astrog/savchenk/archive_pack/${rev}_auxadpdir.tgz
#tar xzvf ${rev}_auxadpdir.tgz


#wget -c -m -nH --cut-dirs=${cd_aux} -R '*txt' ftp://isdcarc.unige.ch/$remote_aux_root/aux/adp/${rev}.${scwver}


echo "Download of data from revolution ${rev} finished"
echo "-------------------------------------------------------"

ls -l $scw_data_root/$rev/$scw*/* 

[ "${filelist:-}" == "" ] || (ls $scw_data_root/$rev/$scw*/* > $filelist)

unlock

[ -s $scw_data_root/$rev/$scw*/isgri_events.fits* ] || exit 1
[ -s $scw_data_root/$rev/$scw*/swg.fits* ] || exit 1


