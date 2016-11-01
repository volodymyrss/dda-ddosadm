#!/bin/env python

import os
import tempfile

from dlogging import logger,logging

def ensure_data(kind="any",scw=None):
    

    if kind=="any":
        r=ensure_data(kind="cons",scw=scw)
        if r is not None:
            return r
        return ensure_data(kind="nrt",scw=scw)

    
    scw=scw[:12]
    if kind=="cons":
        scw=scw+".001"
    if kind=="nrt":
        scw=scw+".000"

    logger.log(logging.INFO,"updating data for %s %s"%(kind,scw))
    
    tf = tempfile.NamedTemporaryFile(delete=False)
    cmd="filelist=%s data_kind=%s download_data.sh %s %s"%(tf.name,kind,scw[:4],scw)
    print("command:",cmd)
    os.system(cmd)

    try:
        fl=[l.strip() for l in open(tf.name)]
        if fl==[]:
            return None
        return fl
    except Exception as e:
        print("exception",e)
        return None

