AddonName, CraftSim = ...

CraftSim.LOCAL_IT = {}

function CraftSim.LOCAL_IT:GetData()
    return {
        -- REQUIRED:
        [CraftSim.CONST.TEXT.STAT_INSPIRATION] = "Ispirazione",
        [CraftSim.CONST.TEXT.STAT_MULTICRAFT] = "Creazione multipla",
        [CraftSim.CONST.TEXT.STAT_RESOURCEFULNESS] = "Parsimonia",
        [CraftSim.CONST.TEXT.STAT_CRAFTINGSPEED] = "Velocità di creazione",
        [CraftSim.CONST.TEXT.EQUIP_MATCH_STRING] = "Equipaggia:",
        [CraftSim.CONST.TEXT.ENCHANTED_MATCH_STRING] = "Incantato:",
        [CraftSim.CONST.TEXT.INSPIRATIONBONUS_SKILL_ITEM_MATCH_STRING] = "aumenta la competenza aggiuntiva fornita da Ispirazione",

        -- OPTIONAL:
    }
end
