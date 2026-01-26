import sys
sys.path.append('../')
import wagoTools
import shutil

wagoTables = ["CraftingData", "CraftingDataEnchantQuality"]

def copy(buildVersion):
    shutil.copy(f"Result/{buildVersion}/EnchantData.lua", "../../../Data/EnchantData.lua")

def map(download, buildVersion):
    csvTables = wagoTools.getWagoTables(wagoTables, download, buildVersion)
    craftingDataTable = csvTables[0]
    enchantDataTable = csvTables[1]

    enchantDataMappedTable = {}

    count = 0
    total = len(craftingDataTable)
    for craftingData in craftingDataTable:
        count = count + 1
        wagoTools.updateProgressBar(count, total)
        if craftingData["Type"] == "3": # 3 .. Enchant
            craftingDataID = int(craftingData["ID"])
            for enchantData in enchantDataTable:
                if enchantData["CraftingDataID"] == str(craftingDataID):
                    qualityID = int(enchantData["Rank"])
                    # if qualityID is greater than 3, set it to 0 due to enchant item not having quality variants
                    if qualityID > 3:
                        qualityID = 0
                    itemID = int(enchantData["ItemID"])
                    if craftingDataID not in enchantDataMappedTable:
                        enchantDataMappedTable[craftingDataID] = {}
                    enchantDataMappedTable[craftingDataID][f"q{qualityID}"] = itemID



    wagoTools.writeLuaTable(enchantDataMappedTable, "EnchantData", "---@class CraftSim\nlocal CraftSim = select(2, ...)\nCraftSim.ENCHANT_RECIPE_DATA = ", buildVersion)

def update(buildVersion):
    map(True, buildVersion)
    copy(buildVersion)

if __name__ == '__main__':
    args = sys.argv[1:]
    buildVersion = (len(args) > 0 and args[0]) or "Latest"
    update(buildVersion)


    
        