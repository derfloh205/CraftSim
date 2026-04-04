import sys
sys.path.append('../')
import wagoTools
import shutil

EFFECT_IDS = {
    "resourcefulness": 76,
    "multicraft": 81,
    "ingenuity": 82,
}

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
        scalingClass = float(toolEnchant["ScalingClass"])

        scalingFactor = abs((effectScalingPoints / scalingClass) * 10)

        value = int(scalingFactor) # floor it

        # remove from string suffix beginning with | and trim string
        name = toolEnchant["Name_lang"].split("|")[0].strip()

        toolEnchantData[enchantID] = {"name": name, "stat": stat, "value": value}

    wagoTools.writeLuaTable(toolEnchantData, "ToolEnchantData", "---@class CraftSim\nlocal CraftSim = select(2, ...)\nCraftSim.TOOLENCHANTDATA = ", buildVersion)