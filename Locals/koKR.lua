AddonName, CraftSim = ...

CraftSim.LOCAL_KO = {}

function CraftSim.LOCAL_KO:GetData()
    return {
        -- REQUIRED:
        [CraftSim.CONST.TEXT.STAT_INSPIRATION] = "영감",
        [CraftSim.CONST.TEXT.STAT_MULTICRAFT] = "복수 제작",
        [CraftSim.CONST.TEXT.STAT_RESOURCEFULNESS] = "지혜",
        [CraftSim.CONST.TEXT.STAT_CRAFTINGSPEED] = "제작 속도",
        [CraftSim.CONST.TEXT.EQUIP_MATCH_STRING] = "착용 효과:",
        [CraftSim.CONST.TEXT.ENCHANTED_MATCH_STRING] = "마법부여:",
        
        -- Details Frame
        [CraftSim.CONST.TEXT.RECIPE_DIFFICULTY_LABEL] = "제작 난이도: ",
        [CraftSim.CONST.TEXT.INSPIRATION_LABEL] = "영감: ",
        [CraftSim.CONST.TEXT.INSPIRATION_SKILL_LABEL] = "영감 기술: ",
        [CraftSim.CONST.TEXT.MULTICRAFT_LABEL] = "복수 제작: ",
        [CraftSim.CONST.TEXT.RESOURCEFULNESS_LABEL] = "지혜: ",
    }
end
