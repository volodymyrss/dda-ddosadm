icd savchenk/arc/integral/scw
cd /sps/integral/data/rev_3/scw

pwd
ipwd

for rev in $@; do
	while true; do
		completed=`ils savchenk/arc/integral/scw | grep \\.complete | wc -l`
		echo "found ${completed:=0} completed"
		if [ $completed -lt 5 ]; then
			echo "not enough completed"
			break
		else
			echo "too much already"
		fi
		sleep 5
	done
	
	iput -b -r -v  -f $rev $rev.incomplete | tee -a ~/projects/irods/deposit_log
	imv $rev.incomplete $rev.complete
done

