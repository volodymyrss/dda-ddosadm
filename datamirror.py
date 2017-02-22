#!/bin/env python

import os
import tempfile
import datamirror
import integralclient

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


def ensure_data_range(t1,t2,kind="any"):
    ijd1=float(integralclient.converttime("ANY",t1,"IJD"))
    ijd2=float(integralclient.converttime("ANY",t2,"IJD"))

    i=ijd1
    
    scws=[]
    while i<ijd2:
        scw=integralclient.converttime("IJD",i,"SCWID")
        if len(scws)>0 and scws[-1]!=scw:
            scws.append(scw)

        x,i=map(float,integralclient.converttime("SCWID",scw,"IJD").split(":"))
        print "scw:",scw,x,i,"wait for",ijd2
        i+=1./24/3600.

    for scw in scws:
        ensure_data(kind=kind,scw=scw)
