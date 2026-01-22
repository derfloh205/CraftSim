import os
import sys
import shutil
import importlib

dataScripts = ["ConcentrationCurveData", "EnchantData", "OptionalReagentData", "ReagentWeightData"] ## SpecializationData is a special case (manually)

if __name__ == '__main__':
    args = sys.argv[1:]
    buildVersion = len(args) > 0 and args[0]

    for folderName in dataScripts:
        print("Updating data script: " + folderName)
        os.chdir(folderName)
        exec(open('mapper.py').read())
        os.chdir("..")