CraftSimAddonName, CraftSim = ...

CraftSim.LOCAL_TW = {}

function CraftSim.LOCAL_TW:GetData()
    local f = CraftSim.UTIL:GetFormatter()
    return {
        -- REQUIRED:
        [CraftSim.CONST.TEXT.STAT_INSPIRATION] = "靈感",
        [CraftSim.CONST.TEXT.STAT_MULTICRAFT] = "複數製造",
        [CraftSim.CONST.TEXT.STAT_RESOURCEFULNESS] = "精明",
        [CraftSim.CONST.TEXT.STAT_CRAFTINGSPEED] = "製造速度",
        [CraftSim.CONST.TEXT.EQUIP_MATCH_STRING] = "裝備：",
        [CraftSim.CONST.TEXT.ENCHANTED_MATCH_STRING] = "附魔：",

        -- OPTIONAL (Defaulting to EN if not available):
        -- Other Statnames

        [CraftSim.CONST.TEXT.STAT_SKILL] = "技能",
        [CraftSim.CONST.TEXT.STAT_MULTICRAFT_BONUS] = "複數製造額外物品",
        [CraftSim.CONST.TEXT.STAT_RESOURCEFULNESS_BONUS] = "精明額外物品",
        [CraftSim.CONST.TEXT.STAT_INSPIRATION_BONUS] = "靈感額外技能",
        [CraftSim.CONST.TEXT.STAT_CRAFTINGSPEED_BONUS] = "製造速度",
        [CraftSim.CONST.TEXT.STAT_PHIAL_EXPERIMENTATION] = "藥瓶突破",
        [CraftSim.CONST.TEXT.STAT_POTION_EXPERIMENTATION] = "藥水突破",

        -- Profit Breakdown Tooltips
        --[CraftSim.CONST.TEXT.RESOURCEFULNESS_EXPLANATION_TOOLTIP] = "Resourcefulness procs for every material individually and then saves about 30% of its quantity.\n\nThe average value it saves is the average saved value of EVERY combination and their chances.\n(All materials proccing at once is very unlikely but saves a lot)\n\nThe average total saved material costs is the sum of the saved material costs of all combinations weighted against their chance.",
        --[CraftSim.CONST.TEXT.MULTICRAFT_ADDITIONAL_ITEMS_EXPLANATION_TOOLTIP] = "This number shows the average amount of items that are additionally created by multicraft.\n\nThis considers your chance and assumes for multicraft that\n(1-2.5y)*any_spec_bonus additional items are created where y is base average of items created for 1 craft",
        --[CraftSim.CONST.TEXT.MULTICRAFT_ADDITIONAL_ITEMS_VALUE_EXPLANATION_TOOLTIP] = "This is the average number of additional items created by multicraft times the sell price of the result item on this quality",
        --[CraftSim.CONST.TEXT.MULTICRAFT_ADDITIONAL_ITEMS_HIGHER_VALUE_EXPLANATION_TOOLTIP] = "This is the average number of additional items created by multicraft and inspiration times the sell price of the result item on the quality reached by inspiration",
        --[CraftSim.CONST.TEXT.MULTICRAFT_ADDITIONAL_ITEMS_HIGHER_QUALITY_EXPLANATION_TOOLTIP] = "This number shows the average amount of items that are additionally created by multicraft proccing with inspiration.\n\nThis considers your multicraft and inspiration chance and reflects the additional items created when both procc at once",
        --[CraftSim.CONST.TEXT.INSPIRATION_ADDITIONAL_ITEMS_EXPLANATION_TOOLTIP] = "This number shows the average amount of items that are created on your current guaranteed quality, when inspiration does not procc",
        --[CraftSim.CONST.TEXT.INSPIRATION_ADDITIONAL_ITEMS_HIGHER_QUALITY_EXPLANATION_TOOLTIP] = "This number shows the average amount of items that are created on the next reachable quality with inspiration",
        --[CraftSim.CONST.TEXT.INSPIRATION_ADDITIONAL_ITEMS_VALUE_EXPLANATION_TOOLTIP] = "This is the average number of items created on the guaranteed quality times the sell price of the result item on this quality",
        --[CraftSim.CONST.TEXT.INSPIRATION_ADDITIONAL_ITEMS_HIGHER_VALUE_EXPLANATION_TOOLTIP] = "This is the average number of items created on the quality reached with inspiration times the sell price of the result item on the quality reached by inspiration",

        -- unused currently
        -- [CraftSim.CONST.TEXT.RECIPE_DIFFICULTY_EXPLANATION_TOOLTIP] = "Recipe difficulty determines where the breakpoints of the different qualities are.\n\nFor recipes with five qualities they are at 20%, 50%, 80% and 100% recipe difficulty as skill.\nFor recipes with three qualities they are at 50% and 100%",
        -- [CraftSim.CONST.TEXT.INSPIRATION_EXPLANATION_TOOLTIP] = "Inspiration gives you a chance to add skill to your craft.\n\nThis may lead to higher quality crafts if the added skill puts your skill over the threshold for the next quality.\nFor recipes with 5 qualities the base bonus skill is a sixth (16.67%) of the base recipe difficulty.\nFor recipes with 3 qualities its a third (33.33%)",
        -- [CraftSim.CONST.TEXT.INSPIRATION_SKILL_EXPLANATION_TOOLTIP] = "This is the skill that is added on top of your current skill if inspiration procs.\n\nIf your current skill plus this bonus skill reaches the threshold\nof the next quality, you craft the item in this higher quality.",
        -- [CraftSim.CONST.TEXT.MULTICRAFT_EXPLANATION_TOOLTIP] = "Multicraft gives you a chance of crafting more items than you would usually produce with a recipe.\n\nThe additional amount is usually between 1 and 2.5y\nwhere y = the usual amount 1 craft yields.",
        -- [CraftSim.CONST.TEXT.REAGENTSKILL_EXPLANATION_TOOLTIP] = "The quality of your materials can give you a maximum of 25% of the base recipe difficulty as bonus skill.\n\nAll Q1 Materials: 0% Bonus\nAll Q2 Materials: 12.5% Bonus\nAll Q3 Materials: 25% Bonus\n\nThe skill is calculated by the amount of materials of each quality weighted against their quality\nand a specific weight value that is unique to each individual dragon flight crafting material item",
    
        -- Details Frame
        [CraftSim.CONST.TEXT.RECIPE_DIFFICULTY_LABEL] = "配方難度：",
        [CraftSim.CONST.TEXT.INSPIRATION_LABEL] = "靈感：",
        [CraftSim.CONST.TEXT.INSPIRATION_SKILL_LABEL] = "靈感技能：",
        [CraftSim.CONST.TEXT.MULTICRAFT_LABEL] = "複數製造：",
        [CraftSim.CONST.TEXT.RESOURCEFULNESS_LABEL] = "精明：",
        [CraftSim.CONST.TEXT.RESOURCEFULNESS_BONUS_LABEL] = "精明節省加成: ",
        [CraftSim.CONST.TEXT.MATERIAL_QUALITY_BONUS_LABEL] = "材料品質加成: ",
        [CraftSim.CONST.TEXT.MATERIAL_QUALITY_MAXIMUM_LABEL] = "材料品質最大佔比: ",
        [CraftSim.CONST.TEXT.EXPECTED_QUALITY_LABEL] = "預期品質: ",
        [CraftSim.CONST.TEXT.NEXT_QUALITY_LABEL] = "下一級品質: ",
        [CraftSim.CONST.TEXT.MISSING_SKILL_LABEL] = "不足技能: ",
        [CraftSim.CONST.TEXT.MISSING_SKILL_INSPIRATION_LABEL] = "不足技能 (靈感)",
        [CraftSim.CONST.TEXT.SKILL_LABEL] = "技能: ",
        [CraftSim.CONST.TEXT.MULTICRAFT_BONUS_LABEL] = "複數製造加成: "
    }
end