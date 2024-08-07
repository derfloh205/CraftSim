import sys
sys.path.append('../')
import db2Tools

buildVersion = "11.0.2.55059" # Beta 07.08.2024
db2Tables = ["CraftingData", "CraftingDataEnchantQuality"]

if __name__ == '__main__':
    args = sys.argv[1:]
    download = len(args) > 0 and args[0] == "true"
    csvTables = db2Tools.getWagoTables(db2Tables, download, buildVersion)
    craftingDataTable = csvTables[0]
    enchantDataTable = csvTables[1]

    enchantDataTable = {}

    for craftingData in craftingDataTable:
        if craftingData["Type"] == "3": # 3 .. Enchant
            craftingDataID = craftingData["ID"]
            for enchantData in enchantDataTable:
                if enchantData["CraftingDataID"] == craftingDataID:
                    


    db2Tools.writeLuaTable(enchantDataTable, "EnchantData", "---@class CraftSim\nlocal CraftSim = select(2, ...)\nCraftSim.ENCHANT_RECIPE_DATA = ", buildVersion)
        