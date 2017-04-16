import ddosa
import datamirror
import glob
import os
import gzip

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
    datafile_restore_mode="url_in_object"

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
            for fn in glob.glob(self.scwpath+"/*fits*"):
                print "found file",fn
                setattr(self,os.path.basename(fn),ddosa.DataFile(fn))
                self.scwfilelist.append(fn)

            

    def post_restore(self):
        if self.input_datasourceconfig.store_files:
            scwid=self.input_scwid.str()
            rev=scwid[:4]
            self.scwpath=os.environ['INTEGRAL_DATA']+"/scw/"+rev+"/"+scwid
            self.swgpath=self.scwpath+"/swg.fits"
            for fn in self.scwfilelist:
                bfn=os.path.basename(fn)

                open(self.scwpath+"/"+bfn,"w").write(getattr(self,bfn).open().read())

                print "doing post-restore",self.scwpath+"/"+bfn,"from",getattr(self,bfn).get_path()
