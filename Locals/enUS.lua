AddonName, CraftSim = ...

CraftSim.LOCAL_EN = {}

function CraftSim.LOCAL_EN:GetData()
    return {
        -- REQUIRED:
        [CraftSim.CONST.TEXT.STAT_INSPIRATION] = "Inspiration",
        [CraftSim.CONST.TEXT.STAT_MULTICRAFT] = "Multicraft",
        [CraftSim.CONST.TEXT.STAT_RESOURCEFULNESS] = "Resourcefulness",
        [CraftSim.CONST.TEXT.STAT_CRAFTINGSPEED] = "Crafting Speed",
        [CraftSim.CONST.TEXT.EQUIP_MATCH_STRING] = "Equip:",
        [CraftSim.CONST.TEXT.ENCHANTED_MATCH_STRING] = "Enchanted:",

        -- OPTIONAL (Defaulting to EN if not available):
        -- Other Statnames

        [CraftSim.CONST.TEXT.STAT_SKILL] = "Skill",
        [CraftSim.CONST.TEXT.STAT_MULTICRAFT_BONUS] = "Multicraft ExtraItems",
        [CraftSim.CONST.TEXT.STAT_RESOURCEFULNESS_BONUS] = "Resourcefulness ExtraItems",
        [CraftSim.CONST.TEXT.STAT_INSPIRATION_BONUS] = "Inspiration SkillBonus",
        [CraftSim.CONST.TEXT.STAT_CRAFTINGSPEED_BONUS] = "Crafting Speed",
        [CraftSim.CONST.TEXT.STAT_PHIAL_EXPERIMENTATION] = "Phial Breakthrough",
        [CraftSim.CONST.TEXT.STAT_POTION_EXPERIMENTATION] = "Potion Breakthrough",

        -- Profit Breakdown Tooltips
        [CraftSim.CONST.TEXT.RESOURCEFULNESS_EXPLANATION_TOOLTIP] = "Resourcefulness procs for every material individually and then saves about 30% of its quantity.\n\nThe average value it saves is the average saved value of EVERY combination and their chances.\n(All materials proccing at once is very unlikely but saves a lot)\n\nThe average total saved material costs is the sum of the saved material costs of all combinations weighted against their chance.",
        [CraftSim.CONST.TEXT.MULTICRAFT_ADDITIONAL_ITEMS_EXPLANATION_TOOLTIP] = "This number shows the average amount of items that are additionally created by multicraft.\n\nThis considers your chance and assumes for multicraft that\n(1-2.5y)*any_spec_bonus additional items are created where y is base average of items created for 1 craft",
        [CraftSim.CONST.TEXT.MULTICRAFT_ADDITIONAL_ITEMS_VALUE_EXPLANATION_TOOLTIP] = "This is the average number of additional items created by multicraft times the sell price of the result item on this quality",
        [CraftSim.CONST.TEXT.MULTICRAFT_ADDITIONAL_ITEMS_HIGHER_VALUE_EXPLANATION_TOOLTIP] = "This is the average number of additional items created by multicraft and inspiration times the sell price of the result item on the quality reached by inspiration",
        [CraftSim.CONST.TEXT.MULTICRAFT_ADDITIONAL_ITEMS_HIGHER_QUALITY_EXPLANATION_TOOLTIP] = "This number shows the average amount of items that are additionally created by multicraft proccing with inspiration.\n\nThis considers your multicraft and inspiration chance and reflects the additional items created when both procc at once",
        [CraftSim.CONST.TEXT.INSPIRATION_ADDITIONAL_ITEMS_EXPLANATION_TOOLTIP] = "This number shows the average amount of items that are created on your current guaranteed quality, when inspiration does not procc",
        [CraftSim.CONST.TEXT.INSPIRATION_ADDITIONAL_ITEMS_HIGHER_QUALITY_EXPLANATION_TOOLTIP] = "This number shows the average amount of items that are created on the next reachable quality with inspiration",
        [CraftSim.CONST.TEXT.INSPIRATION_ADDITIONAL_ITEMS_VALUE_EXPLANATION_TOOLTIP] = "This is the average number of items created on the guaranteed quality times the sell price of the result item on this quality",
        [CraftSim.CONST.TEXT.INSPIRATION_ADDITIONAL_ITEMS_HIGHER_VALUE_EXPLANATION_TOOLTIP] = "This is the average number of items created on the quality reached with inspiration times the sell price of the result item on the quality reached by inspiration",

        [CraftSim.CONST.TEXT.RECIPE_DIFFICULTY_EXPLANATION_TOOLTIP] = "Recipe difficulty determines where the breakpoints of the different qualities are.\n\nFor recipes with five qualities they are at 20%, 50%, 80% and 100% recipe difficulty as skill.\nFor recipes with three qualities they are at 50% and 100%",
        [CraftSim.CONST.TEXT.INSPIRATION_EXPLANATION_TOOLTIP] = "Inspiration gives you a chance to add skill to your craft.\n\nThis may lead to higher quality crafts if the added skill puts your skill over the threshold for the next quality.\nFor recipes with 5 qualities the base bonus skill is a sixth (16.67%) of the base recipe difficulty.\nFor recipes with 3 qualities its a third (33.33%)",
        [CraftSim.CONST.TEXT.INSPIRATION_SKILL_EXPLANATION_TOOLTIP] = "This is the skill that is added on top of your current skill if inspiration procs.\n\nIf your current skill plus this bonus skill reaches the threshold\nof the next quality, you craft the item in this higher quality.",
        [CraftSim.CONST.TEXT.MULTICRAFT_EXPLANATION_TOOLTIP] = "Multicraft gives you a chance of crafting more items than you would usually produce with a recipe.\n\nThe additional amount is usually between 1 and 2.5y\nwhere y = the usual amount 1 craft yields.",
        [CraftSim.CONST.TEXT.REAGENTSKILL_EXPLANATION_TOOLTIP] = "The quality of your materials can give you a maximum of 25% of the base recipe difficulty as bonus skill.\n\nAll Q1 Materials: 0% Bonus\nAll Q2 Materials: 12.5% Bonus\nAll Q3 Materials: 25% Bonus\n\nThe skill is calculated by the amount of materials of each quality weighted against their quality\nand a specific weight value that is unique to each individual dragon flight crafting material item\n\nThis is however different for recrafts. There the maximum the reagents can increase the quality\nis dependent on the quality of materials the item was originally crafted with.\nThe exact workings are not known.\nHowever, CraftSim internally compares the achieved skill with all q3 and calculates\nthe max skill increase based on that.",
        [CraftSim.CONST.TEXT.REAGENTFACTOR_EXPLANATION_TOOLTIP] = "The maximum the materials can contribute to a recipe is most of the time 25% of the base recipe difficulty.\n\nHowever in the case of recrafting, this value can vary based on previous crafts\nand the quality of materials that were used.",
    
        -- Details Frame
        [CraftSim.CONST.TEXT.RECIPE_DIFFICULTY_LABEL] = "Recipe Difficulty: ",
        [CraftSim.CONST.TEXT.INSPIRATION_LABEL] = "Inspiration: ",
        [CraftSim.CONST.TEXT.INSPIRATION_SKILL_LABEL] = "Inspiration Skill: ",
        [CraftSim.CONST.TEXT.MULTICRAFT_LABEL] = "Multicraft: ",
        [CraftSim.CONST.TEXT.RESOURCEFULNESS_LABEL] = "Resourcefulness: ",
        [CraftSim.CONST.TEXT.RESOURCEFULNESS_BONUS_LABEL] = "Resourcefulness Item Bonus: ",
        [CraftSim.CONST.TEXT.MATERIAL_QUALITY_BONUS_LABEL] = "Material Quality Bonus: ",
        [CraftSim.CONST.TEXT.MATERIAL_QUALITY_MAXIMUM_LABEL] = "Material Quality Maximum %: ",
        [CraftSim.CONST.TEXT.EXPECTED_QUALITY_LABEL] = "Expected Quality: ",
        [CraftSim.CONST.TEXT.NEXT_QUALITY_LABEL] = "Next Quality: ",
        [CraftSim.CONST.TEXT.MISSING_SKILL_LABEL] = "Missing Skill: ",
        [CraftSim.CONST.TEXT.MISSING_SKILL_INSPIRATION_LABEL] = "Missing Skill (Inspiration)",
        [CraftSim.CONST.TEXT.SKILL_LABEL] = "Skill: ",
        [CraftSim.CONST.TEXT.MULTICRAFT_BONUS_LABEL] = "Multicraft Item Bonus: ",
        -- Customer Service Module
        [CraftSim.CONST.TEXT.CUSTOMER_SERVICE_AUTO_REPLY_EXPLANATION] = "Enable the automatic answering with the highest possible results and material costs when someone whispers you the command and an item link for an item you can craft!",        
        [CraftSim.CONST.TEXT.CUSTOMER_SERVICE_AUTO_REPLY_FORMAT_EXPLANATION] = "Each line is a seperate chat message when responsing in a whisper.\n\nYou can use following labels to insert information about the requested item's recipe:\n%gc .. link of the guaranteed result quality\n%ic .. link of the result quality reachable with inspiration\n%insp .. your inspiration chance e.g. 18%\n%mc .. your multicraft chance\n%res .. your resourcefulness chance\n%cc .. the crafting costs\n%ccd .. the detailed costs per reagent used (preferably in its own line)",        
        [CraftSim.CONST.TEXT.CUSTOMER_SERVICE_LIVE_PREVIEW_EXPLANATION] = "Enable live crafting preview connections to you via CraftSim Preview Links.\nAnyone who has CraftSim and clicks the shared link can live connect to your crafting information to check out your crafting abilities",        
        
    }


end
