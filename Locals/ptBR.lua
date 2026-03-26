---@class CraftSim
local CraftSim = select(2, ...)

CraftSim.LOCAL_PT = {}

---@return table<CraftSim.LOCALIZATION_IDS, string>
function CraftSim.LOCAL_PT:GetData()
    local f = CraftSim.GUTIL:GetFormatter()
    local cm = function(i, s) return CraftSim.MEDIA:GetAsTextIcon(i, s) end
    return {
        -- REQUIRED:
        STAT_MULTICRAFT = "Multicriação",
        STAT_RESOURCEFULNESS = "Devolução de recursos",
        STAT_INGENUITY = "Engenhosidade",
        STAT_CRAFTINGSPEED = "Velocidade de criação",
        EQUIP_MATCH_STRING = "Equipado:",
        ENCHANTED_MATCH_STRING = "Encantado:",

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

        PROFESSIONS_BLACKSMITHING = "Ferraria",
        PROFESSIONS_LEATHERWORKING = "Couraria",
        PROFESSIONS_ALCHEMY = "Alquimia",
        PROFESSIONS_HERBALISM = "Herbalismo",
        PROFESSIONS_COOKING = "Cozinheiro",
        PROFESSIONS_MINING = "Mineração",
        PROFESSIONS_TAILORING = "Alfaiataria",
        PROFESSIONS_ENGINEERING = "Engenharia",
        PROFESSIONS_ENCHANTING = "Encantamento",
        PROFESSIONS_FISHING = "Pesca",
        PROFESSIONS_SKINNING = "Esfolamento",
        PROFESSIONS_JEWELCRAFTING = "Joalheria",
        PROFESSIONS_INSCRIPTION = "Escrivania",

        -- Other Statnames

        STAT_SKILL = "Perícia",
        STAT_MULTICRAFT_BONUS = "ItemBônus de Multicriação",
        STAT_RESOURCEFULNESS_BONUS = "ItemBônus de Devolução de Recursos",
        STAT_CRAFTINGSPEED_BONUS = "Velocidade de Criação",
        STAT_INGENUITY_BONUS = "Conc Economizada de Engenhosidade",
        STAT_INGENUITY_LESS_CONCENTRATION = "Menor Uso de Concentração",
        STAT_PHIAL_EXPERIMENTATION = "Descoberta de Frasco",
        STAT_POTION_EXPERIMENTATION = "Descoberta de Poção",

        -- Profit Breakdown Tooltips
        RESOURCEFULNESS_EXPLANATION_TOOLTIP =
        "A Devolução de recursos proca para cada reagente individualmente e então economiza cerca de 30% da quantidade.\n\nO valor médio economizado é o valor médio de TODAS as combinações e suas chances.\n(Procar todos os reagentes ao mesmo tempo é muito improvável, mas economiza bastante).\n\nO custo total médio de reagentes economizados é a soma dos custos economizados de todos os reagentes, ponderados pela chance de proc.",

        RECIPE_DIFFICULTY_EXPLANATION_TOOLTIP =
        "A dificuldade da receita determina quanta perícia é necessária para fabricar a receita em cada nível de qualidade.\n\nPara receitas com cinco níveis de qualidade é 20%, 50%, 80% e 100% da dificuldade da receita como perícia.\nPara receitas com três níveis de qualidade é 50% e 100%",
        MULTICRAFT_EXPLANATION_TOOLTIP =
        "Multicriação dá uma probabilidade de fabricar mais objetos do que uma receita normalmente fabricaria.\n\nA quantidade adicional está entre 1 e 2.5y\nonde y = quantidade normal que uma criação fornece.",
        REAGENTSKILL_EXPLANATION_TOOLTIP =
        "A qualidade dos seus reagentes podem dar até um máximo de 40% de perícia adicional da receita base.\n\nTodos os Reagentes de Q1: 0% Bônus\nTodos os Reagentes de Q2: 20% Bônus\nTodos os Reagentes de Q3: 40% Bônus\n\nA habilidade é calculada pela quantidade de reagentes de cada qualidade, ponderada de acordo com sua qualidade \ne um valor de peso específico que é único para cada item de reagente de criação com qualidade.\n\nNo entanto, é diferente quando se trata de Recraft (Recriação). No Recraft, o máximo que os reagentes podem aumentar a qualidade\ndepende da qualidade dos reagentes com os quais o item foi originalmente criado.\nO funcionamento exato disso, é desconhecido.\nTodavia, o CraftSim compara, internamente, a perícia alcançada com todos os de qualidade 3 (Q3) e calcula\no aumento máximo de perícia com base nisso.",
        REAGENTFACTOR_EXPLANATION_TOOLTIP =
        "O máximo que os reagentes podem contribuir para uma receita é, na maioria das vezes, 40% da dificuldade base da receita.\n\nMas, no caso de Recraft (Recriação), esse valor pode variar com base nas criações anteriores\n e na qualidade dos reagentes que foram utilizados.",

        -- Simulation Mode
        SIMULATION_MODE_NONE = "Nenhum",
        SIMULATION_MODE_LABEL = "Modo Simulação",
        SIMULATION_MODE_TITLE = "Modo de Simulação CraftSim",
        SIMULATION_MODE_TOOLTIP =
        "O Modo de Simulação CraftSim torna possível testar combinações de uma receita sem restrições",
        SIMULATION_MODE_OPTIONAL = "Opcional #",
        SIMULATION_MODE_FINISHING = "Finalizante #",
        SIMULATION_MODE_QUALITY_BUTTON_TOOLTIP = "Maximizar Todos Reagentes de Qualidade ",
        SIMULATION_MODE_CLEAR_BUTTON = "Limpar",
        SIMULATION_MODE_CONCENTRATION = " Concentração",
        SIMULATION_MODE_CONCENTRATION_COST = "Custo de Concentração: ",
        CONCENTRATION_ESTIMATED_TIME_UNTIL = "Fabricável às: %s",

        -- Details Frame
        RECIPE_DIFFICULTY_LABEL = "Dificuldade da receita: ",
        MULTICRAFT_LABEL = "Multicriação: ",
        RESOURCEFULNESS_LABEL = "Devolução de recursos: ",
        RESOURCEFULNESS_BONUS_LABEL = "Bonus de item de Devolução de recursos: ",
        CONCENTRATION_LABEL = "Concentração: ",
        REAGENT_QUALITY_BONUS_LABEL = "Bonus de qualidade do Reagente: ",
        REAGENT_QUALITY_MAXIMUM_LABEL = "Qualidade Máxima do Reagente %: ",
        EXPECTED_QUALITY_LABEL = "Qualidade Esperada: ",
        NEXT_QUALITY_LABEL = "Próxima Qualidade: ",
        MISSING_SKILL_LABEL = "Perícia faltante: ",
        SKILL_LABEL = "Perícia: ",
        MULTICRAFT_BONUS_LABEL = "Bonus de item de Multicriação: ",

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
        POPUP_NO_PRICE_SOURCE_SYSTEM = "Nenhuma fonte de preços suportada disponível",
        POPUP_NO_PRICE_SOURCE_TITLE = "Aviso de fonte de preço CraftSim",
        POPUP_NO_PRICE_SOURCE_WARNING =
        "Nenhuma fonte de preço encontrada!\n\nVocê precisa instalar ao menos um dos\naddons de fonte de preços a seguir para\nutilizar os cálculos de lucro do CraftSim:\n\n\n",
        POPUP_NO_PRICE_SOURCE_WARNING_SUPPRESS = "Não exibir aviso novamente",
        POPUP_NO_PRICE_SOURCE_WARNING_ACCEPT = "OK",

        -- Reagents Frame
        REAGENT_OPTIMIZATION_TITLE = "Otimização de Reagentes CraftSim",
        REAGENTS_REACHABLE_QUALITY = "Qualidade Alcançável: ",
        REAGENTS_MISSING = "Reagentes faltantes",
        REAGENTS_AVAILABLE = "Reagentes disponíveis",
        REAGENTS_CHEAPER = "Reagentes mais baratos",
        REAGENTS_BEST_COMBINATION = "Melhor combinação atribuída",
        REAGENTS_NO_COMBINATION = "Nenhuma combinação encontrada \npara melhorar a qualidade",
        REAGENTS_ASSIGN = "Atribuir",
        REAGENTS_MAXIMUM_QUALITY = "Qualidade Máxima: ",
        REAGENTS_AVERAGE_PROFIT_LABEL = "Lucro Ø Médio: ",
        REAGENTS_AVERAGE_PROFIT_TOOLTIP =
            f.bb("O Lucro Médio por Criação") .. " quando utilizando " .. f.l("esta distribuição de reagentes"),
        REAGENTS_OPTIMIZE_BEST_ASSIGNED = "Melhores Reagentes Atribuídos",
        REAGENTS_CONCENTRATION_LABEL = "Concentração: ",
        REAGENTS_OPTIMIZE_INFO = "Shift + BEM nos números para linkar o item no chat",
        ADVANCED_OPTIMIZATION_BUTTON = "Otimização Avançada",
        REAGENTS_OPTIMIZE_TOOLTIP =
            "(Reseta ao Editar)\nHabilita " ..
            f.gold("Valor de Concentração") .. " e " .. f.bb("Reagentes de Finalização ") .. " Otimização",

        -- Specialization Info Frame
        SPEC_INFO_TITLE = "Informações de Especialização CraftSim",
        SPEC_INFO_SIMULATE_KNOWLEDGE_DISTRIBUTION = "Simular Distribuição de Conhecimento",
        SPEC_INFO_NODE_TOOLTIP = "Este nó lhe concede os seguintes atributos para esta receita:",
        SPEC_INFO_WORK_IN_PROGRESS = "Dados Não Disponíveis",

        -- Crafting Results Frame
        CRAFT_LOG_TITLE = "Resultados de Criação CraftSim",
        CRAFT_LOG_LOG = "Registro de Criação",
        CRAFT_LOG_LOG_1 = "Lucro: ",
        CRAFT_LOG_LOG_2 = "Inspirado!",
        CRAFT_LOG_LOG_3 = "Multicriação: ",
        CRAFT_LOG_LOG_4 = "Recursos Salvos!: ",
        CRAFT_LOG_LOG_5 = "Probabilidade: ",
        CRAFT_LOG_CRAFTED_ITEMS = "Itens Criados",
        CRAFT_LOG_SESSION_PROFIT = "Lucro da Sessão",
        CRAFT_LOG_RESET_DATA = "Resetar Dados",
        CRAFT_LOG_EXPORT_JSON = "Exportar JSON",
        CRAFT_LOG_RECIPE_STATISTICS = "Estatísticas da Receita",
        CRAFT_LOG_NOTHING = "Nada criado ainda!",
        CRAFT_LOG_CALCULATION_COMPARISON_NUM_CRAFTS_PREFIX = "Criações: ",
        CRAFT_LOG_STATISTICS_2 = "Lucro Ø Estimado: ",
        CRAFT_LOG_STATISTICS_3 = "Lucro Ø Real: ",
        CRAFT_LOG_STATISTICS_4 = "Lucro Real: ",
        CRAFT_LOG_STATISTICS_5 = "Procs - Real / Estimado: ",
        CRAFT_LOG_STATISTICS_7 = "Multicriação: ",
        CRAFT_LOG_STATISTICS_8 = "- Ø Itens Extras: ",
        CRAFT_LOG_STATISTICS_9 = "Procs de Devolução de Recursos: ",
        CRAFT_LOG_CALCULATION_COMPARISON_NUM_CRAFTS_PREFIX0 = "- Ø Economia: ",
        CRAFT_LOG_CALCULATION_COMPARISON_NUM_CRAFTS_PREFIX1 = "Lucro: ",
        CRAFT_LOG_SAVED_REAGENTS = "Reagentes Economizados",
        CRAFT_LOG_RESULT_ANALYSIS_TAB_DISTRIBUTION_LABEL = "Distribuição dos Resultados",
        CRAFT_LOG_RESULT_ANALYSIS_TAB_DISTRIBUTION_HELP =
        "Distribuição relativa dos resultados de itens criados.\n(Ignorando Quantidades de Multicriação)",
        CRAFT_LOG_RESULT_ANALYSIS_TAB_MULTICRAFT = "Multicriação",
        CRAFT_LOG_RESULT_ANALYSIS_TAB_RESOURCEFULNESS = "Devolução de Recursos",
        CRAFT_LOG_RESULT_ANALYSIS_TAB_YIELD_DDISTRIBUTION = "Distribuição do Rendimento",

        -- Stats Weight Frame
        STAT_WEIGHTS_TITLE = "Lucro Médio do CraftSim",
        EXPLANATIONS_TITLE = "Explicação do Lucro Médio do CraftSim",
        STAT_WEIGHTS_SHOW_EXPLANATION_BUTTON = "Exibir Explicação",
        STAT_WEIGHTS_HIDE_EXPLANATION_BUTTON = "Esconder Explicação",
        STAT_WEIGHTS_SHOW_STATISTICS_BUTTON = "Exibir Estatísticas",
        STAT_WEIGHTS_HIDE_STATISTICS_BUTTON = "Esconder Estatísticas",
        STAT_WEIGHTS_PROFIT_CRAFT = "Ø Lucro / de Criação: ",
        EXPLANATIONS_BASIC_PROFIT_TAB = "Cálculo Básico de Lucro",

        -- Cost Details Frame
        COST_OPTIMIZATION_TITLE = "Otimização de Custo do CraftSim",
        COST_OPTIMIZATION_EXPLANATION =
            "Aqui você tem uma visão geral de todos os valores possíveis dos reagentes utilizados.\nA " ..
            f.bb("'Fonte Utilizada'") ..
            " coluna indica quais dos valores é utilizado.\n\n" ..
            f.g("AH") ..
            " .. Preço na Casa de Leilão\n" ..
            f.l("OU") ..
            " .. Troca de Valor\n" ..
            f.bb("Qualquer Nome") ..
            " .. Estimativa de Custo por craftar por si próprio\n" ..
            f.l("OR") ..
            " sempre será usado se definido. " ..
            f.bb("Custos de Criação") .. " só será usado se menor que " .. f.g("AH"),
        COST_OPTIMIZATION_CRAFTING_COSTS = "Custos de Criação: ",
        COST_OPTIMIZATION_ITEM_HEADER = "Item",
        COST_OPTIMIZATION_AH_PRICE_HEADER = "Preço na AH",
        COST_OPTIMIZATION_OVERRIDE_HEADER = "Personalizar",
        COST_OPTIMIZATION_CRAFTING_HEADER = "Criação",
        COST_OPTIMIZATION_USED_SOURCE = "Fonte Utilizada",
        COST_OPTIMIZATION_REAGENT_COSTS_TAB = "Custos dos Reagentes",
        COST_OPTIMIZATION_SUB_RECIPE_OPTIONS_TAB = "Opções de Sub-Receitas",
        COST_OPTIMIZATION_SUB_RECIPE_OPTIMIZATION = "Otimização de Sub-Receitas " ..
            f.bb("(experimental)"),
        COST_OPTIMIZATION_SUB_RECIPE_OPTIMIZATION_TOOLTIP = "Se habilitado " ..
            f.l("CraftSim") .. " considera o " .. f.g("custo de criação otimizado") ..
            " do seu personagem e de seus alts\nse eles podem criar aquele item.\n\n" ..
            f.r("Pode reduzir a performance um pouco devido a múltiplos cálculos adicionais"),
        COST_OPTIMIZATION_SUB_RECIPE_MAX_DEPTH_LABEL = "Detalhamento do Cálculo da Sub-receita",
        COST_OPTIMIZATION_SUB_RECIPE_INCLUDE_CONCENTRATION = "Habilitar Concentração",
        COST_OPTIMIZATION_SUB_RECIPE_INCLUDE_CONCENTRATION_TOOLTIP = "Se habilitado, " ..
            f.l("CraftSim") .. "vai incluir a qualidade dos reagentes mesmo se a concentração seja necessária.",
        COST_OPTIMIZATION_SUB_RECIPE_INCLUDE_COOLDOWN_RECIPES = "Incluir Recarga de Receitas",
        COST_OPTIMIZATION_SUB_RECIPE_INCLUDE_COOLDOWN_RECIPES_TOOLTIP = "Se habilitado, " ..
            f.l("CraftSim") ..
            " desconsiderará os requisitos de recarga receitas ao calcular reagentes criados por si próprio",
        COST_OPTIMIZATION_SUB_RECIPE_SELECT_RECIPE_CRAFTER = "Selecione Criador de Receitas",
        COST_OPTIMIZATION_REAGENT_LIST_AH_COLUMN_AUCTION_BUYOUT = "Arremate da AH: ",
        COST_OPTIMIZATION_REAGENT_LIST_OVERRIDE = "\n\nPersonalizar",
        COST_OPTIMIZATION_REAGENT_LIST_EXPECTED_COSTS_TOOLTIP = "\n\nCriando ",
        COST_OPTIMIZATION_REAGENT_LIST_EXPECTED_COSTS_PRE_ITEM = "\n- Custo Estimado por Item: ",
        COST_OPTIMIZATION_REAGENT_LIST_CONCENTRATION_COST = f.gold("Custo de Concentração: "),
        COST_OPTIMIZATION_REAGENT_LIST_CONCENTRATION = "Concentração: ",

        -- Statistics Frame
        STATISTICS_TITLE = "Estatísticas do CraftSim",
        STATISTICS_EXPECTED_PROFIT = "Lucro Estimado (μ)",
        STATISTICS_CHANCE_OF = "Probabilidade de ",
        STATISTICS_PROFIT = "Lucro",
        STATISTICS_AFTER = " depois",
        STATISTICS_CRAFTS = "Criações: ",
        STATISTICS_QUALITY_HEADER = "Qualidade",
        STATISTICS_MULTICRAFT_HEADER = "Multicriação",
        STATISTICS_RESOURCEFULNESS_HEADER = "Devolução de Recursos",
        STATISTICS_EXPECTED_PROFIT_HEADER = "Lucro Estimado",
        PROBABILITY_TABLE_TITLE = "Tabela de Probabilidade de Receita",
        STATISTICS_PROBABILITY_TABLE_TAB = "Tabela de Probabilidade",
        STATISTICS_CONCENTRATION_TAB = "Concentração",
        STATISTICS_CONCENTRATION_CURVE_GRAPH = "Curva de Custo de Concentração",
        STATISTICS_CONCENTRATION_CURVE_GRAPH_HELP =
            "Custo de concentração baseado na perícia do personagem para determinada receita\n" ..
            f.bb("X Axis: ") .. " Perícia do Personagem\n" ..
            f.bb("Y Axis: ") .. " Custo de Concentração",

        -- Price Details Frame
        COST_OVERVIEW_TITLE = "Detalhes dos Preços Craftsim",
        PRICE_DETAILS_INV_AH = "Inv/AH",
        PRICE_DETAILS_ITEM = "Item",
        PRICE_DETAILS_PRICE_ITEM = "Preço/Item",
        PRICE_DETAILS_PROFIT_ITEM = "Lucro/Item",

        -- Price Override Frame
        PRICE_OVERRIDE_TITLE = "Personalizar Custo CraftSim",
        PRICE_OVERRIDE_REQUIRED_REAGENTS = "Reagentes Necessários",
        PRICE_OVERRIDE_OPTIONAL_REAGENTS = "Reagentes Opcionais",
        PRICE_OVERRIDE_FINISHING_REAGENTS = "Reagentes de Finalização",
        PRICE_OVERRIDE_RESULT_ITEMS = "Resultado dos Itens",
        PRICE_OVERRIDE_ACTIVE_OVERRIDES = "Personalizações Ativas",
        PRICE_OVERRIDE_ACTIVE_OVERRIDES_TOOLTIP =
        "'(como resultado)' -> personalização de preço considerada apenas quando o item é resultado de uma receita",
        PRICE_OVERRIDE_CLEAR_ALL = "Limpar Tudo",
        PRICE_OVERRIDE_SAVE = "Salvar",
        PRICE_OVERRIDE_SAVED = "Salvo",
        PRICE_OVERRIDE_REMOVE = "Remover",

        -- Recipe Scan Frame
        RECIPE_SCAN_TITLE = "Scan de Receitas CraftSim",
        RECIPE_SCAN_MODE = "Modo Scan",
        RECIPE_SCAN_SORT_MODE = "Modo Classificar",
        RECIPE_SCAN_SCAN_RECIPIES = "Escanear Receitas",
        RECIPE_SCAN_SCAN_CANCEL = "Cancelar",
        RECIPE_SCAN_SCANNING = "Verificando",
        RECIPE_SCAN_INCLUDE_NOT_LEARNED = "Incluir Não Aprendidas",
        RECIPE_SCAN_INCLUDE_NOT_LEARNED_TOOLTIP =
        "Inclui receitas que você ainda não aprendeu na verificação",
        RECIPE_SCAN_INCLUDE_SOULBOUND = "Incluir Vinculadas",
        RECIPE_SCAN_INCLUDE_SOULBOUND_TOOLTIP =
        "Inclui receitas vinculadas na verificação.\n\nRecomenda-se definir uma troca de preço (por exemplo, para simular uma comissão desejada)\nno Módulo de Troca de Preço para os itens criados dessa receita",
        RECIPE_SCAN_INCLUDE_GEAR = "Incluir Equipamento",
        RECIPE_SCAN_INCLUDE_GEAR_TOOLTIP =
        "Inclui todos os tipos de equipamentos de profissão na verificação",
        RECIPE_SCAN_OPTIMIZE_TOOLS = "Otimizar Ferramentas de Profissão",
        RECIPE_SCAN_OPTIMIZE_TOOLS_TOOLTIP =
        "Otimiza suas ferramentas de profissão para obter maior lucro em cada receita\n\n",
        RECIPE_SCAN_OPTIMIZE_TOOLS_WARNING =
        "Pode reduzir performance durante a verificação\nse você tiver muitas ferramentas no inventário",
        RECIPE_SCAN_CRAFTER_HEADER = "Personagem",
        RECIPE_SCAN_RECIPE_HEADER = "Receita",
        RECIPE_SCAN_LEARNED_HEADER = "Aprendido",
        RECIPE_SCAN_RESULT_HEADER = "Resultado",
        RECIPE_SCAN_AVERAGE_PROFIT_HEADER = "Lucro Médio",
        RECIPE_SCAN_CONCENTRATION_VALUE_HEADER = "Valor C.",
        RECIPE_SCAN_CONCENTRATION_COST_HEADER = "Custo C.",
        RECIPE_SCAN_TOP_GEAR_HEADER = "Top Gear",
        RECIPE_SCAN_INV_AH_HEADER = "Inv/AH",
        RECIPE_SCAN_SORT_BY_MARGIN = "Classificar por lucro %",
        RECIPE_SCAN_SORT_BY_MARGIN_TOOLTIP =
        "Classifica a lista de lucros por lucro relativo aos custos de criação.\n(Requer um novo Scan)",
        RECIPE_SCAN_USE_INSIGHT_CHECKBOX = "Usar " .. f.bb("Percepção") .. " se possível",
        RECIPE_SCAN_USE_INSIGHT_CHECKBOX_TOOLTIP = "Usar " ..
            f.bb("Percepção Ilustre") ..
            " or\n" .. f.bb("Percepção Ilustre Inferior") .. " como reagente opcional para receitas que permitam.",
        RECIPE_SCAN_ONLY_FAVORITES_CHECKBOX = "Somente Favoritos",
        RECIPE_SCAN_ONLY_FAVORITES_CHECKBOX_TOOLTIP = "Verifica apenas receitas favoritas",
        RECIPE_SCAN_EQUIPPED = "Equipado",
        RECIPE_SCAN_MODE_OPTIMIZE = "Otimizar",
        RECIPE_SCAN_SORT_MODE_PROFIT = "Lucro",
        RECIPE_SCAN_SORT_MODE_RELATIVE_PROFIT = "Lucro Relativo",
        RECIPE_SCAN_SORT_MODE_CONCENTRATION_VALUE = "Valor de Concentração",
        RECIPE_SCAN_SORT_MODE_CONCENTRATION_COST = "Custo de Concentração",
        RECIPE_SCAN_EXPANSION_FILTER_BUTTON = "Filtrar Expansão",
        RECIPE_SCAN_ALTPROFESSIONS_FILTER_BUTTON = "Profissões dos Alts",
        RECIPE_SCAN_SCAN_ALL_BUTTON_READY = "Escanear Profissões",
        RECIPE_SCAN_SCAN_ALL_BUTTON_SCANNING = "Verificando...",
        RECIPE_SCAN_TAB_LABEL_SCAN = "Escanear Receitas",
        RECIPE_SCAN_TAB_LABEL_OPTIONS = "Opções de Escaneamento",
        RECIPE_SCAN_IMPORT_ALL_PROFESSIONS_CHECKBOX_LABEL = "Todas as Profissões Escaneadas",
        RECIPE_SCAN_IMPORT_ALL_PROFESSIONS_CHECKBOX_TOOLTIP = f.g("True: ") ..
            "Importa Resultados Escaneados de todas as profissões ativadas e escaneadas\n\n" ..
            f.r("False: ") .. "Importa Resultados somente da Profissão selecionada",
        RECIPE_SCAN_CACHED_RECIPES_TOOLTIP =
            "Sempre que você abrir ou escanear uma receita em um personagem, " ..
            f.l("CraftSim") ..
            " vai memorizar ela.\n\nSomente as receitas dos seus alts que " ..
            f.l("CraftSim") .. " pode memorizar serão escaneadas com " .. f.bb("RecipeScan\n\n") ..
            "A quantidade real de receitas escaneadas é baseada nas " .. f.e("Opções de Escaneamento de Receitas"),
        RECIPE_SCAN_CONCENTRATION_TOGGLE = " Concentração",
        RECIPE_SCAN_CONCENTRATION_TOGGLE_TOOLTIP = "Ativar Concentração",
        RECIPE_SCAN_OPTIMIZE_SUBRECIPES = "Otimizar Sub-Receitas " .. f.bb("(experimental)"),
        RECIPE_SCAN_OPTIMIZE_SUBRECIPES_TOOLTIP = "Se ativado, " ..
            f.l("CraftSim") ..
            " também otimiza a criação de receitas de reagentes armazenadas em cache de receitas escaneadas e utiliza seus\n" ..
            f.bb("custos estimados") .. " para calcular os custos de criação do produto final.\n\n" ..
            f.r("Aviso: Isso pode reduzir o desempenho da verificação"),
        RECIPE_SCAN_CACHED_RECIPES = "Receitas em Cache: ",
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
        RECIPE_SCAN_AUTOSELECT_OPEN_PROFESSION = "Autoselect Open Profession",

        -- Recipe Top Gear
        TOP_GEAR_TITLE = "Top Gear CraftSim",
        TOP_GEAR_AUTOMATIC = "Automático",
        TOP_GEAR_AUTOMATIC_TOOLTIP =
        "Simula automaticamente o Melhor Equipamento para o modo selecionado sempre que uma receita for atualizada.\n\nDesativar essa opção pode melhorar o desempenho.",
        TOP_GEAR_SIMULATE = "Simular Top Gear",
        TOP_GEAR_EQUIP = "Equipar",
        TOP_GEAR_SIMULATE_QUALITY = "Qualidade: ",
        TOP_GEAR_SIMULATE_EQUIPPED = "Top Gear equipado",
        TOP_GEAR_SIMULATE_PROFIT_DIFFERENCE = "Ø Diferença de Lucro\n",
        TOP_GEAR_SIMULATE_NEW_MUTLICRAFT = "Nova Multicriação\n",
        TOP_GEAR_SIMULATE_NEW_CRAFTING_SPEED = "Nova Velocidade de Criação\n",
        TOP_GEAR_SIMULATE_NEW_RESOURCEFULNESS = "Nova Devolução de Recursos\n",
        TOP_GEAR_SIMULATE_NEW_SKILL = "Nova Perícia\n",
        TOP_GEAR_SIMULATE_UNHANDLED = "Modo Simulação Não Gerenciado",

        TOP_GEAR_SIM_MODES_PROFIT = "Melhor Lucro",
        TOP_GEAR_SIM_MODES_SKILL = "Melhor Perícia",
        TOP_GEAR_SIM_MODES_MULTICRAFT = "Melhor Multicriação",
        TOP_GEAR_SIM_MODES_RESOURCEFULNESS = "Melhor Devolução de Recursos",
        TOP_GEAR_SIM_MODES_CRAFTING_SPEED = "Melhor Velocidade de Criação",

        -- Options
        OPTIONS_TITLE = "Opções CraftSim",
        OPTIONS_GENERAL_TAB = "Geral",
        OPTIONS_GENERAL_PRICE_SOURCE = "Fonte de Preço",
        OPTIONS_GENERAL_CURRENT_PRICE_SOURCE = "Fonte Atual de Preços: ",
        OPTIONS_GENERAL_NO_PRICE_SOURCE = "Nenhum Addon Compatível de Fonte de Preços Carregado!",
        OPTIONS_GENERAL_SHOW_PROFIT = "Exibir Porcentagem de Lucro",
        OPTIONS_GENERAL_SHOW_PROFIT_TOOLTIP =
        "Exibe a porcentagem de lucro para custos de criação sem considerar o valor em ouro",
        OPTIONS_GENERAL_REMEMBER_LAST_RECIPE = "Lembrar Última Receita Selecionada",
        OPTIONS_GENERAL_REMEMBER_LAST_RECIPE_TOOLTIP =
        "Relembrar a última receita selecionada quando abrir a janela de criação",
        OPTIONS_GENERAL_SUPPORTED_PRICE_SOURCES = "Fontes de Preços Compatíveis:",
        OPTIONS_PERFORMANCE_RAM = "Habilita a limpeza de memória RAM durante a criação",
        OPTIONS_PERFORMANCE_RAM_CRAFTS = "Criações",
        OPTIONS_PERFORMANCE_RAM_TOOLTIP =
        "Quando habilitado, o CraftSim limpará a memória RAM a cada número especificado de criações, removendo dados não utilizados para evitar o acúmulo de memória.\nO acúmulo de memória também pode ocorrer devido a outros addons e que não é específico do CraftSim.\nUma limpeza afetará todo o uso de RAM do WoW.",
        OPTIONS_MODULES_TAB = "Módulos",
        OPTIONS_PROFIT_CALCULATION_TAB = "Cálculo de Lucro",
        OPTIONS_CRAFTING_TAB = "Criação",
        OPTIONS_TSM_RESET = "Redefinir Padrão",
        OPTIONS_TSM_INVALID_EXPRESSION = "Expressão Inválida",
        OPTIONS_TSM_VALID_EXPRESSION = "Expressão Válida",
        OPTIONS_MODULES_REAGENT_OPTIMIZATION = "Módulo de Otimização de Reagentes",
        OPTIONS_MODULES_AVERAGE_PROFIT = "Módulo de Lucro Médio",
        OPTIONS_MODULES_TOP_GEAR = "Módulo Top Gear",
        OPTIONS_MODULES_COST_OVERVIEW = "Módulo de Visão Geral de Custo",
        OPTIONS_MODULES_SPECIALIZATION_INFO = "Módulo de Informações de Especialização",
        OPTIONS_MODULES_CUSTOMER_HISTORY_SIZE = "Número Máximo de Mensagens por Cliente",
        OPTIONS_MODULES_CUSTOMER_HISTORY_MAX_ENTRIES_PER_CLIENT =
        "Máximo de Entradas de Histórico por Cliente",
        OPTIONS_PROFIT_CALCULATION_OFFSET = "Ajustar limites críticos de pontos de perícia em 1",
        OPTIONS_PROFIT_CALCULATION_OFFSET_TOOLTIP =
        "A sugestão de combinação de reagentes tentará alcançar o ponto crítico + 1 em vez de corresponder exatamente à perícia exigida",
        OPTIONS_PROFIT_CALCULATION_MULTICRAFT_CONSTANT = "Constante de Multicriação",
        OPTIONS_PROFIT_CALCULATION_MULTICRAFT_CONSTANT_EXPLANATION =
        "Padrão: 2,5\n\nDados de Criação de diferentes jogadores que coletaram dados no beta e no início do Dragonflight sugerem que\no máximo de itens extras que alguém pode receber de um processo multicriacão é 1+C*y.\nOnde y é a quantidade base de itens para um criação e C é 2,5.\nNo entanto, se desejar, você pode modificar este valor aqui.",
        OPTIONS_PROFIT_CALCULATION_RESOURCEFULNESS_CONSTANT = "Constante de Devolução de Recursos",
        OPTIONS_PROFIT_CALCULATION_RESOURCEFULNESS_CONSTANT_EXPLANATION =
        "Padrão: 0,3\n\nDados de Criação de diferentes jogadores que coletaram dados no beta e no início da Revoada Dracônica sugerem que\na quantidade média de itens salvos é 30% da quantidade necessária.\nNo entanto, se desejar, você pode modificar esse valor aqui.",
        OPTIONS_GENERAL_SHOW_NEWS_CHECKBOX = "Exibir Janela de " .. f.bb("Novidades"),
        OPTIONS_GENERAL_SHOW_NEWS_CHECKBOX_TOOLTIP = "Exibe a janela de " ..
            f.bb("Novidades") .. " das novas atualizações do " .. f.l("CraftSim") .. " quando entrar no jogo",
        OPTIONS_GENERAL_HIDE_MINIMAP_BUTTON_CHECKBOX = "Esconder Botão do Minimapa",
        OPTIONS_GENERAL_HIDE_MINIMAP_BUTTON_TOOLTIP = "Habilite para Esconder o Botão do " ..
            f.l("CraftSim") .. " do Minimapa",
        OPTIONS_GENERAL_COIN_MONEY_FORMAT_CHECKBOX = "Utilizar Texturas de Moedas: ",
        OPTIONS_GENERAL_COIN_MONEY_FORMAT_TOOLTIP =
        "Utiliza ícones de moedas para formatar dinheiro",

        -- Control Panel
        CONTROL_PANEL_MODULES_CRAFT_QUEUE_LABEL = "Fila de Crafts",
        CONTROL_PANEL_MODULES_CRAFT_QUEUE_TOOLTIP =
        "Enfileire e fabrique todas as suas receitas em um só lugar!",
        CONTROL_PANEL_MODULES_TOP_GEAR_LABEL = "Top Gear",
        CONTROL_PANEL_MODULES_TOP_GEAR_TOOLTIP =
        "Exibe a melhor combinação disponível de equipamento de profissão com base no modo selecionado",
        CONTROL_PANEL_MODULES_COST_OVERVIEW_LABEL = "Detalhes dos Preços",
        CONTROL_PANEL_MODULES_COST_OVERVIEW_TOOLTIP =
        "Exibe uma visão geral do preço de venda e do lucro com base na qualidade do item resultante",
        CONTROL_PANEL_MODULES_AVERAGE_PROFIT_LABEL = "Lucro Médio",
        CONTROL_PANEL_MODULES_AVERAGE_PROFIT_TOOLTIP =
        "Exibe o lucro médio com base nas estatísticas da sua profissão e os pesos das estatísticas de lucro como ouro por ponto.",
        CONTROL_PANEL_MODULES_REAGENT_OPTIMIZATION_LABEL = "Otimização de Reagentes",
        CONTROL_PANEL_MODULES_REAGENT_OPTIMIZATION_TOOLTIP =
        "Sugere os reagentes mais baratos para atingir os limites de qualidade específicos.",
        CONTROL_PANEL_MODULES_PRICE_OVERRIDES_LABEL = "Personalizar Custo",
        CONTROL_PANEL_MODULES_PRICE_OVERRIDES_TOOLTIP =
        "Personaliza preços de quaisquer reagentes e resultados de criação, para todas as receitas ou para uma receita específica.",
        CONTROL_PANEL_MODULES_SPECIALIZATION_INFO_LABEL = "Info de Especialização",
        CONTROL_PANEL_MODULES_SPECIALIZATION_INFO_TOOLTIP =
        "Exibe como suas especializações de profissão afetam essa receita e permite simular qualquer configuração!",
        CONTROL_PANEL_MODULES_CRAFT_LOG_LABEL = "Resultados das Criações",
        CONTROL_PANEL_MODULES_CRAFT_LOG_TOOLTIP =
        "Exibe um registro de criações e estatísticas sobre suas criações!",
        CONTROL_PANEL_MODULES_COST_OPTIMIZATION_LABEL = "Otimização de Custo",
        CONTROL_PANEL_MODULES_COST_OPTIMIZATION_TOOLTIP =
        "Módulo que exibe informações detalhadas e auxilia na otimização dos custos de criação.",
        CONTROL_PANEL_MODULES_STATISTICS_LABEL = "Estatísticas",
        CONTROL_PANEL_MODULES_STATISTICS_TOOLTIP =
        "Módulo que exibe informações detalhadas e auxilia na otimização dos custos de criação",
        CONTROL_PANEL_MODULES_RECIPE_SCAN_LABEL = "Scan de Receitas",
        CONTROL_PANEL_MODULES_RECIPE_SCAN_TOOLTIP =
        "Módulo que analisa sua lista de receitas com base em várias opções",
        CONTROL_PANEL_MODULES_CUSTOMER_HISTORY_LABEL = "Histórico de Clientes",
        CONTROL_PANEL_MODULES_CUSTOMER_HISTORY_TOOLTIP =
        "Módulo que fornece um histórico de conversas com clientes, itens confeccionados e comissões.",
        CONTROL_PANEL_MODULES_CRAFT_BUFFS_LABEL = "Buffs de Criação",
        CONTROL_PANEL_MODULES_CRAFT_BUFFS_TOOLTIP =
        "Módulo que exibe seus Buffs de Criação ativos e faltantes.",
        CONTROL_PANEL_MODULES_EXPLANATIONS_LABEL = "DescriçÕes",
        CONTROL_PANEL_MODULES_EXPLANATIONS_TOOLTIP =
            "Módulo que explana como o" .. f.l(" CraftSim") .. " calcula as coisas",
        CONTROL_PANEL_RESET_FRAMES = "Redefinir Janelas",
        CONTROL_PANEL_OPTIONS = "Ajustes",
        CONTROL_PANEL_NEWS = "Novidades",
        CONTROL_PANEL_EASYCRAFT_EXPORT = " Exportar" .. f.l("Easycraft"),
        CONTROL_PANEL_EASYCRAFT_EXPORTING = "Exportando",
        CONTROL_PANEL_EASYCRAFT_EXPORT_NO_RECIPE_FOUND =
        "Nenhuma receita para exportar para a expansão The War Within",
        CONTROL_PANEL_FORGEFINDER_EXPORT = " Exportar" .. f.l("ForgeFinder"),
        CONTROL_PANEL_FORGEFINDER_EXPORTING = "Exportando",
        CONTROL_PANEL_EXPORT_EXPLANATION = f.l("wowforgefinder.com") ..
            " e " .. f.l("easycraft.io") ..
            "\nsão sites para buscar e oferecer " .. f.bb("Ordens de Serviço do WoW"),
        CONTROL_PANEL_DEBUG = "Debugar",
        CONTROL_PANEL_TITLE = "Painel de Controle",
        CONTROL_PANEL_SUPPORTERS_BUTTON = f.patreon("Apoiadores"),

        -- Supporters
        SUPPORTERS_DESCRIPTION = f.l("Obrigado a todas essas pessoas incríveis!"),
        SUPPORTERS_DESCRIPTION_2 = f.l(
            "Quer apoiar o CraftSim e também ser listado aqui com sua mensagem?\nConsidere juntar-se à Comunidade!"),
        SUPPORTERS_DATE = "Data",
        SUPPORTERS_SUPPORTER = "Apoiador",
        SUPPORTERS_MESSAGE = "Mensagem",

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
        CUSTOMER_HISTORY_DELETE_CUSTOMER_CONFIRMATION_POPUP =
        "Are you sure you want to delete\nall data for %s?",
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


        -- Craft Queue
        CRAFT_QUEUE_TITLE = "Fila de Crafts CraftSim",
        CRAFT_QUEUE_CRAFT_AMOUNT_LEFT_HEADER = "Enfileirado",
        CRAFT_QUEUE_CRAFT_PROFESSION_GEAR_HEADER = "Equipamento de Profissão",
        CRAFT_QUEUE_CRAFTING_COSTS_HEADER = "Custos de Criação",
        CRAFT_QUEUE_CRAFT_BUTTON_ROW_LABEL = "Criar",
        CRAFT_QUEUE_CRAFT_BUTTON_ROW_LABEL_WRONG_GEAR = "Ferramentas Incorretas",
        CRAFT_QUEUE_CRAFT_BUTTON_ROW_LABEL_NO_REAGENTS = "Nenhum Reagente",
        CRAFT_QUEUE_ADD_OPEN_RECIPE_BUTTON_LABEL = "Enfileirar Receita Aberta",
        CRAFT_QUEUE_ADD_FIRST_CRAFTS_BUTTON_LABEL = "Enfileirar Primeiros Crafts",
        CRAFT_QUEUE_ADD_WORK_ORDERS_BUTTON_LABEL = "Enfileirar Ordens de Clientes",
        CRAFT_QUEUE_ADD_WORK_ORDERS_ALLOW_CONCENTRATION_CHECKBOX = "Permitir Concentração",
        CRAFT_QUEUE_ADD_WORK_ORDERS_ALLOW_CONCENTRATION_TOOLTIP =
            "Se a qualidade mínima não puder ser alcançada, use " .. f.l("Concentração") .. " se possível",
        CRAFT_QUEUE_CLEAR_ALL_BUTTON_LABEL = "Limpar Fila",
        CRAFT_QUEUE_RESTOCK_FAVORITES_BUTTON_LABEL = "Enfileirar Favoritos",
        CRAFT_QUEUE_CRAFT_BUTTON_ROW_LABEL_WRONG_PROFESSION = "Profissão Incorreta",
        CRAFT_QUEUE_CRAFT_BUTTON_ROW_LABEL_ON_COOLDOWN = "Em Recarga",
        CRAFT_QUEUE_CRAFT_BUTTON_ROW_LABEL_WRONG_CRAFTER = "Personagem Errado",
        CRAFT_QUEUE_RECIPE_REQUIREMENTS_HEADER = "Requisitos",
        CRAFT_QUEUE_RECIPE_REQUIREMENTS_TOOLTIP =
        "Todos os requisitos devem ser atendidos para craftar uma receita.",
        CRAFT_QUEUE_CRAFT_NEXT_BUTTON_LABEL = "Criar Próximo",
        CRAFT_QUEUE_CRAFT_AVAILABLE_AMOUNT = "Craftável",
        CRAFTQUEUE_AUCTIONATOR_SHOPPING_LIST_BUTTON_LABEL = "Criar lista de compras no Auctionator",
        CRAFT_QUEUE_QUEUE_TAB_LABEL = "Fila de Criação",
        CRAFT_QUEUE_FLASH_TASKBAR_OPTION_LABEL = "Sinalizar Barra de Tarefas ao concluir itens da " ..
            f.bb("Fila de Criação"),
        CRAFT_QUEUE_FLASH_TASKBAR_OPTION_TOOLTIP =
            "Se WoW estiver minimizado e uma receita for concluída na " .. f.bb("Fila de Criação") ..
            ", o " .. f.l(" CraftSim") .. " vai sinalizar o ícone do WoW",
        CRAFT_QUEUE_RESTOCK_OPTIONS_TAB_LABEL = "Opções de Reabastecimento",
        CRAFT_QUEUE_RESTOCK_OPTIONS_TAB_TOOLTIP =
        "Configura o comportamento de reabastecimento ao importar do Scan de Receita.",
        CRAFT_QUEUE_RESTOCK_OPTIONS_GENERAL_PROFIT_THRESHOLD_LABEL = "Limite de Lucro:",
        CRAFT_QUEUE_RESTOCK_OPTIONS_SALE_RATE_INPUT_LABEL = "Limite de Taxa de Venda:",
        CRAFT_QUEUE_RESTOCK_OPTIONS_TSM_SALE_RATE_TOOLTIP = string.format(
            [[
Disponível apenas quando %s está carregado!

Será verificado se %s das qualidades escolhidas de um item têm uma taxa de venda
maior ou igual ao limite de taxa de venda configurado.
]], f.bb("TSM"), f.bb("qualquer")),
        CRAFT_QUEUE_RESTOCK_OPTIONS_TSM_SALE_RATE_TOOLTIP_GENERAL = string.format(
            [[
Disponível apenas quando %s está carregado!

Será verificado se %s das qualidades de um item têm uma taxa de venda
maior ou igual ao limite de taxa de venda configurado.
]], f.bb("TSM"), f.bb("qualquer")),
        CRAFT_QUEUE_RESTOCK_OPTIONS_AMOUNT_LABEL = "Quantidade de Reabastecimento:",
        CRAFT_QUEUE_RESTOCK_OPTIONS_RESTOCK_TOOLTIP = "Esta é a " ..
            f.bb("quantidade de criações") ..
            " que ficará na fila para tal receita.\n\nA quantidade de itens que você tem em seu inventário e banco das qualidades verificadas será subtraída do valor de reabastecimento no momento do reabastecimento",
        CRAFT_QUEUE_RESTOCK_OPTIONS_ENABLE_RECIPE_LABEL = "Habilitar:",
        CRAFT_QUEUE_RESTOCK_OPTIONS_GENERAL_OPTIONS_LABEL = "Ajustes Gerais (Todas as Receitas)",
        CRAFT_QUEUE_RESTOCK_OPTIONS_ENABLE_RECIPE_TOOLTIP =
        "Se esta opção estiver desligada, a receita será reabastecida de acordo com os ajustes gerais acima",
        CRAFT_QUEUE_TOTAL_PROFIT_LABEL = "Lucro Ø Total:",
        CRAFT_QUEUE_TOTAL_CRAFTING_COSTS_LABEL = "Total de Custos de Criação:",
        CRAFT_QUEUE_EDIT_RECIPE_TITLE = "Editar Receita",
        CRAFT_QUEUE_EDIT_RECIPE_NAME_LABEL = "Nome da Receita",
        CRAFT_QUEUE_EDIT_RECIPE_REAGENTS_SELECT_LABEL = "Selecionar",
        CRAFT_QUEUE_EDIT_RECIPE_OPTIONAL_REAGENTS_LABEL = "Reagentes Opcionais",
        CRAFT_QUEUE_EDIT_RECIPE_FINISHING_REAGENTS_LABEL = "Reagentes de Finalização",
        CRAFT_QUEUE_EDIT_RECIPE_SPARK_LABEL = "Necessário",
        CRAFT_QUEUE_EDIT_RECIPE_PROFESSION_GEAR_LABEL = "Equipamento de Profissão",
        CRAFT_QUEUE_EDIT_RECIPE_OPTIMIZE_PROFIT_BUTTON = "Otimizar",
        CRAFT_QUEUE_EDIT_RECIPE_CRAFTING_COSTS_LABEL = "Custos de Criação: ",
        CRAFT_QUEUE_EDIT_RECIPE_AVERAGE_PROFIT_LABEL = "Lucro Médio: ",
        CRAFT_QUEUE_EDIT_RECIPE_RESULTS_LABEL = "Resultados",
        CRAFT_QUEUE_EDIT_RECIPE_CONCENTRATION_CHECKBOX = " Concentração",
        CRAFT_QUEUE_AUCTIONATOR_SHOPPING_LIST_PER_CHARACTER_CHECKBOX = "Por Personagem",
        CRAFT_QUEUE_AUCTIONATOR_SHOPPING_LIST_PER_CHARACTER_CHECKBOX_TOOLTIP = "Cria uma " ..
            f.bb("Lista de Compras do Auctionator") ..
            " para cada personagem\nao invés de uma lista de compras para todos",
        CRAFT_QUEUE_AUCTIONATOR_SHOPPING_LIST_TARGET_MODE_CHECKBOX = "Apenas Modo Alvo",
        CRAFT_QUEUE_AUCTIONATOR_SHOPPING_LIST_TARGET_MODE_CHECKBOX_TOOLTIP = "Cria uma " ..
            f.bb("Lista de Compras do Auctionator") .. " apenas para receitas em modo alvo",
        CRAFT_QUEUE_UNSAVED_CHANGES_TOOLTIP = f.white(
            "Quantidade Não Salva na Fila.\nPressione Enter para Salvar"),
        CRAFT_QUEUE_STATUSBAR_LEARNED = f.white("Receita Aprendida"),
        CRAFT_QUEUE_STATUSBAR_COOLDOWN = f.white("Não estando em Recarga"),
        CRAFT_QUEUE_STATUSBAR_REAGENTS = f.white("Reagentes Disponíveis"),
        CRAFT_QUEUE_STATUSBAR_GEAR = f.white("Equipamento de Profissão Equipado"),
        CRAFT_QUEUE_STATUSBAR_CRAFTER = f.white("Personagem Criador Correto"),
        CRAFT_QUEUE_STATUSBAR_PROFESSION = f.white("Profissão Aberta"),
        CRAFT_QUEUE_BUTTON_EDIT = "Editar",
        CRAFT_QUEUE_BUTTON_CRAFT = "Criar",
        CRAFT_QUEUE_BUTTON_CLAIM = "Reivindicar",
        CRAFT_QUEUE_BUTTON_CLAIMED = "Reivindicado",
        CRAFT_QUEUE_BUTTON_NEXT = "Próximo: ",
        CRAFT_QUEUE_BUTTON_NOTHING_QUEUED = "Nada na Fila",
        CRAFT_QUEUE_BUTTON_ORDER = "Ordem",
        CRAFT_QUEUE_BUTTON_SUBMIT = "Enviar",
        CRAFT_QUEUE_IGNORE_ACUITY_RECIPES_CHECKBOX_LABEL = "Ignorar Receitas de Acuidade",
        CRAFT_QUEUE_IGNORE_ACUITY_RECIPES_CHECKBOX_TOOLTIP =
            "Não enfileirar receitas que usam " .. f.bb("Acuidade do Artesão") .. " para criar",
        CRAFT_QUEUE_AMOUNT_TOOLTIP = "\n\nCriações Enfileiradas: ",
        CRAFT_QUEUE_ORDER_CUSTOMER = "\n\nOrdem do Cliente: ",
        CRAFT_QUEUE_ORDER_MINIMUM_QUALITY = "\nQualidade Mínima: ",
        CRAFT_QUEUE_ORDER_REWARDS = "\nRecompensas:",

        CRAFT_BUFFS_TITLE = "Buffs de CraftSim",
        CRAFT_BUFFS_SIMULATE_BUTTON = "Simular Buffs",
        CRAFT_BUFF_CHEFS_HAT_TOOLTIP = f.bb("Wrath of the Lich King Toy.") ..
            "\nRequires Northrend Cooking\nSets Crafting Speed to " .. f.g("0.5 seconds"),

        -- cooldowns module

        COOLDOWNS_TITLE = "Recargas CraftSim",
        CONTROL_PANEL_MODULES_COOLDOWNS_LABEL = "Recargas",
        CONTROL_PANEL_MODULES_COOLDOWNS_TOOLTIP = "Visão Geral da " ..
            f.bb("Recargas de Profissões") .. " da sua conta",
        COOLDOWNS_CRAFTER_HEADER = "Personagem",
        COOLDOWNS_RECIPE_HEADER = "Receita",
        COOLDOWNS_CHARGES_HEADER = "Cargas",
        COOLDOWNS_NEXT_HEADER = "Próxima Carga",
        COOLDOWNS_ALL_HEADER = "Cargas Completas",
        COOLDOWNS_TAB_OVERVIEW = "Visão Geral",
        COOLDOWNS_TAB_OPTIONS = "Ajustes",
        COOLDOWNS_EXPANSION_FILTER_BUTTON = "Filtrar Expansão",
        COOLDOWNS_RECIPE_LIST_TEXT_TOOLTIP = f.bb("\n\nReceitas compartilhando essa Recarga:\n"),
        COOLDOWNS_RECIPE_READY = f.g("Disponível"),

        -- concentration module

        CONCENTRATION_TRACKER_TITLE = "Concentração CraftSim",
        CONCENTRATION_TRACKER_LABEL_CRAFTER = "Personagem",
        CONCENTRATION_TRACKER_LABEL_CURRENT = "Atual",
        CONCENTRATION_TRACKER_LABEL_MAX = "Máximo",
        CONCENTRATION_TRACKER_MAX = f.g("MAX"),
        CONCENTRATION_TRACKER_MAX_VALUE = "Max: ",
        CONCENTRATION_TRACKER_FULL = f.g("Concentração Completa"),
        CONCENTRATION_TRACKER_SORT_MODE_CHARACTER = "Personagem",
        CONCENTRATION_TRACKER_SORT_MODE_CONCENTRATION = "Concentração",
        CONCENTRATION_TRACKER_SORT_MODE_PROFESSION = "Profissão",
        CONCENTRATION_TRACKER_FORMAT_MODE_EUROPE_MAX_DATE = "Europeu - Data Máxima",
        CONCENTRATION_TRACKER_FORMAT_MODE_AMERICA_MAX_DATE = "Americano - Data Máxima",
        CONCENTRATION_TRACKER_FORMAT_MODE_HOURS_LEFT = "Horas Restantes",

        -- static popups
        STATIC_POPUPS_YES = "Sim",
        STATIC_POPUPS_NO = "Não",

        -- frames
        FRAMES_RESETTING = "redefinir frameID: ",
        FRAMES_WHATS_NEW = "O que há de Novo CraftSim?",
        FRAMES_JOIN_DISCORD = "Entre no Discord!",
        FRAMES_DONATE_KOFI = "Visite o CraftSim no Kofi",
        FRAMES_NO_INFO = "Nenhuma Informação",

        -- node data
        NODE_DATA_RANK_TEXT = "Classificação ",
        NODE_DATA_TOOLTIP = "\n\nEstatísticas totais do talento:\n",

        -- columns
        SOURCE_COLUMN_AH = "AH",
        SOURCE_COLUMN_OVERRIDE = "OR",
        SOURCE_COLUMN_WO = "WO",
    }
end
