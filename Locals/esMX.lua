---@class CraftSim
local CraftSim = select(2, ...)

local GUTIL = CraftSim.GUTIL
local f = GUTIL:GetFormatter()

CraftSim.LOCAL_MX = {}

---@return table<CraftSim.LOCALIZATION_IDS, string>
function CraftSim.LOCAL_MX:GetData()
    local cm = function(i, s) return CraftSim.MEDIA:GetAsTextIcon(i, s) end
    local shatter_post_login_tooltip = "\n\n" ..
        f.white("Lanza Añicos una vez tras iniciar sesión para que CraftSim registre tu beneficio.")
    return {
        -- REQUIRED:
        STAT_MULTICRAFT = "Fabricación múltiple",
        STAT_RESOURCEFULNESS = "Inventiva",
        STAT_INGENUITY = "Ingenio",
        STAT_CRAFTINGSPEED = "Velocidad de fabricación",
        EQUIP_MATCH_STRING = "Equipar:",
        ENCHANTED_MATCH_STRING = "Encantado:",

        -- OPTIONAL (Defaulting to EN if not available):

        -- shared prof cds
        DF_ALCHEMY_TRANSMUTATIONS = "DF - Transmutaciones",
        MIDNIGHT_ALCHEMY_TRANSMUTATIONS = "Midnight – Transmutaciones",

        -- expansions

        EXPANSION_VANILLA = "Clásico",
        EXPANSION_THE_BURNING_CRUSADE = "The Burning Crusade",
        EXPANSION_WRATH_OF_THE_LICH_KING = "Wrath of the Lich King",
        EXPANSION_CATACLYSM = "Cataclysm",
        EXPANSION_MISTS_OF_PANDARIA = "Mists of Pandaria",
        EXPANSION_WARLORDS_OF_DRAENOR = "Warlords of Draenor",
        EXPANSION_LEGION = "Legion",
        EXPANSION_BATTLE_FOR_AZEROTH = "Battle for Azeroth",
        EXPANSION_SHADOWLANDS = "Shadowlands",
        EXPANSION_DRAGONFLIGHT = "Dragonflight",
        EXPANSION_THE_WAR_WITHIN = "The War Within",
        EXPANSION_MIDNIGHT = "Midnight",

        -- professions

        PROFESSIONS_BLACKSMITHING = "Herrería",
        PROFESSIONS_LEATHERWORKING = "Peletería",
        PROFESSIONS_ALCHEMY = "Alquimia",
        PROFESSIONS_HERBALISM = "Herboristería",
        PROFESSIONS_COOKING = "Cocina",
        PROFESSIONS_MINING = "Minería",
        PROFESSIONS_TAILORING = "Sastrería",
        PROFESSIONS_ENGINEERING = "Ingeniería",
        PROFESSIONS_ENCHANTING = "Encantamiento",
        PROFESSIONS_FISHING = "Pesca",
        PROFESSIONS_SKINNING = "Desuello",
        PROFESSIONS_JEWELCRAFTING = "Joyería",
        PROFESSIONS_INSCRIPTION = "Inscripción",

        -- Other Statnames

        STAT_SKILL = "Habilidad",
        STAT_MULTICRAFT_BONUS = "Fabricación múltiple: objetos extra",
        STAT_RESOURCEFULNESS_BONUS = "Inventiva: objetos extra",
        STAT_CRAFTINGSPEED_BONUS = "Velocidad de fabricación",
        STAT_INGENUITY_BONUS = "Ingenio: Concentración ahorrada",
        STAT_INGENUITY_LESS_CONCENTRATION = "Menos uso de Concentración",
        STAT_PHIAL_EXPERIMENTATION = "Experimentación de viales",
        STAT_POTION_EXPERIMENTATION = "Experimentación de pociones",

        -- Profit Breakdown Tooltips
        RESOURCEFULNESS_EXPLANATION_TOOLTIP =
        "La Inventiva se activa para cada componente individualmente y luego ahorra alrededor del 30% de su cantidad.\n\nEl valor promedio que ahorra es el valor ahorrado promedio de TODA combinación y sus probabilidades.\n(Que todos los componentes se activen a la vez es muy poco probable, pero ahorra mucho)\n\nEl costo promedio total de componentes ahorrados es la suma de los costos de componentes ahorrados de todas las combinaciones ponderadas frente a su probabilidad.",

        RECIPE_DIFFICULTY_EXPLANATION_TOOLTIP =
        "La dificultad de la receta determina dónde están los puntos de ruptura de las diferentes calidades.\n\nPara recetas con cinco calidades, estos están al 20%, 50%, 80% y 100% de la dificultad de la receta como habilidad.\nPara recetas con tres calidades, están al 50% y 100%.",
        MULTICRAFT_EXPLANATION_TOOLTIP =
        "La Fabricación múltiple te da la probabilidad de crear más objetos de los que normalmente producirías con una receta.\n\nLa cantidad adicional suele estar entre 1 y 2.5y\ndonde y = la cantidad habitual que produce 1 fabricación.",
        REAGENTSKILL_EXPLANATION_TOOLTIP =
        "La calidad de tus componentes puede otorgarte un máximo del 40% de la dificultad base de la receta como habilidad adicional.\n\nTodos los componentes de C1: 0% de bonificación\nTodos los componentes de C2: 20% de bonificación\nTodos los componentes de C3: 40% de bonificación\n\nLa habilidad se calcula por la cantidad de componentes de cada calidad ponderada contra su calidad\ny un valor de peso específico que es único para cada objeto de componente de fabricación con calidad.\n\nSin embargo, esto es diferente para las refabricaciones. Ahí, el máximo que los componentes pueden aumentar la calidad\ndepende de la calidad de los componentes con los que el objeto fue fabricado originalmente.\nEl funcionamiento exacto es desconocido.\nNo obstante, CraftSim compara internamente la habilidad alcanzada con todos en C3 y calcula\nel aumento de habilidad máximo en base a eso.",
        REAGENTFACTOR_EXPLANATION_TOOLTIP =
        "El máximo que los componentes pueden aportar a una receta es, en la mayoría de los casos, el 40% de la dificultad base de la receta.\n\nSin embargo, en el caso de las refabricaciones, este valor puede variar según las fabricaciones previas\ny la calidad de los componentes que se utilizaron.",

        -- Simulation Mode
        SIMULATION_MODE_NONE = "Ninguno",
        SIMULATION_MODE_LABEL = "Simular",
        SIMULATION_MODE_TITLE = "Modo de simulación de CraftSim",
        SIMULATION_MODE_TOOLTIP =
        "El modo de simulación de CraftSim te permite experimentar con una receta sin restricciones",
        SIMULATION_MODE_OPTIONAL = "Opcional #",
        SIMULATION_MODE_FINISHING = "Acabado #",
        SIMULATION_MODE_QUALITY_BUTTON_TOOLTIP = "Maximizar todos los componentes de calidad ",
        SIMULATION_MODE_CLEAR_BUTTON = "Limpiar",
        SIMULATION_MODE_CONCENTRATION = " Concentración",
        SIMULATION_MODE_CONCENTRATION_COST = "Costo de Concentración: ",
        CONCENTRATION_ESTIMATED_TIME_UNTIL = "Se puede fabricar a las: %s",
        SIMULATION_MODE_QUALITY_METER_NEEDED = "Necesario: ",
        SIMULATION_MODE_QUALITY_METER_MISSING = "Falta: ",
        SIMULATION_MODE_QUALITY_METER_MAX = "MÁX",

        -- Details Frame
        RECIPE_DIFFICULTY_LABEL = "Dificultad de receta: ",
        MULTICRAFT_LABEL = "Fabricación múltiple: ",
        RESOURCEFULNESS_LABEL = "Inventiva: ",
        RESOURCEFULNESS_BONUS_LABEL = "Bonificación de objetos de Inventiva: ",
        INGENUITY_LABEL = "Ingenio: ",
        INGENUITY_EXPLANATION_TOOLTIP =
        "Ingenio te otorga la probabilidad de recibir un reembolso parcial de la concentración gastada al fabricar con concentración.",
        CONCENTRATION_LABEL = "Concentración: ",
        REAGENT_QUALITY_BONUS_LABEL = "Bonificación de calidad de componentes: ",
        REAGENT_QUALITY_MAXIMUM_LABEL = "Máximo de calidad de componentes %: ",
        EXPECTED_QUALITY_LABEL = "Calidad esperada: ",
        NEXT_QUALITY_LABEL = "Siguiente calidad: ",
        MISSING_SKILL_LABEL = "Habilidad faltante: ",
        SKILL_LABEL = "Habilidad: ",
        MULTICRAFT_BONUS_LABEL = "Bonificación de objetos de Fabricación múltiple: ",

        -- Statistics
        STATISTICS_CDF_EXPLANATION =
        "Esto se calcula usando la aproximación de 'Abramowitz y Stegun' (1985) de la CDF (Función de Distribución Acumulativa)\n\nNotarás que siempre está alrededor del 50% para 1 fabricación.\nEsto se debe a que el 0 está casi siempre cerca de la ganancia promedio.\nY la probabilidad de obtener la media de la CDF siempre es del 50%.\n\nSin embargo, la tasa de cambio puede ser muy diferente entre recetas.\nSi es más probable tener una ganancia positiva que una negativa, aumentará constantemente.\nEsto es, por supuesto, también cierto para la otra dirección.",
        EXPLANATIONS_PROFIT_CALCULATION_EXPLANATION = f.r("Advertencia: ") .. " ¡Vienen matemáticas!\n\n" ..
            "Cuando fabricas algo, tienes diferentes probabilidades de obtener distintos resultados según tus estadísticas de fabricación.\n" ..
            "Y en estadística, a esto se le llama " .. f.l("Distribución de probabilidad.\n") ..
            "Sin embargo, notarás que las diferentes probabilidades de tus activaciones no suman uno\n" ..
            "(Lo cual es necesario para tal distribución, ya que significa que tienes un 100% de probabilidad de que algo ocurra)\n\n" ..
            "Esto se debe a que activaciones como " ..
            f.bb("Inventiva ") .. "y" .. f.bb(" Fabricación múltiple") .. " pueden ocurrir " .. f.g("al mismo tiempo.\n") ..
            "Así que primero necesitamos convertir nuestras probabilidades de activación en una " ..
            f.l("Distribución de probabilidad ") .. " con probabilidades\n" ..
            "que sumen 100% (Lo que significaría que todos los casos están cubiertos)\n" ..
            "Y para esto tendríamos que calcular " .. f.l("cada") .. " posible resultado de una fabricación\n\n" ..
            "Como: \n" ..
            f.p .. "¿Y si " .. f.bb("nada") .. " se activa?\n" ..
            f.p .. "¿Y si se activa " .. f.bb("Inventiva") .. " o " .. f.bb("Fabricación múltiple") .. "?\n" ..
            f.p .. "¿Y si ambas, " .. f.bb("Inventiva") .. " y " .. f.bb("Fabricación múltiple") .. " se activan?\n" ..
            f.p .. "Y así sucesivamente...\n\n" ..
            "Para una receta que considera todas las activaciones, eso sería 2 elevado a la potencia de 2 posibilidades de resultado, lo que es un limpio 4.\n" ..
            "Para obtener la probabilidad de que solo ocurra " ..
            f.bb("Fabricación múltiple") .. ", ¡tenemos que considerar todas las demás posibilidades!\n" ..
            "La probabilidad de activar " ..
            f.l("solo") .. f.bb(" Fabricación múltiple ") .. "es en realidad la probabilidad de activar " .. f.bb("Fabricación múltiple\n") ..
            "y " .. f.l("no ") .. "activar " .. f.bb("Inventiva\n") ..
            "Y las matemáticas nos dicen que la probabilidad de que algo no ocurra es 1 menos la probabilidad de que ocurra.\n" ..
            "Así que la probabilidad de activar solo " ..
            f.bb("Fabricación múltiple ") ..
            "es en realidad " .. f.g("multicraftChance * (1-resourcefulnessChance)\n\n") ..
            "Después de calcular cada posibilidad de esa manera, ¡las probabilidades individuales de hecho suman uno!\n" ..
            "Lo que significa que ahora podemos aplicar fórmulas estadísticas. La más interesante en nuestro caso es el " ..
            f.bb("Valor esperado") .. "\n" ..
            "Que es, como su nombre indica, el valor que podemos esperar obtener en promedio, o en nuestro caso, la " ..
            f.bb(" ganancia esperada para una fabricación!\n") ..
            "\n" .. cm(CraftSim.MEDIA.IMAGES.EXPECTED_VALUE) .. "\n\n" ..
            "Esto nos dice que el valor esperado " ..
            f.l("E") ..
            " de una distribución de probabilidad " ..
            f.l("X") .. " es la suma de todos sus valores multiplicados por su probabilidad.\n" ..
            "Así que si tenemos un " ..
            f.bb("caso A con probabilidad del 30%") ..
            " y una ganancia de " ..
            GUTIL:FormatMoney(-100 * 10000, true, 0, true, false, false) ..
            " y un " ..
            f.bb("caso B con probabilidad del 70%") ..
            " y una ganancia de " ..
            GUTIL:FormatMoney(300 * 10000, true, 0, true, false, false) .. " entonces la ganancia esperada de eso es\n" ..
            f.bb("\nE(X) = -100*0.3 + 300*0.7  ") ..
            "que es " .. GUTIL:FormatMoney((-100 * 0.3 + 300 * 0.7) * 10000, true, 0, true, false, false) .. "\n" ..
            "¡Puedes ver todos los casos de tu receta actual en la ventana de " .. f.bb("Estadísticas") .. "!"
        ,

        -- Popups
        POPUP_NO_PRICE_SOURCE_SYSTEM = "¡No hay una fuente de precios compatible disponible!",
        POPUP_NO_PRICE_SOURCE_TITLE = "Advertencia de fuente de precios de CraftSim",
        POPUP_NO_PRICE_SOURCE_WARNING =
        "¡No se encontró ninguna fuente de precios!\n\nNecesitas tener instalado al menos uno de los\nsiguientes addons de fuente de precios para\nutilizar los cálculos de ganancias de CraftSim:\n\n\n",
        POPUP_NO_PRICE_SOURCE_WARNING_SUPPRESS = "No volver a mostrar la advertencia",
        POPUP_NO_PRICE_SOURCE_WARNING_ACCEPT = "OK",

        -- Reagents Frame
        REAGENT_OPTIMIZATION_TITLE = "Optimización de componentes de CraftSim",
        REAGENTS_REACHABLE_QUALITY = "Calidad alcanzable: ",
        REAGENTS_MISSING = "Componentes faltantes",
        REAGENTS_AVAILABLE = "Componentes disponibles",
        REAGENTS_CHEAPER = "Componentes más baratos",
        REAGENTS_BEST_COMBINATION = "Mejor combinación asignada",
        REAGENTS_NO_COMBINATION = "No se encontró ninguna combinación \npara aumentar la calidad",
        REAGENTS_ASSIGN = "Asignar",
        REAGENTS_MAXIMUM_QUALITY = "Calidad máxima: ",
        REAGENTS_AVERAGE_PROFIT_LABEL = "Ganancia Ø promedio: ",
        REAGENTS_AVERAGE_PROFIT_TOOLTIP = f.bb("La ganancia promedio por fabricación") ..
            " al usar " .. f.l("esta asignación de componentes"),
        REAGENTS_OPTIMIZE_BEST_ASSIGNED = "Mejores componentes asignados",
        REAGENTS_CONCENTRATION_LABEL = "Concentración: ",
        REAGENTS_OPTIMIZE_INFO = "Shift + clic izquierdo en los números para poner el enlace del objeto en el chat",
        ADVANCED_OPTIMIZATION_BUTTON = "Optimización avanzada",
        REAGENTS_OPTIMIZE_TOOLTIP = "(Se reinicia al editar)\nHabilita la Optimización de " ..
            f.gold("Valor de Concentración") .. " y " .. f.bb("Componentes de Acabado "),

        -- Specialization Info Frame
        SPEC_INFO_TITLE = "Información de especialización de CraftSim",
        SPEC_INFO_SIMULATE_KNOWLEDGE_DISTRIBUTION = "Simular distribución de conocimiento",
        SPEC_INFO_NODE_TOOLTIP = "Este nodo te otorga las siguientes estadísticas para esta receta:",
        SPEC_INFO_WORK_IN_PROGRESS = "No hay datos disponibles",

        -- Crafting Results Frame
        CRAFT_LOG_TITLE = "Registro de fabricación de CraftSim",
        CRAFT_LOG_ADV_TITLE = "Registro de fabricación avanzado de CraftSim",
        CRAFT_LOG_LOG = "Registro de fabricación",
        CRAFT_LOG_LOG_1 = "Ganancia: ",
        CRAFT_LOG_LOG_2 = "Concentración ahorrada: ",
        CRAFT_LOG_LOG_3 = "Fabricación múltiple: ",
        CRAFT_LOG_LOG_4 = "Recursos ahorrados: ",
        CRAFT_LOG_LOG_5 = "Probabilidad: ",
        CRAFT_LOG_CRAFTED_ITEMS = "Objetos fabricados",
        CRAFT_LOG_SESSION_PROFIT = "Ganancia de la sesión: ",
        CRAFT_LOG_RESET_DATA = "Reiniciar datos",
        CRAFT_LOG_EXPORT_JSON = "Exportar JSON",
        CRAFT_LOG_RECIPE_STATISTICS = "Estadísticas de la receta",
        CRAFT_LOG_NOTHING = "¡Nada fabricado aún!",
        CRAFT_LOG_CALCULATION_COMPARISON_NUM_CRAFTS_PREFIX = "Fabricaciones: ",
        CRAFT_LOG_STATISTICS_2 = "Ganancia Ø esperada: ",
        CRAFT_LOG_STATISTICS_3 = "Ganancia Ø real: ",
        CRAFT_LOG_STATISTICS_4 = "Ganancia real: ",
        CRAFT_LOG_STATISTICS_5 = "Activaciones - Real / Esperado: ",
        CRAFT_LOG_STATISTICS_7 = "Fabricación múltiple: ",
        CRAFT_LOG_STATISTICS_8 = "- Ø Objetos extra: ",
        CRAFT_LOG_STATISTICS_9 = "Activaciones de Inventiva: ",
        CRAFT_LOG_CALCULATION_COMPARISON_NUM_CRAFTS_PREFIX0 = "- Ø Costos ahorrados: ",
        CRAFT_LOG_CALCULATION_COMPARISON_NUM_CRAFTS_PREFIX1 = "Ganancia: ",
        CRAFT_LOG_SAVED_REAGENTS = "Componentes ahorrados",
        CRAFT_LOG_DISABLE_CHECKBOX = f.r("Deshabilitar") .. " Registros de fabricación",
        CRAFT_LOG_DISABLE_CHECKBOX_TOOLTIP = "Habilitar esto detiene el registro de cualquier fabricación al crear objetos y puede " ..
            f.g("mejorar el rendimiento"),
        CRAFT_LOG_REAGENT_DETAILS_TAB = "Detalles de componentes",
        CRAFT_LOG_RESULT_ANALYSIS_TAB = "Análisis de resultados",
        CRAFT_LOG_RESULT_ANALYSIS_TAB_DISTRIBUTION_LABEL = "Distribución de resultados",
        CRAFT_LOG_RESULT_ANALYSIS_TAB_DISTRIBUTION_HELP =
        "Distribución relativa de los resultados de objetos fabricados.\n(Ignorando cantidades de Fabricación múltiple)",
        CRAFT_LOG_RESULT_ANALYSIS_TAB_MULTICRAFT = "Fabricación múltiple",
        CRAFT_LOG_RESULT_ANALYSIS_TAB_RESOURCEFULNESS = "Inventiva",
        CRAFT_LOG_RESULT_ANALYSIS_TAB_YIELD_DDISTRIBUTION = "Distribución de producción",

        -- Stats Weight Frame
        STAT_WEIGHTS_TITLE = "Ganancia promedio de CraftSim",
        EXPLANATIONS_TITLE = "Explicación de ganancia promedio de CraftSim",
        STAT_WEIGHTS_SHOW_EXPLANATION_BUTTON = "Mostrar explicación",
        STAT_WEIGHTS_HIDE_EXPLANATION_BUTTON = "Ocultar explicación",
        STAT_WEIGHTS_SHOW_STATISTICS_BUTTON = "Mostrar estadísticas",
        STAT_WEIGHTS_HIDE_STATISTICS_BUTTON = "Ocultar estadísticas",
        STAT_WEIGHTS_PROFIT_CRAFT = "Ø Ganancia / Fabr.: ",
        EXPLANATIONS_BASIC_PROFIT_TAB = "Cálculo de ganancia básica",

        -- Recipe Info Frame
        RECIPE_INFO_TITLE = "Información de receta de CraftSim",
        RECIPE_INFO_OPTIONS_TOOLTIP = "Alternar datos mostrados",
        RECIPE_INFO_RESULT_ITEMS_LABEL = "Objetos resultantes: ",
        RECIPE_INFO_CRAFTING_COST_LABEL = "Costo de fabricación: ",
        RECIPE_INFO_AVG_CRAFTING_COST_LABEL = "Ø Costo de fabricación: ",
        RECIPE_INFO_KNOWLEDGE_POINTS_LABEL = "Puntos de conocimiento: ",
        RECIPE_INFO_AVG_YIELD_LABEL = "Ø Producción: ",
        RECIPE_INFO_AVG_MULTICRAFT_ITEMS_LABEL = "Ø Objetos extra (FM): ",
        RECIPE_INFO_AVG_RESOURCEFULNESS_SAVED_LABEL = "Ø Inv. Ahorrada: ",
        RECIPE_INFO_CONCENTRATION_PROFIT_LABEL = "Ganancia de Conc.: ",
        RECIPE_INFO_CONCENTRATION_COST_LABEL = "Costo base de Conc.: ",
        -- Recipe Info context menu option labels (stat-weight rows, default on)
        RECIPE_INFO_OPTION_AVG_PROFIT = "Ganancia promedio",
        RECIPE_INFO_OPTION_AVG_PROFIT_TOOLTIP = "Muestra la ganancia promedio por fabricación basándose en tus estadísticas de profesión",
        RECIPE_INFO_OPTION_MULTICRAFT_WEIGHT = "Peso de Fabricación múltiple",
        RECIPE_INFO_OPTION_MULTICRAFT_WEIGHT_TOOLTIP =
        "Muestra el aumento de ganancia por punto de Fabricación múltiple",
        RECIPE_INFO_OPTION_RESOURCEFULNESS_WEIGHT = "Peso de Inventiva",
        RECIPE_INFO_OPTION_RESOURCEFULNESS_WEIGHT_TOOLTIP =
        "Muestra el aumento de ganancia por punto de Inventiva",
        RECIPE_INFO_OPTION_CONCENTRATION_WEIGHT = "Peso de Concentración",
        RECIPE_INFO_OPTION_CONCENTRATION_WEIGHT_TOOLTIP =
        "Muestra la ganancia por punto de Concentración, teniendo en cuenta el reembolso de Ingenio",
        -- Recipe Info context menu option labels (extra rows, default off)
        RECIPE_INFO_OPTION_CRAFTING_COST = "Costo de fabricación",
        RECIPE_INFO_OPTION_CRAFTING_COST_TOOLTIP = "Muestra el costo total de fabricación para una creación",
        RECIPE_INFO_OPTION_AVG_CRAFTING_COST = "Costo de fabricación promedio",
        RECIPE_INFO_OPTION_AVG_CRAFTING_COST_TOOLTIP =
        "Muestra el costo promedio de fabricación por creación considerando Inventiva",
        RECIPE_INFO_OPTION_RESULT_ICONS = "Iconos de objetos resultantes",
        RECIPE_INFO_OPTION_RESULT_ICONS_TOOLTIP = "Muestra iconos para cada posible calidad del objeto resultante",
        RECIPE_INFO_OPTION_KNOWLEDGE_POINTS = "Puntos de conocimiento",
        RECIPE_INFO_OPTION_KNOWLEDGE_POINTS_TOOLTIP =
        "Muestra los puntos de conocimiento asignados vs los máximos para los nodos que afectan a esta receta",
        RECIPE_INFO_OPTION_AVG_YIELD = "Producción promedio",
        RECIPE_INFO_OPTION_AVG_YIELD_TOOLTIP = "Muestra la producción promedio de objetos por creación considerando Fabricación múltiple",
        RECIPE_INFO_OPTION_AVG_MULTICRAFT_ITEMS = "Objetos extra promedio por Fabricación múltiple",
        RECIPE_INFO_OPTION_AVG_MULTICRAFT_ITEMS_TOOLTIP =
        "Muestra el número promedio de objetos extra obtenidos por creación a partir de activaciones de Fabricación múltiple",
        RECIPE_INFO_OPTION_AVG_RESOURCEFULNESS_SAVED = "Costos ahorrados promedio (Inventiva)",
        RECIPE_INFO_OPTION_AVG_RESOURCEFULNESS_SAVED_TOOLTIP =
        "Muestra los costos de componentes promedio ahorrados por creación a partir de activaciones de Inventiva",
        RECIPE_INFO_OPTION_CONCENTRATION_PROFIT = "Ganancia promedio (con Concentración)",
        RECIPE_INFO_OPTION_CONCENTRATION_PROFIT_TOOLTIP =
        "Muestra la ganancia promedio por creación al usar Concentración",
        RECIPE_INFO_OPTION_CONCENTRATION_COST = "Costo de Concentración",
        RECIPE_INFO_OPTION_CONCENTRATION_COST_TOOLTIP =
        "Muestra el costo de puntos de Concentración base para una creación",
        RECIPE_INFO_OPTION_PROFIT_PER_QUALITY = "Ganancia por calidad",
        RECIPE_INFO_OPTION_PROFIT_PER_QUALITY_TOOLTIP =
        "Muestra la ganancia estimada para cada posible calidad resultante (precio de venta menos costo de fabricación)",
        RECIPE_INFO_QUALITY_PROFIT_LABEL = "Ganancia:",

        -- Cost Details Frame
        PRICING_TITLE = "Precios de CraftSim",
        PRICING_EXPLANATION = "Aquí puedes ver un resumen de todos los precios posibles de los componentes utilizados.\nLa columna " ..
            f.bb("'Fuente'") ..
            " indica cuál de los precios se está utilizando.\n\n" ..
            f.g("SU") ..
            " .. Precio de Subasta\n" ..
            f.l("SO") ..
            " .. Precio Sobrescrito\n" ..
            f.l("SO") ..
            " siempre se utilizará si está configurado.\n\n" ..
            f.bb("Clic derecho") .. " en cualquier componente o resultado para sobrescribir su precio con un valor personalizado",
        PRICING_CRAFTING_COSTS = "Costos de fabricación: ",
        PRICING_ITEM_HEADER = "Objeto",
        PRICING_DELETE_ALL_OVERRIDES = "Eliminar todas las sobrescrituras",
        COST_OPTIMIZATION_PRICE_HEADER = "Precio",
        COST_OPTIMIZATION_USED_SOURCE = "Fuente",
        PRICING_AVG_CRAFTING_COST = "Ø Costo de fabricación",
        COST_OPTIMIZATION_SUB_RECIPE_OPTIMIZATION_TOOLTIP = "Si está habilitado, " ..
            f.l("CraftSim") .. " considera los " .. f.g("costos de fabricación optimizados") ..
            " de tu personaje y tus alters\nsi son capaces de fabricar ese objeto.\n\n" ..
            f.r("Podría disminuir un poco el rendimiento debido a muchos cálculos adicionales"),
        COST_OPTIMIZATION_SUB_RECIPE_MAX_DEPTH_LABEL = "Profundidad de cálculo de sub-recetas",
        COST_OPTIMIZATION_SUB_RECIPE_INCLUDE_CONCENTRATION = "Habilitar Concentración",
        COST_OPTIMIZATION_SUB_RECIPE_INCLUDE_CONCENTRATION_TOOLTIP = "Si está habilitado, " ..
            f.l("CraftSim") .. " incluirá calidades de componentes incluso si la concentración es necesaria.",
        COST_OPTIMIZATION_SUB_RECIPE_INCLUDE_COOLDOWN_RECIPES = "Incluir recetas con tiempo de reutilización",
        COST_OPTIMIZATION_SUB_RECIPE_INCLUDE_COOLDOWN_RECIPES_TOOLTIP = "Si está habilitado, " ..
            f.l("CraftSim") .. " ignorará los requisitos de tiempo de reutilización de las recetas al calcular componentes fabricados por uno mismo",
        COST_OPTIMIZATION_SUB_RECIPE_SELECT_RECIPE_CRAFTER = "Seleccionar artesano de receta",
        PRICING_REAGENT_LIST_AH_COLUMN_AUCTION_BUYOUT = "Compra en subasta: ",
        PRICING_REAGENT_LIST_OVERRIDE = "\n\nSobrescribir",
        PRICING_REAGENT_LIST_EXPECTED_COSTS_TOOLTIP = "\n\nFabricación ",
        PRICING_REAGENT_LIST_EXPECTED_COSTS_PRE_ITEM = "\n- Costos esperados por objeto: ",
        PRICING_REAGENT_LIST_CONCENTRATION_COST = f.gold("Costo de Concentración: "),
        PRICING_REAGENT_LIST_CONCENTRATION = "Concentración: ",

        -- Statistics Frame
        STATISTICS_TITLE = "Estadísticas de CraftSim",
        STATISTICS_EXPECTED_PROFIT = "Ganancia esperada (μ)",
        STATISTICS_CHANCE_OF = "Probabilidad de ",
        STATISTICS_PROFIT = "Ganancia",
        STATISTICS_AFTER = " después de",
        STATISTICS_CRAFTS = "Fabricaciones: ",
        STATISTICS_QUALITY_HEADER = "Calidad",
        STATISTICS_MULTICRAFT_HEADER = "Fabricación múltiple",
        STATISTICS_RESOURCEFULNESS_HEADER = "Inventiva",
        STATISTICS_EXPECTED_PROFIT_HEADER = "Ganancia esperada",
        PROBABILITY_TABLE_TITLE = "Tabla de probabilidad de receta",
        STATISTICS_PROBABILITY_TABLE_TAB = "Tabla de probabilidad",
        STATISTICS_CONCENTRATION_TAB = "Concentración",
        STATISTICS_CONCENTRATION_CURVE_GRAPH = "Curva de costo de Concentración",
        STATISTICS_CONCENTRATION_CURVE_GRAPH_HELP = "Costo de Concentración basado en la Habilidad del jugador para la receta dada\n" ..
            f.bb("Eje X: ") .. " Habilidad del jugador\n" ..
            f.bb("Eje Y: ") .. " Costo de Concentración",

        -- Price Details Frame
        COST_OVERVIEW_TITLE = "Detalles de precios de CraftSim",
        PRICE_DETAILS_INV_AH = "Inv/SU",
        PRICE_DETAILS_ITEM = "Objeto",
        PRICE_DETAILS_PRICE_ITEM = "Precio/Obj.",
        PRICE_DETAILS_PROFIT_ITEM = "Ganancia/Obj.",

        -- Price Override Frame
        PRICE_OVERRIDE_TITLE = "Sobrescritura de precios de CraftSim",
        PRICE_OVERRIDE_HINT = "(Ahora puedes sobrescribir precios directamente en el " .. f.bb("Módulo de optimización de costos") .. ")",
        PRICE_OVERRIDE_REQUIRED_REAGENTS = "Componentes requeridos",
        PRICE_OVERRIDE_OPTIONAL_REAGENTS = "Componentes opcionales",
        PRICE_OVERRIDE_FINISHING_REAGENTS = "Componentes de acabado",
        PRICE_OVERRIDE_RESULT_ITEMS = "Objetos resultantes",
        PRICE_OVERRIDE_ACTIVE_OVERRIDES = "Sobrescrituras activas",
        PRICE_OVERRIDE_ACTIVE_OVERRIDES_TOOLTIP =
        "'(como resultado)' -> la sobrescritura de precio solo se considera cuando el objeto es el resultado de una receta",
        PRICE_OVERRIDE_CLEAR_ALL = "Limpiar todo",
        PRICE_OVERRIDE_SAVE = "Guardar",
        PRICE_OVERRIDE_SAVED = "Guardado",
        PRICE_OVERRIDE_REMOVE = "Eliminar",

        -- Recipe Scan Frame
        RECIPE_SCAN_TITLE = "Escáner de recetas de CraftSim",
        RECIPE_SCAN_MODE = "Modo de escaneo",
        RECIPE_SCAN_SORT_MODE = "Modo de clasificación",
        RECIPE_SCAN_SCAN_RECIPIES = "Escanear recetas",
        RECIPE_SCAN_SCAN_CANCEL = "Cancelar",
        RECIPE_SCAN_SCANNING = "Escaneando",
        RECIPE_SCAN_INCLUDE_NOT_LEARNED = "Incluir no aprendidas",
        RECIPE_SCAN_INCLUDE_NOT_LEARNED_TOOLTIP = "Incluye recetas que no has aprendido en el escaneo de recetas",
        RECIPE_SCAN_INCLUDE_SOULBOUND = "Incluir ligadas al alma",
        RECIPE_SCAN_INCLUDE_SOULBOUND_TOOLTIP =
        "Incluye recetas ligadas al alma en el escaneo de recetas.\n\nSe recomienda establecer una sobrescritura de precio (ej. para simular una comisión objetivo)\nen el Módulo de Sobrescritura de Precios para los objetos fabricados de esa receta",
        RECIPE_SCAN_INCLUDE_GEAR = "Incluir equipamiento",
        RECIPE_SCAN_INCLUDE_GEAR_TOOLTIP = "Incluye toda forma de recetas de equipamiento en el escaneo de recetas",
        RECIPE_SCAN_OPTIMIZE_TOOLS = "Optimizar herramientas de profesión",
        RECIPE_SCAN_OPTIMIZE_TOOLS_TOOLTIP = "Para cada receta, optimiza tus herramientas de profesión para obtener ganancias\n\n",
        RECIPE_SCAN_OPTIMIZE_TOOLS_WARNING =
        "Podría disminuir el rendimiento durante el escaneo\nsi tienes muchas herramientas en tu inventario",
        RECIPE_SCAN_CRAFTER_HEADER = "Artesano",
        RECIPE_SCAN_RECIPE_HEADER = "Receta",
        RECIPE_SCAN_LEARNED_HEADER = "Aprendida",
        RECIPE_SCAN_RESULT_HEADER = "Resultado",
        RECIPE_SCAN_AVERAGE_PROFIT_HEADER = "Ø Ganancia",
        RECIPE_SCAN_CONCENTRATION_VALUE_HEADER = "V. Conc.",
        RECIPE_SCAN_CONCENTRATION_COST_HEADER = "C. Conc.",
        RECIPE_SCAN_TOP_GEAR_HEADER = "Equip. Sup.",
        RECIPE_SCAN_INV_AH_HEADER = "Inv",
        RECIPE_SCAN_SORT_BY_MARGIN = "Ordenar por % de Ganancia",
        RECIPE_SCAN_SORT_BY_MARGIN_TOOLTIP =
        "Ordena la lista de ganancias por la ganancia relativa a los costos de fabricación.\n(Requiere un nuevo escaneo)",
        RECIPE_SCAN_USE_INSIGHT_CHECKBOX = "Usar " .. f.bb("Perspicacia") .. " si es posible",
        RECIPE_SCAN_USE_INSIGHT_CHECKBOX_TOOLTIP = "Usa " ..
            f.bb("Perspicacia ilustre") ..
            " o\n" .. f.bb("Perspicacia ilustre inferior") .. " como componente opcional para las recetas que lo permitan.",
        RECIPE_SCAN_ONLY_FAVORITES_CHECKBOX = "Solo favoritas",
        RECIPE_SCAN_ONLY_FAVORITES_CHECKBOX_TOOLTIP = "Escanea solo tus recetas favoritas",
        RECIPE_SCAN_EQUIPPED = "Equipado",
        RECIPE_SCAN_MODE_OPTIMIZE = "Optimizar",
        RECIPE_SCAN_SORT_MODE_PROFIT = "Ganancia",
        RECIPE_SCAN_SORT_MODE_RELATIVE_PROFIT = "Ganancia relativa",
        RECIPE_SCAN_SORT_MODE_CONCENTRATION_VALUE = "Valor de Concentración",
        RECIPE_SCAN_SORT_MODE_CONCENTRATION_COST = "Costo de Concentración",
        RECIPE_SCAN_SORT_MODE_CRAFTING_COST = "Costo de fabricación",
        RECIPE_SCAN_EXPANSION_FILTER_BUTTON = "Filtro de expansión",
        RECIPE_SCAN_CATEGORY_FILTER_BUTTON = "Filtro de categoría",
        RECIPE_SCAN_CATEGORY_FILTER_ENABLE_ALL = "Habilitar todo",
        RECIPE_SCAN_ALTPROFESSIONS_FILTER_BUTTON = "Profesiones de alters",
        RECIPE_SCAN_SCAN_ALL_BUTTON_READY = "Escanear profesiones",
        RECIPE_SCAN_SCAN_ALL_BUTTON_SCANNING = "Escaneando...",
        RECIPE_SCAN_TAB_LABEL_SCAN = "Escaneo de recetas",
        RECIPE_SCAN_TAB_LABEL_OPTIONS = "Opciones de escaneo",
        RECIPE_SCAN_IMPORT_ALL_PROFESSIONS_CHECKBOX_LABEL = "Todas las profesiones escaneadas",
        RECIPE_SCAN_IMPORT_ALL_PROFESSIONS_CHECKBOX_TOOLTIP = f.g("Verdadero: ") ..
            "Importar resultados de escaneo de todas las profesiones habilitadas y escaneadas\n\n" ..
            f.r("Falso: ") .. "Importar resultados de escaneo solo de la profesión actualmente seleccionada",
        RECIPE_SCAN_CACHED_RECIPES_TOOLTIP = "Cada vez que abres o escaneas una receta en un personaje, " ..
            f.l("CraftSim") ..
            " la recuerda.\n\nSolo las recetas de tus alters que " ..
            f.l("CraftSim") .. " pueda recordar serán escaneadas con el " .. f.bb("Escáner de recetas\n\n") ..
            "La cantidad real de recetas que se escanean dependerá entonces de tus " .. f.e("Opciones de escaneo de recetas"),
        RECIPE_SCAN_CONCENTRATION_TOGGLE = " Concentración",
        RECIPE_SCAN_CONCENTRATION_TOGGLE_TOOLTIP = "Alternar Concentración",
        RECIPE_SCAN_OPTIMIZE_SUBRECIPES = "Optimizar sub-recetas " .. f.bb("(experimental)"),
        RECIPE_SCAN_OPTIMIZE_SUBRECIPES_TOOLTIP = "Si está habilitado, " ..
            f.l("CraftSim") .. " también optimiza las creaciones de recetas de componentes en caché de las recetas escaneadas y usa sus\n" ..
            f.bb("costos esperados") .. " para calcular los costos de fabricación del producto final.\n\n" ..
            f.r("Advertencia: Esto podría reducir el rendimiento del escaneo"),
        RECIPE_SCAN_CACHED_RECIPES = "Recetas en caché: ",
        RECIPE_SCAN_ENABLE_CONCENTRATION = f.bb("Habilitar ") .. f.gold("Concentración"),
        RECIPE_SCAN_ONLY_FAVORITES = f.r("Solo ") .. f.bb("Favoritas"),
        RECIPE_SCAN_INCLUDE_SOULBOUND_ITEMS = "Incluir objetos " .. f.e("Ligados al alma"),
        RECIPE_SCAN_INCLUDE_UNLEARNED_RECIPES = "Incluir recetas " .. f.r("No aprendidas"),
        RECIPE_SCAN_INCLUDE_GEAR_LABEL = "Incluir equipamiento",
        RECIPE_SCAN_INV_COUNT_INCLUDE_ALTS_LABEL = "Incluir inventario de " .. f.bb("Alters"),
        RECIPE_SCAN_REAGENT_ALLOCATION = "Asignación de componentes",
        RECIPE_SCAN_REAGENT_ALLOCATION_Q1 = "Todos C1",
        RECIPE_SCAN_REAGENT_ALLOCATION_Q2 = "Todos C2",
        RECIPE_SCAN_REAGENT_ALLOCATION_Q3 = "Todos C3",
        RECIPE_SCAN_AUTOSELECT_TOP_PROFIT = "Autoseleccionar " .. f.g("Mejor ganancia"),
        RECIPE_SCAN_OPTIMIZE_PROFESSION_GEAR = "Optimizar " .. f.bb("Equipamiento de profesión"),
        RECIPE_SCAN_OPTIMIZE_CONCENTRATION = "Optimizar " .. f.gold("Concentración"),
        RECIPE_SCAN_OPTIMIZE_FINISHING_REAGENTS = "Optimizar " .. f.bb("Componentes de acabado"),

        -- Shared OptimizationOptions Widget
        OPTIMIZATION_OPTIONS_OPTIMIZE_PROFESSION_TOOLS = "Optimizar " .. f.bb("Herramientas de profesión"),
        OPTIMIZATION_OPTIONS_INCLUDE_SOULBOUND_FINISHING_REAGENTS = "Incluir " ..
            f.e("Componentes de acabado ") .. f.bb("Ligados al alma"),
        OPTIMIZATION_OPTIONS_ONLY_HIGHEST_QUALITY_SOULBOUND_FINISHING_REAGENTS = "Solo " ..
            f.g("Calidad máxima") .. " de " .. f.e("Componentes de acabado ") .. f.bb("Ligados al alma"),
        OPTIMIZATION_OPTIONS_ONLY_HIGHEST_QUALITY_SOULBOUND_FINISHING_REAGENTS_TOOLTIP =
            "Cuando está habilitado, para cada ranura de componente de acabado solo se considera el componente ligado al alma de mayor calidad que poseas.\n\nPor ejemplo, si tienes tanto una " ..
            f.e("Matriz de fabricación múltiple") ..
            " como un " .. f.e("Colector de fabricación múltiple") .. " en tus bolsas, solo se usará el Colector.",
        OPTIMIZATION_OPTIONS_FINISHING_REAGENTS_ALGORITHM = "Algoritmo de " .. f.bb("Componentes de acabado"),
        OPTIMIZATION_OPTIONS_FINISHING_REAGENTS_SIMPLE = "Simple",
        OPTIMIZATION_OPTIONS_FINISHING_REAGENTS_SIMPLE_TOOLTIP =
        "Optimiza la asignación de componentes primero, luego la concentración, y luego selecciona el mejor componente de acabado para cada ranura individualmente.",
        OPTIMIZATION_OPTIONS_FINISHING_REAGENTS_PERMUTATION = "Basado en permutaciones",
        OPTIMIZATION_OPTIONS_FINISHING_REAGENTS_PERMUTATION_TOOLTIP =
            "Prueba todas las combinaciones posibles de componentes de acabado y, para cada una, optimiza individualmente los componentes (si está habilitado) y la concentración (si está habilitada), para luego seleccionar la combinación más rentable.\n\n" ..
            f.r("Advertencia: Esto puede tomar significativamente más tiempo en completarse."),

        RECIPE_SCAN_SEND_TO_CRAFT_QUEUE = "Enviar a Cola de fabricación",
        RECIPE_SCAN_CREATE_CRAFT_LIST = "Crear Lista de fabricación",
        RECIPE_SCAN_SEND_TO_CRAFTQUEUE_CREATE_CRAFT_LIST = "Crear " .. f.bb("Lista de fabricación") .. " en su lugar",
        RECIPE_SCAN_ADD_TO_CRAFT_LIST = f.g("Añadir") .. " a Lista de fabricación",
        RECIPE_SCAN_REMOVE_FROM_CRAFT_LIST = f.r("Eliminar") .. " de Lista de fabricación",
        RECIPE_SCAN_CRAFT_LISTS_TOOLTIP_HEADER = f.bb("Listas de fabricación") .. ":",
        RECIPE_SCAN_PROFIT_MARGIN_THRESHOLD = "Umbral de margen de ganancia (%): ",
        RECIPE_SCAN_DEFAULT_QUEUE_AMOUNT = "Cantidad predeterminada en cola: ",
        RECIPE_SCAN_ADD_TO_CRAFT_QUEUE = "Añadir a Cola de fabricación",
        RECIPE_SCAN_SORT_BY = "Ordenar por",
        RECIPE_SCAN_SORT_ASCENDING = "Ascendente",
        RECIPE_SCAN_REMOVE_FAVORITE = f.r("Eliminar") .. " favorita",
        RECIPE_SCAN_ADD_FAVORITE = f.g("Añadir") .. " favorita",
        RECIPE_SCAN_FAVORITES_CRAFTER_ONLY = f.r("Las favoritas solo se pueden cambiar en el artesano"),
        RECIPE_SCAN_QUEUE_HINT = "Presiona " ..
            CreateAtlasMarkup("NPE_LeftClick", 20, 20, 2) .. " + shift para poner la receta seleccionada en la " ..
            f.bb("Cola de fabricación"),
        RECIPE_SCAN_REMOVE_CACHED_DATA = f.r("Eliminar"),
        RECIPE_SCAN_REMOVE_CACHED_DATA_TOOLTIP = f.r("Eliminar ") ..
            "todos los datos en caché sobre esta combinación de personaje - profesión",
        RECIPE_SCAN_USE_TSM_RESTOCK = "Usar expresión de cantidad de reabastecimiento de " .. f.bb("TSM"),
        RECIPE_SCAN_TSM_SALE_RATE_THRESHOLD = "Umbral de tasa de venta de " .. f.bb("TSM") .. ": ",
        RECIPE_SCAN_AUTOSELECT_OPEN_PROFESSION = "Autoseleccionar " .. f.bb("Profesión abierta"),
        RECIPE_SCAN_UPDATE_LAST_CRAFTING_COST = "Actualizar BD de " .. f.bb("Último costo de fabricación"),
        RECIPE_SCAN_UPDATE_LAST_CRAFTING_COST_TOOLTIP = "Si está habilitado, la base de datos del " .. f.bb("Último costo de fabricación") ..
            " se actualiza para cada receta escaneada.\n\nEsto permite consultar el último costo promedio de fabricación conocido por objeto a través de la API de CraftSim.",
        RECIPE_SCAN_ONLY_CRAFTLISTS_BUTTON = "Solo listas de fabricación",
        RECIPE_SCAN_ONLY_CRAFTLISTS_TOOLTIP =
        "Cuando está habilitado, todos los demás filtros se ignoran y solo las listas de fabricación seleccionadas se escanean utilizando sus respectivas opciones de optimización.",
        RECIPE_SCAN_CRAFTLISTS_SELECT_TITLE = "Seleccionar Listas de fabricación a escanear:",
        RECIPE_SCAN_CRAFTLISTS_NO_LISTS = f.grey("No se han creado Listas de fabricación aún"),
        CRAFT_LISTS_OPTIONS_TOOLTIP_HEADER = f.bb("Opciones") .. ":",
        CRAFT_LISTS_OPTIONS_TOOLTIP_RESTOCK_HEADER = f.bb("Opciones de reabastecimiento") .. ":",
        CRAFT_LISTS_OPTIONS_ONLY_PROFITABLE = "Solo rentables",

        -- Recipe Top Gear
        TOP_GEAR_TITLE = "Equipamiento superior de CraftSim",
        TOP_GEAR_AUTOMATIC = "Automático",
        TOP_GEAR_AUTOMATIC_TOOLTIP =
        "Simula automáticamente el Equipamiento superior para el modo seleccionado cada vez que se actualiza una receta.\n\nDesactivar esto podría mejorar el rendimiento.",
        TOP_GEAR_SIMULATE = "Simular Equipamiento superior",
        TOP_GEAR_EQUIP = "Equipar",
        TOP_GEAR_SIMULATE_QUALITY = "Calidad: ",
        TOP_GEAR_SIMULATE_EQUIPPED = "Equipamiento superior equipado",
        TOP_GEAR_SIMULATE_PROFIT_DIFFERENCE = "Diferencia de Ganancia Ø\n",
        TOP_GEAR_SIMULATE_NEW_MUTLICRAFT = "Nueva Fabricación múltiple\n",
        TOP_GEAR_SIMULATE_NEW_CRAFTING_SPEED = "Nueva Velocidad de fabricación\n",
        TOP_GEAR_SIMULATE_NEW_RESOURCEFULNESS = "Nueva Inventiva\n",
        TOP_GEAR_SIMULATE_NEW_SKILL = "Nueva Habilidad\n",
        TOP_GEAR_SIMULATE_UNHANDLED = "Modo de simulación no manejado",

        TOP_GEAR_SIM_MODES_PROFIT = "Mejor ganancia",
        TOP_GEAR_SIM_MODES_SKILL = "Mejor habilidad",
        TOP_GEAR_SIM_MODES_MULTICRAFT = "Mejor fabricación múltiple",
        TOP_GEAR_SIM_MODES_RESOURCEFULNESS = "Mejor inventiva",
        TOP_GEAR_SIM_MODES_CRAFTING_SPEED = "Mejor velocidad de fabricación",

        -- Options
        OPTIONS_TITLE = "CraftSim",
        OPTIONS_GENERAL_TAB = "General",
        OPTIONS_GENERAL_PRICE_SOURCE = "Fuente de precios",
        OPTIONS_GENERAL_CURRENT_PRICE_SOURCE = "Fuente de precios actual: ",
        OPTIONS_GENERAL_NO_PRICE_SOURCE = "¡No se ha cargado ningún addon de fuente de precios compatible!",
        OPTIONS_GENERAL_SHOW_PROFIT = "Mostrar porcentaje de ganancia",
        OPTIONS_GENERAL_SHOW_PROFIT_TOOLTIP = "Muestra el porcentaje de ganancia respecto a los costos de fabricación, además del valor en oro",
        OPTIONS_GENERAL_REMEMBER_LAST_RECIPE = "Recordar última receta",
        OPTIONS_GENERAL_REMEMBER_LAST_RECIPE_TOOLTIP = "Vuelve a abrir la última receta seleccionada al abrir la ventana de fabricación",
        OPTIONS_GENERAL_SUPPORTED_PRICE_SOURCES = "Fuentes de precios compatibles:",
        OPTIONS_GENERAL_INVENTORY_SOURCE = "Fuente de inventario",
        OPTIONS_GENERAL_CURRENT_INVENTORY_SOURCE = "Fuente de inventario actual: ",
        OPTIONS_GENERAL_NO_INVENTORY_SOURCE = "¡No se ha cargado ningún addon de inventario compatible!",
        OPTIONS_GENERAL_SUPPORTED_INVENTORY_SOURCES = "Fuentes de inventario compatibles:",
        OPTIONS_GENERAL_SHOW_TUTORIAL_BUTTONS_CHECKBOX = "Mostrar botones de tutorial de módulos",
        OPTIONS_GENERAL_SHOW_TUTORIAL_BUTTONS_TOOLTIP = "Muestra botones de tutorial para cada módulo",
        OPTIONS_PERFORMANCE_RAM = "Habilitar limpieza de RAM durante la fabricación",
        OPTIONS_PERFORMANCE_RAM_CRAFTS = "Fabricaciones",
        OPTIONS_PERFORMANCE_RAM_TOOLTIP =
        "Cuando está habilitado, CraftSim limpiará tu memoria RAM de datos sin usar cada cierta cantidad de fabricaciones para evitar que la memoria se acumule.\nLa acumulación de memoria también puede ocurrir debido a otros addons y no es exclusiva de CraftSim.\nUna limpieza afectará a todo el uso de RAM de WoW.",
        OPTIONS_MODULES_TAB = "Módulos",
        OPTIONS_PROFIT_CALCULATION_TAB = "Cálculo de ganancia",
        OPTIONS_CRAFTING_TAB = "Fabricación",
        OPTIONS_TSM_TAB = "TSM",
        OPTIONS_TSM_SECTION_TOOLTIP = "Cadenas de precios de TradeSkillMaster y opciones mejoradas de TSM para CraftSim.",
        OPTIONS_TSM_EXPRESSIONS_HEADER = "Expresiones de precio y reabastecimiento",
        OPTIONS_TSM_ENHANCED_HEADER = "Mejoras de TSM",
        OPTIONS_TSM_RESET = "Restablecer valores predeterminados",
        OPTIONS_TSM_INVALID_EXPRESSION = "Expresión inválida",
        OPTIONS_TSM_VALID_EXPRESSION = "Expresión válida",
        OPTIONS_TSM_DEPOSIT_ENABLED_LABEL = "Habilitar costo de depósito esperado",
        OPTIONS_TSM_DEPOSIT_ENABLED_TOOLTIP =
        "Resta el costo esperado del depósito de la subasta de los cálculos de ganancias.\nUsa los datos de precios de TSM para estimar el depósito que pagarás al listar el objeto.",
        OPTIONS_TSM_DEPOSIT_EXPRESSION_LABEL = "Expresión de depósito de TSM",
        OPTIONS_TSM_SMART_RESTOCK_ENABLED_LABEL = "Reabastecimiento inteligente (restar inventario)",
        OPTIONS_TSM_SMART_RESTOCK_ENABLED_TOOLTIP =
        "Al enviar recetas a la Cola de fabricación, resta los objetos que ya posees\n(bolsas, banco, alters, banco de hermandad/banda) de la cantidad a reabastecer.",
        OPTIONS_TSM_SMART_RESTOCK_INCLUDE_ALTS_LABEL = "Incluir personajes alters",
        OPTIONS_TSM_SMART_RESTOCK_INCLUDE_WARBANK_LABEL = "Incluir banco de banda (Warbank)",
        OPTIONS_MODULES_REAGENT_OPTIMIZATION = "Módulo de Optimización de componentes",
        OPTIONS_MODULES_AVERAGE_PROFIT = "Módulo de Ganancia promedio",
        OPTIONS_MODULES_TOP_GEAR = "Módulo de Equipamiento superior",
        OPTIONS_MODULES_COST_OVERVIEW = "Módulo de Resumen de costos",
        OPTIONS_MODULES_SPECIALIZATION_INFO = "Módulo de Info. de especialización",
        OPTIONS_MODULES_CUSTOMER_HISTORY_SIZE = "Máx. mensajes del historial de clientes por cliente",
        OPTIONS_MODULES_CUSTOMER_HISTORY_MAX_ENTRIES_PER_CLIENT = "Máx. entradas de historial por cliente",
        OPTIONS_PROFIT_CALCULATION_OFFSET = "Desfasar puntos de ruptura de habilidad en 1",
        OPTIONS_PROFIT_CALCULATION_OFFSET_TOOLTIP =
        "La sugerencia de combinación de componentes intentará alcanzar el punto de ruptura + 1 en lugar de coincidir con la habilidad exacta requerida",
        OPTIONS_PROFIT_CALCULATION_MULTICRAFT_CONSTANT = "Constante de Fabricación múltiple",
        OPTIONS_PROFIT_CALCULATION_MULTICRAFT_CONSTANT_EXPLANATION =
        "Predeterminado: 2.5\n\nLos datos de fabricación de diferentes jugadores en la beta y a principios de Dragonflight sugieren que\nlos objetos extra máximos que se pueden recibir de un proc de fabricación múltiple son 1+C*y.\nDonde 'y' es la cantidad base de objetos para una fabricación y 'C' es 2.5.\nSin embargo, si lo deseas, puedes modificar este valor aquí.",
        OPTIONS_PROFIT_CALCULATION_RESOURCEFULNESS_CONSTANT = "Constante de Inventiva",
        OPTIONS_PROFIT_CALCULATION_RESOURCEFULNESS_CONSTANT_EXPLANATION =
        "Predeterminado: 0.3\n\nLos datos de fabricación de diferentes jugadores en la beta y a principios de Dragonflight sugieren que\nla cantidad promedio de objetos ahorrados es del 30% de la cantidad requerida.\nSin embargo, si lo deseas, puedes modificar este valor aquí.",
        OPTIONS_GENERAL_SHOW_NEWS_CHECKBOX = "Mostrar ventana emergente de " .. f.bb("Noticias"),
        OPTIONS_GENERAL_SHOW_NEWS_CHECKBOX_TOOLTIP = "Muestra la ventana emergente de " ..
            f.bb("Noticias") .. " con la nueva información de actualización de " .. f.l("CraftSim") .. " al iniciar sesión en el juego",
        OPTIONS_GENERAL_HIDE_MINIMAP_BUTTON_CHECKBOX = "Ocultar botón del minimapa",
        OPTIONS_GENERAL_HIDE_MINIMAP_BUTTON_TOOLTIP = "Habilita esto para ocultar el botón del minimapa de " ..
            f.l("CraftSim"),
        OPTIONS_GENERAL_COIN_MONEY_FORMAT_CHECKBOX = "Usar texturas de monedas: ",
        OPTIONS_GENERAL_COIN_MONEY_FORMAT_TOOLTIP = "Usa iconos de monedas para dar formato al dinero",
        OPTIONS_SETTINGS_COIN_TEXTURES_LABEL = "Usar texturas de monedas para el dinero",
        OPTIONS_TOOLTIP_TAB = "Descripción emergente (Tooltip)",
        OPTIONS_TOOLTIP_SHOW_REGISTERED_CRAFTERS = "Mostrar artesanos registrados en las descripciones de objetos",
        OPTIONS_TOOLTIP_SHOW_REGISTERED_CRAFTERS_HELP =
        "Cuando está habilitado, las descripciones de los objetos muestran a los personajes de CraftSim que tienen esta receta en caché (y a cualquiera con datos del último costo de fabricación para ese objeto).",
        OPTIONS_TOOLTIP_REGISTERED_CRAFTERS_MAX = "Máx. artesanos mostrados",
        OPTIONS_TOOLTIP_REGISTERED_CRAFTERS_MAX_SUBLABEL =
        "Los artesanos adicionales se resumen con un recuento después de los nombres listados.",

        -- Control Panel
        CONTROL_PANEL_MODULES_CRAFT_QUEUE_LABEL = "Cola de fabricación",
        CONTROL_PANEL_MODULES_CRAFT_QUEUE_TOOLTIP = "¡Pon en cola tus recetas y fabrícalas todas en un solo lugar!",
        CONTROL_PANEL_MODULES_TOP_GEAR_LABEL = "Equipamiento superior",
        CONTROL_PANEL_MODULES_TOP_GEAR_TOOLTIP =
        "Muestra la mejor combinación disponible de equipo de profesión en función del modo seleccionado",
        CONTROL_PANEL_MODULES_COST_OVERVIEW_LABEL = "Detalles de precios",
        CONTROL_PANEL_MODULES_COST_OVERVIEW_TOOLTIP = "Muestra un resumen del precio de venta y la ganancia por calidad del objeto resultante",
        CONTROL_PANEL_MODULES_AVERAGE_PROFIT_LABEL = "Ganancia promedio",
        CONTROL_PANEL_MODULES_AVERAGE_PROFIT_TOOLTIP =
        "Muestra la ganancia promedio basándose en tus estadísticas de profesión y los pesos de estadística de ganancia como oro por punto.",
        CONTROL_PANEL_MODULES_RECIPE_INFO_LABEL = "Info. de receta",
        CONTROL_PANEL_MODULES_RECIPE_INFO_TOOLTIP =
        "Muestra datos de la receta, incluyendo ganancia promedio, pesos de estadística e información adicional personalizable a través del menú contextual.",
        CONTROL_PANEL_MODULES_REAGENT_OPTIMIZATION_LABEL = "Optimización de componentes",
        CONTROL_PANEL_MODULES_REAGENT_OPTIMIZATION_TOOLTIP =
        "Sugiere los componentes más baratos para alcanzar los umbrales de calidad específicos.",
        CONTROL_PANEL_MODULES_PRICE_OVERRIDES_LABEL = "Sobrescritura de precios",
        CONTROL_PANEL_MODULES_PRICE_OVERRIDES_TOOLTIP =
        "Sobrescribe los precios de cualquier componente y resultados de fabricación para todas las recetas o para una en específico.",
        CONTROL_PANEL_MODULES_SPECIALIZATION_INFO_LABEL = "Info. de especialización",
        CONTROL_PANEL_MODULES_SPECIALIZATION_INFO_TOOLTIP =
        "Muestra cómo las especializaciones de tu profesión afectan a esta receta y permite simular cualquier configuración.",
        CONTROL_PANEL_MODULES_CRAFT_LOG_LABEL = "Registro de fabricaciones",
        CONTROL_PANEL_MODULES_CRAFT_LOG_TOOLTIP = "¡Muestra un registro de fabricación y estadísticas sobre tus fabricaciones!",
        CONTROL_PANEL_MODULES_COST_OPTIMIZATION_LABEL = "Precios",
        CONTROL_PANEL_MODULES_COST_OPTIMIZATION_TOOLTIP =
        "Módulo que muestra los detalles de los precios de componentes y el resumen de los resultados de fabricación",
        CONTROL_PANEL_MODULES_STATISTICS_LABEL = "Estadísticas",
        CONTROL_PANEL_MODULES_STATISTICS_TOOLTIP =
        "Módulo que muestra estadísticas detalladas de resultados para la receta actualmente abierta",
        CONTROL_PANEL_MODULES_RECIPE_SCAN_LABEL = "Escáner de recetas",
        CONTROL_PANEL_MODULES_RECIPE_SCAN_TOOLTIP = "Módulo que escanea tu lista de recetas basándose en varias opciones",
        CONTROL_PANEL_MODULES_CUSTOMER_HISTORY_LABEL = "Historial de clientes",
        CONTROL_PANEL_MODULES_CUSTOMER_HISTORY_TOOLTIP =
        "Módulo que proporciona un historial de conversaciones con clientes, objetos fabricados y comisiones",
        CONTROL_PANEL_MODULES_CRAFT_BUFFS_LABEL = "Beneficios de fabricación",
        CONTROL_PANEL_MODULES_CRAFT_BUFFS_TOOLTIP = "Módulo que te muestra tus beneficios de fabricación activos y faltantes",
        CONTROL_PANEL_MODULES_EXPLANATIONS_LABEL = "Explicaciones",
        CONTROL_PANEL_MODULES_EXPLANATIONS_TOOLTIP = "Módulo que te muestra varias explicaciones sobre cómo" ..
            f.l(" CraftSim") .. " calcula las cosas",
        CONTROL_PANEL_RESET_FRAMES = "Restablecer posiciones de marcos",
        CONTROL_PANEL_OPTIONS = "Opciones",
        CONTROL_PANEL_PATCH_NOTES = "Notas del parche",
        CONTROL_PANEL_EXPORTS = "Exportaciones",
        CONTROL_PANEL_EASYCRAFT_EXPORT = "Exportar a " .. f.l("Easycraft"),
        CONTROL_PANEL_EASYCRAFT_EXPORTING = "Exportando",
        CONTROL_PANEL_EASYCRAFT_EXPORT_NO_RECIPE_FOUND = "No hay receta para exportar de la expansión The War Within",
        CONTROL_PANEL_FORGEFINDER_EXPORT = "Exportar a " .. f.l("ForgeFinder"),
        CONTROL_PANEL_FORGEFINDER_EXPORTING = "Exportando",
        CONTROL_PANEL_EXPORT_EXPLANATION = f.l("wowforgefinder.com") ..
            " y " .. f.l("easycraft.io") ..
            "\nson sitios web para buscar y ofrecer " .. f.bb("Pedidos de fabricación de WoW"),
        CONTROL_PANEL_DEBUG = "Depuración",
        CONTROL_PANEL_TITLE = "Panel de control",
        CONTROL_PANEL_SUPPORTERS_BUTTON = f.patreon("Colaboradores"),

        -- Supporters
        SUPPORTERS_DESCRIPTION = f.l("¡Gracias a todas esas increíbles personas!"),
        SUPPORTERS_DESCRIPTION_2 = f.l(
            "¿Quieres apoyar a CraftSim y además aparecer listado aquí con tu mensaje?\n¡Considera unirte a la Comunidad!"),
        SUPPORTERS_DATE = "Fecha",
        SUPPORTERS_SUPPORTER = "Colaborador",
        SUPPORTERS_MESSAGE = "Mensaje",

        -- Customer History
        CUSTOMER_HISTORY_TITLE = "Historial de clientes de CraftSim",
        CUSTOMER_HISTORY_DROPDOWN_LABEL = "Elige un cliente",
        CUSTOMER_HISTORY_TOTAL_TIP = "Propina total: ",
        CUSTOMER_HISTORY_FROM = "De",
        CUSTOMER_HISTORY_TO = "A",
        CUSTOMER_HISTORY_FOR = "Para",
        CUSTOMER_HISTORY_CRAFT_FORMAT = "Fabricó %s para %s",
        CUSTOMER_HISTORY_DELETE_BUTTON = "Eliminar cliente",
        CUSTOMER_HISTORY_WHISPER_BUTTON_LABEL = "Susurrar..",
        CUSTOMER_HISTORY_PURGE_NO_TIP_LABEL = "Eliminar clientes con 0 propina",
        CUSTOMER_HISTORY_PURGE_ZERO_TIPS_CONFIRMATION_POPUP =
        "¿Estás seguro de que quieres eliminar todos los datos\nde los clientes con 0 propina total?",
        CUSTOMER_HISTORY_DELETE_CUSTOMER_CONFIRMATION_POPUP = "¿Estás seguro de que quieres eliminar\ntodos los datos de %s?",
        CUSTOMER_HISTORY_PURGE_DAYS_INPUT_LABEL = "Intervalo de eliminación automática (Días)",
        CUSTOMER_HISTORY_PURGE_DAYS_INPUT_TOOLTIP =
        "CraftSim eliminará automáticamente a todos los clientes por debajo de la propina configurada cuando inicies sesión después de X días de la última eliminación.\nSi se establece en 0, CraftSim nunca eliminará automáticamente.",
        CUSTOMER_HISTORY_CUSTOMER_HEADER = "Cliente",
        CUSTOMER_HISTORY_TOTAL_TIP_HEADER = "Propina total",
        CUSTOMER_HISTORY_CRAFT_HISTORY_DATE_HEADER = "Fecha",
        CUSTOMER_HISTORY_CRAFT_HISTORY_RESULT_HEADER = "Resultado",
        CUSTOMER_HISTORY_CRAFT_HISTORY_TIP_HEADER = "Propina",
        CUSTOMER_HISTORY_CRAFT_HISTORY_CUSTOMER_REAGENTS_HEADER = "Componentes del cliente",
        CUSTOMER_HISTORY_CRAFT_HISTORY_CUSTOMER_NOTE_HEADER = "Nota",
        CUSTOMER_HISTORY_CHAT_MESSAGE_TIMESTAMP = "Marca de tiempo",
        CUSTOMER_HISTORY_CHAT_MESSAGE_SENDER = "Remitente",
        CUSTOMER_HISTORY_CHAT_MESSAGE_MESSAGE = "Mensaje",
        CUSTOMER_HISTORY_CHAT_MESSAGE_YOU = "[Tú]: ",
        CUSTOMER_HISTORY_CRAFT_LIST_TIMESTAMP = "Marca de tiempo",
        CUSTOMER_HISTORY_CRAFT_LIST_RESULTLINK = "EnlaceDeResultado",
        CUSTOMER_HISTORY_CRAFT_LIST_TIP = "Propina",
        CUSTOMER_HISTORY_CRAFT_LIST_REAGENTS = "Componentes",
        CUSTOMER_HISTORY_CRAFT_LIST_SOMENOTE = "AlgunaNota",
        CUSTOMER_HISTORY_TOTAL_AMOUNT = "Cantidad total",
        CUSTOMER_HISTORY_CATEGORY_ENABLE_HISTORY_RECORDING = f.bb("Habilitar ") .. f.gold("Registro de historial"),
        CUSTOMER_HISTORY_CATEGORY_RECORD_PATRON_ORDERS = "Registrar " .. f.bb("Pedidos de patrón"),
        CUSTOMER_HISTORY_CATEGORY_REMOVE_CUSTOMERS = "Eliminar clientes",
        CUSTOMER_HISTORY_CATEGORY_AUTO_REMOVAL = "Eliminación automática",
        CUSTOMER_HISTORY_CATEGORY_REMOVE_BELOW_THRESHOLD = f.l("Eliminar por debajo del umbral"),
        CUSTOMER_HISTORY_CATEGORY_REMOVE_ALL_CUSTOMERS = f.r("Eliminar todos los clientes"),
        CUSTOMER_HISTORY_CATEGORY_REMOVE_ALL_CUSTOMER_DATA = f.r("¿Eliminar TODOS los datos de clientes?"),
        CUSTOMER_HISTORY_CATEGORY_DELETE_CUSTOMER = "Eliminar cliente",

        -- Craft Queue
        CRAFT_QUEUE_TITLE = "Cola de fabricación de CraftSim",
        CRAFT_QUEUE_CRAFT_AMOUNT_LEFT_HEADER = "En cola",
        CRAFT_QUEUE_CRAFT_PROFESSION_GEAR_HEADER = "Herr.",
        CRAFT_QUEUE_CRAFTING_COSTS_HEADER = "Costos de fabricación",
        CRAFT_QUEUE_CRAFT_BUTTON_ROW_LABEL = "Fabricar",
        CRAFT_QUEUE_CRAFT_BUTTON_ROW_LABEL_WRONG_GEAR = "Herr. Equivocadas",
        CRAFT_QUEUE_CRAFT_BUTTON_ROW_LABEL_NO_REAGENTS = "Faltan comp.",
        CRAFT_QUEUE_ADD_OPEN_RECIPE_BUTTON_LABEL = "Encolar receta abierta",
        CRAFT_QUEUE_ADD_FIRST_CRAFTS_BUTTON_LABEL = "Encolar primeras fabricaciones",
        CRAFT_QUEUE_ADD_WORK_ORDERS_BUTTON_LABEL = "Encolar pedidos",
        CRAFT_QUEUE_ADD_WORK_ORDERS_ALLOW_CONCENTRATION_CHECKBOX = "Permitir " .. f.gold("Concentración"),
        CRAFT_QUEUE_ADD_WORK_ORDERS_ALLOW_CONCENTRATION_TOOLTIP = "Si no se puede alcanzar la calidad mínima, usar " ..
            f.l("Concentración") .. " si es posible",
        CRAFT_QUEUE_ADD_WORK_ORDERS_ONLY_PROFITABLE_CHECKBOX = "Solo " .. f.g("Rentables"),
        CRAFT_QUEUE_ADD_WORK_ORDERS_ONLY_PROFITABLE_TOOLTIP = "Solo encolar pedidos con ganancia esperada positiva",
        CRAFT_QUEUE_WORK_ORDER_TYPE_BUTTON = "Tipo de pedido",
        CRAFT_QUEUE_ADD_WORK_ORDERS_AUTO_QUEUE_CHECKBOX = f.g("Autoencolar ") .. f.bb("Pedidos"),
        CRAFT_QUEUE_ADD_WORK_ORDERS_AUTO_QUEUE_TOOLTIP =
        "Encolar automáticamente los pedidos al abrir la mesa de profesión por primera vez tras iniciar sesión",
        CRAFT_QUEUE_PATRON_ORDERS_BUTTON = "Pedidos de patrón",
        CRAFT_QUEUE_GUILD_ORDERS_BUTTON = "Pedidos de hermandad",
        CRAFT_QUEUE_PERSONAL_ORDERS_BUTTON = "Pedidos personales",
        CRAFT_QUEUE_PUBLIC_ORDERS_BUTTON = "Pedidos públicos",
        CRAFT_QUEUE_PUBLIC_ORDERS_MAX_COUNT = f.b("Pedido público") .. " Cantidad máxima: ",
        CRAFT_QUEUE_PUBLIC_ORDERS_MAX_COUNT_TOOLTIP =
            "Número máximo de pedidos públicos a encolar, ordenados por mayor ganancia.\n\nPon " ..
            f.bb("0") .. " para usar tus espacios de reclamo disponibles.",
        CRAFT_QUEUE_GUILD_ORDERS_ALTS_ONLY_CHECKBOX = f.r("Solo ") .. "Personajes alters",
        CRAFT_QUEUE_PATRON_ORDERS_FORCE_CONCENTRATION_CHECKBOX = f.r("Forzar ") .. f.gold("Concentración"),
        CRAFT_QUEUE_PATRON_ORDERS_FORCE_CONCENTRATION_TOOLTIP =
        "Forzar el uso de concentración para todos los pedidos de patrón si es posible",
        CRAFT_QUEUE_PATRON_ORDERS_SPARK_RECIPES_CHECKBOX = "Incluir Recetas con " .. f.e("Chispa"),
        CRAFT_QUEUE_PATRON_ORDERS_SPARK_RECIPES_TOOLTIP = "Incluir pedidos que usan una Chispa como componente",
        CRAFT_QUEUE_PATRON_ORDERS_ACUITY_CHECKBOX = "Incluir recompensas de " .. f.bb("Agudeza/Moxie"),
        CRAFT_QUEUE_PATRON_ORDERS_ACUITY_TOOLTIP = "Incluir pedidos con recompensas de Agudeza/Moxie",
        CRAFT_QUEUE_PATRON_ORDERS_POWER_RUNE_CHECKBOX = "Incluir recompensas de " .. f.bb("Runa de aumento"),
        CRAFT_QUEUE_PATRON_ORDERS_POWER_RUNE_TOOLTIP = "Incluir pedidos con recompensas de Runa de aumento",
        CRAFT_QUEUE_PATRON_ORDERS_KNOWLEDGE_POINTS_CHECKBOX = "Incluir recompensas de " .. f.bb("Punto de conocimiento"),
        CRAFT_QUEUE_PATRON_ORDERS_KNOWLEDGE_POINTS_TOOLTIP = "Incluir pedidos con recompensas de Puntos de conocimiento",
        CRAFT_QUEUE_PATRON_ORDERS_KNOWLEDGE_POINTS_MAX_COST = f.bb("Punto de conocimiento") .. " Costo máximo: ",
        CRAFT_QUEUE_PATRON_ORDERS_KNOWLEDGE_POINTS_MAX_COST_TOOLTIP =
        "Costo máximo de oro permitido por 1 Punto de conocimiento\n\nFormato: ",
        CRAFT_QUEUE_PATRON_ORDERS_MAX_COST = f.bb("Pedido de patrón") .. " Costo máximo: ",
        CRAFT_QUEUE_PATRON_ORDERS_MAX_COST_TOOLTIP = "Costo máximo de oro permitido para un pedido de patrón\n\nFormato: ",
        CRAFT_QUEUE_PATRON_ORDERS_MAX_DURATION_HOURS = f.bb("Pedido de patrón") .. " Duración máxima (horas): ",
        CRAFT_QUEUE_PATRON_ORDERS_MAX_DURATION_HOURS_TOOLTIP =
            "Solo encolar pedidos de patrón que expiren en este número de horas.\n\nPon " ..
            f.bb("0") .. " para deshabilitarlo.",
        CRAFT_QUEUE_PATRON_ORDERS_MAX_DURATION_RESET = "Restablecer",
        CRAFT_QUEUE_PATRON_ORDERS_REAGENT_BAG_VALUE = "Valor de la " .. f.bb("Bolsa de componentes") .. ": ",
        CRAFT_QUEUE_PATRON_ORDERS_REAGENT_BAG_VALUE_TOOLTIP = "Valor de la " ..
            f.bb("Recompensa de Bolsa de Componentes") .. " que se sumará a tu ganancia.\n\nFormato: ",
        CRAFT_QUEUE_PATRON_ORDERS_SKIP_OWNED_MATERIAL_COSTS_CHECKBOX = "Omitir costos de materiales " .. f.g("propios"),
        CRAFT_QUEUE_PATRON_ORDERS_SKIP_OWNED_MATERIAL_COSTS_TOOLTIP = "Cuando está habilitado, los controles de ganancia del " ..
            f.bb("pedido de patrón") .. ", costo máximo, y costo por punto de conocimiento tratan los componentes que ya posees en " ..
            f.bb("bolsas, banco y banco de banda") .. " como costo de oro cero.\n\n" ..
            "Los materiales se rastrean en todos los pedidos de patrón encolados en el mismo lote para que la misma pila no se cuente dos veces.",
        CRAFT_QUEUE_PATRON_ORDERS_INCLUDE_MOXIE_IN_PROFIT_CHECKBOX = "Incluir " .. f.bb("Moxie") .. " en la ganancia esperada",
        CRAFT_QUEUE_PATRON_ORDERS_INCLUDE_MOXIE_IN_PROFIT_TOOLTIP = "Cuando está habilitado, las recompensas de " ..
            f.bb("Moxie") ..
            " de pedidos " ..
            f.bb("PNJ (patrón)") ..
            " y la bonificación de moxie por primera fabricación se suman a la ganancia esperada usando tus valores de Moxie a continuación. Cuando está deshabilitado, el Moxie es solo informativo en las descripciones.",
        CRAFT_QUEUE_PATRON_ORDERS_AUTO_UPDATE_MOXIE_VALUES_CHECKBOX = "Autoactualizar valores de Moxie por actualizaciones de precio",
        CRAFT_QUEUE_PATRON_ORDERS_AUTO_UPDATE_MOXIE_VALUES_TOOLTIP =
        "Cuando está habilitado, CraftSim recalcula los valores de Moxie cuando los precios de las recetas se actualizan y solo sobrescribe las entradas cuyo valor calculado haya cambiado.",
        CRAFT_QUEUE_PATRON_ORDERS_MOXIE_VALUE_TOOLTIP = "Cuánto valoras una unidad de " ..
            f.bb("Moxie") ..
            " de recompensa para esta profesión. Mostrado en las descripciones emergentes; también usado en la ganancia esperada cuando " ..
            f.bb("Incluir Moxie en la ganancia esperada") ..
            " está habilitado.\n\nFormato: ",
        CRAFT_QUEUE_PATRON_REWARD_VALUES_TITLE = "Valores de Moxie",
        CRAFT_QUEUE_PATRON_REWARD_VALUES_MENU_BUTTON = "Establecer valores de Moxie",
        CRAFT_QUEUE_PATRON_REWARD_VALUES_INTRO = "Establece cuánto valoras una unidad de " ..
            f.bb("Moxie") ..
            " de cada profesión; las filas agrupadas comparten un valor, y este se usa en la ganancia esperada cuando " ..
            f.bb("Incluir Moxie en la ganancia esperada") ..
            " está habilitado.",
        CRAFT_QUEUE_PATRON_MOXIE_SURPLUS_SUGGEST_TOOLTIP = "Valor sugerido por " ..
            f.bb("Moxie") ..
            " de tu fuente de precios, utilizando producciones promedio para entregas de " ..
            f.bb("... excedentes del maestro") ..
            " en Midnight (precios de componentes C2).\n\n" ..
            f.g("Clic izquierdo") ..
            " para copiar este valor en la columna Actual.",
        CRAFT_QUEUE_PATRON_MOXIE_SURPLUS_NO_DATA_TOOLTIP =
        "No hay tabla de excedentes para esta profesión, no hay fuente de precios, o todos los componentes listados tienen precio cero.",
        CRAFT_QUEUE_PATRON_MOXIE_VALUES_HEADER_MOXIE = "Moxie",
        CRAFT_QUEUE_PATRON_MOXIE_VALUES_HEADER_ITEMS = "Objetos posibles",
        CRAFT_QUEUE_PATRON_MOXIE_VALUES_HEADER_CURRENT = "Actual",
        CRAFT_QUEUE_PATRON_MOXIE_VALUES_HEADER_SUGGESTED = "Sugerido",
        CRAFT_QUEUE_PATRON_MOXIE_SURPLUS_TT_REAGENT_TOTAL = "Componentes (esperados)",
        CRAFT_QUEUE_PATRON_MOXIE_SURPLUS_TT_PER_MOXIE = "Por " .. f.bb("Moxie"),
        PATRON_MOXIE_SURPLUS_BAG_ITEM_TOOLTIP_EXPECTED_VALUE = "Valor esperado",
        CRAFT_QUEUE_CLEAR_ALL_BUTTON_LABEL = "Limpiar Todo",
        CRAFT_QUEUE_RESTOCK_FAVORITES_SMART_CONCENTRATION_QUEUING = "Encolado " .. f.bb("Inteligente ") ..
            "de " .. f.gold("Concentración"),
        CRAFT_QUEUE_RESTOCK_FAVORITES_SMART_CONCENTRATION_QUEUING_TOOLTIP = "Si está habilitado, " ..
            f.l("CraftSim") ..
            " primero determina la receta de concentración " ..
            f.g("con mejor valor") ..
            ". Luego la encola por la cantidad máxima fabricable.",
        CRAFT_QUEUE_RESTOCK_FAVORITES_OFFSET_CONCENTRATION_CRAFT_AMOUNT = "Desfasar cantidad en cola por " ..
            f.gold("Concentración"),
        CRAFT_QUEUE_RESTOCK_FAVORITES_OFFSET_CONCENTRATION_CRAFT_AMOUNT_TOOLTIP =
            "Si está habilitado, las fabricaciones de concentración se encolarán por la cantidad de fabricaciones esperadas según tu " ..
            f.bb("Ingenio"),
        CRAFT_QUEUE_RESTOCK_FAVORITES_QUEUE_MAIN_PROFESSIONS = "Encolar " .. f.bb("Profesiones Principales Actuales"),
        CRAFT_QUEUE_RESTOCK_FAVORITES_QUEUE_MAIN_PROFESSIONS_TOOLTIP =
        "Si está habilitado, CraftSim procesará ambas profesiones principales del personaje actual a la vez",
        CRAFT_QUEUE_RESTOCK_FAVORITES_OFFSET_QUEUE_AMOUNT_LABEL = "Desfasar cantidad en cola: ",
        CRAFT_QUEUE_RESTOCK_FAVORITES_OFFSET_QUEUE_AMOUNT_TOOLTIP =
        "Siempre sumar la cantidad dada al número de fabricaciones encoladas",
        CRAFT_QUEUE_RESTOCK_FAVORITES_AUTO_SHOPPING_LIST = f.g("Crear ") .. f.bb("Lista de compras") ..
            " automáticamente tras encolar",
        CRAFT_QUEUE_CRAFT_BUTTON_ROW_LABEL_WRONG_PROFESSION = "Profesión equivocada",
        CRAFT_QUEUE_CRAFT_BUTTON_ROW_LABEL_ON_COOLDOWN = "En tiempo de reutilización",
        RECIPE_COOLDOWN_CHARGES_INLINE = "(%d/%d)",
        RECIPE_COOLDOWN_CHARGES_TOOLTIP = "Cargas de tiempo de reutilización: %d / %d",
        CRAFT_QUEUE_CRAFT_BUTTON_ROW_LABEL_WRONG_CRAFTER = "Artesano equivocado",
        CRAFT_QUEUE_RECIPE_REQUIREMENTS_HEADER = "Estado",
        CRAFT_QUEUE_RECIPE_REQUIREMENTS_TOOLTIP = "Se deben cumplir todos los requisitos para fabricar una receta",
        CRAFT_QUEUE_STATUS_CANNOT_CRAFT_FALLBACK = "No se puede fabricar",
        CRAFT_QUEUE_RESULT_FIRST_CRAFT_TOOLTIP_TITLE = "Primera fabricación",
        CRAFT_QUEUE_RESULT_FIRST_CRAFT_TOOLTIP =
            "Otorga un Punto de conocimiento de profesión la primera vez que fabricas esta receta. El valor de Moxie a continuación se incluye en la ganancia esperada solo para " ..
            f.bb("pedidos de PNJ (patrón)") ..
            " cuando " ..
            f.bb("Incluir Moxie en la ganancia esperada") ..
            " está habilitado.",
        CRAFT_QUEUE_FIRST_CRAFT_MOXIE_GOLD_TOOLTIP = "También otorga 10 de moxie de profesión (Valuado en %s)",
        CRAFT_QUEUE_MOXIE_GOLD_IN_TOOLTIP = " (Valuado en %s)",
        CRAFT_QUEUE_CRAFT_NEXT_BUTTON_LABEL = "Fabricar Siguiente",
        CRAFT_QUEUE_CRAFT_AVAILABLE_AMOUNT = "Máx.",
        CRAFT_QUEUE_SHATTER_MOTE_AUTOMATIC = "Automático (más barato)",
        CRAFT_QUEUE_SHATTER_MOTE_AUTOMATIC_OWNED = "Automático (más barato en posesión)",
        CRAFT_QUEUE_SHATTER_RIGHT_CLICK_HINT = "\nClic derecho para elegir mota.",
        CRAFTQUEUE_AUCTIONATOR_SHOPPING_LIST_BUTTON_LABEL = "Crear lista de compras de Auctionator",
        CRAFT_QUEUE_QUEUE_TAB_LABEL = "Cola de fabricación",
        CRAFT_QUEUE_FLASH_TASKBAR_OPTION_LABEL = "Parpadear en la barra de tareas al terminar en " ..
            f.bb("Cola de Fabricación"),
        CRAFT_QUEUE_FLASH_TASKBAR_OPTION_TOOLTIP =
            "Cuando tu juego de WoW esté minimizado y una receta haya terminado de fabricarse en la " .. f.bb("Cola de Fabricación") ..
            ", " .. f.l("CraftSim") .. " hará parpadear el icono de WoW en tu barra de tareas",
        CRAFT_QUEUE_RESTOCK_OPTIONS_TAB_LABEL = "Opciones de reabastecimiento",
        CRAFT_QUEUE_RESTOCK_OPTIONS_TAB_TOOLTIP = "Configura el comportamiento de reabastecimiento al importar desde Escáner de recetas",
        CRAFT_QUEUE_RESTOCK_OPTIONS_GENERAL_PROFIT_THRESHOLD_LABEL = "Umbral de ganancia:",
        CRAFT_QUEUE_RESTOCK_OPTIONS_SALE_RATE_INPUT_LABEL = "Umbral de tasa de venta:",
        CRAFT_QUEUE_RESTOCK_OPTIONS_TSM_SALE_RATE_TOOLTIP = string.format(
            [[
¡Solo disponible cuando %s está cargado!

Comprobará si %s de las calidades elegidas de un objeto tiene una tasa de venta
mayor o igual al umbral configurado.
]], f.bb("TSM"), f.bb("alguna")),
        CRAFT_QUEUE_RESTOCK_OPTIONS_TSM_SALE_RATE_TOOLTIP_GENERAL = string.format(
            [[
¡Solo disponible cuando %s está cargado!

Comprobará si %s de las calidades de un objeto tiene una tasa de venta
mayor o igual al umbral configurado.
]], f.bb("TSM"), f.bb("alguna")),
        CRAFT_QUEUE_RESTOCK_OPTIONS_AMOUNT_LABEL = "Cantidad a reabastecer:",
        CRAFT_QUEUE_RESTOCK_OPTIONS_RESTOCK_TOOLTIP = "Esta es la " ..
            f.bb("cantidad de fabricaciones") ..
            " que se encolarán para esa receta.\n\nLa cantidad de objetos que tengas en tu inventario y banco de las calidades marcadas se restará de la cantidad a reabastecer al momento de hacerlo.",
        CRAFT_QUEUE_RESTOCK_OPTIONS_ENABLE_RECIPE_LABEL = "Habilitar:",
        CRAFT_QUEUE_RESTOCK_OPTIONS_GENERAL_OPTIONS_LABEL = "Opciones generales (Todas las recetas)",
        CRAFT_QUEUE_RESTOCK_OPTIONS_ENABLE_RECIPE_TOOLTIP =
        "Si esto se desactiva, la receta se reabastecerá en base a las opciones generales anteriores",
        CRAFT_QUEUE_TOTAL_PROFIT_LABEL = "Ganancia total Ø:",
        CRAFT_QUEUE_TOTAL_CRAFTING_COSTS_LABEL = "Costos de fabricación totales:",
        CRAFT_QUEUE_EDIT_RECIPE_TITLE = "Editar Receta",
        CRAFT_QUEUE_EDIT_RECIPE_NAME_LABEL = "Nombre de receta",
        CRAFT_QUEUE_EDIT_RECIPE_REAGENTS_SELECT_LABEL = "Seleccionar",
        CRAFT_QUEUE_EDIT_RECIPE_OPTIONAL_REAGENTS_LABEL = "Componentes opcionales",
        CRAFT_QUEUE_EDIT_RECIPE_FINISHING_REAGENTS_LABEL = "Componentes de acabado",
        CRAFT_QUEUE_EDIT_RECIPE_SPARK_LABEL = "Requerido",
        CRAFT_QUEUE_EDIT_RECIPE_PROFESSION_GEAR_LABEL = "Equipamiento de profesión",
        CRAFT_QUEUE_EDIT_RECIPE_OPTIMIZE_PROFIT_BUTTON = "Optimizar",
        CRAFT_QUEUE_EDIT_RECIPE_CRAFTING_COSTS_LABEL = "Costos de fabricación: ",
        CRAFT_QUEUE_EDIT_RECIPE_AVERAGE_PROFIT_LABEL = "Ganancia promedio: ",
        CRAFT_QUEUE_EDIT_RECIPE_RESULTS_LABEL = "Resultados",
        CRAFT_QUEUE_EDIT_RECIPE_CONCENTRATION_CHECKBOX = " Concentración",
        CRAFT_QUEUE_AUCTIONATOR_SHOPPING_LIST_PER_CHARACTER_CHECKBOX = "Por personaje",
        CRAFT_QUEUE_AUCTIONATOR_SHOPPING_LIST_PER_CHARACTER_CHECKBOX_TOOLTIP = "Crea una " ..
            f.bb("Lista de compras de Auctionator") .. " para cada artesano\nen lugar de una sola lista para todos",
        CRAFT_QUEUE_AUCTIONATOR_SHOPPING_LIST_TARGET_MODE_CHECKBOX = "Solo Modo Objetivo",
        CRAFT_QUEUE_AUCTIONATOR_SHOPPING_LIST_TARGET_MODE_CHECKBOX_TOOLTIP = "Crea una " ..
            f.bb("Lista de compras de Auctionator") .. " solo para las recetas en Modo Objetivo",
        CRAFT_QUEUE_UNSAVED_CHANGES_TOOLTIP = f.white("Cantidad en cola no guardada.\nPresiona Enter para Guardar"),
        CRAFT_QUEUE_STATUSBAR_LEARNED = f.white("Receta Aprendida"),
        CRAFT_QUEUE_STATUSBAR_COOLDOWN = f.white("Sin Tiempo de Reutilización"),
        CRAFT_QUEUE_STATUSBAR_REAGENTS = f.white("Componentes Disponibles"),
        CRAFT_QUEUE_STATUSBAR_GEAR = f.white("Equipo de Profesión Equipado"),
        CRAFT_QUEUE_STATUSBAR_CRAFTER = f.white("Personaje Artesano Correcto"),
        CRAFT_QUEUE_STATUSBAR_PROFESSION = f.white("Profesión Abierta"),
        CRAFT_QUEUE_BUTTON_EDIT = "Editar",
        CRAFT_QUEUE_BUTTON_CRAFT = "Fabricar",
        CRAFT_QUEUE_BUTTON_CLAIM = "Reclamar",
        CRAFT_QUEUE_BUTTON_CLAIMED = "Reclamado",
        CRAFT_QUEUE_BUTTON_NEXT = "Sig.: ",
        CRAFT_QUEUE_BUTTON_NOTHING_QUEUED = "Nada en Cola",
        CRAFT_QUEUE_BUTTON_ORDER = "Pedir",
        CRAFT_QUEUE_BUTTON_SUBMIT = "Enviar",
        CRAFT_QUEUE_BUTTON_EQUIP_TOOLS = "Equipar",
        CRAFT_QUEUE_BUTTON_SHATTER = "Añicos",
        CRAFT_QUEUE_STATUS_SHATTER_BUFF = "Beneficio Esencia de añicos inactivo",
        CRAFT_QUEUE_STATUS_SHATTER_AFTER_LOGIN = "Rehacer Añicos requerido tras inicio de sesión",
        CRAFT_QUEUE_SHATTER_TOOLTIP_AFTER_LOGIN = shatter_post_login_tooltip,
        CRAFT_QUEUE_SHATTER_TOOLTIP_MISSING_BUFF = "\n\n" ..
            f.white("Lanza Añicos para aplicar Esencia de añicos."),
        CRAFT_QUEUE_SHATTER_TOOLTIP_STALE_AND_MISSING = "\n\n" ..
            f.white("Esencia de añicos inactiva. Lanza Añicos para aplicarla y sincronizar estadísticas."),
        CRAFT_QUEUE_IGNORE_ACUITY_RECIPES_CHECKBOX_LABEL = "Ignorar recetas de Agudeza",
        CRAFT_QUEUE_IGNORE_ACUITY_RECIPES_CHECKBOX_TOOLTIP = "No encolar primeras fabricaciones que usen " ..
            f.bb("Agudeza de artesano") .. " para fabricar",
        CRAFT_QUEUE_AMOUNT_TOOLTIP = "\n\nFabricaciones en Cola: ",
        CRAFT_QUEUE_ORDER_CUSTOMER = "\n\nCliente del Pedido: ",
        CRAFT_QUEUE_ORDER_MINIMUM_QUALITY = "\nCalidad Mínima: ",
        CRAFT_QUEUE_ORDER_REWARDS = "\nRecompensas:",
        CRAFT_QUEUE_RESTOCK_FAVORITES_OPTIONS_AUTO_SHOPPING_LIST =
        "Si está habilitado, CraftSim creará automáticamente una lista de compras después de realizar operaciones de encolado.",
        CRAFT_QUEUE_IGNORE_SPARK_RECIPES_CHECKBOX_LABEL = "Ignorar recetas con " .. f.e("Chispa"),
        CRAFT_QUEUE_IGNORE_SPARK_RECIPES_CHECKBOX_TOOLTIP = "Ignora recetas que requieran una chispa como componente",
        CRAFT_QUEUE_MENU_AUTO_SHOW = f.g("Abrir automáticamente ") .. "cuando se encole una receta",
        CRAFT_QUEUE_MENU_INGENUITY_IGNORE = f.r("Ignorar ") .. "reducción de cantidad en cola por " .. f.gold("Procs de Ingenio"),
        CRAFT_QUEUE_MENU_DEQUEUE_CONCENTRATION = f.r("Eliminar ") .. "al agotar toda la " .. f.gold("Concentración"),
        CRAFT_QUEUE_MENU_DEQUEUE_CONCENTRATION_TOOLTIP =
        "Autoelimina una receta de la cola cuando la concentración restante no permita más fabricaciones.",
        CRAFT_QUEUE_MENU_MIDNIGHT_SHATTER_FORCE_BUFF = f.gold("Forzar ") ..
            "beneficio de " .. f.bb("Esencia de añicos") .. " para Encantamiento de Midnight",
        CRAFT_QUEUE_MENU_MIDNIGHT_SHATTER_FORCE_BUFF_TOOLTIP = "Cuando está habilitado, CraftSim requerirá que " ..
            "el beneficio de " .. f.bb("Esencia de añicos") .. " esté activo antes de fabricar recetas de Encantamiento.\n\n" ..
            "El botón de Añicos se mostrará en la secuencia y el beneficio se considerará activo durante la optimización.\n\n" ..
            "Cuando está deshabilitado, el paso de Añicos se omite por completo y el beneficio no se tiene en cuenta para la optimización.",
        CRAFT_QUEUE_MENU_TWW_ENCHANT_SHATTER_FORCE_BUFF = f.gold("Forzar ") ..
            "beneficio de " .. f.bb("Esencia de añicos") .. " para Encantamiento de " ..
            CraftSim.GUTIL:ColorizeText("The War Within", CraftSim.GUTIL.COLORS.LEGENDARY),
        CRAFT_QUEUE_MENU_TWW_ENCHANT_SHATTER_FORCE_BUFF_TOOLTIP = "Cuando está habilitado, CraftSim requerirá que " ..
            "el beneficio de " .. f.bb("Esencia de añicos") .. " esté activo antes de fabricar recetas de Encantamiento de TWW.\n\n" ..
            "El botón de Añicos se mostrará en la secuencia y el beneficio se considerará activo durante la optimización.\n\n" ..
            "Cuando está deshabilitado, el paso de Añicos se omite y el beneficio no se tiene en cuenta.",
        CRAFT_QUEUE_MENU_EVERBURNING_IGNITION_FORCE_BUFF = f.gold("Forzar ") ..
            "beneficio de " .. f.bb("Ignición Eterna") .. " para estadísticas de Herrería de TWW",
        CRAFT_QUEUE_MENU_EVERBURNING_IGNITION_FORCE_BUFF_TOOLTIP = "Cuando está habilitado, CraftSim asumirá que " ..
            f.bb("Ignición Eterna") ..
            " está activa durante la optimización de estadísticas cuando el beneficio no se detecte en el jugador.\n\n" ..
            "Esto no añade un botón previo en la cola de fabricación.",
        CRAFT_QUEUE_TUTORIAL_QUEUE_LIST_TOOLTIP =
        "Las recetas encoladas se listan aquí.\nClic izquierdo en una receta para navegar hacia ella\nClic derecho para acciones\nClic con la rueda del ratón para eliminarla de la cola",
        CRAFT_QUEUE_TUTORIAL_CRAFT_NEXT_TOOLTIP = "Usa Fabricar Siguiente para fabricar la primera receta encolada en la cima",
        CRAFT_QUEUE_TUTORIAL_QUEUE_BUTTONS_TOOLTIP =
        "Estos botones pueden usarse para encolar automáticamente rangos de recetas.\nListas de fabricación son listas predefinidas de recetas\nPrimeras fabricaciones son recetas con bonos de primera vez\nLos Pedidos pueden ser de Patrón, Hermandad, Personales o Públicos y se encolan según tus criterios",
        CRAFT_QUEUE_TUTORIAL_SHOPPING_LIST_TOOLTIP =
        "Si tienes cargado el addon Auctionator, puedes usar este botón para crear una lista de compras con los componentes que te falten para la cola.",
        CRAFT_QUEUE_TUTORIAL_QUICK_ACCESS_BAR_TOOLTIP =
        "Este es un acceso rápido a tus componentes de acabado ligados al alma mejorables (Recompensas de Pedidos de Patrón). Para Encantamiento también hay un botón rápido para el beneficio de Añicos",
        CRAFT_QUEUE_TUTORIAL_CRAFT_QUEUE_OPTIONS_TOOLTIP =
        "Aquí puedes encontrar opciones generales para configurar la Cola de fabricación",
        
        -- craft lists
        CRAFT_LISTS_TAB_LABEL = "Listas de fabricación",
        CRAFT_LISTS_QUEUE_BUTTON_LABEL = "Encolar listas",
        CRAFT_LISTS_CREATE_BUTTON_LABEL = "Crear",
        CRAFT_LISTS_DELETE_BUTTON_LABEL = f.r("Eliminar"),
        CRAFT_LISTS_RENAME_BUTTON_LABEL = "Renombrar",
        CRAFT_LISTS_ADD_RECIPE_BUTTON_LABEL = "Añadir receta abierta",
        CRAFT_LISTS_REMOVE_RECIPE_BUTTON_LABEL = f.r("Eliminar"),
        CRAFT_LISTS_EXPORT_BUTTON_LABEL = "Exportar",
        CRAFT_LISTS_IMPORT_BUTTON_LABEL = "Importar",
        CRAFT_LISTS_LIST_NAME_HEADER = "Nombre de lista",
        CRAFT_LISTS_LIST_TYPE_HEADER = "Alcance",
        CRAFT_LISTS_RECIPE_NAME_HEADER = "Receta",
        CRAFT_LISTS_GLOBAL_LABEL = f.bb("Global"),
        CRAFT_LISTS_CHARACTER_LABEL = f.g("Personaje"),
        CRAFT_LISTS_NEW_LIST_DEFAULT_NAME = "Nueva Lista",
        CRAFT_LISTS_RENAME_POPUP_TITLE = "Renombrar Lista de fabricación",
        CRAFT_LISTS_CREATE_POPUP_TITLE = "Crear Lista de fabricación",
        CRAFT_LISTS_EXPORT_POPUP_TITLE = "Exportar Lista de fabricación",
        CRAFT_LISTS_IMPORT_POPUP_TITLE = "Importar Lista de fabricación",
        CRAFT_LISTS_OPTIONS_ENABLE_CONCENTRATION = "Habilitar Concentración",
        CRAFT_LISTS_OPTIONS_OPTIMIZE_CONCENTRATION = "Optimizar Concentración",
        CRAFT_LISTS_OPTIONS_OPTIMIZE_CONCENTRATION_TOOLTIP =
            "Mejora componentes para maximizar la ganancia por punto de concentración gastado",
        CRAFT_LISTS_OPTIONS_CONCENTRATION = f.gold("Concentración"),
        CRAFT_LISTS_OPTIONS_CONCENTRATION_DISABLED = "Deshabilitada",
        CRAFT_LISTS_OPTIONS_CONCENTRATION_DISABLED_TOOLTIP =
            "No usar concentración al escanear o encolar esta lista",
        CRAFT_LISTS_OPTIONS_CONCENTRATION_ENABLED = "Habilitada",
        CRAFT_LISTS_OPTIONS_CONCENTRATION_ENABLED_TOOLTIP =
            "Usar concentración para optimizar; encolar cantidades completas de reabastecimiento sin limitar a tu reserva actual",
        CRAFT_LISTS_OPTIONS_CONCENTRATION_SINGLE = "La mejor",
        CRAFT_LISTS_OPTIONS_CONCENTRATION_SINGLE_TOOLTIP =
            "Encolar solo la receta con mayor valor de concentración por profesión, limitada a la concentración disponible",
        CRAFT_LISTS_OPTIONS_CONCENTRATION_MULTI = "Múltiples recetas",
        CRAFT_LISTS_OPTIONS_CONCENTRATION_MULTI_TOOLTIP =
            "Encolar múltiples recetas en orden de valor de concentración hasta agotar toda la concentración disponible",
        CRAFT_LISTS_OPTIONS_OFFSET_CONCENTRATION = "Desfasar cantidad en cola por " .. f.bb("Concentración"),
        CRAFT_LISTS_OPTIONS_OFFSET_CONCENTRATION_TOOLTIP =
            "Si está habilitado, las fabricaciones de concentración se encolarán por la cantidad de fabricaciones esperadas según tu " ..
            f.bb("Ingenio"),
        CRAFT_LISTS_OPTIONS_OFFSET_CONCENTRATION_POOL_ONLY =
            "Solo se aplica a " .. f.bb("La mejor") .. " y " .. f.bb("Múltiples recetas"),
        CRAFT_LISTS_OPTIONS_OPTIMIZE_TOOLS = "Optimizar Herramientas de profesión",
        CRAFT_LISTS_OPTIONS_TOP_PROFIT_QUALITY = "Autoseleccionar calidad de mejor ganancia",
        CRAFT_LISTS_OPTIONS_OPTIMIZE_FINISHING = "Optimizar componentes de acabado",
        CRAFT_LISTS_OPTIONS_INCLUDE_SOULBOUND = "Incluir componentes de acabado " .. f.e("Ligados al alma"),
        CRAFT_LISTS_OPTIONS_REAGENT_ALLOCATION = "Asignación de componentes",
        CRAFT_LISTS_OPTIONS_REAGENT_ALLOCATION_OPTIMIZE_HIGHEST = "Calidad más alta",
        CRAFT_LISTS_OPTIONS_REAGENT_ALLOCATION_OPTIMIZE_MOST_PROFITABLE = "Calidad más rentable",
        CRAFT_LISTS_OPTIONS_REAGENT_ALLOCATION_TARGET_QUALITY = "Calidad objetivo",
        CRAFT_LISTS_OPTIONS_ENABLE_UNLEARNED = "Habilitar recetas " .. f.r("No aprendidas"),
        CRAFT_LISTS_OPTIONS_USE_TSM_RESTOCK = "Usar expresión de reabastecimiento de " .. f.bb("TSM"),
        CRAFT_LISTS_OPTIONS_TSM_EXPRESSION = "Expresión:",
        CRAFT_LISTS_OPTIONS_USE_CURRENT_CHARACTER = "Fabricar con personaje actual",
        CRAFT_LISTS_OPTIONS_FIXED_CRAFTER = "Artesano Fijo: ",
        CRAFT_LISTS_OPTIONS_RESTOCK_AMOUNT = "Cant. de Reabastecimiento: ",
        CRAFT_LISTS_OPTIONS_OFFSET_QUEUE_AMOUNT = "Desfasar cantidad en cola: ",
        CRAFT_LISTS_OPTIONS_OFFSET_QUEUE_AMOUNT_TOOLTIP = "Siempre sumar la cantidad dada al número de fabricaciones encoladas",
        CRAFT_LISTS_RESTOCK_SUBTRACT_OWNED_LABEL = "Restar bolsas, banco y banco de banda al reabastecer lista",
        CRAFT_LISTS_RESTOCK_SUBTRACT_OWNED_TOOLTIP =
        "Cuando está habilitado, la lista de reabastecimiento encola máx(0, objetivo - cuántos ya tienes).\n\nDesactívalo para encolar siempre hasta el número objetivo sin importar el inventario (por ejemplo, fabricar 20 aunque ya tengas algunos).",
        CRAFT_LISTS_RESTOCK_INCLUDE_ALT_INVENTORY_LABEL = "Incluir Inventario de " .. f.bb("Alters"),
        CRAFT_LISTS_RESTOCK_INCLUDE_ALT_INVENTORY_TOOLTIP =
        "Cuando está habilitado, el inventario de los personajes alters también se resta del objetivo de reabastecimiento.",
        CRAFT_LISTS_SKIP_OWNED_MATERIAL_COSTS_LABEL = "Omitir costos de materiales " .. f.g("propios"),
        CRAFT_LISTS_SKIP_OWNED_MATERIAL_COSTS_TOOLTIP = "Cuando está habilitado, los controles de " ..
            f.bb("solo rentables") .. " tratan los componentes que ya tienes como costo cero.\n\n" ..
            "Usa " .. f.bb("bolsas, banco y banco de banda") .. " para el artesano. Si " ..
            f.bb("Incluir inventario de Alters") .. " está habilitado, también se incluyen alters.\n\n" ..
            "Los materiales se comparten en todas las listas encoladas juntas para no contar una pila dos veces.",
        CRAFT_LISTS_OPTIONS_AUTO_SHOPPING_LIST = "Crear Lista de compras automáticamente después de encolar",
        CRAFT_LISTS_OPTIONS_UPDATE_LAST_CRAFTING_COST = "Actualizar BD de " .. f.bb("Último costo de fabricación"),
        CRAFT_LISTS_OPTIONS_UPDATE_LAST_CRAFTING_COST_TOOLTIP = "Si está habilitado, la base de datos de " .. f.bb("Último costo de fabricación") ..
            " se actualiza para cada receta al encolar listas.\n\nPermite consultar el último costo promedio a través de la API de CraftSim.",
        CRAFT_LISTS_NO_LIST_SELECTED = f.grey("No se ha seleccionado ninguna lista"),
        CRAFT_LISTS_SELECT_LIST_HINT = f.grey("Selecciona una lista para ver las recetas"),
        CRAFT_LISTS_RECIPE_RESTOCK_SET_MAX = "Reabastecer: ",
        CRAFT_LISTS_RECIPE_RESTOCK_TAG = "Reabastecer",
        CRAFT_LISTS_RECIPE_RESTOCK_POPUP_TITLE = "Objetivo de reabastecimiento (0 = apagado)",
        CRAFT_LISTS_RECIPE_RESTOCK_POPUP_HINT = f.grey("0 deshabilita el reabastecimiento para esta receta."),
        CRAFT_LISTS_RECIPE_SUPPORTED_QUALITIES = "Calidades Compatibles",
        CRAFT_LISTS_RECIPE_SUPPORTED_QUALITIES_TOOLTIP =
            "Solo encolar y contar inventario para las calidades de equipo marcadas.\n\nSi no se marca ninguna, se permite cualquier calidad.",

        -- craft buffs

        CRAFT_BUFFS_TITLE = "Beneficios de fabricación de CraftSim",
        CRAFT_BUFFS_SIMULATE_BUTTON = "Simular Beneficios",
        CRAFT_BUFF_CHEFS_HAT_TOOLTIP = f.bb("Juguete de Wrath of the Lich King.") ..
            "\nRequiere Cocina de Rasganorte\nAjusta la Velocidad de fabricación a " .. f.g("0.5 segundos"),

        -- cooldowns module

        COOLDOWNS_TITLE = "Tiempos de reutilización de CraftSim",
        CONTROL_PANEL_MODULES_COOLDOWNS_LABEL = "Tiempos de Reut.",
        CONTROL_PANEL_MODULES_COOLDOWNS_TOOLTIP = "Resumen de los " ..
            f.bb("Tiempos de reutilización de Profesión") .. " de tu cuenta",
        COOLDOWNS_CRAFTER_HEADER = "Artesano",
        COOLDOWNS_RECIPE_HEADER = "Receta",
        COOLDOWNS_CHARGES_HEADER = "Cargas",
        COOLDOWNS_NEXT_HEADER = "Siguiente Carga",
        COOLDOWNS_ALL_HEADER = "Cargas Completas",
        COOLDOWNS_TAB_OVERVIEW = "Resumen",
        COOLDOWNS_TAB_BLACKLIST = "Lista Negra",
        COOLDOWNS_TAB_OPTIONS = "Opciones",
        COOLDOWNS_EXPANSION_FILTER_BUTTON = "Filtro de Expansión",
        COOLDOWNS_RECIPE_LIST_TEXT_TOOLTIP = f.bb("\n\nRecetas que comparten este tiempo de reutilización:\n"),
        COOLDOWNS_RECIPE_READY = f.g("Listo"),
        COOLDOWNS_ADD_TO_BLACKLIST = "Añadir a la lista negra",
        COOLDOWNS_BLACKLIST_RESTORE = "Eliminar de la lista negra",

        -- concentration module

        CONCENTRATION_TRACKER_TITLE = "Concentración de CraftSim",
        CONCENTRATION_TRACKER_LABEL_CRAFTER = "Artesano",
        CONCENTRATION_TRACKER_LABEL_CURRENT = "Actual",
        CONCENTRATION_TRACKER_LABEL_MAX = "Máx",
        CONCENTRATION_TRACKER_MAX = f.g("MÁX"),
        CONCENTRATION_TRACKER_MAX_VALUE = "Máximo: ",
        CONCENTRATION_TRACKER_FULL = f.g("Concentración Llena"),
        CONCENTRATION_TRACKER_SORT_MODE_CHARACTER = "Personaje",
        CONCENTRATION_TRACKER_SORT_MODE_CONCENTRATION = "Concentración",
        CONCENTRATION_TRACKER_SORT_MODE_PROFESSION = "Profesión",
        CONCENTRATION_TRACKER_FORMAT_MODE_EUROPE_MAX_DATE = "Europeo - Fecha máxima",
        CONCENTRATION_TRACKER_FORMAT_MODE_AMERICA_MAX_DATE = "Americano - Fecha máxima",
        CONCENTRATION_TRACKER_FORMAT_MODE_HOURS_LEFT = "Horas restantes",
        CONCENTRATION_TRACKER_LIST_ROW_MOXIE = "Moxie: %s",
        CONCENTRATION_TRACKER_LIST_ROW_ACUITY = "Agudeza: %s",
        CONCENTRATION_TRACKER_LIST_ROW_MOXIE_UNKNOWN = "-",
        CONCENTRATION_TRACKER_PIN_TOOLTIP = "Fijar Resumen",
        CONCENTRATION_TRACKER_LIST_TAB_LABEL = "Lista",
        CONCENTRATION_TRACKER_LIST_TAB_REMOVE_AND_BLACKLIST = "Eliminar y poner en Lista negra",
        CONCENTRATION_TRACKER_OPTIONS_TAB_LABEL = "Opciones",
        CONCENTRATION_TRACKER_OPTIONS_TAB_CLEAR_BLACKLIST = "Limpiar Lista Negra",
        CONCENTRATION_TRACKER_OPTIONS_TAB_SORT_MODE = "Ordenar por: ",
        CONCENTRATION_TRACKER_OPTIONS_TAB_TIME_FORMAT = "Formato de hora: ",

        -- work order tracker module

        WORK_ORDER_TRACKER_TITLE = "Pedidos de Patrón de CraftSim",
        CONTROL_PANEL_MODULES_WORK_ORDER_TRACKER_LABEL = "Pedidos de patrón",
        CONTROL_PANEL_MODULES_WORK_ORDER_TRACKER_TOOLTIP = "Rastrea " ..
            f.bb("Pedidos de patrón") .. " en caché de tus alters con ventanas de expiración y estado de fabricación",
        WORK_ORDER_TRACKER_LIST_TAB_LABEL = "Pedidos",
        WORK_ORDER_TRACKER_OPTIONS_TAB_LABEL = "Opciones",
        WORK_ORDER_TRACKER_REFRESH_BUTTON = "Actualizar",
        WORK_ORDER_TRACKER_COLUMN_CRAFTER = "Artesano",
        WORK_ORDER_TRACKER_COLUMN_RECIPE = "Receta",
        WORK_ORDER_TRACKER_COLUMN_TIME = "Tiempo",
        WORK_ORDER_TRACKER_COLUMN_STATUS = "Estado",
        WORK_ORDER_TRACKER_TIME_EXPIRED = f.grey("Expirado"),
        WORK_ORDER_TRACKER_TIME_LT_6H = f.r("<6h"),
        WORK_ORDER_TRACKER_TIME_6_12H = f.l("6-12h"),
        WORK_ORDER_TRACKER_TIME_12_24H = f.bb("12-24h"),
        WORK_ORDER_TRACKER_TIME_GT_24H = f.g(">24h"),
        WORK_ORDER_TRACKER_CLAIMED = "Reclamado",
        WORK_ORDER_TRACKER_UNKNOWN_RECIPE = "Receta desconocida",
        WORK_ORDER_TRACKER_LAST_SNAPSHOT_FMT = "Última comprobación hace %s",
        WORK_ORDER_TRACKER_TOOLTIP_STATUS = "Estado",
        WORK_ORDER_TRACKER_TOOLTIP_REQUIRED_QUALITY = "Calidad requerida",
        WORK_ORDER_TRACKER_TOOLTIP_QUALITY = "Calidad esperada",
        WORK_ORDER_TRACKER_TOOLTIP_REQUIRED_SHORT = "Req.",
        WORK_ORDER_TRACKER_TOOLTIP_EXPECTED_SHORT = "Esp.",
        WORK_ORDER_TRACKER_TOOLTIP_EXPIRES = "Expira: %s",
        WORK_ORDER_TRACKER_TOOLTIP_CLAIM_ENDS = "Reclamo termina: %s",
        WORK_ORDER_TRACKER_OPTION_AUTO_SNAPSHOT = "Tomar estado automáticamente al abrir pedidos",
        WORK_ORDER_TRACKER_OPTION_USE_CONCENTRATION = "Usar concentración para evaluar calidad",
        WORK_ORDER_TRACKER_OPTION_SORT_MODE = "Ordenar por: ",
        WORK_ORDER_TRACKER_STATUS_FILTER_TITLE = "Filtrar por Estado",
        WORK_ORDER_TRACKER_STATUS_FILTER_TOOLTIP = "Filtra los pedidos por estado de fabricación",
        WORK_ORDER_TRACKER_SORT_MODE_TIME = "Tiempo (urgencia)",
        WORK_ORDER_TRACKER_SORT_MODE_CHARACTER = "Artesano",
        WORK_ORDER_TRACKER_SORT_MODE_PROFESSION = "Profesión",
        WORK_ORDER_TRACKER_SORT_MODE_RECIPE = "Receta",
        WORK_ORDER_TRACKER_CRAFTABILITY_READY = f.g("Listo"),
        WORK_ORDER_TRACKER_CRAFTABILITY_NEEDS_RECIPE = f.r("Falta receta"),
        WORK_ORDER_TRACKER_CRAFTABILITY_NEEDS_QUALITY = f.r("Falta Espec/Calidad"),
        WORK_ORDER_TRACKER_CRAFTABILITY_NEEDS_REAGENTS = f.l("Faltan componentes"),
        WORK_ORDER_TRACKER_CRAFTABILITY_ON_COOLDOWN = f.l("En tiempo de reut."),
        WORK_ORDER_TRACKER_CRAFTABILITY_IN_PROGRESS = f.bb("Reclamado"),
        WORK_ORDER_TRACKER_CRAFTABILITY_BLOCKED = f.r("Bloqueado"),
        WORK_ORDER_TRACKER_CRAFTABILITY_READY_TO_CRAFT = "Listo para fabricar",
        WORK_ORDER_TRACKER_TOOLTIP_RECIPE_SOURCE = "Fuente de receta",
        WORK_ORDER_TRACKER_TOOLTIP_SUGGESTED_SPEC = "Especialización sugerida",
        WORK_ORDER_TRACKER_HINT_OPEN_SPEC = "Abrir especialización",
        WORK_ORDER_TRACKER_HINT_VIEW_RECIPE_SOURCE = "Ver fuente de receta",
        WORK_ORDER_TRACKER_HINT_ADD_TO_SHOPPING_LIST = "Añadir receta a la lista de compras de Auctionator",
        WORK_ORDER_TRACKER_HINT_UNAVAILABLE = "Abre la profesión para ver la fuente",
        RECIPE_ACQUISITION_ADDED_TO_SHOPPING_LIST = "Se añadió %s a la lista de Auctionator",
        RECIPE_ACQUISITION_FAILED_TO_ADD_TO_SHOPPING_LIST = "No se pudo añadir %s a Auctionator",
        RECIPE_ACQUISITION_SHOPPING_LIST_AUCTIONATOR_REQUIRED = "Auctionator es necesario para usar la lista de compras",
        CONTROL_PANEL_MODULES_SHOPPING_LIST_LABEL = "Lista de compras",
        CONTROL_PANEL_MODULES_SHOPPING_LIST_TOOLTIP = "Abre la " .. f.bb("Lista de compras") ..
            " para ver qué componentes necesitas comprar para tus fabricaciones en cola",

        -- static popups
        STATIC_POPUPS_YES = "Sí",
        STATIC_POPUPS_NO = "No",

        -- frames
        FRAMES_RESETTING = "restableciendo frameID: ",
        PATCH_NOTES_TITLE = "Notas del parche de CraftSim",
        FRAMES_WHATS_NEW = "¿Qué hay de nuevo en CraftSim?",
        FRAMES_JOIN_DISCORD = "¡Únete al Discord!",
        FRAMES_DONATE_KOFI = "Visita CraftSim en Ko-fi",
        FRAMES_NO_INFO = "Sin Información",

        -- node data
        NODE_DATA_RANK_TEXT = "Rango ",
        NODE_DATA_TOOLTIP = "\n\nEstadísticas totales del Talento:\n",
        SPECIALIZATION_INFO_TOOLTIP_LABEL = f.l("CraftSim") .. f.white(" Info. de Especialización:"),

        -- last crafting cost tooltip
        LAST_CRAFTING_COST_TOOLTIP_HEADER = f.l("CraftSim"),
        LAST_CRAFTING_COST_TOOLTIP_LABEL = f.white("Último Costo Promedio de Fabricación:"),
        LAST_CRAFTING_COST_TOOLTIP_CRAFTER = f.white("Artesano:"),
        LAST_CRAFTING_COST_TOOLTIP_UPDATED = f.white("Actualizado:"),
        REGISTERED_CRAFTERS_ITEM_TOOLTIP_LABEL = f.white("Artesanos registrados:"),
        REGISTERED_CRAFTERS_ITEM_TOOLTIP_MORE = "+%d más",

        -- columns
        SOURCE_COLUMN_AH = "SU",
        SOURCE_COLUMN_OVERRIDE = "SO",
        SOURCE_COLUMN_WO = "PE",

        -- disenchant
        DISENCHANT_TITLE = "Desencantamiento de CraftSim",
        DISENCHANT_BUTTON = "Desencantar Siguiente",
        DISENCHANT_OPTIONS_MIN_ILVL = "Nivel de objeto mínimo: ",
        DISENCHANT_INFO_TOOLTIP = f.bb("MMB / Clic Derecho") ..
            f.white(" .. Poner objeto en lista negra de la sesión\n") ..
            f.bb("Shift + MMB / Clic Derecho") .. f.white(" .. Poner objeto en lista negra permanentemente"),

        -- banking
        OPTIONS_BANKING_TAB = "Banco",
        OPTIONS_BANKING_MAX_ITEMS_PER_FRAME = "Máximo de objetos por marco: ",
        OPTIONS_BANKING_MAX_ITEMS_PER_FRAME_TOOLTIP =
        "Establece el número máximo de objetos movidos por marco al usar los comandos de meter y sacar",
    }
end
