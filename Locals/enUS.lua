AddonName, CraftSim = ...

CraftSim.LOCAL_EN = {}

function CraftSim.LOCAL_EN:GetData()
    local f = CraftSim.UTIL:GetFormatter()
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
        [CraftSim.CONST.TEXT.CUSTOMER_SERVICE_AUTO_REPLY_FORMAT_EXPLANATION] = "Each line is a seperate chat message in the whisper.\n\nYou can use following labels to insert information about the recipe:\n%gc .. link of the guaranteed result quality\n%ic .. link of the result quality reachable with inspiration\n%insp .. your inspiration chance e.g. 18%\n%mc .. your multicraft chance\n%res .. your resourcefulness chance\n%cc .. the crafting costs\n%ccd .. the detailed costs per reagent used (preferably in its own line)\n%orl .. a simple list of all used optional reagents\n%rl .. a simple list of all required reagents",        
        [CraftSim.CONST.TEXT.CUSTOMER_SERVICE_LIVE_PREVIEW_EXPLANATION] = "Enable live crafting preview connections to you via CraftSim Preview Links.\nAnyone who has CraftSim and clicks the shared link can live connect to your crafting information to check out your crafting abilities",        
        [CraftSim.CONST.TEXT.HSV_EXPLANATION] = "HSV stands for 'Hidden Skill Value' and is a hidden skill increase between 0 to 5% of your recipe difficulty whenever you craft something.\n\nThis hidden skill value can bring you to the next quality similar to inspiration.\n\nHowever, the closer you are to the next quality the higher is the chance!",        
        [CraftSim.CONST.TEXT.CUSTOMER_SERVICE_HIGHEST_GUARANTEED_CHECKBOX_EXPLANATION] = "Check for the highest guaranteed quality the crafter can craft this recipe. And optimize for lowest crafting costs.\n\nIf toggled off. The highest reachable quality with inspiration will be optimized for crafting costs.",        
        
        -- Statistics
        [CraftSim.CONST.TEXT.STATISTICS_CDF_EXPLANATION] = "This is calculated by using the 'abramowitz and stegun' approximation (1985) of the CDF (Cumulative Distribution Function)\n\nYou will notice that its always around 50% for 1 craft.\nThis is because 0 is most of the time close to the average profit.\nAnd the chance of getting the mean of the CDF is always 50%.\n\nHowever, the rate of change can be very different between recipes.\nIf it is more likely to have a positive profit than a negative one, it will steadly increase.\nThis is of course also true for the other direction.",
        [CraftSim.CONST.TEXT.PROFIT_EXPLANATION] = 
        f.r("Warning: ") .. " Math ahead!\n\n" ..
        "When you craft something you have different chances for different outcomes based on your crafting stats.\n" ..
        "And in statistics this is called a " .. f.l("Probability Distribution.\n") .. 
        "However, you will notice that the different chances of your procs do not sum up to one\n" ..
        "(Which is required for such a distribution as it means you got a 100% chance that anything can happen)\n\n" ..
        "This is because procs like " .. f.bb("Inspiration ") .. "and" .. f.bb(" Multicraft") .. " can happen " .. f.g("at the same time.\n") ..
        "So we first need to convert our proc chances to a " .. f.l("Probability Distribution ") .. " with chances\n" .. 
        "summing to 100% (Which would mean that every case is covered)\n" ..
        "And for this we would need to calculate " .. f.l("every") .. " possible outcome of a craft\n\n" ..
        "Like: \n" ..
        f.p .. "What if " .. f.bb("nothing") .. " procs?" ..
        f.p .. "What if " .. f.bb("everything") .. " procs?" ..
        f.p .. "What if only " .. f.bb("Inspiration") .. " and " .. f.bb("Multicraft") .. " procs?" ..
        f.p .. "And so on..\n\n" ..
        "For a recipe that considers all three procs, that would be 2 to the power of 3 outcome possibilities, which is a neat 8.\n" ..
        "To get the chance of only " .. f.bb("Inspiration") .. " occuring, we have to consider all other procs!\n" ..
        "The chance to proc " .. f.l("only") .. f.bb(" Inspiration ") .. "is actually the chance to proc " .. f.bb("Inspiration\n") ..
        "But to " .. f.l("not ") .. "proc " .. f.bb("Multicraft") .. " or " .. f.bb("Resourcefulness.\n") ..
        "And Math tells us that the chance of something not occuring is 1 minus the chance of it occuring.\n" ..
        "So the chance to proc only " .. f.bb("Inspiration ") .. "is actually " .. f.g("inspirationChance * (1-multicraftChance) * (1-resourcefulnessChance)\n\n") ..
        "After calculating each possibility in that way the individual chances indeed sum up to one!\n" .. 
        "Which means we can now apply statistical formulas. The most interesting one in our case is the " .. f.bb("Expected Value") .. "\n" ..
        "Which is, as the name suggests, the value we can expect to get on average, or in our case, the " .. f.bb(" expected profit for a craft!\n") ..
        "\n" .. f.cm(CraftSim.MEDIA.IMAGES.EXPECTED_VALUE) .. "\n\n" ..
        "This tells us that the expected value " .. f.l("E") .. " of a probability distribution " .. f.l("X") .. " is the sum of all its values multiplied by their chance.\n" ..
        "So if we have one " .. f.bb("case A with chance 30%") .. " and profit " .. f.m(-100*10000) .. " and a " .. f.bb("case B with chance 70%") .." and profit " .. f.m(300*10000) .. " then the expected profit of that is\n" ..
        f.bb("\nE(X) = -100*0.3 + 300*0.7  ") .. "which is " .. f.m((-100*0.3 + 300*0.7)*10000) .. "\n" ..
        "You can view all cases for your current recipe in the " .. f.bb("Statistics") .. " window!"
        ,
        [CraftSim.CONST.TEXT.PROFIT_EXPLANATION_HSV] = 
        "The " .. f.l("Hidden Skill Value (HSV)") .. " is an additional random factor that occurs everytime you craft something. It is not mentioned anywhere in the game.\n" ..
        "However you can observe a visualization of the proc: When you craft something the " .. f.bb("Quality Meter") .. "\nfills up to a certain point. And this can 'shoot' quite a bit over your current shown skill.\n" ..
        "\n" .. f.cm(CraftSim.MEDIA.IMAGES.HSV_EXAMPLE) .. "\n\n" ..
        "This extra skill is always between 0% and 5% of your " .. f.bb("Base Recipe Difficulty") .. ".\nMeaning if you have a recipe with 400 difficulty. You can get up to 20 Skill.\n" ..
        "And tests tell us that this is " .. f.bb("uniformly distributed") .. ". Meaning every percent value has the same chance.\n" ..
        f.l("HSV") .. " can influence profits heavily when close to a quality! In CraftSim it is treated as an additional proc, like " .. f.bb("Inspiration") .. " or " .. f.bb("Multicraft.\n") ..
        "However, its effect is depending on your current skill, the recipe difficulty, and the skill you need to reach the next quality.\n" ..
        "So CraftSim calculates the " .. f.bb("missing skill") .. " to reach the next quality and converts it to " .. f.bb("percent relative to the recipe difficulty\n\n") ..
        "So for a recipe with 400 difficulty:if you have 190 Skill, and need 200 to reach the next quality, the missing skill would be 10\n" .. 
        "To get this value in percent relative to the difficulty you can calculate it like this: " .. f.bb("10 / (400 / 100)") .. " which is " .. f.bb("2.5%\n\n") ..
        "Then we need to remember that the " .. f.l("HSV") .. " can give us anywhere between 0 and 5 percent.\n" ..
        "So we need to calculate the " .. f.bb("chance of getting 2.5 or more") .. " when getting a random number between 0 and 5\n" .. 
        "to know the chance of " .. f.l("HSV") .. " giving us a higher quality.\n\n" ..
        "Statistics tell us that such a uniform chance to receive something between two boundaries is called a " .. f.l("Continuous Uniform Probability Distribution\n") ..
        "And thus there is a formula which yields exactly what we need:\n\n" ..
        f.bb("(upperBound - X) / (upperBound - lowerBound)") .. "\nwhere\n" ..
        f.bb("upperBound") .. " is 5\n" ..
        f.bb("lowerBound") .. " is 0\n" ..
        "and " .. f.bb("X") .. " is the desired value where we want equal or more from. In this case 2.5\n" ..
        "In this case we are right in the middle of the " .. f.l("HSV 'Area'") .. " so that we have a chance of\n\n" ..
        f.bb("(5 - 2.5) / (5 - 0) = 0.5") .. " aka 50% to get to next quality by " .. f.l("HSV") .. " alone.\n" ..
        "If we would have more missing skill we would have less chance and the other way round!\n" ..
        "Also, if you are missing skill of 5% or more the chance is 0 or negative, meaning it is not possible that " .. f.l("HSV") .. " alone triggers an upgrade.\n\n" ..
        "However, it is possible that you also reach the next quality when " .. f.bb("Inspiration") .. " and " .. f.l("HSV") .. " occur together and\n" .. 
        "the skill from " .. f.bb("Inspiration") .. " plus the skill from " .. f.l("HSV") .. " give you enough skill to reach the next quality! This is also considered by CraftSim."
        ,

        -- Options
        [CraftSim.CONST.TEXT.MULTICRAFT_CONSTANT_EXPLANATION] = "Default: 2.5\n\nCrafting Data from different data collecting players in beta and early Dragonflight suggest that\nthe maximum extra items one can receive from a multicraft proc is 1+C*y.\nWhere y is the base item amount for one craft and C is 2.5.\nHowever if you wish you can modify this value here.",
        [CraftSim.CONST.TEXT.RESOURCEFULNESS_CONSTANT_EXPLANATION] = "Default: 0.3\n\nCrafting Data from different data collecting players in beta and early Dragonflight suggest that\nthe average amount of items saved is 30% of the required quantity.\nHowever if you wish you can modify this value here.",

        -- Craft Data
        [CraftSim.CONST.TEXT.EXPECTED_CRAFTS_EXPLANATION] = "The expected number of crafts for an item is based on your " .. f.bb("Inspiration") .. ", " .. f.l("HSV Chance") .. " and " .. f.bb("Multicraft"),
        [CraftSim.CONST.TEXT.UPGRADE_CHANCE_EXPLANATION] = "The craft chance for an item is based on your\n" .. f.bb("Inspiration ") .. "and " .. f.l("HSV Chance"),
        [CraftSim.CONST.TEXT.EXPECTED_COSTS_EXPLANATION] = "The expected costs of an item is based on the " .. f.bb("Expected Crafts") .. ", the " .. f.bb("Crafting Costs") ..", and your "  .. f.bb("Resourcefulness") .. " and " .. f.bb("Multicraft"),
        [CraftSim.CONST.TEXT.CRAFT_DATA_EXPLANATION] = "Here you can take a " .. f.bb("'Snapshot'") .. " of your current recipe configuration for a target item\nThe saved data includes a snapshot of your current " .. f.bb("Profession Stats") .. "\nand calculates the " .. f.l("Expected Costs") .. " for an item based on that.\nYou can use " .. f.bb("Simulation Mode") .. " to finetune your configurations!",
        [CraftSim.CONST.TEXT.CRAFT_DATA_OVERRIDE_EXPLANATION] = "If this is checked, the item price will be the " .. f.l("Expected Costs") .. " of the saved Craft Data of this item.\nIf no Craft Data for this item exists " .. f.bb("OR") .. " the Auction House Price is lower, the Auction House price will be taken.",
        
        -- Cost Details
        [CraftSim.CONST.TEXT.COST_DETAILS_EXPLANATION] = "Here you can see an overview of all possible prices of the used materials.\nThe " .. f.bb("'Used Source'") .. " column indicates which one of the prices is used.\n\n" .. f.g("AH") .. " .. Auction House Price\n" .. f.l("OR") .. " .. Price Override\n" .. f.bb("Any Name") .. " .. Expected Costs from Craft Data for this Crafter\n\n" .. f.l("OR") .. " will always be used if set. " .. f.bb("Craft Data") .. " will only be used if lower than " .. f.g("AH"),
        -- Popups
        [CraftSim.CONST.TEXT.NO_PRICE_SOURCE_WARNING] = "No price source found!\n\n" ..
        "You need to have installed at least one of the\nfollowing price source addons to\nutilize CraftSim's profit calculations:\n\n\n",

        -- RecipeScan
        [CraftSim.CONST.TEXT.FORGEFINDER_EXPLANATION] = f.l("www.wowforgefinder.com") .. "\nis a website to search and offer " .. f.bb("WoW Crafting Orders"),
    }
end
