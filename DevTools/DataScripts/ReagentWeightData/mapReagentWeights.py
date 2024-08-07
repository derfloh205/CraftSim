import sys
sys.path.append('../')
import db2Tools

db2Tables = ["Item", "ModifiedCraftingReagentItem", "ModifiedCraftingCategory"]

def getItemWeight(reagentItemID, reagentItemTable, craftingCategoryTable):
    for reagentItem in reagentItemTable:
            if reagentItemID == reagentItem["ID"]:
                craftingCategoryID = reagentItem["ModifiedCraftingCategoryID"]
                for craftingCategory in craftingCategoryTable:
                    if craftingCategoryID == craftingCategory["ID"]:
                        return int(craftingCategory["MatQualityWeight"])
    return 0

if __name__ == '__main__':
    args = sys.argv[1:]
    download = len(args) > 0 and args[0] == "true"
    csvTables = db2Tools.getWagoTables(db2Tables, download)
    tradeSkillItemTable = csvTables[0]
    reagentItemTable = csvTables[1]
    craftingCategoryTable = csvTables[2]

    itemWeightTable = {}

    for item in tradeSkillItemTable:
        itemID = item["ID"]
        reagentItemID = item["ModifiedCraftingReagentItemID"]
        weight = getItemWeight(reagentItemID, reagentItemTable, craftingCategoryTable)
        if weight and weight > 0:
            itemWeightTable[int(itemID)] = {"weight": weight}

    db2Tools.writeLuaTable(itemWeightTable, "ReagentWeightData", "---@class CraftSim\nlocal CraftSim = select(2, ...)\nCraftSim.REAGENT_DATA = ")
        