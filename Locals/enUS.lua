CraftSimAddonName, CraftSim = ...

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
    
        -- Simulation Mode
        [CraftSim.CONST.TEXT.SIMULATION_MODE_LABEL] = "Simulation Mode",
        [CraftSim.CONST.TEXT.SIMULATION_MODE_TITLE] = "CraftSim Simulation Mode",
        [CraftSim.CONST.TEXT.SIMULATION_MODE_TOOLTIP] = "CraftSim's Simulation Mode makes it possible to play around with a recipe without restrictions",

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
        [CraftSim.CONST.TEXT.HSV_EXPLANATION] = "HSV stands for 'Hidden Skill Value' and is a hidden skill increase between 0 to 5% of your recipe difficulty whenever you craft something.\n\nThis hidden skill value can bring you to the next quality similar to inspiration.\n\nHowever, the closer you are to the next quality the higher is the chance!",        
        
        -- Statistics
        [CraftSim.CONST.TEXT.STATISTICS_CDF_EXPLANATION] = "This is calculated by using the 'abramowitz and stegun' approximation (1985) of the CDF (Cumulative Distribution Function)\n\nYou will notice that its always around 50% for 1 craft.\nThis is because 0 is most of the time close to the average profit.\nAnd the chance of getting the mean of the CDF is always 50%.\n\nHowever, the rate of change can be very different between recipes.\nIf it is more likely to have a positive profit than a negative one, it will steadly increase.\nThis is of course also true for the other direction.",
        [CraftSim.CONST.TEXT.STAT_WEIGHTS_PROFIT_EXPLANATION] = 
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
        [CraftSim.CONST.TEXT.STAT_WEIGHTS_PROFIT_EXPLANATION_HSV] = 
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

        -- Popups
        [CraftSim.CONST.TEXT.POPUP_NO_PRICE_SOURCE_SYSTEM] = "No Supported Price Source Available!",
        [CraftSim.CONST.TEXT.POPUP_NO_PRICE_SOURCE_TITLE] = "CraftSim Price Source Warning",
        [CraftSim.CONST.TEXT.POPUP_NO_PRICE_SOURCE_WARNING] = "No price source found!\n\nYou need to have installed at least one of the\nfollowing price source addons to\nutilize CraftSim's profit calculations:\n\n\n",
        [CraftSim.CONST.TEXT.POPUP_NO_PRICE_SOURCE_WARNING_SUPPRESS] = "Do not show warning again",

        -- Materials Frame
        [CraftSim.CONST.TEXT.MATERIALS_TITLE] = "CraftSim Material Optimization",
        [CraftSim.CONST.TEXT.MATERIALS_INSPIRATION_BREAKPOINT] = "Reach Inspiration Breakpoint",
        [CraftSim.CONST.TEXT.MATERIALS_INSPIRATION_BREAKPOINT_TOOLTIP] = "Try to reach the skill breakpoint where an inspiration proc upgrades to the next higher quality with the cheapest material combination",
        [CraftSim.CONST.TEXT.MATERIALS_REACHABLE_QUALITY] = "Reachable Quality: ",
        [CraftSim.CONST.TEXT.MATERIALS_MISSING] = "Materials missing",
        [CraftSim.CONST.TEXT.MATERIALS_AVAILABLE] = "Materials available",
        [CraftSim.CONST.TEXT.MATERIALS_CHEAPER] = "Cheapest Materials",
        [CraftSim.CONST.TEXT.MATERIALS_BEST_COMBINATION] = "Best combination assigned",
        [CraftSim.CONST.TEXT.MATERIALS_NO_COMBINATION] = "No combination found \nto increase quality",
        [CraftSim.CONST.TEXT.MATERIALS_ASSIGN] = "Assign",

        -- Specialization Info Frame
        [CraftSim.CONST.TEXT.SPEC_INFO_TITLE] = "CraftSim Specialization Info",
        [CraftSim.CONST.TEXT.SPEC_INFO_SIMULATE_KNOWLEDGE_DISTRIBUTION] = "Simulate Knowledge Distribution",
        [CraftSim.CONST.TEXT.SPEC_INFO_NODE_TOOLTIP] = "This node grants you following stats for this recipe:",
        [CraftSim.CONST.TEXT.SPEC_INFO_WORK_IN_PROGRESS] = "SpecInfo Work in Progress",

        -- Crafting Results Frame
        [CraftSim.CONST.TEXT.CRAFT_RESULTS_TITLE] = "CraftSim Crafting Results",
        [CraftSim.CONST.TEXT.CRAFT_RESULTS_LOG] = "Craft Log",
        [CraftSim.CONST.TEXT.CRAFT_RESULTS_LOG_1] = "Profit: ",
        [CraftSim.CONST.TEXT.CRAFT_RESULTS_LOG_2] = "Inspired!",
        [CraftSim.CONST.TEXT.CRAFT_RESULTS_LOG_3] = "Multicraft: ",
        [CraftSim.CONST.TEXT.CRAFT_RESULTS_LOG_4] = "Resources Saved!: ",
        [CraftSim.CONST.TEXT.CRAFT_RESULTS_LOG_5] = "Chance: ",
        [CraftSim.CONST.TEXT.CRAFT_RESULTS_CRAFTED_ITEMS] = "Crafted Items",
        [CraftSim.CONST.TEXT.CRAFT_RESULTS_SESSION_PROFIT] = "Session Profit",
        [CraftSim.CONST.TEXT.CRAFT_RESULTS_RESET_DATA] = "Reset Data",
        [CraftSim.CONST.TEXT.CRAFT_RESULTS_EXPORT_JSON] = "Export JSON",
        [CraftSim.CONST.TEXT.CRAFT_RESULTS_RECIPE_STATISTICS] = "Recipe Statistics",
        [CraftSim.CONST.TEXT.CRAFT_RESULTS_NOTHING] = "Nothing crafted yet!",
        [CraftSim.CONST.TEXT.CRAFT_RESULTS_STATISTICS_1] = "Crafts: ",
        [CraftSim.CONST.TEXT.CRAFT_RESULTS_STATISTICS_2] = "Expected Ø Profit: ",
        [CraftSim.CONST.TEXT.CRAFT_RESULTS_STATISTICS_3] = "Real Ø Profit: ",
        [CraftSim.CONST.TEXT.CRAFT_RESULTS_STATISTICS_4] = "Real Profit: ",
        [CraftSim.CONST.TEXT.CRAFT_RESULTS_STATISTICS_5] = "Procs - Real / Expected: ",
        [CraftSim.CONST.TEXT.CRAFT_RESULTS_STATISTICS_6] = "Inspiration: ",
        [CraftSim.CONST.TEXT.CRAFT_RESULTS_STATISTICS_7] = "Multicraft: ",
        [CraftSim.CONST.TEXT.CRAFT_RESULTS_STATISTICS_8] = "- Ø Extra Items: ",
        [CraftSim.CONST.TEXT.CRAFT_RESULTS_STATISTICS_9] = "Resourcefulness Procs: ",
        [CraftSim.CONST.TEXT.CRAFT_RESULTS_STATISTICS_10] = "- Ø Saved Costs: ",
        [CraftSim.CONST.TEXT.CRAFT_RESULTS_STATISTICS_11] = "Profit: ",
        [CraftSim.CONST.TEXT.CRAFT_RESULTS_SAVED_REAGENTS] = "Saved Reagents",
        [CraftSim.CONST.TEXT.CRAFT_RESULTS_DISABLE_CHECKBOX] = f.l("Disable Craft Result Recording"),
        [CraftSim.CONST.TEXT.CRAFT_RESULTS_DISABLE_CHECKBOX_TOOLTIP] = "Enabling this stops the recording of any craft results when crafting and may " .. f.g("increase performance"),
        
        -- Stats Weight Frame
        [CraftSim.CONST.TEXT.STAT_WEIGHTS_TITLE] = "CraftSim Average Profit",
        [CraftSim.CONST.TEXT.STAT_WEIGHTS_EXPLANATION_TITLE] = "CraftSim Average Profit Explanation",
        [CraftSim.CONST.TEXT.STAT_WEIGHTS_SHOW_EXPLANATION_BUTTON] = "Show Explanation",
        [CraftSim.CONST.TEXT.STAT_WEIGHTS_HIDE_EXPLANATION_BUTTON] = "Hide Explanation",
        [CraftSim.CONST.TEXT.STAT_WEIGHTS_SHOW_STATISTICS_BUTTON] = "Show Statistics",
        [CraftSim.CONST.TEXT.STAT_WEIGHTS_HIDE_STATISTICS_BUTTON] = "Hide Statistics",
        [CraftSim.CONST.TEXT.STAT_WEIGHTS_PROFIT_CRAFT] = "Ø Profit / Craft: ",
        [CraftSim.CONST.TEXT.STAT_WEIGHTS_PROFIT_EXPLANATION_TAB] = "Basic Profit Calculation",
        [CraftSim.CONST.TEXT.STAT_WEIGHTS_PROFIT_EXPLANATION_HSV_TAB] = "HSV Consideration",

        -- Cost Details Frame
        [CraftSim.CONST.TEXT.COST_DETAILS_TITLE] = "CraftSim Cost Details",
        [CraftSim.CONST.TEXT.COST_DETAILS_EXPLANATION] = "Here you can see an overview of all possible prices of the used materials.\nThe " .. f.bb("'Used Source'") .. " column indicates which one of the prices is used.\n\n" .. f.g("AH") .. " .. Auction House Price\n" .. f.l("OR") .. " .. Price Override\n" .. f.bb("Any Name") .. " .. Expected Costs from Craft Data for this Crafter\n\n" .. f.l("OR") .. " will always be used if set. " .. f.bb("Craft Data") .. " will only be used if lower than " .. f.g("AH"),
        [CraftSim.CONST.TEXT.COST_DETAILS_CRAFTING_COSTS] = "Crafting Costs: ",
        [CraftSim.CONST.TEXT.COST_DETAILS_ITEM_HEADER] = "Item",
        [CraftSim.CONST.TEXT.COST_DETAILS_AH_PRICE_HEADER] = "AH Price",
        [CraftSim.CONST.TEXT.COST_DETAILS_OVERRIDE_HEADER] = "Override",
        [CraftSim.CONST.TEXT.COST_DETAILS_CRAFT_DATA_HEADER] = "Craft Data",
        [CraftSim.CONST.TEXT.COST_DETAILS_USED_SOURCE] = "Used Source",

        -- Craft Data Frame
        [CraftSim.CONST.TEXT.CRAFT_DATA_TITLE] = "CraftSim Craft Data",
        [CraftSim.CONST.TEXT.CRAFT_DATA_EXPLANATION] = "Here you can take a " .. f.bb("'Snapshot'") .. " of your current recipe configuration for a target item\nThe saved data includes a snapshot of your current " .. f.bb("Profession Stats") .. "\nand calculates the " .. f.l("Expected Costs") .. " for an item based on that.\nYou can use " .. f.bb("Simulation Mode") .. " to finetune your configurations!",
        [CraftSim.CONST.TEXT.CRAFT_DATA_RECIPE_ITEMS] = "Recipe Items",
        [CraftSim.CONST.TEXT.CRAFT_DATA_DELETE_ALL] = "Delete for all Recipes",
        [CraftSim.CONST.TEXT.CRAFT_DATA_DELETE_RECIPE] = "Delete for Recipe",
        [CraftSim.CONST.TEXT.CRAFT_DATA_CRAFTER] = "Crafter: ",
        [CraftSim.CONST.TEXT.CRAFT_DATA_EXPECTED_CRAFTS] = "Expected Crafts: ",
        [CraftSim.CONST.TEXT.CRAFT_DATA_EXPECTED_CRAFTS_EXPLANATION] = "The expected number of crafts for an item is based on your " .. f.bb("Inspiration") .. ", " .. f.l("HSV Chance") .. " and " .. f.bb("Multicraft"),
        [CraftSim.CONST.TEXT.CRAFT_DATA_CRAFTING_CHANCE] = "Crafting Chance: ",
        [CraftSim.CONST.TEXT.CRAFT_DATA_UPGRADE_CHANCE_EXPLANATION] = "The craft chance for an item is based on your\n" .. f.bb("Inspiration ") .. "and " .. f.l("HSV Chance"),
        [CraftSim.CONST.TEXT.CRAFT_DATA_EXPECTED_COSTS] = "Expected Costs: ",
        [CraftSim.CONST.TEXT.CRAFT_DATA_EXPECTED_COSTS_EXPLANATION] = "The expected costs of an item is based on the " .. f.bb("Expected Crafts") .. ", the " .. f.bb("Crafting Costs") ..", and your "  .. f.bb("Resourcefulness") .. " and " .. f.bb("Multicraft"),
        [CraftSim.CONST.TEXT.CRAFT_DATA_MINIMUM_COST] = "Minimum Costs: ",
        [CraftSim.CONST.TEXT.CRAFT_DATA_SAVE] = "Save",
        [CraftSim.CONST.TEXT.CRAFT_DATA_UPDATE] = "Update",
        [CraftSim.CONST.TEXT.CRAFT_DATA_UNREACHABLE] = "Unreachable",
        [CraftSim.CONST.TEXT.CRAFT_DATA_DELETE] = "Delete",
        [CraftSim.CONST.TEXT.CRAFT_DATA_SEND] = "Send to Player",
        [CraftSim.CONST.TEXT.CRAFT_DATA_SAVED_MATERIALS] = "Saved Material Configuration",
        [CraftSim.CONST.TEXT.CRAFT_DATA_NO_DATA] = "No data found for this item",
        [CraftSim.CONST.TEXT.CRAFT_DATA_OPTIONAL_MATERIALS] = "Optional Reagents",
        [CraftSim.CONST.TEXT.CRAFT_DATA_ITEM_HEADER] = "Item",
        [CraftSim.CONST.TEXT.CRAFT_DATA_CRAFTER_HEADER] = "Crafter",
        [CraftSim.CONST.TEXT.CRAFT_DATA_EXPECTED_COST_HEADER] = "Expected Cost",
        [CraftSim.CONST.TEXT.CRAFT_DATA_CHANCE_HEADER] = "Chance",
        [CraftSim.CONST.TEXT.CRAFT_DATA_OVERRIDE_EXPLANATION] = "If this is checked, the item price will be the " .. f.l("Expected Costs") .. " of the saved Craft Data of this item.\nIf no Craft Data for this item exists " .. f.bb("OR") .. " the Auction House Price is lower, the Auction House price will be taken.",

        -- Statistics Frame
        [CraftSim.CONST.TEXT.STATISTICS_TITLE] = "CraftSim Statistics",
        [CraftSim.CONST.TEXT.STATISTICS_EXPECTED_PROFIT] = "Expected Profit (μ)",
        [CraftSim.CONST.TEXT.STATISTICS_CHANCE_OF] = "Chance of ",
        [CraftSim.CONST.TEXT.STATISTICS_PROFIT] = "Profit",
        [CraftSim.CONST.TEXT.STATISTICS_AFTER] = " after",
        [CraftSim.CONST.TEXT.STATISTICS_CRAFTS] = "Crafts: ",
        [CraftSim.CONST.TEXT.STATISTICS_QUALITY_HEADER] = "Quality",
        [CraftSim.CONST.TEXT.STATISTICS_CHANCE_HEADER] = "Chance",
        [CraftSim.CONST.TEXT.STATISTICS_EXPECTED_CRAFTS_HEADER] = "Ø Expected Crafts",
        [CraftSim.CONST.TEXT.STATISTICS_INSPIRATION_HEADER] = "Inspiration",
        [CraftSim.CONST.TEXT.STATISTICS_MULTICRAFT_HEADER] = "Multicraft",
        [CraftSim.CONST.TEXT.STATISTICS_RESOURCEFULNESS_HEADER] = "Resourcefulness",
        [CraftSim.CONST.TEXT.STATISTICS_HSV_NEXT] = "HSV Next",
        [CraftSim.CONST.TEXT.STATISTICS_HSV_SKIP] = "HSV Skip",
        [CraftSim.CONST.TEXT.STATISTICS_EXPECTED_PROFIT_HEADER] = "Expected Profit",
        [CraftSim.CONST.TEXT.PROBABILITY_TABLE_TITLE] = "Recipe Probability Table",
        [CraftSim.CONST.TEXT.PROBABILITY_TABLE_EXPLANATION] = "This table shows all possible proc combinations of the current recipe.\n\n" .. f.l("HSV Next") ..  " .. HSV chance for next quality\n\n" .. f.l("HSV Skip") .. " .. HSV chance to skip a quality with inspiration",
        [CraftSim.CONST.TEXT.STATISTICS_EXPECTED_COSTS_HEADER] = "Ø Expected Costs per Item",
        [CraftSim.CONST.TEXT.STATISTICS_EXPECTED_COSTS_WITH_RETURN_HEADER] = "With Ø Sell Return",
        [CraftSim.CONST.TEXT.STATISTICS_EXPLANATION_ICON] = "This table gives you the average (Ø) expected crafts and costs per quality.\n\n" .. f.g("Chance") .. " is the chance of crafting this item considering your " .. f.bb("Inspiration") .. " and " .. f.l("HSV") .. "\n\n" .. f.g("Expected Crafts") .. " tells you how often, on average, you have to craft this recipe to craft this quality\n\n" .. f.g("Expected Costs per Item") .. " tells you, on average, what the costs for 1 resulting item in this quality are (this can be below the crafting costs since it is per item and considers stats like " .. f.bb("Multicraft") .. "\n\n" .. f.g("With Sell Return") .. " subtracts the sell value (considering AH Cut) of the (average number) of crafted items of lower quality until the desired quality is crafted",


        -- Customer Service Frame
        [CraftSim.CONST.TEXT.CUSTOMER_SERVICE_TITLE] = "CraftSim Customer Service",
        [CraftSim.CONST.TEXT.CUSTOMER_SERVICE_RECIPE_WHISPER] = "Recipe Whisper",
        [CraftSim.CONST.TEXT.CUSTOMER_SERVICE_LIVE_PREVIEW] = "Live Preview",
        [CraftSim.CONST.TEXT.CUSTOMER_SERVICE_WHISPER] = "Whisper",
        [CraftSim.CONST.TEXT.CUSTOMER_SERVICE_MESSAGE_FORMAT] = "Message Format",
        [CraftSim.CONST.TEXT.CUSTOMER_SERVICE_RESET_TO_DEFAULT] = "Reset to Defaults",
        [CraftSim.CONST.TEXT.CUSTOMER_SERVICE_ALLOW_CONNECTIONS] = "Allow Connections",
        [CraftSim.CONST.TEXT.CUSTOMER_SERVICE_SEND_INVITE] = "Send Invite",
        [CraftSim.CONST.TEXT.CUSTOMER_SERVICE_AUTO_REPLY_EXPLANATION] = "Enable the automatic answering with the highest possible results and material costs when someone whispers you the command and an item link for an item you can craft!",        
        [CraftSim.CONST.TEXT.CUSTOMER_SERVICE_AUTO_REPLY_FORMAT_EXPLANATION] = "Each line is a seperate chat message in the whisper.\n\nYou can use following labels to insert information about the recipe:\n%gc .. link of the guaranteed result quality\n%ic .. link of the result quality reachable with inspiration\n%insp .. your inspiration chance e.g. 18%\n%mc .. your multicraft chance\n%res .. your resourcefulness chance\n%cc .. the crafting costs\n%ccd .. the detailed costs per reagent used (preferably in its own line)\n%orl .. a simple list of all used optional reagents\n%rl .. a simple list of all required reagents",        
        [CraftSim.CONST.TEXT.CUSTOMER_SERVICE_LIVE_PREVIEW_EXPLANATION] = "Enable live crafting preview connections to you via CraftSim Preview Links.\nAnyone who has CraftSim and clicks the shared link can live connect to your crafting information to check out your crafting abilities",        
        [CraftSim.CONST.TEXT.CUSTOMER_SERVICE_HIGHEST_GUARANTEED_CHECKBOX] = "Highest Guaranteed",
        [CraftSim.CONST.TEXT.CUSTOMER_SERVICE_HIGHEST_GUARANTEED_CHECKBOX_EXPLANATION] = "Check for the highest guaranteed quality the crafter can craft this recipe. And optimize for lowest crafting costs.\n\nIf toggled off. The highest reachable quality with inspiration will be optimized for crafting costs.",        
        [CraftSim.CONST.TEXT.CUSTOMER_SERVICE_LIVE_PREVIEW_TITLE] = "CraftSim Live Preview",
        [CraftSim.CONST.TEXT.CUSTOMER_SERVICE_CRAFTER_PROFESSION] = "Crafter's Profession",
        [CraftSim.CONST.TEXT.CUSTOMER_SERVICE_LEARNED_RECIPES] = "Learned Recipes",
        [CraftSim.CONST.TEXT.CUSTOMER_SERVICE_LEARNED_RECIPES_INITIAL] = "Select Recipe",
        [CraftSim.CONST.TEXT.CUSTOMER_SERVICE_REQUESTING_UPDATE] = "Requesting Update",
        [CraftSim.CONST.TEXT.CUSTOMER_SERVICE_TIMEOUT] = "Timeout (Player Offline?)",
        [CraftSim.CONST.TEXT.CUSTOMER_SERVICE_REAGENT_OPTIONAL] = "Optional",
        [CraftSim.CONST.TEXT.CUSTOMER_SERVICE_REAGENT_FINISHING] = "Finishing",
        [CraftSim.CONST.TEXT.CUSTOMER_SERVICE_CRAFTING_COSTS] = "Crafting Costs",
        [CraftSim.CONST.TEXT.CUSTOMER_SERVICE_EXPECTED_RESULTS] = "Expected Result",
        [CraftSim.CONST.TEXT.CUSTOMER_SERVICE_EXPECTED_INSPIRATION] = "Chance for",
        [CraftSim.CONST.TEXT.CUSTOMER_SERVICE_REQUIRED_MATERIALS] = "Required Materials",
        [CraftSim.CONST.TEXT.CUSTOMER_SERVICE_REAGENTS_NONE] = "None",
        [CraftSim.CONST.TEXT.CUSTOMER_SERVICE_REAGENTS_LOCKED] = "Locked",

        -- Price Details Frame
        [CraftSim.CONST.TEXT.PRICE_DETAILS_TITLE] = "CraftSim Price Details",
        [CraftSim.CONST.TEXT.PRICE_DETAILS_INV_AH] = "Inv/AH",
        [CraftSim.CONST.TEXT.PRICE_DETAILS_ITEM] = "Item",
        [CraftSim.CONST.TEXT.PRICE_DETAILS_PRICE_ITEM] = "Price/Item",
        [CraftSim.CONST.TEXT.PRICE_DETAILS_PROFIT_ITEM] = "Profit/Item",

        -- Price Override Frame
        [CraftSim.CONST.TEXT.PRICE_OVERRIDE_TITLE] = "CraftSim Price Overrides",
        [CraftSim.CONST.TEXT.PRICE_OVERRIDE_REQUIRED_REAGENTS] = "Required Reagents",
        [CraftSim.CONST.TEXT.PRICE_OVERRIDE_OPTIONAL_REAGENTS] = "Optional Reagents",
        [CraftSim.CONST.TEXT.PRICE_OVERRIDE_FINISHING_REAGENTS] = "Finishing Reagents",
        [CraftSim.CONST.TEXT.PRICE_OVERRIDE_RESULT_ITEMS] = "Result Items",
        [CraftSim.CONST.TEXT.PRICE_OVERRIDE_ACTIVE_OVERRIDES] = "Active Overrides",
        [CraftSim.CONST.TEXT.PRICE_OVERRIDE_ACTIVE_OVERRIDES_TOOLTIP] = "'(as result)' -> price override only considered when item is a result of a recipe",
        [CraftSim.CONST.TEXT.PRICE_OVERRIDE_CLEAR_ALL] = "Clear All",
        [CraftSim.CONST.TEXT.PRICE_OVERRIDE_SAVE] = "Save",
        [CraftSim.CONST.TEXT.PRICE_OVERRIDE_SAVED] = "Saved",
        [CraftSim.CONST.TEXT.PRICE_OVERRIDE_REMOVE] = "Remove",
        
        -- Recipe Scan Frame
        [CraftSim.CONST.TEXT.RECIPE_SCAN_TITLE] = "CraftSim Recipe Scan",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_MODE] = "Scan Mode",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_SCAN_RECIPIES] = "Scan Recipes",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_SCANNING] = "Scanning",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_INCLUDE_NOT_LEARNED] = "Include not learned",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_INCLUDE_NOT_LEARNED_TOOLTIP] = "Include recipes you do not have learned in the recipe scan", 
        [CraftSim.CONST.TEXT.RECIPE_SCAN_INCLUDE_SOULBOUND] = "Include Soulbound",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_INCLUDE_SOULBOUND_TOOLTIP] = "Include soulbound recipes in the recipe scan.\n\nIt is recommended to set a price override (e.g. to simulate a target comission)\nin the Price Override Module for that recipe's crafted items", 
        [CraftSim.CONST.TEXT.RECIPE_SCAN_INCLUDE_GEAR] = "Include Gear",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_INCLUDE_GEAR_TOOLTIP] = "Include all form of gear recipes in the recipe scan", 
        [CraftSim.CONST.TEXT.RECIPE_SCAN_OPTIMIZE_TOOLS] = "Optimize Profession Tools", 
        [CraftSim.CONST.TEXT.RECIPE_SCAN_OPTIMIZE_TOOLS_TOOLTIP] = "For each recipe optimize your profession tools for profit\n\n",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_OPTIMIZE_TOOLS_WARNING] = "Might lower performance during scanning\nif you have a lot of tools in your inventory",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_RECIPE_HEADER] = "Recipe",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_LEARNED_HEADER] = "Learned",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_GUARANTEED_HEADER] = "Guaranteed",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_HIGHEST_RESULT_HEADER] = "Highest Result",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_AVERAGE_PROFIT_HEADER] = "Average Profit",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_TOP_GEAR_HEADER] = "Top Gear",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_INV_AH_HEADER] = "Inv/AH",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_SORT_BY_MARGIN] = "Sort by Profit %",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_SORT_BY_MARGIN_TOOLTIP] = "Sort the profit list by profit relative to crafting costs.\n(Requires a new scan)",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_USE_INSIGHT_CHECKBOX] = "Use " .. f.bb("Insight") .. " if possible",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_USE_INSIGHT_CHECKBOX_TOOLTIP] = "Use " .. f.bb("Illustrious Insight") .. " or\n" .. f.bb("Lesser Illustrious Insight") .. " as optional reagent for recipes that allow it.",

        -- Recipe Top Gear
        [CraftSim.CONST.TEXT.TOP_GEAR_TITLE] = "CraftSim Top Gear",
        [CraftSim.CONST.TEXT.TOP_GEAR_AUTOMATIC] = "Automatic",
        [CraftSim.CONST.TEXT.TOP_GEAR_AUTOMATIC_TOOLTIP] = "Automatically simulate Top Gear for your selected mode whenever a recipe updates.\n\nTurning this off may increase performance.",
        [CraftSim.CONST.TEXT.TOP_GEAR_SIMULATE] = "Simulate Top Gear",
        [CraftSim.CONST.TEXT.TOP_GEAR_EQUIP] = "Equip",
        [CraftSim.CONST.TEXT.TOP_GEAR_SIMULATE_QUALITY] = "Quality: ",
        [CraftSim.CONST.TEXT.TOP_GEAR_SIMULATE_EQUIPPED] = "Top Gear equipped",
        [CraftSim.CONST.TEXT.TOP_GEAR_SIMULATE_PROFIT_DIFFERENCE] = "Ø Profit Difference\n",
        [CraftSim.CONST.TEXT.TOP_GEAR_SIMULATE_NEW_MUTLICRAFT] = "New Multicraft\n",
        [CraftSim.CONST.TEXT.TOP_GEAR_SIMULATE_NEW_CRAFTING_SPEED] = "New Crafting Speed\n",
        [CraftSim.CONST.TEXT.TOP_GEAR_SIMULATE_NEW_RESOURCEFULNESS] = "New Resourcefulness\n",
        [CraftSim.CONST.TEXT.TOP_GEAR_SIMULATE_NEW_INSPIRATION] = "New Inspiration\n",
        [CraftSim.CONST.TEXT.TOP_GEAR_SIMULATE_NEW_SKILL] = "New Skill\n",
        [CraftSim.CONST.TEXT.TOP_GEAR_SIMULATE_UNHANDLED] = "Unhandled Sim Mode",

        [CraftSim.CONST.TEXT.TOP_GEAR_SIM_MODES_PROFIT] = "Top Profit",
        [CraftSim.CONST.TEXT.TOP_GEAR_SIM_MODES_SKILL] = "Top Skill",
        [CraftSim.CONST.TEXT.TOP_GEAR_SIM_MODES_INSPIRATION] = "Top Inspiration",
        [CraftSim.CONST.TEXT.TOP_GEAR_SIM_MODES_MULTICRAFT] = "Top Multicraft",
        [CraftSim.CONST.TEXT.TOP_GEAR_SIM_MODES_RESOURCEFULNESS] = "Top Resourcefulness",
        [CraftSim.CONST.TEXT.TOP_GEAR_SIM_MODES_CRAFTING_SPEED] = "Top Crafting Speed",

        -- Options
        [CraftSim.CONST.TEXT.OPTIONS_TITLE] = "CraftSim Options",
        [CraftSim.CONST.TEXT.OPTIONS_GENERAL_TAB] = "General",
        [CraftSim.CONST.TEXT.OPTIONS_GENERAL_PRICE_SOURCE] = "Price Source",
        [CraftSim.CONST.TEXT.OPTIONS_GENERAL_CURRENT_PRICE_SOURCE] = "Current Price Source: ",
        [CraftSim.CONST.TEXT.OPTIONS_GENERAL_NO_PRICE_SOURCE] = "No Supported Price Source Addon loaded!",
        [CraftSim.CONST.TEXT.OPTIONS_GENERAL_SHOW_PROFIT] = "Show Profit Percentage",
        [CraftSim.CONST.TEXT.OPTIONS_GENERAL_SHOW_PROFIT_TOOLTIP] = "Show the percentage of profit to crafting costs besides the gold value",
        [CraftSim.CONST.TEXT.OPTIONS_GENERAL_REMEMBER_LAST_RECIPE] = "Remember Last Recipe",
        [CraftSim.CONST.TEXT.OPTIONS_GENERAL_REMEMBER_LAST_RECIPE_TOOLTIP] = "Reopen last selected recipe when opening the crafting window",
        [CraftSim.CONST.TEXT.OPTIONS_GENERAL_DETAILED_TOOLTIP] = "Detailed Last Crafting Information",
        [CraftSim.CONST.TEXT.OPTIONS_GENERAL_DETAILED_TOOLTIP_TOOLTIP] = "Show the complete breakdown of your last used material combination in an item tooltip",
        [CraftSim.CONST.TEXT.OPTIONS_GENERAL_SUPPORTED_PRICE_SOURCES] = "Supported Price Sources:",
        [CraftSim.CONST.TEXT.OPTIONS_PERFORMANCE_RAM] = "Enable RAM cleanup while crafting",
        [CraftSim.CONST.TEXT.OPTIONS_PERFORMANCE_RAM_TOOLTIP] = "When enabled, CraftSim will clear your RAM every specified number of crafts from unused data to prevent memory from building up.\nMemory Build Up can also happen because of other addons and is not CraftSim specific.\nA cleanup will affect the whole WoW RAM Usage.",
        [CraftSim.CONST.TEXT.OPTIONS_MODULES_TAB] = "Modules",
        [CraftSim.CONST.TEXT.OPTIONS_PROFIT_CALCULATION_TAB] = "Profit Calculation",
        [CraftSim.CONST.TEXT.OPTIONS_CRAFTING_TAB] = "Crafting",
        [CraftSim.CONST.TEXT.OPTIONS_TSM_RESET] = "Reset Default",
        [CraftSim.CONST.TEXT.OPTIONS_TSM_INVALID_EXPRESSION] = "Expression Invalid",
        [CraftSim.CONST.TEXT.OPTIONS_TSM_VALID_EXPRESSION] = "Expression Valid",
        [CraftSim.CONST.TEXT.OPTIONS_MODULES_TRANSPARENCY] = "Transparency",
        [CraftSim.CONST.TEXT.OPTIONS_MODULES_MATERIALS] = "Material Optimizing Module",
        [CraftSim.CONST.TEXT.OPTIONS_MODULES_AVERAGE_PROFIT] = "Average Profit Module",
        [CraftSim.CONST.TEXT.OPTIONS_MODULES_TOP_GEAR] = "Top Gear Module",
        [CraftSim.CONST.TEXT.OPTIONS_MODULES_COST_OVERVIEW] = "Cost Overview Module",
        [CraftSim.CONST.TEXT.OPTIONS_MODULES_SPECIALIZATION_INFO] = "Specialization Info Module",
        [CraftSim.CONST.TEXT.OPTIONS_MODULES_CUSTOMER_HISTORY_SIZE] = "Customer History max messages per client",
        [CraftSim.CONST.TEXT.OPTIONS_PROFIT_CALCULATION_OFFSET] = "Offset Skill Breakpoints by 1",
        [CraftSim.CONST.TEXT.OPTIONS_PROFIT_CALCULATION_OFFSET_TOOLTIP] = "The material combination suggestion will try to reach the breakpoint + 1 instead of matching the exact skill required",
        [CraftSim.CONST.TEXT.OPTIONS_PROFIT_CALCULATION_MULTICRAFT_CONSTANT] = "Multicraft Constant",
        [CraftSim.CONST.TEXT.OPTIONS_PROFIT_CALCULATION_MULTICRAFT_CONSTANT_EXPLANATION] = "Default: 2.5\n\nCrafting Data from different data collecting players in beta and early Dragonflight suggest that\nthe maximum extra items one can receive from a multicraft proc is 1+C*y.\nWhere y is the base item amount for one craft and C is 2.5.\nHowever if you wish you can modify this value here.",
        [CraftSim.CONST.TEXT.OPTIONS_PROFIT_CALCULATION_RESOURCEFULNESS_CONSTANT] = "Resourcefulness Constant",
        [CraftSim.CONST.TEXT.OPTIONS_PROFIT_CALCULATION_RESOURCEFULNESS_CONSTANT_EXPLANATION] = "Default: 0.3\n\nCrafting Data from different data collecting players in beta and early Dragonflight suggest that\nthe average amount of items saved is 30% of the required quantity.\nHowever if you wish you can modify this value here.",
        [CraftSim.CONST.TEXT.OPTIONS_GENERAL_SHOW_NEWS_CHECKBOX] = "Show " .. f.bb("News") .. " Popup",
        [CraftSim.CONST.TEXT.OPTIONS_GENERAL_SHOW_NEWS_CHECKBOX_TOOLTIP] = "Show the " .. f.bb("News") .. " Popup for new " .. f.l("CraftSim") .. " Update Information when logging into the game",

        -- Control Panel
        [CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_TOP_GEAR_LABEL] = "Top Gear",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_TOP_GEAR_TOOLTIP] = "Shows the best available profession gear combination based on the selected mode",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_PRICE_DETAILS_LABEL] = "Price Details",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_PRICE_DETAILS_TOOLTIP] = "Shows a sell price and profit overview by resulting item quality",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_AVERAGE_PROFIT_LABEL] = "Average Profit",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_AVERAGE_PROFIT_TOOLTIP] = "Shows the average profit based on your profession stats and the profit stat weights as gold per point.",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_MATERIAL_OPTIMIZATION_LABEL] = "Material Optimization",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_MATERIAL_OPTIMIZATION_TOOLTIP] = "Suggests the cheapest materials to reach the highest quality/inspiration threshold.",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_PRICE_OVERRIDES_LABEL] = "Price Overrides",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_PRICE_OVERRIDES_TOOLTIP] = "Override prices of any materials, optional materials and craft results for all recipes or for one recipe specifically. You can also set an item to use Craft Data as price.",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_CRAFT_DATA_LABEL] = "Craft Data",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_CRAFT_DATA_TOOLTIP] = "Edit the saved configurations for crafting commodities of different qualities to show in tooltips and to calculate crafting costs",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_SPECIALIZATION_INFO_LABEL] = "Specialization Info",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_SPECIALIZATION_INFO_TOOLTIP] = "Shows how your profession specializations affect this recipe and makes it possible to simulate any configuration!",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_CRAFT_RESULTS_LABEL] = "Craft Results",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_CRAFT_RESULTS_TOOLTIP] = "Show a crafting log and statistics about your crafts!",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_COST_DETAILS_LABEL] = "Cost Details",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_COST_DETAILS_TOOLTIP] = "Module that shows detailed information about crafting costs",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_RECIPE_SCAN_LABEL] = "Recipe Scan",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_RECIPE_SCAN_TOOLTIP] = "Module that scans your recipe list based on various options",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_CUSTOMER_SERVICE_LABEL] = "Customer Service",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_CUSTOMER_SERVICE_TOOLTIP] = "Module that offers various options to interact with potential customers",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_CUSTOMER_HISTORY_LABEL] = "Customer History",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_CUSTOMER_HISTORY_TOOLTIP] = "Module that provides a history of conversations with customers, crafted items and commissions",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_RESET_FRAMES] = "Reset Frame Positions",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_OPTIONS] = "Options",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_NEWS] = "News",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_FORGEFINDER_EXPORT] = f.l("ForgeFinder") .. " Export",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_FORGEFINDER_EXPORTING] = "Exporting",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_FORGEFINDER_EXPLANATION] = f.l("www.wowforgefinder.com") .. "\nis a website to search and offer " .. f.bb("WoW Crafting Orders"),
        [CraftSim.CONST.TEXT.CONTROL_PANEL_DEBUG] = "Debug",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_TITLE] = "Control Panel",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_SUPPORTERS_BUTTON] = f.patreon("Supporters"),

        -- Supporters
        [CraftSim.CONST.TEXT.SUPPORTERS_DESCRIPTION] = f.l("Thank you to all those awesome people!"),

        -- Customer History
        [CraftSim.CONST.TEXT.CUSTOMER_HISTORY_TITLE] = "CraftSim Customer History",
        [CraftSim.CONST.TEXT.CUSTOMER_HISTORY_DROPDOWN_LABEL] = "Choose a customer",
        [CraftSim.CONST.TEXT.CUSTOMER_HISTORY_TOTAL_TIP] = "Total tip: ",
        [CraftSim.CONST.TEXT.CUSTOMER_HISTORY_FROM] = "From",
        [CraftSim.CONST.TEXT.CUSTOMER_HISTORY_TO] = "To",
        [CraftSim.CONST.TEXT.CUSTOMER_HISTORY_FOR] = "For",
        [CraftSim.CONST.TEXT.CUSTOMER_HISTORY_CRAFT_FORMAT] = "Crafted %s for %s",
        [CraftSim.CONST.TEXT.CUSTOMER_HISTORY_DELETE_BUTTON] = "Remove customer",
    }
end
