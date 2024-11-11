---@class CraftSim
local CraftSim = select(2, ...)

CraftSim.LOCAL_RU = {}

function CraftSim.LOCAL_RU:GetData()
    local f = CraftSim.GUTIL:GetFormatter()
    local cm = function(i, s) return CraftSim.MEDIA:GetAsTextIcon(i, s) end
    return {
        -- REQUIRED:
        [CraftSim.CONST.TEXT.STAT_MULTICRAFT] = "Перепроизводство",
        [CraftSim.CONST.TEXT.STAT_RESOURCEFULNESS] = "Находчивость",
        [CraftSim.CONST.TEXT.STAT_INGENUITY] = "Изобретательность",
        [CraftSim.CONST.TEXT.STAT_CRAFTINGSPEED] = "Скорость изготовления",
        [CraftSim.CONST.TEXT.EQUIP_MATCH_STRING] = "Если на персонаже:",
        [CraftSim.CONST.TEXT.ENCHANTED_MATCH_STRING] = "Чары:",

        -- OPTIONAL (Defaulting to EN if not available):

        -- shared prof cds
        [CraftSim.CONST.TEXT.DF_ALCHEMY_TRANSMUTATIONS] = "Трансмутация DF",

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

        [CraftSim.CONST.TEXT.PROFESSIONS_BLACKSMITHING] = "Кузнечное дело",
        [CraftSim.CONST.TEXT.PROFESSIONS_LEATHERWORKING] = "Кожевничество",
        [CraftSim.CONST.TEXT.PROFESSIONS_ALCHEMY] = "Алхимия",
        [CraftSim.CONST.TEXT.PROFESSIONS_HERBALISM] = "Травничество",
        [CraftSim.CONST.TEXT.PROFESSIONS_COOKING] = "Кулинария",
        [CraftSim.CONST.TEXT.PROFESSIONS_MINING] = "Горное дело",
        [CraftSim.CONST.TEXT.PROFESSIONS_TAILORING] = "Портняжное дело",
        [CraftSim.CONST.TEXT.PROFESSIONS_ENGINEERING] = "Инженерное дело",
        [CraftSim.CONST.TEXT.PROFESSIONS_ENCHANTING] = "Зачарование",
        [CraftSim.CONST.TEXT.PROFESSIONS_FISHING] = "Рыбная ловля",
        [CraftSim.CONST.TEXT.PROFESSIONS_SKINNING] = "Снятие шкур",
        [CraftSim.CONST.TEXT.PROFESSIONS_JEWELCRAFTING] = "Ювелирное дело",
        [CraftSim.CONST.TEXT.PROFESSIONS_INSCRIPTION] = "Начертание",

        -- Other Statnames

        [CraftSim.CONST.TEXT.STAT_SKILL] = "Навык",
        [CraftSim.CONST.TEXT.STAT_MULTICRAFT_BONUS] = "Бонус предметов от перепроизводства",
        [CraftSim.CONST.TEXT.STAT_RESOURCEFULNESS_BONUS] = "Бонус предметов от наход.",
        [CraftSim.CONST.TEXT.STAT_CRAFTINGSPEED_BONUS] = "Скорость изготовления",
        [CraftSim.CONST.TEXT.STAT_INGENUITY_BONUS] = "Сохраненная изобретательностью концентрация",
        [CraftSim.CONST.TEXT.STAT_INGENUITY_LESS_CONCENTRATION] = "Снижение затрат концентрации",
        [CraftSim.CONST.TEXT.STAT_PHIAL_EXPERIMENTATION] = "Прорыв в экспериментах с флаконами",
        [CraftSim.CONST.TEXT.STAT_POTION_EXPERIMENTATION] = "Прорыв в экспериментах с зельями",

        -- Profit Breakdown Tooltips
        [CraftSim.CONST.TEXT.RESOURCEFULNESS_EXPLANATION_TOOLTIP] =
        "Находчивость прокает для каждого материала индивидуально, а затем сохраняет около 30% его количества.\n\nСреднее сохраненное значение - это среднее сохраненное значение КАЖДОЙ комбинации и их шансов.\n(Прок всех материалов одновременно очень маловероятен, но сохраняет очень много)\n\nСредняя общая сэкономленная стоимость материалов представляет собой сумму сэкономленных затрат на материалы всех комбинаций, взвешенную с учетом их вероятности.",

        [CraftSim.CONST.TEXT.RECIPE_DIFFICULTY_EXPLANATION_TOOLTIP] =
        "Сложность рецепта определяет, где находятся контрольные точки различных качеств.\n\nДля рецептов с пятью качествами они составляют 20%, 50%, 80% и 100% сложности рецепта в очках навыка.\nДля рецептов с тремя качествами они составляют 50% и 100%",
        [CraftSim.CONST.TEXT.MULTICRAFT_EXPLANATION_TOOLTIP] =
        "Перепроизводство дает вам возможность создать больше предметов, чем вы обычно производите по рецепту.\n\nДополнительная сумма обычно составляет от 1 до 2.5y\nгде y = обычная сумма, которую дает 1 крафт.",
        [CraftSim.CONST.TEXT.REAGENTSKILL_EXPLANATION_TOOLTIP] =
        "Качество ваших материалов может дать вам максимум 40% от базовой сложности рецепта в качестве бонусного навыка.\n\nВсе материалы Q1: бонус 0%\nВсе материалы Q2: бонус 20%\nВсе материалы Q3: бонус 40%\n n\nНавык рассчитывается по количеству материалов каждого качества, взвешенному по отношению к их качеству\n и конкретному значению веса, которое уникально для каждого отдельного материала для крафта Dragonflight\n\nОднако для переделок это отличается. Существует предел того, насколько реагенты могут увеличить качество,\nон зависит от качества материалов, из которых изначально был создан предмет.\nТочные принципы работы неизвестны.\nОднако CraftSim внутренне сравнивает достигнутый навык со всеми q3 и рассчитывает\nмаксимальное увеличение навыка на основе этого.",
        [CraftSim.CONST.TEXT.REAGENTFACTOR_EXPLANATION_TOOLTIP] =
        "Наибольший вклад, который материалы могут внести в рецепт, в большинстве случаев составляет 40% от базовой сложности рецепта.\n\nОднако в случае переделки это значение может варьироваться в зависимости от предыдущих крафтов\n и качества использованных ранее материалов.",

        -- Simulation Mode
        [CraftSim.CONST.TEXT.SIMULATION_MODE_NONE] = "Нет",
        [CraftSim.CONST.TEXT.SIMULATION_MODE_LABEL] = "Режим симуляции",
        [CraftSim.CONST.TEXT.SIMULATION_MODE_TITLE] = "Режим симуляции CraftSim",
        [CraftSim.CONST.TEXT.SIMULATION_MODE_TOOLTIP] =
        "Режим симуляции CraftSim позволяет экспериментировать с рецептом без ограничений",
        [CraftSim.CONST.TEXT.SIMULATION_MODE_OPTIONAL] = "Необязательные #",
        [CraftSim.CONST.TEXT.SIMULATION_MODE_FINISHING] = "Завершающие #",

        -- Details Frame
        [CraftSim.CONST.TEXT.RECIPE_DIFFICULTY_LABEL] = "Сложность рецепта: ",
        [CraftSim.CONST.TEXT.MULTICRAFT_LABEL] = "Перепроизводство: ",
        [CraftSim.CONST.TEXT.RESOURCEFULNESS_LABEL] = "Находчивость: ",
        [CraftSim.CONST.TEXT.RESOURCEFULNESS_BONUS_LABEL] = "Бонус предметов от находчивости: ",
        [CraftSim.CONST.TEXT.CONCENTRATION_LABEL] = "Концентрация: ",
        [CraftSim.CONST.TEXT.REAGENT_QUALITY_BONUS_LABEL] = "Бонус от качества материалов: ",
        [CraftSim.CONST.TEXT.REAGENT_QUALITY_MAXIMUM_LABEL] = "Наиб. бонус от кач. материалов в %: ",
        [CraftSim.CONST.TEXT.EXPECTED_QUALITY_LABEL] = "Ожидаемое качество: ",
        [CraftSim.CONST.TEXT.NEXT_QUALITY_LABEL] = "Следующее качество: ",
        [CraftSim.CONST.TEXT.MISSING_SKILL_LABEL] = "Недостающий навык: ",
        [CraftSim.CONST.TEXT.SKILL_LABEL] = "Навык: ",
        [CraftSim.CONST.TEXT.MULTICRAFT_BONUS_LABEL] = "Бонус предметов от перепроизводства: ",

        -- Statistics
        [CraftSim.CONST.TEXT.STATISTICS_CDF_EXPLANATION] =
        "Это рассчитывается с использованием аппроксимации Абрамовица и Стегуна (1985) CDF (кумулятивной функции распределения)\n\nВы заметите, что это всегда около 50% для 1 крафта.\nЭто потому, что в большинстве случаев 0 близок к средней прибыли.\nИ вероятность получения среднего значения CDF всегда составляет 50%.\n\nОднако скорость изменения может сильно различаться в зависимости от рецепта.\nЕсли вероятность получения положительной прибыли выше, чем отрицательной, он будет постоянно увеличиваться.\nЭто, конечно, верно и для другого направления.",
        [CraftSim.CONST.TEXT.EXPLANATIONS_PROFIT_CALCULATION_EXPLANATION] =
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
        [CraftSim.CONST.TEXT.POPUP_NO_PRICE_SOURCE_SYSTEM] = "Нет поддерживаемого источника цен!",
        [CraftSim.CONST.TEXT.POPUP_NO_PRICE_SOURCE_TITLE] = "Предупреждение об источнике цен CraftSim",
        [CraftSim.CONST.TEXT.POPUP_NO_PRICE_SOURCE_WARNING] =
        "Источник цен не найден!\n\nВам необходимо установить хотя бы один из\nследующих аддонов-источников цен, чтобы\nиспользовать расчеты прибыли CraftSim:\n\n\n",
        [CraftSim.CONST.TEXT.POPUP_NO_PRICE_SOURCE_WARNING_SUPPRESS] = "Больше не показывать предупреждение",

        -- Reagents Frame
        [CraftSim.CONST.TEXT.REAGENT_OPTIMIZATION_TITLE] = "Оптимизация материалов CraftSim",
        [CraftSim.CONST.TEXT.REAGENTS_REACHABLE_QUALITY] = "Достижимое качество: ",
        [CraftSim.CONST.TEXT.REAGENTS_MISSING] = "Недостающие материалы",
        [CraftSim.CONST.TEXT.REAGENTS_AVAILABLE] = "Доступные материалы",
        [CraftSim.CONST.TEXT.REAGENTS_CHEAPER] = "Самые дешевые материалы",
        [CraftSim.CONST.TEXT.REAGENTS_BEST_COMBINATION] = "Назначена лучшая комбинация",
        [CraftSim.CONST.TEXT.REAGENTS_NO_COMBINATION] = "Повышающая качество \nкомбинация не найдена",
        [CraftSim.CONST.TEXT.REAGENTS_ASSIGN] = "Назначить",

        -- Specialization Info Frame
        [CraftSim.CONST.TEXT.SPEC_INFO_TITLE] = "Информация о специализации CraftSim",
        [CraftSim.CONST.TEXT.SPEC_INFO_SIMULATE_KNOWLEDGE_DISTRIBUTION] = "Симулировать распределение знаний",
        [CraftSim.CONST.TEXT.SPEC_INFO_NODE_TOOLTIP] =
        "Этот узел предоставляет вам следующие характеристики для этого рецепта:",
        [CraftSim.CONST.TEXT.SPEC_INFO_WORK_IN_PROGRESS] = "Работа над SpecInfo продолжается",

        -- Crafting Results Frame
        [CraftSim.CONST.TEXT.CRAFT_LOG_TITLE] = "Результаты крафта CraftSim",
        [CraftSim.CONST.TEXT.CRAFT_LOG_LOG] = "Журнал крафта",
        [CraftSim.CONST.TEXT.CRAFT_LOG_LOG_1] = "Прибыль: ",
        [CraftSim.CONST.TEXT.CRAFT_LOG_LOG_2] = "Вдохновение!",
        [CraftSim.CONST.TEXT.CRAFT_LOG_LOG_3] = "Перепроизводство: ",
        [CraftSim.CONST.TEXT.CRAFT_LOG_LOG_4] = "Ресурсы сохранены!: ",
        [CraftSim.CONST.TEXT.CRAFT_LOG_LOG_5] = "Шанс: ",
        [CraftSim.CONST.TEXT.CRAFT_LOG_CRAFTED_ITEMS] = "Созданные предметы",
        [CraftSim.CONST.TEXT.CRAFT_LOG_SESSION_PROFIT] = "Прибыль за сеанс",
        [CraftSim.CONST.TEXT.CRAFT_LOG_RESET_DATA] = "Сбросить данные",
        [CraftSim.CONST.TEXT.CRAFT_LOG_EXPORT_JSON] = "Экспортировать JSON",
        [CraftSim.CONST.TEXT.CRAFT_LOG_RECIPE_STATISTICS] = "Статистика рецептов",
        [CraftSim.CONST.TEXT.CRAFT_LOG_NOTHING] = "Пока ничего не создано!",
        [CraftSim.CONST.TEXT.CRAFT_LOG_CALCULATION_COMPARISON_NUM_CRAFTS_PREFIX] = "Крафты: ",
        [CraftSim.CONST.TEXT.CRAFT_LOG_STATISTICS_2] = "Ожидаемая Ø прибыль: ",
        [CraftSim.CONST.TEXT.CRAFT_LOG_STATISTICS_3] = "Реальная Ø прибыль: ",
        [CraftSim.CONST.TEXT.CRAFT_LOG_STATISTICS_4] = "Реальная прибыль: ",
        [CraftSim.CONST.TEXT.CRAFT_LOG_STATISTICS_5] = "Проки - Реальность / Ожидание: ",
        [CraftSim.CONST.TEXT.CRAFT_LOG_STATISTICS_7] = "Перепроизводство: ",
        [CraftSim.CONST.TEXT.CRAFT_LOG_STATISTICS_8] = "- Ø дополнительные предметы: ",
        [CraftSim.CONST.TEXT.CRAFT_LOG_STATISTICS_9] = "Проки находчивости: ",
        [CraftSim.CONST.TEXT.CRAFT_LOG_CALCULATION_COMPARISON_NUM_CRAFTS_PREFIX0] = "- Ø сэкономленные затраты: ",
        [CraftSim.CONST.TEXT.CRAFT_LOG_CALCULATION_COMPARISON_NUM_CRAFTS_PREFIX1] = "Прибыль: ",
        [CraftSim.CONST.TEXT.CRAFT_LOG_SAVED_REAGENTS] = "Сохраненные реагенты",

        -- Stats Weight Frame
        [CraftSim.CONST.TEXT.STAT_WEIGHTS_TITLE] = "Средняя прибыль CraftSim",
        [CraftSim.CONST.TEXT.EXPLANATIONS_TITLE] = "Объяснение средней прибыли CraftSim",
        [CraftSim.CONST.TEXT.STAT_WEIGHTS_SHOW_EXPLANATION_BUTTON] = "Показать объяснение",
        [CraftSim.CONST.TEXT.STAT_WEIGHTS_HIDE_EXPLANATION_BUTTON] = "Скрыть объяснение",
        [CraftSim.CONST.TEXT.STAT_WEIGHTS_SHOW_STATISTICS_BUTTON] = "Показать статистику",
        [CraftSim.CONST.TEXT.STAT_WEIGHTS_HIDE_STATISTICS_BUTTON] = "Скрыть статистику",
        [CraftSim.CONST.TEXT.STAT_WEIGHTS_PROFIT_CRAFT] = "Ø Прибыль / Крафт: ",
        [CraftSim.CONST.TEXT.EXPLANATIONS_BASIC_PROFIT_TAB] = "Базовый расчет прибыли",

        -- Cost Details Frame
        [CraftSim.CONST.TEXT.COST_OPTIMIZATION_TITLE] = "Оптимизация затрат CraftSim",
        [CraftSim.CONST.TEXT.COST_OPTIMIZATION_EXPLANATION] =
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
        [CraftSim.CONST.TEXT.COST_OPTIMIZATION_CRAFTING_COSTS] = "Стоимость изготовления: ",
        [CraftSim.CONST.TEXT.COST_OPTIMIZATION_ITEM_HEADER] = "Предмет",
        [CraftSim.CONST.TEXT.COST_OPTIMIZATION_AH_PRICE_HEADER] = "Цена AH",
        [CraftSim.CONST.TEXT.COST_OPTIMIZATION_OVERRIDE_HEADER] = "Переопределение",
        [CraftSim.CONST.TEXT.COST_OPTIMIZATION_CRAFTING_HEADER] = "Изготовление",
        [CraftSim.CONST.TEXT.COST_OPTIMIZATION_USED_SOURCE] = "Использованный источник",

        -- Statistics Frame
        [CraftSim.CONST.TEXT.STATISTICS_TITLE] = "Статистика CraftSim",
        [CraftSim.CONST.TEXT.STATISTICS_EXPECTED_PROFIT] = "Ожидаемая прибыль (μ)",
        [CraftSim.CONST.TEXT.STATISTICS_CHANCE_OF] = "Шанс ",
        [CraftSim.CONST.TEXT.STATISTICS_PROFIT] = "Прибыли",
        [CraftSim.CONST.TEXT.STATISTICS_AFTER] = " после",
        [CraftSim.CONST.TEXT.STATISTICS_CRAFTS] = "Крафтов: ",
        [CraftSim.CONST.TEXT.STATISTICS_QUALITY_HEADER] = "Качество",
        [CraftSim.CONST.TEXT.STATISTICS_MULTICRAFT_HEADER] = "Перепроизводство",
        [CraftSim.CONST.TEXT.STATISTICS_RESOURCEFULNESS_HEADER] = "Находчивость",
        [CraftSim.CONST.TEXT.STATISTICS_EXPECTED_PROFIT_HEADER] = "Ожидаемая прибыль",
        [CraftSim.CONST.TEXT.PROBABILITY_TABLE_TITLE] = "Таблица вероятностей рецептов",

        -- Price Details Frame
        [CraftSim.CONST.TEXT.COST_OVERVIEW_TITLE] = "Информация о ценах CraftSim",
        [CraftSim.CONST.TEXT.PRICE_DETAILS_INV_AH] = "Инв/Аук",
        [CraftSim.CONST.TEXT.PRICE_DETAILS_ITEM] = "Предмет",
        [CraftSim.CONST.TEXT.PRICE_DETAILS_PRICE_ITEM] = "Цена/Предмет",
        [CraftSim.CONST.TEXT.PRICE_DETAILS_PROFIT_ITEM] = "Прибыль/Предмет",

        -- Price Override Frame
        [CraftSim.CONST.TEXT.PRICE_OVERRIDE_TITLE] = "Переопределение цены CraftSim",
        [CraftSim.CONST.TEXT.PRICE_OVERRIDE_REQUIRED_REAGENTS] = "Необходимые реагенты",
        [CraftSim.CONST.TEXT.PRICE_OVERRIDE_OPTIONAL_REAGENTS] = "Необязательные реагенты",
        [CraftSim.CONST.TEXT.PRICE_OVERRIDE_FINISHING_REAGENTS] = "Завершающие реагенты",
        [CraftSim.CONST.TEXT.PRICE_OVERRIDE_RESULT_ITEMS] = "Результат",
        [CraftSim.CONST.TEXT.PRICE_OVERRIDE_ACTIVE_OVERRIDES] = "Активные переопределения",
        [CraftSim.CONST.TEXT.PRICE_OVERRIDE_ACTIVE_OVERRIDES_TOOLTIP] =
        "'(как результат)' -> переопределение цены учитывается только в том случае, если предмет является результатом рецепта",
        [CraftSim.CONST.TEXT.PRICE_OVERRIDE_CLEAR_ALL] = "Очистить все",
        [CraftSim.CONST.TEXT.PRICE_OVERRIDE_SAVE] = "Сохранить",
        [CraftSim.CONST.TEXT.PRICE_OVERRIDE_SAVED] = "Сохранено",
        [CraftSim.CONST.TEXT.PRICE_OVERRIDE_REMOVE] = "Удалить",

        -- Recipe Scan Frame
        [CraftSim.CONST.TEXT.RECIPE_SCAN_TITLE] = "Сканирование рецептов CraftSim",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_MODE] = "Режим сканирования",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_SORT_MODE] = "Режим сортировки",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_SCAN_RECIPIES] = "Сканировать рецепты",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_SCAN_CANCEL] = "Отмена",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_SCANNING] = "Сканирование",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_INCLUDE_NOT_LEARNED] = "Включить не изученные",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_INCLUDE_NOT_LEARNED_TOOLTIP] =
        "Включить в сканирование рецептов рецепты, которые вы не изучили",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_INCLUDE_SOULBOUND] = "Включить персональные",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_INCLUDE_SOULBOUND_TOOLTIP] =
        "Включайте персональные рецепты в сканирование рецептов.\n\nРекомендуется установить переопределение цены (например, для симуляции целевой комиссии)\nin в Модуле переопределения цены для предметов, созданных по этому рецепту",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_INCLUDE_GEAR] = "Включить снаряжение",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_INCLUDE_GEAR_TOOLTIP] =
        "Включить в сканирование рецептов все рецепты снаряжения",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_OPTIMIZE_TOOLS] = "Оптимизация инструментов",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_OPTIMIZE_TOOLS_TOOLTIP] =
        "Для каждого рецепта оптимизировать инструменты для наибольшей прибыли\n\n",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_OPTIMIZE_TOOLS_WARNING] =
        "Может снизиться производительность во время сканирования,\nесли в вашем инвентаре много инструментов",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_CRAFTER_HEADER] = "Ремесленник",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_RECIPE_HEADER] = "Рецепт",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_LEARNED_HEADER] = "Изучено",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_RESULT_HEADER] = "Результат",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_AVERAGE_PROFIT_HEADER] = "Средняя прибыль",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_CONCENTRATION_VALUE_HEADER] = "Значение конц.",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_CONCENTRATION_COST_HEADER] = "Затраты конц.",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_TOP_GEAR_HEADER] = "Лучшая экипировка",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_INV_AH_HEADER] = "Инв/Аук",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_SORT_BY_MARGIN] = "Сортировать по % прибыли",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_SORT_BY_MARGIN_TOOLTIP] =
        "Отсортировать список прибыли по прибыли относительно затрат на изготовление.\n(Требуется новое сканирование)",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_USE_INSIGHT_CHECKBOX] = "По возможности использовать " .. f.bb("Озарение"),
        [CraftSim.CONST.TEXT.RECIPE_SCAN_USE_INSIGHT_CHECKBOX_TOOLTIP] = "Использовать " ..
            f.bb("Блистательное озарение") ..
            " или\n" ..
            f.bb("Малое блистательное озарение") ..
            " в качестве дополнительного реагента для рецептов, которые это позволяют.",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_ONLY_FAVORITES_CHECKBOX] = "Только избранное",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_ONLY_FAVORITES_CHECKBOX_TOOLTIP] = "Сканировать только ваши избранные рецепты",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_EQUIPPED] = "Надето",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_MODE_OPTIMIZE] = "Оптимизировать реагенты",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_SORT_MODE_PROFIT] = "Прибыль",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_SORT_MODE_RELATIVE_PROFIT] = "Относительная прибыль",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_SORT_MODE_CONCENTRATION_VALUE] = "Значение концентрации",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_SORT_MODE_CONCENTRATION_COST] = "Затраты концентрации",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_EXPANSION_FILTER_BUTTON] = "Дополнения",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_ALTPROFESSIONS_FILTER_BUTTON] = "Профессии альтов",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_SCAN_ALL_BUTTON_READY] = "Сканировать профессии",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_SCAN_ALL_BUTTON_SCANNING] = "Сканирование...",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_TAB_LABEL_SCAN] = "Сканирование рецептов",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_TAB_LABEL_OPTIONS] = "Параметры сканирования",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_IMPORT_ALL_PROFESSIONS_CHECKBOX_LABEL] = "Все просканированные профессии",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_IMPORT_ALL_PROFESSIONS_CHECKBOX_TOOLTIP] = f.g("Включено: ") ..
            "Импортировать результаты сканирования всех включенных и просканированных профессий\n\n" ..
            f.r("Выключено: ") .. "Импортировать результаты сканирования только из выбранной в данный момент профессии",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_CACHED_RECIPES_TOOLTIP] =
            "Каждый раз, когда вы открываете или сканируете рецепт персонажа, " ..
            f.l("CraftSim") ..
            " запоминает его.\n\nТолько рецепты ваших альтов, которые " ..
            f.l("CraftSim") .. " помнит, будут просканированы с помощью " .. f.bb("Сканирования рецептов\n\n") ..
            "Фактическое количество сканируемых рецептов зависит от ваших " .. f.e("Параметров сканирования рецептов"),

        -- Recipe Top Gear
        [CraftSim.CONST.TEXT.TOP_GEAR_TITLE] = "Снаряжение CraftSim",
        [CraftSim.CONST.TEXT.TOP_GEAR_AUTOMATIC] = "Автоматически",
        [CraftSim.CONST.TEXT.TOP_GEAR_AUTOMATIC_TOOLTIP] =
        "Автоматически симулировать снаряжение для выбранного вами режима при каждом обновлении рецепта.\n\nОтключение этого параметра может повысить производительность.",
        [CraftSim.CONST.TEXT.TOP_GEAR_SIMULATE] = "Симулировать снаряжение",
        [CraftSim.CONST.TEXT.TOP_GEAR_EQUIP] = "Надеть",
        [CraftSim.CONST.TEXT.TOP_GEAR_SIMULATE_QUALITY] = "Качество: ",
        [CraftSim.CONST.TEXT.TOP_GEAR_SIMULATE_EQUIPPED] = "Надето лучшее снаряжение",
        [CraftSim.CONST.TEXT.TOP_GEAR_SIMULATE_PROFIT_DIFFERENCE] = "Ø Разница в прибыли\n",
        [CraftSim.CONST.TEXT.TOP_GEAR_SIMULATE_NEW_MUTLICRAFT] = "Новое перепроизводство\n",
        [CraftSim.CONST.TEXT.TOP_GEAR_SIMULATE_NEW_CRAFTING_SPEED] = "Новая скорость изготовления\n",
        [CraftSim.CONST.TEXT.TOP_GEAR_SIMULATE_NEW_RESOURCEFULNESS] = "Новая находчивость\n",
        [CraftSim.CONST.TEXT.TOP_GEAR_SIMULATE_NEW_SKILL] = "Новый навык\n",
        [CraftSim.CONST.TEXT.TOP_GEAR_SIMULATE_UNHANDLED] = "Режим необработанной симуляции",

        [CraftSim.CONST.TEXT.TOP_GEAR_SIM_MODES_PROFIT] = "Максимальная прибыль",
        [CraftSim.CONST.TEXT.TOP_GEAR_SIM_MODES_SKILL] = "Высший навык",
        [CraftSim.CONST.TEXT.TOP_GEAR_SIM_MODES_MULTICRAFT] = "Высшее перепроизводство",
        [CraftSim.CONST.TEXT.TOP_GEAR_SIM_MODES_RESOURCEFULNESS] = "Высшая находчивость",
        [CraftSim.CONST.TEXT.TOP_GEAR_SIM_MODES_CRAFTING_SPEED] = "Высшая скорость изготовления",

        -- Options
        [CraftSim.CONST.TEXT.OPTIONS_TITLE] = "Параметры CraftSim",
        [CraftSim.CONST.TEXT.OPTIONS_GENERAL_TAB] = "Общие",
        [CraftSim.CONST.TEXT.OPTIONS_GENERAL_PRICE_SOURCE] = "Источник цен",
        [CraftSim.CONST.TEXT.OPTIONS_GENERAL_CURRENT_PRICE_SOURCE] = "Текущий источник цен: ",
        [CraftSim.CONST.TEXT.OPTIONS_GENERAL_NO_PRICE_SOURCE] = "Не загружен аддон-источник цен!",
        [CraftSim.CONST.TEXT.OPTIONS_GENERAL_SHOW_PROFIT] = "Показать процент прибыли",
        [CraftSim.CONST.TEXT.OPTIONS_GENERAL_SHOW_PROFIT_TOOLTIP] =
        "Показать процент прибыли от затрат на крафт помимо стоимости в золоте",
        [CraftSim.CONST.TEXT.OPTIONS_GENERAL_REMEMBER_LAST_RECIPE] = "Запомнить последний рецепт",
        [CraftSim.CONST.TEXT.OPTIONS_GENERAL_REMEMBER_LAST_RECIPE_TOOLTIP] =
        "Повторно открыть последний выбранный рецепт при открытии окна крафта",
        [CraftSim.CONST.TEXT.OPTIONS_GENERAL_SUPPORTED_PRICE_SOURCES] = "Поддерживаемые источники цен:",
        [CraftSim.CONST.TEXT.OPTIONS_PERFORMANCE_RAM] = "Включить очистку оперативной памяти во время крафта",
        [CraftSim.CONST.TEXT.OPTIONS_PERFORMANCE_RAM_TOOLTIP] =
        "При включении CraftSim будет очищать вашу оперативную память при каждом указанном количестве крафтов от неиспользуемых данных, чтобы предотвратить накопление памяти.\nНакопление памяти также может произойти из-за других дополнений и не является специфичным для CraftSim.\nОчистка затронет всё использование оперативной памяти WoW.",
        [CraftSim.CONST.TEXT.OPTIONS_MODULES_TAB] = "Модули",
        [CraftSim.CONST.TEXT.OPTIONS_PROFIT_CALCULATION_TAB] = "Расчет прибыли",
        [CraftSim.CONST.TEXT.OPTIONS_CRAFTING_TAB] = "Изготовление",
        [CraftSim.CONST.TEXT.OPTIONS_TSM_RESET] = "Сбросить по умолчанию",
        [CraftSim.CONST.TEXT.OPTIONS_TSM_INVALID_EXPRESSION] = "Недопустимое выражение",
        [CraftSim.CONST.TEXT.OPTIONS_TSM_VALID_EXPRESSION] = "Допустимое выражение",
        [CraftSim.CONST.TEXT.OPTIONS_MODULES_REAGENT_OPTIMIZATION] = "Модуль оптимизации материалов",
        [CraftSim.CONST.TEXT.OPTIONS_MODULES_AVERAGE_PROFIT] = "Модуль средней прибыли",
        [CraftSim.CONST.TEXT.OPTIONS_MODULES_TOP_GEAR] = "Модуль снаряжения",
        [CraftSim.CONST.TEXT.OPTIONS_MODULES_COST_OVERVIEW] = "Модуль обзора стоимости",
        [CraftSim.CONST.TEXT.OPTIONS_MODULES_SPECIALIZATION_INFO] = "Модуль информации о специализации",
        [CraftSim.CONST.TEXT.OPTIONS_MODULES_CUSTOMER_HISTORY_SIZE] =
        "Максимальное количество сообщений\nистории клиентов на одного клиента",
        [CraftSim.CONST.TEXT.OPTIONS_PROFIT_CALCULATION_OFFSET] = "Сместить точки навыков на 1",
        [CraftSim.CONST.TEXT.OPTIONS_PROFIT_CALCULATION_OFFSET_TOOLTIP] =
        "Предложение по комбинации материалов будет пытаться достичь точки + 1 вместо того, чтобы точно соответствовать требуемому навыку",
        [CraftSim.CONST.TEXT.OPTIONS_PROFIT_CALCULATION_MULTICRAFT_CONSTANT] = "Константа перепроизводства",
        [CraftSim.CONST.TEXT.OPTIONS_PROFIT_CALCULATION_MULTICRAFT_CONSTANT_EXPLANATION] =
        "По умолчанию: 2.5\n\nДанные о крафтах от разных игроков, собиравших данные в бета-версии и ранней версии Dragonflight, указывают, что\nмаксимальное количество дополнительных предметов, которые можно получить в результате перепроизводства, составляет 1+C*y.\nГде y — базовое количество предметов для одного крафта и C — 2.5.\nОднако, если вы хотите, вы можете изменить это значение здесь.",
        [CraftSim.CONST.TEXT.OPTIONS_PROFIT_CALCULATION_RESOURCEFULNESS_CONSTANT] = "Константа находчивости",
        [CraftSim.CONST.TEXT.OPTIONS_PROFIT_CALCULATION_RESOURCEFULNESS_CONSTANT_EXPLANATION] =
        "По умолчанию: 0.3\n\nДанные о крафте от разных игроков, собиравших данные в бета-версии и ранней версии Dragonflight, предполагают, что\nсреднее количество сохраняемых предметов составляет 30% от необходимого количества.\nОднако, если вы хотите, вы можете изменить это значение здесь.",
        [CraftSim.CONST.TEXT.OPTIONS_GENERAL_SHOW_NEWS_CHECKBOX] = "Показать всплывающее окно " .. f.bb("Новостей"),
        [CraftSim.CONST.TEXT.OPTIONS_GENERAL_SHOW_NEWS_CHECKBOX_TOOLTIP] = "Показать всплывающее окно " ..
            f.bb("Новостей") .. " для новой информации об обновлениях " .. f.l("CraftSim") .. " при входе в игру",
        [CraftSim.CONST.TEXT.OPTIONS_GENERAL_HIDE_MINIMAP_BUTTON_CHECKBOX] = "Скрыть кнопку мини-карты",
        [CraftSim.CONST.TEXT.OPTIONS_GENERAL_HIDE_MINIMAP_BUTTON_TOOLTIP] = "Включить скрытие кнопки мини-карты" ..
            f.l("CraftSim"),

        -- Control Panel
        [CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_CRAFT_QUEUE_LABEL] = "Очередь крафта",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_CRAFT_QUEUE_TOOLTIP] =
        "Ставьте рецепты в очередь и создавайте их все в одном месте!",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_TOP_GEAR_LABEL] = "Снаряжение",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_TOP_GEAR_TOOLTIP] =
        "Показывает лучшую доступную комбинацию снаряжения для профессии в зависимости от выбранного режима",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_COST_OVERVIEW_LABEL] = "Данные о ценах",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_COST_OVERVIEW_TOOLTIP] =
        "Показывает цену продажи и обзор прибыли в зависимости от качества товара",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_AVERAGE_PROFIT_LABEL] = "Средняя прибыль",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_AVERAGE_PROFIT_TOOLTIP] =
        "Показывает среднюю прибыль на основе характеристик вашей профессии и прибыль от каждого очка характеристик в золоте.",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_REAGENT_OPTIMIZATION_LABEL] = "Оптимизация материалов",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_REAGENT_OPTIMIZATION_TOOLTIP] =
        "Предлагает самые дешевые материалы для достижения наивысшего порога качества.",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_PRICE_OVERRIDES_LABEL] = "Переопределение",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_PRICE_OVERRIDES_TOOLTIP] =
        "Переопределить цены на любые материалы, дополнительные материалы и результаты крафта для всех рецептов или для одного рецепта конкретно.",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_SPECIALIZATION_INFO_LABEL] = "Инфо о спец.",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_SPECIALIZATION_INFO_TOOLTIP] =
        "Показывает, как специализации вашей профессии влияют на этот рецепт и позволяет симулировать любую конфигурацию!",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_CRAFT_LOG_LABEL] = "Результаты крафта",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_CRAFT_LOG_TOOLTIP] =
        "Показать журнал крафта и статистику ваших крафтов!",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_COST_OPTIMIZATION_LABEL] = "Данные о стоимости",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_COST_OPTIMIZATION_TOOLTIP] =
        "Модуль, показывающий подробную информацию о стоимости крафта",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_STATISTICS_LABEL] = "Статистика",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_STATISTICS_TOOLTIP] =
        "Модуль, который показывает подробную статистику результатов для текущего открытого рецепта",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_RECIPE_SCAN_LABEL] = "Скан. рецептов",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_RECIPE_SCAN_TOOLTIP] =
        "Модуль, которой сканирует ваш список рецептов на базе заданных параметров",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_CUSTOMER_HISTORY_LABEL] = "История клиентов",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_CUSTOMER_HISTORY_TOOLTIP] =
        "Модуль, который предоставляет историю взаимодействия с клиентами, созданных предметов и комиссий",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_CRAFT_BUFFS_LABEL] = "Усиления",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_CRAFT_BUFFS_TOOLTIP] =
        "Модуль, который показывает ваши активные и недостающие ремесленные усиления",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_EXPLANATIONS_LABEL] = "Объяснения",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_EXPLANATIONS_TOOLTIP] =
            "Модуль, который показывает вам различные объяснения того, как" .. f.l(" CraftSim") .. " проводит вычисления",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_RESET_FRAMES] = "Сбросить позиции",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_OPTIONS] = "Параметры",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_NEWS] = "Новости",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_EASYCRAFT_EXPORT] = "Экспорт " .. f.l("Easycraft"),
        [CraftSim.CONST.TEXT.CONTROL_PANEL_EASYCRAFT_EXPORTING] = "Экспорт",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_EASYCRAFT_EXPORT_NO_RECIPE_FOUND] =
        "Нет рецепта для экспорта для дополнения The War Within",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_FORGEFINDER_EXPORT] = "Экспорт " .. f.l("ForgeFinder"),
        [CraftSim.CONST.TEXT.CONTROL_PANEL_FORGEFINDER_EXPORTING] = "Экспорт",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_EXPORT_EXPLANATION] = f.l("wowforgefinder.com") ..
            " & " .. f.l("easycraft.io") ..
            "\n- веб-сайт для поиска и предложения " .. f.bb("заказов в WoW"),
        [CraftSim.CONST.TEXT.CONTROL_PANEL_DEBUG] = "Отладка",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_TITLE] = "Панель управления",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_SUPPORTERS_BUTTON] = f.patreon("Поддержавшие"),

        -- Supporters
        [CraftSim.CONST.TEXT.SUPPORTERS_DESCRIPTION] = f.l("Спасибо всем этим замечательным людям!"),
        [CraftSim.CONST.TEXT.SUPPORTERS_DESCRIPTION_2] = f.l(
            "Хотите ли вы поддержать CraftSim и также быть упомянутыми здесь со своим сообщением?\nРассмотрите возможность пожертвования <3"),
        [CraftSim.CONST.TEXT.SUPPORTERS_DATE] = "Дата",
        [CraftSim.CONST.TEXT.SUPPORTERS_SUPPORTER] = "Имя",
        [CraftSim.CONST.TEXT.SUPPORTERS_MESSAGE] = "Сообщение",

        -- Customer History
        [CraftSim.CONST.TEXT.CUSTOMER_HISTORY_TITLE] = "История клиентов CraftSim",
        [CraftSim.CONST.TEXT.CUSTOMER_HISTORY_DROPDOWN_LABEL] = "Выберите клиента",
        [CraftSim.CONST.TEXT.CUSTOMER_HISTORY_TOTAL_TIP] = "Сумма чаевых: ",
        [CraftSim.CONST.TEXT.CUSTOMER_HISTORY_FROM] = "От",
        [CraftSim.CONST.TEXT.CUSTOMER_HISTORY_TO] = "До",
        [CraftSim.CONST.TEXT.CUSTOMER_HISTORY_FOR] = "Для",
        [CraftSim.CONST.TEXT.CUSTOMER_HISTORY_CRAFT_FORMAT] = "Создано %s для %s",
        [CraftSim.CONST.TEXT.CUSTOMER_HISTORY_DELETE_BUTTON] = "Удалить клиента",
        [CraftSim.CONST.TEXT.CUSTOMER_HISTORY_WHISPER_BUTTON_LABEL] = "Шепот..",
        [CraftSim.CONST.TEXT.CUSTOMER_HISTORY_PURGE_NO_TIP_LABEL] = "Удалить клиентов с 0 чаевыми",
        [CraftSim.CONST.TEXT.CUSTOMER_HISTORY_PURGE_ZERO_TIPS_CONFIRMATION_POPUP] =
        "Вы уверены, что хотите удалить все данные\nот клиентов с общей суммой чаевых 0?",
        [CraftSim.CONST.TEXT.CUSTOMER_HISTORY_DELETE_CUSTOMER_CONFIRMATION_POPUP] =
        "Вы уверены, что хотите удалить\nвсе данные для %s?",
        [CraftSim.CONST.TEXT.CUSTOMER_HISTORY_PURGE_DAYS_INPUT_LABEL] = "Интервал автоматического удаления (Дней)",
        [CraftSim.CONST.TEXT.CUSTOMER_HISTORY_PURGE_DAYS_INPUT_TOOLTIP] =
        "CraftSim автоматически удалит всех клиентов с 0 чаевыми при входе в систему через X дней после последнего удаления.\nЕсли установлено значение 0, CraftSim никогда не будет удалять автоматически.",
        [CraftSim.CONST.TEXT.CUSTOMER_HISTORY_CUSTOMER_HEADER] = "Клиент",
        [CraftSim.CONST.TEXT.CUSTOMER_HISTORY_TOTAL_TIP_HEADER] = "Сумма чаевых",
        [CraftSim.CONST.TEXT.CUSTOMER_HISTORY_CRAFT_HISTORY_DATE_HEADER] = "Дата",
        [CraftSim.CONST.TEXT.CUSTOMER_HISTORY_CRAFT_HISTORY_RESULT_HEADER] = "Результат",
        [CraftSim.CONST.TEXT.CUSTOMER_HISTORY_CRAFT_HISTORY_TIP_HEADER] = "Чаевые",
        [CraftSim.CONST.TEXT.CUSTOMER_HISTORY_CRAFT_HISTORY_CUSTOMER_REAGENTS_HEADER] = "Реагенты клиента",
        [CraftSim.CONST.TEXT.CUSTOMER_HISTORY_CRAFT_HISTORY_CUSTOMER_NOTE_HEADER] = "Примечание",


        -- Craft Queue
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_TITLE] = "Очередь крафта CraftSim",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_CRAFT_AMOUNT_LEFT_HEADER] = "В очереди",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_CRAFT_PROFESSION_GEAR_HEADER] = "Снаряжение",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_CRAFTING_COSTS_HEADER] = "Стоимость изготовления",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_CRAFT_BUTTON_ROW_LABEL] = "Создать",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_CRAFT_BUTTON_ROW_LABEL_WRONG_GEAR] = "Неправильные инструменты",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_CRAFT_BUTTON_ROW_LABEL_NO_REAGENTS] = "Нет материалов",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_ADD_OPEN_RECIPE_BUTTON_LABEL] = "Добавить открытый рецепт",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_CLEAR_ALL_BUTTON_LABEL] = "Очистить все",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_RESTOCK_FAVORITES_BUTTON_LABEL] =
        "Пополнить запасы на основе сканирования рецептов",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_CRAFT_BUTTON_ROW_LABEL_WRONG_PROFESSION] = "Неправильная профессия",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_CRAFT_BUTTON_ROW_LABEL_ON_COOLDOWN] = "На перезарядке",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_CRAFT_BUTTON_ROW_LABEL_WRONG_CRAFTER] = "Неправильный крафтер",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_RECIPE_REQUIREMENTS_HEADER] = "Состояние",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_CRAFT_NEXT_BUTTON_LABEL] = "Создать дальше",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_CRAFT_AVAILABLE_AMOUNT] = "Можно создать",
        [CraftSim.CONST.TEXT.CRAFTQUEUE_AUCTIONATOR_SHOPPING_LIST_BUTTON_LABEL] = "Создать список покупок Auctionator",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_QUEUE_TAB_LABEL] = "Очередь крафта",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_FLASH_TASKBAR_OPTION_LABEL] =
            "Помигать иконкой панели задач по завершении крафта в " ..
            f.bb("Очереди крафта"),
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_FLASH_TASKBAR_OPTION_TOOLTIP] =
            "Когда ваш клиент WoW свернут и крафт рецепта в " .. f.bb("Очереди крафта") ..
            " заканчивается," .. f.l(" CraftSim") .. " заставит иконку WoW в панели задач замигать",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_RESTOCK_OPTIONS_TAB_LABEL] = "Варианты пополнения запасов",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_RESTOCK_OPTIONS_GENERAL_PROFIT_THRESHOLD_LABEL] = "Порог прибыли:",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_RESTOCK_OPTIONS_SALE_RATE_INPUT_LABEL] = "Порог цены продажи:",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_RESTOCK_OPTIONS_TSM_SALE_RATE_TOOLTIP] = string.format(
            [[
Доступно только, если загружен %s!

Будет проверено, имеет ли %s предмет выбранного качества процент продаж
выше или равный настроенному пороговому значению цены продажи.
]], f.bb("TSM"), f.bb("любой")),
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_RESTOCK_OPTIONS_TSM_SALE_RATE_TOOLTIP_GENERAL] = string.format(
            [[
Доступно только, если загружен %s!

Будет проверено, имеет ли %s качество предмета процент продаж
выше или равный настроенному пороговому значению цены продажи.
]], f.bb("TSM"), f.bb("любое")),
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_RESTOCK_OPTIONS_AMOUNT_LABEL] = "Сумма пополнения запасов:",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_RESTOCK_OPTIONS_RESTOCK_TOOLTIP] = "Это " ..
            f.bb("количество крафтов") ..
            " которое будет поставлено в очередь для этого рецепта.\n\nКоличество предметов проверенных качеств в вашем инвентаре и банке будет вычтено из суммы пополнения при пополнении",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_RESTOCK_OPTIONS_ENABLE_RECIPE_LABEL] = "Включить:",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_RESTOCK_OPTIONS_GENERAL_OPTIONS_LABEL] = "Общие параметры (Все рецепты)",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_RESTOCK_OPTIONS_ENABLE_RECIPE_TOOLTIP] =
        "Если этот параметр отключен, рецепт будет пополнен на основе общих параметров, указанных выше",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_TOTAL_PROFIT_LABEL] = "Общая Ø прибыль:",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_TOTAL_CRAFTING_COSTS_LABEL] = "Общая стоимость крафта:",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_EDIT_RECIPE_TITLE] = "Изменить рецепт",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_EDIT_RECIPE_NAME_LABEL] = "Название рецепта",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_EDIT_RECIPE_REAGENTS_SELECT_LABEL] = "Выбрать",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_EDIT_RECIPE_OPTIONAL_REAGENTS_LABEL] = "Необязательные реагенты",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_EDIT_RECIPE_FINISHING_REAGENTS_LABEL] = "Завершающие реагенты",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_EDIT_RECIPE_PROFESSION_GEAR_LABEL] = "Профессиональное снаряжение",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_EDIT_RECIPE_OPTIMIZE_PROFIT_BUTTON] = "Оптимизировать прибыль",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_EDIT_RECIPE_CRAFTING_COSTS_LABEL] = "Стоимость изготовления: ",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_EDIT_RECIPE_AVERAGE_PROFIT_LABEL] = "Средняя прибыль: ",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_EDIT_RECIPE_RESULTS_LABEL] = "Результаты",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_EDIT_RECIPE_CONCENTRATION_CHECKBOX] = " Концентрация",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_AUCTIONATOR_SHOPPING_LIST_PER_CHARACTER_CHECKBOX] = "Для персонажа",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_AUCTIONATOR_SHOPPING_LIST_PER_CHARACTER_CHECKBOX_TOOLTIP] = "Создать " ..
            f.bb("Список покупок Auctionator") ..
            " для каждого персонажа-крафтера\nвместо одного списка покупок для всех",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_AUCTIONATOR_SHOPPING_LIST_TARGET_MODE_CHECKBOX] = "Только целевой режим",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_AUCTIONATOR_SHOPPING_LIST_TARGET_MODE_CHECKBOX_TOOLTIP] = "Создать " ..
            f.bb("Список покупок Auctionator") .. " только для рецептов целевого режима",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_UNSAVED_CHANGES_TOOLTIP] = f.white(
            "Величина очереди не сохранена.\nНажмите Enter для сохранения"),
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_STATUSBAR_LEARNED] = f.white("Рецепт изучен"),
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_STATUSBAR_COOLDOWN] = f.white("Не восстанавливается"),
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_STATUSBAR_REAGENTS] = f.white("Материалы доступны"),
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_STATUSBAR_GEAR] = f.white("Профессиональное снаряжение надето"),
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_STATUSBAR_CRAFTER] = f.white("Правильный персонаж-крафтер"),
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_STATUSBAR_PROFESSION] = f.white("Профессия открыта"),

        -- craft buffs

        [CraftSim.CONST.TEXT.CRAFT_BUFFS_TITLE] = "Усиления CraftSim",
        [CraftSim.CONST.TEXT.CRAFT_BUFFS_SIMULATE_BUTTON] = "Симулировать усиления",
        [CraftSim.CONST.TEXT.CRAFT_BUFF_CHEFS_HAT_TOOLTIP] = f.bb("Игрушка из Wrath of the Lich King.") ..
            "\nТребуется кулинария Нордскола\nУстанавливает скорость изготовления на " .. f.g("0.5 секунды"),

        -- cooldowns module

        [CraftSim.CONST.TEXT.COOLDOWNS_TITLE] = "Кулдауны CraftSim",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_COOLDOWNS_LABEL] = "Кулдауны",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_COOLDOWNS_TOOLTIP] = "Обзор " ..
            f.bb("Кулдаунов профессий") .. " вашей учетной записи",
        [CraftSim.CONST.TEXT.COOLDOWNS_CRAFTER_HEADER] = "Ремесленник",
        [CraftSim.CONST.TEXT.COOLDOWNS_RECIPE_HEADER] = "Рецепт",
        [CraftSim.CONST.TEXT.COOLDOWNS_CHARGES_HEADER] = "Заряды",
        [CraftSim.CONST.TEXT.COOLDOWNS_NEXT_HEADER] = "Следующий заряд",
        [CraftSim.CONST.TEXT.COOLDOWNS_ALL_HEADER] = "Полный заряд",

        [CraftSim.CONST.TEXT.CONCENTRATION_TRACKER_TITLE] = "Концентрация CraftSim",

        -- static popups
        [CraftSim.CONST.TEXT.STATIC_POPUPS_YES] = "Да",
        [CraftSim.CONST.TEXT.STATIC_POPUPS_NO] = "Нет",
    }
end
