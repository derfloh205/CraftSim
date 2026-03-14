import sys
sys.path.append('../')
import wagoTools
import shutil

EFFECT_IDS = {
    "resourcefulness": 76,
    "multicraft": 81,
    "ingenuity": 82,
}

# Scaling constant to convert from Wago's EffectScalingPoints to the actual stat value. Calculated based on known values for certain enchants for midnight ilvl ranges.
scalingConstant = 15 / 10.5783996582

wagoTables = ["SpellItemEnchantment"]

def copy(buildVersion):
    shutil.copy(f"_Result/{buildVersion}/ToolEnchantData.lua", "../../Data/ToolEnchantData.lua")

def map(buildVersion):
    csvTables = wagoTools.getWagoTables(wagoTables, False, buildVersion)
    spellItemEnchantmentTable = csvTables[0]

    toolEnchantData = {}

    toolEnchants = wagoTools.searchTable(spellItemEnchantmentTable, 
                                         {
                                            "conditions": 
                                            {
                                                "EffectArg_0": [str(EFFECT_IDS["resourcefulness"]), str(EFFECT_IDS["multicraft"]), str(EFFECT_IDS["ingenuity"])]
                                            }
                                        })


    for toolEnchant in toolEnchants:
        enchantID = int(toolEnchant["ID"])
        stat = ""
        if toolEnchant["EffectArg_0"] == str(EFFECT_IDS["resourcefulness"]):
            stat = "resourcefulness"
        elif toolEnchant["EffectArg_0"] == str(EFFECT_IDS["multicraft"]):
            stat = "multicraft"
        elif toolEnchant["EffectArg_0"] == str(EFFECT_IDS["ingenuity"]):
            stat = "ingenuity"

        effectScalingPoints = float(toolEnchant["EffectScalingPoints_0"])

        value = round(effectScalingPoints * scalingConstant)

        itemLevelMin = int(toolEnchant["ItemLevelMin"])
        itemlevelMax = int(toolEnchant["ItemLevelMax"])

        # remove from string suffix beginning with | and trim string
        name = toolEnchant["Name_lang"].split("|")[0].strip()

        toolEnchantData[int(enchantID)] = {"name": name, "enchantID": enchantID, "stat": stat, "scalingPoints": effectScalingPoints, "itemLevelMin": itemLevelMin, "itemLevelMax": itemlevelMax, "value": value}

    wagoTools.writeLuaTable(toolEnchantData, "ToolEnchantData", "---@class CraftSim\nlocal CraftSim = select(2, ...)\nCraftSim.TOOLENCHANTDATA = ", buildVersion)