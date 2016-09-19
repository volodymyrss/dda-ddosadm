#!/bin/bash

rev=${1:?}  #revolution rev{$i} ($i: 0-9)

echo "Data will be downloaded in:"

data_dir=/Integral2/data/nrt/scw/
cd $data_dir
pwd

echo "-------------------------------------------------------"
echo "Starting download of data from ${arc}"

mkdir -vp $data_dir/$rev$i
#chmod -R +w $data_dir/$rev$i
cd $data_dir/
pwd
#/afs/in2p3.fr/throng/integral/ncftp/ncftp-3.2.2_64b/bin/ncftpget -u pi_ftp -p 0.511MeV

#rsync -lrtv  --exclude "raw" isdcarc.unige.ch::arc/FTP/arc_distr/NRT/public/scw/$rev/ $rev
#rsync -lrtv --exclude "spi_oper*" --exclude "raw" isdcarc.unige.ch::arc/FTP/arc_distr/NRT/public/scw/$rev/ $rev

    arc="pvphase/nrt/ops/scw/$rev"

    #wget -m -nH --cut-dirs=4 -R "spi_oper.fits*" ftp://pi_ftp:0.511MeV@isdcarc.unige.ch/$arc/rev.0*
    wget -m -nH --cut-dirs=4 ftp://pi_ftp:0.511MeV@isdcarc.unige.ch/$arc/${scw:-*}
    #wget -m -nH --cut-dirs=4 -R "spi_oper.fits*" ftp://pi_ftp:0.511MeV@isdcarc.unige.ch/$arc/*004600*

    cd $data_dir/../aux/adp                                                                                                                                                 
    #wget -m -nH --cut-dirs=5 -R "spi_oper.fits*" ftp://pi_ftp:0.511MeV@isdcarc.unige.ch/pvphase/nrt/ops/aux/adp/$rev*
    #wget -m -nH --cut-dirs=5 -R "spi_oper.fits*" ftp://pi_ftp:0.511MeV@isdcarc.unige.ch/pvphase/nrt/ops/aux/adp/ref

    #rsync -lrtv  isdcarc.unige.ch::arc/FTP/arc_distr/NRT/public/aux/adp/$rev.000 aux/adp/$r

    wget -m -nH --cut-dirs=7 ftp://pi_ftp:0.511MeV@isdcarc.unige.ch/arc/FTP/arc_distr/NRT/public/aux/adp/$rev*



echo "Download of data from revolution ${rev}${i} finished"
echo "-------------------------------------------------------"



