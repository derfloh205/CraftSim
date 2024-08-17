import shutil
import sys

if __name__ == '__main__':
    args = sys.argv[1:]
    buildVersion = (len(args) > 0 and args[0]) or "Latest"

    shutil.copy(f"Result/{buildVersion}/ConcentrationCurveData.lua", "../../../Data/ConcentrationCurveData.lua")
    