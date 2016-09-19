source $THRONG_DIR/site.sh

rev=${1:?}


cd $INTEGRAL_DATA/scw

csfile=$PWD/checksums

echo -n "`date +%s` $rev `du -s $rev` " >> $csfile

a=`date +%s`

(cd $rev; find  -type f -print0  | xargs -0 sha1sum | sort | sha1sum) >> $csfile

a="$a `date +%s`"

echo "`date` checksum of $rev ($a) `hostname` (`tail -1 $csfile`)" >> $THRONG_DIR/common_logs/data_access/checksums/log
