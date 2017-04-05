import ddosa
import datamirror

class ScWData(ddosa.ScWData):
    def main(self):
        try:
            ddosa.ScWData.main(self)
        except ddosa.dataanalysis.AnalysisException as e:
            print "offline ScWData failed:",e
            datamirror.ensure_data(scw=self.input_scwid.str(),kind="any")
            ddosa.ScWData.main(self)
            

