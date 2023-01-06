addonName, CraftSim = ...

CraftSim.LOCAL_TW = {}

function CraftSim.LOCAL_TW:GetData()
    return {
        -- REQUIRED:
        [CraftSim.CONST.TEXT.STAT_INSPIRATION] = "靈感",
        [CraftSim.CONST.TEXT.STAT_MULTICRAFT] = "複數製造",
        [CraftSim.CONST.TEXT.STAT_RESOURCEFULNESS] = "精明",
        [CraftSim.CONST.TEXT.STAT_CRAFTINGSPEED] = "製造速度",
        [CraftSim.CONST.TEXT.EQUIP_MATCH_STRING] = "裝備：",
        [CraftSim.CONST.TEXT.ENCHANTED_MATCH_STRING] = "附魔：",
        [CraftSim.CONST.TEXT.INSPIRATIONBONUS_SKILL_ITEM_MATCH_STRING] = "在製作期間獲得靈感時，提高所提供的的技能",

        -- OPTIONAL (Defaulting to EN if not available):
        -- Other Statnames
		
		[CraftSim.CONST.TEXT.STAT_SKILL] = "技能",
    }
end