---@class CraftSim
local CraftSim = select(2, ...)

CraftSim.LOCAL_EN = {}

---@return table<CraftSim.LOCALIZATION_IDS, string>
function CraftSim.LOCAL_EN:GetData()
    local f = CraftSim.GUTIL:GetFormatter()
    local cm = function(i, s) return CraftSim.MEDIA:GetAsTextIcon(i, s) end
    local shatter_post_login_tooltip = "\n\n" ..
        f.white("Cast Shatter once after login so CraftSim matches your buff.")
    return {
        -- REQUIRED:
        STAT_MULTICRAFT = "Multicraft",
        STAT_RESOURCEFULNESS = "Resourcefulness",
        STAT_INGENUITY = "Ingenuity",
        STAT_CRAFTINGSPEED = "Crafting Speed",
        EQUIP_MATCH_STRING = "Equip:",
        ENCHANTED_MATCH_STRING = "Enchanted:",

        -- OPTIONAL (Defaulting to EN if not available):

        -- shared prof cds
        DF_ALCHEMY_TRANSMUTATIONS = "DF - Transmutations",
        MIDNIGHT_ALCHEMY_TRANSMUTATIONS = "Midnight – Transmutations",

        -- expansions

        EXPANSION_VANILLA = "Classic",
        EXPANSION_THE_BURNING_CRUSADE = "The Burning Crusade",
        EXPANSION_WRATH_OF_THE_LICH_KING = "Wrath of the Lich King",
        EXPANSION_CATACLYSM = "Cataclysm",
        EXPANSION_MISTS_OF_PANDARIA = "Mists of Pandaria",
        EXPANSION_WARLORDS_OF_DRAENOR = "Warlords of Draenor",
        EXPANSION_LEGION = "Legion",
        EXPANSION_BATTLE_FOR_AZEROTH = "Battle of Azeroth",
        EXPANSION_SHADOWLANDS = "Shadowlands",
        EXPANSION_DRAGONFLIGHT = "Dragonflight",
        EXPANSION_THE_WAR_WITHIN = "The War Within",
        EXPANSION_MIDNIGHT = "Midnight",

        -- professions

        PROFESSIONS_BLACKSMITHING = "Blacksmithing",
        PROFESSIONS_LEATHERWORKING = "Leatherworking",
        PROFESSIONS_ALCHEMY = "Alchemy",
        PROFESSIONS_HERBALISM = "Herbalism",
        PROFESSIONS_COOKING = "Cooking",
        PROFESSIONS_MINING = "Mining",
        PROFESSIONS_TAILORING = "Tailoring",
        PROFESSIONS_ENGINEERING = "Engineering",
        PROFESSIONS_ENCHANTING = "Enchanting",
        PROFESSIONS_FISHING = "Fishing",
        PROFESSIONS_SKINNING = "Skinning",
        PROFESSIONS_JEWELCRAFTING = "Jewelcrafting",
        PROFESSIONS_INSCRIPTION = "Inscription",

        -- Other Statnames

        STAT_SKILL = "Skill",
        STAT_MULTICRAFT_BONUS = "Multicraft ExtraItems",
        STAT_RESOURCEFULNESS_BONUS = "Resourcefulness ExtraItems",
        STAT_CRAFTINGSPEED_BONUS = "Crafting Speed",
        STAT_INGENUITY_BONUS = "Ingenuity Saved Conc",
        STAT_INGENUITY_LESS_CONCENTRATION = "Less Concentration Use",
        STAT_PHIAL_EXPERIMENTATION = "Phial Breakthrough",
        STAT_POTION_EXPERIMENTATION = "Potion Breakthrough",

        -- Profit Breakdown Tooltips
        RESOURCEFULNESS_EXPLANATION_TOOLTIP =
        "Resourcefulness procs for every reagent individually and then saves about 30% of its quantity.\n\nThe average value it saves is the average saved value of EVERY combination and their chances.\n(All reagents proccing at once is very unlikely but saves a lot)\n\nThe average total saved reagent costs is the sum of the saved reagent costs of all combinations weighted against their chance.",

        RECIPE_DIFFICULTY_EXPLANATION_TOOLTIP =
        "Recipe difficulty determines where the breakpoints of the different qualities are.\n\nFor recipes with five qualities they are at 20%, 50%, 80% and 100% recipe difficulty as skill.\nFor recipes with three qualities they are at 50% and 100%",
        MULTICRAFT_EXPLANATION_TOOLTIP =
        "Multicraft gives you a chance of crafting more items than you would usually produce with a recipe.\n\nThe additional amount is usually between 1 and 2.5y\nwhere y = the usual amount 1 craft yields.",
        REAGENTSKILL_EXPLANATION_TOOLTIP =
        "The quality of your reagents can give you a maximum of 40% of the base recipe difficulty as bonus skill.\n\nAll Q1 Reagents: 0% Bonus\nAll Q2 Reagents: 20% Bonus\nAll Q3 Reagents: 40% Bonus\n\nThe skill is calculated by the amount of reagents of each quality weighted against their quality\nand a specific weight value that is unique to each individual crafting reagent item with quality\n\nThis is however different for recrafts. There the maximum the reagents can increase the quality\nis dependent on the quality of reagents the item was originally crafted with.\nThe exact workings are not known.\nHowever, CraftSim internally compares the achieved skill with all q3 and calculates\nthe max skill increase based on that.",
        REAGENTFACTOR_EXPLANATION_TOOLTIP =
        "The maximum the reagents can contribute to a recipe is most of the time 40% of the base recipe difficulty.\n\nHowever in the case of recrafting, this value can vary based on previous crafts\nand the quality of reagents that were used.",

        -- Simulation Mode
        SIMULATION_MODE_NONE = "None",
        SIMULATION_MODE_LABEL = "Simulation Mode",
        SIMULATION_MODE_TITLE = "CraftSim Simulation Mode",
        SIMULATION_MODE_TOOLTIP =
        "CraftSim's Simulation Mode makes it possible to play around with a recipe without restrictions",
        SIMULATION_MODE_OPTIONAL = "Optional #",
        SIMULATION_MODE_FINISHING = "Finishing #",
        SIMULATION_MODE_QUALITY_BUTTON_TOOLTIP = "Max All Reagents of Quality ",
        SIMULATION_MODE_CLEAR_BUTTON = "Clear",
        SIMULATION_MODE_CONCENTRATION = " Concentration",
        SIMULATION_MODE_CONCENTRATION_COST = "Concentration Cost: ",
        CONCENTRATION_ESTIMATED_TIME_UNTIL = "Craftable at: %s",
        SIMULATION_MODE_QUALITY_METER_NEEDED = "Needed: ",
        SIMULATION_MODE_QUALITY_METER_MISSING = "Missing: ",
        SIMULATION_MODE_QUALITY_METER_MAX = "MAX",

        -- Details Frame
        RECIPE_DIFFICULTY_LABEL = "Recipe Difficulty: ",
        MULTICRAFT_LABEL = "Multicraft: ",
        RESOURCEFULNESS_LABEL = "Resourcefulness: ",
        RESOURCEFULNESS_BONUS_LABEL = "Resourcefulness Item Bonus: ",
        INGENUITY_LABEL = "Ingenuity: ",
        INGENUITY_EXPLANATION_TOOLTIP =
        "Ingenuity gives you a chance to receive a partial refund of concentration spent when crafting with concentration.",
        CONCENTRATION_LABEL = "Concentration: ",
        REAGENT_QUALITY_BONUS_LABEL = "Reagent Quality Bonus: ",
        REAGENT_QUALITY_MAXIMUM_LABEL = "Reagent Quality Maximum %: ",
        EXPECTED_QUALITY_LABEL = "Expected Quality: ",
        NEXT_QUALITY_LABEL = "Next Quality: ",
        MISSING_SKILL_LABEL = "Missing Skill: ",
        SKILL_LABEL = "Skill: ",
        MULTICRAFT_BONUS_LABEL = "Multicraft Item Bonus: ",

        -- Statistics
        STATISTICS_CDF_EXPLANATION =
        "This is calculated by using the 'abramowitz and stegun' approximation (1985) of the CDF (Cumulative Distribution Function)\n\nYou will notice that its always around 50% for 1 craft.\nThis is because 0 is most of the time close to the average profit.\nAnd the chance of getting the mean of the CDF is always 50%.\n\nHowever, the rate of change can be very different between recipes.\nIf it is more likely to have a positive profit than a negative one, it will steadly increase.\nThis is of course also true for the other direction.",
        EXPLANATIONS_PROFIT_CALCULATION_EXPLANATION = f.r("Warning: ") .. " Math ahead!\n\n" ..
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
        POPUP_NO_PRICE_SOURCE_SYSTEM = "No Supported Price Source Available!",
        POPUP_NO_PRICE_SOURCE_TITLE = "CraftSim Price Source Warning",
        POPUP_NO_PRICE_SOURCE_WARNING =
        "No price source found!\n\nYou need to have installed at least one of the\nfollowing price source addons to\nutilize CraftSim's profit calculations:\n\n\n",
        POPUP_NO_PRICE_SOURCE_WARNING_SUPPRESS = "Do not show warning again",
        POPUP_NO_PRICE_SOURCE_WARNING_ACCEPT = "OK",

        -- Reagents Frame
        REAGENT_OPTIMIZATION_TITLE = "CraftSim Reagent Optimization",
        REAGENTS_REACHABLE_QUALITY = "Reachable Quality: ",
        REAGENTS_MISSING = "Reagents missing",
        REAGENTS_AVAILABLE = "Reagents available",
        REAGENTS_CHEAPER = "Cheapest Reagents",
        REAGENTS_BEST_COMBINATION = "Best combination assigned",
        REAGENTS_NO_COMBINATION = "No combination found \nto increase quality",
        REAGENTS_ASSIGN = "Assign",
        REAGENTS_MAXIMUM_QUALITY = "Maximum Quality: ",
        REAGENTS_AVERAGE_PROFIT_LABEL = "Average Ø Profit: ",
        REAGENTS_AVERAGE_PROFIT_TOOLTIP = f.bb("The Average Profit per Craft") ..
            " when using " .. f.l("this reagent allocation"),
        REAGENTS_OPTIMIZE_BEST_ASSIGNED = "Best Reagents Assigned",
        REAGENTS_CONCENTRATION_LABEL = "Concentration: ",
        REAGENTS_OPTIMIZE_INFO = "Shift + LMB on numbers to put the item link in chat",
        ADVANCED_OPTIMIZATION_BUTTON = "Advanced Optimization",
        REAGENTS_OPTIMIZE_TOOLTIP = "(Resets on Edit)\nEnables " ..
            f.gold("Concentration Value") .. " and " .. f.bb("Finishing Reagent ") .. " Optimization",

        -- Specialization Info Frame
        SPEC_INFO_TITLE = "CraftSim Specialization Info",
        SPEC_INFO_SIMULATE_KNOWLEDGE_DISTRIBUTION = "Simulate Knowledge Distribution",
        SPEC_INFO_NODE_TOOLTIP = "This node grants you following stats for this recipe:",
        SPEC_INFO_WORK_IN_PROGRESS = "No Data Available",

        -- Crafting Results Frame
        CRAFT_LOG_TITLE = "CraftSim Craft Log",
        CRAFT_LOG_ADV_TITLE = "CraftSim Advanced Craft Log",
        CRAFT_LOG_LOG = "Craft Log",
        CRAFT_LOG_LOG_1 = "Profit: ",
        CRAFT_LOG_LOG_2 = "Concentration Saved: ",
        CRAFT_LOG_LOG_3 = "Multicraft: ",
        CRAFT_LOG_LOG_4 = "Resources Saved: ",
        CRAFT_LOG_LOG_5 = "Chance: ",
        CRAFT_LOG_CRAFTED_ITEMS = "Crafted Items",
        CRAFT_LOG_SESSION_PROFIT = "Session Profit: ",
        CRAFT_LOG_RESET_DATA = "Reset Data",
        CRAFT_LOG_EXPORT_JSON = "Export JSON",
        CRAFT_LOG_RECIPE_STATISTICS = "Recipe Statistics",
        CRAFT_LOG_NOTHING = "Nothing crafted yet!",
        CRAFT_LOG_CALCULATION_COMPARISON_NUM_CRAFTS_PREFIX = "Crafts: ",
        CRAFT_LOG_STATISTICS_2 = "Expected Ø Profit: ",
        CRAFT_LOG_STATISTICS_3 = "Real Ø Profit: ",
        CRAFT_LOG_STATISTICS_4 = "Real Profit: ",
        CRAFT_LOG_STATISTICS_5 = "Procs - Real / Expected: ",
        CRAFT_LOG_STATISTICS_7 = "Multicraft: ",
        CRAFT_LOG_STATISTICS_8 = "- Ø Extra Items: ",
        CRAFT_LOG_STATISTICS_9 = "Resourcefulness Procs: ",
        CRAFT_LOG_CALCULATION_COMPARISON_NUM_CRAFTS_PREFIX0 = "- Ø Saved Costs: ",
        CRAFT_LOG_CALCULATION_COMPARISON_NUM_CRAFTS_PREFIX1 = "Profit: ",
        CRAFT_LOG_SAVED_REAGENTS = "Saved Reagents",
        CRAFT_LOG_DISABLE_CHECKBOX = f.r("Disable") .. " Craft Logs",
        CRAFT_LOG_DISABLE_CHECKBOX_TOOLTIP = "Enabling this stops the recording of any crafts when crafting and may " ..
            f.g("increase performance"),
        CRAFT_LOG_REAGENT_DETAILS_TAB = "Reagent Details",
        CRAFT_LOG_RESULT_ANALYSIS_TAB = "Result Analysis",
        CRAFT_LOG_RESULT_ANALYSIS_TAB_DISTRIBUTION_LABEL = "Result Distribution",
        CRAFT_LOG_RESULT_ANALYSIS_TAB_DISTRIBUTION_HELP =
        "Relative distribution of crafted item results.\n(Ignoring Multicraft Quantities)",
        CRAFT_LOG_RESULT_ANALYSIS_TAB_MULTICRAFT = "Multicraft",
        CRAFT_LOG_RESULT_ANALYSIS_TAB_RESOURCEFULNESS = "Resourcefulness",
        CRAFT_LOG_RESULT_ANALYSIS_TAB_YIELD_DDISTRIBUTION = "Yield Distribution",

        -- Stats Weight Frame
        STAT_WEIGHTS_TITLE = "CraftSim Average Profit",
        EXPLANATIONS_TITLE = "CraftSim Average Profit Explanation",
        STAT_WEIGHTS_SHOW_EXPLANATION_BUTTON = "Show Explanation",
        STAT_WEIGHTS_HIDE_EXPLANATION_BUTTON = "Hide Explanation",
        STAT_WEIGHTS_SHOW_STATISTICS_BUTTON = "Show Statistics",
        STAT_WEIGHTS_HIDE_STATISTICS_BUTTON = "Hide Statistics",
        STAT_WEIGHTS_PROFIT_CRAFT = "Ø Profit / Craft: ",
        EXPLANATIONS_BASIC_PROFIT_TAB = "Basic Profit Calculation",

        -- Cost Details Frame
        PRICING_TITLE = "CraftSim Pricing",
        PRICING_EXPLANATION = "Here you can see an overview of all possible prices of the used reagents.\nThe " ..
            f.bb("'Used Source'") ..
            " column indicates which one of the prices is used.\n\n" ..
            f.g("AH") ..
            " .. Auction House Price\n" ..
            f.l("OR") ..
            " .. Price Override\n" ..
            f.l("OR") ..
            " will always be used if set.\n\n" ..
            f.bb("Right Click") .. " on any reagent or result item to override its price by a custom value",
        PRICING_CRAFTING_COSTS = "Crafting Costs: ",
        PRICING_ITEM_HEADER = "Item",
        PRICING_DELETE_ALL_OVERRIDES = "Delete All Overrides",
        COST_OPTIMIZATION_PRICE_HEADER = "Price",
        COST_OPTIMIZATION_USED_SOURCE = "Source",
        PRICING_AVG_CRAFTING_COST = "Ø Craft Cost",
        COST_OPTIMIZATION_SUB_RECIPE_OPTIMIZATION_TOOLTIP = "If enabled " ..
            f.l("CraftSim") .. " considers the " .. f.g("optimized crafting costs") ..
            " of your character and your alts\nif they are able to craft that item.\n\n" ..
            f.r("Might decrease performance a bit due to a lot of additional calculations"),
        COST_OPTIMIZATION_SUB_RECIPE_MAX_DEPTH_LABEL = "Sub Recipe Calculation Depth",
        COST_OPTIMIZATION_SUB_RECIPE_INCLUDE_CONCENTRATION = "Enable Concentration",
        COST_OPTIMIZATION_SUB_RECIPE_INCLUDE_CONCENTRATION_TOOLTIP = "If enabled, " ..
            f.l("CraftSim") .. " will include reagent qualities even if concentration is necessary.",
        COST_OPTIMIZATION_SUB_RECIPE_INCLUDE_COOLDOWN_RECIPES = "Include Cooldown Recipes",
        COST_OPTIMIZATION_SUB_RECIPE_INCLUDE_COOLDOWN_RECIPES_TOOLTIP = "If enabled, " ..
            f.l("CraftSim") .. " will ignore cooldown requirements of recipes when calculating self crafted reagents",
        COST_OPTIMIZATION_SUB_RECIPE_SELECT_RECIPE_CRAFTER = "Select Recipe Crafter",
        PRICING_REAGENT_LIST_AH_COLUMN_AUCTION_BUYOUT = "Auction Buyout: ",
        PRICING_REAGENT_LIST_OVERRIDE = "\n\nOverride",
        PRICING_REAGENT_LIST_EXPECTED_COSTS_TOOLTIP = "\n\nCrafting ",
        PRICING_REAGENT_LIST_EXPECTED_COSTS_PRE_ITEM = "\n- Expected Costs Per Item: ",
        PRICING_REAGENT_LIST_CONCENTRATION_COST = f.gold("Concentration Cost: "),
        PRICING_REAGENT_LIST_CONCENTRATION = "Concentration: ",

        -- Statistics Frame
        STATISTICS_TITLE = "CraftSim Statistics",
        STATISTICS_EXPECTED_PROFIT = "Expected Profit (μ)",
        STATISTICS_CHANCE_OF = "Chance of ",
        STATISTICS_PROFIT = "Profit",
        STATISTICS_AFTER = " after",
        STATISTICS_CRAFTS = "Crafts: ",
        STATISTICS_QUALITY_HEADER = "Quality",
        STATISTICS_MULTICRAFT_HEADER = "Multicraft",
        STATISTICS_RESOURCEFULNESS_HEADER = "Resourcefulness",
        STATISTICS_EXPECTED_PROFIT_HEADER = "Expected Profit",
        PROBABILITY_TABLE_TITLE = "Recipe Probability Table",
        STATISTICS_PROBABILITY_TABLE_TAB = "Probability Table",
        STATISTICS_CONCENTRATION_TAB = "Concentration",
        STATISTICS_CONCENTRATION_CURVE_GRAPH = "Concentration Cost Curve",
        STATISTICS_CONCENTRATION_CURVE_GRAPH_HELP = "Concentration Cost based on Player Skill for given Recipe\n" ..
            f.bb("X Axis: ") .. " Player Skill\n" ..
            f.bb("Y Axis: ") .. " Concentration Cost",

        -- Price Details Frame
        COST_OVERVIEW_TITLE = "CraftSim Price Details",
        PRICE_DETAILS_INV_AH = "Inv/AH",
        PRICE_DETAILS_ITEM = "Item",
        PRICE_DETAILS_PRICE_ITEM = "Price/Item",
        PRICE_DETAILS_PROFIT_ITEM = "Profit/Item",

        -- Price Override Frame
        PRICE_OVERRIDE_TITLE = "CraftSim Price Overrides",
        PRICE_OVERRIDE_HINT = "(You can now override prices directly in the " .. f.bb("Cost Optimization Module") .. ")",
        PRICE_OVERRIDE_REQUIRED_REAGENTS = "Required Reagents",
        PRICE_OVERRIDE_OPTIONAL_REAGENTS = "Optional Reagents",
        PRICE_OVERRIDE_FINISHING_REAGENTS = "Finishing Reagents",
        PRICE_OVERRIDE_RESULT_ITEMS = "Result Items",
        PRICE_OVERRIDE_ACTIVE_OVERRIDES = "Active Overrides",
        PRICE_OVERRIDE_ACTIVE_OVERRIDES_TOOLTIP =
        "'(as result)' -> price override only considered when item is a result of a recipe",
        PRICE_OVERRIDE_CLEAR_ALL = "Clear All",
        PRICE_OVERRIDE_SAVE = "Save",
        PRICE_OVERRIDE_SAVED = "Saved",
        PRICE_OVERRIDE_REMOVE = "Remove",

        -- Recipe Scan Frame
        RECIPE_SCAN_TITLE = "CraftSim Recipe Scan",
        RECIPE_SCAN_MODE = "Scan Mode",
        RECIPE_SCAN_SORT_MODE = "Sort Mode",
        RECIPE_SCAN_SCAN_RECIPIES = "Scan Recipes",
        RECIPE_SCAN_SCAN_CANCEL = "Cancel",
        RECIPE_SCAN_SCANNING = "Scanning",
        RECIPE_SCAN_INCLUDE_NOT_LEARNED = "Include not learned",
        RECIPE_SCAN_INCLUDE_NOT_LEARNED_TOOLTIP = "Include recipes you do not have learned in the recipe scan",
        RECIPE_SCAN_INCLUDE_SOULBOUND = "Include Soulbound",
        RECIPE_SCAN_INCLUDE_SOULBOUND_TOOLTIP =
        "Include soulbound recipes in the recipe scan.\n\nIt is recommended to set a price override (e.g. to simulate a target comission)\nin the Price Override Module for that recipe's crafted items",
        RECIPE_SCAN_INCLUDE_GEAR = "Include Gear",
        RECIPE_SCAN_INCLUDE_GEAR_TOOLTIP = "Include all form of gear recipes in the recipe scan",
        RECIPE_SCAN_OPTIMIZE_TOOLS = "Optimize Profession Tools",
        RECIPE_SCAN_OPTIMIZE_TOOLS_TOOLTIP = "For each recipe optimize your profession tools for profit\n\n",
        RECIPE_SCAN_OPTIMIZE_TOOLS_WARNING =
        "Might lower performance during scanning\nif you have a lot of tools in your inventory",
        RECIPE_SCAN_CRAFTER_HEADER = "Crafter",
        RECIPE_SCAN_RECIPE_HEADER = "Recipe",
        RECIPE_SCAN_LEARNED_HEADER = "Learned",
        RECIPE_SCAN_RESULT_HEADER = "Result",
        RECIPE_SCAN_AVERAGE_PROFIT_HEADER = "Ø Profit",
        RECIPE_SCAN_CONCENTRATION_VALUE_HEADER = "C. Value",
        RECIPE_SCAN_CONCENTRATION_COST_HEADER = "C. Cost",
        RECIPE_SCAN_TOP_GEAR_HEADER = "Top Gear",
        RECIPE_SCAN_INV_AH_HEADER = "Inv/AH",
        RECIPE_SCAN_SORT_BY_MARGIN = "Sort by Profit %",
        RECIPE_SCAN_SORT_BY_MARGIN_TOOLTIP =
        "Sort the profit list by profit relative to crafting costs.\n(Requires a new scan)",
        RECIPE_SCAN_USE_INSIGHT_CHECKBOX = "Use " .. f.bb("Insight") .. " if possible",
        RECIPE_SCAN_USE_INSIGHT_CHECKBOX_TOOLTIP = "Use " ..
            f.bb("Illustrious Insight") ..
            " or\n" .. f.bb("Lesser Illustrious Insight") .. " as optional reagent for recipes that allow it.",
        RECIPE_SCAN_ONLY_FAVORITES_CHECKBOX = "Only Favorites",
        RECIPE_SCAN_ONLY_FAVORITES_CHECKBOX_TOOLTIP = "Scan only your favorite recipes",
        RECIPE_SCAN_EQUIPPED = "Equipped",
        RECIPE_SCAN_MODE_OPTIMIZE = "Optimize",
        RECIPE_SCAN_SORT_MODE_PROFIT = "Profit",
        RECIPE_SCAN_SORT_MODE_RELATIVE_PROFIT = "Relative Profit",
        RECIPE_SCAN_SORT_MODE_CONCENTRATION_VALUE = "Concentration Value",
        RECIPE_SCAN_SORT_MODE_CONCENTRATION_COST = "Concentration Cost",
        RECIPE_SCAN_SORT_MODE_CRAFTING_COST = "Crafting Cost",
        RECIPE_SCAN_EXPANSION_FILTER_BUTTON = "Expansion Filter",
        RECIPE_SCAN_CATEGORY_FILTER_BUTTON = "Category Filter",
        RECIPE_SCAN_CATEGORY_FILTER_ENABLE_ALL = "Enable All",
        RECIPE_SCAN_ALTPROFESSIONS_FILTER_BUTTON = "Alt Professions",
        RECIPE_SCAN_SCAN_ALL_BUTTON_READY = "Scan Professions",
        RECIPE_SCAN_SCAN_ALL_BUTTON_SCANNING = "Scanning...",
        RECIPE_SCAN_TAB_LABEL_SCAN = "Recipe Scan",
        RECIPE_SCAN_TAB_LABEL_OPTIONS = "Scan Options",
        RECIPE_SCAN_IMPORT_ALL_PROFESSIONS_CHECKBOX_LABEL = "All Scanned Professions",
        RECIPE_SCAN_IMPORT_ALL_PROFESSIONS_CHECKBOX_TOOLTIP = f.g("True: ") ..
            "Import Scan Results from all enabled and scanned professions\n\n" ..
            f.r("False: ") .. "Import Scan Results only from currently selected profession",
        RECIPE_SCAN_CACHED_RECIPES_TOOLTIP = "Whenever you open or scan a recipe on a character, " ..
            f.l("CraftSim") ..
            " remembers it.\n\nOnly recipes from your alts that " ..
            f.l("CraftSim") .. " can remember will be scanned with " .. f.bb("RecipeScan\n\n") ..
            "The actual amount of recipes that are scanned is then based on your " .. f.e("Recipe Scan Options"),
        RECIPE_SCAN_CONCENTRATION_TOGGLE = " Concentration",
        RECIPE_SCAN_CONCENTRATION_TOGGLE_TOOLTIP = "Toggle Concentration",
        RECIPE_SCAN_OPTIMIZE_SUBRECIPES = "Optimize Sub Recipes " .. f.bb("(experimental)"),
        RECIPE_SCAN_OPTIMIZE_SUBRECIPES_TOOLTIP = "If enabled, " ..
            f.l("CraftSim") .. " also optimizes crafts of cached reagent recipes of scanned recipes and uses their\n" ..
            f.bb("expected costs") .. " to calculate the crafting costs for the final product.\n\n" ..
            f.r("Warning: This might reduce scanning performance"),
        RECIPE_SCAN_CACHED_RECIPES = "Cached Recipes: ",
        RECIPE_SCAN_ENABLE_CONCENTRATION = f.bb("Enable ") .. f.gold("Concentration"),
        RECIPE_SCAN_ONLY_FAVORITES = f.r("Only ") .. f.bb("Favorites"),
        RECIPE_SCAN_INCLUDE_SOULBOUND_ITEMS = "Include " .. f.e("Soulbound") .. " Items",
        RECIPE_SCAN_INCLUDE_UNLEARNED_RECIPES = "Include " .. f.r("Unlearned") .. " Recipes",
        RECIPE_SCAN_INCLUDE_GEAR_LABEL = "Include Gear",
        RECIPE_SCAN_REAGENT_ALLOCATION = "Reagent Allocation",
        RECIPE_SCAN_REAGENT_ALLOCATION_Q1 = "All Q1",
        RECIPE_SCAN_REAGENT_ALLOCATION_Q2 = "All Q2",
        RECIPE_SCAN_REAGENT_ALLOCATION_Q3 = "All Q3",
        RECIPE_SCAN_AUTOSELECT_TOP_PROFIT = "Autoselect " .. f.g("Top Profit Quality"),
        RECIPE_SCAN_OPTIMIZE_PROFESSION_GEAR = "Optimize " .. f.bb("Profession Gear"),
        RECIPE_SCAN_OPTIMIZE_CONCENTRATION = "Optimize " .. f.gold("Concentration"),
        RECIPE_SCAN_OPTIMIZE_FINISHING_REAGENTS = "Optimize " .. f.bb("Finishing Reagents"),

        -- Shared OptimizationOptions Widget
        OPTIMIZATION_OPTIONS_OPTIMIZE_PROFESSION_TOOLS = "Optimize " .. f.bb("Profession Tools"),
        OPTIMIZATION_OPTIONS_INCLUDE_SOULBOUND_FINISHING_REAGENTS = "Include " ..
            f.e("Soulbound") .. f.bb(" Finishing Reagents"),
        OPTIMIZATION_OPTIONS_ONLY_HIGHEST_QUALITY_SOULBOUND_FINISHING_REAGENTS = "Only " ..
            f.g("Highest Quality") .. f.e(" Soulbound") .. f.bb(" Finishing Reagents"),
        OPTIMIZATION_OPTIONS_ONLY_HIGHEST_QUALITY_SOULBOUND_FINISHING_REAGENTS_TOOLTIP =
            "When enabled, for each finishing reagent slot only the highest quality soulbound reagent you own is considered.\n\nFor example, if you have both a " ..
            f.e("Multicraft Matrix") ..
            " and a " .. f.e("Multicraft Manifold") .. " in your bags, only the Manifold will be used.",
        OPTIMIZATION_OPTIONS_FINISHING_REAGENTS_ALGORITHM = f.bb("Finishing Reagents") .. " Algorithm",
        OPTIMIZATION_OPTIONS_FINISHING_REAGENTS_SIMPLE = "Simple",
        OPTIMIZATION_OPTIONS_FINISHING_REAGENTS_SIMPLE_TOOLTIP =
        "Optimizes reagent allocation first, then concentration, then selects the best finishing reagent for each slot individually.",
        OPTIMIZATION_OPTIONS_FINISHING_REAGENTS_PERMUTATION = "Permutation Based",
        OPTIMIZATION_OPTIONS_FINISHING_REAGENTS_PERMUTATION_TOOLTIP =
            "Tries all possible finishing reagent combinations and for each individually optimizes reagents (if enabled) and concentration (if enabled), then selects the most profitable combination.\n\n" ..
            f.r("Warning: This may take significantly longer to complete."),

        RECIPE_SCAN_SEND_TO_CRAFT_QUEUE = "Send to Craft Queue",
        RECIPE_SCAN_CREATE_CRAFT_LIST = "Create CraftList",
        RECIPE_SCAN_SEND_TO_CRAFTQUEUE_CREATE_CRAFT_LIST = "Create " .. f.bb("Craft List") .. " instead",
        RECIPE_SCAN_ADD_TO_CRAFT_LIST = f.g("Add") .. " to Craft List",
        RECIPE_SCAN_REMOVE_FROM_CRAFT_LIST = f.r("Remove") .. " from Craft List",
        RECIPE_SCAN_CRAFT_LISTS_TOOLTIP_HEADER = f.bb("Craft Lists") .. ":",
        RECIPE_SCAN_PROFIT_MARGIN_THRESHOLD = "Profit Margin Threshold (%): ",
        RECIPE_SCAN_DEFAULT_QUEUE_AMOUNT = "Default Queue Amount: ",
        RECIPE_SCAN_ADD_TO_CRAFT_QUEUE = "Add to Craft Queue",
        RECIPE_SCAN_SORT_BY = "Sort By",
        RECIPE_SCAN_SORT_ASCENDING = "Ascending",
        RECIPE_SCAN_REMOVE_FAVORITE = f.r("Remove") .. " Favorite",
        RECIPE_SCAN_ADD_FAVORITE = f.g("Add") .. " Favorite",
        RECIPE_SCAN_FAVORITES_CRAFTER_ONLY = f.r("Favorites can only be changed on the crafter"),
        RECIPE_SCAN_QUEUE_HINT = "Press " ..
            CreateAtlasMarkup("NPE_LeftClick", 20, 20, 2) .. " + shift to queue selected recipe into the " ..
            f.bb("Craft Queue"),
        RECIPE_SCAN_REMOVE_CACHED_DATA = f.r("Remove"),
        RECIPE_SCAN_REMOVE_CACHED_DATA_TOOLTIP = f.r("Remove ") ..
            "all cached data about this character - profession combination",
        RECIPE_SCAN_USE_TSM_RESTOCK = "Use " .. f.bb("TSM") .. " Restock Amount Expression",
        RECIPE_SCAN_TSM_SALE_RATE_THRESHOLD = f.bb("TSM") .. " Sale Rate Threshold: ",
        RECIPE_SCAN_AUTOSELECT_OPEN_PROFESSION = "Autoselect " .. f.bb("Open Profession"),
        RECIPE_SCAN_UPDATE_LAST_CRAFTING_COST = "Update " .. f.bb("Last Crafting Cost") .. " DB",
        RECIPE_SCAN_UPDATE_LAST_CRAFTING_COST_TOOLTIP = "If enabled, the " .. f.bb("Last Crafting Cost") ..
            " database is updated for each scanned recipe.\n\nThis allows querying the last known average crafting cost per item via the CraftSim API.",

        -- Recipe Top Gear
        TOP_GEAR_TITLE = "CraftSim Top Gear",
        TOP_GEAR_AUTOMATIC = "Automatic",
        TOP_GEAR_AUTOMATIC_TOOLTIP =
        "Automatically simulate Top Gear for your selected mode whenever a recipe updates.\n\nTurning this off may increase performance.",
        TOP_GEAR_SIMULATE = "Simulate Top Gear",
        TOP_GEAR_EQUIP = "Equip",
        TOP_GEAR_SIMULATE_QUALITY = "Quality: ",
        TOP_GEAR_SIMULATE_EQUIPPED = "Top Gear equipped",
        TOP_GEAR_SIMULATE_PROFIT_DIFFERENCE = "Ø Profit Difference\n",
        TOP_GEAR_SIMULATE_NEW_MUTLICRAFT = "New Multicraft\n",
        TOP_GEAR_SIMULATE_NEW_CRAFTING_SPEED = "New Crafting Speed\n",
        TOP_GEAR_SIMULATE_NEW_RESOURCEFULNESS = "New Resourcefulness\n",
        TOP_GEAR_SIMULATE_NEW_SKILL = "New Skill\n",
        TOP_GEAR_SIMULATE_UNHANDLED = "Unhandled Sim Mode",

        TOP_GEAR_SIM_MODES_PROFIT = "Top Profit",
        TOP_GEAR_SIM_MODES_SKILL = "Top Skill",
        TOP_GEAR_SIM_MODES_MULTICRAFT = "Top Multicraft",
        TOP_GEAR_SIM_MODES_RESOURCEFULNESS = "Top Resourcefulness",
        TOP_GEAR_SIM_MODES_CRAFTING_SPEED = "Top Crafting Speed",

        -- Options
        OPTIONS_TITLE = "CraftSim",
        OPTIONS_GENERAL_TAB = "General",
        OPTIONS_GENERAL_PRICE_SOURCE = "Price Source",
        OPTIONS_GENERAL_CURRENT_PRICE_SOURCE = "Current Price Source: ",
        OPTIONS_GENERAL_NO_PRICE_SOURCE = "No Supported Price Source Addon loaded!",
        OPTIONS_GENERAL_SHOW_PROFIT = "Show Profit Percentage",
        OPTIONS_GENERAL_SHOW_PROFIT_TOOLTIP = "Show the percentage of profit to crafting costs besides the gold value",
        OPTIONS_GENERAL_REMEMBER_LAST_RECIPE = "Remember Last Recipe",
        OPTIONS_GENERAL_REMEMBER_LAST_RECIPE_TOOLTIP = "Reopen last selected recipe when opening the crafting window",
        OPTIONS_GENERAL_SUPPORTED_PRICE_SOURCES = "Supported Price Sources:",
        OPTIONS_PERFORMANCE_RAM = "Enable RAM cleanup while crafting",
        OPTIONS_PERFORMANCE_RAM_CRAFTS = "Crafts",
        OPTIONS_PERFORMANCE_RAM_TOOLTIP =
        "When enabled, CraftSim will clear your RAM every specified number of crafts from unused data to prevent memory from building up.\nMemory Build Up can also happen because of other addons and is not CraftSim specific.\nA cleanup will affect the whole WoW RAM Usage.",
        OPTIONS_MODULES_TAB = "Modules",
        OPTIONS_PROFIT_CALCULATION_TAB = "Profit Calculation",
        OPTIONS_CRAFTING_TAB = "Crafting",
        OPTIONS_TSM_TAB = "TSM",
        OPTIONS_TSM_SECTION_TOOLTIP = "TradeSkillMaster price strings and CraftSim TSM-enhanced options.",
        OPTIONS_TSM_EXPRESSIONS_HEADER = "Price & restock expressions",
        OPTIONS_TSM_ENHANCED_HEADER = "TSM Enhanced",
        OPTIONS_TSM_RESET = "Reset Default",
        OPTIONS_TSM_INVALID_EXPRESSION = "Expression Invalid",
        OPTIONS_TSM_VALID_EXPRESSION = "Expression Valid",
        OPTIONS_TSM_DEPOSIT_ENABLED_LABEL = "Enable Expected Deposit Cost",
        OPTIONS_TSM_DEPOSIT_ENABLED_TOOLTIP =
        "Subtract the expected AH deposit cost from profit calculations.\nUses TSM price data to estimate the deposit you will pay when listing.",
        OPTIONS_TSM_DEPOSIT_EXPRESSION_LABEL = "TSM Deposit Expression",
        OPTIONS_TSM_SMART_RESTOCK_ENABLED_LABEL = "Smart Restock (subtract inventory)",
        OPTIONS_TSM_SMART_RESTOCK_ENABLED_TOOLTIP =
        "When sending recipes to the Craft Queue, subtract items you already own\n(bags, bank, alts, warbank) from the restock amount.",
        OPTIONS_TSM_SMART_RESTOCK_INCLUDE_ALTS_LABEL = "Include alt characters",
        OPTIONS_TSM_SMART_RESTOCK_INCLUDE_WARBANK_LABEL = "Include warbank",
        OPTIONS_MODULES_REAGENT_OPTIMIZATION = "Reagent Optimizing Module",
        OPTIONS_MODULES_AVERAGE_PROFIT = "Average Profit Module",
        OPTIONS_MODULES_TOP_GEAR = "Top Gear Module",
        OPTIONS_MODULES_COST_OVERVIEW = "Cost Overview Module",
        OPTIONS_MODULES_SPECIALIZATION_INFO = "Specialization Info Module",
        OPTIONS_MODULES_CUSTOMER_HISTORY_SIZE = "Customer History max messages per client",
        OPTIONS_MODULES_CUSTOMER_HISTORY_MAX_ENTRIES_PER_CLIENT = "Max history entries per client",
        OPTIONS_PROFIT_CALCULATION_OFFSET = "Offset Skill Breakpoints by 1",
        OPTIONS_PROFIT_CALCULATION_OFFSET_TOOLTIP =
        "The reagent combination suggestion will try to reach the breakpoint + 1 instead of matching the exact skill required",
        OPTIONS_PROFIT_CALCULATION_MULTICRAFT_CONSTANT = "Multicraft Constant",
        OPTIONS_PROFIT_CALCULATION_MULTICRAFT_CONSTANT_EXPLANATION =
        "Default: 2.5\n\nCrafting Data from different data collecting players in beta and early Dragonflight suggest that\nthe maximum extra items one can receive from a multicraft proc is 1+C*y.\nWhere y is the base item amount for one craft and C is 2.5.\nHowever if you wish you can modify this value here.",
        OPTIONS_PROFIT_CALCULATION_RESOURCEFULNESS_CONSTANT = "Resourcefulness Constant",
        OPTIONS_PROFIT_CALCULATION_RESOURCEFULNESS_CONSTANT_EXPLANATION =
        "Default: 0.3\n\nCrafting Data from different data collecting players in beta and early Dragonflight suggest that\nthe average amount of items saved is 30% of the required quantity.\nHowever if you wish you can modify this value here.",
        OPTIONS_GENERAL_SHOW_NEWS_CHECKBOX = "Show " .. f.bb("News") .. " Popup",
        OPTIONS_GENERAL_SHOW_NEWS_CHECKBOX_TOOLTIP = "Show the " ..
            f.bb("News") .. " Popup for new " .. f.l("CraftSim") .. " Update Information when logging into the game",
        OPTIONS_GENERAL_HIDE_MINIMAP_BUTTON_CHECKBOX = "Hide Minimap Button",
        OPTIONS_GENERAL_HIDE_MINIMAP_BUTTON_TOOLTIP = "Enable to hide the " ..
            f.l("CraftSim") .. " Minimap Button",
        OPTIONS_GENERAL_COIN_MONEY_FORMAT_CHECKBOX = "Use Coin Textures: ",
        OPTIONS_GENERAL_COIN_MONEY_FORMAT_TOOLTIP = "Use coin icons to format money",
        OPTIONS_SETTINGS_COIN_TEXTURES_LABEL = "Use coin textures for money",
        OPTIONS_TOOLTIP_TAB = "Tooltip",
        OPTIONS_TOOLTIP_SHOW_REGISTERED_CRAFTERS = "Show registered crafters on item tooltips",
        OPTIONS_TOOLTIP_SHOW_REGISTERED_CRAFTERS_HELP =
        "When enabled, item tooltips list CraftSim characters who have this recipe cached (and any with last crafting cost data for that item).",
        OPTIONS_TOOLTIP_REGISTERED_CRAFTERS_MAX = "Max crafters shown",
        OPTIONS_TOOLTIP_REGISTERED_CRAFTERS_MAX_SUBLABEL =
        "Additional crafters are summarized with a count after the listed names.",

        -- Control Panel
        CONTROL_PANEL_MODULES_CRAFT_QUEUE_LABEL = "Craft Queue",
        CONTROL_PANEL_MODULES_CRAFT_QUEUE_TOOLTIP = "Queue your recipes and craft them all on one place!",
        CONTROL_PANEL_MODULES_TOP_GEAR_LABEL = "Top Gear",
        CONTROL_PANEL_MODULES_TOP_GEAR_TOOLTIP =
        "Shows the best available profession gear combination based on the selected mode",
        CONTROL_PANEL_MODULES_COST_OVERVIEW_LABEL = "Price Details",
        CONTROL_PANEL_MODULES_COST_OVERVIEW_TOOLTIP = "Shows a sell price and profit overview by resulting item quality",
        CONTROL_PANEL_MODULES_AVERAGE_PROFIT_LABEL = "Average Profit",
        CONTROL_PANEL_MODULES_AVERAGE_PROFIT_TOOLTIP =
        "Shows the average profit based on your profession stats and the profit stat weights as gold per point.",
        CONTROL_PANEL_MODULES_REAGENT_OPTIMIZATION_LABEL = "Reagent Optimization",
        CONTROL_PANEL_MODULES_REAGENT_OPTIMIZATION_TOOLTIP =
        "Suggests the cheapest reagents to reach the specific quality thresholds.",
        CONTROL_PANEL_MODULES_PRICE_OVERRIDES_LABEL = "Price Overrides",
        CONTROL_PANEL_MODULES_PRICE_OVERRIDES_TOOLTIP =
        "Override prices of any reagents, and craft results for all recipes or for one recipe specifically.",
        CONTROL_PANEL_MODULES_SPECIALIZATION_INFO_LABEL = "Specialization Info",
        CONTROL_PANEL_MODULES_SPECIALIZATION_INFO_TOOLTIP =
        "Shows how your profession specializations affect this recipe and makes it possible to simulate any configuration!",
        CONTROL_PANEL_MODULES_CRAFT_LOG_LABEL = "Craft Log",
        CONTROL_PANEL_MODULES_CRAFT_LOG_TOOLTIP = "Show a crafting log and statistics about your crafts!",
        CONTROL_PANEL_MODULES_COST_OPTIMIZATION_LABEL = "Pricing",
        CONTROL_PANEL_MODULES_COST_OPTIMIZATION_TOOLTIP =
        "Module that shows reagent pricing details and craft result overview",
        CONTROL_PANEL_MODULES_STATISTICS_LABEL = "Statistics",
        CONTROL_PANEL_MODULES_STATISTICS_TOOLTIP =
        "Module that shows detailed outcome statistics for the currently open recipe",
        CONTROL_PANEL_MODULES_RECIPE_SCAN_LABEL = "Recipe Scan",
        CONTROL_PANEL_MODULES_RECIPE_SCAN_TOOLTIP = "Module that scans your recipe list based on various options",
        CONTROL_PANEL_MODULES_CUSTOMER_HISTORY_LABEL = "Customer History",
        CONTROL_PANEL_MODULES_CUSTOMER_HISTORY_TOOLTIP =
        "Module that provides a history of conversations with customers, crafted items and commissions",
        CONTROL_PANEL_MODULES_CRAFT_BUFFS_LABEL = "Craft Buffs",
        CONTROL_PANEL_MODULES_CRAFT_BUFFS_TOOLTIP = "Module that shows you your active and missing Craft Buffs",
        CONTROL_PANEL_MODULES_EXPLANATIONS_LABEL = "Explanations",
        CONTROL_PANEL_MODULES_EXPLANATIONS_TOOLTIP = "Module that shows you various explanations of how" ..
            f.l(" CraftSim") .. " calculates things",
        CONTROL_PANEL_RESET_FRAMES = "Reset Frame Positions",
        CONTROL_PANEL_OPTIONS = "Options",
        CONTROL_PANEL_NEWS = "News",
        CONTROL_PANEL_EXPORTS = "Exports",
        CONTROL_PANEL_EASYCRAFT_EXPORT = f.l("Easycraft") .. " Export",
        CONTROL_PANEL_EASYCRAFT_EXPORTING = "Exporting",
        CONTROL_PANEL_EASYCRAFT_EXPORT_NO_RECIPE_FOUND = "No recipe to export for The War Within expansion",
        CONTROL_PANEL_FORGEFINDER_EXPORT = f.l("ForgeFinder") .. " Export",
        CONTROL_PANEL_FORGEFINDER_EXPORTING = "Exporting",
        CONTROL_PANEL_EXPORT_EXPLANATION = f.l("wowforgefinder.com") ..
            " and " .. f.l("easycraft.io") ..
            "\nare websites to search and offer " .. f.bb("WoW Crafting Orders"),
        CONTROL_PANEL_DEBUG = "Debug",
        CONTROL_PANEL_TITLE = "Control Panel",
        CONTROL_PANEL_SUPPORTERS_BUTTON = f.patreon("Supporters"),

        -- Supporters
        SUPPORTERS_DESCRIPTION = f.l("Thank you to all those awesome people!"),
        SUPPORTERS_DESCRIPTION_2 = f.l(
            "Do you want to support CraftSim and also be listed here with your message?\nConsider joining the Community!"),
        SUPPORTERS_DATE = "Date",
        SUPPORTERS_SUPPORTER = "Supporter",
        SUPPORTERS_MESSAGE = "Message",

        -- Customer History
        CUSTOMER_HISTORY_TITLE = "CraftSim Customer History",
        CUSTOMER_HISTORY_DROPDOWN_LABEL = "Choose a customer",
        CUSTOMER_HISTORY_TOTAL_TIP = "Total tip: ",
        CUSTOMER_HISTORY_FROM = "From",
        CUSTOMER_HISTORY_TO = "To",
        CUSTOMER_HISTORY_FOR = "For",
        CUSTOMER_HISTORY_CRAFT_FORMAT = "Crafted %s for %s",
        CUSTOMER_HISTORY_DELETE_BUTTON = "Remove customer",
        CUSTOMER_HISTORY_WHISPER_BUTTON_LABEL = "Whisper..",
        CUSTOMER_HISTORY_PURGE_NO_TIP_LABEL = "Remove 0 Tip Customers",
        CUSTOMER_HISTORY_PURGE_ZERO_TIPS_CONFIRMATION_POPUP =
        "Are you sure you want to delete all data\nfrom customers with 0 total tip?",
        CUSTOMER_HISTORY_DELETE_CUSTOMER_CONFIRMATION_POPUP = "Are you sure you want to delete\nall data for %s?",
        CUSTOMER_HISTORY_PURGE_DAYS_INPUT_LABEL = "Auto Remove Interval (Days)",
        CUSTOMER_HISTORY_PURGE_DAYS_INPUT_TOOLTIP =
        "CraftSim will automatically remove all customers below the configured tip when you login after X days of the last deletion.\nIf set to 0, CraftSim will never delete automatically.",
        CUSTOMER_HISTORY_CUSTOMER_HEADER = "Customer",
        CUSTOMER_HISTORY_TOTAL_TIP_HEADER = "Total Tip",
        CUSTOMER_HISTORY_CRAFT_HISTORY_DATE_HEADER = "Date",
        CUSTOMER_HISTORY_CRAFT_HISTORY_RESULT_HEADER = "Result",
        CUSTOMER_HISTORY_CRAFT_HISTORY_TIP_HEADER = "Tip",
        CUSTOMER_HISTORY_CRAFT_HISTORY_CUSTOMER_REAGENTS_HEADER = "Customer Reagents",
        CUSTOMER_HISTORY_CRAFT_HISTORY_CUSTOMER_NOTE_HEADER = "Note",
        CUSTOMER_HISTORY_CHAT_MESSAGE_TIMESTAMP = "Timestamp",
        CUSTOMER_HISTORY_CHAT_MESSAGE_SENDER = "Sender",
        CUSTOMER_HISTORY_CHAT_MESSAGE_MESSAGE = "Message",
        CUSTOMER_HISTORY_CHAT_MESSAGE_YOU = "[You]: ",
        CUSTOMER_HISTORY_CRAFT_LIST_TIMESTAMP = "Timestamp",
        CUSTOMER_HISTORY_CRAFT_LIST_RESULTLINK = "ResultLink",
        CUSTOMER_HISTORY_CRAFT_LIST_TIP = "Tip",
        CUSTOMER_HISTORY_CRAFT_LIST_REAGENTS = "Reagents",
        CUSTOMER_HISTORY_CRAFT_LIST_SOMENOTE = "SomeNote",
        CUSTOMER_HISTORY_TOTAL_AMOUNT = "Total amount",
        CUSTOMER_HISTORY_CATEGORY_ENABLE_HISTORY_RECORDING = f.bb("Enable ") .. f.gold("History Recording"),
        CUSTOMER_HISTORY_CATEGORY_RECORD_PATRON_ORDERS = "Record " .. f.bb("Patron Orders"),
        CUSTOMER_HISTORY_CATEGORY_REMOVE_CUSTOMERS = "Remove Customers",
        CUSTOMER_HISTORY_CATEGORY_AUTO_REMOVAL = "Auto Removal",
        CUSTOMER_HISTORY_CATEGORY_REMOVE_BELOW_THRESHOLD = f.l("Remove below Threshold"),
        CUSTOMER_HISTORY_CATEGORY_REMOVE_ALL_CUSTOMERS = f.r("Remove All Customers"),
        CUSTOMER_HISTORY_CATEGORY_REMOVE_ALL_CUSTOMER_DATA = f.r("Remove ALL Customer Data?"),
        CUSTOMER_HISTORY_CATEGORY_DELETE_CUSTOMER = "Delete Customer",

        -- Craft Queue
        CRAFT_QUEUE_TITLE = "CraftSim Craft Queue",
        CRAFT_QUEUE_CRAFT_AMOUNT_LEFT_HEADER = "Queued",
        CRAFT_QUEUE_CRAFT_PROFESSION_GEAR_HEADER = "Tools",
        CRAFT_QUEUE_CRAFTING_COSTS_HEADER = "Crafting Costs",
        CRAFT_QUEUE_CRAFT_BUTTON_ROW_LABEL = "Craft",
        CRAFT_QUEUE_CRAFT_BUTTON_ROW_LABEL_WRONG_GEAR = "Wrong Tools",
        CRAFT_QUEUE_CRAFT_BUTTON_ROW_LABEL_NO_REAGENTS = "No Reagents",
        CRAFT_QUEUE_ADD_OPEN_RECIPE_BUTTON_LABEL = "Queue Open Recipe",
        CRAFT_QUEUE_ADD_FIRST_CRAFTS_BUTTON_LABEL = "Queue First Crafts",
        CRAFT_QUEUE_ADD_WORK_ORDERS_BUTTON_LABEL = "Queue Work Orders",
        CRAFT_QUEUE_ADD_WORK_ORDERS_ALLOW_CONCENTRATION_CHECKBOX = "Allow " .. f.gold("Concentration"),
        CRAFT_QUEUE_ADD_WORK_ORDERS_ALLOW_CONCENTRATION_TOOLTIP = "If minimum quality cannot be reached, use " ..
            f.l("Concentration") .. " if possible",
        CRAFT_QUEUE_ADD_WORK_ORDERS_ONLY_PROFITABLE_CHECKBOX = "Only " .. f.g("Profitable"),
        CRAFT_QUEUE_ADD_WORK_ORDERS_ONLY_PROFITABLE_TOOLTIP = "Only queue work orders with expected positive profit",
        CRAFT_QUEUE_WORK_ORDER_TYPE_BUTTON = "Work Order Type",
        CRAFT_QUEUE_PATRON_ORDERS_BUTTON = "Patron Orders",
        CRAFT_QUEUE_GUILD_ORDERS_BUTTON = "Guild Orders",
        CRAFT_QUEUE_PERSONAL_ORDERS_BUTTON = "Personal Orders",
        CRAFT_QUEUE_PUBLIC_ORDERS_BUTTON = "Public Orders",
        CRAFT_QUEUE_PUBLIC_ORDERS_MAX_COUNT = f.b("Public Order") .. " Max Count: ",
        CRAFT_QUEUE_PUBLIC_ORDERS_MAX_COUNT_TOOLTIP =
            "Maximum number of public orders to queue, sorted by highest profit.\n\nSet to " ..
            f.bb("0") .. " to use your available claim slots.",
        CRAFT_QUEUE_GUILD_ORDERS_ALTS_ONLY_CHECKBOX = f.r("Only ") .. "Alt Characters",
        CRAFT_QUEUE_PATRON_ORDERS_FORCE_CONCENTRATION_CHECKBOX = f.r("Force ") .. f.gold("Concentration"),
        CRAFT_QUEUE_PATRON_ORDERS_FORCE_CONCENTRATION_TOOLTIP =
        "Force the use of concentration for all patron orders if possible",
        CRAFT_QUEUE_PATRON_ORDERS_SPARK_RECIPES_CHECKBOX = "Include " .. f.e("Spark") .. " Recipes",
        CRAFT_QUEUE_PATRON_ORDERS_SPARK_RECIPES_TOOLTIP = "Include Orders that use a Spark as Reagent",
        CRAFT_QUEUE_PATRON_ORDERS_ACUITY_CHECKBOX = "Include " .. f.bb("Acuity/Moxie") .. " Rewards",
        CRAFT_QUEUE_PATRON_ORDERS_ACUITY_TOOLTIP = "Include Orders with Acuity/Moxie Rewards",
        CRAFT_QUEUE_PATRON_ORDERS_POWER_RUNE_CHECKBOX = "Include " .. f.bb("Augment Rune") .. " Rewards",
        CRAFT_QUEUE_PATRON_ORDERS_POWER_RUNE_TOOLTIP = "Include Orders with Augment Rune Rewards",
        CRAFT_QUEUE_PATRON_ORDERS_KNOWLEDGE_POINTS_CHECKBOX = "Include " .. f.bb("Knowledge Point") .. " Rewards",
        CRAFT_QUEUE_PATRON_ORDERS_KNOWLEDGE_POINTS_TOOLTIP = "Include Orders with Knowledge Point Rewards",
        CRAFT_QUEUE_PATRON_ORDERS_KNOWLEDGE_POINTS_MAX_COST = f.bb("Knowledge Point") .. " Max Cost: ",
        CRAFT_QUEUE_PATRON_ORDERS_KNOWLEDGE_POINTS_MAX_COST_TOOLTIP =
        "Maximum allowed gold cost of 1 Knowledge Point\n\nFormat: ",
        CRAFT_QUEUE_PATRON_ORDERS_MAX_COST = f.bb("Patron Order") .. " Max Cost: ",
        CRAFT_QUEUE_PATRON_ORDERS_MAX_COST_TOOLTIP = "Maximum allowed gold cost of a patron order\n\nFormat: ",
        CRAFT_QUEUE_PATRON_ORDERS_REAGENT_BAG_VALUE = f.bb("Reagent Bag") .. " Value: ",
        CRAFT_QUEUE_PATRON_ORDERS_REAGENT_BAG_VALUE_TOOLTIP = "Value of the " ..
            f.bb("Reagent Bag Reward") .. " that will be added to your profit.\n\nFormat: ",
        CRAFT_QUEUE_PATRON_ORDERS_INCLUDE_MOXIE_IN_PROFIT_CHECKBOX = "Include " .. f.bb("Moxie") .. " in expected profit",
        CRAFT_QUEUE_PATRON_ORDERS_INCLUDE_MOXIE_IN_PROFIT_TOOLTIP = "When enabled, " ..
            f.bb("NPC (patron)") ..
            " order " ..
            f.bb("Moxie") ..
            " rewards and the first-craft moxie bonus are added to expected profit using your Moxie values below. When disabled, Moxie stays informational in tooltips only.",
        CRAFT_QUEUE_PATRON_ORDERS_MOXIE_VALUE_TOOLTIP = "How much you value one unit of this profession's " ..
            f.bb("Moxie") ..
            " reward. Shown in tooltips; also used in expected profit when " ..
            f.bb("Include Moxie in expected profit") ..
            " is enabled.\n\nFormat: ",
        CRAFT_QUEUE_PATRON_REWARD_VALUES_TITLE = "Moxie values",
        CRAFT_QUEUE_PATRON_REWARD_VALUES_MENU_BUTTON = "Set Moxie values",
        CRAFT_QUEUE_PATRON_REWARD_VALUES_INTRO = "Set how much you value one unit of each profession's " ..
            f.bb("Moxie") ..
            ". " ..
            "Always shown in tooltips; " ..
            f.bb("expected profit") ..
            " includes Moxie at these rates when " ..
            f.bb("Include Moxie in expected profit") ..
            " is enabled (otherwise gold-only: tips, commission, item rewards).",
        CRAFT_QUEUE_CLEAR_ALL_BUTTON_LABEL = "Clear All",
        CRAFT_QUEUE_RESTOCK_FAVORITES_SMART_CONCENTRATION_QUEUING = f.bb("Smart ") ..
            f.gold("Concentration") .. f.bb(" Queueing"),
        CRAFT_QUEUE_RESTOCK_FAVORITES_SMART_CONCENTRATION_QUEUING_TOOLTIP = "If enabled, " ..
            f.l("CraftSim") ..
            " first determines the " ..
            f.g("best valued concentration") ..
            " recipe. Then queues it for the maximum craftable amount.",
        CRAFT_QUEUE_RESTOCK_FAVORITES_OFFSET_CONCENTRATION_CRAFT_AMOUNT = "Offset " ..
            f.gold("Concentration") .. f.bb(" Queue Amount"),
        CRAFT_QUEUE_RESTOCK_FAVORITES_OFFSET_CONCENTRATION_CRAFT_AMOUNT_TOOLTIP =
            "If enabled, concentration crafts will be queued for the amount of expected crafts based on your " ..
            f.bb("Ingenuity"),
        CRAFT_QUEUE_RESTOCK_FAVORITES_QUEUE_MAIN_PROFESSIONS = "Queue " .. f.bb("Current Main Professions"),
        CRAFT_QUEUE_RESTOCK_FAVORITES_QUEUE_MAIN_PROFESSIONS_TOOLTIP =
        "If enabled, CraftSim will process both main professions of the current character at once",
        CRAFT_QUEUE_RESTOCK_FAVORITES_OFFSET_QUEUE_AMOUNT_LABEL = "Offset Queue Amount: ",
        CRAFT_QUEUE_RESTOCK_FAVORITES_OFFSET_QUEUE_AMOUNT_TOOLTIP =
        "Always add given amount to the number of queued crafts",
        CRAFT_QUEUE_RESTOCK_FAVORITES_AUTO_SHOPPING_LIST = "Automatically create a Shopping List after Scan",
        CRAFT_QUEUE_CRAFT_BUTTON_ROW_LABEL_WRONG_PROFESSION = "Wrong Profession",
        CRAFT_QUEUE_CRAFT_BUTTON_ROW_LABEL_ON_COOLDOWN = "On Cooldown",
        RECIPE_COOLDOWN_CHARGES_INLINE = "(%d/%d)",
        RECIPE_COOLDOWN_CHARGES_TOOLTIP = "Cooldown charges: %d / %d",
        CRAFT_QUEUE_CRAFT_BUTTON_ROW_LABEL_WRONG_CRAFTER = "Wrong Crafter",
        CRAFT_QUEUE_RECIPE_REQUIREMENTS_HEADER = "Status",
        CRAFT_QUEUE_RECIPE_REQUIREMENTS_TOOLTIP = "All Requirements need to be fulfilled in order to craft a recipe",
        CRAFT_QUEUE_STATUS_CANNOT_CRAFT_FALLBACK = "Cannot craft",
        CRAFT_QUEUE_RESULT_FIRST_CRAFT_TOOLTIP_TITLE = "First Craft",
        CRAFT_QUEUE_RESULT_FIRST_CRAFT_TOOLTIP =
            "Awards one profession Knowledge Point the first time you craft this recipe. Moxie value below is included in expected profit only for " ..
            f.bb("NPC (patron)") ..
            " orders when " ..
            f.bb("Include Moxie in expected profit") ..
            " is enabled.",
        CRAFT_QUEUE_FIRST_CRAFT_MOXIE_GOLD_TOOLTIP = "Also grants 10 profession moxie (Valued at %s)",
        CRAFT_QUEUE_MOXIE_GOLD_IN_TOOLTIP = " (Valued at %s)",
        CRAFT_QUEUE_CRAFT_NEXT_BUTTON_LABEL = "Craft Next",
        CRAFT_QUEUE_CRAFT_AVAILABLE_AMOUNT = "Max",
        CRAFT_QUEUE_SHATTER_MOTE_AUTOMATIC = "Automatic (cheapest)",
        CRAFT_QUEUE_SHATTER_MOTE_AUTOMATIC_OWNED = "Automatic (cheapest owned)",
        CRAFT_QUEUE_SHATTER_RIGHT_CLICK_HINT = "\nRight-click to choose mote.",
        CRAFTQUEUE_AUCTIONATOR_SHOPPING_LIST_BUTTON_LABEL = "Create Auctionator Shopping List",
        CRAFT_QUEUE_QUEUE_TAB_LABEL = "Craft Queue",
        CRAFT_QUEUE_FLASH_TASKBAR_OPTION_LABEL = "Flash Taskbar on " ..
            f.bb("CraftQueue") .. " craft finished",
        CRAFT_QUEUE_FLASH_TASKBAR_OPTION_TOOLTIP =
            "When your WoW Game is minimized and a recipe has finished crafting in the " .. f.bb("CraftQueue") ..
            "," .. f.l(" CraftSim") .. " will flash your Taskbar WoW Icon",
        CRAFT_QUEUE_RESTOCK_OPTIONS_TAB_LABEL = "Restock Options",
        CRAFT_QUEUE_RESTOCK_OPTIONS_TAB_TOOLTIP = "Configure the restock behaviour when importing from Recipe Scan",
        CRAFT_QUEUE_RESTOCK_OPTIONS_GENERAL_PROFIT_THRESHOLD_LABEL = "Profit Threshold:",
        CRAFT_QUEUE_RESTOCK_OPTIONS_SALE_RATE_INPUT_LABEL = "Sale Rate Threshold:",
        CRAFT_QUEUE_RESTOCK_OPTIONS_TSM_SALE_RATE_TOOLTIP = string.format(
            [[
Only available when %s is loaded!

It will be checked wether %s of an item's chosen qualities has a sale rate
greater or equal the configured sale rate threshold.
]], f.bb("TSM"), f.bb("any")),
        CRAFT_QUEUE_RESTOCK_OPTIONS_TSM_SALE_RATE_TOOLTIP_GENERAL = string.format(
            [[
Only available when %s is loaded!

It will be checked wether %s of an item's qualities has a sale rate
greater or equal the configured sale rate threshold.
]], f.bb("TSM"), f.bb("any")),
        CRAFT_QUEUE_RESTOCK_OPTIONS_AMOUNT_LABEL = "Restock Amount:",
        CRAFT_QUEUE_RESTOCK_OPTIONS_RESTOCK_TOOLTIP = "This is the " ..
            f.bb("amount of crafts") ..
            " that will be queued for that recipe.\n\nThe amount of items you have in your inventory and bank of the checked qualities will be subtracted from the restock amount upon restocking",
        CRAFT_QUEUE_RESTOCK_OPTIONS_ENABLE_RECIPE_LABEL = "Enable:",
        CRAFT_QUEUE_RESTOCK_OPTIONS_GENERAL_OPTIONS_LABEL = "General Options (All Recipes)",
        CRAFT_QUEUE_RESTOCK_OPTIONS_ENABLE_RECIPE_TOOLTIP =
        "If this is toggled off, the recipe will be restocked based on the general options above",
        CRAFT_QUEUE_TOTAL_PROFIT_LABEL = "Total Ø Profit:",
        CRAFT_QUEUE_TOTAL_CRAFTING_COSTS_LABEL = "Total Crafting Costs:",
        CRAFT_QUEUE_EDIT_RECIPE_TITLE = "Edit Recipe",
        CRAFT_QUEUE_EDIT_RECIPE_NAME_LABEL = "Recipe Name",
        CRAFT_QUEUE_EDIT_RECIPE_REAGENTS_SELECT_LABEL = "Select",
        CRAFT_QUEUE_EDIT_RECIPE_OPTIONAL_REAGENTS_LABEL = "Optional Reagents",
        CRAFT_QUEUE_EDIT_RECIPE_FINISHING_REAGENTS_LABEL = "Finishing Reagents",
        CRAFT_QUEUE_EDIT_RECIPE_SPARK_LABEL = "Required",
        CRAFT_QUEUE_EDIT_RECIPE_PROFESSION_GEAR_LABEL = "Profession Gear",
        CRAFT_QUEUE_EDIT_RECIPE_OPTIMIZE_PROFIT_BUTTON = "Optimize",
        CRAFT_QUEUE_EDIT_RECIPE_CRAFTING_COSTS_LABEL = "Crafting Costs: ",
        CRAFT_QUEUE_EDIT_RECIPE_AVERAGE_PROFIT_LABEL = "Average Profit: ",
        CRAFT_QUEUE_EDIT_RECIPE_RESULTS_LABEL = "Results",
        CRAFT_QUEUE_EDIT_RECIPE_CONCENTRATION_CHECKBOX = " Concentration",
        CRAFT_QUEUE_AUCTIONATOR_SHOPPING_LIST_PER_CHARACTER_CHECKBOX = "Per Character",
        CRAFT_QUEUE_AUCTIONATOR_SHOPPING_LIST_PER_CHARACTER_CHECKBOX_TOOLTIP = "Create an " ..
            f.bb("Auctionator Shopping List") .. " for each crafter character\ninstead of one shopping list for all",
        CRAFT_QUEUE_AUCTIONATOR_SHOPPING_LIST_TARGET_MODE_CHECKBOX = "Target Mode Only",
        CRAFT_QUEUE_AUCTIONATOR_SHOPPING_LIST_TARGET_MODE_CHECKBOX_TOOLTIP = "Create an " ..
            f.bb("Auctionator Shopping List") .. " for target mode recipes only",
        CRAFT_QUEUE_UNSAVED_CHANGES_TOOLTIP = f.white("Unsaved Queue Amount.\nPress Enter to Save"),
        CRAFT_QUEUE_STATUSBAR_LEARNED = f.white("Recipe Learned"),
        CRAFT_QUEUE_STATUSBAR_COOLDOWN = f.white("Not on Cooldown"),
        CRAFT_QUEUE_STATUSBAR_REAGENTS = f.white("Reagents Available"),
        CRAFT_QUEUE_STATUSBAR_GEAR = f.white("Profession Gear Equipped"),
        CRAFT_QUEUE_STATUSBAR_CRAFTER = f.white("Correct Crafter Character"),
        CRAFT_QUEUE_STATUSBAR_PROFESSION = f.white("Profession Open"),
        CRAFT_QUEUE_BUTTON_EDIT = "Edit",
        CRAFT_QUEUE_BUTTON_CRAFT = "Craft",
        CRAFT_QUEUE_BUTTON_CLAIM = "Claim",
        CRAFT_QUEUE_BUTTON_CLAIMED = "Claimed",
        CRAFT_QUEUE_BUTTON_NEXT = "Next: ",
        CRAFT_QUEUE_BUTTON_NOTHING_QUEUED = "Nothing Queued",
        CRAFT_QUEUE_BUTTON_ORDER = "Order",
        CRAFT_QUEUE_BUTTON_SUBMIT = "Submit",
        CRAFT_QUEUE_BUTTON_EQUIP_TOOLS = "Equip",
        CRAFT_QUEUE_BUTTON_SHATTER = "Shatter",
        CRAFT_QUEUE_STATUS_SHATTER_BUFF = "Shattering Essence buff not active",
        CRAFT_QUEUE_STATUS_SHATTER_AFTER_LOGIN = "Reshatter required after login",
        CRAFT_QUEUE_SHATTER_TOOLTIP_AFTER_LOGIN = shatter_post_login_tooltip,
        CRAFT_QUEUE_SHATTER_TOOLTIP_MISSING_BUFF = "\n\n" ..
            f.white("Cast Shatter to apply Shattering Essence."),
        CRAFT_QUEUE_SHATTER_TOOLTIP_STALE_AND_MISSING = "\n\n" ..
            f.white("Shattering Essence inactive. Cast Shatter to apply it and sync post-login stats."),
        CRAFT_QUEUE_IGNORE_ACUITY_RECIPES_CHECKBOX_LABEL = "Ignore Acuity Recipes",
        CRAFT_QUEUE_IGNORE_ACUITY_RECIPES_CHECKBOX_TOOLTIP = "Do not queue first crafts that use " ..
            f.bb("Artisan's Acuity") .. " for crafting",
        CRAFT_QUEUE_AMOUNT_TOOLTIP = "\n\nQueued Crafts: ",
        CRAFT_QUEUE_ORDER_CUSTOMER = "\n\nOrder Customer: ",
        CRAFT_QUEUE_ORDER_MINIMUM_QUALITY = "\nMinimum Quality: ",
        CRAFT_QUEUE_ORDER_REWARDS = "\nRewards:",
        CRAFT_QUEUE_RESTOCK_FAVORITES_OPTIONS_AUTO_SHOPPING_LIST =
        "If enabled, CraftSim will automatically create a shopping list after scanning.",
        CRAFT_QUEUE_IGNORE_SPARK_RECIPES_CHECKBOX_LABEL = "Ignore " .. f.e("Spark") .. " Recipes",
        CRAFT_QUEUE_IGNORE_SPARK_RECIPES_CHECKBOX_TOOLTIP = "Ignore recipes that require a spark reagent",
        CRAFT_QUEUE_MENU_AUTO_SHOW = f.g("Automatically Open ") .. "when a recipe is queued",
        CRAFT_QUEUE_MENU_INGENUITY_IGNORE = f.r("Ignore ") .. "Queue Amount Reduction on " .. f.gold("Ingenuity Procs"),
        CRAFT_QUEUE_MENU_DEQUEUE_CONCENTRATION = f.r("Remove ") .. "on full " .. f.gold("Concentration") .. " used",
        CRAFT_QUEUE_MENU_DEQUEUE_CONCENTRATION_TOOLTIP =
        "Autoremove a crafted recipe when remaining concentration does not allow further crafts.",
        CRAFT_QUEUE_MENU_MIDNIGHT_SHATTER_FORCE_BUFF = f.gold("Force ") ..
            f.bb("Shattering Essence") .. " buff for Midnight Enchanting",
        CRAFT_QUEUE_MENU_MIDNIGHT_SHATTER_FORCE_BUFF_TOOLTIP = "When enabled, CraftSim will require the " ..
            f.bb("Shattering Essence") .. " buff to be active before crafting Enchanting recipes.\n\n" ..
            "The Shatter button will be shown in the button sequence and the buff will be assumed active during optimization.\n\n" ..
            "When disabled, the Shatter step is skipped entirely and the buff is not factored into optimization.",
        CRAFT_QUEUE_MENU_TWW_ENCHANT_SHATTER_FORCE_BUFF = f.gold("Force ") ..
            f.bb("Shattering Essence") .. " buff for " ..
            CraftSim.GUTIL:ColorizeText("The War Within", CraftSim.GUTIL.COLORS.LEGENDARY) .. " Enchanting",
        CRAFT_QUEUE_MENU_TWW_ENCHANT_SHATTER_FORCE_BUFF_TOOLTIP = "When enabled, CraftSim will require the " ..
            f.bb("Shattering Essence") .. " buff to be active before crafting TWW Enchanting recipes.\n\n" ..
            "The Shatter button will be shown in the button sequence and the buff will be assumed active during optimization.\n\n" ..
            "When disabled, the Shatter step is skipped entirely and the buff is not factored into optimization.",
        CRAFT_QUEUE_MENU_EVERBURNING_IGNITION_FORCE_BUFF = f.gold("Force ") ..
            f.bb("Everburning Ignition") .. " buff for TWW Blacksmithing stats",
        CRAFT_QUEUE_MENU_EVERBURNING_IGNITION_FORCE_BUFF_TOOLTIP = "When enabled, CraftSim will assume " ..
            f.bb("Everburning Ignition") ..
            " is active during stat optimization when the buff is not detected on the player.\n\n" ..
            "This does not add a Shatter-style prerequisite row to the craft queue.",
        CRAFT_QUEUE_HELP = f.bb("Left Click") .. " .. Jump to Recipe\n" ..
            f.bb("Right Click") .. " .. Open Recipe Options\n" ..
            f.bb("Middle Click") .. " .. Remove Recipe from Queue",

        -- craft lists
        CRAFT_LISTS_TAB_LABEL = "Craft Lists",
        CRAFT_LISTS_QUEUE_BUTTON_LABEL = "Queue Craft Lists",
        CRAFT_LISTS_CREATE_BUTTON_LABEL = "Create",
        CRAFT_LISTS_DELETE_BUTTON_LABEL = f.r("Delete"),
        CRAFT_LISTS_RENAME_BUTTON_LABEL = "Rename",
        CRAFT_LISTS_ADD_RECIPE_BUTTON_LABEL = "Add Open Recipe",
        CRAFT_LISTS_REMOVE_RECIPE_BUTTON_LABEL = f.r("Remove"),
        CRAFT_LISTS_EXPORT_BUTTON_LABEL = "Export",
        CRAFT_LISTS_IMPORT_BUTTON_LABEL = "Import",
        CRAFT_LISTS_LIST_NAME_HEADER = "List Name",
        CRAFT_LISTS_LIST_TYPE_HEADER = "Scope",
        CRAFT_LISTS_RECIPE_NAME_HEADER = "Recipe",
        CRAFT_LISTS_GLOBAL_LABEL = f.bb("Global"),
        CRAFT_LISTS_CHARACTER_LABEL = f.g("Character"),
        CRAFT_LISTS_NEW_LIST_DEFAULT_NAME = "New List",
        CRAFT_LISTS_RENAME_POPUP_TITLE = "Rename Craft List",
        CRAFT_LISTS_CREATE_POPUP_TITLE = "Create Craft List",
        CRAFT_LISTS_EXPORT_POPUP_TITLE = "Export Craft List",
        CRAFT_LISTS_IMPORT_POPUP_TITLE = "Import Craft List",
        CRAFT_LISTS_OPTIONS_ENABLE_CONCENTRATION = CraftSim.GUTIL:IconToText(CraftSim.CONST.CONCENTRATION_ICON, 15, 15) ..
            f.gold(" Enable Concentration"),
        CRAFT_LISTS_OPTIONS_OPTIMIZE_CONCENTRATION = "Optimize " .. f.gold("Concentration"),
        CRAFT_LISTS_OPTIONS_SMART_CONCENTRATION = f.bb("Smart ") .. f.gold("Concentration") .. f.bb(" Queueing"),
        CRAFT_LISTS_OPTIONS_SMART_CONCENTRATION_TOOLTIP =
        "Queue recipes in order of most concentration value per point, spending all available concentration",
        CRAFT_LISTS_OPTIONS_OFFSET_CONCENTRATION = "Offset " .. f.gold("Concentration") .. f.bb(" Queue Amount"),
        CRAFT_LISTS_OPTIONS_OFFSET_CONCENTRATION_TOOLTIP =
            "If enabled, concentration crafts will be queued for the amount of expected crafts based on your " ..
            f.bb("Ingenuity"),
        CRAFT_LISTS_OPTIONS_OPTIMIZE_TOOLS = "Optimize Profession Tools",
        CRAFT_LISTS_OPTIONS_TOP_PROFIT_QUALITY = "Autoselect Top Profit Quality",
        CRAFT_LISTS_OPTIONS_OPTIMIZE_FINISHING = "Optimize Finishing Reagents",
        CRAFT_LISTS_OPTIONS_INCLUDE_SOULBOUND = "Include " .. f.e("Soulbound") .. f.bb(" Finishing Reagents"),
        CRAFT_LISTS_OPTIONS_REAGENT_ALLOCATION = "Reagent Allocation",
        CRAFT_LISTS_OPTIONS_REAGENT_ALLOCATION_OPTIMIZE_HIGHEST = "Highest Quality",
        CRAFT_LISTS_OPTIONS_REAGENT_ALLOCATION_OPTIMIZE_MOST_PROFITABLE = "Most Profitable Quality",
        CRAFT_LISTS_OPTIONS_REAGENT_ALLOCATION_TARGET_QUALITY = "Target Quality",
        CRAFT_LISTS_OPTIONS_ENABLE_UNLEARNED = "Enable " .. f.r("Unlearned") .. " Recipes",
        CRAFT_LISTS_OPTIONS_USE_TSM_RESTOCK = "Use " .. f.bb("TSM") .. " Restock Expression",
        CRAFT_LISTS_OPTIONS_TSM_EXPRESSION = "Expression:",
        CRAFT_LISTS_OPTIONS_USE_CURRENT_CHARACTER = "Craft with current character",
        CRAFT_LISTS_OPTIONS_FIXED_CRAFTER = "Fixed Crafter: ",
        CRAFT_LISTS_OPTIONS_RESTOCK_AMOUNT = "Restock Amount: ",
        CRAFT_LISTS_OPTIONS_OFFSET_QUEUE_AMOUNT = "Offset Queue Amount: ",
        CRAFT_LISTS_OPTIONS_OFFSET_QUEUE_AMOUNT_TOOLTIP = "Always add given amount to the number of queued crafts",
        CRAFT_LISTS_RESTOCK_SUBTRACT_OWNED_LABEL = "Subtract bags, bank & warbank for craft list restock",
        CRAFT_LISTS_RESTOCK_SUBTRACT_OWNED_TOOLTIP =
        "When enabled, craft list restock queues max(0, target - how many you already have).\n\nTurn off to always queue up to the target number regardless of inventory (for example, craft 20 even if you already have some).",
        CRAFT_LISTS_OPTIONS_AUTO_SHOPPING_LIST = "Automatically create Shopping List after Queue",
        CRAFT_LISTS_OPTIONS_UPDATE_LAST_CRAFTING_COST = "Update " .. f.bb("Last Crafting Cost") .. " DB",
        CRAFT_LISTS_OPTIONS_UPDATE_LAST_CRAFTING_COST_TOOLTIP = "If enabled, the " .. f.bb("Last Crafting Cost") ..
            " database is updated for each recipe when queuing craft lists.\n\nThis allows querying the last known average crafting cost per item via the CraftSim API.",
        CRAFT_LISTS_NO_LIST_SELECTED = f.grey("No list selected"),
        CRAFT_LISTS_SELECT_LIST_HINT = f.grey("Select a list to view recipes"),
        CRAFT_LISTS_RECIPE_RESTOCK_SET_MAX = "Restock: ",
        CRAFT_LISTS_RECIPE_RESTOCK_TAG = "Restock",
        CRAFT_LISTS_RECIPE_RESTOCK_POPUP_TITLE = "Restock target (0 = off)",
        CRAFT_LISTS_RECIPE_RESTOCK_POPUP_HINT = f.grey("0 disables restock for this recipe."),

        -- craft buffs

        CRAFT_BUFFS_TITLE = "CraftSim Craft Buffs",
        CRAFT_BUFFS_SIMULATE_BUTTON = "Simulate Buffs",
        CRAFT_BUFF_CHEFS_HAT_TOOLTIP = f.bb("Wrath of the Lich King Toy.") ..
            "\nRequires Northrend Cooking\nSets Crafting Speed to " .. f.g("0.5 seconds"),

        -- cooldowns module

        COOLDOWNS_TITLE = "CraftSim Cooldowns",
        CONTROL_PANEL_MODULES_COOLDOWNS_LABEL = "Cooldowns",
        CONTROL_PANEL_MODULES_COOLDOWNS_TOOLTIP = "Overview for your account's " ..
            f.bb("Profession Cooldowns"),
        COOLDOWNS_CRAFTER_HEADER = "Crafter",
        COOLDOWNS_RECIPE_HEADER = "Recipe",
        COOLDOWNS_CHARGES_HEADER = "Charges",
        COOLDOWNS_NEXT_HEADER = "Next Charge",
        COOLDOWNS_ALL_HEADER = "Charges Full",
        COOLDOWNS_TAB_OVERVIEW = "Overview",
        COOLDOWNS_TAB_BLACKLIST = "Blacklist",
        COOLDOWNS_TAB_OPTIONS = "Options",
        COOLDOWNS_EXPANSION_FILTER_BUTTON = "Expansion Filter",
        COOLDOWNS_RECIPE_LIST_TEXT_TOOLTIP = f.bb("\n\nRecipes sharing this Cooldown:\n"),
        COOLDOWNS_RECIPE_READY = f.g("Ready"),
        COOLDOWNS_ADD_TO_BLACKLIST = "Add to Blacklist",
        COOLDOWNS_BLACKLIST_RESTORE = "Remove from blacklist",

        -- concentration module

        CONCENTRATION_TRACKER_TITLE = "CraftSim Concentration",
        CONCENTRATION_TRACKER_LABEL_CRAFTER = "Crafter",
        CONCENTRATION_TRACKER_LABEL_CURRENT = "Current",
        CONCENTRATION_TRACKER_LABEL_MAX = "Max",
        CONCENTRATION_TRACKER_MAX = f.g("MAX"),
        CONCENTRATION_TRACKER_MAX_VALUE = "Max: ",
        CONCENTRATION_TRACKER_FULL = f.g("Concentration Full"),
        CONCENTRATION_TRACKER_SORT_MODE_CHARACTER = "Character",
        CONCENTRATION_TRACKER_SORT_MODE_CONCENTRATION = "Concentration",
        CONCENTRATION_TRACKER_SORT_MODE_PROFESSION = "Profession",
        CONCENTRATION_TRACKER_FORMAT_MODE_EUROPE_MAX_DATE = "European - Max Date",
        CONCENTRATION_TRACKER_FORMAT_MODE_AMERICA_MAX_DATE = "American - Max Date",
        CONCENTRATION_TRACKER_FORMAT_MODE_HOURS_LEFT = "Hours Left",
        CONCENTRATION_TRACKER_PIN_TOOLTIP = "Pin Overview",
        CONCENTRATION_TRACKER_LIST_TAB_LABEL = "List",
        CONCENTRATION_TRACKER_LIST_TAB_REMOVE_AND_BLACKLIST = "Remove and Blacklist",
        CONCENTRATION_TRACKER_OPTIONS_TAB_LABEL = "Options",
        CONCENTRATION_TRACKER_OPTIONS_TAB_CLEAR_BLACKLIST = "Clear Blacklist",
        CONCENTRATION_TRACKER_OPTIONS_TAB_SORT_MODE = "Sort Mode: ",
        CONCENTRATION_TRACKER_OPTIONS_TAB_TIME_FORMAT = "Time Format: ",

        -- static popups
        STATIC_POPUPS_YES = "Yes",
        STATIC_POPUPS_NO = "No",

        -- frames
        FRAMES_RESETTING = "resetting frameID: ",
        FRAMES_WHATS_NEW = "CraftSim What's New?",
        FRAMES_JOIN_DISCORD = "Join the Discord!",
        FRAMES_DONATE_KOFI = "Visit CraftSim on Kofi",
        FRAMES_NO_INFO = "No Info",

        -- node data
        NODE_DATA_RANK_TEXT = "Rank ",
        NODE_DATA_TOOLTIP = "\n\nTotal Stats from Talent:\n",
        SPECIALIZATION_INFO_TOOLTIP_LABEL = f.l("CraftSim") .. f.white(" Specialization Info:"),

        -- last crafting cost tooltip
        LAST_CRAFTING_COST_TOOLTIP_HEADER = f.l("CraftSim"),
        LAST_CRAFTING_COST_TOOLTIP_LABEL = f.white("Last Average Crafting Costs:"),
        LAST_CRAFTING_COST_TOOLTIP_CRAFTER = f.white("Crafter:"),
        LAST_CRAFTING_COST_TOOLTIP_UPDATED = f.white("Updated:"),
        REGISTERED_CRAFTERS_ITEM_TOOLTIP_LABEL = f.white("Registered crafters:"),
        REGISTERED_CRAFTERS_ITEM_TOOLTIP_MORE = "+%d more",

        -- columns
        SOURCE_COLUMN_AH = "AH",
        SOURCE_COLUMN_OVERRIDE = "OR",
        SOURCE_COLUMN_WO = "WO",

        -- disenchant
        DISENCHANT_TITLE = "CraftSim Disenchanting",
        DISENCHANT_BUTTON = "Disenchant Next",
        DISENCHANT_OPTIONS_MIN_ILVL = "Minimum Item Level: ",
        DISENCHANT_INFO_TOOLTIP = f.bb("MMB") ..
            f.white(" .. Blacklist Item for Session\n") ..
            f.bb("Shift + MMB") .. f.white(" .. Blacklist Item Permanently"),
    }
end
