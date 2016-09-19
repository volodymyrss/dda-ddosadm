sd=savchenk/arc/integral/scw/
icd $sd
ipwd
pwd


while true; do
    ready=`ils $sd | awk '/\.complete/ {print $2}'`
    
    echo "ready: $ready"
    
    for r in $ready; do
        echo "can get $r"

        iget -r -f -v $r | tee -a ~/projects/irods/retrieve_log
        irm -rf $r
    done

    sleep 5
done
