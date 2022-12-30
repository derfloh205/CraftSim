addonName, CraftSim = ...

CraftSim.LOCAL_IT = {}

function CraftSim.LOCAL_IT:GetData()
    return {
        -- REQUIRED:
        [CraftSim.CONST.TEXT.STAT_INSPIRATION] = "Izpiratione",
        [CraftSim.CONST.TEXT.STAT_MULTICRAFT] = "Mehrfachherstellung",
        [CraftSim.CONST.TEXT.STAT_RESOURCEFULNESS] = "Einfallsreichtum",
        [CraftSim.CONST.TEXT.STAT_CRAFTINGSPEED] = "Herstellungsgeschwindigkeit",
        [CraftSim.CONST.TEXT.EQUIP_MATCH_STRING] = "Equipaggia:",
        [CraftSim.CONST.TEXT.ENCHANTED_MATCH_STRING] = "Incantato:",
        [CraftSim.CONST.TEXT.INSPIRATIONBONUS_SKILL_ITEM_MATCH_STRING] = "durch Inspiration um",

        -- OPTIONAL:
    }
end