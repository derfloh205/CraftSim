import sys
sys.path.append('../')
import wagoTools

buildVersion = "11.0.2.56044"
wagoTables = ["CraftingData", "CraftingDifficulty", "CurvePoint"]

if __name__ == '__main__':
    args = sys.argv[1:]
    download = len(args) > 0 and args[0] == "true"
    csvTables = wagoTools.getWagoTables(wagoTables, download, buildVersion)
    craftingDataTable = csvTables[0]
    craftingDifficultyTable = csvTables[1]
    curvePointTable = csvTables[2]

    concentrationCostDataTable = {}

    print("Mapping Concentration Curve Data")

    counter = 0
    total = len(craftingDataTable)
    for craftingData in craftingDataTable:
        counter = counter + 1
        craftingDataID = int(craftingData["ID"])
        craftingDifficultyID = craftingData["CraftingDifficultyID"]
        wagoTools.updateProgressBar(counter, total, craftingDataID)
        for craftingDifficulty in craftingDifficultyTable:
            if craftingDifficulty["ID"] == craftingDifficultyID:
                curveID = craftingDifficulty["ConcentrationSkillCurveID"]
                constantCurveID = craftingDifficulty["ConcentrationDifficultyCurveID"]

                if craftingDataID not in concentrationCostDataTable:
                    concentrationCostDataTable[craftingDataID] = {
                        "costConstantData": {},
                        "curveData": {}
                    }

                for curvePoint in curvePointTable:
                    if curvePoint["CurveID"] == constantCurveID:
                        if curvePoint["Pos_0"] is not None:
                            if curvePoint["Pos_1"] is not None:

                                recipeDifficultyThreshold = float(curvePoint["Pos_0"])
                                multiplier = float(curvePoint["Pos_1"])
                                
                                concentrationCostDataTable[craftingDataID]["costConstantData"][recipeDifficultyThreshold] = multiplier

                for curvePoint in curvePointTable:
                    if curvePoint["CurveID"] == curveID:
                        if curvePoint["Pos_0"] is not None:
                            if curvePoint["Pos_1"] is not None:

                                recipeDifficultyThreshold = float(curvePoint["Pos_0"]) / 100
                                skillCurveValue = float(curvePoint["Pos_1"])

                                concentrationCostDataTable[craftingDataID]["curveData"][recipeDifficultyThreshold] = skillCurveValue

    wagoTools.writeLuaTable(concentrationCostDataTable, "ConcentrationCurveData", "---@class CraftSim\nlocal CraftSim = select(2, ...)\nCraftSim.CONCENTRATION_CURVE_DATA = ", buildVersion)
        