import sys
sys.path.append('../')
import wagoTools

buildVersion = "11.0.2.56110" 
wagoTables = ["CraftingData", "CraftingDataEnchantQuality"]

if __name__ == '__main__':
    args = sys.argv[1:]
    download = len(args) > 0 and args[0] == "true"
    csvTables = wagoTools.getWagoTables(wagoTables, download, buildVersion)
    craftingDataTable = csvTables[0]
    enchantDataTable = csvTables[1]

    enchantDataMappedTable = {}

    for craftingData in craftingDataTable:
        if craftingData["Type"] == "3": # 3 .. Enchant
            craftingDataID = int(craftingData["ID"])
            print(f"Mapping CraftingDataID: {craftingDataID}")
            for enchantData in enchantDataTable:
                if enchantData["CraftingDataID"] == str(craftingDataID):
                    qualityID = int(enchantData["Rank"])
                    itemID = int(enchantData["ItemID"])
                    if craftingDataID not in enchantDataMappedTable:
                        enchantDataMappedTable[craftingDataID] = {}
                    enchantDataMappedTable[craftingDataID][f"q{qualityID}"] = itemID



    wagoTools.writeLuaTable(enchantDataMappedTable, "EnchantData", "---@class CraftSim\nlocal CraftSim = select(2, ...)\nCraftSim.ENCHANT_RECIPE_DATA = ", buildVersion)
        