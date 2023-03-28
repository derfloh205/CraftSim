AddonName, CraftSim = ...

CraftSim.LOCAL_CN = {}

function CraftSim.LOCAL_CN:GetData()
    local f = CraftSim.UTIL:GetFormatter()
    return {
        -- REQUIRED:
        [CraftSim.CONST.TEXT.STAT_INSPIRATION] = "灵感",
        [CraftSim.CONST.TEXT.STAT_MULTICRAFT] = "产能",
        [CraftSim.CONST.TEXT.STAT_RESOURCEFULNESS] = "充裕",
        [CraftSim.CONST.TEXT.STAT_CRAFTINGSPEED] = "制作速度",
        [CraftSim.CONST.TEXT.EQUIP_MATCH_STRING] = "装备：",
        [CraftSim.CONST.TEXT.ENCHANTED_MATCH_STRING] = "附魔：",
    }
end