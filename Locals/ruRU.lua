---@class CraftSim
local CraftSim = select(2, ...)

CraftSim.LOCAL_RU = {}

---@return table<CraftSim.LOCALIZATION_IDS, string>
function CraftSim.LOCAL_RU:GetData()
    local f = CraftSim.GUTIL:GetFormatter()
    local cm = function(i, s) return CraftSim.MEDIA:GetAsTextIcon(i, s) end
    return {
        -- REQUIRED:
        STAT_MULTICRAFT = "Перепроизводство",
        STAT_RESOURCEFULNESS = "Находчивость",
        STAT_INGENUITY = "Изобретательность",
        STAT_CRAFTINGSPEED = "Скорость изготовления",
        EQUIP_MATCH_STRING = "Если на персонаже:",
        ENCHANTED_MATCH_STRING = "Чары:",

        -- OPTIONAL (Defaulting to EN if not available):

        -- shared prof cds
        DF_ALCHEMY_TRANSMUTATIONS = "Трансмутация DF",

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

        PROFESSIONS_BLACKSMITHING = "Кузнечное дело",
        PROFESSIONS_LEATHERWORKING = "Кожевничество",
        PROFESSIONS_ALCHEMY = "Алхимия",
        PROFESSIONS_HERBALISM = "Травничество",
        PROFESSIONS_COOKING = "Кулинария",
        PROFESSIONS_MINING = "Горное дело",
        PROFESSIONS_TAILORING = "Портняжное дело",
        PROFESSIONS_ENGINEERING = "Инженерное дело",
        PROFESSIONS_ENCHANTING = "Зачарование",
        PROFESSIONS_FISHING = "Рыбная ловля",
        PROFESSIONS_SKINNING = "Снятие шкур",
        PROFESSIONS_JEWELCRAFTING = "Ювелирное дело",
        PROFESSIONS_INSCRIPTION = "Начертание",

        -- Other Statnames

        STAT_SKILL = "Навык",
        STAT_MULTICRAFT_BONUS = "Бонус предметов от перепроизводства",
        STAT_RESOURCEFULNESS_BONUS = "Бонус предметов от наход.",
        STAT_CRAFTINGSPEED_BONUS = "Скорость изготовления",
        STAT_INGENUITY_BONUS = "Сохраненная изобретательностью концентрация",
        STAT_INGENUITY_LESS_CONCENTRATION = "Снижение затрат концентрации",
        STAT_PHIAL_EXPERIMENTATION = "Прорыв в экспериментах с флаконами",
        STAT_POTION_EXPERIMENTATION = "Прорыв в экспериментах с зельями",

        -- Profit Breakdown Tooltips
        RESOURCEFULNESS_EXPLANATION_TOOLTIP =
        "Находчивость прокает для каждого материала индивидуально, а затем сохраняет около 30% его количества.\n\nСреднее сохраненное значение - это среднее сохраненное значение КАЖДОЙ комбинации и их шансов.\n(Прок всех материалов одновременно очень маловероятен, но сохраняет очень много)\n\nСредняя общая сэкономленная стоимость материалов представляет собой сумму сэкономленных затрат на материалы всех комбинаций, взвешенную с учетом их вероятности.",

        RECIPE_DIFFICULTY_EXPLANATION_TOOLTIP =
        "Сложность рецепта определяет, где находятся контрольные точки различных качеств.\n\nДля рецептов с пятью качествами они составляют 20%, 50%, 80% и 100% сложности рецепта в очках навыка.\nДля рецептов с тремя качествами они составляют 50% и 100%",
        MULTICRAFT_EXPLANATION_TOOLTIP =
        "Перепроизводство дает вам возможность создать больше предметов, чем вы обычно производите по рецепту.\n\nДополнительная сумма обычно составляет от 1 до 2.5y\nгде y = обычная сумма, которую дает 1 крафт.",
        REAGENTSKILL_EXPLANATION_TOOLTIP =
        "Качество ваших материалов может дать вам максимум 40% от базовой сложности рецепта в качестве бонусного навыка.\n\nВсе материалы Q1: бонус 0%\nВсе материалы Q2: бонус 20%\nВсе материалы Q3: бонус 40%\n n\nНавык рассчитывается по количеству материалов каждого качества, взвешенному по отношению к их качеству\n и конкретному значению веса, которое уникально для каждого отдельного материала для крафта Dragonflight\n\nОднако для переделок это отличается. Существует предел того, насколько реагенты могут увеличить качество,\nон зависит от качества материалов, из которых изначально был создан предмет.\nТочные принципы работы неизвестны.\nОднако CraftSim внутренне сравнивает достигнутый навык со всеми q3 и рассчитывает\nмаксимальное увеличение навыка на основе этого.",
        REAGENTFACTOR_EXPLANATION_TOOLTIP =
        "Наибольший вклад, который материалы могут внести в рецепт, в большинстве случаев составляет 40% от базовой сложности рецепта.\n\nОднако в случае переделки это значение может варьироваться в зависимости от предыдущих крафтов\n и качества использованных ранее материалов.",

        -- Simulation Mode
        SIMULATION_MODE_NONE = "Нет",
        SIMULATION_MODE_LABEL = "Режим симуляции",
        SIMULATION_MODE_TITLE = "Режим симуляции CraftSim",
        SIMULATION_MODE_TOOLTIP =
        "Режим симуляции CraftSim позволяет экспериментировать с рецептом без ограничений",
        SIMULATION_MODE_OPTIONAL = "Необязательные #",
        SIMULATION_MODE_FINISHING = "Завершающие #",

        -- Details Frame
        RECIPE_DIFFICULTY_LABEL = "Сложность рецепта: ",
        MULTICRAFT_LABEL = "Перепроизводство: ",
        RESOURCEFULNESS_LABEL = "Находчивость: ",
        RESOURCEFULNESS_BONUS_LABEL = "Бонус предметов от находчивости: ",
        CONCENTRATION_LABEL = "Концентрация: ",
        REAGENT_QUALITY_BONUS_LABEL = "Бонус от качества материалов: ",
        REAGENT_QUALITY_MAXIMUM_LABEL = "Наиб. бонус от кач. материалов в %: ",
        EXPECTED_QUALITY_LABEL = "Ожидаемое качество: ",
        NEXT_QUALITY_LABEL = "Следующее качество: ",
        MISSING_SKILL_LABEL = "Недостающий навык: ",
        SKILL_LABEL = "Навык: ",
        MULTICRAFT_BONUS_LABEL = "Бонус предметов от перепроизводства: ",

        -- Statistics
        STATISTICS_CDF_EXPLANATION =
        "Это рассчитывается с использованием аппроксимации Абрамовица и Стегуна (1985) CDF (кумулятивной функции распределения)\n\nВы заметите, что это всегда около 50% для 1 крафта.\nЭто потому, что в большинстве случаев 0 близок к средней прибыли.\nИ вероятность получения среднего значения CDF всегда составляет 50%.\n\nОднако скорость изменения может сильно различаться в зависимости от рецепта.\nЕсли вероятность получения положительной прибыли выше, чем отрицательной, он будет постоянно увеличиваться.\nЭто, конечно, верно и для другого направления.",
        EXPLANATIONS_PROFIT_CALCULATION_EXPLANATION =
            f.r("Внимание: ") .. " Впереди математика!\n\n" ..
            "Когда вы создаете что-то, у вас есть разные шансы на разные результаты в зависимости от ваших показателей крафта.\n" ..
            "И в статистике это называется " .. f.l("Распределением вероятностей.\n") ..
            "Однако вы заметите, что разные шансы ваших проков не суммируются до единицы\n" ..
            "(Что требуется для такого распределения, поскольку означает, что у вас есть 100% вероятность того, что что-то может случиться)\n\n" ..
            "Это потому что проки типа " ..
            f.bb("Находчивость ") .. "и" .. f.bb(" Перепроизводство") .. " могут случиться " .. f.g("одновременно.\n") ..
            "Итак, сначала нам нужно преобразовать наши шансы прока в " ..
            f.l("Распределение вероятностей ") .. " с шансами,\n" ..
            "суммирующимися до 100% (что означает, что рассматривается каждый случай)\n" ..
            "И для этого нам нужно будет вычислить " .. f.l("каждый") .. " возможный результат крафта\n\n" ..
            "Например: \n" ..
            f.p .. "Что, если " .. f.bb("ничего") .. " не прокнет?\n" ..
            f.p .. "Что, если прокнет или " .. f.bb("Находчивость") .. ", или " .. f.bb("Перепроизводство") .. "?\n" ..
            f.p .. "Что, если прокнут и " .. f.bb("Находчивость") .. " и " .. f.bb("Перепроизводство") .. " ?\n" ..
            f.p .. "И так далее..\n\n" ..
            "Для рецепта, учитывающего все проки, это будет 2 в степени 2 вариантов результата, что составляет аккуратные 4.\n" ..
            "Чтобы получить возможность появления только " ..
            f.bb("Перепроизводства") .. ", мы должны учитывать все остальные варианты!\n" ..
            "Шанс на прок " ..
            f.l("только") .. f.bb(" Перепроизводства ") .. "на самом деле это шанс " .. f.bb("Перепроизводства") ..
            "при котором " .. f.l("не ") .. "прокает " .. f.bb("Находчивость.\n") ..
            "А математика говорит нам, что вероятность того, что что-то не произойдет, равна 1 минус вероятность того, что это произойдет.\n" ..
            "Так что шанс прока только " ..
            f.bb("Перепроизводства ") ..
            "на самом деле " .. f.g("multicraftChance * (1-resourcefulnessChance)\n\n") ..
            "После такого расчета каждой возможности сумма индивидуальных шансов действительно равна единице!\n" ..
            "Это означает, что теперь мы можем применять статистические формулы. Самая интересная из них в нашем случае — это " ..
            f.bb("Ожидаемое значение") .. "\n" ..
            "Это, как следует из названия, значение, которое мы можем ожидать в среднем, или, в нашем случае, " ..
            f.bb(" ожидаемая прибыль от крафта!\n") ..
            "\n" .. cm(CraftSim.MEDIA.IMAGES.EXPECTED_VALUE) .. "\n\n" ..
            "Это говорит нам о том, что ожидаемое значение " ..
            f.l("E") ..
            " распределения вероятностей " ..
            f.l("X") .. " — это сумма всех его значений, умноженная на их вероятность.\n" ..
            "Так что в " ..
            f.bb("случае A с шансом 30%") ..
            " и прибылью " ..
            CraftSim.UTIL:FormatMoney(-100 * 10000, true) ..
            " и " ..
            f.bb("случае B с шансом 70%") ..
            " и прибылью " .. f.m(300 * 10000) .. " ожидаемая прибыль равна\n" ..
            f.bb("\nE(X) = -100*0.3 + 300*0.7  ") ..
            "что равно " .. CraftSim.UTIL:FormatMoney((-100 * 0.3 + 300 * 0.7) * 10000, true) .. "\n" ..
            "Вы можете просмотреть все случаи для вашего текущего рецепта в окне " .. f.bb("Статистика") .. "!"
        ,

        -- Popups
        POPUP_NO_PRICE_SOURCE_SYSTEM = "Нет поддерживаемого источника цен!",
        POPUP_NO_PRICE_SOURCE_TITLE = "Предупреждение об источнике цен CraftSim",
        POPUP_NO_PRICE_SOURCE_WARNING =
        "Источник цен не найден!\n\nВам необходимо установить хотя бы один из\nследующих аддонов-источников цен, чтобы\nиспользовать расчеты прибыли CraftSim:\n\n\n",
        POPUP_NO_PRICE_SOURCE_WARNING_SUPPRESS = "Больше не показывать предупреждение",

        -- Reagents Frame
        REAGENT_OPTIMIZATION_TITLE = "Оптимизация материалов CraftSim",
        REAGENTS_REACHABLE_QUALITY = "Достижимое качество: ",
        REAGENTS_MISSING = "Недостающие материалы",
        REAGENTS_AVAILABLE = "Доступные материалы",
        REAGENTS_CHEAPER = "Самые дешевые материалы",
        REAGENTS_BEST_COMBINATION = "Назначена лучшая комбинация",
        REAGENTS_NO_COMBINATION = "Повышающая качество \nкомбинация не найдена",
        REAGENTS_ASSIGN = "Назначить",

        -- Specialization Info Frame
        SPEC_INFO_TITLE = "Информация о специализации CraftSim",
        SPEC_INFO_SIMULATE_KNOWLEDGE_DISTRIBUTION = "Симулировать распределение знаний",
        SPEC_INFO_NODE_TOOLTIP =
        "Этот узел предоставляет вам следующие характеристики для этого рецепта:",
        SPEC_INFO_WORK_IN_PROGRESS = "Работа над SpecInfo продолжается",

        -- Crafting Results Frame
        CRAFT_LOG_TITLE = "Результаты крафта CraftSim",
        CRAFT_LOG_LOG = "Журнал крафта",
        CRAFT_LOG_LOG_1 = "Прибыль: ",
        CRAFT_LOG_LOG_2 = "Вдохновение!",
        CRAFT_LOG_LOG_3 = "Перепроизводство: ",
        CRAFT_LOG_LOG_4 = "Ресурсы сохранены!: ",
        CRAFT_LOG_LOG_5 = "Шанс: ",
        CRAFT_LOG_CRAFTED_ITEMS = "Созданные предметы",
        CRAFT_LOG_SESSION_PROFIT = "Прибыль за сеанс",
        CRAFT_LOG_RESET_DATA = "Сбросить данные",
        CRAFT_LOG_EXPORT_JSON = "Экспортировать JSON",
        CRAFT_LOG_RECIPE_STATISTICS = "Статистика рецептов",
        CRAFT_LOG_NOTHING = "Пока ничего не создано!",
        CRAFT_LOG_CALCULATION_COMPARISON_NUM_CRAFTS_PREFIX = "Крафты: ",
        CRAFT_LOG_STATISTICS_2 = "Ожидаемая Ø прибыль: ",
        CRAFT_LOG_STATISTICS_3 = "Реальная Ø прибыль: ",
        CRAFT_LOG_STATISTICS_4 = "Реальная прибыль: ",
        CRAFT_LOG_STATISTICS_5 = "Проки - Реальность / Ожидание: ",
        CRAFT_LOG_STATISTICS_7 = "Перепроизводство: ",
        CRAFT_LOG_STATISTICS_8 = "- Ø дополнительные предметы: ",
        CRAFT_LOG_STATISTICS_9 = "Проки находчивости: ",
        CRAFT_LOG_CALCULATION_COMPARISON_NUM_CRAFTS_PREFIX0 = "- Ø сэкономленные затраты: ",
        CRAFT_LOG_CALCULATION_COMPARISON_NUM_CRAFTS_PREFIX1 = "Прибыль: ",
        CRAFT_LOG_SAVED_REAGENTS = "Сохраненные реагенты",

        -- Stats Weight Frame
        STAT_WEIGHTS_TITLE = "Средняя прибыль CraftSim",
        EXPLANATIONS_TITLE = "Объяснение средней прибыли CraftSim",
        STAT_WEIGHTS_SHOW_EXPLANATION_BUTTON = "Показать объяснение",
        STAT_WEIGHTS_HIDE_EXPLANATION_BUTTON = "Скрыть объяснение",
        STAT_WEIGHTS_SHOW_STATISTICS_BUTTON = "Показать статистику",
        STAT_WEIGHTS_HIDE_STATISTICS_BUTTON = "Скрыть статистику",
        STAT_WEIGHTS_PROFIT_CRAFT = "Ø Прибыль / Крафт: ",
        EXPLANATIONS_BASIC_PROFIT_TAB = "Базовый расчет прибыли",

        -- Cost Details Frame
        PRICING_TITLE = "Оптимизация затрат CraftSim",
        PRICING_EXPLANATION =
            "Здесь вы можете увидеть обзор всех возможных цен на использованные материалы.\nСтолбец " ..
            f.bb("'Использованный источник'") ..
            " указывает, какая из цен используется.\n\n" ..
            f.g("AH") ..
            " .. Цена аукционного дома\n" ..
            f.l("OR") ..
            " .. Переопределение цены\n" ..
            f.bb("Изготовление") ..
            " .. Ожидаемые затраты на изготовление самостоятельно\n" ..
            f.l("OR") ..
            " всегда будет использоваться, если установлено. " ..
            f.bb("Стоимость изготовления") .. " будет использоваться, только если ниже " .. f.g("AH"),
        PRICING_CRAFTING_COSTS = "Стоимость изготовления: ",
        PRICING_ITEM_HEADER = "Предмет",
        COST_OPTIMIZATION_OVERRIDE_HEADER = "Переопределение",
        COST_OPTIMIZATION_CRAFTING_HEADER = "Изготовление",
        COST_OPTIMIZATION_USED_SOURCE = "Использованный источник",

        -- Statistics Frame
        STATISTICS_TITLE = "Статистика CraftSim",
        STATISTICS_EXPECTED_PROFIT = "Ожидаемая прибыль (μ)",
        STATISTICS_CHANCE_OF = "Шанс ",
        STATISTICS_PROFIT = "Прибыли",
        STATISTICS_AFTER = " после",
        STATISTICS_CRAFTS = "Крафтов: ",
        STATISTICS_QUALITY_HEADER = "Качество",
        STATISTICS_MULTICRAFT_HEADER = "Перепроизводство",
        STATISTICS_RESOURCEFULNESS_HEADER = "Находчивость",
        STATISTICS_EXPECTED_PROFIT_HEADER = "Ожидаемая прибыль",
        PROBABILITY_TABLE_TITLE = "Таблица вероятностей рецептов",

        -- Price Details Frame
        COST_OVERVIEW_TITLE = "Информация о ценах CraftSim",
        PRICE_DETAILS_INV_AH = "Инв/Аук",
        PRICE_DETAILS_ITEM = "Предмет",
        PRICE_DETAILS_PRICE_ITEM = "Цена/Предмет",
        PRICE_DETAILS_PROFIT_ITEM = "Прибыль/Предмет",

        -- Price Override Frame
        PRICE_OVERRIDE_TITLE = "Переопределение цены CraftSim",
        PRICE_OVERRIDE_REQUIRED_REAGENTS = "Необходимые реагенты",
        PRICE_OVERRIDE_OPTIONAL_REAGENTS = "Необязательные реагенты",
        PRICE_OVERRIDE_FINISHING_REAGENTS = "Завершающие реагенты",
        PRICE_OVERRIDE_RESULT_ITEMS = "Результат",
        PRICE_OVERRIDE_ACTIVE_OVERRIDES = "Активные переопределения",
        PRICE_OVERRIDE_ACTIVE_OVERRIDES_TOOLTIP =
        "'(как результат)' -> переопределение цены учитывается только в том случае, если предмет является результатом рецепта",
        PRICE_OVERRIDE_CLEAR_ALL = "Очистить все",
        PRICE_OVERRIDE_SAVE = "Сохранить",
        PRICE_OVERRIDE_SAVED = "Сохранено",
        PRICE_OVERRIDE_REMOVE = "Удалить",

        -- Recipe Scan Frame
        RECIPE_SCAN_TITLE = "Сканирование рецептов CraftSim",
        RECIPE_SCAN_MODE = "Режим сканирования",
        RECIPE_SCAN_SORT_MODE = "Режим сортировки",
        RECIPE_SCAN_SCAN_RECIPIES = "Сканировать рецепты",
        RECIPE_SCAN_SCAN_CANCEL = "Отмена",
        RECIPE_SCAN_SCANNING = "Сканирование",
        RECIPE_SCAN_INCLUDE_NOT_LEARNED = "Включить не изученные",
        RECIPE_SCAN_INCLUDE_NOT_LEARNED_TOOLTIP =
        "Включить в сканирование рецептов рецепты, которые вы не изучили",
        RECIPE_SCAN_INCLUDE_SOULBOUND = "Включить персональные",
        RECIPE_SCAN_INCLUDE_SOULBOUND_TOOLTIP =
        "Включайте персональные рецепты в сканирование рецептов.\n\nРекомендуется установить переопределение цены (например, для симуляции целевой комиссии)\nin в Модуле переопределения цены для предметов, созданных по этому рецепту",
        RECIPE_SCAN_INCLUDE_GEAR = "Включить снаряжение",
        RECIPE_SCAN_INCLUDE_GEAR_TOOLTIP =
        "Включить в сканирование рецептов все рецепты снаряжения",
        RECIPE_SCAN_OPTIMIZE_TOOLS = "Оптимизация инструментов",
        RECIPE_SCAN_OPTIMIZE_TOOLS_TOOLTIP =
        "Для каждого рецепта оптимизировать инструменты для наибольшей прибыли\n\n",
        RECIPE_SCAN_OPTIMIZE_TOOLS_WARNING =
        "Может снизиться производительность во время сканирования,\nесли в вашем инвентаре много инструментов",
        RECIPE_SCAN_CRAFTER_HEADER = "Ремесленник",
        RECIPE_SCAN_RECIPE_HEADER = "Рецепт",
        RECIPE_SCAN_LEARNED_HEADER = "Изучено",
        RECIPE_SCAN_RESULT_HEADER = "Результат",
        RECIPE_SCAN_AVERAGE_PROFIT_HEADER = "Средняя прибыль",
        RECIPE_SCAN_CONCENTRATION_VALUE_HEADER = "Значение конц.",
        RECIPE_SCAN_CONCENTRATION_COST_HEADER = "Затраты конц.",
        RECIPE_SCAN_TOP_GEAR_HEADER = "Лучшая экипировка",
        RECIPE_SCAN_INV_AH_HEADER = "Инв/Аук",
        RECIPE_SCAN_SORT_BY_MARGIN = "Сортировать по % прибыли",
        RECIPE_SCAN_SORT_BY_MARGIN_TOOLTIP =
        "Отсортировать список прибыли по прибыли относительно затрат на изготовление.\n(Требуется новое сканирование)",
        RECIPE_SCAN_USE_INSIGHT_CHECKBOX = "По возможности использовать " .. f.bb("Озарение"),
        RECIPE_SCAN_USE_INSIGHT_CHECKBOX_TOOLTIP = "Использовать " ..
            f.bb("Блистательное озарение") ..
            " или\n" ..
            f.bb("Малое блистательное озарение") ..
            " в качестве дополнительного реагента для рецептов, которые это позволяют.",
        RECIPE_SCAN_ONLY_FAVORITES_CHECKBOX = "Только избранное",
        RECIPE_SCAN_ONLY_FAVORITES_CHECKBOX_TOOLTIP = "Сканировать только ваши избранные рецепты",
        RECIPE_SCAN_EQUIPPED = "Надето",
        RECIPE_SCAN_MODE_OPTIMIZE = "Оптимизировать реагенты",
        RECIPE_SCAN_SORT_MODE_PROFIT = "Прибыль",
        RECIPE_SCAN_SORT_MODE_RELATIVE_PROFIT = "Относительная прибыль",
        RECIPE_SCAN_SORT_MODE_CONCENTRATION_VALUE = "Значение концентрации",
        RECIPE_SCAN_SORT_MODE_CONCENTRATION_COST = "Затраты концентрации",
        RECIPE_SCAN_EXPANSION_FILTER_BUTTON = "Дополнения",
        RECIPE_SCAN_ALTPROFESSIONS_FILTER_BUTTON = "Профессии альтов",
        RECIPE_SCAN_SCAN_ALL_BUTTON_READY = "Сканировать профессии",
        RECIPE_SCAN_SCAN_ALL_BUTTON_SCANNING = "Сканирование...",
        RECIPE_SCAN_TAB_LABEL_SCAN = "Сканирование рецептов",
        RECIPE_SCAN_TAB_LABEL_OPTIONS = "Параметры сканирования",
        RECIPE_SCAN_IMPORT_ALL_PROFESSIONS_CHECKBOX_LABEL = "Все просканированные профессии",
        RECIPE_SCAN_IMPORT_ALL_PROFESSIONS_CHECKBOX_TOOLTIP = f.g("Включено: ") ..
            "Импортировать результаты сканирования всех включенных и просканированных профессий\n\n" ..
            f.r("Выключено: ") .. "Импортировать результаты сканирования только из выбранной в данный момент профессии",
        RECIPE_SCAN_CACHED_RECIPES_TOOLTIP =
            "Каждый раз, когда вы открываете или сканируете рецепт персонажа, " ..
            f.l("CraftSim") ..
            " запоминает его.\n\nТолько рецепты ваших альтов, которые " ..
            f.l("CraftSim") .. " помнит, будут просканированы с помощью " .. f.bb("Сканирования рецептов\n\n") ..
            "Фактическое количество сканируемых рецептов зависит от ваших " .. f.e("Параметров сканирования рецептов"),
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
        OPTIMIZATION_OPTIONS_FINISHING_REAGENTS_SIMPLE_TOOLTIP =
        "Optimizes reagent allocation first, then concentration, then selects the best finishing reagent for each slot individually.",
        OPTIMIZATION_OPTIONS_FINISHING_REAGENTS_PERMUTATION = "Permutation Based",
        OPTIMIZATION_OPTIONS_FINISHING_REAGENTS_PERMUTATION_TOOLTIP =
        "Tries all possible finishing reagent combinations and for each individually optimizes reagents (if enabled) and concentration (if enabled), then selects the most profitable combination.\n\nWarning: This may take significantly longer to complete.",
        RECIPE_SCAN_AUTOSELECT_OPEN_PROFESSION = "Autoselect Open Profession",

        -- Recipe Top Gear
        TOP_GEAR_TITLE = "Снаряжение CraftSim",
        TOP_GEAR_AUTOMATIC = "Автоматически",
        TOP_GEAR_AUTOMATIC_TOOLTIP =
        "Автоматически симулировать снаряжение для выбранного вами режима при каждом обновлении рецепта.\n\nОтключение этого параметра может повысить производительность.",
        TOP_GEAR_SIMULATE = "Симулировать снаряжение",
        TOP_GEAR_EQUIP = "Надеть",
        TOP_GEAR_SIMULATE_QUALITY = "Качество: ",
        TOP_GEAR_SIMULATE_EQUIPPED = "Надето лучшее снаряжение",
        TOP_GEAR_SIMULATE_PROFIT_DIFFERENCE = "Ø Разница в прибыли\n",
        TOP_GEAR_SIMULATE_NEW_MUTLICRAFT = "Новое перепроизводство\n",
        TOP_GEAR_SIMULATE_NEW_CRAFTING_SPEED = "Новая скорость изготовления\n",
        TOP_GEAR_SIMULATE_NEW_RESOURCEFULNESS = "Новая находчивость\n",
        TOP_GEAR_SIMULATE_NEW_SKILL = "Новый навык\n",
        TOP_GEAR_SIMULATE_UNHANDLED = "Режим необработанной симуляции",

        TOP_GEAR_SIM_MODES_PROFIT = "Максимальная прибыль",
        TOP_GEAR_SIM_MODES_SKILL = "Высший навык",
        TOP_GEAR_SIM_MODES_MULTICRAFT = "Высшее перепроизводство",
        TOP_GEAR_SIM_MODES_RESOURCEFULNESS = "Высшая находчивость",
        TOP_GEAR_SIM_MODES_CRAFTING_SPEED = "Высшая скорость изготовления",

        -- Options
        OPTIONS_TITLE = "CraftSim",
        OPTIONS_GENERAL_TAB = "Общие",
        OPTIONS_GENERAL_PRICE_SOURCE = "Источник цен",
        OPTIONS_GENERAL_CURRENT_PRICE_SOURCE = "Текущий источник цен: ",
        OPTIONS_GENERAL_NO_PRICE_SOURCE = "Не загружен аддон-источник цен!",
        OPTIONS_GENERAL_SHOW_PROFIT = "Показать процент прибыли",
        OPTIONS_GENERAL_SHOW_PROFIT_TOOLTIP =
        "Показать процент прибыли от затрат на крафт помимо стоимости в золоте",
        OPTIONS_GENERAL_REMEMBER_LAST_RECIPE = "Запомнить последний рецепт",
        OPTIONS_GENERAL_REMEMBER_LAST_RECIPE_TOOLTIP =
        "Повторно открыть последний выбранный рецепт при открытии окна крафта",
        OPTIONS_GENERAL_SUPPORTED_PRICE_SOURCES = "Поддерживаемые источники цен:",
        OPTIONS_PERFORMANCE_RAM = "Включить очистку оперативной памяти во время крафта",
        OPTIONS_PERFORMANCE_RAM_TOOLTIP =
        "При включении CraftSim будет очищать вашу оперативную память при каждом указанном количестве крафтов от неиспользуемых данных, чтобы предотвратить накопление памяти.\nНакопление памяти также может произойти из-за других дополнений и не является специфичным для CraftSim.\nОчистка затронет всё использование оперативной памяти WoW.",
        OPTIONS_MODULES_TAB = "Модули",
        OPTIONS_PROFIT_CALCULATION_TAB = "Расчет прибыли",
        OPTIONS_CRAFTING_TAB = "Изготовление",
        OPTIONS_TSM_RESET = "Сбросить по умолчанию",
        OPTIONS_TSM_INVALID_EXPRESSION = "Недопустимое выражение",
        OPTIONS_TSM_VALID_EXPRESSION = "Допустимое выражение",
        OPTIONS_MODULES_REAGENT_OPTIMIZATION = "Модуль оптимизации материалов",
        OPTIONS_MODULES_AVERAGE_PROFIT = "Модуль средней прибыли",
        OPTIONS_MODULES_TOP_GEAR = "Модуль снаряжения",
        OPTIONS_MODULES_COST_OVERVIEW = "Модуль обзора стоимости",
        OPTIONS_MODULES_SPECIALIZATION_INFO = "Модуль информации о специализации",
        OPTIONS_MODULES_CUSTOMER_HISTORY_SIZE =
        "Максимальное количество сообщений\nистории клиентов на одного клиента",
        OPTIONS_PROFIT_CALCULATION_OFFSET = "Сместить точки навыков на 1",
        OPTIONS_PROFIT_CALCULATION_OFFSET_TOOLTIP =
        "Предложение по комбинации материалов будет пытаться достичь точки + 1 вместо того, чтобы точно соответствовать требуемому навыку",
        OPTIONS_PROFIT_CALCULATION_MULTICRAFT_CONSTANT = "Константа перепроизводства",
        OPTIONS_PROFIT_CALCULATION_MULTICRAFT_CONSTANT_EXPLANATION =
        "По умолчанию: 2.5\n\nДанные о крафтах от разных игроков, собиравших данные в бета-версии и ранней версии Dragonflight, указывают, что\nмаксимальное количество дополнительных предметов, которые можно получить в результате перепроизводства, составляет 1+C*y.\nГде y — базовое количество предметов для одного крафта и C — 2.5.\nОднако, если вы хотите, вы можете изменить это значение здесь.",
        OPTIONS_PROFIT_CALCULATION_RESOURCEFULNESS_CONSTANT = "Константа находчивости",
        OPTIONS_PROFIT_CALCULATION_RESOURCEFULNESS_CONSTANT_EXPLANATION =
        "По умолчанию: 0.3\n\nДанные о крафте от разных игроков, собиравших данные в бета-версии и ранней версии Dragonflight, предполагают, что\nсреднее количество сохраняемых предметов составляет 30% от необходимого количества.\nОднако, если вы хотите, вы можете изменить это значение здесь.",
        OPTIONS_GENERAL_SHOW_NEWS_CHECKBOX = "Показать всплывающее окно " .. f.bb("Новостей"),
        OPTIONS_GENERAL_SHOW_NEWS_CHECKBOX_TOOLTIP = "Показать всплывающее окно " ..
            f.bb("Новостей") .. " для новой информации об обновлениях " .. f.l("CraftSim") .. " при входе в игру",
        OPTIONS_GENERAL_HIDE_MINIMAP_BUTTON_CHECKBOX = "Скрыть кнопку мини-карты",
        OPTIONS_GENERAL_HIDE_MINIMAP_BUTTON_TOOLTIP = "Включить скрытие кнопки мини-карты" ..
            f.l("CraftSim"),

        -- Control Panel
        CONTROL_PANEL_MODULES_CRAFT_QUEUE_LABEL = "Очередь крафта",
        CONTROL_PANEL_MODULES_CRAFT_QUEUE_TOOLTIP =
        "Ставьте рецепты в очередь и создавайте их все в одном месте!",
        CONTROL_PANEL_MODULES_TOP_GEAR_LABEL = "Снаряжение",
        CONTROL_PANEL_MODULES_TOP_GEAR_TOOLTIP =
        "Показывает лучшую доступную комбинацию снаряжения для профессии в зависимости от выбранного режима",
        CONTROL_PANEL_MODULES_COST_OVERVIEW_LABEL = "Данные о ценах",
        CONTROL_PANEL_MODULES_COST_OVERVIEW_TOOLTIP =
        "Показывает цену продажи и обзор прибыли в зависимости от качества товара",
        CONTROL_PANEL_MODULES_AVERAGE_PROFIT_LABEL = "Средняя прибыль",
        CONTROL_PANEL_MODULES_AVERAGE_PROFIT_TOOLTIP =
        "Показывает среднюю прибыль на основе характеристик вашей профессии и прибыль от каждого очка характеристик в золоте.",
        CONTROL_PANEL_MODULES_REAGENT_OPTIMIZATION_LABEL = "Оптимизация материалов",
        CONTROL_PANEL_MODULES_REAGENT_OPTIMIZATION_TOOLTIP =
        "Предлагает самые дешевые материалы для достижения наивысшего порога качества.",
        CONTROL_PANEL_MODULES_PRICE_OVERRIDES_LABEL = "Переопределение",
        CONTROL_PANEL_MODULES_PRICE_OVERRIDES_TOOLTIP =
        "Переопределить цены на любые материалы, дополнительные материалы и результаты крафта для всех рецептов или для одного рецепта конкретно.",
        CONTROL_PANEL_MODULES_SPECIALIZATION_INFO_LABEL = "Инфо о спец.",
        CONTROL_PANEL_MODULES_SPECIALIZATION_INFO_TOOLTIP =
        "Показывает, как специализации вашей профессии влияют на этот рецепт и позволяет симулировать любую конфигурацию!",
        CONTROL_PANEL_MODULES_CRAFT_LOG_LABEL = "Результаты крафта",
        CONTROL_PANEL_MODULES_CRAFT_LOG_TOOLTIP =
        "Показать журнал крафта и статистику ваших крафтов!",
        CONTROL_PANEL_MODULES_COST_OPTIMIZATION_LABEL = "Данные о стоимости",
        CONTROL_PANEL_MODULES_COST_OPTIMIZATION_TOOLTIP =
        "Модуль, показывающий подробную информацию о стоимости крафта",
        CONTROL_PANEL_MODULES_STATISTICS_LABEL = "Статистика",
        CONTROL_PANEL_MODULES_STATISTICS_TOOLTIP =
        "Модуль, который показывает подробную статистику результатов для текущего открытого рецепта",
        CONTROL_PANEL_MODULES_RECIPE_SCAN_LABEL = "Скан. рецептов",
        CONTROL_PANEL_MODULES_RECIPE_SCAN_TOOLTIP =
        "Модуль, которой сканирует ваш список рецептов на базе заданных параметров",
        CONTROL_PANEL_MODULES_CUSTOMER_HISTORY_LABEL = "История клиентов",
        CONTROL_PANEL_MODULES_CUSTOMER_HISTORY_TOOLTIP =
        "Модуль, который предоставляет историю взаимодействия с клиентами, созданных предметов и комиссий",
        CONTROL_PANEL_MODULES_CRAFT_BUFFS_LABEL = "Усиления",
        CONTROL_PANEL_MODULES_CRAFT_BUFFS_TOOLTIP =
        "Модуль, который показывает ваши активные и недостающие ремесленные усиления",
        CONTROL_PANEL_MODULES_EXPLANATIONS_LABEL = "Объяснения",
        CONTROL_PANEL_MODULES_EXPLANATIONS_TOOLTIP =
            "Модуль, который показывает вам различные объяснения того, как" .. f.l(" CraftSim") .. " проводит вычисления",
        CONTROL_PANEL_RESET_FRAMES = "Сбросить позиции",
        CONTROL_PANEL_OPTIONS = "Параметры",
        CONTROL_PANEL_NEWS = "Новости",
        CONTROL_PANEL_EASYCRAFT_EXPORT = "Экспорт " .. f.l("Easycraft"),
        CONTROL_PANEL_EASYCRAFT_EXPORTING = "Экспорт",
        CONTROL_PANEL_EASYCRAFT_EXPORT_NO_RECIPE_FOUND =
        "Нет рецепта для экспорта для дополнения The War Within",
        CONTROL_PANEL_FORGEFINDER_EXPORT = "Экспорт " .. f.l("ForgeFinder"),
        CONTROL_PANEL_FORGEFINDER_EXPORTING = "Экспорт",
        CONTROL_PANEL_EXPORT_EXPLANATION = f.l("wowforgefinder.com") ..
            " & " .. f.l("easycraft.io") ..
            "\n- веб-сайт для поиска и предложения " .. f.bb("заказов в WoW"),
        CONTROL_PANEL_DEBUG = "Отладка",
        CONTROL_PANEL_TITLE = "Панель управления",
        CONTROL_PANEL_SUPPORTERS_BUTTON = f.patreon("Поддержавшие"),

        -- Supporters
        SUPPORTERS_DESCRIPTION = f.l("Спасибо всем этим замечательным людям!"),
        SUPPORTERS_DESCRIPTION_2 = f.l(
            "Хотите ли вы поддержать CraftSim и также быть упомянутыми здесь со своим сообщением?\nРассмотрите возможность пожертвования <3"),
        SUPPORTERS_DATE = "Дата",
        SUPPORTERS_SUPPORTER = "Имя",
        SUPPORTERS_MESSAGE = "Сообщение",

        -- Customer History
        CUSTOMER_HISTORY_TITLE = "История клиентов CraftSim",
        CUSTOMER_HISTORY_DROPDOWN_LABEL = "Выберите клиента",
        CUSTOMER_HISTORY_TOTAL_TIP = "Сумма чаевых: ",
        CUSTOMER_HISTORY_FROM = "От",
        CUSTOMER_HISTORY_TO = "До",
        CUSTOMER_HISTORY_FOR = "Для",
        CUSTOMER_HISTORY_CRAFT_FORMAT = "Создано %s для %s",
        CUSTOMER_HISTORY_DELETE_BUTTON = "Удалить клиента",
        CUSTOMER_HISTORY_WHISPER_BUTTON_LABEL = "Шепот..",
        CUSTOMER_HISTORY_PURGE_NO_TIP_LABEL = "Удалить клиентов с 0 чаевыми",
        CUSTOMER_HISTORY_PURGE_ZERO_TIPS_CONFIRMATION_POPUP =
        "Вы уверены, что хотите удалить все данные\nот клиентов с общей суммой чаевых 0?",
        CUSTOMER_HISTORY_DELETE_CUSTOMER_CONFIRMATION_POPUP =
        "Вы уверены, что хотите удалить\nвсе данные для %s?",
        CUSTOMER_HISTORY_PURGE_DAYS_INPUT_LABEL = "Интервал автоматического удаления (Дней)",
        CUSTOMER_HISTORY_PURGE_DAYS_INPUT_TOOLTIP =
        "CraftSim автоматически удалит всех клиентов с 0 чаевыми при входе в систему через X дней после последнего удаления.\nЕсли установлено значение 0, CraftSim никогда не будет удалять автоматически.",
        CUSTOMER_HISTORY_CUSTOMER_HEADER = "Клиент",
        CUSTOMER_HISTORY_TOTAL_TIP_HEADER = "Сумма чаевых",
        CUSTOMER_HISTORY_CRAFT_HISTORY_DATE_HEADER = "Дата",
        CUSTOMER_HISTORY_CRAFT_HISTORY_RESULT_HEADER = "Результат",
        CUSTOMER_HISTORY_CRAFT_HISTORY_TIP_HEADER = "Чаевые",
        CUSTOMER_HISTORY_CRAFT_HISTORY_CUSTOMER_REAGENTS_HEADER = "Реагенты клиента",
        CUSTOMER_HISTORY_CRAFT_HISTORY_CUSTOMER_NOTE_HEADER = "Примечание",


        -- Craft Queue
        CRAFT_QUEUE_TITLE = "Очередь крафта CraftSim",
        CRAFT_QUEUE_CRAFT_AMOUNT_LEFT_HEADER = "В очереди",
        CRAFT_QUEUE_CRAFT_PROFESSION_GEAR_HEADER = "Снаряжение",
        CRAFT_QUEUE_CRAFTING_COSTS_HEADER = "Стоимость изготовления",
        CRAFT_QUEUE_CRAFT_BUTTON_ROW_LABEL = "Создать",
        CRAFT_QUEUE_CRAFT_BUTTON_ROW_LABEL_WRONG_GEAR = "Неправильные инструменты",
        CRAFT_QUEUE_CRAFT_BUTTON_ROW_LABEL_NO_REAGENTS = "Нет материалов",
        CRAFT_QUEUE_ADD_OPEN_RECIPE_BUTTON_LABEL = "Добавить открытый рецепт",
        CRAFT_QUEUE_CLEAR_ALL_BUTTON_LABEL = "Очистить все",
        CRAFT_QUEUE_RESTOCK_FAVORITES_BUTTON_LABEL =
        "Пополнить запасы на основе сканирования рецептов",
        CRAFT_QUEUE_CRAFT_BUTTON_ROW_LABEL_WRONG_PROFESSION = "Неправильная профессия",
        CRAFT_QUEUE_CRAFT_BUTTON_ROW_LABEL_ON_COOLDOWN = "На перезарядке",
        CRAFT_QUEUE_CRAFT_BUTTON_ROW_LABEL_WRONG_CRAFTER = "Неправильный крафтер",
        CRAFT_QUEUE_RECIPE_REQUIREMENTS_HEADER = "Состояние",
        CRAFT_QUEUE_CRAFT_NEXT_BUTTON_LABEL = "Создать дальше",
        CRAFT_QUEUE_CRAFT_AVAILABLE_AMOUNT = "Можно создать",
        CRAFTQUEUE_AUCTIONATOR_SHOPPING_LIST_BUTTON_LABEL = "Создать список покупок Auctionator",
        CRAFT_QUEUE_QUEUE_TAB_LABEL = "Очередь крафта",
        CRAFT_QUEUE_FLASH_TASKBAR_OPTION_LABEL =
            "Помигать иконкой панели задач по завершении крафта в " ..
            f.bb("Очереди крафта"),
        CRAFT_QUEUE_FLASH_TASKBAR_OPTION_TOOLTIP =
            "Когда ваш клиент WoW свернут и крафт рецепта в " .. f.bb("Очереди крафта") ..
            " заканчивается," .. f.l(" CraftSim") .. " заставит иконку WoW в панели задач замигать",
        CRAFT_QUEUE_RESTOCK_OPTIONS_TAB_LABEL = "Варианты пополнения запасов",
        CRAFT_QUEUE_RESTOCK_OPTIONS_GENERAL_PROFIT_THRESHOLD_LABEL = "Порог прибыли:",
        CRAFT_QUEUE_RESTOCK_OPTIONS_SALE_RATE_INPUT_LABEL = "Порог цены продажи:",
        CRAFT_QUEUE_RESTOCK_OPTIONS_TSM_SALE_RATE_TOOLTIP = string.format(
            [[
Доступно только, если загружен %s!

Будет проверено, имеет ли %s предмет выбранного качества процент продаж
выше или равный настроенному пороговому значению цены продажи.
]], f.bb("TSM"), f.bb("любой")),
        CRAFT_QUEUE_RESTOCK_OPTIONS_TSM_SALE_RATE_TOOLTIP_GENERAL = string.format(
            [[
Доступно только, если загружен %s!

Будет проверено, имеет ли %s качество предмета процент продаж
выше или равный настроенному пороговому значению цены продажи.
]], f.bb("TSM"), f.bb("любое")),
        CRAFT_QUEUE_RESTOCK_OPTIONS_AMOUNT_LABEL = "Сумма пополнения запасов:",
        CRAFT_QUEUE_RESTOCK_OPTIONS_RESTOCK_TOOLTIP = "Это " ..
            f.bb("количество крафтов") ..
            " которое будет поставлено в очередь для этого рецепта.\n\nКоличество предметов проверенных качеств в вашем инвентаре и банке будет вычтено из суммы пополнения при пополнении",
        CRAFT_QUEUE_RESTOCK_OPTIONS_ENABLE_RECIPE_LABEL = "Включить:",
        CRAFT_QUEUE_RESTOCK_OPTIONS_GENERAL_OPTIONS_LABEL = "Общие параметры (Все рецепты)",
        CRAFT_QUEUE_RESTOCK_OPTIONS_ENABLE_RECIPE_TOOLTIP =
        "Если этот параметр отключен, рецепт будет пополнен на основе общих параметров, указанных выше",
        CRAFT_QUEUE_TOTAL_PROFIT_LABEL = "Общая Ø прибыль:",
        CRAFT_QUEUE_TOTAL_CRAFTING_COSTS_LABEL = "Общая стоимость крафта:",
        CRAFT_QUEUE_EDIT_RECIPE_TITLE = "Изменить рецепт",
        CRAFT_QUEUE_EDIT_RECIPE_NAME_LABEL = "Название рецепта",
        CRAFT_QUEUE_EDIT_RECIPE_REAGENTS_SELECT_LABEL = "Выбрать",
        CRAFT_QUEUE_EDIT_RECIPE_OPTIONAL_REAGENTS_LABEL = "Необязательные реагенты",
        CRAFT_QUEUE_EDIT_RECIPE_FINISHING_REAGENTS_LABEL = "Завершающие реагенты",
        CRAFT_QUEUE_EDIT_RECIPE_PROFESSION_GEAR_LABEL = "Профессиональное снаряжение",
        CRAFT_QUEUE_EDIT_RECIPE_OPTIMIZE_PROFIT_BUTTON = "Оптимизировать прибыль",
        CRAFT_QUEUE_EDIT_RECIPE_CRAFTING_COSTS_LABEL = "Стоимость изготовления: ",
        CRAFT_QUEUE_EDIT_RECIPE_AVERAGE_PROFIT_LABEL = "Средняя прибыль: ",
        CRAFT_QUEUE_EDIT_RECIPE_RESULTS_LABEL = "Результаты",
        CRAFT_QUEUE_EDIT_RECIPE_CONCENTRATION_CHECKBOX = " Концентрация",
        CRAFT_QUEUE_AUCTIONATOR_SHOPPING_LIST_PER_CHARACTER_CHECKBOX = "Для персонажа",
        CRAFT_QUEUE_AUCTIONATOR_SHOPPING_LIST_PER_CHARACTER_CHECKBOX_TOOLTIP = "Создать " ..
            f.bb("Список покупок Auctionator") ..
            " для каждого персонажа-крафтера\nвместо одного списка покупок для всех",
        CRAFT_QUEUE_AUCTIONATOR_SHOPPING_LIST_TARGET_MODE_CHECKBOX = "Только целевой режим",
        CRAFT_QUEUE_AUCTIONATOR_SHOPPING_LIST_TARGET_MODE_CHECKBOX_TOOLTIP = "Создать " ..
            f.bb("Список покупок Auctionator") .. " только для рецептов целевого режима",
        CRAFT_QUEUE_UNSAVED_CHANGES_TOOLTIP = f.white(
            "Величина очереди не сохранена.\nНажмите Enter для сохранения"),
        CRAFT_QUEUE_STATUSBAR_LEARNED = f.white("Рецепт изучен"),
        CRAFT_QUEUE_STATUSBAR_COOLDOWN = f.white("Не восстанавливается"),
        CRAFT_QUEUE_STATUSBAR_REAGENTS = f.white("Материалы доступны"),
        CRAFT_QUEUE_STATUSBAR_GEAR = f.white("Профессиональное снаряжение надето"),
        CRAFT_QUEUE_STATUSBAR_CRAFTER = f.white("Правильный персонаж-крафтер"),
        CRAFT_QUEUE_STATUSBAR_PROFESSION = f.white("Профессия открыта"),

        -- craft buffs

        CRAFT_BUFFS_TITLE = "Усиления CraftSim",
        CRAFT_BUFFS_SIMULATE_BUTTON = "Симулировать усиления",
        CRAFT_BUFF_CHEFS_HAT_TOOLTIP = f.bb("Игрушка из Wrath of the Lich King.") ..
            "\nТребуется кулинария Нордскола\nУстанавливает скорость изготовления на " .. f.g("0.5 секунды"),

        -- cooldowns module

        COOLDOWNS_TITLE = "Кулдауны CraftSim",
        CONTROL_PANEL_MODULES_COOLDOWNS_LABEL = "Кулдауны",
        CONTROL_PANEL_MODULES_COOLDOWNS_TOOLTIP = "Обзор " ..
            f.bb("Кулдаунов профессий") .. " вашей учетной записи",
        COOLDOWNS_CRAFTER_HEADER = "Ремесленник",
        COOLDOWNS_RECIPE_HEADER = "Рецепт",
        COOLDOWNS_CHARGES_HEADER = "Заряды",
        COOLDOWNS_NEXT_HEADER = "Следующий заряд",
        COOLDOWNS_ALL_HEADER = "Полный заряд",

        CONCENTRATION_TRACKER_TITLE = "Концентрация CraftSim",

        -- static popups
        STATIC_POPUPS_YES = "Да",
        STATIC_POPUPS_NO = "Нет",
    }
end
