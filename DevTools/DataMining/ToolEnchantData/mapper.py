import sys
sys.path.append('../')
import wagoTools
import shutil

wagoTables = ["SpellItemEnchantment", "ItemBonus"]

def copy(buildVersion):
    shutil.copy(f"_Result/{buildVersion}/ToolEnchantData.lua", "../../Data/ToolEnchantData.lua")

def map(buildVersion):
    csvTables = wagoTools.getWagoTables(wagoTables, False, buildVersion)
    spellItemEnchantmentTable = csvTables[0]
    itemBonusTable = csvTables[1]

    toolEnchantData = {}

    for item in spellItemEnchantmentTable:
        enchantID = item["ID"]
        
        toolEnchantData[int(enchantID)] = {"enchantID": enchantID}

    wagoTools.writeLuaTable(toolEnchantData, "ToolEnchantData", "---@class CraftSim\nlocal CraftSim = select(2, ...)\nCraftSim.TOOLENCHANTDATA = ", buildVersion)