---@class CraftSim
local CraftSim = select(2, ...)

CraftSim.LOCAL_FR = {}

---@return table<CraftSim.LOCALIZATION_IDS, string>
function CraftSim.LOCAL_FR:GetData()
    local f = CraftSim.GUTIL:GetFormatter()
    local cm = function(i, s) return CraftSim.MEDIA:GetAsTextIcon(i, s) end
    return {
        -- REQUIRED:
        STAT_MULTICRAFT = "Fabrication multiple",
        STAT_RESOURCEFULNESS = "Ingéniosité",
        STAT_INGENUITY = "Inventivité",
        STAT_CRAFTINGSPEED = "Vitesse de fabrication",
        EQUIP_MATCH_STRING = "Équipé :",
        ENCHANTED_MATCH_STRING = "Enchanté :",

        -- OPTIONAL (Defaulting to EN if not available):

        -- shared prof cds
        DF_ALCHEMY_TRANSMUTATIONS = "DF - Transmutations",

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

        -- professions

        PROFESSIONS_BLACKSMITHING = "Forge",
        PROFESSIONS_LEATHERWORKING = "Travail du cuir",
        PROFESSIONS_ALCHEMY = "Alchimie",
        PROFESSIONS_HERBALISM = "Herboristerie",
        PROFESSIONS_COOKING = "Cuisine",
        PROFESSIONS_MINING = "Minage",
        PROFESSIONS_TAILORING = "Couture",
        PROFESSIONS_ENGINEERING = "Ingénierie",
        PROFESSIONS_ENCHANTING = "Enchantement",
        PROFESSIONS_FISHING = "Pêche",
        PROFESSIONS_SKINNING = "Dépeçage",
        PROFESSIONS_JEWELCRAFTING = "Joaillerie",
        PROFESSIONS_INSCRIPTION = "Calligraphie",

        -- Other Statnames

        STAT_SKILL = "Compétence",
        STAT_MULTICRAFT_BONUS = "Objets bonus multicraft",
        STAT_RESOURCEFULNESS_BONUS = "Objets bonus Ingéniosité",
        STAT_CRAFTINGSPEED_BONUS = "Vitesse d'artisanat",
        STAT_INGENUITY_BONUS = "Concentration économisée",
        STAT_INGENUITY_LESS_CONCENTRATION = "Moins de concentration utilisée",
        STAT_PHIAL_EXPERIMENTATION = "Expérimentation des flacons",
        STAT_POTION_EXPERIMENTATION = "Expérimentation des potions",

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
        SIMULATION_MODE_LABEL = "Mode Simulation",
        SIMULATION_MODE_TITLE = "CraftSim Mode Simulation",
        SIMULATION_MODE_TOOLTIP =
        "Le Mode Simulation de Craftsim permet de jouer avec toutes les options sans aucune réstrictions",
        SIMULATION_MODE_OPTIONAL = "Optionnel #",
        SIMULATION_MODE_FINISHING = "Finition #",
        SIMULATION_MODE_QUALITY_BUTTON_TOOLTIP = "Max matériaux de Qualité ",
        SIMULATION_MODE_CLEAR_BUTTON = "Vider",
        SIMULATION_MODE_CONCENTRATION = " Concentration",
        SIMULATION_MODE_CONCENTRATION_COST = "Coût Concentration : ",
        CONCENTRATION_ESTIMATED_TIME_UNTIL = "Fabricable à : %s",

        -- Details Frame
        RECIPE_DIFFICULTY_LABEL = "Difficulté: ",
        MULTICRAFT_LABEL = "Multicraft: ",
        RESOURCEFULNESS_LABEL = "Ingéniosité: ",
        RESOURCEFULNESS_BONUS_LABEL = "Item Bonus Ingéniosité: ",
        CONCENTRATION_LABEL = "Concentration: ",
        REAGENT_QUALITY_BONUS_LABEL = "Bonus Qualité Matériaux: ",
        REAGENT_QUALITY_MAXIMUM_LABEL = "Maximum Qualité Matériaux %: ",
        EXPECTED_QUALITY_LABEL = "Qualité attendue: ",
        NEXT_QUALITY_LABEL = "Qualité suivante: ",
        MISSING_SKILL_LABEL = "Comp. Manquante: ",
        SKILL_LABEL = "Compétence: ",
        MULTICRAFT_BONUS_LABEL = "Item Bonus Multicraft : ",

        -- Statistics
        STATISTICS_CDF_EXPLANATION =
        "This is calculated by using the 'abramowitz and stegun' approximation (1985) of the CDF (Cumulative Distribution Function)\n\nYou will notice that its always around 50% for 1 craft.\nThis is because 0 is most of the time close to the average profit.\nAnd the chance of getting the mean of the CDF is always 50%.\n\nHowever, the rate of change can be very different between recipes.\nIf it is more likely to have a positive profit than a negative one, it will steadly increase.\nThis is of course also true for the other direction.",
        EXPLANATIONS_PROFIT_CALCULATION_EXPLANATION =
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
        POPUP_NO_PRICE_SOURCE_SYSTEM = "Aucune source de prix supporté disponible!",
        POPUP_NO_PRICE_SOURCE_TITLE = "Avertissement de source de prix Craftsim",
        POPUP_NO_PRICE_SOURCE_WARNING =
        "Aucune source de prix trouvée !\n\nVous devez installer au moins un\nde ces addons de sources de prix\npour utiliser le calcul de profit de CraftSim:\n\n\n",
        POPUP_NO_PRICE_SOURCE_WARNING_SUPPRESS = "Ne plus montrer l'avertissement",
        POPUP_NO_PRICE_SOURCE_WARNING_ACCEPT = "OK",

        -- Reagents Frame
        REAGENT_OPTIMIZATION_TITLE = "Optimisation des matériaux CraftSim",
        REAGENTS_REACHABLE_QUALITY = "Qualité atteignable: ",
        REAGENTS_MISSING = "Matériaux manquants",
        REAGENTS_AVAILABLE = "Matériaux disponibles",
        REAGENTS_CHEAPER = "Matériaux moins cher",
        REAGENTS_BEST_COMBINATION = "Meilleur combinaison assigné",
        REAGENTS_NO_COMBINATION = "Aucune combinaison trouvée \npour augmenter la qualité",
        REAGENTS_ASSIGN = "Assigner",
        REAGENTS_MAXIMUM_QUALITY = "Qualité max: ",
        REAGENTS_AVERAGE_PROFIT_LABEL = "Profit moyen: ",
        REAGENTS_AVERAGE_PROFIT_TOOLTIP =
            f.bb("Le profit moyen par craft") .. " en utilisant " .. f.l("cette répartition de matériaux"),
        REAGENTS_OPTIMIZE_BEST_ASSIGNED = "Meilleurs matériaux assignés",
        REAGENTS_CONCENTRATION_LABEL = "Concentration: ",
        REAGENTS_OPTIMIZE_INFO =
        "Shift + Clic gauche sur les chiffres pour mettre le lien de l'objet dans le chat",
        ADVANCED_OPTIMIZATION_BUTTON = "Optimisation Avancée",
        REAGENTS_OPTIMIZE_TOOLTIP =
            "(Réinitialise lors de l'édition)\nActive " ..
            f.gold("Valeur de Concentration") ..
            " et " .. f.bb("Optimisation des Composants de Finition") .. " Optimisation",

        -- Specialization Info Frame
        SPEC_INFO_TITLE = "Info de spécialisation CraftSim",
        SPEC_INFO_SIMULATE_KNOWLEDGE_DISTRIBUTION = "Simuler la distribution de connaissances",
        SPEC_INFO_NODE_TOOLTIP = "Ces noeuds vous apportent ces stats pour cette recette:",
        SPEC_INFO_WORK_IN_PROGRESS = "Specialization Info\nWork in Progress",

        -- Crafting Results Frame
        CRAFT_LOG_TITLE = "Résultats de fabrication CraftSim",
        CRAFT_LOG_LOG = "Craft Log",
        CRAFT_LOG_LOG_1 = "Profit: ",
        CRAFT_LOG_LOG_2 = "Inspiré!",
        CRAFT_LOG_LOG_3 = "Multicraft: ",
        CRAFT_LOG_LOG_4 = "Ressources économisées!: ",
        CRAFT_LOG_LOG_5 = "Chance: ",
        CRAFT_LOG_CRAFTED_ITEMS = "Items fabriqués",
        CRAFT_LOG_SESSION_PROFIT = "Profit Session",
        CRAFT_LOG_RESET_DATA = "Reset Données",
        CRAFT_LOG_EXPORT_JSON = "Export JSON",
        CRAFT_LOG_RECIPE_STATISTICS = "Stats recette",
        CRAFT_LOG_NOTHING = "Aucune fabrication!",
        CRAFT_LOG_CALCULATION_COMPARISON_NUM_CRAFTS_PREFIX = "Crafts: ",
        CRAFT_LOG_STATISTICS_2 = "Profit Ø estimé: ",
        CRAFT_LOG_STATISTICS_3 = "Profit Ø réel: ",
        CRAFT_LOG_STATISTICS_4 = "Profit réel: ",
        CRAFT_LOG_STATISTICS_5 = "Procs - Réel / Attendu: ",
        CRAFT_LOG_STATISTICS_7 = "Multicraft: ",
        CRAFT_LOG_STATISTICS_8 = "- Ø Extra Items: ",
        CRAFT_LOG_STATISTICS_9 = "Procs Ingéniosité: ",
        CRAFT_LOG_CALCULATION_COMPARISON_NUM_CRAFTS_PREFIX0 = "- Ø coûts économisés: ",
        CRAFT_LOG_CALCULATION_COMPARISON_NUM_CRAFTS_PREFIX1 = "Profit: ",
        CRAFT_LOG_SAVED_REAGENTS = "Mat. économisés",
        CRAFT_LOG_RESULT_ANALYSIS_TAB_DISTRIBUTION_LABEL = "Distribution des Résultats",
        CRAFT_LOG_RESULT_ANALYSIS_TAB_DISTRIBUTION_HELP =
        "Distribution relative des résultats des objets fabriqués.\n(Ignorant les quantités de Multicraft)",
        CRAFT_LOG_RESULT_ANALYSIS_TAB_MULTICRAFT = "Multicraft",
        CRAFT_LOG_RESULT_ANALYSIS_TAB_RESOURCEFULNESS = "Ingéniosité",
        CRAFT_LOG_RESULT_ANALYSIS_TAB_YIELD_DDISTRIBUTION = "Distribution du Rendement",

        -- Stats Weight Frame
        STAT_WEIGHTS_TITLE = "Profit Moyen CraftSim",
        EXPLANATIONS_TITLE = "Explication du Profit Moyen CraftSim",
        STAT_WEIGHTS_SHOW_EXPLANATION_BUTTON = "Afficher explications",
        STAT_WEIGHTS_HIDE_EXPLANATION_BUTTON = "Cacher explications",
        STAT_WEIGHTS_SHOW_STATISTICS_BUTTON = "Afficher Statistiques",
        STAT_WEIGHTS_HIDE_STATISTICS_BUTTON = "Cacher Statistiques",
        STAT_WEIGHTS_PROFIT_CRAFT = "Profit Ø / Craft: ",
        EXPLANATIONS_BASIC_PROFIT_TAB = "Calcul du profit basique",

        -- Cost Details Frame
        COST_OPTIMIZATION_TITLE = "Optimisation des coûts CraftSim",
        COST_OPTIMIZATION_EXPLANATION =
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
        COST_OPTIMIZATION_CRAFTING_COSTS = "Coût de craft: ",
        COST_OPTIMIZATION_ITEM_HEADER = "Objet",
        COST_OPTIMIZATION_AH_PRICE_HEADER = "Prix HV",
        COST_OPTIMIZATION_OVERRIDE_HEADER = "Remplacement",
        COST_OPTIMIZATION_CRAFTING_HEADER = "Artisanat",
        COST_OPTIMIZATION_USED_SOURCE = "Source Utilisée",
        COST_OPTIMIZATION_REAGENT_COSTS_TAB = "Coûts des Matériaux",
        COST_OPTIMIZATION_SUB_RECIPE_OPTIONS_TAB = "Options de Sous-Recette",
        COST_OPTIMIZATION_SUB_RECIPE_OPTIMIZATION = "Optimisation des Sous-recettes " ..
            f.bb("(experimental)"),
        COST_OPTIMIZATION_SUB_RECIPE_OPTIMIZATION_TOOLTIP = "Si activé " ..
            f.l("CraftSim") .. " considers the " .. f.g("optimized crafting costs") ..
            " of your character and your alts\nif they are able to craft that item.\n\n" ..
            f.r("Might decrease performance a bit due to a lot of additional calculations"),
        COST_OPTIMIZATION_SUB_RECIPE_MAX_DEPTH_LABEL = "Profondeur de Calcul des Sous-recettes",
        COST_OPTIMIZATION_SUB_RECIPE_INCLUDE_CONCENTRATION = "Activer la Concentration",
        COST_OPTIMIZATION_SUB_RECIPE_INCLUDE_CONCENTRATION_TOOLTIP = "If enabled, " ..
            f.l("CraftSim") .. " will include reagent qualities even if concentration is necessary.",
        COST_OPTIMIZATION_SUB_RECIPE_INCLUDE_COOLDOWN_RECIPES =
        "Inclure Recettes avec Temps de Recharge",
        COST_OPTIMIZATION_SUB_RECIPE_INCLUDE_COOLDOWN_RECIPES_TOOLTIP = "If enabled, " ..
            f.l("CraftSim") .. " will ignore cooldown requirements of recipes when calculating self crafted reagents",
        COST_OPTIMIZATION_SUB_RECIPE_SELECT_RECIPE_CRAFTER = "Sélectionner l'artisan de la recette",
        COST_OPTIMIZATION_REAGENT_LIST_AH_COLUMN_AUCTION_BUYOUT = "Achat immédiat: ",
        COST_OPTIMIZATION_REAGENT_LIST_OVERRIDE = "\n\nRemplacement",
        COST_OPTIMIZATION_REAGENT_LIST_EXPECTED_COSTS_TOOLTIP = "\n\nArtisanat ",
        COST_OPTIMIZATION_REAGENT_LIST_EXPECTED_COSTS_PRE_ITEM =
        "\n- Coûts Prévisionnels Par Article: ",
        COST_OPTIMIZATION_REAGENT_LIST_CONCENTRATION_COST = f.gold("Coût Concentration: "),
        COST_OPTIMIZATION_REAGENT_LIST_CONCENTRATION = "Concentration : ",

        -- Statistics Frame
        STATISTICS_TITLE = "Statistiques CraftSim",
        STATISTICS_EXPECTED_PROFIT = "Profit estimé (μ)",
        STATISTICS_CHANCE_OF = "Chance de ",
        STATISTICS_PROFIT = "Profit",
        STATISTICS_AFTER = " après",
        STATISTICS_CRAFTS = "Crafts: ",
        STATISTICS_QUALITY_HEADER = "Qualité",
        STATISTICS_MULTICRAFT_HEADER = "Multicraft",
        STATISTICS_RESOURCEFULNESS_HEADER = "Resourcefulness",
        STATISTICS_EXPECTED_PROFIT_HEADER = "Expected Profit",
        PROBABILITY_TABLE_TITLE = "Recipe Probability Table",
        STATISTICS_PROBABILITY_TABLE_TAB = "Probability Table",
        STATISTICS_CONCENTRATION_TAB = "Concentration",
        STATISTICS_CONCENTRATION_CURVE_GRAPH = "Concentration Cost Curve",
        STATISTICS_CONCENTRATION_CURVE_GRAPH_HELP =
            "Concentration Cost based on Player Skill for given Recipe\n" ..
            f.bb("X Axis: ") .. " Player Skill\n" ..
            f.bb("Y Axis: ") .. " Concentration Cost",

        -- Price Details Frame
        COST_OVERVIEW_TITLE = "Details des prix CraftSim",
        PRICE_DETAILS_INV_AH = "Sac/HV",
        PRICE_DETAILS_ITEM = "Item",
        PRICE_DETAILS_PRICE_ITEM = "Prix/Item",
        PRICE_DETAILS_PROFIT_ITEM = "Profit/Item",

        -- Price Override Frame
        PRICE_OVERRIDE_TITLE = "Remplacement des prix CraftSim",
        PRICE_OVERRIDE_REQUIRED_REAGENTS = "Composants Requis",
        PRICE_OVERRIDE_OPTIONAL_REAGENTS = "Composants Optionnels",
        PRICE_OVERRIDE_FINISHING_REAGENTS = "Composants de finitions",
        PRICE_OVERRIDE_RESULT_ITEMS = "Résultat",
        PRICE_OVERRIDE_ACTIVE_OVERRIDES = "Remplacement actifs",
        PRICE_OVERRIDE_ACTIVE_OVERRIDES_TOOLTIP =
        "'(as result)' -> price override only considered when item is a result of a recipe",
        PRICE_OVERRIDE_CLEAR_ALL = "Supprimer tout",
        PRICE_OVERRIDE_SAVE = "Enregistrer",
        PRICE_OVERRIDE_SAVED = "Enregistré",
        PRICE_OVERRIDE_REMOVE = "Supprimer",

        -- Recipe Scan Frame
        RECIPE_SCAN_TITLE = "Scan Recettes CraftSim",
        RECIPE_SCAN_MODE = "Mode de scan",
        RECIPE_SCAN_SORT_MODE = "Mode de tri",
        RECIPE_SCAN_SCAN_RECIPIES = "Scanner recettes",
        RECIPE_SCAN_SCAN_CANCEL = "Annuler",
        RECIPE_SCAN_SCANNING = "Scan...",
        RECIPE_SCAN_INCLUDE_NOT_LEARNED = "Inclure non apprises",
        RECIPE_SCAN_INCLUDE_NOT_LEARNED_TOOLTIP =
        "Inclu les recettes non connues dans le scan",
        RECIPE_SCAN_INCLUDE_SOULBOUND = "Inclure liés",
        RECIPE_SCAN_INCLUDE_SOULBOUND_TOOLTIP =
        "Include soulbound recipes in the recipe scan.\n\nIt is recommended to set a price override (e.g. to simulate a target comission)\nin the Price Override Module for that recipe's crafted items",
        RECIPE_SCAN_INCLUDE_GEAR = "Inclure l'équipement",
        RECIPE_SCAN_INCLUDE_GEAR_TOOLTIP = "Inclu toutes les formes d'équipements dans le scan",
        RECIPE_SCAN_OPTIMIZE_TOOLS = "Optimiser l'équipement de métier",
        RECIPE_SCAN_OPTIMIZE_TOOLS_TOOLTIP =
        "Optimise votre équipement de métier pour chaque recette\n\n",
        RECIPE_SCAN_OPTIMIZE_TOOLS_WARNING =
        "Ceci peut affecter les performances\nsi vous avez beaucoup d'équipements dans votre sac",
        RECIPE_SCAN_CRAFTER_HEADER = "Fabricant",
        RECIPE_SCAN_RECIPE_HEADER = "Recette",
        RECIPE_SCAN_LEARNED_HEADER = "Apprise",
        RECIPE_SCAN_RESULT_HEADER = "Resultat",
        RECIPE_SCAN_AVERAGE_PROFIT_HEADER = "Profit moyen",
        RECIPE_SCAN_CONCENTRATION_VALUE_HEADER = "C. Valeur",
        RECIPE_SCAN_CONCENTRATION_COST_HEADER = "C. Coût",
        RECIPE_SCAN_TOP_GEAR_HEADER = "Meilleur équipement",
        RECIPE_SCAN_INV_AH_HEADER = "Sac/HV",
        RECIPE_SCAN_SORT_BY_MARGIN = "Tri %Profit",
        RECIPE_SCAN_SORT_BY_MARGIN_TOOLTIP =
        "Tri la liste en fonction du profit relatif\nau coût de fabrication(Nouv. Scan requis)",
        RECIPE_SCAN_USE_INSIGHT_CHECKBOX = "Utiliser " .. f.bb("Clairvoyance") .. " si possible",
        RECIPE_SCAN_USE_INSIGHT_CHECKBOX_TOOLTIP = "Utiliser " ..
            f.bb("Clairvoyance illustre") ..
            " ou\n" .. f.bb("Clairvoyance illustre inférieure") .. " en composants optionnels si possible",
        RECIPE_SCAN_ONLY_FAVORITES_CHECKBOX = "Favoris uniquements",
        RECIPE_SCAN_ONLY_FAVORITES_CHECKBOX_TOOLTIP = "Scan uniquement les recettes favorites",
        RECIPE_SCAN_EQUIPPED = "Equipé",
        RECIPE_SCAN_MODE_OPTIMIZE = "Optimiser Matériaux",
        RECIPE_SCAN_SORT_MODE_PROFIT = "Profit",
        RECIPE_SCAN_SORT_MODE_RELATIVE_PROFIT = "Profit Relatif",
        RECIPE_SCAN_SORT_MODE_CONCENTRATION_VALUE = "Valeur Concentration",
        RECIPE_SCAN_SORT_MODE_CONCENTRATION_COST = "Coût Concentration",
        RECIPE_SCAN_SORT_MODE_CRAFTING_COST = "Coût Artisanat",
        RECIPE_SCAN_EXPANSION_FILTER_BUTTON = "Extensions",
        RECIPE_SCAN_ALTPROFESSIONS_FILTER_BUTTON = "Alt Professions",
        RECIPE_SCAN_SCAN_ALL_BUTTON_READY = "Scan Professions",
        RECIPE_SCAN_SCAN_ALL_BUTTON_SCANNING = "Scan...",
        RECIPE_SCAN_TAB_LABEL_SCAN = "Scan Recettes",
        RECIPE_SCAN_TAB_LABEL_OPTIONS = "Options de Scan",
        RECIPE_SCAN_IMPORT_ALL_PROFESSIONS_CHECKBOX_LABEL = "Toutes professions scannées",
        RECIPE_SCAN_IMPORT_ALL_PROFESSIONS_CHECKBOX_TOOLTIP = f.g("Coché: ") ..
            "Importe le résultat du scan de toutes les professions séléctionnées\n\n" ..
            f.r("Décoché: ") .. "Importe le résultat du scan de la profession actuellement séléctionnée",
        RECIPE_SCAN_CACHED_RECIPES_TOOLTIP =
            "Chaque fois que vous ouvrez ou scannez une recette sur un personnage, " ..
            f.l("CraftSim") ..
            " la retient.\n\nUniquement les recettes alts que " ..
            f.l("CraftSim") .. " connaît peuvent être scannée avec le" .. f.bb("Scan Recettes\n\n") ..
            "Le montant actuel des recettes scannées est basé sur vos " .. f.e("Options de Scan"),
        RECIPE_SCAN_CONCENTRATION_TOGGLE = " Concentration",
        RECIPE_SCAN_CONCENTRATION_TOGGLE_TOOLTIP = "Activer/Désactiver la Concentration",
        RECIPE_SCAN_OPTIMIZE_SUBRECIPES = "Optimiser les Sous-recettes " .. f.bb("(expérimental)"),
        RECIPE_SCAN_OPTIMIZE_SUBRECIPES_TOOLTIP = "Si activé, " ..
            f.l("CraftSim") ..
            " optimise également les crafts des recettes de composants mises en cache des recettes scannées et utilise leurs\n" ..
            f.bb("coûts prévus") .. " pour calculer les coûts de fabrication du produit final.\n\n" ..
            f.r("Avertissement : Cela peut réduire les performances de scan"),
        RECIPE_SCAN_CACHED_RECIPES = "Recettes mémorisées: ",
        RECIPE_SCAN_ENABLE_CONCENTRATION = "Enable Concentration",
        RECIPE_SCAN_ONLY_FAVORITES = "Only Favorites",
        RECIPE_SCAN_INCLUDE_SOULBOUND_ITEMS = "Include Soulbound Items",
        RECIPE_SCAN_INCLUDE_UNLEARNED_RECIPES = "Include Unlearned Recipes",
        RECIPE_SCAN_INCLUDE_GEAR_LABEL = "Include Gear",
        RECIPE_SCAN_REAGENT_ALLOCATION = "Reagent Allocation",
        RECIPE_SCAN_REAGENT_ALLOCATION_Q1 = "All Q1",
        RECIPE_SCAN_REAGENT_ALLOCATION_Q2 = "All Q2",
        RECIPE_SCAN_REAGENT_ALLOCATION_Q3 = "All Q3",
        RECIPE_SCAN_AUTOSELECT_TOP_PROFIT = "Autoselect Top Profit Quality",
        RECIPE_SCAN_OPTIMIZE_PROFESSION_GEAR = "Optimize Profession Gear",
        RECIPE_SCAN_OPTIMIZE_CONCENTRATION = "Optimize Concentration",
        RECIPE_SCAN_OPTIMIZE_FINISHING_REAGENTS = "Optimize Finishing Reagents",
        OPTIMIZATION_OPTIONS_OPTIMIZE_PROFESSION_TOOLS = "Optimize Profession Tools",
        OPTIMIZATION_OPTIONS_INCLUDE_SOULBOUND_FINISHING_REAGENTS = "Include Soulbound Finishing Reagents",
        OPTIMIZATION_OPTIONS_FINISHING_REAGENTS_ALGORITHM = "Finishing Reagents Algorithm",
        OPTIMIZATION_OPTIONS_FINISHING_REAGENTS_SIMPLE = "Simple",
        OPTIMIZATION_OPTIONS_FINISHING_REAGENTS_SIMPLE_TOOLTIP = "Optimizes reagent allocation first, then concentration, then selects the best finishing reagent for each slot individually.",
        OPTIMIZATION_OPTIONS_FINISHING_REAGENTS_PERMUTATION = "Permutation Based",
        OPTIMIZATION_OPTIONS_FINISHING_REAGENTS_PERMUTATION_TOOLTIP = "Tries all possible finishing reagent combinations and for each individually optimizes reagents (if enabled) and concentration (if enabled), then selects the most profitable combination.\n\nWarning: This may take significantly longer to complete.",
        RECIPE_SCAN_AUTOSELECT_OPEN_PROFESSION = "Autoselect Open Profession",

        -- Recipe Top Gear
        TOP_GEAR_TITLE = "Meilleur Equipement CraftSim",
        TOP_GEAR_AUTOMATIC = "Automatique",
        TOP_GEAR_AUTOMATIC_TOOLTIP =
        "Simule automatiquement votre équipement pour le mode choisi a chaque fois que vous selectionnez une recette.\n\nDésactiver cette option améliore les performances.",
        TOP_GEAR_SIMULATE = "Simuler meilleur équipement",
        TOP_GEAR_EQUIP = "Equiper",
        TOP_GEAR_SIMULATE_QUALITY = "Qualité: ",
        TOP_GEAR_SIMULATE_EQUIPPED = "Meilleur stuff equipé",
        TOP_GEAR_SIMULATE_PROFIT_DIFFERENCE = "Difference de Profit Ø \n",
        TOP_GEAR_SIMULATE_NEW_MUTLICRAFT = "Nouv. Multicraft\n",
        TOP_GEAR_SIMULATE_NEW_CRAFTING_SPEED = "Nouv. Vitesse Fabrication\n",
        TOP_GEAR_SIMULATE_NEW_RESOURCEFULNESS = "Nouv. Ingéniosité\n",
        TOP_GEAR_SIMULATE_NEW_SKILL = "Nouv. Compétence\n",
        TOP_GEAR_SIMULATE_UNHANDLED = "Mode Sim. non géré",

        TOP_GEAR_SIM_MODES_PROFIT = "Top Profit",
        TOP_GEAR_SIM_MODES_SKILL = "Top Compétence",
        TOP_GEAR_SIM_MODES_MULTICRAFT = "Top Multicraft",
        TOP_GEAR_SIM_MODES_RESOURCEFULNESS = "Top Ingéniosité",
        TOP_GEAR_SIM_MODES_CRAFTING_SPEED = "Top Vitesse Fabrication",

        -- Options
        OPTIONS_TITLE = "Options CraftSim",
        OPTIONS_GENERAL_TAB = "General",
        OPTIONS_GENERAL_PRICE_SOURCE = "Source de Prix",
        OPTIONS_GENERAL_CURRENT_PRICE_SOURCE = "Source de prix actuelle: ",
        OPTIONS_GENERAL_NO_PRICE_SOURCE = "Pas d'addon de source de prix chargé!",
        OPTIONS_GENERAL_SHOW_PROFIT = "Afficher le % Profit",
        OPTIONS_GENERAL_SHOW_PROFIT_TOOLTIP =
        "Afficher le pourcentage de profit par rapport aux coûts d'artisanat en plus de la valeur de l'or",
        OPTIONS_GENERAL_REMEMBER_LAST_RECIPE = "Retenir dernière recette",
        OPTIONS_GENERAL_REMEMBER_LAST_RECIPE_TOOLTIP =
        "Réouverture de la dernière recette sélectionnée lors de l'ouverture de la fenêtre d'artisanat",
        OPTIONS_GENERAL_SUPPORTED_PRICE_SOURCES = "Source de prix supportées:",
        OPTIONS_PERFORMANCE_RAM = "Activer le nettoyage de la RAM pendant la fabrication",
        OPTIONS_PERFORMANCE_RAM_CRAFTS = "Crafts",
        OPTIONS_PERFORMANCE_RAM_TOOLTIP =
        "Lorsque cette option est activée, CraftSim nettoie votre RAM après un certain nombres de crafts spécifiés afin d'empêcher l'accumulation de mémoire.\nL'accumulation de mémoire peut également se produire à cause d'autres addons et n'est pas spécifique à CraftSim.",
        OPTIONS_MODULES_TAB = "Modules",
        OPTIONS_PROFIT_CALCULATION_TAB = "Calcul du profit",
        OPTIONS_CRAFTING_TAB = "Artisanat",
        OPTIONS_TSM_RESET = "Paramètres par défaut",
        OPTIONS_TSM_INVALID_EXPRESSION = "Expression Invalide",
        OPTIONS_TSM_VALID_EXPRESSION = "Expression Valide",
        OPTIONS_TSM_DEPOSIT_ENABLED_LABEL = "Activer le coût de dépôt estimé",
        OPTIONS_TSM_DEPOSIT_ENABLED_TOOLTIP = "Soustrait le coût de dépôt HV estimé du calcul de profit.\nUtilise les données de prix TSM pour estimer le dépôt lors de la mise en vente.",
        OPTIONS_TSM_DEPOSIT_EXPRESSION_LABEL = "Expression TSM pour le dépôt",
        OPTIONS_TSM_SMART_RESTOCK_ENABLED_LABEL = "Restock intelligent (soustraire l'inventaire)",
        OPTIONS_TSM_SMART_RESTOCK_ENABLED_TOOLTIP = "Lors de l'envoi des recettes dans la file d'artisanat, soustrait les objets\ndéjà possédés (sacs, banque, alts, banque de guilde) du nombre à restock.",
        OPTIONS_TSM_SMART_RESTOCK_INCLUDE_ALTS_LABEL = "Inclure les personnages alternatifs",
        OPTIONS_TSM_SMART_RESTOCK_INCLUDE_WARBANK_LABEL = "Inclure la banque de guilde",
        OPTIONS_MODULES_REAGENT_OPTIMIZATION = "Module Optimisation Matériaux",
        OPTIONS_MODULES_AVERAGE_PROFIT = "Module Profit Moyen",
        OPTIONS_MODULES_TOP_GEAR = "Module Top Equipement",
        OPTIONS_MODULES_COST_OVERVIEW = "Module Vue Coût détaillé",
        OPTIONS_MODULES_SPECIALIZATION_INFO = "Module Info. Spécialisation",
        OPTIONS_MODULES_CUSTOMER_HISTORY_SIZE = "Max message en historique par client",
        OPTIONS_MODULES_CUSTOMER_HISTORY_MAX_ENTRIES_PER_CLIENT = "Max history entries per client",
        OPTIONS_PROFIT_CALCULATION_OFFSET = "Décalage de 1 point de compétence",
        OPTIONS_PROFIT_CALCULATION_OFFSET_TOOLTIP =
        "La proposition de combinaison de matériaux tentera d'atteindre +1 au lieu de correspondre à la compétence exacte requise.",
        OPTIONS_PROFIT_CALCULATION_MULTICRAFT_CONSTANT = "Constante Multicraft",
        OPTIONS_PROFIT_CALCULATION_MULTICRAFT_CONSTANT_EXPLANATION =
        "Default: 2.5\n\nCrafting Data from different data collecting players in beta and early Dragonflight suggest that\nthe maximum extra items one can receive from a multicraft proc is 1+C*y.\nWhere y is the base item amount for one craft and C is 2.5.\nHowever if you wish you can modify this value here.",
        OPTIONS_PROFIT_CALCULATION_RESOURCEFULNESS_CONSTANT = "Constante Ingéniosité",
        OPTIONS_PROFIT_CALCULATION_RESOURCEFULNESS_CONSTANT_EXPLANATION =
        "Default: 0.3\n\nCrafting Data from different data collecting players in beta and early Dragonflight suggest that\nthe average amount of items saved is 30% of the required quantity.\nHowever if you wish you can modify this value here.",
        OPTIONS_GENERAL_SHOW_NEWS_CHECKBOX = "Afficher la popup des " .. f.bb("News"),
        OPTIONS_GENERAL_SHOW_NEWS_CHECKBOX_TOOLTIP = "Show the " ..
            f.bb("News") .. " Popup for new " .. f.l("CraftSim") .. " Update Information when logging into the game",
        OPTIONS_GENERAL_HIDE_MINIMAP_BUTTON_CHECKBOX = "Cacher bouton minimap",
        OPTIONS_GENERAL_HIDE_MINIMAP_BUTTON_TOOLTIP = "Enable to hide the " ..
            f.l("CraftSim") .. " Minimap Button",
        OPTIONS_GENERAL_COIN_MONEY_FORMAT_CHECKBOX = "UTextures pièces: ",
        OPTIONS_GENERAL_COIN_MONEY_FORMAT_TOOLTIP =
        "Utiliser des icônes de pièces pour formater l'argent",

        -- Control Panel
        CONTROL_PANEL_MODULES_CRAFT_QUEUE_LABEL = "File d'attente",
        CONTROL_PANEL_MODULES_CRAFT_QUEUE_TOOLTIP =
        "Queue your recipes and craft them all on one place!",
        CONTROL_PANEL_MODULES_TOP_GEAR_LABEL = "Meilleur Equipement",
        CONTROL_PANEL_MODULES_TOP_GEAR_TOOLTIP =
        "Shows the best available profession gear combination based on the selected mode",
        CONTROL_PANEL_MODULES_COST_OVERVIEW_LABEL = "Details Prix",
        CONTROL_PANEL_MODULES_COST_OVERVIEW_TOOLTIP =
        "Shows a sell price and profit overview by resulting item quality",
        CONTROL_PANEL_MODULES_AVERAGE_PROFIT_LABEL = "Profit Moyen",
        CONTROL_PANEL_MODULES_AVERAGE_PROFIT_TOOLTIP =
        "Shows the average profit based on your profession stats and the profit stat weights as gold per point.",
        CONTROL_PANEL_MODULES_REAGENT_OPTIMIZATION_LABEL = "Optimisation Matériaux",
        CONTROL_PANEL_MODULES_REAGENT_OPTIMIZATION_TOOLTIP =
        "Suggests the cheapest reagents to reach the specific quality thresholds.",
        CONTROL_PANEL_MODULES_PRICE_OVERRIDES_LABEL = "Remplacement Prix",
        CONTROL_PANEL_MODULES_PRICE_OVERRIDES_TOOLTIP =
        "Override prices of any reagents, and craft results for all recipes or for one recipe specifically.",
        CONTROL_PANEL_MODULES_SPECIALIZATION_INFO_LABEL = "Info Specialisation",
        CONTROL_PANEL_MODULES_SPECIALIZATION_INFO_TOOLTIP =
        "Shows how your profession specializations affect this recipe and makes it possible to simulate any configuration!",
        CONTROL_PANEL_MODULES_CRAFT_LOG_LABEL = "Résultats Fabrication",
        CONTROL_PANEL_MODULES_CRAFT_LOG_TOOLTIP =
        "Show a crafting log and statistics about your crafts!",
        CONTROL_PANEL_MODULES_COST_OPTIMIZATION_LABEL = "Optimisation Coûts",
        CONTROL_PANEL_MODULES_COST_OPTIMIZATION_TOOLTIP =
        "Module that shows detailed information about and helps with optimizing crafting costs",
        CONTROL_PANEL_MODULES_STATISTICS_LABEL = "Stats",
        CONTROL_PANEL_MODULES_STATISTICS_TOOLTIP =
        "Module that shows detailed outcome statistics for the currently open recipe",
        CONTROL_PANEL_MODULES_RECIPE_SCAN_LABEL = "Scan Recette",
        CONTROL_PANEL_MODULES_RECIPE_SCAN_TOOLTIP =
        "Module that scans your recipe list based on various options",
        CONTROL_PANEL_MODULES_CUSTOMER_HISTORY_LABEL = "Historique Client",
        CONTROL_PANEL_MODULES_CUSTOMER_HISTORY_TOOLTIP =
        "Module that provides a history of conversations with customers, crafted items and commissions",
        CONTROL_PANEL_MODULES_CRAFT_BUFFS_LABEL = "Buffs Crafts",
        CONTROL_PANEL_MODULES_CRAFT_BUFFS_TOOLTIP =
        "Module that shows you your active and missing Craft Buffs",
        CONTROL_PANEL_MODULES_EXPLANATIONS_LABEL = "Explications",
        CONTROL_PANEL_MODULES_EXPLANATIONS_TOOLTIP =
            "Module that shows you various explanations of how" .. f.l(" CraftSim") .. " calculates things",
        CONTROL_PANEL_RESET_FRAMES = "Réinit. Position fenêtres",
        CONTROL_PANEL_OPTIONS = "Options",
        CONTROL_PANEL_NEWS = "News",
        CONTROL_PANEL_EASYCRAFT_EXPORT = f.l("Easycraft") .. " Export",
        CONTROL_PANEL_EASYCRAFT_EXPORTING = "En cours...",
        CONTROL_PANEL_EASYCRAFT_EXPORT_NO_RECIPE_FOUND =
        "Aucune recette trouvée pour l'extension The War Within",
        CONTROL_PANEL_FORGEFINDER_EXPORT = f.l("ForgeFinder") .. " Export",
        CONTROL_PANEL_FORGEFINDER_EXPORTING = "Exporting",
        CONTROL_PANEL_EXPORT_EXPLANATION = f.l("wowforgefinder.com") ..
            " and " .. f.l("easycraft.io") ..
            "\nsont des platformes permettant de chercher et publier des " .. f.bb("commandes de craft"),
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
        CUSTOMER_HISTORY_TITLE = "Historique Client CraftSim",
        CUSTOMER_HISTORY_DROPDOWN_LABEL = "Choisir un client",
        CUSTOMER_HISTORY_TOTAL_TIP = "Pourboire total: ",
        CUSTOMER_HISTORY_FROM = "De",
        CUSTOMER_HISTORY_TO = "À",
        CUSTOMER_HISTORY_FOR = "Pour",
        CUSTOMER_HISTORY_CRAFT_FORMAT = "Fabriqué %s pour %s",
        CUSTOMER_HISTORY_DELETE_BUTTON = "Supprimer client",
        CUSTOMER_HISTORY_WHISPER_BUTTON_LABEL = "Chuchoter..",
        CUSTOMER_HISTORY_PURGE_NO_TIP_LABEL = "Supprimer clients sans pourboire",
        CUSTOMER_HISTORY_PURGE_ZERO_TIPS_CONFIRMATION_POPUP =
        "Êtes-vous sûr de vouloir supprimer toutes les données\n des clients sans pourboire total?",
        CUSTOMER_HISTORY_DELETE_CUSTOMER_CONFIRMATION_POPUP =
        "Êtes-vous sûr de vouloir supprimer\n toutes les données pour %s?",
        CUSTOMER_HISTORY_PURGE_DAYS_INPUT_LABEL = "Intervalle de suppression automatique (jours)",
        CUSTOMER_HISTORY_PURGE_DAYS_INPUT_TOOLTIP =
        "CraftSim supprimera automatiquement tous les clients sans pourboire lorsque vous vous connecterez après X jours depuis la dernière suppression.\nSi réglé à 0, CraftSim ne supprimera jamais automatiquement.",
        CUSTOMER_HISTORY_CUSTOMER_HEADER = "Client",
        CUSTOMER_HISTORY_TOTAL_TIP_HEADER = "Pourboire total",
        CUSTOMER_HISTORY_CRAFT_HISTORY_DATE_HEADER = "Date",
        CUSTOMER_HISTORY_CRAFT_HISTORY_RESULT_HEADER = "Résultat",
        CUSTOMER_HISTORY_CRAFT_HISTORY_TIP_HEADER = "Pourboire",
        CUSTOMER_HISTORY_CRAFT_HISTORY_CUSTOMER_REAGENTS_HEADER = "Matériaux du client",
        CUSTOMER_HISTORY_CRAFT_HISTORY_CUSTOMER_NOTE_HEADER = "Note",
        CUSTOMER_HISTORY_CHAT_MESSAGE_TIMESTAMP = "Horodatage",
        CUSTOMER_HISTORY_CHAT_MESSAGE_SENDER = "Expéditeur",
        CUSTOMER_HISTORY_CHAT_MESSAGE_MESSAGE = "Message",
        CUSTOMER_HISTORY_CHAT_MESSAGE_YOU = "[Vous]: ",
        CUSTOMER_HISTORY_CRAFT_LIST_TIMESTAMP = "Horodatage",
        CUSTOMER_HISTORY_CRAFT_LIST_RESULTLINK = "Lien du résultat",
        CUSTOMER_HISTORY_CRAFT_LIST_TIP = "Pourboire",
        CUSTOMER_HISTORY_CRAFT_LIST_REAGENTS = "Matériaux",
        CUSTOMER_HISTORY_CRAFT_LIST_SOMENOTE = "Note",

        -- File d'attente de fabrication
        CRAFT_QUEUE_TITLE = "File d'attente CraftSim",
        CRAFT_QUEUE_CRAFT_AMOUNT_LEFT_HEADER = "En file d'attente",
        CRAFT_QUEUE_CRAFT_PROFESSION_GEAR_HEADER = "Équipement de profession",
        CRAFT_QUEUE_CRAFTING_COSTS_HEADER = "Coûts de fabrication",
        CRAFT_QUEUE_CRAFT_BUTTON_ROW_LABEL = "Fabriquer",
        CRAFT_QUEUE_CRAFT_BUTTON_ROW_LABEL_WRONG_GEAR = "Mauvais outils",
        CRAFT_QUEUE_CRAFT_BUTTON_ROW_LABEL_NO_REAGENTS = "Pas de matériaux",
        CRAFT_QUEUE_ADD_OPEN_RECIPE_BUTTON_LABEL = "Ajouter recette ouverte",
        CRAFT_QUEUE_ADD_FIRST_CRAFTS_BUTTON_LABEL = "Ajouter premières fabrications",
        CRAFT_QUEUE_ADD_WORK_ORDERS_BUTTON_LABEL = "Ajouter commandes de travail",
        CRAFT_QUEUE_ADD_WORK_ORDERS_ALLOW_CONCENTRATION_CHECKBOX = "Permettre la " .. f.gold("Concentration"),
        CRAFT_QUEUE_ADD_WORK_ORDERS_ALLOW_CONCENTRATION_TOOLTIP =
            "Si la qualité minimale ne peut pas être atteinte, utiliser " .. f.l("Concentration") .. " si possible",
        CRAFT_QUEUE_WORK_ORDER_TYPE_BUTTON = "Type de commande",
        CRAFT_QUEUE_PATRON_ORDERS_BUTTON = "Commandes de clients",
        CRAFT_QUEUE_GUILD_ORDERS_BUTTON = "Commandes de guilde",
        CRAFT_QUEUE_PERSONAL_ORDERS_BUTTON = "Commandes personnelles",
        CRAFT_QUEUE_GUILD_ORDERS_ALTS_ONLY_CHECKBOX = f.r("Seulement ") .. "les rerolls",
        CRAFT_QUEUE_PATRON_ORDERS_FORCE_CONCENTRATION_CHECKBOX = f.r("Forcer ") .. f.gold("Concentration"),
        CRAFT_QUEUE_PATRON_ORDERS_FORCE_CONCENTRATION_TOOLTIP = "Forcer l'utilisation de la concentration pour toutes les commandes de clients si possible",
        CRAFT_QUEUE_PATRON_ORDERS_SPARK_RECIPES_CHECKBOX = "Inclure les recettes avec " .. f.e("Étincelle"),
        CRAFT_QUEUE_PATRON_ORDERS_SPARK_RECIPES_TOOLTIP = "Inclure les commandes nécessitant une Étincelle comme matériau",
        CRAFT_QUEUE_PATRON_ORDERS_ACUITY_CHECKBOX = "Inclure les récompenses " .. f.bb("Acuité/Aplomb"),
        CRAFT_QUEUE_PATRON_ORDERS_ACUITY_TOOLTIP = "Inclure les commandes avec des récompenses d'Acuité/Aplomb",
        CRAFT_QUEUE_PATRON_ORDERS_POWER_RUNE_CHECKBOX = "Inclure les récompenses " .. f.bb("Rune d'augmentation"),
        CRAFT_QUEUE_PATRON_ORDERS_POWER_RUNE_TOOLTIP = "Inclure les commandes avec des récompenses de Rune d'augmentation",
        CRAFT_QUEUE_PATRON_ORDERS_KNOWLEDGE_POINTS_CHECKBOX = "Inclure les récompenses " .. f.bb("Points de connaissance"),
        CRAFT_QUEUE_PATRON_ORDERS_KNOWLEDGE_POINTS_TOOLTIP = "Inclure les commandes avec des récompenses de Points de connaissance",
        CRAFT_QUEUE_CLEAR_ALL_BUTTON_LABEL = "Tout effacer",
        CRAFT_QUEUE_RESTOCK_FAVORITES_BUTTON_LABEL = "Ajouter favoris",
        CRAFT_QUEUE_CRAFT_BUTTON_ROW_LABEL_WRONG_PROFESSION = "Mauvaise profession",
        CRAFT_QUEUE_CRAFT_BUTTON_ROW_LABEL_ON_COOLDOWN = "En recharge",
        CRAFT_QUEUE_CRAFT_BUTTON_ROW_LABEL_WRONG_CRAFTER = "Mauvais artisan",
        CRAFT_QUEUE_RECIPE_REQUIREMENTS_HEADER = "Exigences",
        CRAFT_QUEUE_RECIPE_REQUIREMENTS_TOOLTIP =
        "Tous les critères doivent être remplis pour fabriquer une recette",
        CRAFT_QUEUE_CRAFT_NEXT_BUTTON_LABEL = "Fabriquer suivant",
        CRAFT_QUEUE_CRAFT_AVAILABLE_AMOUNT = "Fabricable",
        CRAFTQUEUE_AUCTIONATOR_SHOPPING_LIST_BUTTON_LABEL = "Créer liste d'achats Auctionator",
        CRAFT_QUEUE_QUEUE_TAB_LABEL = "File d'attente",
        CRAFT_QUEUE_FLASH_TASKBAR_OPTION_LABEL = "Faire clignoter la barre des tâches lorsque " ..
            f.bb("CraftQueue") .. " fabrication terminée",
        CRAFT_QUEUE_FLASH_TASKBAR_OPTION_TOOLTIP =
            "Lorsque votre jeu WoW est minimisé et qu'une recette a terminé de se fabriquer dans la " ..
            f.bb("CraftQueue") ..
            "," .. f.l(" CraftSim") .. " fera clignoter l'icône WoW de votre barre des tâches",
        CRAFT_QUEUE_RESTOCK_OPTIONS_TAB_LABEL = "Options de réapprovisionnement",
        CRAFT_QUEUE_RESTOCK_OPTIONS_TAB_TOOLTIP =
        "Configurer le comportement de réapprovisionnement lors de l'importation depuis le scan de recette",
        CRAFT_QUEUE_RESTOCK_OPTIONS_GENERAL_PROFIT_THRESHOLD_LABEL = "Seuil de profit:",
        CRAFT_QUEUE_RESTOCK_OPTIONS_SALE_RATE_INPUT_LABEL = "Seuil de taux de vente:",
        CRAFT_QUEUE_RESTOCK_OPTIONS_TSM_SALE_RATE_TOOLTIP = string.format(
            [[
        Disponible uniquement lorsque %s est chargé!

        Il sera vérifié si %s des qualités choisies d'un article a un taux de vente
        supérieur ou égal au seuil de taux de vente configuré.
        ]], f.bb("TSM"), f.bb("any")),
        CRAFT_QUEUE_RESTOCK_OPTIONS_TSM_SALE_RATE_TOOLTIP_GENERAL = string.format(
            [[
        Disponible uniquement lorsque %s est chargé!

        Il sera vérifié si %s des qualités d'un article a un taux de vente
        supérieur ou égal au seuil de taux de vente configuré.
        ]], f.bb("TSM"), f.bb("any")),
        CRAFT_QUEUE_RESTOCK_OPTIONS_AMOUNT_LABEL = "Quantité de réapprovisionnement:",
        CRAFT_QUEUE_RESTOCK_OPTIONS_RESTOCK_TOOLTIP = "C'est la " ..
            f.bb("quantité de fabrications") ..
            " qui sera mise en file d'attente pour cette recette.\n\nLa quantité d'articles que vous avez dans votre inventaire et votre banque des qualités vérifiées sera soustraite de la quantité de réapprovisionnement lors du réapprovisionnement",
        CRAFT_QUEUE_RESTOCK_OPTIONS_ENABLE_RECIPE_LABEL = "Activer:",
        CRAFT_QUEUE_RESTOCK_OPTIONS_GENERAL_OPTIONS_LABEL =
        "Options générales (toutes les recettes)",
        CRAFT_QUEUE_RESTOCK_OPTIONS_ENABLE_RECIPE_TOOLTIP =
        "Si cette option est désactivée, la recette sera réapprovisionnée en fonction des options générales ci-dessus",
        CRAFT_QUEUE_TOTAL_PROFIT_LABEL = "Profit total Ø:",
        CRAFT_QUEUE_TOTAL_CRAFTING_COSTS_LABEL = "Coûts de fabrication totaux:",
        CRAFT_QUEUE_EDIT_RECIPE_TITLE = "Modifier la recette",
        CRAFT_QUEUE_EDIT_RECIPE_NAME_LABEL = "Nom de la recette",
        CRAFT_QUEUE_EDIT_RECIPE_REAGENTS_SELECT_LABEL = "Sélectionner",
        CRAFT_QUEUE_EDIT_RECIPE_OPTIONAL_REAGENTS_LABEL = "Matériaux optionnels",
        CRAFT_QUEUE_EDIT_RECIPE_FINISHING_REAGENTS_LABEL = "Matériaux de finition",
        CRAFT_QUEUE_EDIT_RECIPE_SPARK_LABEL = "Étincelle",
        CRAFT_QUEUE_EDIT_RECIPE_PROFESSION_GEAR_LABEL = "Équipement de profession",
        CRAFT_QUEUE_EDIT_RECIPE_OPTIMIZE_PROFIT_BUTTON = "Optimiser",
        CRAFT_QUEUE_EDIT_RECIPE_CRAFTING_COSTS_LABEL = "Coûts de fabrication: ",
        CRAFT_QUEUE_EDIT_RECIPE_AVERAGE_PROFIT_LABEL = "Profit moyen: ",
        CRAFT_QUEUE_EDIT_RECIPE_RESULTS_LABEL = "Résultats",
        CRAFT_QUEUE_EDIT_RECIPE_CONCENTRATION_CHECKBOX = " Concentration",
        CRAFT_QUEUE_AUCTIONATOR_SHOPPING_LIST_PER_CHARACTER_CHECKBOX = "Par personnage",
        CRAFT_QUEUE_AUCTIONATOR_SHOPPING_LIST_PER_CHARACTER_CHECKBOX_TOOLTIP = "Créer une " ..
            f.bb("Liste d'achats Auctionator") ..
            " pour chaque personnage artisan\nau lieu d'une seule liste d'achats pour tous",
        CRAFT_QUEUE_AUCTIONATOR_SHOPPING_LIST_TARGET_MODE_CHECKBOX = "Mode cible uniquement",
        CRAFT_QUEUE_AUCTIONATOR_SHOPPING_LIST_TARGET_MODE_CHECKBOX_TOOLTIP = "Créer une " ..
            f.bb("Liste d'achats Auctionator") .. " uniquement pour les recettes en mode cible",
        CRAFT_QUEUE_UNSAVED_CHANGES_TOOLTIP = f.white(
            "Quantité en file d'attente non enregistrée.\nAppuyez sur Entrée pour enregistrer"),
        CRAFT_QUEUE_STATUSBAR_LEARNED = f.white("Recette apprise"),
        CRAFT_QUEUE_STATUSBAR_COOLDOWN = f.white("Pas en recharge"),
        CRAFT_QUEUE_STATUSBAR_REAGENTS = f.white("Matériaux disponibles"),
        CRAFT_QUEUE_STATUSBAR_GEAR = f.white("Équipement de profession équipé"),
        CRAFT_QUEUE_STATUSBAR_CRAFTER = f.white("Personnage artisan correct"),
        CRAFT_QUEUE_STATUSBAR_PROFESSION = f.white("Profession ouverte"),
        CRAFT_QUEUE_BUTTON_EDIT = "Modifier",
        CRAFT_QUEUE_BUTTON_CRAFT = "Fabriquer",
        CRAFT_QUEUE_BUTTON_CLAIM = "Réclamer",
        CRAFT_QUEUE_BUTTON_CLAIMED = "Réclamé",
        CRAFT_QUEUE_BUTTON_NEXT = "Suivant: ",
        CRAFT_QUEUE_BUTTON_NOTHING_QUEUED = "Rien en file d'attente",
        CRAFT_QUEUE_BUTTON_ORDER = "Commander",
        CRAFT_QUEUE_BUTTON_SUBMIT = "Soumettre",
        CRAFT_QUEUE_IGNORE_ACUITY_RECIPES_CHECKBOX_LABEL = "Ignorer les recettes d'acuité",
        CRAFT_QUEUE_IGNORE_ACUITY_RECIPES_CHECKBOX_TOOLTIP =
            "Ne pas mettre en file d'attente les premières fabrications qui utilisent " ..
            f.bb("Acuité de l'artisan") .. " pour la fabrication",
        CRAFT_QUEUE_AMOUNT_TOOLTIP = "\n\nFabrications en file d'attente: ",
        CRAFT_QUEUE_ORDER_CUSTOMER = "\n\nClient de la commande: ",
        CRAFT_QUEUE_ORDER_MINIMUM_QUALITY = "\nQualité minimale: ",
        CRAFT_QUEUE_ORDER_REWARDS = "\nRécompenses:",

        -- craft buffs

        CRAFT_BUFFS_TITLE = "Buffs de fabrication CraftSim",
        CRAFT_BUFFS_SIMULATE_BUTTON = "Simuler les buffs",
        CRAFT_BUFF_CHEFS_HAT_TOOLTIP = f.bb("Jouet de Wrath of the Lich King.") ..
            "\nNécessite la cuisine de Norfendre\nRéduit la vitesse de fabrication à " .. f.g("0.5 secondes"),

        -- cooldowns module

        COOLDOWNS_TITLE = "Temps de recharge CraftSim",
        CONTROL_PANEL_MODULES_COOLDOWNS_LABEL = "Temps de recharge",
        CONTROL_PANEL_MODULES_COOLDOWNS_TOOLTIP = "Aperçu des " ..
            f.bb("temps de recharge de profession") .. " de votre compte",
        COOLDOWNS_CRAFTER_HEADER = "Artisan",
        COOLDOWNS_RECIPE_HEADER = "Recette",
        COOLDOWNS_CHARGES_HEADER = "Charges",
        COOLDOWNS_NEXT_HEADER = "Prochaine charge",
        COOLDOWNS_ALL_HEADER = "Charges complètes",
        COOLDOWNS_TAB_OVERVIEW = "Aperçu",
        COOLDOWNS_TAB_BLACKLIST = "Blacklist",
        COOLDOWNS_TAB_OPTIONS = "Options",
        COOLDOWNS_EXPANSION_FILTER_BUTTON = "Filtre d'extension",
        COOLDOWNS_RECIPE_LIST_TEXT_TOOLTIP = f.bb(
            "\n\nRecettes partageant ce temps de recharge:\n"),
        COOLDOWNS_RECIPE_READY = f.g("Prêt"),
        COOLDOWNS_ADD_TO_BLACKLIST = "Ajouter à la blacklist",
        COOLDOWNS_BLACKLIST_RESTORE = "Retirer de la blacklist",

        -- concentration module

        CONCENTRATION_TRACKER_TITLE = "Concentration CraftSim",
        CONCENTRATION_TRACKER_LABEL_CRAFTER = "Artisan",
        CONCENTRATION_TRACKER_LABEL_CURRENT = "Actuel",
        CONCENTRATION_TRACKER_LABEL_MAX = "Max",
        CONCENTRATION_TRACKER_MAX = f.g("MAX"),
        CONCENTRATION_TRACKER_MAX_VALUE = "Max: ",
        CONCENTRATION_TRACKER_FULL = f.g("Concentration complète"),
        CONCENTRATION_TRACKER_SORT_MODE_CHARACTER = "Personnage",
        CONCENTRATION_TRACKER_SORT_MODE_CONCENTRATION = "Concentration",
        CONCENTRATION_TRACKER_SORT_MODE_PROFESSION = "Profession",
        CONCENTRATION_TRACKER_FORMAT_MODE_EUROPE_MAX_DATE = "Europe - Date max",
        CONCENTRATION_TRACKER_FORMAT_MODE_AMERICA_MAX_DATE = "Amérique - Date max",
        CONCENTRATION_TRACKER_FORMAT_MODE_HOURS_LEFT = "Heures restantes",

        -- static popups
        STATIC_POPUPS_YES = "Oui",
        STATIC_POPUPS_NO = "Non",

        -- frames
        FRAMES_RESETTING = "réinitialisation de frameID: ",
        FRAMES_WHATS_NEW = "Quoi de neuf dans CraftSim?",
        FRAMES_JOIN_DISCORD = "Rejoignez le Discord!",
        FRAMES_DONATE_KOFI = "Visitez CraftSim sur Kofi",
        FRAMES_NO_INFO = "Pas d'info",

        -- node data
        NODE_DATA_RANK_TEXT = "Rang ",
        NODE_DATA_TOOLTIP = "\n\nStatistiques totales du talent:\n",

        -- columns
        SOURCE_COLUMN_AH = "HV",
        SOURCE_COLUMN_OVERRIDE = "OR",
        SOURCE_COLUMN_WO = "CA",
    }
end
