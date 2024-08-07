import sys
sys.path.append('../')
import db2Tools

buildVersion = "11.0.0.55960"
db2Tables = ["CraftingData", "CraftingDifficulty", "CurvePoint"]

if __name__ == '__main__':
    args = sys.argv[1:]
    download = len(args) > 0 and args[0] == "true"
    csvTables = db2Tools.getWagoTables(db2Tables, download, buildVersion)
    craftingDataTable = csvTables[0]
    craftingDifficultyTable = csvTables[1]
    curvePointTable = csvTables[2]

    concentrationCostDataTable = {}

    for craftingData in craftingDataTable:
        craftingDataID = int(craftingData["ID"])
        craftingDifficultyID = craftingData["CraftingDifficultyID"]
        print(f"Mapping Crafting Data: {str(craftingDataID)}")
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

    db2Tools.writeLuaTable(concentrationCostDataTable, "ConcentrationCurveData", "---@class CraftSim\nlocal CraftSim = select(2, ...)\nCraftSim.CONCENTRATION_CURVE_DATA = ", buildVersion)
        