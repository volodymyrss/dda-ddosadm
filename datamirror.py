#!/bin/env python

import os
import tempfile

def ensure_data(kind="any",scw=None):
    

    if kind=="any":
        r=ensure_data(kind="cons",scw=scw)
        if r is not None:
            return r
        return ensure_data(kind="nrt",scw=scw)

    
    tf = tempfile.NamedTemporaryFile(delete=False)
    cmd="filelist=%s data_kind=%s sh download.sh %s %s"%(tf.name,kind,scw[:4],scw)
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

