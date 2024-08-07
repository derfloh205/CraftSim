import csv
import luadata

def getDataTable(tableName):
    with open(tableName + '.csv', mode='r') as file:
        csv_reader = csv.DictReader(file)
        data_table = []
        for row in csv_reader:
            data_table.append(row)
    return data_table

def writeLuaTable(dataTable, fileName, prefix):
    luadata.write(fileName + ".lua", dataTable, encoding="utf-8", indent="\t", prefix=prefix)

if __name__ == '__main__':
    craftingDataTable = getDataTable("CraftingData")
    craftingDifficultyTable = getDataTable("CraftingDifficulty")
    curvePointTable = getDataTable("CurvePoint")

    print("craftingData: " + str(len(craftingDataTable)))
    print("craftingDifficulty: " + str(len(craftingDifficultyTable)))
    print("curvePoint: " + str(len(curvePointTable)))

    concentrationCostDataTable = {}

    for craftingData in craftingDataTable:
        craftingDataID = int(craftingData["ID"])
        craftingDifficultyID = craftingData["CraftingDifficultyID"]
        print("Mapping Crafting Data: " + str(craftingDataID))
        for craftingDifficulty in craftingDifficultyTable:
            if craftingDifficulty["ID"] == craftingDifficultyID:
                curveID = craftingDifficulty["ConcentrationSkillCurveID"]
                constantCurveID = craftingDifficulty["ConcentrationDifficultyCurveID"]

                if craftingDataID not in concentrationCostDataTable:
                    concentrationCostDataTable[craftingDataID] = {
                        "costConstant": None,
                        "curveData": {}
                    }

                for curvePoint in curvePointTable:
                    if curvePoint["CurveID"] == constantCurveID:
                        concentrationCostDataTable[craftingDataID]["costConstant"] = float(curvePoint["Pos_1"])

                for curvePoint in curvePointTable:
                    if curvePoint["CurveID"] == curveID:
                        if curvePoint["Pos_0"] is not None:
                            if curvePoint["Pos_1"] is not None:

                                recipeDifficultyThreshold = float(curvePoint["Pos_0"]) / 100
                                skillCurveValue = float(curvePoint["Pos_1"])

                                concentrationCostDataTable[craftingDataID]["curveData"][recipeDifficultyThreshold] = skillCurveValue

    writeLuaTable(concentrationCostDataTable, "ConcentrationCurveData", "---@class CraftSim\nlocal CraftSim = select(2, ...)\nCraftSim.CONCENTRATION_CURVE_DATA = ")
        