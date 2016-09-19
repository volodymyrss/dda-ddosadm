#!/bin/bash

rev=${1:?}  #revolution rev{$i} ($i: 0-9)

echo "Data will be downloaded in:"

data_dir=${INTEGRAL_DATA:?}/rev_3/scw/
cd $data_dir
pwd

arc=/arc/rev_3/scw/${rev}

echo "-------------------------------------------------------"
echo "Starting download of data from ${arc}"

mkdir -p $data_dir/$rev$i
chmod -R +w $data_dir/$rev$i/${scw:-*}
cd $data_dir/$rev$i
#/afs/in2p3.fr/throng/integral/ncftp/ncftp-3.2.2_64b/bin/ncftpget -u pi_ftp -p 0.511MeV -R -v isdcarc.unige.ch . ${arc}"/*0.0*"

pwd

#wget -m -nH --cut-dirs=5  ftp://pi_ftp:0.511MeV@isdcarc.unige.ch/$arc/rev.0*
#wget -m -nH --cut-dirs=5 -R "spi_oper.fits*" ftp://pi_ftp:0.511MeV@isdcarc.unige.ch/$arc/rev.0*
echo wget -m -nH --cut-dirs=5  ftp://pi_ftp:0.511MeV@isdcarc.unige.ch/$arc/${scw:-*}.0*
wget -m -nH --cut-dirs=5  ftp://pi_ftp:0.511MeV@isdcarc.unige.ch/$arc/${scw:-*}
#wget -m -nH --cut-dirs=5 ftp://isdcarc.unige.ch/arc/FTP/arc_distr/CONS/public/scw/$rev/${scw:-*}


wget -m -nH --cut-dirs=4 ftp://isdcarc.unige.ch/arc/rev_3/scw/$rev/${scw:-*}/*

#wget -m -nH --cut-dirs=5  ftp://pi_ftp:0.511MeV@isdcarc.unige.ch/$arc/*0078*0.0*
#wget -m -nH --cut-dirs=5 -R "spi_oper.fits*" ftp://pi_ftp:0.511MeV@isdcarc.unige.ch/$arc/*0078*0.0*

#cd $data_dir/../aux/adp                                                                                                                                                  

pwd
#wget -m -nH --cut-dirs=4 ftp://pi_ftp:0.511MeV@isdcarc.unige.ch/arc/rev_3/aux/adp/$rev*     
#wget -m -nH --cut-dirs=4 ftp://pi_ftp:0.511MeV@isdcarc.unige.ch/arc/rev_3/aux/adp/

echo "Download of data from revolution ${rev}${i} finished"
echo "-------------------------------------------------------"


