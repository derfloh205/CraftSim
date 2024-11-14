---@class CraftSim
local CraftSim = select(2, ...)

CraftSim.LOCAL_CN = {}

function CraftSim.LOCAL_CN:GetData()
    local f = CraftSim.GUTIL:GetFormatter()
    local cm = function(i, s) return CraftSim.MEDIA:GetAsTextIcon(i, s) end
    return {
        -- REQUIRED:
        [CraftSim.CONST.TEXT.STAT_MULTICRAFT] = "产能",
        [CraftSim.CONST.TEXT.STAT_RESOURCEFULNESS] = "充裕",
        [CraftSim.CONST.TEXT.STAT_INGENUITY] = "奇思",
        [CraftSim.CONST.TEXT.STAT_CRAFTINGSPEED] = "制作速度",
        [CraftSim.CONST.TEXT.EQUIP_MATCH_STRING] = "装备：",
        [CraftSim.CONST.TEXT.ENCHANTED_MATCH_STRING] = "附魔：",

        -- OPTIONAL (Defaulting to EN if not available):

        -- shared prof cds
        [CraftSim.CONST.TEXT.DF_ALCHEMY_TRANSMUTATIONS] = "巨龙时代 - 转化",

        -- expansions

        [CraftSim.CONST.TEXT.EXPANSION_VANILLA] = "经典",
        [CraftSim.CONST.TEXT.EXPANSION_THE_BURNING_CRUSADE] = "燃烧的远征",
        [CraftSim.CONST.TEXT.EXPANSION_WRATH_OF_THE_LICH_KING] = "巫妖王之怒",
        [CraftSim.CONST.TEXT.EXPANSION_CATACLYSM] = "大地的裂变",
        [CraftSim.CONST.TEXT.EXPANSION_MISTS_OF_PANDARIA] = "熊猫人之谜",
        [CraftSim.CONST.TEXT.EXPANSION_WARLORDS_OF_DRAENOR] = "德拉诺之王",
        [CraftSim.CONST.TEXT.EXPANSION_LEGION] = "军团再临",
        [CraftSim.CONST.TEXT.EXPANSION_BATTLE_FOR_AZEROTH] = "争霸艾泽拉斯",
        [CraftSim.CONST.TEXT.EXPANSION_SHADOWLANDS] = "暗影国度",
        [CraftSim.CONST.TEXT.EXPANSION_DRAGONFLIGHT] = "巨龙时代",
        [CraftSim.CONST.TEXT.EXPANSION_THE_WAR_WITHIN] = "地心之战",

        -- professions

        [CraftSim.CONST.TEXT.PROFESSIONS_BLACKSMITHING] = "锻造",
        [CraftSim.CONST.TEXT.PROFESSIONS_LEATHERWORKING] = "制皮",
        [CraftSim.CONST.TEXT.PROFESSIONS_ALCHEMY] = "炼金术",
        [CraftSim.CONST.TEXT.PROFESSIONS_HERBALISM] = "草药学",
        [CraftSim.CONST.TEXT.PROFESSIONS_COOKING] = "烹饪",
        [CraftSim.CONST.TEXT.PROFESSIONS_MINING] = "采矿",
        [CraftSim.CONST.TEXT.PROFESSIONS_TAILORING] = "裁缝",
        [CraftSim.CONST.TEXT.PROFESSIONS_ENGINEERING] = "工程学",
        [CraftSim.CONST.TEXT.PROFESSIONS_ENCHANTING] = "附魔",
        [CraftSim.CONST.TEXT.PROFESSIONS_FISHING] = "钓鱼",
        [CraftSim.CONST.TEXT.PROFESSIONS_SKINNING] = "剥皮",
        [CraftSim.CONST.TEXT.PROFESSIONS_JEWELCRAFTING] = "珠宝加工",
        [CraftSim.CONST.TEXT.PROFESSIONS_INSCRIPTION] = "铭文",

        -- Other Statnames

        [CraftSim.CONST.TEXT.STAT_SKILL] = "技能",
        [CraftSim.CONST.TEXT.STAT_MULTICRAFT_BONUS] = "产能额外物品",
        [CraftSim.CONST.TEXT.STAT_RESOURCEFULNESS_BONUS] = "充裕额外物品",
        [CraftSim.CONST.TEXT.STAT_CRAFTINGSPEED_BONUS] = "制造速度",
        [CraftSim.CONST.TEXT.STAT_INGENUITY_BONUS] = "奇思节省专注",
        [CraftSim.CONST.TEXT.STAT_INGENUITY_LESS_CONCENTRATION] = "更少的专注使用",
        [CraftSim.CONST.TEXT.STAT_PHIAL_EXPERIMENTATION] = "药瓶突破",
        [CraftSim.CONST.TEXT.STAT_POTION_EXPERIMENTATION] = "药水突破",

        -- Profit Breakdown Tooltips
        [CraftSim.CONST.TEXT.RESOURCEFULNESS_EXPLANATION_TOOLTIP] =
        "充裕会分别触发每一种材料，然后节省约 30% 的数量。\n\n它节省的平均值是每一组合及其机率的平均节省值。\n（所有材料同时触发机率很低，但节省很多。）\n\n平均总节省的材料成本是所有组合的节省材料成本，并根据其机率进行加权。",

        [CraftSim.CONST.TEXT.RECIPE_DIFFICULTY_EXPLANATION_TOOLTIP] =
        "配方难度决定了不同品质的临界点。\n\n对于有五种品质的配方，它们分别在 20%、50%、80% 和 100% 的配方技能难度。\n对于有三个品质的配方，它们分别在 50% 和 100%。",
        [CraftSim.CONST.TEXT.MULTICRAFT_EXPLANATION_TOOLTIP] =
        "产能给你一个使用配方制作比你通常会制作的更多物品的机率。\n\n额外数量通常介于 1 到 2.5y 之间\ny = 1 次制作通常产生的数量。",
        [CraftSim.CONST.TEXT.REAGENTSKILL_EXPLANATION_TOOLTIP] =
        "你的材料品质可以给你最多 40% 的基础配方难度作为奖励技能。\n\n所有1星材料：0% 奖励\n所有2星材料：20% 奖励\n所有3星材料：40% 奖励\n\n技能是借由每种品质的材料数量乘以它们的品质\n以及每个个别巨龙时代制作材料物品独有的特定权重值来计算的\n\n然而，这对于再造却不同。在那里，试剂可以增加品质的最大值\n取决于最初制作物品所使用的材料品质。\n确切的运作方式尚不清楚。\n然而，CraftSim 在内部将达到的技能与所有3星进行比较，并计算\n基于此的最大技能提升。",
        [CraftSim.CONST.TEXT.REAGENTFACTOR_EXPLANATION_TOOLTIP] =
        "材料对配方所能贡献的最大值在大部分时间是基础配方难度的 40%。\n\n然而，在再造的情况下，这个数值会根据之前的制作而有所不同\n以及之前使用过的材料品质。",

        -- Simulation Mode
        [CraftSim.CONST.TEXT.SIMULATION_MODE_NONE] = "无",
        [CraftSim.CONST.TEXT.SIMULATION_MODE_LABEL] = "模拟模式",
        [CraftSim.CONST.TEXT.SIMULATION_MODE_TITLE] = "CraftSim 模拟模式",
        [CraftSim.CONST.TEXT.SIMULATION_MODE_TOOLTIP] =
        "CraftSim 的模拟模式可以不受限制地尝试配方",
        [CraftSim.CONST.TEXT.SIMULATION_MODE_OPTIONAL] = "可选 #",
        [CraftSim.CONST.TEXT.SIMULATION_MODE_FINISHING] = "正在完成 #",
        [CraftSim.CONST.TEXT.SIMULATION_MODE_QUALITY_BUTTON_TOOLTIP] = "所有材料使用最高品质",
        [CraftSim.CONST.TEXT.SIMULATION_MODE_CLEAR_BUTTON] = "清除",
        [CraftSim.CONST.TEXT.SIMULATION_MODE_CONCENTRATION] = " 专注",
        [CraftSim.CONST.TEXT.SIMULATION_MODE_CONCENTRATION_COST] = "专注成本：",

        -- Details Frame
        [CraftSim.CONST.TEXT.RECIPE_DIFFICULTY_LABEL] = "配方难度：",
        [CraftSim.CONST.TEXT.MULTICRAFT_LABEL] = "产能：",
        [CraftSim.CONST.TEXT.RESOURCEFULNESS_LABEL] = "充裕：",
        [CraftSim.CONST.TEXT.RESOURCEFULNESS_BONUS_LABEL] = "充裕节省加成：",
        [CraftSim.CONST.TEXT.CONCENTRATION_LABEL] = "专注：",
        [CraftSim.CONST.TEXT.REAGENT_QUALITY_BONUS_LABEL] = "材料品质加成：",
        [CraftSim.CONST.TEXT.REAGENT_QUALITY_MAXIMUM_LABEL] = "材料品质最大百分比：",
        [CraftSim.CONST.TEXT.EXPECTED_QUALITY_LABEL] = "预期品质：",
        [CraftSim.CONST.TEXT.NEXT_QUALITY_LABEL] = "下一级品质：",
        [CraftSim.CONST.TEXT.MISSING_SKILL_LABEL] = "缺失技能：",
        [CraftSim.CONST.TEXT.SKILL_LABEL] = "技能：",
        [CraftSim.CONST.TEXT.MULTICRAFT_BONUS_LABEL] = "产能物品加成：",

        -- Statistics
        [CraftSim.CONST.TEXT.STATISTICS_CDF_EXPLANATION] =
        "这里使用 《abramowitz and stegun 的近似值》（1985）计算CDF（累积分布函数）\n\n你会注意到 1 件中它的比例总是大约 50%。\n这是因为 0 在大多数时间都接近平均利润。\n而且 CDF 的均值总有 50% 的机率。\n\n然而，不同配方之间的变化率可能有很大的差异。\n如果有可能获得正利润而不是负利润，它将会稳定增加。\n对于其他方向的变化当然也是一样。",
        [CraftSim.CONST.TEXT.EXPLANATIONS_PROFIT_CALCULATION_EXPLANATION] =
            f.r("警告：") .. "前方是超硬核数学！（译者注：看不懂 QAQ）\n\n" ..
            "当你制作物品时，你有不同的机率可以使不同的结果基于你的制作数据。\n" ..
            "而在统计学，这被称作 " .. f.l("机率分配。\n") ..
            "但是，你会注意到你的进程不同可能性并不会加起来到 1\n" ..
            "（这对于这样的分配是需要的，因为这表示你拥有 100% 机率去让任何事情发生）\n\n" ..
            "这是因为进程像是 " .. f.bb("灵感") .. "和" ..
            f.bb("产能") .. " 可以 " .. f.g("同时发生。\n") ..
            "所以我们首先需要把我们的进程可能性转换成有着 100% 总机率的 " ..
            f.l("机率分配 ") ..
            "（这意谓着所有状况都被覆盖到了）\n" ..
            "我们需要计算制作的" .. f.l("每一个") .. "可能结果以达成这件事\n\n" ..
            "例如：\n" ..
            f.p .. "假如" .. f.bb("没有") .. "任何进程发生呢？" ..
            f.p .. "假如" .. f.bb("所有") .. "进程都发生呢？" ..
            f.p .. "假如只有" .. f.bb("灵感") .. " 和 " .. f.bb("产能") .. "发生呢？" ..
            f.p .. "等等诸如此类的状况\n\n" ..
            "对于一个考量所有三个进程的配方，这将会有 2 的 3 次方个可能结果，也就是整整 8 个。\n" ..
            "要获得只有 " ..
            f.bb("灵感") .. " 发生的可能性，我们必须考量所有其他进程！\n" ..
            "只有 " .. f.l("仅有") .. f.bb("灵感") .. "发生的可能性实际上是" .. f.bb("灵感") .. "发生的可能性\n" ..
            "但是 " .. f.l("没有") .. "发生" .. f.bb("产能") .. "或" .. f.bb("充裕。\n") ..
            "而数学告诉我们，某事没有发生的机率是它发生的机率的 1 减掉该机率。\n" ..
            "所以只有" ..
            f.bb("灵感") .. "发生的可能性实际上是" .. f.g("灵感可能性 * (1-产能机率) * (1-充裕机率)\n\n") ..
            "在用这种方式计算每个可能性后，各别可能性确实会加起来到 1！\n" ..
            "这意味着我们现在可以用统计公式了。对我们来说最有趣的是 " .. f.bb("期望值") .. "\n" ..
            "正如其名，期望值是指我们平均可以获得的价值，或者在我们的例子中，也就是 " ..
            f.bb("制作的期望利润！\n") ..
            "\n" .. cm(CraftSim.MEDIA.IMAGES.EXPECTED_VALUE) .. "\n\n" ..
            "这告诉我们机率分配 " .. f.l("X") .. " 的期望值 " .. f.l("E") .. " 是所有数值与其可能性的乘积的总和。\n" ..
            "所以如果我们有一个 " ..
            f.bb("情况 A 机率 30%") ..
            " 利润 " .. CraftSim.UTIL:FormatMoney(-100 * 10000, true) ..
            " 和一个" ..
            f.bb("情况 B 机率 70%") .. " 利润 " .. CraftSim.UTIL:FormatMoney(300 * 10000, true) .. " 那该情况的期望利润就是\n" ..
            f.bb("\nE(X) = -100*0.3 + 300*0.7 ") ..
            " 是 " .. CraftSim.UTIL:FormatMoney((-100 * 0.3 + 300 * 0.7) * 10000, true) .. "\n" ..
            "你可以在" .. f.bb("统计数据") .. "窗口中查看当前配方的所有情况！"
        ,

        -- Popups
        [CraftSim.CONST.TEXT.POPUP_NO_PRICE_SOURCE_SYSTEM] = "没有可用的价格来源！",
        [CraftSim.CONST.TEXT.POPUP_NO_PRICE_SOURCE_TITLE] = "CraftSim 价格来源警告",
        [CraftSim.CONST.TEXT.POPUP_NO_PRICE_SOURCE_WARNING] =
        "没有找到价格来源！\n\n至少需要安装下面其中一个价格来源插件，CraftSim 才能计算利润：\n\n\n",
        [CraftSim.CONST.TEXT.POPUP_NO_PRICE_SOURCE_WARNING_SUPPRESS] = "不要再显示警告",
        [CraftSim.CONST.TEXT.POPUP_NO_PRICE_SOURCE_WARNING_ACCEPT] = "好的",

        -- Reagents Frame
        [CraftSim.CONST.TEXT.REAGENT_OPTIMIZATION_TITLE] = "CraftSim 材料优化",
        [CraftSim.CONST.TEXT.REAGENTS_REACHABLE_QUALITY] = "可达到品质：",
        [CraftSim.CONST.TEXT.REAGENTS_MISSING] = "缺少材料",
        [CraftSim.CONST.TEXT.REAGENTS_AVAILABLE] = "可用材料",
        [CraftSim.CONST.TEXT.REAGENTS_CHEAPER] = "最便宜材料",
        [CraftSim.CONST.TEXT.REAGENTS_BEST_COMBINATION] = "已分配最佳组合",
        [CraftSim.CONST.TEXT.REAGENTS_NO_COMBINATION] = "无法找到提高\n品质的组合",
        [CraftSim.CONST.TEXT.REAGENTS_ASSIGN] = "分配",
        [CraftSim.CONST.TEXT.REAGENTS_MAXIMUM_QUALITY] = "最高品质：",
        [CraftSim.CONST.TEXT.REAGENTS_AVERAGE_PROFIT_LABEL] = "平均 Ø 利润：",
        [CraftSim.CONST.TEXT.REAGENTS_AVERAGE_PROFIT_TOOLTIP] =
            "当使用" .. f.l("这种材料分配") .. "时" .. f.bb("每个制造的平均利润"),
        [CraftSim.CONST.TEXT.REAGENTS_OPTIMIZE_BEST_ASSIGNED] = "已分配最佳材料",
        [CraftSim.CONST.TEXT.REAGENTS_CONCENTRATION_LABEL] = "专注：",
        [CraftSim.CONST.TEXT.REAGENTS_OPTIMIZE_INFO] = "在数字上按Shift+鼠标左键将物品链接放入聊天中",
        [CraftSim.CONST.TEXT.ADVANCED_OPTIMIZATION_BUTTON] = "优化",
        [CraftSim.CONST.TEXT.REAGENTS_OPTIMIZE_TOOLTIP] =
            f.r("实验性：") ..
            "性能需求繁重，并在编辑时重置。\n为每个集中值的 " ..
            f.gold("最高金币价值") .. " 优化",

        -- Specialization Info Frame
        [CraftSim.CONST.TEXT.SPEC_INFO_TITLE] = "CraftSim 专精信息",
        [CraftSim.CONST.TEXT.SPEC_INFO_SIMULATE_KNOWLEDGE_DISTRIBUTION] = "模拟专业知识点分配",
        [CraftSim.CONST.TEXT.SPEC_INFO_NODE_TOOLTIP] = "该节点为您提供该配方的下列属性：",
        [CraftSim.CONST.TEXT.SPEC_INFO_WORK_IN_PROGRESS] = "专精信息\n仍在开发中",

        -- Crafting Results Frame
        [CraftSim.CONST.TEXT.CRAFT_LOG_TITLE] = "CraftSim 制造结果",
        [CraftSim.CONST.TEXT.CRAFT_LOG_LOG] = "制造记录",
        [CraftSim.CONST.TEXT.CRAFT_LOG_LOG_1] = "利润：",
        [CraftSim.CONST.TEXT.CRAFT_LOG_LOG_2] = "获得灵感！",
        [CraftSim.CONST.TEXT.CRAFT_LOG_LOG_3] = "产能：",
        [CraftSim.CONST.TEXT.CRAFT_LOG_LOG_4] = "节省资源！：",
        [CraftSim.CONST.TEXT.CRAFT_LOG_LOG_5] = "机率：",
        [CraftSim.CONST.TEXT.CRAFT_LOG_CRAFTED_ITEMS] = "制造的物品",
        [CraftSim.CONST.TEXT.CRAFT_LOG_SESSION_PROFIT] = "此次利润",
        [CraftSim.CONST.TEXT.CRAFT_LOG_RESET_DATA] = "重置数据",
        [CraftSim.CONST.TEXT.CRAFT_LOG_EXPORT_JSON] = "导出 JSON",
        [CraftSim.CONST.TEXT.CRAFT_LOG_RECIPE_STATISTICS] = "配方统计数据",
        [CraftSim.CONST.TEXT.CRAFT_LOG_NOTHING] = "尚未制造任何东西！",
        [CraftSim.CONST.TEXT.CRAFT_LOG_CALCULATION_COMPARISON_NUM_CRAFTS_PREFIX] = "制造：",
        [CraftSim.CONST.TEXT.CRAFT_LOG_STATISTICS_2] = "预期 Ø 利润：",
        [CraftSim.CONST.TEXT.CRAFT_LOG_STATISTICS_3] = "实际 Ø 利润：",
        [CraftSim.CONST.TEXT.CRAFT_LOG_STATISTICS_4] = "实际利润：",
        [CraftSim.CONST.TEXT.CRAFT_LOG_STATISTICS_5] = "过程 - 实际/期望：",
        [CraftSim.CONST.TEXT.CRAFT_LOG_STATISTICS_6] = "灵感：",
        [CraftSim.CONST.TEXT.CRAFT_LOG_STATISTICS_7] = "产能：",
        [CraftSim.CONST.TEXT.CRAFT_LOG_STATISTICS_8] = "- Ø 额外物品：",
        [CraftSim.CONST.TEXT.CRAFT_LOG_STATISTICS_9] = "充裕过程：",
        [CraftSim.CONST.TEXT.CRAFT_LOG_CALCULATION_COMPARISON_NUM_CRAFTS_PREFIX0] = "- Ø 节省成本：",
        [CraftSim.CONST.TEXT.CRAFT_LOG_CALCULATION_COMPARISON_NUM_CRAFTS_PREFIX1] = "利润：",
        [CraftSim.CONST.TEXT.CRAFT_LOG_SAVED_REAGENTS] = "节省材料",
        [CraftSim.CONST.TEXT.CRAFT_LOG_RESULT_ANALYSIS_TAB_DISTRIBUTION_LABEL] = "成品分布",
        [CraftSim.CONST.TEXT.CRAFT_LOG_RESULT_ANALYSIS_TAB_DISTRIBUTION_HELP] = "制造物品成品的相对分布。\n（忽略产能数量）",
        [CraftSim.CONST.TEXT.CRAFT_LOG_RESULT_ANALYSIS_TAB_MULTICRAFT] = "产能",
        [CraftSim.CONST.TEXT.CRAFT_LOG_RESULT_ANALYSIS_TAB_RESOURCEFULNESS] = "充裕",
        [CraftSim.CONST.TEXT.CRAFT_LOG_RESULT_ANALYSIS_TAB_YIELD_DDISTRIBUTION] = "产量分布",

        -- Stats Weight Frame
        [CraftSim.CONST.TEXT.STAT_WEIGHTS_TITLE] = "CraftSim 平均利润",
        [CraftSim.CONST.TEXT.EXPLANATIONS_TITLE] = "CraftSim 平均利润说明",
        [CraftSim.CONST.TEXT.STAT_WEIGHTS_SHOW_EXPLANATION_BUTTON] = "显示说明",
        [CraftSim.CONST.TEXT.STAT_WEIGHTS_HIDE_EXPLANATION_BUTTON] = "隐藏说明",
        [CraftSim.CONST.TEXT.STAT_WEIGHTS_SHOW_STATISTICS_BUTTON] = "显示统计数据",
        [CraftSim.CONST.TEXT.STAT_WEIGHTS_HIDE_STATISTICS_BUTTON] = "隐藏统计数据",
        [CraftSim.CONST.TEXT.STAT_WEIGHTS_PROFIT_CRAFT] = "Ø 利润/制造：",
        [CraftSim.CONST.TEXT.EXPLANATIONS_BASIC_PROFIT_TAB] = "基本利润计算",

        -- Cost Details Frame
        [CraftSim.CONST.TEXT.COST_OPTIMIZATION_TITLE] = "CraftSim 成本明细",
        [CraftSim.CONST.TEXT.COST_OPTIMIZATION_EXPLANATION] =
            "所有材料可能价格概述如下。\n" ..
            f.bb("'使用来源'") ..
            " 字段指示哪一个价格已被使用。\n\n" ..
            f.g("拍卖") ..
            " .. 拍卖行价格\n" ..
            f.l("重订") ..
            " .. 重订价格\n" ..
            f.bb("任何名称") ..
            " .. 工匠的制作数据预估成本\n\n" ..
            f.l("重订") ..
            " 如已设置则会优先使用它。 " .. f.bb("制造成本") .. " 仅在低于 " .. f.g("拍卖") .. " 时才会使用。",
        [CraftSim.CONST.TEXT.COST_OPTIMIZATION_CRAFTING_COSTS] = "制造成本：",
        [CraftSim.CONST.TEXT.COST_OPTIMIZATION_ITEM_HEADER] = "物品",
        [CraftSim.CONST.TEXT.COST_OPTIMIZATION_AH_PRICE_HEADER] = "拍卖价格",
        [CraftSim.CONST.TEXT.COST_OPTIMIZATION_OVERRIDE_HEADER] = "重订价格",
        [CraftSim.CONST.TEXT.COST_OPTIMIZATION_CRAFTING_HEADER] = "制造数据",
        [CraftSim.CONST.TEXT.COST_OPTIMIZATION_USED_SOURCE] = "使用来源",
        [CraftSim.CONST.TEXT.COST_OPTIMIZATION_REAGENT_COSTS_TAB] = "材料成本",
        [CraftSim.CONST.TEXT.COST_OPTIMIZATION_SUB_RECIPE_OPTIONS_TAB] = "子配方选项",
        [CraftSim.CONST.TEXT.COST_OPTIMIZATION_SUB_RECIPE_OPTIMIZATION] = "子配方优化" .. f.bb("(实验性)"),
        [CraftSim.CONST.TEXT.COST_OPTIMIZATION_SUB_RECIPE_OPTIMIZATION_TOOLTIP] =
            "启用时，如果你的角色或小号能够制作该物品。\n" ..
            f.l("CraftSim") .. "会考虑" .. f.g("优化过的制作成本") .. "\n\n" ..
            f.r("由于大量额外的计算，可能会稍微降低性能"),
        [CraftSim.CONST.TEXT.COST_OPTIMIZATION_SUB_RECIPE_MAX_DEPTH_LABEL] = "子配方计算深度",
        [CraftSim.CONST.TEXT.COST_OPTIMIZATION_SUB_RECIPE_INCLUDE_CONCENTRATION] = "启用专注",
        [CraftSim.CONST.TEXT.COST_OPTIMIZATION_SUB_RECIPE_INCLUDE_CONCENTRATION_TOOLTIP] =
            "启用后，当需要专注时 " .. f.l("CraftSim") .. " 也会将材料品质包括在内。",
        [CraftSim.CONST.TEXT.COST_OPTIMIZATION_SUB_RECIPE_INCLUDE_COOLDOWN_RECIPES] = "包括冷却中的配方",
        [CraftSim.CONST.TEXT.COST_OPTIMIZATION_SUB_RECIPE_INCLUDE_COOLDOWN_RECIPES_TOOLTIP] =
            "启用后，计算自制材料时 " .. f.l("CraftSim") .. " 将忽略配方的冷却时间要求。",
        [CraftSim.CONST.TEXT.COST_OPTIMIZATION_SUB_RECIPE_SELECT_RECIPE_CRAFTER] = "选择配方工匠",
        [CraftSim.CONST.TEXT.COST_OPTIMIZATION_REAGENT_LIST_AH_COLUMN_AUCTION_BUYOUT] = "拍卖价格：",
        [CraftSim.CONST.TEXT.COST_OPTIMIZATION_REAGENT_LIST_OVERRIDE] = "\n\n重定价格",
        [CraftSim.CONST.TEXT.COST_OPTIMIZATION_REAGENT_LIST_EXPECTED_COSTS_TOOLTIP] = "\n\n正在制造 ",
        [CraftSim.CONST.TEXT.COST_OPTIMIZATION_REAGENT_LIST_EXPECTED_COSTS_PRE_ITEM] = "\n- 每个物品的预期成本：",
        [CraftSim.CONST.TEXT.COST_OPTIMIZATION_REAGENT_LIST_CONCENTRATION_COST] = f.gold("专注成本："),
        [CraftSim.CONST.TEXT.COST_OPTIMIZATION_REAGENT_LIST_CONCENTRATION] = "专注：",

        -- Statistics Frame
        [CraftSim.CONST.TEXT.STATISTICS_TITLE] = "CraftSim 统计数据",
        [CraftSim.CONST.TEXT.STATISTICS_EXPECTED_PROFIT] = "预期利润 (μ)",
        [CraftSim.CONST.TEXT.STATISTICS_CHANCE_OF] = "制造后",
        [CraftSim.CONST.TEXT.STATISTICS_PROFIT] = "利润",
        [CraftSim.CONST.TEXT.STATISTICS_AFTER] = " 的机率",
        [CraftSim.CONST.TEXT.STATISTICS_CRAFTS] = "制造：",
        [CraftSim.CONST.TEXT.STATISTICS_QUALITY_HEADER] = "品质",
        [CraftSim.CONST.TEXT.STATISTICS_CHANCE_HEADER] = "机率",
        [CraftSim.CONST.TEXT.STATISTICS_EXPECTED_CRAFTS_HEADER] = "Ø 预期制造",
        [CraftSim.CONST.TEXT.STATISTICS_MULTICRAFT_HEADER] = "产能",
        [CraftSim.CONST.TEXT.STATISTICS_RESOURCEFULNESS_HEADER] = "充裕",
        [CraftSim.CONST.TEXT.STATISTICS_HSV_NEXT] = "HSV提升",
        [CraftSim.CONST.TEXT.STATISTICS_HSV_SKIP] = "HSV跳过",
        [CraftSim.CONST.TEXT.STATISTICS_EXPECTED_PROFIT_HEADER] = "预期利润",
        [CraftSim.CONST.TEXT.PROBABILITY_TABLE_TITLE] = "配方概率表",
        [CraftSim.CONST.TEXT.STATISTICS_EXPECTED_COSTS_HEADER] = "每件物品的 Ø 预期成本",
        [CraftSim.CONST.TEXT.STATISTICS_EXPECTED_COSTS_WITH_RETURN_HEADER] = "Ø 销售回报",
        [CraftSim.CONST.TEXT.STATISTICS_PROBABILITY_TABLE_TAB] = "概率表",
        [CraftSim.CONST.TEXT.STATISTICS_CONCENTRATION_TAB] = "专注",
        [CraftSim.CONST.TEXT.STATISTICS_CONCENTRATION_CURVE_GRAPH] = "专注成本曲线",
        [CraftSim.CONST.TEXT.STATISTICS_CONCENTRATION_CURVE_GRAPH_HELP] =
            "基于玩家技能的特定的配方的专注成本\n" ..
            f.bb("X轴：") .. "玩家技能\n" ..
            f.bb("Y轴：") .. "专注成本",

        -- Price Details Frame
        [CraftSim.CONST.TEXT.COST_OVERVIEW_TITLE] = "CraftSim 价格明细",
        [CraftSim.CONST.TEXT.PRICE_DETAILS_INV_AH] = "库存/拍卖",
        [CraftSim.CONST.TEXT.PRICE_DETAILS_ITEM] = "物品",
        [CraftSim.CONST.TEXT.PRICE_DETAILS_PRICE_ITEM] = "价格/物品",
        [CraftSim.CONST.TEXT.PRICE_DETAILS_PROFIT_ITEM] = "利润/物品",

        -- Price Override Frame
        [CraftSim.CONST.TEXT.PRICE_OVERRIDE_TITLE] = "CraftSim 重订价格",
        [CraftSim.CONST.TEXT.PRICE_OVERRIDE_REQUIRED_REAGENTS] = "必要材料",
        [CraftSim.CONST.TEXT.PRICE_OVERRIDE_OPTIONAL_REAGENTS] = "可选材料",
        [CraftSim.CONST.TEXT.PRICE_OVERRIDE_FINISHING_REAGENTS] = "完成材料",
        [CraftSim.CONST.TEXT.PRICE_OVERRIDE_RESULT_ITEMS] = "产出物品",
        [CraftSim.CONST.TEXT.PRICE_OVERRIDE_ACTIVE_OVERRIDES] = "启用的重订价格",
        [CraftSim.CONST.TEXT.PRICE_OVERRIDE_ACTIVE_OVERRIDES_TOOLTIP] =
        "'(产出物品)' -> 当物品是配方生产出来的才考虑重订价格",
        [CraftSim.CONST.TEXT.PRICE_OVERRIDE_CLEAR_ALL] = "全部清除",
        [CraftSim.CONST.TEXT.PRICE_OVERRIDE_SAVE] = "保存",
        [CraftSim.CONST.TEXT.PRICE_OVERRIDE_SAVED] = "已保存",
        [CraftSim.CONST.TEXT.PRICE_OVERRIDE_REMOVE] = "移除",

        -- Recipe Scan Frame
        [CraftSim.CONST.TEXT.RECIPE_SCAN_TITLE] = "CraftSim 配方扫描",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_MODE] = "扫描模式",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_SORT_MODE] = "排序模式",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_SCAN_RECIPIES] = "扫描配方",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_SCAN_CANCEL] = "取消",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_SCANNING] = "正在扫描",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_INCLUDE_NOT_LEARNED] = "包含尚未学会",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_INCLUDE_NOT_LEARNED_TOOLTIP] =
        "配方扫描中要包含你还没学会的配方",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_INCLUDE_SOULBOUND] = "包含灵魂绑定",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_INCLUDE_SOULBOUND_TOOLTIP] =
        "配方扫描中要包含灵魂绑定的配方\n\n建议在重订价格模块对该配方的制造物品\n设置价格 (例如模拟目标佣金)",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_INCLUDE_GEAR] = "包含装备",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_INCLUDE_GEAR_TOOLTIP] = "在配方扫描中包含所有种类的装备配方",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_OPTIMIZE_TOOLS] = "优化专业工具",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_OPTIMIZE_TOOLS_TOOLTIP] =
        "为每个配方优化你的专业工具以获取利润\n\n",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_OPTIMIZE_TOOLS_WARNING] =
        "如果你的背包中有很多任务具\n扫描期间可能会降低游戏性能",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_CRAFTER_HEADER] = "工匠",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_RECIPE_HEADER] = "配方",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_LEARNED_HEADER] = "已学会",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_RESULT_HEADER] = "成品",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_AVERAGE_PROFIT_HEADER] = "平均利润",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_CONCENTRATION_VALUE_HEADER] = "专注值",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_CONCENTRATION_COST_HEADER] = "专注成本",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_TOP_GEAR_HEADER] = "最佳装备",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_INV_AH_HEADER] = "库存/拍卖",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_SORT_BY_MARGIN] = "按利润百分比排序",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_SORT_BY_MARGIN_TOOLTIP] =
        "根据和制造花费相关的利润排序利润清单。\n(需要重新扫描)",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_USE_INSIGHT_CHECKBOX] = "使用" .. f.bb("洞悉") .. " (如果可以的话)",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_USE_INSIGHT_CHECKBOX_TOOLTIP] = "如果配方允许，使用" ..
            f.bb("卓然洞悉") .. "或\n" .. f.bb("次级卓然洞悉") .. "作为可选的材料。",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_ONLY_FAVORITES_CHECKBOX] = "只有最爱",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_ONLY_FAVORITES_CHECKBOX_TOOLTIP] = "只扫描最爱的配方",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_EQUIPPED] = "已装备",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_MODE_OPTIMIZE] = "优化材料",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_SORT_MODE_PROFIT] = "利润",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_SORT_MODE_RELATIVE_PROFIT] = "相关的利润",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_SORT_MODE_CONCENTRATION_VALUE] = "专注值",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_SORT_MODE_CONCENTRATION_COST] = "专注成本",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_EXPANSION_FILTER_BUTTON] = "资料片",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_ALTPROFESSIONS_FILTER_BUTTON] = "小号专业",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_SCAN_ALL_BUTTON_READY] = "扫描专业",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_SCAN_ALL_BUTTON_SCANNING] = "正在扫描...",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_TAB_LABEL_SCAN] = "配方扫描",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_TAB_LABEL_OPTIONS] = "扫描选项",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_IMPORT_ALL_PROFESSIONS_CHECKBOX_LABEL] = "所有已扫描的专业",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_IMPORT_ALL_PROFESSIONS_CHECKBOX_TOOLTIP] = f.g("是：") ..
            "导入所有已启用和已扫描专业的扫描结果\n\n" ..
            f.r("否：") .. "仅导入当前选定专业的扫描结果",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_CACHED_RECIPES_TOOLTIP] =
            "每当你打开或扫描某个角色的配方时，" ..
            f.l("CraftSim") ..
            " 会记住它。\n\n只有你的小号能记住的配方才会被 " ..
            f.l("CraftSim") .. " 用 " .. f.bb("配方扫描") .. " 扫到\n\n" ..
            "实际扫描的配方数量取决于你的 " .. f.e("配方扫描选项"),
        [CraftSim.CONST.TEXT.RECIPE_SCAN_CONCENTRATION_TOGGLE] = " 专注",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_CONCENTRATION_TOGGLE_TOOLTIP] = "开/关专注",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_OPTIMIZE_SUBRECIPES] = "优化子配方" .. f.bb("(实验性)"),
        [CraftSim.CONST.TEXT.RECIPE_SCAN_OPTIMIZE_SUBRECIPES_TOOLTIP] = "启用后，" ..
            f.l("CraftSim") .. "也会同时优化制造扫描到的配方中缓存的材料配方，\n并使用其" ..
            f.bb("预期成本") .. "来计算最终产品的制作成本。\n\n" ..
            f.r("警告：这可能会降低扫描性能"),
        [CraftSim.CONST.TEXT.RECIPE_SCAN_CACHED_RECIPES] = "已扫描的配方：",

        -- Recipe Top Gear
        [CraftSim.CONST.TEXT.TOP_GEAR_TITLE] = "CraftSim 最佳装备",
        [CraftSim.CONST.TEXT.TOP_GEAR_AUTOMATIC] = "自动",
        [CraftSim.CONST.TEXT.TOP_GEAR_AUTOMATIC_TOOLTIP] =
        "配方更新时自动模拟所选模式的最佳装备。\n\n关闭此选项可以提高性能。",
        [CraftSim.CONST.TEXT.TOP_GEAR_SIMULATE] = "模拟最佳装备",
        [CraftSim.CONST.TEXT.TOP_GEAR_EQUIP] = "装备",
        [CraftSim.CONST.TEXT.TOP_GEAR_SIMULATE_QUALITY] = "品质：",
        [CraftSim.CONST.TEXT.TOP_GEAR_SIMULATE_EQUIPPED] = "已穿上最佳装备",
        [CraftSim.CONST.TEXT.TOP_GEAR_SIMULATE_PROFIT_DIFFERENCE] = "Ø 利润差\n",
        [CraftSim.CONST.TEXT.TOP_GEAR_SIMULATE_NEW_MUTLICRAFT] = "新的产能\n",
        [CraftSim.CONST.TEXT.TOP_GEAR_SIMULATE_NEW_CRAFTING_SPEED] = "新的制造速度\n",
        [CraftSim.CONST.TEXT.TOP_GEAR_SIMULATE_NEW_RESOURCEFULNESS] = "新的充裕\n",
        [CraftSim.CONST.TEXT.TOP_GEAR_SIMULATE_NEW_SKILL] = "新的技能\n",
        [CraftSim.CONST.TEXT.TOP_GEAR_SIMULATE_UNHANDLED] = "未处理的模拟模式",

        [CraftSim.CONST.TEXT.TOP_GEAR_SIM_MODES_PROFIT] = "最佳利润",
        [CraftSim.CONST.TEXT.TOP_GEAR_SIM_MODES_SKILL] = "最佳技能",
        [CraftSim.CONST.TEXT.TOP_GEAR_SIM_MODES_MULTICRAFT] = "最佳产能",
        [CraftSim.CONST.TEXT.TOP_GEAR_SIM_MODES_RESOURCEFULNESS] = "最佳充裕",
        [CraftSim.CONST.TEXT.TOP_GEAR_SIM_MODES_CRAFTING_SPEED] = "最佳制造速度",

        -- Options
        [CraftSim.CONST.TEXT.OPTIONS_TITLE] = "CraftSim 选项",
        [CraftSim.CONST.TEXT.OPTIONS_GENERAL_TAB] = "一般",
        [CraftSim.CONST.TEXT.OPTIONS_GENERAL_PRICE_SOURCE] = "价格来源",
        [CraftSim.CONST.TEXT.OPTIONS_GENERAL_CURRENT_PRICE_SOURCE] = "当前价格来源：",
        [CraftSim.CONST.TEXT.OPTIONS_GENERAL_NO_PRICE_SOURCE] = "没有加载支持的价格来源插件！",
        [CraftSim.CONST.TEXT.OPTIONS_GENERAL_SHOW_PROFIT] = "显示利润百分比",
        [CraftSim.CONST.TEXT.OPTIONS_GENERAL_SHOW_PROFIT_TOOLTIP] =
        "除了金钱，还要显示利润占造制成本的百分比。",
        [CraftSim.CONST.TEXT.OPTIONS_GENERAL_REMEMBER_LAST_RECIPE] = "记住上次的配方",
        [CraftSim.CONST.TEXT.OPTIONS_GENERAL_REMEMBER_LAST_RECIPE_TOOLTIP] =
        "打开制造窗口时，再次打开上次选择的配方。",
        [CraftSim.CONST.TEXT.OPTIONS_GENERAL_SUPPORTED_PRICE_SOURCES] = "支持的价格来源：",
        [CraftSim.CONST.TEXT.OPTIONS_PERFORMANCE_RAM] = "制造时启用内存清理",
        [CraftSim.CONST.TEXT.OPTIONS_PERFORMANCE_RAM_CRAFTS] = "个制造",
        [CraftSim.CONST.TEXT.OPTIONS_PERFORMANCE_RAM_TOOLTIP] =
        "启用时，CraftSim 会在每次指定数量的制造后清除内存中未使用的数据，以防止内存堆积。\n内存堆积也有可能是其他插件引起的，并且不是只有 CraftSim。\n清理会影响整个魔兽的内存使用量。",
        [CraftSim.CONST.TEXT.OPTIONS_MODULES_TAB] = "模块",
        [CraftSim.CONST.TEXT.OPTIONS_PROFIT_CALCULATION_TAB] = "利润计算",
        [CraftSim.CONST.TEXT.OPTIONS_CRAFTING_TAB] = "制造",
        [CraftSim.CONST.TEXT.OPTIONS_TSM_RESET] = "恢复成默认值",
        [CraftSim.CONST.TEXT.OPTIONS_TSM_INVALID_EXPRESSION] = "语法不正确",
        [CraftSim.CONST.TEXT.OPTIONS_TSM_VALID_EXPRESSION] = "语法正确",
        [CraftSim.CONST.TEXT.OPTIONS_MODULES_REAGENT_OPTIMIZATION] = "材料优化模块",
        [CraftSim.CONST.TEXT.OPTIONS_MODULES_AVERAGE_PROFIT] = "平均利润模块",
        [CraftSim.CONST.TEXT.OPTIONS_MODULES_TOP_GEAR] = "最佳装备模块",
        [CraftSim.CONST.TEXT.OPTIONS_MODULES_COST_OVERVIEW] = "成本概览模块",
        [CraftSim.CONST.TEXT.OPTIONS_MODULES_SPECIALIZATION_INFO] = "专精信息模块",
        [CraftSim.CONST.TEXT.OPTIONS_MODULES_CUSTOMER_HISTORY_SIZE] = "每个客户的历史消息上限",
        [CraftSim.CONST.TEXT.OPTIONS_MODULES_CUSTOMER_HISTORY_MAX_ENTRIES_PER_CLIENT] = "每个客户的最大历史记录条数",
        [CraftSim.CONST.TEXT.OPTIONS_PROFIT_CALCULATION_OFFSET] = "技能临界点 + 1",
        [CraftSim.CONST.TEXT.OPTIONS_PROFIT_CALCULATION_OFFSET_TOOLTIP] =
        "材料组合建议会尝试达到临界点 + 1 而不是刚好符合需要的技能点数",
        [CraftSim.CONST.TEXT.OPTIONS_PROFIT_CALCULATION_MULTICRAFT_CONSTANT] = "产能常数",
        [CraftSim.CONST.TEXT.OPTIONS_PROFIT_CALCULATION_MULTICRAFT_CONSTANT_EXPLANATION] =
        "默认：2.5\n\n来自 beta 以及早期搜集不同玩家数据的制作数据显示。\n一次产能中额外能获得的道具数量最多为 1+C*y。\nC 中 y 是数量的基本制作道具，而 C 为 2.5。\n如果想要的话可以修改此处的值。",
        [CraftSim.CONST.TEXT.OPTIONS_PROFIT_CALCULATION_RESOURCEFULNESS_CONSTANT] = "充裕常数",
        [CraftSim.CONST.TEXT.OPTIONS_PROFIT_CALCULATION_RESOURCEFULNESS_CONSTANT_EXPLANATION] =
        "默认：0.3\n\n来自 beta 以及早期搜集不同玩家数据的制作数据显示。\n平均节省的物品数量为所需数量的 30%。\n如果想要的话可以修改此处的值。",
        [CraftSim.CONST.TEXT.OPTIONS_GENERAL_SHOW_NEWS_CHECKBOX] = "显示" .. f.bb("更新信息"),
        [CraftSim.CONST.TEXT.OPTIONS_GENERAL_SHOW_NEWS_CHECKBOX_TOOLTIP] = "登录游戏时，显示 " ..
            f.l("CraftSim") .. f.bb(" 更新信息") .. "的弹窗。",
        [CraftSim.CONST.TEXT.OPTIONS_GENERAL_HIDE_MINIMAP_BUTTON_CHECKBOX] = "隐藏小地图按钮",
        [CraftSim.CONST.TEXT.OPTIONS_GENERAL_HIDE_MINIMAP_BUTTON_TOOLTIP] = "启用以隐藏 " ..
            f.l("CraftSim") .. " 小地图按钮",
        [CraftSim.CONST.TEXT.OPTIONS_GENERAL_COIN_MONEY_FORMAT_CHECKBOX] = "使用硬币图标：",
        [CraftSim.CONST.TEXT.OPTIONS_GENERAL_COIN_MONEY_FORMAT_TOOLTIP] = "使用硬币图标显示货币",

        -- Control Panel
        [CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_CRAFT_QUEUE_LABEL] = "制作队列",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_CRAFT_QUEUE_TOOLTIP] =
        "在同一个地方排队并制造你的配方！",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_TOP_GEAR_LABEL] = "最佳装备",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_TOP_GEAR_TOOLTIP] =
        "根据选择的模式来显示最佳的可用专业装备组合",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_COST_OVERVIEW_LABEL] = "价格明细",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_COST_OVERVIEW_TOOLTIP] =
        "按物品品质显示销售价格和利润概览",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_AVERAGE_PROFIT_LABEL] = "平均利润",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_AVERAGE_PROFIT_TOOLTIP] =
        "根据你的专业属性和利润比重来显示平均利润，每个点数多少金。",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_REAGENT_OPTIMIZATION_LABEL] = "材料优化",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_REAGENT_OPTIMIZATION_TOOLTIP] =
        "建议使用最便宜材料便能达到最高品质/灵感的阈值",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_PRICE_OVERRIDES_LABEL] = "重订价格",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_PRICE_OVERRIDES_TOOLTIP] =
        "取代所有配方或特定配方的任何材料、可选材料和制造成品的价格。也可以设置物品使用制造数据的价格。",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_SPECIALIZATION_INFO_LABEL] = "专精信息",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_SPECIALIZATION_INFO_TOOLTIP] =
        "显示你的专业专精会如何影响这个配方，可以模拟任何配置！",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_CRAFT_LOG_LABEL] = "制造结果",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_CRAFT_LOG_TOOLTIP] =
        "显示制造的日志和统计数据！",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_COST_OPTIMIZATION_LABEL] = "成本明细",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_COST_OPTIMIZATION_TOOLTIP] =
        "显示制造成本详细信息的模块",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_STATISTICS_LABEL] = "统计",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_STATISTICS_TOOLTIP] =
        "显示当前打开的配方的详细结果统计数据的模块",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_RECIPE_SCAN_LABEL] = "配方扫描",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_RECIPE_SCAN_TOOLTIP] =
        "根据多种不同的选项扫描你的配方列表",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_CUSTOMER_HISTORY_LABEL] = "客户记录",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_CUSTOMER_HISTORY_TOOLTIP] =
        "提供与客户对谈的历史记录、制作过的物品和佣金的模块",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_CRAFT_BUFFS_LABEL] = "制造增益效果",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_CRAFT_BUFFS_TOOLTIP] =
        "显示你激活和缺失的制造增益效果的模块",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_EXPLANATIONS_LABEL] = "解释",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_EXPLANATIONS_TOOLTIP] =
            "该模块向你展示" .. f.l(" CraftSim") .. " 是如何计算的",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_RESET_FRAMES] = "重置框架位置",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_OPTIONS] = "选项",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_NEWS] = "更新信息",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_EASYCRAFT_EXPORT] = f.l("Easycraft") .. " 导出",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_EASYCRAFT_EXPORTING] = "正在导出",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_EASYCRAFT_EXPORT_NO_RECIPE_FOUND] = "没有适用于地心之战资料片的导出配方",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_FORGEFINDER_EXPORT] = f.l("ForgeFinder") .. " 导出",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_FORGEFINDER_EXPORTING] = "正在导出",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_EXPORT_EXPLANATION] = f.l("wowforgefinder.com") ..
            " & " .. f.l("easycraft.io") ..
            "\n是个寻找和提供" .. f.bb("魔兽世界制造订单") .. "的网站。",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_DEBUG] = "调试",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_TITLE] = "控制台",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_SUPPORTERS_BUTTON] = f.patreon("赞助者"),

        -- Supporters
        [CraftSim.CONST.TEXT.SUPPORTERS_DESCRIPTION] = f.l("感谢这些超棒的人们！"),
        [CraftSim.CONST.TEXT.SUPPORTERS_DESCRIPTION_2] = f.l(
            "您是否想要支持 CraftSim 并且在这里留下你名字和消息？\n请考虑捐款 <3"),
        [CraftSim.CONST.TEXT.SUPPORTERS_DATE] = "日期",
        [CraftSim.CONST.TEXT.SUPPORTERS_SUPPORTER] = "赞助者",
        [CraftSim.CONST.TEXT.SUPPORTERS_MESSAGE] = "留言",

        -- Customer History
        [CraftSim.CONST.TEXT.CUSTOMER_HISTORY_TITLE] = "CraftSim 客户记录",
        [CraftSim.CONST.TEXT.CUSTOMER_HISTORY_DROPDOWN_LABEL] = "选择客户",
        [CraftSim.CONST.TEXT.CUSTOMER_HISTORY_TOTAL_TIP] = "小费总计：",
        [CraftSim.CONST.TEXT.CUSTOMER_HISTORY_FROM] = "来自",
        [CraftSim.CONST.TEXT.CUSTOMER_HISTORY_TO] = "给",
        [CraftSim.CONST.TEXT.CUSTOMER_HISTORY_FOR] = "给",
        [CraftSim.CONST.TEXT.CUSTOMER_HISTORY_CRAFT_FORMAT] = "制造 %s 给 %s",
        [CraftSim.CONST.TEXT.CUSTOMER_HISTORY_DELETE_BUTTON] = "移除客户",
        [CraftSim.CONST.TEXT.CUSTOMER_HISTORY_WHISPER_BUTTON_LABEL] = "密语..",
        [CraftSim.CONST.TEXT.CUSTOMER_HISTORY_PURGE_NO_TIP_LABEL] = "移除 0 小费客户",
        [CraftSim.CONST.TEXT.CUSTOMER_HISTORY_PURGE_ZERO_TIPS_CONFIRMATION_POPUP] = "是否确定要删除小费总计为 0 的所有客户数据？",
        [CraftSim.CONST.TEXT.CUSTOMER_HISTORY_DELETE_CUSTOMER_CONFIRMATION_POPUP] = "是否确定要删除 %s 的所有数据？",
        [CraftSim.CONST.TEXT.CUSTOMER_HISTORY_PURGE_DAYS_INPUT_LABEL] = "天后自动移除",
        [CraftSim.CONST.TEXT.CUSTOMER_HISTORY_PURGE_DAYS_INPUT_TOOLTIP] =
        "CraftSim 会在每次登录后，自动删除上次删除后 X 天的所有 0 小费客户。\n设为 0 时，CraftSim 将完全不会自动删除。",
        [CraftSim.CONST.TEXT.CUSTOMER_HISTORY_CUSTOMER_HEADER] = "客户",
        [CraftSim.CONST.TEXT.CUSTOMER_HISTORY_TOTAL_TIP_HEADER] = "小费总计",
        [CraftSim.CONST.TEXT.CUSTOMER_HISTORY_CRAFT_HISTORY_DATE_HEADER] = "日期",
        [CraftSim.CONST.TEXT.CUSTOMER_HISTORY_CRAFT_HISTORY_RESULT_HEADER] = "成品",
        [CraftSim.CONST.TEXT.CUSTOMER_HISTORY_CRAFT_HISTORY_TIP_HEADER] = "小费",
        [CraftSim.CONST.TEXT.CUSTOMER_HISTORY_CRAFT_HISTORY_CUSTOMER_REAGENTS_HEADER] = "客户材料",
        [CraftSim.CONST.TEXT.CUSTOMER_HISTORY_CRAFT_HISTORY_CUSTOMER_NOTE_HEADER] = "备注",
        [CraftSim.CONST.TEXT.CUSTOMER_HISTORY_CHAT_MESSAGE_TIMESTAMP] = "时间",
        [CraftSim.CONST.TEXT.CUSTOMER_HISTORY_CHAT_MESSAGE_SENDER] = "发送者",
        [CraftSim.CONST.TEXT.CUSTOMER_HISTORY_CHAT_MESSAGE_MESSAGE] = "消息",
        [CraftSim.CONST.TEXT.CUSTOMER_HISTORY_CHAT_MESSAGE_YOU] = "[你]: ",
        [CraftSim.CONST.TEXT.CUSTOMER_HISTORY_CRAFT_LIST_TIMESTAMP] = "时间",
        [CraftSim.CONST.TEXT.CUSTOMER_HISTORY_CRAFT_LIST_RESULTLINK] = "成品链接",
        [CraftSim.CONST.TEXT.CUSTOMER_HISTORY_CRAFT_LIST_TIP] = "小费",
        [CraftSim.CONST.TEXT.CUSTOMER_HISTORY_CRAFT_LIST_REAGENTS] = "材料",
        [CraftSim.CONST.TEXT.CUSTOMER_HISTORY_CRAFT_LIST_SOMENOTE] = "注释",

        -- Craft Queue
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_TITLE] = "CraftSim 制造队列",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_CRAFT_AMOUNT_LEFT_HEADER] = "排队中",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_CRAFT_PROFESSION_GEAR_HEADER] = "专业装备",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_CRAFTING_COSTS_HEADER] = "制造成本",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_CRAFT_BUTTON_ROW_LABEL] = "制造",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_CRAFT_BUTTON_ROW_LABEL_WRONG_GEAR] = "工具错误",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_CRAFT_BUTTON_ROW_LABEL_NO_REAGENTS] = "没有材料",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_ADD_OPEN_RECIPE_BUTTON_LABEL] = "加入开放材料",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_ADD_FIRST_CRAFTS_BUTTON_LABEL] = "添加首次制造",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_ADD_WORK_ORDERS_BUTTON_LABEL] = "添加客户订单",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_ADD_WORK_ORDERS_ALLOW_CONCENTRATION_CHECKBOX] = "允许使用专注",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_ADD_WORK_ORDERS_ALLOW_CONCENTRATION_TOOLTIP] =
            "如果无法达到最低品质要求，尽可能使用" .. f.l("专注"),
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_CLEAR_ALL_BUTTON_LABEL] = "全部清除",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_RESTOCK_FAVORITES_BUTTON_LABEL] = "根据配方扫描补货",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_CRAFT_BUTTON_ROW_LABEL_WRONG_PROFESSION] = "专业错误",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_CRAFT_BUTTON_ROW_LABEL_ON_COOLDOWN] = "冷却中",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_RECIPE_REQUIREMENTS_HEADER] = "需求",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_RECIPE_REQUIREMENTS_TOOLTIP] = "需要满足所有需求才能制作配方",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_CRAFT_NEXT_BUTTON_LABEL] = "制造下一个",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_CRAFT_AVAILABLE_AMOUNT] = "可制造",
        [CraftSim.CONST.TEXT.CRAFTQUEUE_AUCTIONATOR_SHOPPING_LIST_BUTTON_LABEL] = "创建Auctionator购物清单",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_QUEUE_TAB_LABEL] = "制造队列",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_FLASH_TASKBAR_OPTION_LABEL] = "闪烁任务栏，当" ..
            f.bb("制造队列") .. "制造完成时",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_FLASH_TASKBAR_OPTION_TOOLTIP] =
            "当你的魔兽世界窗口最小化并且配方在" .. f.bb("制造队列") ..
            "时，" .. f.l(" CraftSim") .. " 将闪烁你任务栏的魔兽世界图标",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_RESTOCK_OPTIONS_TAB_LABEL] = "补货选项",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_RESTOCK_OPTIONS_TAB_TOOLTIP] = "配置从配方扫描导入时的补货行为",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_RESTOCK_OPTIONS_GENERAL_PROFIT_THRESHOLD_LABEL] = "利润阈值：",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_RESTOCK_OPTIONS_SALE_RATE_INPUT_LABEL] = "销售率阈值：",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_RESTOCK_OPTIONS_TSM_SALE_RATE_TOOLTIP] = string.format(
            [[
只有已加载 %s 时才可使用！

这会检查已选择的物品品质的 %s 销售率
是否大于或等于设置的销售率阈值。
]], f.bb("TSM"), f.bb("任何")),
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_RESTOCK_OPTIONS_TSM_SALE_RATE_TOOLTIP_GENERAL] = string.format(
            [[
只有已加载 %s 时才可使用！

这会检查物品品质的%s销售率
是否大于或等于设置的销售率阈值。
]], f.bb("TSM"), f.bb("任何")),
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_RESTOCK_OPTIONS_AMOUNT_LABEL] = "补货数量：",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_RESTOCK_OPTIONS_RESTOCK_TOOLTIP] = "这是该配方正在排队的" ..
            f.bb("制作数量") ..
            "。\n\n您在背包与银行中拥有该星级数量的物品将从补货数量中扣除",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_RESTOCK_OPTIONS_ENABLE_RECIPE_LABEL] = "启用：",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_RESTOCK_OPTIONS_GENERAL_OPTIONS_LABEL] = "一般选项 (所有配方)",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_RESTOCK_OPTIONS_ENABLE_RECIPE_TOOLTIP] =
        "如果此选项为关闭，将根据上述的一般选项进补货",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_TOTAL_PROFIT_LABEL] = "总计 Ø 利润：",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_TOTAL_CRAFTING_COSTS_LABEL] = "总计制造成本：",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_EDIT_RECIPE_TITLE] = "编辑配方",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_EDIT_RECIPE_NAME_LABEL] = "配方名称",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_EDIT_RECIPE_REAGENTS_SELECT_LABEL] = "选择",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_EDIT_RECIPE_OPTIONAL_REAGENTS_LABEL] = "可选材料",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_EDIT_RECIPE_FINISHING_REAGENTS_LABEL] = "完成材料",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_EDIT_RECIPE_PROFESSION_GEAR_LABEL] = "专业工具",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_EDIT_RECIPE_OPTIMIZE_PROFIT_BUTTON] = "优化利润",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_EDIT_RECIPE_CRAFTING_COSTS_LABEL] = "制作成本：",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_EDIT_RECIPE_AVERAGE_PROFIT_LABEL] = "平均利润：",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_EDIT_RECIPE_RESULTS_LABEL] = "成品",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_EDIT_RECIPE_CONCENTRATION_CHECKBOX] = " 专注",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_AUCTIONATOR_SHOPPING_LIST_PER_CHARACTER_CHECKBOX] = "每个角色",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_AUCTIONATOR_SHOPPING_LIST_PER_CHARACTER_CHECKBOX_TOOLTIP] = "单独为每个工匠角色创建一个 " ..
            f.bb("Auctionator 购物清单") .. " 。\n而不是为所有角色创建一个购物清单",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_AUCTIONATOR_SHOPPING_LIST_TARGET_MODE_CHECKBOX] = "仅目标模式",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_AUCTIONATOR_SHOPPING_LIST_TARGET_MODE_CHECKBOX_TOOLTIP] = "仅为目标模式配方创建一个 " ..
            f.bb("Auctionator 购物清单") .. " 。",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_UNSAVED_CHANGES_TOOLTIP] = f.white("未保存的队列数量。\n按回车保存"),
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_STATUSBAR_LEARNED] = f.white("配方已学会"),
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_STATUSBAR_COOLDOWN] = f.white("未处于冷却状态"),
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_STATUSBAR_REAGENTS] = f.white("可用材料"),
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_STATUSBAR_GEAR] = f.white("已装备专业装备"),
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_STATUSBAR_CRAFTER] = f.white("正确的工匠角色"),
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_STATUSBAR_PROFESSION] = f.white("专业启用"),
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_BUTTON_EDIT] = "编辑",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_BUTTON_CRAFT] = "制造",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_BUTTON_CLAIM] = "接单",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_BUTTON_CLAIMED] = "已接单",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_BUTTON_NEXT] = "下一个：",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_BUTTON_NOTHING_QUEUED] = "无排队中",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_BUTTON_ORDER] = "订购",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_BUTTON_SUBMIT] = "交单",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_IGNORE_ACUITY_RECIPES_CHECKBOX_LABEL] = "忽略匠人之敏配方",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_IGNORE_ACUITY_RECIPES_CHECKBOX_TOOLTIP] =
            "不要把使用 " .. f.bb("匠人之敏") .. " 的配方先加入制造队列",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_AMOUNT_TOOLTIP] = "\n\n排队中的制造：",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_ORDER_CUSTOMER] = "\n\n订单发布人：",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_ORDER_MINIMUM_QUALITY] = "\n最低品质：",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_ORDER_REWARDS] = "\n奖励：",

        -- craft buffs

        [CraftSim.CONST.TEXT.CRAFT_BUFFS_TITLE] = "CraftSim 制造增益效果",
        [CraftSim.CONST.TEXT.CRAFT_BUFFS_SIMULATE_BUTTON] = "模拟增益效果",
        [CraftSim.CONST.TEXT.CRAFT_BUFF_CHEFS_HAT_TOOLTIP] = f.bb("巫妖王之怒玩具。") ..
            "\n需要诺森德烹饪\n将制作速度设置为 " .. f.g("0.5 秒"),

        -- cooldowns module

        [CraftSim.CONST.TEXT.COOLDOWNS_TITLE] = "CraftSim 冷却",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_COOLDOWNS_LABEL] = "冷却",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_COOLDOWNS_TOOLTIP] = "总览你账号的 " ..
            f.bb("专业冷却"),
        [CraftSim.CONST.TEXT.COOLDOWNS_CRAFTER_HEADER] = "工匠",
        [CraftSim.CONST.TEXT.COOLDOWNS_RECIPE_HEADER] = "配方",
        [CraftSim.CONST.TEXT.COOLDOWNS_CHARGES_HEADER] = "充能",
        [CraftSim.CONST.TEXT.COOLDOWNS_NEXT_HEADER] = "下次充能",
        [CraftSim.CONST.TEXT.COOLDOWNS_ALL_HEADER] = "充能完毕",
        [CraftSim.CONST.TEXT.COOLDOWNS_TAB_OVERVIEW] = "概览",
        [CraftSim.CONST.TEXT.COOLDOWNS_TAB_OPTIONS] = "选项",
        [CraftSim.CONST.TEXT.COOLDOWNS_EXPANSION_FILTER_BUTTON] = "资料片过滤器",
        [CraftSim.CONST.TEXT.COOLDOWNS_RECIPE_LIST_TEXT_TOOLTIP] = f.bb("\n\n配方共享冷却：\n"),
        [CraftSim.CONST.TEXT.COOLDOWNS_RECIPE_READY] = f.g("就绪"),

        -- concentration module

        [CraftSim.CONST.TEXT.CONCENTRATION_TRACKER_TITLE] = "CraftSim 专注",
        [CraftSim.CONST.TEXT.CONCENTRATION_TRACKER_LABEL_CRAFTER] = "工匠",
        [CraftSim.CONST.TEXT.CONCENTRATION_TRACKER_LABEL_CURRENT] = "当前",
        [CraftSim.CONST.TEXT.CONCENTRATION_TRACKER_LABEL_MAX] = "最大",
        [CraftSim.CONST.TEXT.CONCENTRATION_TRACKER_MAX] = f.g("最大"),
        [CraftSim.CONST.TEXT.CONCENTRATION_TRACKER_MAX_VALUE] = "最大值：",
        [CraftSim.CONST.TEXT.CONCENTRATION_TRACKER_FULL] = f.g("专注值满"),

        -- static popups
        [CraftSim.CONST.TEXT.STATIC_POPUPS_YES] = "是",
        [CraftSim.CONST.TEXT.STATIC_POPUPS_NO] = "否",

        -- frames
        [CraftSim.CONST.TEXT.FRAMES_RESETTING] = "正在重置框架ID： ",
        [CraftSim.CONST.TEXT.FRAMES_WHATS_NEW] = "CraftSim 有什么新功能？",
        [CraftSim.CONST.TEXT.FRAMES_JOIN_DISCORD] = "加入 Discord!",
        [CraftSim.CONST.TEXT.FRAMES_DONATE_KOFI] = "在 Kofi 上访问 CraftSim",
        [CraftSim.CONST.TEXT.FRAMES_NO_INFO] = "无信息",

        -- node data
        [CraftSim.CONST.TEXT.NODE_DATA_RANK_TEXT] = "等级 ",
        [CraftSim.CONST.TEXT.NODE_DATA_TOOLTIP] = "\n\n来自天赋的总计数据：\n",

        -- columns
        [CraftSim.CONST.TEXT.SOURCE_COLUMN_AH] = "拍卖",
        [CraftSim.CONST.TEXT.SOURCE_COLUMN_OVERRIDE] = "重订",
        [CraftSim.CONST.TEXT.SOURCE_COLUMN_WO] = "订单",
    }
end
