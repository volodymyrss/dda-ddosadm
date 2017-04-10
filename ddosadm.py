import ddosa
import datamirror
import glob
import os

class ScWData(ddosa.ScWData):
    cached=True
    store_files=True
    test_files=False
    datafile_restore_mode="url_in_object"

    def main(self):
        try:
            ddosa.ScWData.main(self)
        except ddosa.dataanalysis.AnalysisException as e:
            print "offline ScWData failed:",e
            datamirror.ensure_data(scw=self.input_scwid.str(),kind="any")
            ddosa.ScWData.main(self)

        self.scwfilelist=[]

        if self.store_files:
            print "searching for ScW files:",self.scwpath+"/*"
            for fn in glob.glob(self.scwpath+"/*fits*"):
                print "found file",fn
                setattr(self,os.path.basename(fn),ddosa.DataFile(fn))
                self.scwfilelist.append(fn)
        

    def post_restore(self):
        self.scwpath=getattr(self,'swg.fits').cached_path.replace("swg.fits.gz","")
        self.swgpath=self.scwpath+"/swg.fits"
        print "doing post-restore from",self.scwpath
