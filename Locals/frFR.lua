---@class CraftSim
local CraftSim = select(2, ...)

CraftSim.LOCAL_FR = {}

function CraftSim.LOCAL_FR:GetData()
    local f = CraftSim.GUTIL:GetFormatter()
    local cm = function(i, s) return CraftSim.MEDIA:GetAsTextIcon(i, s) end
    return {
        -- REQUIRED:
        [CraftSim.CONST.TEXT.STAT_MULTICRAFT] = "Fabrication multiple",
        [CraftSim.CONST.TEXT.STAT_RESOURCEFULNESS] = "Ingéniosité",
        [CraftSim.CONST.TEXT.STAT_INGENUITY] = "Inventivité",
        [CraftSim.CONST.TEXT.STAT_CRAFTINGSPEED] = "Vitesse de fabrication",
        [CraftSim.CONST.TEXT.EQUIP_MATCH_STRING] = "Équipé :",
        [CraftSim.CONST.TEXT.ENCHANTED_MATCH_STRING] = "Enchanté :",

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

        -- professions

        [CraftSim.CONST.TEXT.PROFESSIONS_BLACKSMITHING] = "Forge",
        [CraftSim.CONST.TEXT.PROFESSIONS_LEATHERWORKING] = "Travail du cuir",
        [CraftSim.CONST.TEXT.PROFESSIONS_ALCHEMY] = "Alchimie",
        [CraftSim.CONST.TEXT.PROFESSIONS_HERBALISM] = "Herboristerie",
        [CraftSim.CONST.TEXT.PROFESSIONS_COOKING] = "Cuisine",
        [CraftSim.CONST.TEXT.PROFESSIONS_MINING] = "Minage",
        [CraftSim.CONST.TEXT.PROFESSIONS_TAILORING] = "Couture",
        [CraftSim.CONST.TEXT.PROFESSIONS_ENGINEERING] = "Ingénierie",
        [CraftSim.CONST.TEXT.PROFESSIONS_ENCHANTING] = "Enchantement",
        [CraftSim.CONST.TEXT.PROFESSIONS_FISHING] = "Pêche",
        [CraftSim.CONST.TEXT.PROFESSIONS_SKINNING] = "Dépeçage",
        [CraftSim.CONST.TEXT.PROFESSIONS_JEWELCRAFTING] = "Joaillerie",
        [CraftSim.CONST.TEXT.PROFESSIONS_INSCRIPTION] = "Calligraphie",

        -- Other Statnames

        [CraftSim.CONST.TEXT.STAT_SKILL] = "Compétence",
        [CraftSim.CONST.TEXT.STAT_MULTICRAFT_BONUS] = "Objets bonus multicraft",
        [CraftSim.CONST.TEXT.STAT_RESOURCEFULNESS_BONUS] = "Objets bonus Ingéniosité",
        [CraftSim.CONST.TEXT.STAT_CRAFTINGSPEED_BONUS] = "Vitesse d'artisanat",
        [CraftSim.CONST.TEXT.STAT_INGENUITY_BONUS] = "Concentration économisée",
        [CraftSim.CONST.TEXT.STAT_INGENUITY_LESS_CONCENTRATION] = "Moins de concentration utilisée",
        [CraftSim.CONST.TEXT.STAT_PHIAL_EXPERIMENTATION] = "Expérimentation des flacons",
        [CraftSim.CONST.TEXT.STAT_POTION_EXPERIMENTATION] = "Expérimentation des potions",

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
        [CraftSim.CONST.TEXT.SIMULATION_MODE_LABEL] = "Mode Simulation",
        [CraftSim.CONST.TEXT.SIMULATION_MODE_TITLE] = "CraftSim Mode Simulation",
        [CraftSim.CONST.TEXT.SIMULATION_MODE_TOOLTIP] =
        "Le Mode Simulation de Craftsim permet de jouer avec toutes les options sans aucune réstrictions",
        [CraftSim.CONST.TEXT.SIMULATION_MODE_OPTIONAL] = "Optionnel #",
        [CraftSim.CONST.TEXT.SIMULATION_MODE_FINISHING] = "Finition #",
        [CraftSim.CONST.TEXT.SIMULATION_MODE_QUALITY_BUTTON_TOOLTIP] = "Max matériaux de Qualité ",
        [CraftSim.CONST.TEXT.SIMULATION_MODE_CLEAR_BUTTON] = "Vider",
        [CraftSim.CONST.TEXT.SIMULATION_MODE_CONCENTRATION] = " Concentration",
        [CraftSim.CONST.TEXT.SIMULATION_MODE_CONCENTRATION_COST] = "Coût Concentration : ",

        -- Details Frame
        [CraftSim.CONST.TEXT.RECIPE_DIFFICULTY_LABEL] = "Difficulté: ",
        [CraftSim.CONST.TEXT.MULTICRAFT_LABEL] = "Multicraft: ",
        [CraftSim.CONST.TEXT.RESOURCEFULNESS_LABEL] = "Ingéniosité: ",
        [CraftSim.CONST.TEXT.RESOURCEFULNESS_BONUS_LABEL] = "Item Bonus Ingéniosité: ",
        [CraftSim.CONST.TEXT.CONCENTRATION_LABEL] = "Concentration: ",
        [CraftSim.CONST.TEXT.REAGENT_QUALITY_BONUS_LABEL] = "Bonus Qualité Matériaux: ",
        [CraftSim.CONST.TEXT.REAGENT_QUALITY_MAXIMUM_LABEL] = "Maximum Qualité Matériaux %: ",
        [CraftSim.CONST.TEXT.EXPECTED_QUALITY_LABEL] = "Qualité attendue: ",
        [CraftSim.CONST.TEXT.NEXT_QUALITY_LABEL] = "Qualité suivante: ",
        [CraftSim.CONST.TEXT.MISSING_SKILL_LABEL] = "Comp. Manquante: ",
        [CraftSim.CONST.TEXT.SKILL_LABEL] = "Compétence: ",
        [CraftSim.CONST.TEXT.MULTICRAFT_BONUS_LABEL] = "Item Bonus Multicraft : ",

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
        [CraftSim.CONST.TEXT.POPUP_NO_PRICE_SOURCE_SYSTEM] = "Aucune source de prix supporté disponible!",
        [CraftSim.CONST.TEXT.POPUP_NO_PRICE_SOURCE_TITLE] = "Avertissement de source de prix Craftsim",
        [CraftSim.CONST.TEXT.POPUP_NO_PRICE_SOURCE_WARNING] =
        "Aucune source de prix trouvée !\n\nVous devez installer au moins un\nde ces addons de sources de prix\npour utiliser le calcul de profit de CraftSim:\n\n\n",
        [CraftSim.CONST.TEXT.POPUP_NO_PRICE_SOURCE_WARNING_SUPPRESS] = "Ne plus montrer l'avertissement",
        [CraftSim.CONST.TEXT.POPUP_NO_PRICE_SOURCE_WARNING_ACCEPT] = "OK",

        -- Reagents Frame
        [CraftSim.CONST.TEXT.REAGENT_OPTIMIZATION_TITLE] = "Optimisation des matériaux CraftSim",
        [CraftSim.CONST.TEXT.REAGENTS_REACHABLE_QUALITY] = "Qualité atteignable: ",
        [CraftSim.CONST.TEXT.REAGENTS_MISSING] = "Matériaux manquants",
        [CraftSim.CONST.TEXT.REAGENTS_AVAILABLE] = "Matériaux disponibles",
        [CraftSim.CONST.TEXT.REAGENTS_CHEAPER] = "Matériaux moins cher",
        [CraftSim.CONST.TEXT.REAGENTS_BEST_COMBINATION] = "Meilleur combinaison assigné",
        [CraftSim.CONST.TEXT.REAGENTS_NO_COMBINATION] = "Aucune combinaison trouvée \npour augmenter la qualité",
        [CraftSim.CONST.TEXT.REAGENTS_ASSIGN] = "Assigner",
        [CraftSim.CONST.TEXT.REAGENTS_MAXIMUM_QUALITY] = "Qualité max: ",
        [CraftSim.CONST.TEXT.REAGENTS_AVERAGE_PROFIT_LABEL] = "Profit moyen: ",
        [CraftSim.CONST.TEXT.REAGENTS_AVERAGE_PROFIT_TOOLTIP] =
            f.bb("Le profit moyen par craft") .. " en utilisant " .. f.l("cette répartition de matériaux"),
        [CraftSim.CONST.TEXT.REAGENTS_OPTIMIZE_BEST_ASSIGNED] = "Meilleurs matériaux assignés",
        [CraftSim.CONST.TEXT.REAGENTS_CONCENTRATION_LABEL] = "Concentration: ",
        [CraftSim.CONST.TEXT.REAGENTS_OPTIMIZE_INFO] =
        "Shift + Clic gauche sur les chiffres pour mettre le lien de l'objet dans le chat",
        [CraftSim.CONST.TEXT.ADVANCED_OPTIMIZATION_BUTTON] = "Optimisation Avancée",
        [CraftSim.CONST.TEXT.REAGENTS_OPTIMIZE_TOOLTIP] =
            "(Réinitialise lors de l'édition)\nActive " ..
            f.gold("Valeur de Concentration") ..
            " et " .. f.bb("Optimisation des Composants de Finition") .. " Optimisation",

        -- Specialization Info Frame
        [CraftSim.CONST.TEXT.SPEC_INFO_TITLE] = "Info de spécialisation CraftSim",
        [CraftSim.CONST.TEXT.SPEC_INFO_SIMULATE_KNOWLEDGE_DISTRIBUTION] = "Simuler la distribution de connaissances",
        [CraftSim.CONST.TEXT.SPEC_INFO_NODE_TOOLTIP] = "Ces noeuds vous apportent ces stats pour cette recette:",
        [CraftSim.CONST.TEXT.SPEC_INFO_WORK_IN_PROGRESS] = "Specialization Info\nWork in Progress",

        -- Crafting Results Frame
        [CraftSim.CONST.TEXT.CRAFT_LOG_TITLE] = "Résultats de fabrication CraftSim",
        [CraftSim.CONST.TEXT.CRAFT_LOG_LOG] = "Craft Log",
        [CraftSim.CONST.TEXT.CRAFT_LOG_LOG_1] = "Profit: ",
        [CraftSim.CONST.TEXT.CRAFT_LOG_LOG_2] = "Inspiré!",
        [CraftSim.CONST.TEXT.CRAFT_LOG_LOG_3] = "Multicraft: ",
        [CraftSim.CONST.TEXT.CRAFT_LOG_LOG_4] = "Ressources économisées!: ",
        [CraftSim.CONST.TEXT.CRAFT_LOG_LOG_5] = "Chance: ",
        [CraftSim.CONST.TEXT.CRAFT_LOG_CRAFTED_ITEMS] = "Items fabriqués",
        [CraftSim.CONST.TEXT.CRAFT_LOG_SESSION_PROFIT] = "Profit Session",
        [CraftSim.CONST.TEXT.CRAFT_LOG_RESET_DATA] = "Reset Données",
        [CraftSim.CONST.TEXT.CRAFT_LOG_EXPORT_JSON] = "Export JSON",
        [CraftSim.CONST.TEXT.CRAFT_LOG_RECIPE_STATISTICS] = "Stats recette",
        [CraftSim.CONST.TEXT.CRAFT_LOG_NOTHING] = "Aucune fabrication!",
        [CraftSim.CONST.TEXT.CRAFT_LOG_CALCULATION_COMPARISON_NUM_CRAFTS_PREFIX] = "Crafts: ",
        [CraftSim.CONST.TEXT.CRAFT_LOG_STATISTICS_2] = "Profit Ø estimé: ",
        [CraftSim.CONST.TEXT.CRAFT_LOG_STATISTICS_3] = "Profit Ø réel: ",
        [CraftSim.CONST.TEXT.CRAFT_LOG_STATISTICS_4] = "Profit réel: ",
        [CraftSim.CONST.TEXT.CRAFT_LOG_STATISTICS_5] = "Procs - Réel / Attendu: ",
        [CraftSim.CONST.TEXT.CRAFT_LOG_STATISTICS_7] = "Multicraft: ",
        [CraftSim.CONST.TEXT.CRAFT_LOG_STATISTICS_8] = "- Ø Extra Items: ",
        [CraftSim.CONST.TEXT.CRAFT_LOG_STATISTICS_9] = "Procs Ingéniosité: ",
        [CraftSim.CONST.TEXT.CRAFT_LOG_CALCULATION_COMPARISON_NUM_CRAFTS_PREFIX0] = "- Ø coûts économisés: ",
        [CraftSim.CONST.TEXT.CRAFT_LOG_CALCULATION_COMPARISON_NUM_CRAFTS_PREFIX1] = "Profit: ",
        [CraftSim.CONST.TEXT.CRAFT_LOG_SAVED_REAGENTS] = "Mat. économisés",
        [CraftSim.CONST.TEXT.CRAFT_LOG_RESULT_ANALYSIS_TAB_DISTRIBUTION_LABEL] = "Distribution des Résultats",
        [CraftSim.CONST.TEXT.CRAFT_LOG_RESULT_ANALYSIS_TAB_DISTRIBUTION_HELP] =
        "Distribution relative des résultats des objets fabriqués.\n(Ignorant les quantités de Multicraft)",
        [CraftSim.CONST.TEXT.CRAFT_LOG_RESULT_ANALYSIS_TAB_MULTICRAFT] = "Multicraft",
        [CraftSim.CONST.TEXT.CRAFT_LOG_RESULT_ANALYSIS_TAB_RESOURCEFULNESS] = "Ingéniosité",
        [CraftSim.CONST.TEXT.CRAFT_LOG_RESULT_ANALYSIS_TAB_YIELD_DDISTRIBUTION] = "Distribution du Rendement",

        -- Stats Weight Frame
        [CraftSim.CONST.TEXT.STAT_WEIGHTS_TITLE] = "Profit Moyen CraftSim",
        [CraftSim.CONST.TEXT.EXPLANATIONS_TITLE] = "Explication du Profit Moyen CraftSim",
        [CraftSim.CONST.TEXT.STAT_WEIGHTS_SHOW_EXPLANATION_BUTTON] = "Afficher explications",
        [CraftSim.CONST.TEXT.STAT_WEIGHTS_HIDE_EXPLANATION_BUTTON] = "Cacher explications",
        [CraftSim.CONST.TEXT.STAT_WEIGHTS_SHOW_STATISTICS_BUTTON] = "Afficher Statistiques",
        [CraftSim.CONST.TEXT.STAT_WEIGHTS_HIDE_STATISTICS_BUTTON] = "Cacher Statistiques",
        [CraftSim.CONST.TEXT.STAT_WEIGHTS_PROFIT_CRAFT] = "Profit Ø / Craft: ",
        [CraftSim.CONST.TEXT.EXPLANATIONS_BASIC_PROFIT_TAB] = "Calcul du profit basique",

        -- Cost Details Frame
        [CraftSim.CONST.TEXT.COST_OPTIMIZATION_TITLE] = "Optimisation des coûts CraftSim",
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
            " will always be used if set. " .. f.bb("Crafting Costs") .. " will only be used if lower than " .. f.g("AH"),
        [CraftSim.CONST.TEXT.COST_OPTIMIZATION_CRAFTING_COSTS] = "Coût de craft: ",
        [CraftSim.CONST.TEXT.COST_OPTIMIZATION_ITEM_HEADER] = "Objet",
        [CraftSim.CONST.TEXT.COST_OPTIMIZATION_AH_PRICE_HEADER] = "Prix HV",
        [CraftSim.CONST.TEXT.COST_OPTIMIZATION_OVERRIDE_HEADER] = "Remplacement",
        [CraftSim.CONST.TEXT.COST_OPTIMIZATION_CRAFTING_HEADER] = "Artisanat",
        [CraftSim.CONST.TEXT.COST_OPTIMIZATION_USED_SOURCE] = "Source Utilisée",
        [CraftSim.CONST.TEXT.COST_OPTIMIZATION_REAGENT_COSTS_TAB] = "Coûts des Matériaux",
        [CraftSim.CONST.TEXT.COST_OPTIMIZATION_SUB_RECIPE_OPTIONS_TAB] = "Options de Sous-Recette",
        [CraftSim.CONST.TEXT.COST_OPTIMIZATION_SUB_RECIPE_OPTIMIZATION] = "Optimisation des Sous-recettes " ..
            f.bb("(experimental)"),
        [CraftSim.CONST.TEXT.COST_OPTIMIZATION_SUB_RECIPE_OPTIMIZATION_TOOLTIP] = "Si activé " ..
            f.l("CraftSim") .. " considers the " .. f.g("optimized crafting costs") ..
            " of your character and your alts\nif they are able to craft that item.\n\n" ..
            f.r("Might decrease performance a bit due to a lot of additional calculations"),
        [CraftSim.CONST.TEXT.COST_OPTIMIZATION_SUB_RECIPE_MAX_DEPTH_LABEL] = "Profondeur de Calcul des Sous-recettes",
        [CraftSim.CONST.TEXT.COST_OPTIMIZATION_SUB_RECIPE_INCLUDE_CONCENTRATION] = "Activer la Concentration",
        [CraftSim.CONST.TEXT.COST_OPTIMIZATION_SUB_RECIPE_INCLUDE_CONCENTRATION_TOOLTIP] = "If enabled, " ..
            f.l("CraftSim") .. " will include reagent qualities even if concentration is necessary.",
        [CraftSim.CONST.TEXT.COST_OPTIMIZATION_SUB_RECIPE_INCLUDE_COOLDOWN_RECIPES] =
        "Inclure Recettes avec Temps de Recharge",
        [CraftSim.CONST.TEXT.COST_OPTIMIZATION_SUB_RECIPE_INCLUDE_COOLDOWN_RECIPES_TOOLTIP] = "If enabled, " ..
            f.l("CraftSim") .. " will ignore cooldown requirements of recipes when calculating self crafted reagents",
        [CraftSim.CONST.TEXT.COST_OPTIMIZATION_SUB_RECIPE_SELECT_RECIPE_CRAFTER] = "Sélectionner l'artisan de la recette",
        [CraftSim.CONST.TEXT.COST_OPTIMIZATION_REAGENT_LIST_AH_COLUMN_AUCTION_BUYOUT] = "Achat immédiat: ",
        [CraftSim.CONST.TEXT.COST_OPTIMIZATION_REAGENT_LIST_OVERRIDE] = "\n\nRemplacement",
        [CraftSim.CONST.TEXT.COST_OPTIMIZATION_REAGENT_LIST_EXPECTED_COSTS_TOOLTIP] = "\n\nArtisanat ",
        [CraftSim.CONST.TEXT.COST_OPTIMIZATION_REAGENT_LIST_EXPECTED_COSTS_PRE_ITEM] =
        "\n- Coûts Prévisionnels Par Article: ",
        [CraftSim.CONST.TEXT.COST_OPTIMIZATION_REAGENT_LIST_CONCENTRATION_COST] = f.gold("Coût Concentration: "),
        [CraftSim.CONST.TEXT.COST_OPTIMIZATION_REAGENT_LIST_CONCENTRATION] = "Concentration : ",

        -- Statistics Frame
        [CraftSim.CONST.TEXT.STATISTICS_TITLE] = "Statistiques CraftSim",
        [CraftSim.CONST.TEXT.STATISTICS_EXPECTED_PROFIT] = "Profit estimé (μ)",
        [CraftSim.CONST.TEXT.STATISTICS_CHANCE_OF] = "Chance de ",
        [CraftSim.CONST.TEXT.STATISTICS_PROFIT] = "Profit",
        [CraftSim.CONST.TEXT.STATISTICS_AFTER] = " après",
        [CraftSim.CONST.TEXT.STATISTICS_CRAFTS] = "Crafts: ",
        [CraftSim.CONST.TEXT.STATISTICS_QUALITY_HEADER] = "Qualité",
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
        [CraftSim.CONST.TEXT.COST_OVERVIEW_TITLE] = "Details des prix CraftSim",
        [CraftSim.CONST.TEXT.PRICE_DETAILS_INV_AH] = "Sac/HV",
        [CraftSim.CONST.TEXT.PRICE_DETAILS_ITEM] = "Item",
        [CraftSim.CONST.TEXT.PRICE_DETAILS_PRICE_ITEM] = "Prix/Item",
        [CraftSim.CONST.TEXT.PRICE_DETAILS_PROFIT_ITEM] = "Profit/Item",

        -- Price Override Frame
        [CraftSim.CONST.TEXT.PRICE_OVERRIDE_TITLE] = "Remplacement des prix CraftSim",
        [CraftSim.CONST.TEXT.PRICE_OVERRIDE_REQUIRED_REAGENTS] = "Composants Requis",
        [CraftSim.CONST.TEXT.PRICE_OVERRIDE_OPTIONAL_REAGENTS] = "Composants Optionnels",
        [CraftSim.CONST.TEXT.PRICE_OVERRIDE_FINISHING_REAGENTS] = "Composants de finitions",
        [CraftSim.CONST.TEXT.PRICE_OVERRIDE_RESULT_ITEMS] = "Résultat",
        [CraftSim.CONST.TEXT.PRICE_OVERRIDE_ACTIVE_OVERRIDES] = "Remplacement actifs",
        [CraftSim.CONST.TEXT.PRICE_OVERRIDE_ACTIVE_OVERRIDES_TOOLTIP] =
        "'(as result)' -> price override only considered when item is a result of a recipe",
        [CraftSim.CONST.TEXT.PRICE_OVERRIDE_CLEAR_ALL] = "Supprimer tout",
        [CraftSim.CONST.TEXT.PRICE_OVERRIDE_SAVE] = "Enregistrer",
        [CraftSim.CONST.TEXT.PRICE_OVERRIDE_SAVED] = "Enregistré",
        [CraftSim.CONST.TEXT.PRICE_OVERRIDE_REMOVE] = "Supprimer",

        -- Recipe Scan Frame
        [CraftSim.CONST.TEXT.RECIPE_SCAN_TITLE] = "Scan Recettes CraftSim",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_MODE] = "Mode de scan",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_SORT_MODE] = "Mode de tri",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_SCAN_RECIPIES] = "Scanner recettes",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_SCAN_CANCEL] = "Annuler",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_SCANNING] = "Scan...",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_INCLUDE_NOT_LEARNED] = "Inclure non apprises",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_INCLUDE_NOT_LEARNED_TOOLTIP] =
        "Inclu les recettes non connues dans le scan",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_INCLUDE_SOULBOUND] = "Inclure liés",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_INCLUDE_SOULBOUND_TOOLTIP] =
        "Include soulbound recipes in the recipe scan.\n\nIt is recommended to set a price override (e.g. to simulate a target comission)\nin the Price Override Module for that recipe's crafted items",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_INCLUDE_GEAR] = "Inclure l'équipement",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_INCLUDE_GEAR_TOOLTIP] = "Inclu toutes les formes d'équipements dans le scan",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_OPTIMIZE_TOOLS] = "Optimiser l'équipement de métier",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_OPTIMIZE_TOOLS_TOOLTIP] =
        "Optimise votre équipement de métier pour chaque recette\n\n",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_OPTIMIZE_TOOLS_WARNING] =
        "Ceci peut affecter les performances\nsi vous avez beaucoup d'équipements dans votre sac",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_CRAFTER_HEADER] = "Fabricant",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_RECIPE_HEADER] = "Recette",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_LEARNED_HEADER] = "Apprise",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_RESULT_HEADER] = "Resultat",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_AVERAGE_PROFIT_HEADER] = "Profit moyen",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_CONCENTRATION_VALUE_HEADER] = "C. Valeur",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_CONCENTRATION_COST_HEADER] = "C. Coût",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_TOP_GEAR_HEADER] = "Meilleur équipement",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_INV_AH_HEADER] = "Sac/HV",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_SORT_BY_MARGIN] = "Tri %Profit",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_SORT_BY_MARGIN_TOOLTIP] =
        "Tri la liste en fonction du profit relatif\nau coût de fabrication(Nouv. Scan requis)",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_USE_INSIGHT_CHECKBOX] = "Utiliser " .. f.bb("Clairvoyance") .. " si possible",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_USE_INSIGHT_CHECKBOX_TOOLTIP] = "Utiliser " ..
            f.bb("Clairvoyance illustre") ..
            " ou\n" .. f.bb("Clairvoyance illustre inférieure") .. " en composants optionnels si possible",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_ONLY_FAVORITES_CHECKBOX] = "Favoris uniquements",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_ONLY_FAVORITES_CHECKBOX_TOOLTIP] = "Scan uniquement les recettes favorites",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_EQUIPPED] = "Equipé",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_MODE_OPTIMIZE] = "Optimiser Matériaux",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_SORT_MODE_PROFIT] = "Profit",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_SORT_MODE_RELATIVE_PROFIT] = "Profit Relatif",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_SORT_MODE_CONCENTRATION_VALUE] = "Valeur Concentration",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_SORT_MODE_CONCENTRATION_COST] = "Coût Concentration",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_SORT_MODE_CRAFTING_COST] = "Coût Artisanat",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_EXPANSION_FILTER_BUTTON] = "Extensions",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_ALTPROFESSIONS_FILTER_BUTTON] = "Alt Professions",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_SCAN_ALL_BUTTON_READY] = "Scan Professions",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_SCAN_ALL_BUTTON_SCANNING] = "Scan...",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_TAB_LABEL_SCAN] = "Scan Recettes",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_TAB_LABEL_OPTIONS] = "Options de Scan",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_IMPORT_ALL_PROFESSIONS_CHECKBOX_LABEL] = "Toutes professions scannées",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_IMPORT_ALL_PROFESSIONS_CHECKBOX_TOOLTIP] = f.g("Coché: ") ..
            "Importe le résultat du scan de toutes les professions séléctionnées\n\n" ..
            f.r("Décoché: ") .. "Importe le résultat du scan de la profession actuellement séléctionnée",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_CACHED_RECIPES_TOOLTIP] =
            "Chaque fois que vous ouvrez ou scannez une recette sur un personnage, " ..
            f.l("CraftSim") ..
            " la retient.\n\nUniquement les recettes alts que " ..
            f.l("CraftSim") .. " connaît peuvent être scannée avec le" .. f.bb("Scan Recettes\n\n") ..
            "Le montant actuel des recettes scannées est basé sur vos " .. f.e("Options de Scan"),
        [CraftSim.CONST.TEXT.RECIPE_SCAN_CONCENTRATION_TOGGLE] = " Concentration",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_CONCENTRATION_TOGGLE_TOOLTIP] = "Activer/Désactiver la Concentration",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_OPTIMIZE_SUBRECIPES] = "Optimiser les Sous-recettes " .. f.bb("(expérimental)"),
        [CraftSim.CONST.TEXT.RECIPE_SCAN_OPTIMIZE_SUBRECIPES_TOOLTIP] = "Si activé, " ..
            f.l("CraftSim") ..
            " optimise également les crafts des recettes de composants mises en cache des recettes scannées et utilise leurs\n" ..
            f.bb("coûts prévus") .. " pour calculer les coûts de fabrication du produit final.\n\n" ..
            f.r("Avertissement : Cela peut réduire les performances de scan"),
        [CraftSim.CONST.TEXT.RECIPE_SCAN_CACHED_RECIPES] = "Recettes mémorisées: ",

        -- Recipe Top Gear
        [CraftSim.CONST.TEXT.TOP_GEAR_TITLE] = "Meilleur Equipement CraftSim",
        [CraftSim.CONST.TEXT.TOP_GEAR_AUTOMATIC] = "Automatique",
        [CraftSim.CONST.TEXT.TOP_GEAR_AUTOMATIC_TOOLTIP] =
        "Simule automatiquement votre équipement pour le mode choisi a chaque fois que vous selectionnez une recette.\n\nDésactiver cette option améliore les performances.",
        [CraftSim.CONST.TEXT.TOP_GEAR_SIMULATE] = "Simuler meilleur équipement",
        [CraftSim.CONST.TEXT.TOP_GEAR_EQUIP] = "Equiper",
        [CraftSim.CONST.TEXT.TOP_GEAR_SIMULATE_QUALITY] = "Qualité: ",
        [CraftSim.CONST.TEXT.TOP_GEAR_SIMULATE_EQUIPPED] = "Meilleur stuff equipé",
        [CraftSim.CONST.TEXT.TOP_GEAR_SIMULATE_PROFIT_DIFFERENCE] = "Difference de Profit Ø \n",
        [CraftSim.CONST.TEXT.TOP_GEAR_SIMULATE_NEW_MUTLICRAFT] = "Nouv. Multicraft\n",
        [CraftSim.CONST.TEXT.TOP_GEAR_SIMULATE_NEW_CRAFTING_SPEED] = "Nouv. Vitesse Fabrication\n",
        [CraftSim.CONST.TEXT.TOP_GEAR_SIMULATE_NEW_RESOURCEFULNESS] = "Nouv. Ingéniosité\n",
        [CraftSim.CONST.TEXT.TOP_GEAR_SIMULATE_NEW_SKILL] = "Nouv. Compétence\n",
        [CraftSim.CONST.TEXT.TOP_GEAR_SIMULATE_UNHANDLED] = "Mode Sim. non géré",

        [CraftSim.CONST.TEXT.TOP_GEAR_SIM_MODES_PROFIT] = "Top Profit",
        [CraftSim.CONST.TEXT.TOP_GEAR_SIM_MODES_SKILL] = "Top Compétence",
        [CraftSim.CONST.TEXT.TOP_GEAR_SIM_MODES_MULTICRAFT] = "Top Multicraft",
        [CraftSim.CONST.TEXT.TOP_GEAR_SIM_MODES_RESOURCEFULNESS] = "Top Ingéniosité",
        [CraftSim.CONST.TEXT.TOP_GEAR_SIM_MODES_CRAFTING_SPEED] = "Top Vitesse Fabrication",

        -- Options
        [CraftSim.CONST.TEXT.OPTIONS_TITLE] = "Options CraftSim",
        [CraftSim.CONST.TEXT.OPTIONS_GENERAL_TAB] = "General",
        [CraftSim.CONST.TEXT.OPTIONS_GENERAL_PRICE_SOURCE] = "Source de Prix",
        [CraftSim.CONST.TEXT.OPTIONS_GENERAL_CURRENT_PRICE_SOURCE] = "Source de prix actuelle: ",
        [CraftSim.CONST.TEXT.OPTIONS_GENERAL_NO_PRICE_SOURCE] = "Pas d'addon de source de prix chargé!",
        [CraftSim.CONST.TEXT.OPTIONS_GENERAL_SHOW_PROFIT] = "Afficher le % Profit",
        [CraftSim.CONST.TEXT.OPTIONS_GENERAL_SHOW_PROFIT_TOOLTIP] =
        "Afficher le pourcentage de profit par rapport aux coûts d'artisanat en plus de la valeur de l'or",
        [CraftSim.CONST.TEXT.OPTIONS_GENERAL_REMEMBER_LAST_RECIPE] = "Retenir dernière recette",
        [CraftSim.CONST.TEXT.OPTIONS_GENERAL_REMEMBER_LAST_RECIPE_TOOLTIP] =
        "Réouverture de la dernière recette sélectionnée lors de l'ouverture de la fenêtre d'artisanat",
        [CraftSim.CONST.TEXT.OPTIONS_GENERAL_SUPPORTED_PRICE_SOURCES] = "Source de prix supportées:",
        [CraftSim.CONST.TEXT.OPTIONS_PERFORMANCE_RAM] = "Activer le nettoyage de la RAM pendant la fabrication",
        [CraftSim.CONST.TEXT.OPTIONS_PERFORMANCE_RAM_CRAFTS] = "Crafts",
        [CraftSim.CONST.TEXT.OPTIONS_PERFORMANCE_RAM_TOOLTIP] =
        "Lorsque cette option est activée, CraftSim nettoie votre RAM après un certain nombres de crafts spécifiés afin d'empêcher l'accumulation de mémoire.\nL'accumulation de mémoire peut également se produire à cause d'autres addons et n'est pas spécifique à CraftSim.",
        [CraftSim.CONST.TEXT.OPTIONS_MODULES_TAB] = "Modules",
        [CraftSim.CONST.TEXT.OPTIONS_PROFIT_CALCULATION_TAB] = "Calcul du profit",
        [CraftSim.CONST.TEXT.OPTIONS_CRAFTING_TAB] = "Artisanat",
        [CraftSim.CONST.TEXT.OPTIONS_TSM_RESET] = "Paramètres par défaut",
        [CraftSim.CONST.TEXT.OPTIONS_TSM_INVALID_EXPRESSION] = "Expression Invalide",
        [CraftSim.CONST.TEXT.OPTIONS_TSM_VALID_EXPRESSION] = "Expression Valide",
        [CraftSim.CONST.TEXT.OPTIONS_MODULES_REAGENT_OPTIMIZATION] = "Module Optimisation Matériaux",
        [CraftSim.CONST.TEXT.OPTIONS_MODULES_AVERAGE_PROFIT] = "Module Profit Moyen",
        [CraftSim.CONST.TEXT.OPTIONS_MODULES_TOP_GEAR] = "Module Top Equipement",
        [CraftSim.CONST.TEXT.OPTIONS_MODULES_COST_OVERVIEW] = "Module Vue Coût détaillé",
        [CraftSim.CONST.TEXT.OPTIONS_MODULES_SPECIALIZATION_INFO] = "Module Info. Spécialisation",
        [CraftSim.CONST.TEXT.OPTIONS_MODULES_CUSTOMER_HISTORY_SIZE] = "Max message en historique par client",
        [CraftSim.CONST.TEXT.OPTIONS_MODULES_CUSTOMER_HISTORY_MAX_ENTRIES_PER_CLIENT] = "Max history entries per client",
        [CraftSim.CONST.TEXT.OPTIONS_PROFIT_CALCULATION_OFFSET] = "Décalage de 1 point de compétence",
        [CraftSim.CONST.TEXT.OPTIONS_PROFIT_CALCULATION_OFFSET_TOOLTIP] =
        "La proposition de combinaison de matériaux tentera d'atteindre +1 au lieu de correspondre à la compétence exacte requise.",
        [CraftSim.CONST.TEXT.OPTIONS_PROFIT_CALCULATION_MULTICRAFT_CONSTANT] = "Constante Multicraft",
        [CraftSim.CONST.TEXT.OPTIONS_PROFIT_CALCULATION_MULTICRAFT_CONSTANT_EXPLANATION] =
        "Default: 2.5\n\nCrafting Data from different data collecting players in beta and early Dragonflight suggest that\nthe maximum extra items one can receive from a multicraft proc is 1+C*y.\nWhere y is the base item amount for one craft and C is 2.5.\nHowever if you wish you can modify this value here.",
        [CraftSim.CONST.TEXT.OPTIONS_PROFIT_CALCULATION_RESOURCEFULNESS_CONSTANT] = "Constante Ingéniosité",
        [CraftSim.CONST.TEXT.OPTIONS_PROFIT_CALCULATION_RESOURCEFULNESS_CONSTANT_EXPLANATION] =
        "Default: 0.3\n\nCrafting Data from different data collecting players in beta and early Dragonflight suggest that\nthe average amount of items saved is 30% of the required quantity.\nHowever if you wish you can modify this value here.",
        [CraftSim.CONST.TEXT.OPTIONS_GENERAL_SHOW_NEWS_CHECKBOX] = "Afficher la popup des " .. f.bb("News"),
        [CraftSim.CONST.TEXT.OPTIONS_GENERAL_SHOW_NEWS_CHECKBOX_TOOLTIP] = "Show the " ..
            f.bb("News") .. " Popup for new " .. f.l("CraftSim") .. " Update Information when logging into the game",
        [CraftSim.CONST.TEXT.OPTIONS_GENERAL_HIDE_MINIMAP_BUTTON_CHECKBOX] = "Cacher bouton minimap",
        [CraftSim.CONST.TEXT.OPTIONS_GENERAL_HIDE_MINIMAP_BUTTON_TOOLTIP] = "Enable to hide the " ..
            f.l("CraftSim") .. " Minimap Button",
        [CraftSim.CONST.TEXT.OPTIONS_GENERAL_COIN_MONEY_FORMAT_CHECKBOX] = "UTextures pièces: ",
        [CraftSim.CONST.TEXT.OPTIONS_GENERAL_COIN_MONEY_FORMAT_TOOLTIP] =
        "Utiliser des icônes de pièces pour formater l'argent",

        -- Control Panel
        [CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_CRAFT_QUEUE_LABEL] = "File d'attente",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_CRAFT_QUEUE_TOOLTIP] =
        "Queue your recipes and craft them all on one place!",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_TOP_GEAR_LABEL] = "Meilleur Equipement",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_TOP_GEAR_TOOLTIP] =
        "Shows the best available profession gear combination based on the selected mode",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_COST_OVERVIEW_LABEL] = "Details Prix",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_COST_OVERVIEW_TOOLTIP] =
        "Shows a sell price and profit overview by resulting item quality",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_AVERAGE_PROFIT_LABEL] = "Profit Moyen",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_AVERAGE_PROFIT_TOOLTIP] =
        "Shows the average profit based on your profession stats and the profit stat weights as gold per point.",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_REAGENT_OPTIMIZATION_LABEL] = "Optimisation Matériaux",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_REAGENT_OPTIMIZATION_TOOLTIP] =
        "Suggests the cheapest reagents to reach the specific quality thresholds.",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_PRICE_OVERRIDES_LABEL] = "Remplacement Prix",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_PRICE_OVERRIDES_TOOLTIP] =
        "Override prices of any reagents, and craft results for all recipes or for one recipe specifically.",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_SPECIALIZATION_INFO_LABEL] = "Info Specialisation",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_SPECIALIZATION_INFO_TOOLTIP] =
        "Shows how your profession specializations affect this recipe and makes it possible to simulate any configuration!",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_CRAFT_LOG_LABEL] = "Résultats Fabrication",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_CRAFT_LOG_TOOLTIP] =
        "Show a crafting log and statistics about your crafts!",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_COST_OPTIMIZATION_LABEL] = "Optimisation Coûts",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_COST_OPTIMIZATION_TOOLTIP] =
        "Module that shows detailed information about and helps with optimizing crafting costs",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_STATISTICS_LABEL] = "Stats",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_STATISTICS_TOOLTIP] =
        "Module that shows detailed outcome statistics for the currently open recipe",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_RECIPE_SCAN_LABEL] = "Scan Recette",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_RECIPE_SCAN_TOOLTIP] =
        "Module that scans your recipe list based on various options",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_CUSTOMER_HISTORY_LABEL] = "Historique Client",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_CUSTOMER_HISTORY_TOOLTIP] =
        "Module that provides a history of conversations with customers, crafted items and commissions",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_CRAFT_BUFFS_LABEL] = "Buffs Crafts",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_CRAFT_BUFFS_TOOLTIP] =
        "Module that shows you your active and missing Craft Buffs",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_EXPLANATIONS_LABEL] = "Explications",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_EXPLANATIONS_TOOLTIP] =
            "Module that shows you various explanations of how" .. f.l(" CraftSim") .. " calculates things",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_RESET_FRAMES] = "Réinit. Position fenêtres",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_OPTIONS] = "Options",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_NEWS] = "News",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_EASYCRAFT_EXPORT] = f.l("Easycraft") .. " Export",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_EASYCRAFT_EXPORTING] = "En cours...",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_EASYCRAFT_EXPORT_NO_RECIPE_FOUND] =
        "Aucune recette trouvée pour l'extension The War Within",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_FORGEFINDER_EXPORT] = f.l("ForgeFinder") .. " Export",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_FORGEFINDER_EXPORTING] = "Exporting",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_EXPORT_EXPLANATION] = f.l("wowforgefinder.com") ..
            " and " .. f.l("easycraft.io") ..
            "\nsont des platformes permettant de chercher et publier des " .. f.bb("commandes de craft"),
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
        [CraftSim.CONST.TEXT.CUSTOMER_HISTORY_TITLE] = "Historique Client CraftSim",
        [CraftSim.CONST.TEXT.CUSTOMER_HISTORY_DROPDOWN_LABEL] = "Choisir un client",
        [CraftSim.CONST.TEXT.CUSTOMER_HISTORY_TOTAL_TIP] = "Pourboire total: ",
        [CraftSim.CONST.TEXT.CUSTOMER_HISTORY_FROM] = "De",
        [CraftSim.CONST.TEXT.CUSTOMER_HISTORY_TO] = "À",
        [CraftSim.CONST.TEXT.CUSTOMER_HISTORY_FOR] = "Pour",
        [CraftSim.CONST.TEXT.CUSTOMER_HISTORY_CRAFT_FORMAT] = "Fabriqué %s pour %s",
        [CraftSim.CONST.TEXT.CUSTOMER_HISTORY_DELETE_BUTTON] = "Supprimer client",
        [CraftSim.CONST.TEXT.CUSTOMER_HISTORY_WHISPER_BUTTON_LABEL] = "Chuchoter..",
        [CraftSim.CONST.TEXT.CUSTOMER_HISTORY_PURGE_NO_TIP_LABEL] = "Supprimer clients sans pourboire",
        [CraftSim.CONST.TEXT.CUSTOMER_HISTORY_PURGE_ZERO_TIPS_CONFIRMATION_POPUP] =
        "Êtes-vous sûr de vouloir supprimer toutes les données\n des clients sans pourboire total?",
        [CraftSim.CONST.TEXT.CUSTOMER_HISTORY_DELETE_CUSTOMER_CONFIRMATION_POPUP] =
        "Êtes-vous sûr de vouloir supprimer\n toutes les données pour %s?",
        [CraftSim.CONST.TEXT.CUSTOMER_HISTORY_PURGE_DAYS_INPUT_LABEL] = "Intervalle de suppression automatique (jours)",
        [CraftSim.CONST.TEXT.CUSTOMER_HISTORY_PURGE_DAYS_INPUT_TOOLTIP] =
        "CraftSim supprimera automatiquement tous les clients sans pourboire lorsque vous vous connecterez après X jours depuis la dernière suppression.\nSi réglé à 0, CraftSim ne supprimera jamais automatiquement.",
        [CraftSim.CONST.TEXT.CUSTOMER_HISTORY_CUSTOMER_HEADER] = "Client",
        [CraftSim.CONST.TEXT.CUSTOMER_HISTORY_TOTAL_TIP_HEADER] = "Pourboire total",
        [CraftSim.CONST.TEXT.CUSTOMER_HISTORY_CRAFT_HISTORY_DATE_HEADER] = "Date",
        [CraftSim.CONST.TEXT.CUSTOMER_HISTORY_CRAFT_HISTORY_RESULT_HEADER] = "Résultat",
        [CraftSim.CONST.TEXT.CUSTOMER_HISTORY_CRAFT_HISTORY_TIP_HEADER] = "Pourboire",
        [CraftSim.CONST.TEXT.CUSTOMER_HISTORY_CRAFT_HISTORY_CUSTOMER_REAGENTS_HEADER] = "Matériaux du client",
        [CraftSim.CONST.TEXT.CUSTOMER_HISTORY_CRAFT_HISTORY_CUSTOMER_NOTE_HEADER] = "Note",
        [CraftSim.CONST.TEXT.CUSTOMER_HISTORY_CHAT_MESSAGE_TIMESTAMP] = "Horodatage",
        [CraftSim.CONST.TEXT.CUSTOMER_HISTORY_CHAT_MESSAGE_SENDER] = "Expéditeur",
        [CraftSim.CONST.TEXT.CUSTOMER_HISTORY_CHAT_MESSAGE_MESSAGE] = "Message",
        [CraftSim.CONST.TEXT.CUSTOMER_HISTORY_CHAT_MESSAGE_YOU] = "[Vous]: ",
        [CraftSim.CONST.TEXT.CUSTOMER_HISTORY_CRAFT_LIST_TIMESTAMP] = "Horodatage",
        [CraftSim.CONST.TEXT.CUSTOMER_HISTORY_CRAFT_LIST_RESULTLINK] = "Lien du résultat",
        [CraftSim.CONST.TEXT.CUSTOMER_HISTORY_CRAFT_LIST_TIP] = "Pourboire",
        [CraftSim.CONST.TEXT.CUSTOMER_HISTORY_CRAFT_LIST_REAGENTS] = "Matériaux",
        [CraftSim.CONST.TEXT.CUSTOMER_HISTORY_CRAFT_LIST_SOMENOTE] = "Note",

        -- File d'attente de fabrication
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_TITLE] = "File d'attente CraftSim",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_CRAFT_AMOUNT_LEFT_HEADER] = "En file d'attente",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_CRAFT_PROFESSION_GEAR_HEADER] = "Équipement de profession",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_CRAFTING_COSTS_HEADER] = "Coûts de fabrication",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_CRAFT_BUTTON_ROW_LABEL] = "Fabriquer",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_CRAFT_BUTTON_ROW_LABEL_WRONG_GEAR] = "Mauvais outils",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_CRAFT_BUTTON_ROW_LABEL_NO_REAGENTS] = "Pas de matériaux",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_ADD_OPEN_RECIPE_BUTTON_LABEL] = "Ajouter recette ouverte",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_ADD_FIRST_CRAFTS_BUTTON_LABEL] = "Ajouter premières fabrications",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_ADD_WORK_ORDERS_BUTTON_LABEL] = "Ajouter commandes de travail",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_ADD_WORK_ORDERS_ALLOW_CONCENTRATION_CHECKBOX] = "Permettre la concentration",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_ADD_WORK_ORDERS_ALLOW_CONCENTRATION_TOOLTIP] =
            "Si la qualité minimale ne peut pas être atteinte, utiliser " .. f.l("Concentration") .. " si possible",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_CLEAR_ALL_BUTTON_LABEL] = "Tout effacer",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_RESTOCK_FAVORITES_BUTTON_LABEL] = "Ajouter favoris",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_CRAFT_BUTTON_ROW_LABEL_WRONG_PROFESSION] = "Mauvaise profession",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_CRAFT_BUTTON_ROW_LABEL_ON_COOLDOWN] = "En recharge",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_CRAFT_BUTTON_ROW_LABEL_WRONG_CRAFTER] = "Mauvais artisan",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_RECIPE_REQUIREMENTS_HEADER] = "Exigences",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_RECIPE_REQUIREMENTS_TOOLTIP] =
        "Tous les critères doivent être remplis pour fabriquer une recette",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_CRAFT_NEXT_BUTTON_LABEL] = "Fabriquer suivant",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_CRAFT_AVAILABLE_AMOUNT] = "Fabricable",
        [CraftSim.CONST.TEXT.CRAFTQUEUE_AUCTIONATOR_SHOPPING_LIST_BUTTON_LABEL] = "Créer liste d'achats Auctionator",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_QUEUE_TAB_LABEL] = "File d'attente",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_FLASH_TASKBAR_OPTION_LABEL] = "Faire clignoter la barre des tâches lorsque " ..
            f.bb("CraftQueue") .. " fabrication terminée",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_FLASH_TASKBAR_OPTION_TOOLTIP] =
            "Lorsque votre jeu WoW est minimisé et qu'une recette a terminé de se fabriquer dans la " ..
            f.bb("CraftQueue") ..
            "," .. f.l(" CraftSim") .. " fera clignoter l'icône WoW de votre barre des tâches",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_RESTOCK_OPTIONS_TAB_LABEL] = "Options de réapprovisionnement",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_RESTOCK_OPTIONS_TAB_TOOLTIP] =
        "Configurer le comportement de réapprovisionnement lors de l'importation depuis le scan de recette",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_RESTOCK_OPTIONS_GENERAL_PROFIT_THRESHOLD_LABEL] = "Seuil de profit:",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_RESTOCK_OPTIONS_SALE_RATE_INPUT_LABEL] = "Seuil de taux de vente:",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_RESTOCK_OPTIONS_TSM_SALE_RATE_TOOLTIP] = string.format(
            [[
        Disponible uniquement lorsque %s est chargé!

        Il sera vérifié si %s des qualités choisies d'un article a un taux de vente
        supérieur ou égal au seuil de taux de vente configuré.
        ]], f.bb("TSM"), f.bb("any")),
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_RESTOCK_OPTIONS_TSM_SALE_RATE_TOOLTIP_GENERAL] = string.format(
            [[
        Disponible uniquement lorsque %s est chargé!

        Il sera vérifié si %s des qualités d'un article a un taux de vente
        supérieur ou égal au seuil de taux de vente configuré.
        ]], f.bb("TSM"), f.bb("any")),
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_RESTOCK_OPTIONS_AMOUNT_LABEL] = "Quantité de réapprovisionnement:",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_RESTOCK_OPTIONS_RESTOCK_TOOLTIP] = "C'est la " ..
            f.bb("quantité de fabrications") ..
            " qui sera mise en file d'attente pour cette recette.\n\nLa quantité d'articles que vous avez dans votre inventaire et votre banque des qualités vérifiées sera soustraite de la quantité de réapprovisionnement lors du réapprovisionnement",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_RESTOCK_OPTIONS_ENABLE_RECIPE_LABEL] = "Activer:",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_RESTOCK_OPTIONS_GENERAL_OPTIONS_LABEL] =
        "Options générales (toutes les recettes)",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_RESTOCK_OPTIONS_ENABLE_RECIPE_TOOLTIP] =
        "Si cette option est désactivée, la recette sera réapprovisionnée en fonction des options générales ci-dessus",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_TOTAL_PROFIT_LABEL] = "Profit total Ø:",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_TOTAL_CRAFTING_COSTS_LABEL] = "Coûts de fabrication totaux:",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_EDIT_RECIPE_TITLE] = "Modifier la recette",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_EDIT_RECIPE_NAME_LABEL] = "Nom de la recette",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_EDIT_RECIPE_REAGENTS_SELECT_LABEL] = "Sélectionner",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_EDIT_RECIPE_OPTIONAL_REAGENTS_LABEL] = "Matériaux optionnels",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_EDIT_RECIPE_FINISHING_REAGENTS_LABEL] = "Matériaux de finition",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_EDIT_RECIPE_SPARK_LABEL] = "Étincelle",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_EDIT_RECIPE_PROFESSION_GEAR_LABEL] = "Équipement de profession",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_EDIT_RECIPE_OPTIMIZE_PROFIT_BUTTON] = "Optimiser",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_EDIT_RECIPE_CRAFTING_COSTS_LABEL] = "Coûts de fabrication: ",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_EDIT_RECIPE_AVERAGE_PROFIT_LABEL] = "Profit moyen: ",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_EDIT_RECIPE_RESULTS_LABEL] = "Résultats",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_EDIT_RECIPE_CONCENTRATION_CHECKBOX] = " Concentration",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_AUCTIONATOR_SHOPPING_LIST_PER_CHARACTER_CHECKBOX] = "Par personnage",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_AUCTIONATOR_SHOPPING_LIST_PER_CHARACTER_CHECKBOX_TOOLTIP] = "Créer une " ..
            f.bb("Liste d'achats Auctionator") ..
            " pour chaque personnage artisan\nau lieu d'une seule liste d'achats pour tous",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_AUCTIONATOR_SHOPPING_LIST_TARGET_MODE_CHECKBOX] = "Mode cible uniquement",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_AUCTIONATOR_SHOPPING_LIST_TARGET_MODE_CHECKBOX_TOOLTIP] = "Créer une " ..
            f.bb("Liste d'achats Auctionator") .. " uniquement pour les recettes en mode cible",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_UNSAVED_CHANGES_TOOLTIP] = f.white(
            "Quantité en file d'attente non enregistrée.\nAppuyez sur Entrée pour enregistrer"),
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_STATUSBAR_LEARNED] = f.white("Recette apprise"),
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_STATUSBAR_COOLDOWN] = f.white("Pas en recharge"),
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_STATUSBAR_REAGENTS] = f.white("Matériaux disponibles"),
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_STATUSBAR_GEAR] = f.white("Équipement de profession équipé"),
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_STATUSBAR_CRAFTER] = f.white("Personnage artisan correct"),
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_STATUSBAR_PROFESSION] = f.white("Profession ouverte"),
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_BUTTON_EDIT] = "Modifier",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_BUTTON_CRAFT] = "Fabriquer",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_BUTTON_CLAIM] = "Réclamer",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_BUTTON_CLAIMED] = "Réclamé",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_BUTTON_NEXT] = "Suivant: ",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_BUTTON_NOTHING_QUEUED] = "Rien en file d'attente",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_BUTTON_ORDER] = "Commander",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_BUTTON_SUBMIT] = "Soumettre",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_IGNORE_ACUITY_RECIPES_CHECKBOX_LABEL] = "Ignorer les recettes d'acuité",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_IGNORE_ACUITY_RECIPES_CHECKBOX_TOOLTIP] =
            "Ne pas mettre en file d'attente les premières fabrications qui utilisent " ..
            f.bb("Acuité de l'artisan") .. " pour la fabrication",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_AMOUNT_TOOLTIP] = "\n\nFabrications en file d'attente: ",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_ORDER_CUSTOMER] = "\n\nClient de la commande: ",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_ORDER_MINIMUM_QUALITY] = "\nQualité minimale: ",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_ORDER_REWARDS] = "\nRécompenses:",

        -- craft buffs

        [CraftSim.CONST.TEXT.CRAFT_BUFFS_TITLE] = "Buffs de fabrication CraftSim",
        [CraftSim.CONST.TEXT.CRAFT_BUFFS_SIMULATE_BUTTON] = "Simuler les buffs",
        [CraftSim.CONST.TEXT.CRAFT_BUFF_CHEFS_HAT_TOOLTIP] = f.bb("Jouet de Wrath of the Lich King.") ..
            "\nNécessite la cuisine de Norfendre\nRéduit la vitesse de fabrication à " .. f.g("0.5 secondes"),

        -- cooldowns module

        [CraftSim.CONST.TEXT.COOLDOWNS_TITLE] = "Temps de recharge CraftSim",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_COOLDOWNS_LABEL] = "Temps de recharge",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_COOLDOWNS_TOOLTIP] = "Aperçu des " ..
            f.bb("temps de recharge de profession") .. " de votre compte",
        [CraftSim.CONST.TEXT.COOLDOWNS_CRAFTER_HEADER] = "Artisan",
        [CraftSim.CONST.TEXT.COOLDOWNS_RECIPE_HEADER] = "Recette",
        [CraftSim.CONST.TEXT.COOLDOWNS_CHARGES_HEADER] = "Charges",
        [CraftSim.CONST.TEXT.COOLDOWNS_NEXT_HEADER] = "Prochaine charge",
        [CraftSim.CONST.TEXT.COOLDOWNS_ALL_HEADER] = "Charges complètes",
        [CraftSim.CONST.TEXT.COOLDOWNS_TAB_OVERVIEW] = "Aperçu",
        [CraftSim.CONST.TEXT.COOLDOWNS_TAB_OPTIONS] = "Options",
        [CraftSim.CONST.TEXT.COOLDOWNS_EXPANSION_FILTER_BUTTON] = "Filtre d'extension",
        [CraftSim.CONST.TEXT.COOLDOWNS_RECIPE_LIST_TEXT_TOOLTIP] = f.bb(
            "\n\nRecettes partageant ce temps de recharge:\n"),
        [CraftSim.CONST.TEXT.COOLDOWNS_RECIPE_READY] = f.g("Prêt"),

        -- concentration module

        [CraftSim.CONST.TEXT.CONCENTRATION_TRACKER_TITLE] = "Concentration CraftSim",
        [CraftSim.CONST.TEXT.CONCENTRATION_TRACKER_LABEL_CRAFTER] = "Artisan",
        [CraftSim.CONST.TEXT.CONCENTRATION_TRACKER_LABEL_CURRENT] = "Actuel",
        [CraftSim.CONST.TEXT.CONCENTRATION_TRACKER_LABEL_MAX] = "Max",
        [CraftSim.CONST.TEXT.CONCENTRATION_TRACKER_MAX] = f.g("MAX"),
        [CraftSim.CONST.TEXT.CONCENTRATION_TRACKER_MAX_VALUE] = "Max: ",
        [CraftSim.CONST.TEXT.CONCENTRATION_TRACKER_FULL] = f.g("Concentration complète"),
        [CraftSim.CONST.TEXT.CONCENTRATION_TRACKER_SORT_MODE_CHARACTER] = "Personnage",
        [CraftSim.CONST.TEXT.CONCENTRATION_TRACKER_SORT_MODE_CONCENTRATION] = "Concentration",
        [CraftSim.CONST.TEXT.CONCENTRATION_TRACKER_SORT_MODE_PROFESSION] = "Profession",
        [CraftSim.CONST.TEXT.CONCENTRATION_TRACKER_FORMAT_MODE_EUROPE_MAX_DATE] = "Europe - Date max",
        [CraftSim.CONST.TEXT.CONCENTRATION_TRACKER_FORMAT_MODE_AMERICA_MAX_DATE] = "Amérique - Date max",
        [CraftSim.CONST.TEXT.CONCENTRATION_TRACKER_FORMAT_MODE_HOURS_LEFT] = "Heures restantes",

        -- static popups
        [CraftSim.CONST.TEXT.STATIC_POPUPS_YES] = "Oui",
        [CraftSim.CONST.TEXT.STATIC_POPUPS_NO] = "Non",

        -- frames
        [CraftSim.CONST.TEXT.FRAMES_RESETTING] = "réinitialisation de frameID: ",
        [CraftSim.CONST.TEXT.FRAMES_WHATS_NEW] = "Quoi de neuf dans CraftSim?",
        [CraftSim.CONST.TEXT.FRAMES_JOIN_DISCORD] = "Rejoignez le Discord!",
        [CraftSim.CONST.TEXT.FRAMES_DONATE_KOFI] = "Visitez CraftSim sur Kofi",
        [CraftSim.CONST.TEXT.FRAMES_NO_INFO] = "Pas d'info",

        -- node data
        [CraftSim.CONST.TEXT.NODE_DATA_RANK_TEXT] = "Rang ",
        [CraftSim.CONST.TEXT.NODE_DATA_TOOLTIP] = "\n\nStatistiques totales du talent:\n",

        -- columns
        [CraftSim.CONST.TEXT.SOURCE_COLUMN_AH] = "HV",
        [CraftSim.CONST.TEXT.SOURCE_COLUMN_OVERRIDE] = "OR",
        [CraftSim.CONST.TEXT.SOURCE_COLUMN_WO] = "CA",
    }
end
