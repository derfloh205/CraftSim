import sys
sys.path.append('../')
import wagoTools
import shutil

wagoTables = ["Item", "ModifiedCraftingReagentItem", "ModifiedCraftingCategory"]

def getItemWeight(reagentItemID, reagentItemTable, craftingCategoryTable):
    for reagentItem in reagentItemTable:
            if reagentItemID == reagentItem["ID"]:
                craftingCategoryID = reagentItem["ModifiedCraftingCategoryID"]
                for craftingCategory in craftingCategoryTable:
                    if craftingCategoryID == craftingCategory["ID"]:
                        return int(craftingCategory["MatQualityWeight"])
    return 0

def copy(buildVersion):
    shutil.copy(f"Result/{buildVersion}/ReagentWeightData.lua", "../../../Data/ReagentWeightData.lua")

def map(download, buildVersion):
    csvTables = wagoTools.getWagoTables(wagoTables, download, buildVersion)
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

    wagoTools.writeLuaTable(itemWeightTable, "ReagentWeightData", "---@class CraftSim\nlocal CraftSim = select(2, ...)\nCraftSim.REAGENT_DATA = ", buildVersion)

def update(buildVersion):
    map(True, buildVersion)
    copy(buildVersion)

if __name__ == '__main__':
    args = sys.argv[1:]
    buildVersion = (len(args) > 0 and args[0]) or buildVersion

    update(buildVersion)