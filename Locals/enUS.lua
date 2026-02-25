---@class CraftSim
local CraftSim = select(2, ...)

CraftSim.LOCAL_EN = {}

function CraftSim.LOCAL_EN:GetData()
    local f = CraftSim.GUTIL:GetFormatter()
    local cm = function(i, s) return CraftSim.MEDIA:GetAsTextIcon(i, s) end
    return {
        -- REQUIRED:
        [CraftSim.CONST.TEXT.STAT_MULTICRAFT] = "Multicraft",
        [CraftSim.CONST.TEXT.STAT_RESOURCEFULNESS] = "Resourcefulness",
        [CraftSim.CONST.TEXT.STAT_INGENUITY] = "Ingenuity",
        [CraftSim.CONST.TEXT.STAT_CRAFTINGSPEED] = "Crafting Speed",
        [CraftSim.CONST.TEXT.EQUIP_MATCH_STRING] = "Equip:",
        [CraftSim.CONST.TEXT.ENCHANTED_MATCH_STRING] = "Enchanted:",

        -- OPTIONAL (Defaulting to EN if not available):

        -- shared prof cds
        [CraftSim.CONST.TEXT.DF_ALCHEMY_TRANSMUTATIONS] = "DF - Transmutations",

        -- expansions

        [CraftSim.CONST.TEXT.EXPANSION_VANILLA] = "Classic",
        [CraftSim.CONST.TEXT.EXPANSION_THE_BURNING_CRUSADE] = "The Burning Crusade",
        [CraftSim.CONST.TEXT.EXPANSION_WRATH_OF_THE_LICH_KING] = "Wrath of the Lich King",
        [CraftSim.CONST.TEXT.EXPANSION_CATACLYSM] = "Cataclysm",
        [CraftSim.CONST.TEXT.EXPANSION_MISTS_OF_PANDARIA] = "Mists of Pandaria",
        [CraftSim.CONST.TEXT.EXPANSION_WARLORDS_OF_DRAENOR] = "Warlords of Draenor",
        [CraftSim.CONST.TEXT.EXPANSION_LEGION] = "Legion",
        [CraftSim.CONST.TEXT.EXPANSION_BATTLE_FOR_AZEROTH] = "Battle of Azeroth",
        [CraftSim.CONST.TEXT.EXPANSION_SHADOWLANDS] = "Shadowlands",
        [CraftSim.CONST.TEXT.EXPANSION_DRAGONFLIGHT] = "Dragonflight",
        [CraftSim.CONST.TEXT.EXPANSION_THE_WAR_WITHIN] = "The War Within",
        [CraftSim.CONST.TEXT.EXPANSION_MIDNIGHT] = "Midnight",

        -- professions

        [CraftSim.CONST.TEXT.PROFESSIONS_BLACKSMITHING] = "Blacksmithing",
        [CraftSim.CONST.TEXT.PROFESSIONS_LEATHERWORKING] = "Leatherworking",
        [CraftSim.CONST.TEXT.PROFESSIONS_ALCHEMY] = "Alchemy",
        [CraftSim.CONST.TEXT.PROFESSIONS_HERBALISM] = "Herbalism",
        [CraftSim.CONST.TEXT.PROFESSIONS_COOKING] = "Cooking",
        [CraftSim.CONST.TEXT.PROFESSIONS_MINING] = "Mining",
        [CraftSim.CONST.TEXT.PROFESSIONS_TAILORING] = "Tailoring",
        [CraftSim.CONST.TEXT.PROFESSIONS_ENGINEERING] = "Engineering",
        [CraftSim.CONST.TEXT.PROFESSIONS_ENCHANTING] = "Enchanting",
        [CraftSim.CONST.TEXT.PROFESSIONS_FISHING] = "Fishing",
        [CraftSim.CONST.TEXT.PROFESSIONS_SKINNING] = "Skinning",
        [CraftSim.CONST.TEXT.PROFESSIONS_JEWELCRAFTING] = "Jewelcrafting",
        [CraftSim.CONST.TEXT.PROFESSIONS_INSCRIPTION] = "Inscription",

        -- Other Statnames

        [CraftSim.CONST.TEXT.STAT_SKILL] = "Skill",
        [CraftSim.CONST.TEXT.STAT_MULTICRAFT_BONUS] = "Multicraft ExtraItems",
        [CraftSim.CONST.TEXT.STAT_RESOURCEFULNESS_BONUS] = "Resourcefulness ExtraItems",
        [CraftSim.CONST.TEXT.STAT_CRAFTINGSPEED_BONUS] = "Crafting Speed",
        [CraftSim.CONST.TEXT.STAT_INGENUITY_BONUS] = "Ingenuity Saved Conc",
        [CraftSim.CONST.TEXT.STAT_INGENUITY_LESS_CONCENTRATION] = "Less Concentration Use",
        [CraftSim.CONST.TEXT.STAT_PHIAL_EXPERIMENTATION] = "Phial Breakthrough",
        [CraftSim.CONST.TEXT.STAT_POTION_EXPERIMENTATION] = "Potion Breakthrough",

        -- Profit Breakdown Tooltips
        [CraftSim.CONST.TEXT.RESOURCEFULNESS_EXPLANATION_TOOLTIP] =
        "Resourcefulness procs for every reagent individually and then saves about 30% of its quantity.\n\nThe average value it saves is the average saved value of EVERY combination and their chances.\n(All reagents proccing at once is very unlikely but saves a lot)\n\nThe average total saved reagent costs is the sum of the saved reagent costs of all combinations weighted against their chance.",

        [CraftSim.CONST.TEXT.RECIPE_DIFFICULTY_EXPLANATION_TOOLTIP] =
        "Recipe difficulty determines where the breakpoints of the different qualities are.\n\nFor recipes with five qualities they are at 20%, 50%, 80% and 100% recipe difficulty as skill.\nFor recipes with three qualities they are at 50% and 100%",
        [CraftSim.CONST.TEXT.MULTICRAFT_EXPLANATION_TOOLTIP] =
        "Multicraft gives you a chance of crafting more items than you would usually produce with a recipe.\n\nThe additional amount is usually between 1 and 2.5y\nwhere y = the usual amount 1 craft yields.",
        [CraftSim.CONST.TEXT.REAGENTSKILL_EXPLANATION_TOOLTIP] =
        "The quality of your reagents can give you a maximum of 40% of the base recipe difficulty as bonus skill.\n\nAll Q1 Reagents: 0% Bonus\nAll Q2 Reagents: 20% Bonus\nAll Q3 Reagents: 40% Bonus\n\nThe skill is calculated by the amount of reagents of each quality weighted against their quality\nand a specific weight value that is unique to each individual crafting reagent item with quality\n\nThis is however different for recrafts. There the maximum the reagents can increase the quality\nis dependent on the quality of reagents the item was originally crafted with.\nThe exact workings are not known.\nHowever, CraftSim internally compares the achieved skill with all q3 and calculates\nthe max skill increase based on that.",
        [CraftSim.CONST.TEXT.REAGENTFACTOR_EXPLANATION_TOOLTIP] =
        "The maximum the reagents can contribute to a recipe is most of the time 40% of the base recipe difficulty.\n\nHowever in the case of recrafting, this value can vary based on previous crafts\nand the quality of reagents that were used.",

        -- Simulation Mode
        [CraftSim.CONST.TEXT.SIMULATION_MODE_NONE] = "None",
        [CraftSim.CONST.TEXT.SIMULATION_MODE_LABEL] = "Simulation Mode",
        [CraftSim.CONST.TEXT.SIMULATION_MODE_TITLE] = "CraftSim Simulation Mode",
        [CraftSim.CONST.TEXT.SIMULATION_MODE_TOOLTIP] =
        "CraftSim's Simulation Mode makes it possible to play around with a recipe without restrictions",
        [CraftSim.CONST.TEXT.SIMULATION_MODE_OPTIONAL] = "Optional #",
        [CraftSim.CONST.TEXT.SIMULATION_MODE_FINISHING] = "Finishing #",
        [CraftSim.CONST.TEXT.SIMULATION_MODE_QUALITY_BUTTON_TOOLTIP] = "Max All Reagents of Quality ",
        [CraftSim.CONST.TEXT.SIMULATION_MODE_CLEAR_BUTTON] = "Clear",
        [CraftSim.CONST.TEXT.SIMULATION_MODE_CONCENTRATION] = " Concentration",
        [CraftSim.CONST.TEXT.SIMULATION_MODE_CONCENTRATION_COST] = "Concentration Cost: ",

        -- Details Frame
        [CraftSim.CONST.TEXT.RECIPE_DIFFICULTY_LABEL] = "Recipe Difficulty: ",
        [CraftSim.CONST.TEXT.MULTICRAFT_LABEL] = "Multicraft: ",
        [CraftSim.CONST.TEXT.RESOURCEFULNESS_LABEL] = "Resourcefulness: ",
        [CraftSim.CONST.TEXT.RESOURCEFULNESS_BONUS_LABEL] = "Resourcefulness Item Bonus: ",
        [CraftSim.CONST.TEXT.CONCENTRATION_LABEL] = "Concentration: ",
        [CraftSim.CONST.TEXT.REAGENT_QUALITY_BONUS_LABEL] = "Reagent Quality Bonus: ",
        [CraftSim.CONST.TEXT.REAGENT_QUALITY_MAXIMUM_LABEL] = "Reagent Quality Maximum %: ",
        [CraftSim.CONST.TEXT.EXPECTED_QUALITY_LABEL] = "Expected Quality: ",
        [CraftSim.CONST.TEXT.NEXT_QUALITY_LABEL] = "Next Quality: ",
        [CraftSim.CONST.TEXT.MISSING_SKILL_LABEL] = "Missing Skill: ",
        [CraftSim.CONST.TEXT.SKILL_LABEL] = "Skill: ",
        [CraftSim.CONST.TEXT.MULTICRAFT_BONUS_LABEL] = "Multicraft Item Bonus: ",

        -- Statistics
        [CraftSim.CONST.TEXT.STATISTICS_CDF_EXPLANATION] =
        "This is calculated by using the 'abramowitz and stegun' approximation (1985) of the CDF (Cumulative Distribution Function)\n\nYou will notice that its always around 50% for 1 craft.\nThis is because 0 is most of the time close to the average profit.\nAnd the chance of getting the mean of the CDF is always 50%.\n\nHowever, the rate of change can be very different between recipes.\nIf it is more likely to have a positive profit than a negative one, it will steadly increase.\nThis is of course also true for the other direction.",
        [CraftSim.CONST.TEXT.EXPLANATIONS_PROFIT_CALCULATION_EXPLANATION] =
            f.r("Warning: ") .. " Math ahead!\n\n" ..
            "When you craft something you have different chances for different outcomes based on your crafting stats.\n" ..
            "And in statistics this is called a " .. f.l("Probability Distribution.\n") ..
            "However, you will notice that the different chances of your procs do not sum up to one\n" ..
            "(Which is required for such a distribution as it means you got a 100% chance that anything can happen)\n\n" ..
            "This is because procs like " ..
            f.bb("Resourcefulness ") .. "and" .. f.bb(" Multicraft") .. " can happen " .. f.g("at the same time.\n") ..
            "So we first need to convert our proc chances to a " ..
            f.l("Probability Distribution ") .. " with chances\n" ..
            "summing to 100% (Which would mean that every case is covered)\n" ..
            "And for this we would need to calculate " .. f.l("every") .. " possible outcome of one craft\n\n" ..
            "Like: \n" ..
            f.p .. "What if " .. f.bb("nothing") .. " procs?\n" ..
            f.p .. "What if either " .. f.bb("Resourcefulness") .. " or " .. f.bb("Multicraft") .. " procs?\n" ..
            f.p .. "What if both " .. f.bb("Resourcefulness") .. " and " .. f.bb("Multicraft") .. " procs?\n" ..
            f.p .. "And so on..\n\n" ..
            "For a recipe that considers all procs, that would be 2 to the power of 2 outcome possibilities, which is a neat 4.\n" ..
            "To get the chance of only " ..
            f.bb("Multicraft") .. " occuring, we have to consider all other possibilities!\n" ..
            "The chance to proc " ..
            f.l("only") .. f.bb(" Multicraft ") .. "is actually the chance to proc " .. f.bb("Multicraft\n") ..
            "and " .. f.l("not ") .. "proc " .. f.bb("Resourcefulness\n") ..
            "And Math tells us that the chance of something not occuring is 1 minus the chance of it occuring.\n" ..
            "So the chance to proc only " ..
            f.bb("Multicraft ") ..
            "is actually " .. f.g("multicraftChance * (1-resourcefulnessChance)\n\n") ..
            "After calculating each possibility in that way the individual chances indeed sum up to one!\n" ..
            "Which means we can now apply statistical formulas. The most interesting one in our case is the " ..
            f.bb("Expected Value") .. "\n" ..
            "Which is, as the name suggests, the value we can expect to get on average, or in our case, the " ..
            f.bb(" expected profit for a craft!\n") ..
            "\n" .. cm(CraftSim.MEDIA.IMAGES.EXPECTED_VALUE) .. "\n\n" ..
            "This tells us that the expected value " ..
            f.l("E") ..
            " of a probability distribution " ..
            f.l("X") .. " is the sum of all its values multiplied by their chance.\n" ..
            "So if we have one " ..
            f.bb("case A with chance 30%") ..
            " and profit " ..
            CraftSim.UTIL:FormatMoney(-100 * 10000, true) ..
            " and a " ..
            f.bb("case B with chance 70%") ..
            " and profit " .. CraftSim.UTIL:FormatMoney(300 * 10000, true) .. " then the expected profit of that is\n" ..
            f.bb("\nE(X) = -100*0.3 + 300*0.7  ") ..
            "which is " .. CraftSim.UTIL:FormatMoney((-100 * 0.3 + 300 * 0.7) * 10000, true) .. "\n" ..
            "You can view all cases for your current recipe in the " .. f.bb("Statistics") .. " window!"
        ,

        -- Popups
        [CraftSim.CONST.TEXT.POPUP_NO_PRICE_SOURCE_SYSTEM] = "No Supported Price Source Available!",
        [CraftSim.CONST.TEXT.POPUP_NO_PRICE_SOURCE_TITLE] = "CraftSim Price Source Warning",
        [CraftSim.CONST.TEXT.POPUP_NO_PRICE_SOURCE_WARNING] =
        "No price source found!\n\nYou need to have installed at least one of the\nfollowing price source addons to\nutilize CraftSim's profit calculations:\n\n\n",
        [CraftSim.CONST.TEXT.POPUP_NO_PRICE_SOURCE_WARNING_SUPPRESS] = "Do not show warning again",
        [CraftSim.CONST.TEXT.POPUP_NO_PRICE_SOURCE_WARNING_ACCEPT] = "OK",

        -- Reagents Frame
        [CraftSim.CONST.TEXT.REAGENT_OPTIMIZATION_TITLE] = "CraftSim Reagent Optimization",
        [CraftSim.CONST.TEXT.REAGENTS_REACHABLE_QUALITY] = "Reachable Quality: ",
        [CraftSim.CONST.TEXT.REAGENTS_MISSING] = "Reagents missing",
        [CraftSim.CONST.TEXT.REAGENTS_AVAILABLE] = "Reagents available",
        [CraftSim.CONST.TEXT.REAGENTS_CHEAPER] = "Cheapest Reagents",
        [CraftSim.CONST.TEXT.REAGENTS_BEST_COMBINATION] = "Best combination assigned",
        [CraftSim.CONST.TEXT.REAGENTS_NO_COMBINATION] = "No combination found \nto increase quality",
        [CraftSim.CONST.TEXT.REAGENTS_ASSIGN] = "Assign",
        [CraftSim.CONST.TEXT.REAGENTS_MAXIMUM_QUALITY] = "Maximum Quality: ",
        [CraftSim.CONST.TEXT.REAGENTS_AVERAGE_PROFIT_LABEL] = "Average Ø Profit: ",
        [CraftSim.CONST.TEXT.REAGENTS_AVERAGE_PROFIT_TOOLTIP] =
            f.bb("The Average Profit per Craft") .. " when using " .. f.l("this reagent allocation"),
        [CraftSim.CONST.TEXT.REAGENTS_OPTIMIZE_BEST_ASSIGNED] = "Best Reagents Assigned",
        [CraftSim.CONST.TEXT.REAGENTS_CONCENTRATION_LABEL] = "Concentration: ",
        [CraftSim.CONST.TEXT.REAGENTS_OPTIMIZE_INFO] = "Shift + LMB on numbers to put the item link in chat",
        [CraftSim.CONST.TEXT.ADVANCED_OPTIMIZATION_BUTTON] = "Advanced Optimization",
        [CraftSim.CONST.TEXT.REAGENTS_OPTIMIZE_TOOLTIP] =
            "(Resets on Edit)\nEnables " ..
            f.gold("Concentration Value") .. " and " .. f.bb("Finishing Reagent ") .. " Optimization",

        -- Specialization Info Frame
        [CraftSim.CONST.TEXT.SPEC_INFO_TITLE] = "CraftSim Specialization Info",
        [CraftSim.CONST.TEXT.SPEC_INFO_SIMULATE_KNOWLEDGE_DISTRIBUTION] = "Simulate Knowledge Distribution",
        [CraftSim.CONST.TEXT.SPEC_INFO_NODE_TOOLTIP] = "This node grants you following stats for this recipe:",
        [CraftSim.CONST.TEXT.SPEC_INFO_WORK_IN_PROGRESS] = "No Data Available",

        -- Crafting Results Frame
        [CraftSim.CONST.TEXT.CRAFT_LOG_TITLE] = "CraftSim Craft Log",
        [CraftSim.CONST.TEXT.CRAFT_LOG_ADV_TITLE] = "CraftSim Advanced Craft Log",
        [CraftSim.CONST.TEXT.CRAFT_LOG_LOG] = "Craft Log",
        [CraftSim.CONST.TEXT.CRAFT_LOG_LOG_1] = "Profit: ",
        [CraftSim.CONST.TEXT.CRAFT_LOG_LOG_2] = "Concentration Saved: ",
        [CraftSim.CONST.TEXT.CRAFT_LOG_LOG_3] = "Multicraft: ",
        [CraftSim.CONST.TEXT.CRAFT_LOG_LOG_4] = "Resources Saved: ",
        [CraftSim.CONST.TEXT.CRAFT_LOG_LOG_5] = "Chance: ",
        [CraftSim.CONST.TEXT.CRAFT_LOG_CRAFTED_ITEMS] = "Crafted Items",
        [CraftSim.CONST.TEXT.CRAFT_LOG_SESSION_PROFIT] = "Session Profit: ",
        [CraftSim.CONST.TEXT.CRAFT_LOG_RESET_DATA] = "Reset Data",
        [CraftSim.CONST.TEXT.CRAFT_LOG_EXPORT_JSON] = "Export JSON",
        [CraftSim.CONST.TEXT.CRAFT_LOG_RECIPE_STATISTICS] = "Recipe Statistics",
        [CraftSim.CONST.TEXT.CRAFT_LOG_NOTHING] = "Nothing crafted yet!",
        [CraftSim.CONST.TEXT.CRAFT_LOG_CALCULATION_COMPARISON_NUM_CRAFTS_PREFIX] = "Crafts: ",
        [CraftSim.CONST.TEXT.CRAFT_LOG_STATISTICS_2] = "Expected Ø Profit: ",
        [CraftSim.CONST.TEXT.CRAFT_LOG_STATISTICS_3] = "Real Ø Profit: ",
        [CraftSim.CONST.TEXT.CRAFT_LOG_STATISTICS_4] = "Real Profit: ",
        [CraftSim.CONST.TEXT.CRAFT_LOG_STATISTICS_5] = "Procs - Real / Expected: ",
        [CraftSim.CONST.TEXT.CRAFT_LOG_STATISTICS_7] = "Multicraft: ",
        [CraftSim.CONST.TEXT.CRAFT_LOG_STATISTICS_8] = "- Ø Extra Items: ",
        [CraftSim.CONST.TEXT.CRAFT_LOG_STATISTICS_9] = "Resourcefulness Procs: ",
        [CraftSim.CONST.TEXT.CRAFT_LOG_CALCULATION_COMPARISON_NUM_CRAFTS_PREFIX0] = "- Ø Saved Costs: ",
        [CraftSim.CONST.TEXT.CRAFT_LOG_CALCULATION_COMPARISON_NUM_CRAFTS_PREFIX1] = "Profit: ",
        [CraftSim.CONST.TEXT.CRAFT_LOG_SAVED_REAGENTS] = "Saved Reagents",
        [CraftSim.CONST.TEXT.CRAFT_LOG_DISABLE_CHECKBOX] = f.r("Disable") .. " Craft Logs",
        [CraftSim.CONST.TEXT.CRAFT_LOG_DISABLE_CHECKBOX_TOOLTIP] =
            "Enabling this stops the recording of any crafts when crafting and may " ..
            f.g("increase performance"),
        [CraftSim.CONST.TEXT.CRAFT_LOG_REAGENT_DETAILS_TAB] = "Reagent Details",
        [CraftSim.CONST.TEXT.CRAFT_LOG_RESULT_ANALYSIS_TAB] = "Result Analysis",
        [CraftSim.CONST.TEXT.CRAFT_LOG_RESULT_ANALYSIS_TAB_DISTRIBUTION_LABEL] = "Result Distribution",
        [CraftSim.CONST.TEXT.CRAFT_LOG_RESULT_ANALYSIS_TAB_DISTRIBUTION_HELP] =
        "Relative distribution of crafted item results.\n(Ignoring Multicraft Quantities)",
        [CraftSim.CONST.TEXT.CRAFT_LOG_RESULT_ANALYSIS_TAB_MULTICRAFT] = "Multicraft",
        [CraftSim.CONST.TEXT.CRAFT_LOG_RESULT_ANALYSIS_TAB_RESOURCEFULNESS] = "Resourcefulness",
        [CraftSim.CONST.TEXT.CRAFT_LOG_RESULT_ANALYSIS_TAB_YIELD_DDISTRIBUTION] = "Yield Distribution",

        -- Stats Weight Frame
        [CraftSim.CONST.TEXT.STAT_WEIGHTS_TITLE] = "CraftSim Average Profit",
        [CraftSim.CONST.TEXT.EXPLANATIONS_TITLE] = "CraftSim Average Profit Explanation",
        [CraftSim.CONST.TEXT.STAT_WEIGHTS_SHOW_EXPLANATION_BUTTON] = "Show Explanation",
        [CraftSim.CONST.TEXT.STAT_WEIGHTS_HIDE_EXPLANATION_BUTTON] = "Hide Explanation",
        [CraftSim.CONST.TEXT.STAT_WEIGHTS_SHOW_STATISTICS_BUTTON] = "Show Statistics",
        [CraftSim.CONST.TEXT.STAT_WEIGHTS_HIDE_STATISTICS_BUTTON] = "Hide Statistics",
        [CraftSim.CONST.TEXT.STAT_WEIGHTS_PROFIT_CRAFT] = "Ø Profit / Craft: ",
        [CraftSim.CONST.TEXT.EXPLANATIONS_BASIC_PROFIT_TAB] = "Basic Profit Calculation",

        -- Cost Details Frame
        [CraftSim.CONST.TEXT.COST_OPTIMIZATION_TITLE] = "CraftSim Cost Optimization",
        [CraftSim.CONST.TEXT.COST_OPTIMIZATION_EXPLANATION] =
            "Here you can see an overview of all possible prices of the used reagents.\nThe " ..
            f.bb("'Used Source'") ..
            " column indicates which one of the prices is used.\n\n" ..
            f.g("AH") ..
            " .. Auction House Price\n" ..
            f.l("OR") ..
            " .. Price Override\n" ..
            f.bb("Any Name") ..
            " .. Expected Costs from crafting it yourself\n" ..
            f.l("OR") ..
            " will always be used if set. " ..
            f.bb("Crafting Costs") .. " will only be used if lower than " .. f.g("AH") .. "\n\n" ..
            f.bb("Right Click") .. " on any reagent to override its price by a custom value",
        [CraftSim.CONST.TEXT.COST_OPTIMIZATION_CRAFTING_COSTS] = "Crafting Costs: ",
        [CraftSim.CONST.TEXT.COST_OPTIMIZATION_ITEM_HEADER] = "Item",
        [CraftSim.CONST.TEXT.COST_OPTIMIZATION_AH_PRICE_HEADER] = "AH Price",
        [CraftSim.CONST.TEXT.COST_OPTIMIZATION_OVERRIDE_HEADER] = "Override",
        [CraftSim.CONST.TEXT.COST_OPTIMIZATION_CRAFTING_HEADER] = "Crafting",
        [CraftSim.CONST.TEXT.COST_OPTIMIZATION_USED_SOURCE] = "Used Source",
        [CraftSim.CONST.TEXT.COST_OPTIMIZATION_REAGENT_COSTS_TAB] = "Reagent Costs",
        [CraftSim.CONST.TEXT.COST_OPTIMIZATION_SUB_RECIPE_OPTIONS_TAB] = "Sub Recipe Options",
        [CraftSim.CONST.TEXT.COST_OPTIMIZATION_SUB_RECIPE_OPTIMIZATION] = "Sub Recipe Optimization " ..
            f.bb("(experimental)"),
        [CraftSim.CONST.TEXT.COST_OPTIMIZATION_SUB_RECIPE_OPTIMIZATION_TOOLTIP] = "If enabled " ..
            f.l("CraftSim") .. " considers the " .. f.g("optimized crafting costs") ..
            " of your character and your alts\nif they are able to craft that item.\n\n" ..
            f.r("Might decrease performance a bit due to a lot of additional calculations"),
        [CraftSim.CONST.TEXT.COST_OPTIMIZATION_SUB_RECIPE_MAX_DEPTH_LABEL] = "Sub Recipe Calculation Depth",
        [CraftSim.CONST.TEXT.COST_OPTIMIZATION_SUB_RECIPE_INCLUDE_CONCENTRATION] = "Enable Concentration",
        [CraftSim.CONST.TEXT.COST_OPTIMIZATION_SUB_RECIPE_INCLUDE_CONCENTRATION_TOOLTIP] = "If enabled, " ..
            f.l("CraftSim") .. " will include reagent qualities even if concentration is necessary.",
        [CraftSim.CONST.TEXT.COST_OPTIMIZATION_SUB_RECIPE_INCLUDE_COOLDOWN_RECIPES] = "Include Cooldown Recipes",
        [CraftSim.CONST.TEXT.COST_OPTIMIZATION_SUB_RECIPE_INCLUDE_COOLDOWN_RECIPES_TOOLTIP] = "If enabled, " ..
            f.l("CraftSim") .. " will ignore cooldown requirements of recipes when calculating self crafted reagents",
        [CraftSim.CONST.TEXT.COST_OPTIMIZATION_SUB_RECIPE_SELECT_RECIPE_CRAFTER] = "Select Recipe Crafter",
        [CraftSim.CONST.TEXT.COST_OPTIMIZATION_REAGENT_LIST_AH_COLUMN_AUCTION_BUYOUT] = "Auction Buyout: ",
        [CraftSim.CONST.TEXT.COST_OPTIMIZATION_REAGENT_LIST_OVERRIDE] = "\n\nOverride",
        [CraftSim.CONST.TEXT.COST_OPTIMIZATION_REAGENT_LIST_EXPECTED_COSTS_TOOLTIP] = "\n\nCrafting ",
        [CraftSim.CONST.TEXT.COST_OPTIMIZATION_REAGENT_LIST_EXPECTED_COSTS_PRE_ITEM] = "\n- Expected Costs Per Item: ",
        [CraftSim.CONST.TEXT.COST_OPTIMIZATION_REAGENT_LIST_CONCENTRATION_COST] = f.gold("Concentration Cost: "),
        [CraftSim.CONST.TEXT.COST_OPTIMIZATION_REAGENT_LIST_CONCENTRATION] = "Concentration: ",

        -- Statistics Frame
        [CraftSim.CONST.TEXT.STATISTICS_TITLE] = "CraftSim Statistics",
        [CraftSim.CONST.TEXT.STATISTICS_EXPECTED_PROFIT] = "Expected Profit (μ)",
        [CraftSim.CONST.TEXT.STATISTICS_CHANCE_OF] = "Chance of ",
        [CraftSim.CONST.TEXT.STATISTICS_PROFIT] = "Profit",
        [CraftSim.CONST.TEXT.STATISTICS_AFTER] = " after",
        [CraftSim.CONST.TEXT.STATISTICS_CRAFTS] = "Crafts: ",
        [CraftSim.CONST.TEXT.STATISTICS_QUALITY_HEADER] = "Quality",
        [CraftSim.CONST.TEXT.STATISTICS_MULTICRAFT_HEADER] = "Multicraft",
        [CraftSim.CONST.TEXT.STATISTICS_RESOURCEFULNESS_HEADER] = "Resourcefulness",
        [CraftSim.CONST.TEXT.STATISTICS_EXPECTED_PROFIT_HEADER] = "Expected Profit",
        [CraftSim.CONST.TEXT.PROBABILITY_TABLE_TITLE] = "Recipe Probability Table",
        [CraftSim.CONST.TEXT.STATISTICS_PROBABILITY_TABLE_TAB] = "Probability Table",
        [CraftSim.CONST.TEXT.STATISTICS_CONCENTRATION_TAB] = "Concentration",
        [CraftSim.CONST.TEXT.STATISTICS_CONCENTRATION_CURVE_GRAPH] = "Concentration Cost Curve",
        [CraftSim.CONST.TEXT.STATISTICS_CONCENTRATION_CURVE_GRAPH_HELP] =
            "Concentration Cost based on Player Skill for given Recipe\n" ..
            f.bb("X Axis: ") .. " Player Skill\n" ..
            f.bb("Y Axis: ") .. " Concentration Cost",

        -- Price Details Frame
        [CraftSim.CONST.TEXT.COST_OVERVIEW_TITLE] = "CraftSim Price Details",
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
        [CraftSim.CONST.TEXT.PRICE_OVERRIDE_ACTIVE_OVERRIDES_TOOLTIP] =
        "'(as result)' -> price override only considered when item is a result of a recipe",
        [CraftSim.CONST.TEXT.PRICE_OVERRIDE_CLEAR_ALL] = "Clear All",
        [CraftSim.CONST.TEXT.PRICE_OVERRIDE_SAVE] = "Save",
        [CraftSim.CONST.TEXT.PRICE_OVERRIDE_SAVED] = "Saved",
        [CraftSim.CONST.TEXT.PRICE_OVERRIDE_REMOVE] = "Remove",

        -- Recipe Scan Frame
        [CraftSim.CONST.TEXT.RECIPE_SCAN_TITLE] = "CraftSim Recipe Scan",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_MODE] = "Scan Mode",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_SORT_MODE] = "Sort Mode",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_SCAN_RECIPIES] = "Scan Recipes",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_SCAN_CANCEL] = "Cancel",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_SCANNING] = "Scanning",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_INCLUDE_NOT_LEARNED] = "Include not learned",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_INCLUDE_NOT_LEARNED_TOOLTIP] =
        "Include recipes you do not have learned in the recipe scan",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_INCLUDE_SOULBOUND] = "Include Soulbound",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_INCLUDE_SOULBOUND_TOOLTIP] =
        "Include soulbound recipes in the recipe scan.\n\nIt is recommended to set a price override (e.g. to simulate a target comission)\nin the Price Override Module for that recipe's crafted items",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_INCLUDE_GEAR] = "Include Gear",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_INCLUDE_GEAR_TOOLTIP] = "Include all form of gear recipes in the recipe scan",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_OPTIMIZE_TOOLS] = "Optimize Profession Tools",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_OPTIMIZE_TOOLS_TOOLTIP] =
        "For each recipe optimize your profession tools for profit\n\n",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_OPTIMIZE_TOOLS_WARNING] =
        "Might lower performance during scanning\nif you have a lot of tools in your inventory",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_CRAFTER_HEADER] = "Crafter",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_RECIPE_HEADER] = "Recipe",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_LEARNED_HEADER] = "Learned",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_RESULT_HEADER] = "Result",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_AVERAGE_PROFIT_HEADER] = "Ø Profit",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_CONCENTRATION_VALUE_HEADER] = "C. Value",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_CONCENTRATION_COST_HEADER] = "C. Cost",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_TOP_GEAR_HEADER] = "Top Gear",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_INV_AH_HEADER] = "Inv/AH",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_SORT_BY_MARGIN] = "Sort by Profit %",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_SORT_BY_MARGIN_TOOLTIP] =
        "Sort the profit list by profit relative to crafting costs.\n(Requires a new scan)",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_USE_INSIGHT_CHECKBOX] = "Use " .. f.bb("Insight") .. " if possible",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_USE_INSIGHT_CHECKBOX_TOOLTIP] = "Use " ..
            f.bb("Illustrious Insight") ..
            " or\n" .. f.bb("Lesser Illustrious Insight") .. " as optional reagent for recipes that allow it.",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_ONLY_FAVORITES_CHECKBOX] = "Only Favorites",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_ONLY_FAVORITES_CHECKBOX_TOOLTIP] = "Scan only your favorite recipes",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_EQUIPPED] = "Equipped",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_MODE_OPTIMIZE] = "Optimize",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_SORT_MODE_PROFIT] = "Profit",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_SORT_MODE_RELATIVE_PROFIT] = "Relative Profit",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_SORT_MODE_CONCENTRATION_VALUE] = "Concentration Value",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_SORT_MODE_CONCENTRATION_COST] = "Concentration Cost",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_SORT_MODE_CRAFTING_COST] = "Crafting Cost",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_EXPANSION_FILTER_BUTTON] = "Expansion Filter",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_ALTPROFESSIONS_FILTER_BUTTON] = "Alt Professions",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_SCAN_ALL_BUTTON_READY] = "Scan Professions",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_SCAN_ALL_BUTTON_SCANNING] = "Scanning...",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_TAB_LABEL_SCAN] = "Recipe Scan",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_TAB_LABEL_OPTIONS] = "Scan Options",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_IMPORT_ALL_PROFESSIONS_CHECKBOX_LABEL] = "All Scanned Professions",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_IMPORT_ALL_PROFESSIONS_CHECKBOX_TOOLTIP] = f.g("True: ") ..
            "Import Scan Results from all enabled and scanned professions\n\n" ..
            f.r("False: ") .. "Import Scan Results only from currently selected profession",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_CACHED_RECIPES_TOOLTIP] =
            "Whenever you open or scan a recipe on a character, " ..
            f.l("CraftSim") ..
            " remembers it.\n\nOnly recipes from your alts that " ..
            f.l("CraftSim") .. " can remember will be scanned with " .. f.bb("RecipeScan\n\n") ..
            "The actual amount of recipes that are scanned is then based on your " .. f.e("Recipe Scan Options"),
        [CraftSim.CONST.TEXT.RECIPE_SCAN_CONCENTRATION_TOGGLE] = " Concentration",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_CONCENTRATION_TOGGLE_TOOLTIP] = "Toggle Concentration",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_OPTIMIZE_SUBRECIPES] = "Optimize Sub Recipes " .. f.bb("(experimental)"),
        [CraftSim.CONST.TEXT.RECIPE_SCAN_OPTIMIZE_SUBRECIPES_TOOLTIP] = "If enabled, " ..
            f.l("CraftSim") .. " also optimizes crafts of cached reagent recipes of scanned recipes and uses their\n" ..
            f.bb("expected costs") .. " to calculate the crafting costs for the final product.\n\n" ..
            f.r("Warning: This might reduce scanning performance"),
        [CraftSim.CONST.TEXT.RECIPE_SCAN_CACHED_RECIPES] = "Cached Recipes: ",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_ENABLE_CONCENTRATION] = f.bb("Enable ") .. f.gold("Concentration"),
        [CraftSim.CONST.TEXT.RECIPE_SCAN_ONLY_FAVORITES] = f.r("Only ") .. f.bb("Favorites"),
        [CraftSim.CONST.TEXT.RECIPE_SCAN_INCLUDE_SOULBOUND_ITEMS] = "Include " .. f.e("Soulbound") .. " Items",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_INCLUDE_UNLEARNED_RECIPES] = "Include " .. f.r("Unlearned") .. " Recipes",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_INCLUDE_GEAR_LABEL] = "Include Gear",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_REAGENT_ALLOCATION] = "Reagent Allocation",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_REAGENT_ALLOCATION_Q1] = "All Q1",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_REAGENT_ALLOCATION_Q2] = "All Q2",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_REAGENT_ALLOCATION_Q3] = "All Q3",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_AUTOSELECT_TOP_PROFIT] = "Autoselect " .. f.g("Top Profit Quality"),
        [CraftSim.CONST.TEXT.RECIPE_SCAN_OPTIMIZE_PROFESSION_GEAR] = "Optimize " .. f.bb("Profession Gear"),
        [CraftSim.CONST.TEXT.RECIPE_SCAN_OPTIMIZE_CONCENTRATION] = "Optimize " .. f.gold("Concentration"),
        [CraftSim.CONST.TEXT.RECIPE_SCAN_OPTIMIZE_FINISHING_REAGENTS] = "Optimize " .. f.bb("Finishing Reagents"),
        [CraftSim.CONST.TEXT.RECIPE_SCAN_SEND_TO_CRAFT_QUEUE] = "Send to Craft Queue",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_PROFIT_MARGIN_THRESHOLD] = "Profit Margin Threshold (%): ",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_DEFAULT_QUEUE_AMOUNT] = "Default Queue Amount: ",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_ADD_TO_CRAFT_QUEUE] = "Add to Craft Queue",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_SORT_BY] = "Sort By",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_SORT_ASCENDING] = "Ascending",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_REMOVE_FAVORITE] = f.r("Remove") .. " Favorite",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_ADD_FAVORITE] = f.g("Add") .. " Favorite",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_FAVORITES_CRAFTER_ONLY] = f.r("Favorites can only be changed on the crafter"),
        [CraftSim.CONST.TEXT.RECIPE_SCAN_QUEUE_HINT] = "Press " ..
            CreateAtlasMarkup("NPE_LeftClick", 20, 20, 2) .. " + shift to queue selected recipe into the " ..
            f.bb("Craft Queue"),
        [CraftSim.CONST.TEXT.RECIPE_SCAN_REMOVE_CACHED_DATA] = f.r("Remove"),
        [CraftSim.CONST.TEXT.RECIPE_SCAN_REMOVE_CACHED_DATA_TOOLTIP] = f.r("Remove ") ..
            "all cached data about this character - profession combination",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_USE_TSM_RESTOCK] = "Use " .. f.bb("TSM") .. " Restock Amount Expression",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_TSM_SALE_RATE_THRESHOLD] = f.bb("TSM") .. " Sale Rate Threshold: ",

        -- Recipe Top Gear
        [CraftSim.CONST.TEXT.TOP_GEAR_TITLE] = "CraftSim Top Gear",
        [CraftSim.CONST.TEXT.TOP_GEAR_AUTOMATIC] = "Automatic",
        [CraftSim.CONST.TEXT.TOP_GEAR_AUTOMATIC_TOOLTIP] =
        "Automatically simulate Top Gear for your selected mode whenever a recipe updates.\n\nTurning this off may increase performance.",
        [CraftSim.CONST.TEXT.TOP_GEAR_SIMULATE] = "Simulate Top Gear",
        [CraftSim.CONST.TEXT.TOP_GEAR_EQUIP] = "Equip",
        [CraftSim.CONST.TEXT.TOP_GEAR_SIMULATE_QUALITY] = "Quality: ",
        [CraftSim.CONST.TEXT.TOP_GEAR_SIMULATE_EQUIPPED] = "Top Gear equipped",
        [CraftSim.CONST.TEXT.TOP_GEAR_SIMULATE_PROFIT_DIFFERENCE] = "Ø Profit Difference\n",
        [CraftSim.CONST.TEXT.TOP_GEAR_SIMULATE_NEW_MUTLICRAFT] = "New Multicraft\n",
        [CraftSim.CONST.TEXT.TOP_GEAR_SIMULATE_NEW_CRAFTING_SPEED] = "New Crafting Speed\n",
        [CraftSim.CONST.TEXT.TOP_GEAR_SIMULATE_NEW_RESOURCEFULNESS] = "New Resourcefulness\n",
        [CraftSim.CONST.TEXT.TOP_GEAR_SIMULATE_NEW_SKILL] = "New Skill\n",
        [CraftSim.CONST.TEXT.TOP_GEAR_SIMULATE_UNHANDLED] = "Unhandled Sim Mode",

        [CraftSim.CONST.TEXT.TOP_GEAR_SIM_MODES_PROFIT] = "Top Profit",
        [CraftSim.CONST.TEXT.TOP_GEAR_SIM_MODES_SKILL] = "Top Skill",
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
        [CraftSim.CONST.TEXT.OPTIONS_GENERAL_SHOW_PROFIT_TOOLTIP] =
        "Show the percentage of profit to crafting costs besides the gold value",
        [CraftSim.CONST.TEXT.OPTIONS_GENERAL_REMEMBER_LAST_RECIPE] = "Remember Last Recipe",
        [CraftSim.CONST.TEXT.OPTIONS_GENERAL_REMEMBER_LAST_RECIPE_TOOLTIP] =
        "Reopen last selected recipe when opening the crafting window",
        [CraftSim.CONST.TEXT.OPTIONS_GENERAL_SUPPORTED_PRICE_SOURCES] = "Supported Price Sources:",
        [CraftSim.CONST.TEXT.OPTIONS_PERFORMANCE_RAM] = "Enable RAM cleanup while crafting",
        [CraftSim.CONST.TEXT.OPTIONS_PERFORMANCE_RAM_CRAFTS] = "Crafts",
        [CraftSim.CONST.TEXT.OPTIONS_PERFORMANCE_RAM_TOOLTIP] =
        "When enabled, CraftSim will clear your RAM every specified number of crafts from unused data to prevent memory from building up.\nMemory Build Up can also happen because of other addons and is not CraftSim specific.\nA cleanup will affect the whole WoW RAM Usage.",
        [CraftSim.CONST.TEXT.OPTIONS_MODULES_TAB] = "Modules",
        [CraftSim.CONST.TEXT.OPTIONS_PROFIT_CALCULATION_TAB] = "Profit Calculation",
        [CraftSim.CONST.TEXT.OPTIONS_CRAFTING_TAB] = "Crafting",
        [CraftSim.CONST.TEXT.OPTIONS_TSM_RESET] = "Reset Default",
        [CraftSim.CONST.TEXT.OPTIONS_TSM_INVALID_EXPRESSION] = "Expression Invalid",
        [CraftSim.CONST.TEXT.OPTIONS_TSM_VALID_EXPRESSION] = "Expression Valid",
        [CraftSim.CONST.TEXT.OPTIONS_MODULES_REAGENT_OPTIMIZATION] = "Reagent Optimizing Module",
        [CraftSim.CONST.TEXT.OPTIONS_MODULES_AVERAGE_PROFIT] = "Average Profit Module",
        [CraftSim.CONST.TEXT.OPTIONS_MODULES_TOP_GEAR] = "Top Gear Module",
        [CraftSim.CONST.TEXT.OPTIONS_MODULES_COST_OVERVIEW] = "Cost Overview Module",
        [CraftSim.CONST.TEXT.OPTIONS_MODULES_SPECIALIZATION_INFO] = "Specialization Info Module",
        [CraftSim.CONST.TEXT.OPTIONS_MODULES_CUSTOMER_HISTORY_SIZE] = "Customer History max messages per client",
        [CraftSim.CONST.TEXT.OPTIONS_MODULES_CUSTOMER_HISTORY_MAX_ENTRIES_PER_CLIENT] = "Max history entries per client",
        [CraftSim.CONST.TEXT.OPTIONS_PROFIT_CALCULATION_OFFSET] = "Offset Skill Breakpoints by 1",
        [CraftSim.CONST.TEXT.OPTIONS_PROFIT_CALCULATION_OFFSET_TOOLTIP] =
        "The reagent combination suggestion will try to reach the breakpoint + 1 instead of matching the exact skill required",
        [CraftSim.CONST.TEXT.OPTIONS_PROFIT_CALCULATION_MULTICRAFT_CONSTANT] = "Multicraft Constant",
        [CraftSim.CONST.TEXT.OPTIONS_PROFIT_CALCULATION_MULTICRAFT_CONSTANT_EXPLANATION] =
        "Default: 2.5\n\nCrafting Data from different data collecting players in beta and early Dragonflight suggest that\nthe maximum extra items one can receive from a multicraft proc is 1+C*y.\nWhere y is the base item amount for one craft and C is 2.5.\nHowever if you wish you can modify this value here.",
        [CraftSim.CONST.TEXT.OPTIONS_PROFIT_CALCULATION_RESOURCEFULNESS_CONSTANT] = "Resourcefulness Constant",
        [CraftSim.CONST.TEXT.OPTIONS_PROFIT_CALCULATION_RESOURCEFULNESS_CONSTANT_EXPLANATION] =
        "Default: 0.3\n\nCrafting Data from different data collecting players in beta and early Dragonflight suggest that\nthe average amount of items saved is 30% of the required quantity.\nHowever if you wish you can modify this value here.",
        [CraftSim.CONST.TEXT.OPTIONS_GENERAL_SHOW_NEWS_CHECKBOX] = "Show " .. f.bb("News") .. " Popup",
        [CraftSim.CONST.TEXT.OPTIONS_GENERAL_SHOW_NEWS_CHECKBOX_TOOLTIP] = "Show the " ..
            f.bb("News") .. " Popup for new " .. f.l("CraftSim") .. " Update Information when logging into the game",
        [CraftSim.CONST.TEXT.OPTIONS_GENERAL_HIDE_MINIMAP_BUTTON_CHECKBOX] = "Hide Minimap Button",
        [CraftSim.CONST.TEXT.OPTIONS_GENERAL_HIDE_MINIMAP_BUTTON_TOOLTIP] = "Enable to hide the " ..
            f.l("CraftSim") .. " Minimap Button",
        [CraftSim.CONST.TEXT.OPTIONS_GENERAL_COIN_MONEY_FORMAT_CHECKBOX] = "Use Coin Textures: ",
        [CraftSim.CONST.TEXT.OPTIONS_GENERAL_COIN_MONEY_FORMAT_TOOLTIP] = "Use coin icons to format money",

        -- Control Panel
        [CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_CRAFT_QUEUE_LABEL] = "Craft Queue",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_CRAFT_QUEUE_TOOLTIP] =
        "Queue your recipes and craft them all on one place!",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_TOP_GEAR_LABEL] = "Top Gear",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_TOP_GEAR_TOOLTIP] =
        "Shows the best available profession gear combination based on the selected mode",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_COST_OVERVIEW_LABEL] = "Price Details",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_COST_OVERVIEW_TOOLTIP] =
        "Shows a sell price and profit overview by resulting item quality",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_AVERAGE_PROFIT_LABEL] = "Average Profit",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_AVERAGE_PROFIT_TOOLTIP] =
        "Shows the average profit based on your profession stats and the profit stat weights as gold per point.",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_REAGENT_OPTIMIZATION_LABEL] = "Reagent Optimization",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_REAGENT_OPTIMIZATION_TOOLTIP] =
        "Suggests the cheapest reagents to reach the specific quality thresholds.",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_PRICE_OVERRIDES_LABEL] = "Price Overrides",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_PRICE_OVERRIDES_TOOLTIP] =
        "Override prices of any reagents, and craft results for all recipes or for one recipe specifically.",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_SPECIALIZATION_INFO_LABEL] = "Specialization Info",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_SPECIALIZATION_INFO_TOOLTIP] =
        "Shows how your profession specializations affect this recipe and makes it possible to simulate any configuration!",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_CRAFT_LOG_LABEL] = "Craft Log",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_CRAFT_LOG_TOOLTIP] =
        "Show a crafting log and statistics about your crafts!",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_COST_OPTIMIZATION_LABEL] = "Cost Optimization",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_COST_OPTIMIZATION_TOOLTIP] =
        "Module that shows detailed information about and helps with optimizing crafting costs",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_STATISTICS_LABEL] = "Statistics",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_STATISTICS_TOOLTIP] =
        "Module that shows detailed outcome statistics for the currently open recipe",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_RECIPE_SCAN_LABEL] = "Recipe Scan",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_RECIPE_SCAN_TOOLTIP] =
        "Module that scans your recipe list based on various options",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_CUSTOMER_HISTORY_LABEL] = "Customer History",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_CUSTOMER_HISTORY_TOOLTIP] =
        "Module that provides a history of conversations with customers, crafted items and commissions",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_CRAFT_BUFFS_LABEL] = "Craft Buffs",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_CRAFT_BUFFS_TOOLTIP] =
        "Module that shows you your active and missing Craft Buffs",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_EXPLANATIONS_LABEL] = "Explanations",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_EXPLANATIONS_TOOLTIP] =
            "Module that shows you various explanations of how" .. f.l(" CraftSim") .. " calculates things",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_RESET_FRAMES] = "Reset Frame Positions",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_OPTIONS] = "Options",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_NEWS] = "News",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_EASYCRAFT_EXPORT] = f.l("Easycraft") .. " Export",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_EASYCRAFT_EXPORTING] = "Exporting",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_EASYCRAFT_EXPORT_NO_RECIPE_FOUND] =
        "No recipe to export for The War Within expansion",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_FORGEFINDER_EXPORT] = f.l("ForgeFinder") .. " Export",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_FORGEFINDER_EXPORTING] = "Exporting",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_EXPORT_EXPLANATION] = f.l("wowforgefinder.com") ..
            " and " .. f.l("easycraft.io") ..
            "\nare websites to search and offer " .. f.bb("WoW Crafting Orders"),
        [CraftSim.CONST.TEXT.CONTROL_PANEL_DEBUG] = "Debug",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_TITLE] = "Control Panel",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_SUPPORTERS_BUTTON] = f.patreon("Supporters"),

        -- Supporters
        [CraftSim.CONST.TEXT.SUPPORTERS_DESCRIPTION] = f.l("Thank you to all those awesome people!"),
        [CraftSim.CONST.TEXT.SUPPORTERS_DESCRIPTION_2] = f.l(
            "Do you want to support CraftSim and also be listed here with your message?\nConsider joining the Community!"),
        [CraftSim.CONST.TEXT.SUPPORTERS_DATE] = "Date",
        [CraftSim.CONST.TEXT.SUPPORTERS_SUPPORTER] = "Supporter",
        [CraftSim.CONST.TEXT.SUPPORTERS_MESSAGE] = "Message",

        -- Customer History
        [CraftSim.CONST.TEXT.CUSTOMER_HISTORY_TITLE] = "CraftSim Customer History",
        [CraftSim.CONST.TEXT.CUSTOMER_HISTORY_DROPDOWN_LABEL] = "Choose a customer",
        [CraftSim.CONST.TEXT.CUSTOMER_HISTORY_TOTAL_TIP] = "Total tip: ",
        [CraftSim.CONST.TEXT.CUSTOMER_HISTORY_FROM] = "From",
        [CraftSim.CONST.TEXT.CUSTOMER_HISTORY_TO] = "To",
        [CraftSim.CONST.TEXT.CUSTOMER_HISTORY_FOR] = "For",
        [CraftSim.CONST.TEXT.CUSTOMER_HISTORY_CRAFT_FORMAT] = "Crafted %s for %s",
        [CraftSim.CONST.TEXT.CUSTOMER_HISTORY_DELETE_BUTTON] = "Remove customer",
        [CraftSim.CONST.TEXT.CUSTOMER_HISTORY_WHISPER_BUTTON_LABEL] = "Whisper..",
        [CraftSim.CONST.TEXT.CUSTOMER_HISTORY_PURGE_NO_TIP_LABEL] = "Remove 0 Tip Customers",
        [CraftSim.CONST.TEXT.CUSTOMER_HISTORY_PURGE_ZERO_TIPS_CONFIRMATION_POPUP] =
        "Are you sure you want to delete all data\nfrom customers with 0 total tip?",
        [CraftSim.CONST.TEXT.CUSTOMER_HISTORY_DELETE_CUSTOMER_CONFIRMATION_POPUP] =
        "Are you sure you want to delete\nall data for %s?",
        [CraftSim.CONST.TEXT.CUSTOMER_HISTORY_PURGE_DAYS_INPUT_LABEL] = "Auto Remove Interval (Days)",
        [CraftSim.CONST.TEXT.CUSTOMER_HISTORY_PURGE_DAYS_INPUT_TOOLTIP] =
        "CraftSim will automatically remove all customers below the configured tip when you login after X days of the last deletion.\nIf set to 0, CraftSim will never delete automatically.",
        [CraftSim.CONST.TEXT.CUSTOMER_HISTORY_CUSTOMER_HEADER] = "Customer",
        [CraftSim.CONST.TEXT.CUSTOMER_HISTORY_TOTAL_TIP_HEADER] = "Total Tip",
        [CraftSim.CONST.TEXT.CUSTOMER_HISTORY_CRAFT_HISTORY_DATE_HEADER] = "Date",
        [CraftSim.CONST.TEXT.CUSTOMER_HISTORY_CRAFT_HISTORY_RESULT_HEADER] = "Result",
        [CraftSim.CONST.TEXT.CUSTOMER_HISTORY_CRAFT_HISTORY_TIP_HEADER] = "Tip",
        [CraftSim.CONST.TEXT.CUSTOMER_HISTORY_CRAFT_HISTORY_CUSTOMER_REAGENTS_HEADER] = "Customer Reagents",
        [CraftSim.CONST.TEXT.CUSTOMER_HISTORY_CRAFT_HISTORY_CUSTOMER_NOTE_HEADER] = "Note",
        [CraftSim.CONST.TEXT.CUSTOMER_HISTORY_CHAT_MESSAGE_TIMESTAMP] = "Timestamp",
        [CraftSim.CONST.TEXT.CUSTOMER_HISTORY_CHAT_MESSAGE_SENDER] = "Sender",
        [CraftSim.CONST.TEXT.CUSTOMER_HISTORY_CHAT_MESSAGE_MESSAGE] = "Message",
        [CraftSim.CONST.TEXT.CUSTOMER_HISTORY_CHAT_MESSAGE_YOU] = "[You]: ",
        [CraftSim.CONST.TEXT.CUSTOMER_HISTORY_CRAFT_LIST_TIMESTAMP] = "Timestamp",
        [CraftSim.CONST.TEXT.CUSTOMER_HISTORY_CRAFT_LIST_RESULTLINK] = "ResultLink",
        [CraftSim.CONST.TEXT.CUSTOMER_HISTORY_CRAFT_LIST_TIP] = "Tip",
        [CraftSim.CONST.TEXT.CUSTOMER_HISTORY_CRAFT_LIST_REAGENTS] = "Reagents",
        [CraftSim.CONST.TEXT.CUSTOMER_HISTORY_CRAFT_LIST_SOMENOTE] = "SomeNote",
        [CraftSim.CONST.TEXT.CUSTOMER_HISTORY_TOTAL_AMOUNT] = "Total amount",

        -- Craft Queue
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_TITLE] = "CraftSim Craft Queue",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_CRAFT_AMOUNT_LEFT_HEADER] = "Queued",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_CRAFT_PROFESSION_GEAR_HEADER] = "Tools",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_CRAFTING_COSTS_HEADER] = "Crafting Costs",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_CRAFT_BUTTON_ROW_LABEL] = "Craft",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_CRAFT_BUTTON_ROW_LABEL_WRONG_GEAR] = "Wrong Tools",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_CRAFT_BUTTON_ROW_LABEL_NO_REAGENTS] = "No Reagents",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_ADD_OPEN_RECIPE_BUTTON_LABEL] = "Queue Open Recipe",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_ADD_FIRST_CRAFTS_BUTTON_LABEL] = "Queue First Crafts",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_ADD_WORK_ORDERS_BUTTON_LABEL] = "Queue Work Orders",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_ADD_WORK_ORDERS_ALLOW_CONCENTRATION_CHECKBOX] = "Allow Concentration",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_ADD_WORK_ORDERS_ALLOW_CONCENTRATION_TOOLTIP] =
            "If minimum quality cannot be reached, use " .. f.l("Concentration") .. " if possible",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_ADD_WORK_ORDERS_ONLY_PROFITABLE_CHECKBOX] = "Only Profitable",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_ADD_WORK_ORDERS_ONLY_PROFITABLE_TOOLTIP] = "Only queue work orders with expected positive profit",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_CLEAR_ALL_BUTTON_LABEL] = "Clear All",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_RESTOCK_FAVORITES_BUTTON_LABEL] = "Queue Favorites",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_CRAFT_BUTTON_ROW_LABEL_WRONG_PROFESSION] = "Wrong Profession",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_CRAFT_BUTTON_ROW_LABEL_ON_COOLDOWN] = "On Cooldown",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_CRAFT_BUTTON_ROW_LABEL_WRONG_CRAFTER] = "Wrong Crafter",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_RECIPE_REQUIREMENTS_HEADER] = "Status",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_RECIPE_REQUIREMENTS_TOOLTIP] =
        "All Requirements need to be fulfilled in order to craft a recipe",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_CRAFT_NEXT_BUTTON_LABEL] = "Craft Next",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_CRAFT_AVAILABLE_AMOUNT] = "Max",
        [CraftSim.CONST.TEXT.CRAFTQUEUE_AUCTIONATOR_SHOPPING_LIST_BUTTON_LABEL] = "Create Auctionator Shopping List",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_QUEUE_TAB_LABEL] = "Craft Queue",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_FLASH_TASKBAR_OPTION_LABEL] = "Flash Taskbar on " ..
            f.bb("CraftQueue") .. " craft finished",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_FLASH_TASKBAR_OPTION_TOOLTIP] =
            "When your WoW Game is minimized and a recipe has finished crafting in the " .. f.bb("CraftQueue") ..
            "," .. f.l(" CraftSim") .. " will flash your Taskbar WoW Icon",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_RESTOCK_OPTIONS_TAB_LABEL] = "Restock Options",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_RESTOCK_OPTIONS_TAB_TOOLTIP] =
        "Configure the restock behaviour when importing from Recipe Scan",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_RESTOCK_OPTIONS_GENERAL_PROFIT_THRESHOLD_LABEL] = "Profit Threshold:",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_RESTOCK_OPTIONS_SALE_RATE_INPUT_LABEL] = "Sale Rate Threshold:",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_RESTOCK_OPTIONS_TSM_SALE_RATE_TOOLTIP] = string.format(
            [[
Only available when %s is loaded!

It will be checked wether %s of an item's chosen qualities has a sale rate
greater or equal the configured sale rate threshold.
]], f.bb("TSM"), f.bb("any")),
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_RESTOCK_OPTIONS_TSM_SALE_RATE_TOOLTIP_GENERAL] = string.format(
            [[
Only available when %s is loaded!

It will be checked wether %s of an item's qualities has a sale rate
greater or equal the configured sale rate threshold.
]], f.bb("TSM"), f.bb("any")),
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_RESTOCK_OPTIONS_AMOUNT_LABEL] = "Restock Amount:",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_RESTOCK_OPTIONS_RESTOCK_TOOLTIP] = "This is the " ..
            f.bb("amount of crafts") ..
            " that will be queued for that recipe.\n\nThe amount of items you have in your inventory and bank of the checked qualities will be subtracted from the restock amount upon restocking",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_RESTOCK_OPTIONS_ENABLE_RECIPE_LABEL] = "Enable:",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_RESTOCK_OPTIONS_GENERAL_OPTIONS_LABEL] = "General Options (All Recipes)",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_RESTOCK_OPTIONS_ENABLE_RECIPE_TOOLTIP] =
        "If this is toggled off, the recipe will be restocked based on the general options above",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_TOTAL_PROFIT_LABEL] = "Total Ø Profit:",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_TOTAL_CRAFTING_COSTS_LABEL] = "Total Crafting Costs:",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_EDIT_RECIPE_TITLE] = "Edit Recipe",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_EDIT_RECIPE_NAME_LABEL] = "Recipe Name",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_EDIT_RECIPE_REAGENTS_SELECT_LABEL] = "Select",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_EDIT_RECIPE_OPTIONAL_REAGENTS_LABEL] = "Optional Reagents",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_EDIT_RECIPE_FINISHING_REAGENTS_LABEL] = "Finishing Reagents",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_EDIT_RECIPE_SPARK_LABEL] = "Required",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_EDIT_RECIPE_PROFESSION_GEAR_LABEL] = "Profession Gear",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_EDIT_RECIPE_OPTIMIZE_PROFIT_BUTTON] = "Optimize",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_EDIT_RECIPE_CRAFTING_COSTS_LABEL] = "Crafting Costs: ",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_EDIT_RECIPE_AVERAGE_PROFIT_LABEL] = "Average Profit: ",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_EDIT_RECIPE_RESULTS_LABEL] = "Results",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_EDIT_RECIPE_CONCENTRATION_CHECKBOX] = " Concentration",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_AUCTIONATOR_SHOPPING_LIST_PER_CHARACTER_CHECKBOX] = "Per Character",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_AUCTIONATOR_SHOPPING_LIST_PER_CHARACTER_CHECKBOX_TOOLTIP] = "Create an " ..
            f.bb("Auctionator Shopping List") .. " for each crafter character\ninstead of one shopping list for all",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_AUCTIONATOR_SHOPPING_LIST_TARGET_MODE_CHECKBOX] = "Target Mode Only",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_AUCTIONATOR_SHOPPING_LIST_TARGET_MODE_CHECKBOX_TOOLTIP] = "Create an " ..
            f.bb("Auctionator Shopping List") .. " for target mode recipes only",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_UNSAVED_CHANGES_TOOLTIP] = f.white("Unsaved Queue Amount.\nPress Enter to Save"),
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_STATUSBAR_LEARNED] = f.white("Recipe Learned"),
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_STATUSBAR_COOLDOWN] = f.white("Not on Cooldown"),
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_STATUSBAR_REAGENTS] = f.white("Reagents Available"),
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_STATUSBAR_GEAR] = f.white("Profession Gear Equipped"),
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_STATUSBAR_CRAFTER] = f.white("Correct Crafter Character"),
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_STATUSBAR_PROFESSION] = f.white("Profession Open"),
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_BUTTON_EDIT] = "Edit",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_BUTTON_CRAFT] = "Craft",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_BUTTON_CLAIM] = "Claim",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_BUTTON_CLAIMED] = "Claimed",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_BUTTON_NEXT] = "Next: ",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_BUTTON_NOTHING_QUEUED] = "Nothing Queued",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_BUTTON_ORDER] = "Order",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_BUTTON_SUBMIT] = "Submit",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_IGNORE_ACUITY_RECIPES_CHECKBOX_LABEL] = "Ignore Acuity Recipes",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_IGNORE_ACUITY_RECIPES_CHECKBOX_TOOLTIP] =
            "Do not queue first crafts that use " .. f.bb("Artisan's Acuity") .. " for crafting",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_AMOUNT_TOOLTIP] = "\n\nQueued Crafts: ",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_ORDER_CUSTOMER] = "\n\nOrder Customer: ",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_ORDER_MINIMUM_QUALITY] = "\nMinimum Quality: ",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_ORDER_REWARDS] = "\nRewards:",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_RESTOCK_FAVORITES_OPTIONS_AUTO_SHOPPING_LIST] = "If enabled, CraftSim will automatically create a shopping list after scanning.",

        -- craft buffs

        [CraftSim.CONST.TEXT.CRAFT_BUFFS_TITLE] = "CraftSim Craft Buffs",
        [CraftSim.CONST.TEXT.CRAFT_BUFFS_SIMULATE_BUTTON] = "Simulate Buffs",
        [CraftSim.CONST.TEXT.CRAFT_BUFF_CHEFS_HAT_TOOLTIP] = f.bb("Wrath of the Lich King Toy.") ..
            "\nRequires Northrend Cooking\nSets Crafting Speed to " .. f.g("0.5 seconds"),

        -- cooldowns module

        [CraftSim.CONST.TEXT.COOLDOWNS_TITLE] = "CraftSim Cooldowns",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_COOLDOWNS_LABEL] = "Cooldowns",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_COOLDOWNS_TOOLTIP] = "Overview for your account's " ..
            f.bb("Profession Cooldowns"),
        [CraftSim.CONST.TEXT.COOLDOWNS_CRAFTER_HEADER] = "Crafter",
        [CraftSim.CONST.TEXT.COOLDOWNS_RECIPE_HEADER] = "Recipe",
        [CraftSim.CONST.TEXT.COOLDOWNS_CHARGES_HEADER] = "Charges",
        [CraftSim.CONST.TEXT.COOLDOWNS_NEXT_HEADER] = "Next Charge",
        [CraftSim.CONST.TEXT.COOLDOWNS_ALL_HEADER] = "Charges Full",
        [CraftSim.CONST.TEXT.COOLDOWNS_TAB_OVERVIEW] = "Overview",
        [CraftSim.CONST.TEXT.COOLDOWNS_TAB_OPTIONS] = "Options",
        [CraftSim.CONST.TEXT.COOLDOWNS_EXPANSION_FILTER_BUTTON] = "Expansion Filter",
        [CraftSim.CONST.TEXT.COOLDOWNS_RECIPE_LIST_TEXT_TOOLTIP] = f.bb("\n\nRecipes sharing this Cooldown:\n"),
        [CraftSim.CONST.TEXT.COOLDOWNS_RECIPE_READY] = f.g("Ready"),

        -- concentration module

        [CraftSim.CONST.TEXT.CONCENTRATION_TRACKER_TITLE] = "CraftSim Concentration",
        [CraftSim.CONST.TEXT.CONCENTRATION_TRACKER_LABEL_CRAFTER] = "Crafter",
        [CraftSim.CONST.TEXT.CONCENTRATION_TRACKER_LABEL_CURRENT] = "Current",
        [CraftSim.CONST.TEXT.CONCENTRATION_TRACKER_LABEL_MAX] = "Max",
        [CraftSim.CONST.TEXT.CONCENTRATION_TRACKER_MAX] = f.g("MAX"),
        [CraftSim.CONST.TEXT.CONCENTRATION_TRACKER_MAX_VALUE] = "Max: ",
        [CraftSim.CONST.TEXT.CONCENTRATION_TRACKER_FULL] = f.g("Concentration Full"),
        [CraftSim.CONST.TEXT.CONCENTRATION_TRACKER_SORT_MODE_CHARACTER] = "Character",
        [CraftSim.CONST.TEXT.CONCENTRATION_TRACKER_SORT_MODE_CONCENTRATION] = "Concentration",
        [CraftSim.CONST.TEXT.CONCENTRATION_TRACKER_SORT_MODE_PROFESSION] = "Profession",
        [CraftSim.CONST.TEXT.CONCENTRATION_TRACKER_FORMAT_MODE_EUROPE_MAX_DATE] = "European - Max Date",
        [CraftSim.CONST.TEXT.CONCENTRATION_TRACKER_FORMAT_MODE_AMERICA_MAX_DATE] = "American - Max Date",
        [CraftSim.CONST.TEXT.CONCENTRATION_TRACKER_FORMAT_MODE_HOURS_LEFT] = "Hours Left",

        -- static popups
        [CraftSim.CONST.TEXT.STATIC_POPUPS_YES] = "Yes",
        [CraftSim.CONST.TEXT.STATIC_POPUPS_NO] = "No",

        -- frames
        [CraftSim.CONST.TEXT.FRAMES_RESETTING] = "resetting frameID: ",
        [CraftSim.CONST.TEXT.FRAMES_WHATS_NEW] = "CraftSim What's New?",
        [CraftSim.CONST.TEXT.FRAMES_JOIN_DISCORD] = "Join the Discord!",
        [CraftSim.CONST.TEXT.FRAMES_DONATE_KOFI] = "Visit CraftSim on Kofi",
        [CraftSim.CONST.TEXT.FRAMES_NO_INFO] = "No Info",

        -- node data
        [CraftSim.CONST.TEXT.NODE_DATA_RANK_TEXT] = "Rank ",
        [CraftSim.CONST.TEXT.NODE_DATA_TOOLTIP] = "\n\nTotal Stats from Talent:\n",

        -- columns
        [CraftSim.CONST.TEXT.SOURCE_COLUMN_AH] = "AH",
        [CraftSim.CONST.TEXT.SOURCE_COLUMN_OVERRIDE] = "OR",
        [CraftSim.CONST.TEXT.SOURCE_COLUMN_WO] = "WO",
    }
end
