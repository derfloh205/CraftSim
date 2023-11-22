CraftSimAddonName, CraftSim = ...

CraftSim.LOCAL_RU = {}

function CraftSim.LOCAL_RU:GetData()
    local f = CraftSim.UTIL:GetFormatter()
    return {
        -- REQUIRED:
        [CraftSim.CONST.TEXT.STAT_INSPIRATION] = "Вдохновение",
        [CraftSim.CONST.TEXT.STAT_MULTICRAFT] = "Перепроизводство",
        [CraftSim.CONST.TEXT.STAT_RESOURCEFULNESS] = "Находчивость",
        [CraftSim.CONST.TEXT.STAT_CRAFTINGSPEED] = "Скорость изготовления",
        [CraftSim.CONST.TEXT.EQUIP_MATCH_STRING] = "Если на персонаже:",
        [CraftSim.CONST.TEXT.ENCHANTED_MATCH_STRING] = "Чары:",

        -- OPTIONAL:
    }
end