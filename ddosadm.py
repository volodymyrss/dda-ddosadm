import ddosa
import datamirror
import glob
import os
import gzip
import subprocess

class DataSourceConfig(ddosa.DataAnalysis):
    store_files=True

class AUXADP(ddosa.DataAnalysis):
    input_rev=ddosa.RevForScW

    def main(self):
        print self.input_rev.auxadppath
        print self.input_rev.revdir
        # this is fetched at the same time as scw, should be not


class ScWData(ddosa.ScWData):
    cached=True
    test_files=False
   # rename_output_unique=False
    #datafile_restore_mode="url_in_object"

    version="v3"

    input_datasourceconfig=DataSourceConfig

    def main(self):
        try:
            ddosa.ScWData.main(self)
        except ddosa.dataanalysis.AnalysisException as e:
            print "offline ScWData failed:",e
            datamirror.ensure_data(scw=self.input_scwid.str(),kind="any")
            ddosa.ScWData.main(self)

        self.scwfilelist=[]

        if self.input_datasourceconfig.store_files:
            print "searching for ScW files:",self.scwpath+"/*"
            targz="scw_pack.tar"
            subprocess.check_call(["tar","-C",self.scwpath,"-cvf",targz,"."])
            self.scwpack=ddosa.DataFile(targz)

            

    def post_restore(self):
        if self.input_datasourceconfig.store_files:
            scwid=self.input_scwid.str()
            rev=scwid[:4]
            self.scwpath=os.environ['INTEGRAL_DATA']+"/scw/"+rev+"/"+scwid
            self.swgpath=self.scwpath+"/swg.fits"
            
            if not os.path.exists(self.scwpath): os.makedirs(self.scwpath)
            cmd=["tar","-C",self.scwpath,"-xvf",os.path.abspath(self.scwpack.get_path())]
            print "cmd",cmd
            subprocess.check_call(cmd)
            print "restored scw in",self.scwpath
