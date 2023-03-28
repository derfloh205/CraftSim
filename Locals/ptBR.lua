AddonName, CraftSim = ...

CraftSim.LOCAL_PT = {}

function CraftSim.LOCAL_PT:GetData()
    local f = CraftSim.UTIL:GetFormatter()
    return {
        -- REQUIRED:
        [CraftSim.CONST.TEXT.STAT_INSPIRATION] = "Inspiração",
        [CraftSim.CONST.TEXT.STAT_MULTICRAFT] = "Multicriação",
        [CraftSim.CONST.TEXT.STAT_RESOURCEFULNESS] = "Devolução de recursos",
        [CraftSim.CONST.TEXT.STAT_CRAFTINGSPEED] = "Velocidade de criação",
        [CraftSim.CONST.TEXT.EQUIP_MATCH_STRING] = "Equipado:",
        [CraftSim.CONST.TEXT.ENCHANTED_MATCH_STRING] = "Encantado:",

        -- OPTIONAL:
        -- Details Frame
        [CraftSim.CONST.TEXT.RECIPE_DIFFICULTY_LABEL] = "Dificuldade da receita: ",
        [CraftSim.CONST.TEXT.INSPIRATION_LABEL] = "Inspiração: ",
        [CraftSim.CONST.TEXT.MULTICRAFT_LABEL] = "Multicriação: ",
        [CraftSim.CONST.TEXT.RESOURCEFULNESS_LABEL] = "Devolução de recursos: ",
    }
end