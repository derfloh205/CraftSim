---@class CraftSim
local CraftSim = select(2, ...)

CraftSim.LOCAL_PT = {}

function CraftSim.LOCAL_PT:GetData()
    local f = CraftSim.GUTIL:GetFormatter()
    local cm = function(i, s) return CraftSim.MEDIA:GetAsTextIcon(i, s) end
    return {
        -- REQUIRED:
        [CraftSim.CONST.TEXT.STAT_MULTICRAFT] = "Multicriação",
        [CraftSim.CONST.TEXT.STAT_RESOURCEFULNESS] = "Devolução de recursos",
        [CraftSim.CONST.TEXT.STAT_INGENUITY] = "Engenhosidade",
        [CraftSim.CONST.TEXT.STAT_CRAFTINGSPEED] = "Velocidade de criação",
        [CraftSim.CONST.TEXT.EQUIP_MATCH_STRING] = "Equipado:",
        [CraftSim.CONST.TEXT.ENCHANTED_MATCH_STRING] = "Encantado:",

        -- OPTIONAL (Defaulting to EN if not available):

        -- professions

        [CraftSim.CONST.TEXT.PROFESSIONS_BLACKSMITHING] = "Ferraria",
        [CraftSim.CONST.TEXT.PROFESSIONS_LEATHERWORKING] = "Couraria",
        [CraftSim.CONST.TEXT.PROFESSIONS_ALCHEMY] = "Alquimia",
        [CraftSim.CONST.TEXT.PROFESSIONS_HERBALISM] = "Herbalismo",
        [CraftSim.CONST.TEXT.PROFESSIONS_COOKING] = "Cozinheiro",
        [CraftSim.CONST.TEXT.PROFESSIONS_MINING] = "Mineração",
        [CraftSim.CONST.TEXT.PROFESSIONS_TAILORING] = "Alfaiataria",
        [CraftSim.CONST.TEXT.PROFESSIONS_ENGINEERING] = "Engenharia",
        [CraftSim.CONST.TEXT.PROFESSIONS_ENCHANTING] = "Encantamento",
        [CraftSim.CONST.TEXT.PROFESSIONS_FISHING] = "Pesca",
        [CraftSim.CONST.TEXT.PROFESSIONS_SKINNING] = "Esfolamento",
        [CraftSim.CONST.TEXT.PROFESSIONS_JEWELCRAFTING] = "Joalheria",
        [CraftSim.CONST.TEXT.PROFESSIONS_INSCRIPTION] = "Escrivaninha",

        -- Profit Breakdown Tooltips
        [CraftSim.CONST.TEXT.RESOURCEFULNESS_EXPLANATION_TOOLTIP] =
        "A Devolução de recursos proca para cada reagente individualmente e então economiza cerca de 30% da quantidade.\n\nO valor médio economizado é o valor médio de TODAS as combinações e suas chances.\n(Procar todos os reagentes ao mesmo tempo é muito improvável, mas economiza bastante).\n\nO custo total médio de reagentes economizados é a soma dos custos economizados de todos os reagentes, ponderados pela chance de proc.",

        [CraftSim.CONST.TEXT.RECIPE_DIFFICULTY_EXPLANATION_TOOLTIP] =
        "A dificuldade da receita determina quanta perícia é necessária para fabricar a receita em cada nível de qualidade.\n\nPara receitas com cinco níveis de qualidade é 20%, 50%, 80% e 100% da dificuldade da receita como perícia.\nPara receitas com três níveis de qualidade é 50% e 100%",
        [CraftSim.CONST.TEXT.MULTICRAFT_EXPLANATION_TOOLTIP] =
        "Multicriação dá uma probabilidade de fabricar mais objetos do que uma receita normalmente fabricaria.\n\nA quantidade adicional está entre 1 e 2.5y\nonde y = quantidade normal que uma criação fornece.",
        [CraftSim.CONST.TEXT.REAGENTSKILL_EXPLANATION_TOOLTIP] =
        "A qualidade dos seus reagentes podem dar até um máximo de 40% de perícia adicional da receita base.\n\nTodos os Reagentes de Q1: 0% Bônus\nTodos os Reagentes de Q2: 20% Bônus\nTodos os Reagentes de Q3: 40% Bônus\n\nA habilidade é calculada pela quantidade de reagentes de cada qualidade, ponderada de acordo com sua qualidade \ne um valor de peso específico que é único para cada item de reagente de criação com qualidade.\n\nNo entanto, é diferente quando se trata de Recraft (Recriação). No Recraft, o máximo que os reagentes podem aumentar a qualidade\ndepende da qualidade dos reagentes com os quais o item foi originalmente criado.\nO funcionamento exato disso, é desconhecido.\nTodavia, o CraftSim compara, internamente, a perícia alcançada com todos os de qualidade 3 (Q3) e calcula\no aumento máximo de perícia com base nisso.",
        [CraftSim.CONST.TEXT.REAGENTFACTOR_EXPLANATION_TOOLTIP] =
        "O máximo que os reagentes podem contribuir para uma receita é, na maioria das vezes, 40% da dificuldade base da receita.\n\nMas, no caso de Recraft (Recriação), esse valor pode variar com base nas criações anteriores\n e na qualidade dos reagentes que foram utilizados.",

        -- Simulation Mode
        [CraftSim.CONST.TEXT.SIMULATION_MODE_NONE] = "Nenhum",
        [CraftSim.CONST.TEXT.SIMULATION_MODE_LABEL] = "Modo Simulação",
        [CraftSim.CONST.TEXT.SIMULATION_MODE_TITLE] = "Modo de Simulação CraftSim",
        [CraftSim.CONST.TEXT.SIMULATION_MODE_TOOLTIP] =
        "O Modo de Simulação CraftSim torna possível testar combinações de uma receita sem restrições",
        [CraftSim.CONST.TEXT.SIMULATION_MODE_OPTIONAL] = "Opcional #",
        [CraftSim.CONST.TEXT.SIMULATION_MODE_FINISHING] = "Acabamento #",
        [CraftSim.CONST.TEXT.SIMULATION_MODE_QUALITY_BUTTON_TOOLTIP] = "Maximizar Todos Reagentes de Qualidade ",
        [CraftSim.CONST.TEXT.SIMULATION_MODE_CLEAR_BUTTON] = "Limpar",
        [CraftSim.CONST.TEXT.SIMULATION_MODE_CONCENTRATION] = " Concentração",
        [CraftSim.CONST.TEXT.SIMULATION_MODE_CONCENTRATION_COST] = "Custo de Concentração: ",

        -- Details Frame
        [CraftSim.CONST.TEXT.RECIPE_DIFFICULTY_LABEL] = "Dificuldade da receita: ",
        [CraftSim.CONST.TEXT.MULTICRAFT_LABEL] = "Multicriação: ",
        [CraftSim.CONST.TEXT.RESOURCEFULNESS_LABEL] = "Devolução de recursos: ",
        [CraftSim.CONST.TEXT.RESOURCEFULNESS_BONUS_LABEL] = "Bonus de item de Devolução de recursos: ",
        [CraftSim.CONST.TEXT.CONCENTRATION_LABEL] = "Concentração: ",
        [CraftSim.CONST.TEXT.REAGENT_QUALITY_BONUS_LABEL] = "Bonus de qualidade do Reagente: ",
        [CraftSim.CONST.TEXT.REAGENT_QUALITY_MAXIMUM_LABEL] = "Máxima Qualidade do Reagente %: ",
        [CraftSim.CONST.TEXT.EXPECTED_QUALITY_LABEL] = "Qualidade Esperada: ",
        [CraftSim.CONST.TEXT.NEXT_QUALITY_LABEL] = "Próxima Qualidade: ",
        [CraftSim.CONST.TEXT.MISSING_SKILL_LABEL] = "Perícia faltante: ",
        [CraftSim.CONST.TEXT.SKILL_LABEL] = "Perícia: ",
        [CraftSim.CONST.TEXT.MULTICRAFT_BONUS_LABEL] = "Bonus de item de Multicriação: ",

        -- Popups
        [CraftSim.CONST.TEXT.POPUP_NO_PRICE_SOURCE_SYSTEM] = "Nenhuma fonte de preços suportada disponível",
        [CraftSim.CONST.TEXT.POPUP_NO_PRICE_SOURCE_TITLE] = "Aviso de fonte de preço CraftSim",
        [CraftSim.CONST.TEXT.POPUP_NO_PRICE_SOURCE_WARNING] =
        "Nenhuma fonte de preço encontrada!\n\nVocê precisa instalar ao menos um dos\naddons de fonte de preços a seguir para\nutilizar os cálculos de lucro do CraftSim:\n\n\n",
        [CraftSim.CONST.TEXT.POPUP_NO_PRICE_SOURCE_WARNING_SUPPRESS] = "Não mostrar aviso novamente",
        [CraftSim.CONST.TEXT.POPUP_NO_PRICE_SOURCE_WARNING_ACCEPT] = "OK",

        -- Reagents Frame
        [CraftSim.CONST.TEXT.REAGENT_OPTIMIZATION_TITLE] = "Otimização de Reagentes CraftSim",
        [CraftSim.CONST.TEXT.REAGENTS_REACHABLE_QUALITY] = "Qualidade Alcançável: ",
        [CraftSim.CONST.TEXT.REAGENTS_MISSING] = "Reagentes faltantes",
        [CraftSim.CONST.TEXT.REAGENTS_AVAILABLE] = "Reagentes disponíveis",
        [CraftSim.CONST.TEXT.REAGENTS_CHEAPER] = "Reagentes mais baratos",
        [CraftSim.CONST.TEXT.REAGENTS_BEST_COMBINATION] = "Melhor combinação atribuída",
        [CraftSim.CONST.TEXT.REAGENTS_NO_COMBINATION] = "Nenhuma combinação encontrada \npara melhorar a qualidade",
        [CraftSim.CONST.TEXT.REAGENTS_ASSIGN] = "Atribuir",
        [CraftSim.CONST.TEXT.REAGENTS_MAXIMUM_QUALITY] = "Qualidade Máxima: ",
        [CraftSim.CONST.TEXT.REAGENTS_AVERAGE_PROFIT_LABEL] = "Lucro Ø Médio: ",
        [CraftSim.CONST.TEXT.REAGENTS_AVERAGE_PROFIT_TOOLTIP] =
            f.bb("O Lucro Médio por Criação") .. " quando utilizando " .. f.l("esta distribuição de reagentes"),
        [CraftSim.CONST.TEXT.REAGENTS_OPTIMIZE_BEST_ASSIGNED] = "Melhores Reagentes Atribuídos",
        [CraftSim.CONST.TEXT.REAGENTS_CONCENTRATION_LABEL] = "Concentração: ",
        [CraftSim.CONST.TEXT.REAGENTS_OPTIMIZE_INFO] = "Shift + BEM nos números para linkar o item no chat",
        [CraftSim.CONST.TEXT.ADVANCED_OPTIMIZATION_BUTTON] = "Otimizar",
        [CraftSim.CONST.TEXT.REAGENTS_OPTIMIZE_TOOLTIP] =
            f.r("Experimental: ") ..
            "Pesado em Performance e Reseta ao Editar.\nOtimiza para " ..
            f.gold("Maior Valor de Ouro") .. " por ponto de concentração",

        -- Specialization Info Frame
        [CraftSim.CONST.TEXT.SPEC_INFO_TITLE] = "Informações de Especialização CraftSim",
        [CraftSim.CONST.TEXT.SPEC_INFO_SIMULATE_KNOWLEDGE_DISTRIBUTION] = "Simular Distribuição de Conhecimento",
        [CraftSim.CONST.TEXT.SPEC_INFO_NODE_TOOLTIP] = "Este nó lhe concede os seguintes atributos para esta receita:",
        [CraftSim.CONST.TEXT.SPEC_INFO_WORK_IN_PROGRESS] = "Informações de Especialização\nTrabalho em Andamento",

        -- Crafting Results Frame
        [CraftSim.CONST.TEXT.CRAFT_RESULTS_TITLE] = "Resultados de Criação CraftSim",
        [CraftSim.CONST.TEXT.CRAFT_RESULTS_LOG] = "Registro de Criação",
        [CraftSim.CONST.TEXT.CRAFT_RESULTS_LOG_1] = "Lucro: ",
        [CraftSim.CONST.TEXT.CRAFT_RESULTS_LOG_2] = "Inspirado!",
        [CraftSim.CONST.TEXT.CRAFT_RESULTS_LOG_3] = "Multicriação: ",
        [CraftSim.CONST.TEXT.CRAFT_RESULTS_LOG_4] = "Recursos Salvos!: ",
        [CraftSim.CONST.TEXT.CRAFT_RESULTS_LOG_5] = "Probabilidade: ",
        [CraftSim.CONST.TEXT.CRAFT_RESULTS_CRAFTED_ITEMS] = "Itens Criados",
        [CraftSim.CONST.TEXT.CRAFT_RESULTS_SESSION_PROFIT] = "Lucro da Sessão",
        [CraftSim.CONST.TEXT.CRAFT_RESULTS_RESET_DATA] = "Resetar Dados",
        [CraftSim.CONST.TEXT.CRAFT_RESULTS_EXPORT_JSON] = "Exportar JSON",
        [CraftSim.CONST.TEXT.CRAFT_RESULTS_RECIPE_STATISTICS] = "Estatísticas da Receita",
        [CraftSim.CONST.TEXT.CRAFT_RESULTS_NOTHING] = "Nada criado ainda!",
        [CraftSim.CONST.TEXT.CRAFT_RESULTS_STATISTICS_1] = "Criações: ",
        [CraftSim.CONST.TEXT.CRAFT_RESULTS_STATISTICS_2] = "Lucro Ø Estimado: ",
        [CraftSim.CONST.TEXT.CRAFT_RESULTS_STATISTICS_3] = "Lucro Ø Real: ",
        [CraftSim.CONST.TEXT.CRAFT_RESULTS_STATISTICS_4] = "Lucro Real: ",
        [CraftSim.CONST.TEXT.CRAFT_RESULTS_STATISTICS_5] = "Procs - Real / Estimado: ",
        [CraftSim.CONST.TEXT.CRAFT_RESULTS_STATISTICS_7] = "Multicriação: ",
        [CraftSim.CONST.TEXT.CRAFT_RESULTS_STATISTICS_8] = "- Ø Itens Extras: ",
        [CraftSim.CONST.TEXT.CRAFT_RESULTS_STATISTICS_9] = "Procs de Devolução de Recursos: ",
        [CraftSim.CONST.TEXT.CRAFT_RESULTS_STATISTICS_10] = "- Ø Economia: ",
        [CraftSim.CONST.TEXT.CRAFT_RESULTS_STATISTICS_11] = "Lucro: ",
        [CraftSim.CONST.TEXT.CRAFT_RESULTS_SAVED_REAGENTS] = "Reagentes Economizados",
        [CraftSim.CONST.TEXT.CRAFT_RESULTS_DISABLE_CHECKBOX] = f.l("Desativar Registro de Resultados de Criação"),
        [CraftSim.CONST.TEXT.CRAFT_RESULTS_DISABLE_CHECKBOX_TOOLTIP] =
            "Ativar essa opção encerra o registro de resultados de qualquer criação quando estiver criando e pode " ..
            f.g("melhorar a performance"),
        [CraftSim.CONST.TEXT.CRAFT_RESULTS_CRAFT_PROFITS_TAB] = "Lucros de Criação",
        [CraftSim.CONST.TEXT.CRAFT_RESULTS_STATISTICS_TRACKER_TAB] = "Rastreamento de Estatísticas",
        [CraftSim.CONST.TEXT.CRAFT_RESULTS_STATISTICS_TRACKER_TAB_DISTRIBUTION_LABEL] = "Distribuição dos Resultados",
        [CraftSim.CONST.TEXT.CRAFT_RESULTS_STATISTICS_TRACKER_TAB_DISTRIBUTION_HELP] =
        "Distribuição relativa dos resultados de itens criados.\n(Ignorando Quantidades de Multicriação)",
        [CraftSim.CONST.TEXT.CRAFT_RESULTS_STATISTICS_TRACKER_TAB_MULTICRAFT] = "Multicriação",
        [CraftSim.CONST.TEXT.CRAFT_RESULTS_STATISTICS_TRACKER_TAB_RESOURCEFULNESS] = "Devolução de Recursos",
        [CraftSim.CONST.TEXT.CRAFT_RESULTS_STATISTICS_TRACKER_TAB_YIELD_DDISTRIBUTION] = "Distribuição do Rendimento",

        -- Stats Weight Frame
        [CraftSim.CONST.TEXT.STAT_WEIGHTS_TITLE] = "Lucro Médio do CraftSim",
        [CraftSim.CONST.TEXT.EXPLANATIONS_TITLE] = "Explicação do Lucro Médio do CraftSim",
        [CraftSim.CONST.TEXT.STAT_WEIGHTS_SHOW_EXPLANATION_BUTTON] = "Mostrar Explicação",
        [CraftSim.CONST.TEXT.STAT_WEIGHTS_HIDE_EXPLANATION_BUTTON] = "Esconder Explicação",
        [CraftSim.CONST.TEXT.STAT_WEIGHTS_SHOW_STATISTICS_BUTTON] = "Mostrar Estatísticas",
        [CraftSim.CONST.TEXT.STAT_WEIGHTS_HIDE_STATISTICS_BUTTON] = "Esconder Estatísticas",
        [CraftSim.CONST.TEXT.STAT_WEIGHTS_PROFIT_CRAFT] = "Ø Lucro / de Criação: ",
        [CraftSim.CONST.TEXT.EXPLANATIONS_BASIC_PROFIT_TAB] = "Cálculo Básico de Lucro",

        -- Cost Details Frame
        [CraftSim.CONST.TEXT.COST_OPTIMIZATION_TITLE] = "Otimização de Custo do CraftSim",
        [CraftSim.CONST.TEXT.COST_OPTIMIZATION_EXPLANATION] =
            "Aqui você tem uma visão geral de todos os valores possíveis dos reagentes utilizados.\nA " ..
            f.bb("'Fonte Utilizada'") ..
            " coluna indica quais dos valores é utilizado.\n\n" ..
            f.g("AH") ..
            " .. Preço na Casa de Leilão\n" ..
            f.l("OR") ..
            " .. Sustituir Valor\n" ..
            f.bb("Qualquer Nome") ..
            " .. Estimativa de Custo de Produção Própria\n" ..
            f.l("OR") ..
            " sempre será usado se definido. " ..
            f.bb("Custos de Criação") .. " só será usado se menor que " .. f.g("AH"),
        [CraftSim.CONST.TEXT.COST_OPTIMIZATION_CRAFTING_COSTS] = "Custos de Criação: ",
        [CraftSim.CONST.TEXT.COST_OPTIMIZATION_ITEM_HEADER] = "Item",
        [CraftSim.CONST.TEXT.COST_OPTIMIZATION_AH_PRICE_HEADER] = "Valor da AH",
        [CraftSim.CONST.TEXT.COST_OPTIMIZATION_OVERRIDE_HEADER] = "Substituir",
        [CraftSim.CONST.TEXT.COST_OPTIMIZATION_CRAFTING_HEADER] = "Criação",
        [CraftSim.CONST.TEXT.COST_OPTIMIZATION_USED_SOURCE] = "Fonte Aplicada",
        [CraftSim.CONST.TEXT.COST_OPTIMIZATION_REAGENT_COSTS_TAB] = "Custos dos Reagentes",
        [CraftSim.CONST.TEXT.COST_OPTIMIZATION_SUB_RECIPE_OPTIONS_TAB] = "Opções de Sub-Receitas",
        [CraftSim.CONST.TEXT.COST_OPTIMIZATION_SUB_RECIPE_OPTIMIZATION] = "Otimização de Sub-Receitas " ..
            f.bb("(experimental)"),
        [CraftSim.CONST.TEXT.COST_OPTIMIZATION_SUB_RECIPE_OPTIMIZATION_TOOLTIP] = "Se ativado " ..
            f.l("CraftSim") .. " considera o " .. f.g("custo de criação otimizado") ..
            " do seu personagem e dos seus alts\nse eles podem criar aquele item.\n\n" ..
            f.r("Pode reduzir a performance um pouco devido a múltiplos cálculos adicionais"),
        [CraftSim.CONST.TEXT.COST_OPTIMIZATION_SUB_RECIPE_MAX_DEPTH_LABEL] = "Detalhamento do Cálculo da Sub-receita",
        [CraftSim.CONST.TEXT.COST_OPTIMIZATION_SUB_RECIPE_INCLUDE_CONCENTRATION] = "Ativar Concentração",
        [CraftSim.CONST.TEXT.COST_OPTIMIZATION_SUB_RECIPE_INCLUDE_CONCENTRATION_TOOLTIP] = "Se ativado, " ..
            f.l("CraftSim") .. "incluirá qualidades de reagentes mesmo que a concentração seja necessária.",
        [CraftSim.CONST.TEXT.COST_OPTIMIZATION_SUB_RECIPE_INCLUDE_COOLDOWN_RECIPES] = "Incluir Recarga de Receitas",
        [CraftSim.CONST.TEXT.COST_OPTIMIZATION_SUB_RECIPE_INCLUDE_COOLDOWN_RECIPES_TOOLTIP] = "Se ativado, " ..
            f.l("CraftSim") ..
            " desconsiderará os requisitos de recarga receitas ao calcular reagentes criados por si próprio",
        [CraftSim.CONST.TEXT.COST_OPTIMIZATION_SUB_RECIPE_SELECT_RECIPE_CRAFTER] = "Selecione Criador de Receitas",
        [CraftSim.CONST.TEXT.COST_OPTIMIZATION_REAGENT_LIST_AH_COLUMN_AUCTION_BUYOUT] = "Arremate de Leilão: ",
        [CraftSim.CONST.TEXT.COST_OPTIMIZATION_REAGENT_LIST_OVERRIDE] = "\n\nSubstituir",
        [CraftSim.CONST.TEXT.COST_OPTIMIZATION_REAGENT_LIST_EXPECTED_COSTS_TOOLTIP] = "\n\nCriando ",
        [CraftSim.CONST.TEXT.COST_OPTIMIZATION_REAGENT_LIST_EXPECTED_COSTS_PRE_ITEM] = "\n- Custo Estimado por Item: ",
        [CraftSim.CONST.TEXT.COST_OPTIMIZATION_REAGENT_LIST_CONCENTRATION_COST] = f.gold("Custo de Concentração: "),
        [CraftSim.CONST.TEXT.COST_OPTIMIZATION_REAGENT_LIST_CONCENTRATION] = "Concentração: ",

        -- Statistics Frame
        [CraftSim.CONST.TEXT.STATISTICS_TITLE] = "Estatísticas do CraftSim",
        [CraftSim.CONST.TEXT.STATISTICS_EXPECTED_PROFIT] = "Lucro Estimado (μ)",
        [CraftSim.CONST.TEXT.STATISTICS_CHANCE_OF] = "Chance de ",
        [CraftSim.CONST.TEXT.STATISTICS_PROFIT] = "Lucro",
        [CraftSim.CONST.TEXT.STATISTICS_AFTER] = " depois",
        [CraftSim.CONST.TEXT.STATISTICS_CRAFTS] = "Criações: ",
        [CraftSim.CONST.TEXT.STATISTICS_QUALITY_HEADER] = "Qualidade",
        [CraftSim.CONST.TEXT.STATISTICS_MULTICRAFT_HEADER] = "Multicriação",
        [CraftSim.CONST.TEXT.STATISTICS_RESOURCEFULNESS_HEADER] = "Devolução de recursos",
        [CraftSim.CONST.TEXT.STATISTICS_EXPECTED_PROFIT_HEADER] = "Lucro Estimado",
        [CraftSim.CONST.TEXT.PROBABILITY_TABLE_TITLE] = "Tabela de Probabilidade de Receita",
        [CraftSim.CONST.TEXT.STATISTICS_PROBABILITY_TABLE_TAB] = "Tabela de Probabilidade",
        [CraftSim.CONST.TEXT.STATISTICS_CONCENTRATION_TAB] = "Concentração",
        [CraftSim.CONST.TEXT.STATISTICS_CONCENTRATION_CURVE_GRAPH] = "Curva de Custo de Concentração",
        [CraftSim.CONST.TEXT.STATISTICS_CONCENTRATION_CURVE_GRAPH_HELP] =
            "Custo de concentração baseado na perícia do personagem para determinada receita\n" ..
            f.bb("X Axis: ") .. " Perícia do Personagem\n" ..
            f.bb("Y Axis: ") .. " Custo de Concentração",

        -- Price Details Frame
        [CraftSim.CONST.TEXT.COST_OVERVIEW_TITLE] = "Detalhamento de Preços do Craftsim",
        [CraftSim.CONST.TEXT.PRICE_DETAILS_INV_AH] = "Inv/AH",
        [CraftSim.CONST.TEXT.PRICE_DETAILS_ITEM] = "Item",
        [CraftSim.CONST.TEXT.PRICE_DETAILS_PRICE_ITEM] = "Preço/Item",
        [CraftSim.CONST.TEXT.PRICE_DETAILS_PROFIT_ITEM] = "Lucro/Item",

        -- Price Override Frame
        [CraftSim.CONST.TEXT.PRICE_OVERRIDE_TITLE] = "Substituir Preços do CraftSim",
        [CraftSim.CONST.TEXT.PRICE_OVERRIDE_REQUIRED_REAGENTS] = "Reagentes Necessários",
        [CraftSim.CONST.TEXT.PRICE_OVERRIDE_OPTIONAL_REAGENTS] = "Reagentes Opcionais",
        [CraftSim.CONST.TEXT.PRICE_OVERRIDE_FINISHING_REAGENTS] = "Reagentes Finalizantes",
        [CraftSim.CONST.TEXT.PRICE_OVERRIDE_RESULT_ITEMS] = "Resultado dos Itens",
        [CraftSim.CONST.TEXT.PRICE_OVERRIDE_ACTIVE_OVERRIDES] = "Ativar Substituições",
        [CraftSim.CONST.TEXT.PRICE_OVERRIDE_ACTIVE_OVERRIDES_TOOLTIP] =
        "'(como resultado)' -> substituição de preço considerada apenas quando o item é resultado de uma receita",
        [CraftSim.CONST.TEXT.PRICE_OVERRIDE_CLEAR_ALL] = "Limpar Tudo",
        [CraftSim.CONST.TEXT.PRICE_OVERRIDE_SAVE] = "Salvar",
        [CraftSim.CONST.TEXT.PRICE_OVERRIDE_SAVED] = "Salvo",
        [CraftSim.CONST.TEXT.PRICE_OVERRIDE_REMOVE] = "Remover",

        -- Recipe Scan Frame
        [CraftSim.CONST.TEXT.RECIPE_SCAN_TITLE] = "Escaneamento de Receitas do CraftSim",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_MODE] = "Modo Scan",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_SORT_MODE] = "Modo Aleatório",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_SCAN_RECIPIES] = "Escanear Receitas",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_SCAN_CANCEL] = "Cancelar",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_SCANNING] = "Verificando",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_INCLUDE_NOT_LEARNED] = "Incluir Não Aprendidas",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_INCLUDE_NOT_LEARNED_TOOLTIP] =
        "Inclui receitas que você ainda não aprendeu na verificação",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_INCLUDE_SOULBOUND] = "Incluir Vinculadas",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_INCLUDE_SOULBOUND_TOOLTIP] =
        "Inclui receitas vinculadas na verificação.\n\nRecomenda-se definir uma substituição de preço (por exemplo, para simular uma comissão desejada)\nno Módulo de Substituição de Preço para os itens criados dessa receita",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_INCLUDE_GEAR] = "Incluir Equipamento",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_INCLUDE_GEAR_TOOLTIP] =
        "Inclui todos os tipos de equipamentos de profissão na verificação",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_OPTIMIZE_TOOLS] = "Otimizar Ferramentas de Profissão",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_OPTIMIZE_TOOLS_TOOLTIP] =
        "Otimiza suas ferramentas de profissão para obter maior lucro em cada receita\n\n",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_OPTIMIZE_TOOLS_WARNING] =
        "Pode reduzir performance durante a verificação\nse você tiver muitas ferramentas no inventário",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_CRAFTER_HEADER] = "Criador",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_RECIPE_HEADER] = "Receita",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_LEARNED_HEADER] = "Aprendido",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_RESULT_HEADER] = "Resultado",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_AVERAGE_PROFIT_HEADER] = "Lucro Médio",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_CONCENTRATION_VALUE_HEADER] = "Valor C.",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_CONCENTRATION_COST_HEADER] = "Custo C.",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_TOP_GEAR_HEADER] = "Top Gear",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_INV_AH_HEADER] = "Inv/AH",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_SORT_BY_MARGIN] = "Classificar por lucro %",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_SORT_BY_MARGIN_TOOLTIP] =
        "Classifica a lista de lucros por lucro relativo aos custos de fabricação.\n(Requer um novo Scan)",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_USE_INSIGHT_CHECKBOX] = "Usar " .. f.bb("Percepção") .. " se possível",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_USE_INSIGHT_CHECKBOX_TOOLTIP] = "Usar " ..
            f.bb("Percepção Ilustre") ..
            " or\n" .. f.bb("Percepção Ilustre Inferior") .. " como reagente opcional para receitas que permitam.",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_ONLY_FAVORITES_CHECKBOX] = "Somente Favoritos",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_ONLY_FAVORITES_CHECKBOX_TOOLTIP] = "Verifica apenas receitas favoritas",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_EQUIPPED] = "Equipado",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_MODE_Q1] = "Reagentes de Qualidade 1",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_MODE_Q2] = "Reagentes de Qualidade 2",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_MODE_Q3] = "Reagentes de Qualidade 3",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_MODE_OPTIMIZE] = "Otimizar Reagentes",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_SORT_MODE_PROFIT] = "Lucro",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_SORT_MODE_RELATIVE_PROFIT] = "Lucro Relativo",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_SORT_MODE_CONCENTRATION_VALUE] = "Valor de Concentração",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_SORT_MODE_CONCENTRATION_COST] = "Custo de Concentração",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_EXPANSION_FILTER_BUTTON] = "Filtrar Expansão",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_ALTPROFESSIONS_FILTER_BUTTON] = "Profissões dos Alts",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_SCAN_ALL_BUTTON_READY] = "Escanear Profissões",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_SCAN_ALL_BUTTON_SCANNING] = "Verificando...",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_TAB_LABEL_SCAN] = "Escanear Receitas",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_TAB_LABEL_OPTIONS] = "Opções de Escaneamento",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_IMPORT_ALL_PROFESSIONS_CHECKBOX_LABEL] = "Todas as Profissões Escaneadas",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_IMPORT_ALL_PROFESSIONS_CHECKBOX_TOOLTIP] = f.g("True: ") ..
            "Importa Resultados Escaneados de todas as profissões ativadas e escaneadas\n\n" ..
            f.r("False: ") .. "Importa Resultados somente da Profissão selecionada",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_CACHED_RECIPES_TOOLTIP] =
            "Sempre que você abrir ou escanear uma receita em um personagem, " ..
            f.l("CraftSim") ..
            " vai memorizar ela.\n\nSomente as receitas dos seus alts que " ..
            f.l("CraftSim") .. " pode memorizar serão escaneadas com " .. f.bb("RecipeScan\n\n") ..
            "A quantidade real de receitas escaneadas é baseada nas " .. f.e("Opções de Escaneamento de Receitas"),
        [CraftSim.CONST.TEXT.RECIPE_SCAN_CONCENTRATION_TOGGLE] = " Concentração",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_CONCENTRATION_TOGGLE_TOOLTIP] = "Ativar Concentração",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_OPTIMIZE_SUBRECIPES] = "Otimizar Sub-Receitas " .. f.bb("(experimental)"),
        [CraftSim.CONST.TEXT.RECIPE_SCAN_OPTIMIZE_SUBRECIPES_TOOLTIP] = "Se ativado, " ..
            f.l("CraftSim") ..
            " também otimiza a criação de receitas de reagentes armazenadas em cache de receitas escaneadas e utiliza seus\n" ..
            f.bb("custos estimados") .. " para calcular os custos de criação do produto final.\n\n" ..
            f.r("Aviso: Isso pode reduzir o desempenho da verificação"),
        [CraftSim.CONST.TEXT.RECIPE_SCAN_CACHED_RECIPES] = "Receitas em Cache: ",

        -- Recipe Top Gear
        [CraftSim.CONST.TEXT.TOP_GEAR_TITLE] = "Top Gear do CraftSim",
        [CraftSim.CONST.TEXT.TOP_GEAR_AUTOMATIC] = "Automático",
        [CraftSim.CONST.TEXT.TOP_GEAR_AUTOMATIC_TOOLTIP] =
        "Simula automaticamente o Top Gear (Melhor Equipamento) para o modo selecionado sempre que uma receita for atualizada.\n\nDesativar essa opção pode melhorar o desempenho.",
        [CraftSim.CONST.TEXT.TOP_GEAR_SIMULATE] = "Simular Top Gear",
        [CraftSim.CONST.TEXT.TOP_GEAR_EQUIP] = "Equipar",
        [CraftSim.CONST.TEXT.TOP_GEAR_SIMULATE_QUALITY] = "Qualidade: ",
        [CraftSim.CONST.TEXT.TOP_GEAR_SIMULATE_EQUIPPED] = "Top Gear equipado",
        [CraftSim.CONST.TEXT.TOP_GEAR_SIMULATE_PROFIT_DIFFERENCE] = "Ø Diferença de Lucro\n",
        [CraftSim.CONST.TEXT.TOP_GEAR_SIMULATE_NEW_MUTLICRAFT] = "Nova Multicriação\n",
        [CraftSim.CONST.TEXT.TOP_GEAR_SIMULATE_NEW_CRAFTING_SPEED] = "Nova Velocidade de Criação\n",
        [CraftSim.CONST.TEXT.TOP_GEAR_SIMULATE_NEW_RESOURCEFULNESS] = "Nova Devolução de Recursos\n",
        [CraftSim.CONST.TEXT.TOP_GEAR_SIMULATE_NEW_SKILL] = "Nova Perícia\n",
        [CraftSim.CONST.TEXT.TOP_GEAR_SIMULATE_UNHANDLED] = "Modo Simulação Não Gerenciado",

        [CraftSim.CONST.TEXT.TOP_GEAR_SIM_MODES_PROFIT] = "Top Lucro",
        [CraftSim.CONST.TEXT.TOP_GEAR_SIM_MODES_SKILL] = "Top Perícia",
        [CraftSim.CONST.TEXT.TOP_GEAR_SIM_MODES_MULTICRAFT] = "Top Multicriação",
        [CraftSim.CONST.TEXT.TOP_GEAR_SIM_MODES_RESOURCEFULNESS] = "Top Devolução de Recursos",
        [CraftSim.CONST.TEXT.TOP_GEAR_SIM_MODES_CRAFTING_SPEED] = "Top Velocidade de Criação",

        -- Options
        [CraftSim.CONST.TEXT.OPTIONS_TITLE] = "Opções do CraftSim",
        [CraftSim.CONST.TEXT.OPTIONS_GENERAL_TAB] = "Geral",
        [CraftSim.CONST.TEXT.OPTIONS_GENERAL_PRICE_SOURCE] = "Fonte de Preço",
        [CraftSim.CONST.TEXT.OPTIONS_GENERAL_CURRENT_PRICE_SOURCE] = "Fonte Atual de Preços: ",
        [CraftSim.CONST.TEXT.OPTIONS_GENERAL_NO_PRICE_SOURCE] = "Nenhum Addon Compatível de Preços Carregado!",
        [CraftSim.CONST.TEXT.OPTIONS_GENERAL_SHOW_PROFIT] = "Mostrar Porcentagem de Lucro",
        [CraftSim.CONST.TEXT.OPTIONS_GENERAL_SHOW_PROFIT_TOOLTIP] =
        "Exibe a porcentagem de lucro em relação aos custos de criação, além do valor em ouro",
        [CraftSim.CONST.TEXT.OPTIONS_GENERAL_REMEMBER_LAST_RECIPE] = "Lembrar Última Receita Selecionada",
        [CraftSim.CONST.TEXT.OPTIONS_GENERAL_REMEMBER_LAST_RECIPE_TOOLTIP] =
        "Relembrar a última receita selecionada quando abrir a janela de criação",
        [CraftSim.CONST.TEXT.OPTIONS_GENERAL_SUPPORTED_PRICE_SOURCES] = "Fontes de Preços Compatíveis:",
        [CraftSim.CONST.TEXT.OPTIONS_PERFORMANCE_RAM] = "Habilita a limpeza de memória RAM durante a criação",
        [CraftSim.CONST.TEXT.OPTIONS_PERFORMANCE_RAM_CRAFTS] = "Criações",
        [CraftSim.CONST.TEXT.OPTIONS_PERFORMANCE_RAM_TOOLTIP] =
        "Quando ativado, o CraftSim limpará a memória RAM a cada número especificado de criações, removendo dados não utilizados para evitar o acúmulo de memória.\nO acúmulo de memória também pode ocorrer devido a outros addons e que não é específico do CraftSim.\nUma limpeza afetará todo o uso de RAM do WoW.",
        [CraftSim.CONST.TEXT.OPTIONS_MODULES_TAB] = "Módulos",
        [CraftSim.CONST.TEXT.OPTIONS_PROFIT_CALCULATION_TAB] = "Cálculo de Lucro",
        [CraftSim.CONST.TEXT.OPTIONS_CRAFTING_TAB] = "Criação",
        [CraftSim.CONST.TEXT.OPTIONS_TSM_RESET] = "Redefinir Padrão",
        [CraftSim.CONST.TEXT.OPTIONS_TSM_INVALID_EXPRESSION] = "Expressão Inválida",
        [CraftSim.CONST.TEXT.OPTIONS_TSM_VALID_EXPRESSION] = "Expressão Válida",
        [CraftSim.CONST.TEXT.OPTIONS_MODULES_REAGENT_OPTIMIZATION] = "Módulo de Otimização de Reagentes",
        [CraftSim.CONST.TEXT.OPTIONS_MODULES_AVERAGE_PROFIT] = "Módulo de Lucro Médio",
        [CraftSim.CONST.TEXT.OPTIONS_MODULES_TOP_GEAR] = "Módulo Top Gear",
        [CraftSim.CONST.TEXT.OPTIONS_MODULES_COST_OVERVIEW] = "Módulo de Visão Geral de Custo",
        [CraftSim.CONST.TEXT.OPTIONS_MODULES_SPECIALIZATION_INFO] = "Módulo de Informações de Especialização",
        [CraftSim.CONST.TEXT.OPTIONS_MODULES_CUSTOMER_HISTORY_SIZE] =
        "Histórico do Cliente – Número Máximo de Mensagens por Cliente",
        [CraftSim.CONST.TEXT.OPTIONS_MODULES_CUSTOMER_HISTORY_MAX_ENTRIES_PER_CLIENT] =
        "Máximo de Entradas de Histórico por Cliente",
        [CraftSim.CONST.TEXT.OPTIONS_PROFIT_CALCULATION_OFFSET] = "Ajustar limites críticos de pontos de perícia em 1",
        [CraftSim.CONST.TEXT.OPTIONS_PROFIT_CALCULATION_OFFSET_TOOLTIP] =
        "A sugestão de combinação de reagentes tentará alcançar o ponto crítico +1 ao invés de corresponder exatamente à perícia exigida",
        [CraftSim.CONST.TEXT.OPTIONS_PROFIT_CALCULATION_MULTICRAFT_CONSTANT] = "Constante de Multicriação",
        [CraftSim.CONST.TEXT.OPTIONS_PROFIT_CALCULATION_MULTICRAFT_CONSTANT_EXPLANATION] =
        "Padrão: 2,5\n\nDados de Criação de diferentes jogadores que coletaram dados no beta e no início do Dragonflight sugerem que\no máximo de itens extras que alguém pode receber de um processo multicriacão é 1+C*y.\nOnde y é a quantidade base de itens para um criação e C é 2,5.\nNo entanto, se desejar, você pode modificar este valor aqui.",
        [CraftSim.CONST.TEXT.OPTIONS_PROFIT_CALCULATION_RESOURCEFULNESS_CONSTANT] = "Constante de Devolução de Recursos",
        [CraftSim.CONST.TEXT.OPTIONS_PROFIT_CALCULATION_RESOURCEFULNESS_CONSTANT_EXPLANATION] =
        "Padrão: 0,3\n\nDados de Criação de diferentes jogadores que coletaram dados no beta e no início do Dragonflight sugerem que\na quantidade média de itens salvos é 30% da quantidade necessária.\nNo entanto, se desejar, você pode modificar esse valor aqui.",
        [CraftSim.CONST.TEXT.OPTIONS_GENERAL_SHOW_NEWS_CHECKBOX] = "Exibir Janela de " .. f.bb("Novidades"),
        [CraftSim.CONST.TEXT.OPTIONS_GENERAL_SHOW_NEWS_CHECKBOX_TOOLTIP] = "Exibe a janela de " ..
            f.bb("Novidades") .. " das novas atualizações do " .. f.l("CraftSim") .. " quando entrar no jogo",
        [CraftSim.CONST.TEXT.OPTIONS_GENERAL_HIDE_MINIMAP_BUTTON_CHECKBOX] = "Esconder Botão do Minimapa",
        [CraftSim.CONST.TEXT.OPTIONS_GENERAL_HIDE_MINIMAP_BUTTON_TOOLTIP] = "Ative para Esconder o Botão do " ..
            f.l("CraftSim") .. " no Minimapa",
        [CraftSim.CONST.TEXT.OPTIONS_GENERAL_COIN_MONEY_FORMAT_CHECKBOX] = "Utilizar Texturas de Moedas: ",
        [CraftSim.CONST.TEXT.OPTIONS_GENERAL_COIN_MONEY_FORMAT_TOOLTIP] =
        "Utilizar Ícones de Moedas para Formatar Valores",

        -- Control Panel
        [CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_CRAFT_QUEUE_LABEL] = "Fila de Criação",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_CRAFT_QUEUE_TOOLTIP] =
        "Coloque suas receitas na fila e fabrique todas em um só lugar!",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_TOP_GEAR_LABEL] = "Top Gear",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_TOP_GEAR_TOOLTIP] =
        "Mostra a melhor combinação disponível de equipamento de profissão com base no modo selecionado",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_COST_OVERVIEW_LABEL] = "Detalhes dos Preços",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_COST_OVERVIEW_TOOLTIP] =
        "Mostra uma visão geral do preço de venda e do lucro com base na qualidade do item resultante",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_AVERAGE_PROFIT_LABEL] = "Lucro Médio",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_AVERAGE_PROFIT_TOOLTIP] =
        "Mostra o lucro médio com base nas estatísticas da sua profissão e os pesos das estatísticas de lucro como ouro por ponto.",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_REAGENT_OPTIMIZATION_LABEL] = "Otimização de Reagentes",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_REAGENT_OPTIMIZATION_TOOLTIP] =
        "Sugere os reagentes mais baratos para atingir os limites de qualidade específicos.",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_PRICE_OVERRIDES_LABEL] = "Substituições de preço",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_PRICE_OVERRIDES_TOOLTIP] =
        "Substitui preços de quaisquer reagentes e resultados de criação, para todas as receitas ou para uma receita específica.",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_SPECIALIZATION_INFO_LABEL] = "Informações de Especialização",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_SPECIALIZATION_INFO_TOOLTIP] =
        "Mostra como suas especializações de profissão afetam essa receita e permite simular qualquer configuração!",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_CRAFT_RESULTS_LABEL] = "Resultados das Criações",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_CRAFT_RESULTS_TOOLTIP] =
        "Exibe um registro de criações e estatísticas sobre suas criações!",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_COST_OPTIMIZATION_LABEL] = "Otimização de Custo",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_COST_OPTIMIZATION_TOOLTIP] =
        "Módulo que mostra informações detalhadas e auxilia na otimização dos custos de criação.",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_STATISTICS_LABEL] = "Estatísticas",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_STATISTICS_TOOLTIP] =
        "Módulo que mostra informações detalhadas e auxilia na otimização dos custos de criação",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_RECIPE_SCAN_LABEL] = "Escaneamento de Receitas",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_RECIPE_SCAN_TOOLTIP] =
        "Módulo que analisa sua lista de receitas com base em várias opções",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_CUSTOMER_HISTORY_LABEL] = "Histórico de Clientes",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_CUSTOMER_HISTORY_TOOLTIP] =
        "Módulo que fornece um histórico de conversas com clientes, itens confeccionados e comissões.",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_CRAFT_BUFFS_LABEL] = "Buffs de Criação",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_CRAFT_BUFFS_TOOLTIP] =
        "Módulo que mostra seus Buffs de Criação ativos e faltantes.",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_EXPLANATIONS_LABEL] = "Explicações",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_EXPLANATIONS_TOOLTIP] =
            "Módulo que fornece várias explicações de como o" .. f.l(" CraftSim") .. " calcula as coisas",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_RESET_FRAMES] = "Redefinir Posições das Janelas",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_OPTIONS] = "Opções",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_NEWS] = "Novidades",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_EASYCRAFT_EXPORT] = " Exportar" .. f.l("Easycraft"),
        [CraftSim.CONST.TEXT.CONTROL_PANEL_EASYCRAFT_EXPORTING] = "Exportando",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_EASYCRAFT_EXPORT_NO_RECIPE_FOUND] =
        "Nenhuma receita para exportar para a expansão The Wari Within",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_FORGEFINDER_EXPORT] = " Exportar" .. f.l("ForgeFinder"),
        [CraftSim.CONST.TEXT.CONTROL_PANEL_FORGEFINDER_EXPORTING] = "Exportando",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_EXPORT_EXPLANATION] = f.l("wowforgefinder.com") ..
            " e " .. f.l("easycraft.io") ..
            "\nsão sites para buscar e oferecer " .. f.bb("Ordens de Serviço do WoW"),
        [CraftSim.CONST.TEXT.CONTROL_PANEL_DEBUG] = "Debugar",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_TITLE] = "Painel de Controle",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_SUPPORTERS_BUTTON] = f.patreon("Apoiadores"),

        -- Supporters
        [CraftSim.CONST.TEXT.SUPPORTERS_DESCRIPTION] = f.l("Obrigado a todas essas pessoas incríveis!"),
        [CraftSim.CONST.TEXT.SUPPORTERS_DESCRIPTION_2] = f.l(
            "Quer apoiar o CraftSim e também ser listado aqui com sua mensagem?\nConsidere juntar-se à Comunidade!"),
        [CraftSim.CONST.TEXT.SUPPORTERS_DATE] = "Data",
        [CraftSim.CONST.TEXT.SUPPORTERS_SUPPORTER] = "Apoiador",
        [CraftSim.CONST.TEXT.SUPPORTERS_MESSAGE] = "Mensagem",

        -- Craft Queue
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_TITLE] = "Fila de Criação do CraftSim",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_CRAFT_AMOUNT_LEFT_HEADER] = "Em Fila",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_CRAFT_PROFESSION_GEAR_HEADER] = "Equipamento de Profissão",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_CRAFTING_COSTS_HEADER] = "Custos de Criação",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_CRAFT_BUTTON_ROW_LABEL] = "Criar",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_CRAFT_BUTTON_ROW_LABEL_WRONG_GEAR] = "Ferramentas Incorretas",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_CRAFT_BUTTON_ROW_LABEL_NO_REAGENTS] = "Nenhum Reagente",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_ADD_OPEN_RECIPE_BUTTON_LABEL] = "Colocar Receita na Fila",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_ADD_FIRST_CRAFTS_BUTTON_LABEL] = "Colocar Primeiras Criações na Fila",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_ADD_PATRON_ORDERS_BUTTON_LABEL] = "Colocar Ordens de Clientes na Fila",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_ADD_PATRON_ORDERS_ALLOW_CONCENTRATION_CHECKBOX] = "Permitir Concentração",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_ADD_PATRON_ORDERS_ALLOW_CONCENTRATION_TOOLTIP] =
            "Se a qualidade mínima não puder ser alcançada, use " .. f.l("Concentração") .. " se possível",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_CLEAR_ALL_BUTTON_LABEL] = "Limpar Tudo",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_IMPORT_RECIPE_SCAN_BUTTON_LABEL] =
        "Reabastecer a partir do Escaneamento de Receitas",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_CRAFT_BUTTON_ROW_LABEL_WRONG_PROFESSION] = "Profissão Incorreta",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_CRAFT_BUTTON_ROW_LABEL_ON_COOLDOWN] = "Em Recarga",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_CRAFT_BUTTON_ROW_LABEL_WRONG_CRAFTER] = "Fabricante Errado",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_RECIPE_REQUIREMENTS_HEADER] = "Requisitos",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_RECIPE_REQUIREMENTS_TOOLTIP] =
        "Todos os requisitos devem ser atendidos para se criar uma receita.",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_CRAFT_NEXT_BUTTON_LABEL] = "Criar Próximo",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_CRAFT_AVAILABLE_AMOUNT] = "Fabricável",
        [CraftSim.CONST.TEXT.CRAFTQUEUE_AUCTIONATOR_SHOPPING_LIST_BUTTON_LABEL] = "Criar lista de compras do Auctionator",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_QUEUE_TAB_LABEL] = "Fila de Criação",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_FLASH_TASKBAR_OPTION_LABEL] =
            "Ativar Flash na Barra de Tarefas ao finalizar itens da " ..
            f.bb("Fila de Criação"),
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_FLASH_TASKBAR_OPTION_TOOLTIP] =
            "Quando WoW estiver minimizado e uma receita for concluída na " .. f.bb("Fila de Criação") ..
            ", o " .. f.l(" CraftSim") .. " vai sinalizar o ícone do WoW na Barra de Tarefas",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_RESTOCK_OPTIONS_TAB_LABEL] = "Opções de Reabastecimento",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_RESTOCK_OPTIONS_TAB_TOOLTIP] =
        "Configura o comportamento de reabastecimento ao importar do Escaneamento de Receita.",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_RESTOCK_OPTIONS_GENERAL_PROFIT_THRESHOLD_LABEL] = "Limite de Lucro:",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_RESTOCK_OPTIONS_SALE_RATE_INPUT_LABEL] = "Limite de Taxa de Venda:",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_RESTOCK_OPTIONS_TSM_SALE_RATE_TOOLTIP] = string.format(
            [[
Disponível apenas quando %s está carregado!

Será verificado se %s das qualidades escolhidas de um item têm uma taxa de venda
maior ou igual ao limite de taxa de venda configurado.
]], f.bb("TSM"), f.bb("qualquer")),
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_RESTOCK_OPTIONS_TSM_SALE_RATE_TOOLTIP_GENERAL] = string.format(
            [[
Disponível apenas quando %s está carregado!

Será verificado se %s das qualidades de um item têm uma taxa de venda
maior ou igual ao limite de taxa de venda configurado.
]], f.bb("TSM"), f.bb("qualquer")),
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_RESTOCK_OPTIONS_AMOUNT_LABEL] = "Quantidade de Reabastecimento:",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_RESTOCK_OPTIONS_RESTOCK_TOOLTIP] = "Esta é a " ..
            f.bb("quantidade de criações") ..
            " que ficará na fila para tal receita.\n\nA quantidade de itens que você tem em seu inventário e banco das qualidades verificadas será subtraída do valor de reabastecimento no momento do reabastecimento",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_RESTOCK_OPTIONS_ENABLE_RECIPE_LABEL] = "Ativar:",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_RESTOCK_OPTIONS_GENERAL_OPTIONS_LABEL] = "Opções Gerais (Todas as Receitas)",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_RESTOCK_OPTIONS_ENABLE_RECIPE_TOOLTIP] =
        "Se esta opção estiver desligada, a receita será reabastecida de acordo com as opções gerais acima",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_TOTAL_PROFIT_LABEL] = "Lucro Ø Total:",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_TOTAL_CRAFTING_COSTS_LABEL] = "Total de Custos de Criação:",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_EDIT_RECIPE_TITLE] = "Editar Receita",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_EDIT_RECIPE_NAME_LABEL] = "Nome da Receita",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_EDIT_RECIPE_REAGENTS_SELECT_LABEL] = "Selecionar",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_EDIT_RECIPE_OPTIONAL_REAGENTS_LABEL] = "Reagentes Opcionais",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_EDIT_RECIPE_FINISHING_REAGENTS_LABEL] = "Finalizantes",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_EDIT_RECIPE_SPARK_LABEL] = "Fagulha",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_EDIT_RECIPE_PROFESSION_GEAR_LABEL] = "Equipamento de Profissão",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_EDIT_RECIPE_OPTIMIZE_PROFIT_BUTTON] = "Otimizar",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_EDIT_RECIPE_CRAFTING_COSTS_LABEL] = "Custos de Criação: ",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_EDIT_RECIPE_AVERAGE_PROFIT_LABEL] = "Lucro Médio: ",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_EDIT_RECIPE_RESULTS_LABEL] = "Resultados",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_EDIT_RECIPE_CONCENTRATION_CHECKBOX] = " Concentração",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_AUCTIONATOR_SHOPPING_LIST_PER_CHARACTER_CHECKBOX] = "Por Personagem",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_AUCTIONATOR_SHOPPING_LIST_PER_CHARACTER_CHECKBOX_TOOLTIP] = "Cria uma " ..
            f.bb("Lista de Compras do Auctionator") ..
            " para cada personagem\nao invés de uma lista de compras para todos",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_AUCTIONATOR_SHOPPING_LIST_TARGET_MODE_CHECKBOX] = "Apenas Modo Alvo",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_AUCTIONATOR_SHOPPING_LIST_TARGET_MODE_CHECKBOX_TOOLTIP] = "Cria uma " ..
            f.bb("Lista de Compras do Auctionator") .. " apenas para receitas em modo alvo",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_UNSAVED_CHANGES_TOOLTIP] = f.white(
            "Quantidade Não Salva na Fila.\nPressione Enter para Salvar"),
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_STATUSBAR_LEARNED] = f.white("Receita Aprendida"),
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_STATUSBAR_COOLDOWN] = f.white("Não estando em Recarga"),
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_STATUSBAR_REAGENTS] = f.white("Reagentes Disponíveis"),
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_STATUSBAR_GEAR] = f.white("Equipamento de Profissão Equipado"),
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_STATUSBAR_CRAFTER] = f.white("Personagem Criador Correto"),
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_STATUSBAR_PROFESSION] = f.white("Profissão Aberta"),
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_BUTTON_EDIT] = "Editar",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_BUTTON_CRAFT] = "Criar",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_BUTTON_CLAIM] = "Reivindicar",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_BUTTON_CLAIMED] = "Reivindicado",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_BUTTON_NEXT] = "Próximo: ",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_BUTTON_NOTHING_QUEUED] = "Nada na Fila",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_BUTTON_ORDER] = "Ordem",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_BUTTON_SUBMIT] = "Enviar",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_IGNORE_ACUITY_RECIPES_CHECKBOX_LABEL] = "Ignorar Receitas de Acuidade",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_IGNORE_ACUITY_RECIPES_CHECKBOX_TOOLTIP] =
            "Não incluir na fila receitas que usam " .. f.bb("Acuidade do Artesão") .. " para criar",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_AMOUNT_TOOLTIP] = "\n\nCriações na Fila: ",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_ORDER_CUSTOMER] = "\n\nOrdem do Cliente: ",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_ORDER_MINIMUM_QUALITY] = "\nQualidade Mínima: ",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_ORDER_REWARDS] = "\nRecompensas:",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_ORDER_INFO_REAGENTS_IN_YOUR_INVENTORY] = f.r(
            "\n\nTodos os reagentes fornecidos devem estar no seu inventário para criar uma ordem de serviço!"),

        -- cooldowns module

        [CraftSim.CONST.TEXT.COOLDOWNS_TITLE] = "Recargas do CraftSim",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_COOLDOWNS_LABEL] = "Recargas",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_COOLDOWNS_TOOLTIP] = "Visão Geral da " ..
            f.bb("Recargas de Profissões") .. " da sua conta",
        [CraftSim.CONST.TEXT.COOLDOWNS_CRAFTER_HEADER] = "Personagem",
        [CraftSim.CONST.TEXT.COOLDOWNS_RECIPE_HEADER] = "Receita",
        [CraftSim.CONST.TEXT.COOLDOWNS_CHARGES_HEADER] = "Cargas",
        [CraftSim.CONST.TEXT.COOLDOWNS_NEXT_HEADER] = "Próxima Carga",
        [CraftSim.CONST.TEXT.COOLDOWNS_ALL_HEADER] = "Cargas Completas",
        [CraftSim.CONST.TEXT.COOLDOWNS_TAB_OVERVIEW] = "Visão Geral",
        [CraftSim.CONST.TEXT.COOLDOWNS_TAB_OPTIONS] = "Opções",
        [CraftSim.CONST.TEXT.COOLDOWNS_EXPANSION_FILTER_BUTTON] = "Filtrar Expansão",
        [CraftSim.CONST.TEXT.COOLDOWNS_RECIPE_LIST_TEXT_TOOLTIP] = f.bb("\n\nReceitas compartilhando essa Recarga:\n"),
        [CraftSim.CONST.TEXT.COOLDOWNS_RECIPE_READY] = f.g("Disponível"),

        -- concentration module

        [CraftSim.CONST.TEXT.CONCENTRATION_TRACKER_TITLE] = "Concentração do CraftSim",
        [CraftSim.CONST.TEXT.CONCENTRATION_TRACKER_LABEL_CRAFTER] = "Personagem",
        [CraftSim.CONST.TEXT.CONCENTRATION_TRACKER_LABEL_CURRENT] = "Atual",
        [CraftSim.CONST.TEXT.CONCENTRATION_TRACKER_LABEL_MAX] = "Máximo",
        [CraftSim.CONST.TEXT.CONCENTRATION_TRACKER_MAX] = f.g("MAX"),
        [CraftSim.CONST.TEXT.CONCENTRATION_TRACKER_MAX_VALUE] = "Max: ",
        [CraftSim.CONST.TEXT.CONCENTRATION_TRACKER_FULL] = f.g("Concentração Completa"),
        [CraftSim.CONST.TEXT.CONCENTRATION_TRACKER_SORT_MODE_CHARACTER] = "Personagem",
        [CraftSim.CONST.TEXT.CONCENTRATION_TRACKER_SORT_MODE_CONCENTRATION] = "Concentração",
        [CraftSim.CONST.TEXT.CONCENTRATION_TRACKER_SORT_MODE_PROFESSION] = "Profissão",
        [CraftSim.CONST.TEXT.CONCENTRATION_TRACKER_FORMAT_MODE_EUROPE_MAX_DATE] = "Europeu - Data Máxima",
        [CraftSim.CONST.TEXT.CONCENTRATION_TRACKER_FORMAT_MODE_AMERICA_MAX_DATE] = "Americano - Data Máxima",
        [CraftSim.CONST.TEXT.CONCENTRATION_TRACKER_FORMAT_MODE_HOURS_LEFT] = "Horas Restantes",


        -- static popups
        [CraftSim.CONST.TEXT.STATIC_POPUPS_YES] = "Sim",
        [CraftSim.CONST.TEXT.STATIC_POPUPS_NO] = "Não",

        -- frames
        [CraftSim.CONST.TEXT.FRAMES_RESETTING] = "redefinir frameID: ",
        [CraftSim.CONST.TEXT.FRAMES_WHATS_NEW] = "O que há de Novo CraftSim?",
        [CraftSim.CONST.TEXT.FRAMES_JOIN_DISCORD] = "Faça parte do Discord!",
        [CraftSim.CONST.TEXT.FRAMES_DONATE_KOFI] = "Visite o CraftSim no Kofi",
        [CraftSim.CONST.TEXT.FRAMES_NO_INFO] = "Nenhuma Informação",

        -- node data
        [CraftSim.CONST.TEXT.NODE_DATA_RANK_TEXT] = "Classificação ",
        [CraftSim.CONST.TEXT.NODE_DATA_TOOLTIP] = "\n\nEstatísticas totais do talento:\n",

    }
end
