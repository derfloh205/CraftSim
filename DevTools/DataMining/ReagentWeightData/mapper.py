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
    shutil.copy(f"_Result/{buildVersion}/ReagentWeightData.lua", "../../Data/ReagentWeightData.lua")

def map(buildVersion):
    csvTables = wagoTools.getWagoTables(wagoTables, False, buildVersion)
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