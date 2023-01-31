AddonName, CraftSim = ...

CraftSim.LOCAL_DE = {}

function CraftSim.LOCAL_DE:GetData()
    return {
        -- REQUIRED:
        [CraftSim.CONST.TEXT.STAT_INSPIRATION] = "Inspiration",
        [CraftSim.CONST.TEXT.STAT_MULTICRAFT] = "Mehrfachherstellung",
        [CraftSim.CONST.TEXT.STAT_RESOURCEFULNESS] = "Einfallsreichtum",
        [CraftSim.CONST.TEXT.STAT_CRAFTINGSPEED] = "Herstellungsgeschwindigkeit",
        [CraftSim.CONST.TEXT.EQUIP_MATCH_STRING] = "Anlegen:",
        [CraftSim.CONST.TEXT.ENCHANTED_MATCH_STRING] = "Verzaubert:",

        -- OPTIONAL:
    }
end