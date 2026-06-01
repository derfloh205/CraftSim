---@class CraftSim
local CraftSim = select(2, ...)

CraftSim.LOCAL_CN = {}

---@return table<CraftSim.LOCALIZATION_IDS, string>
function CraftSim.LOCAL_CN:GetData()
    local f = CraftSim.GUTIL:GetFormatter()
    local cm = function(i, s) return CraftSim.MEDIA:GetAsTextIcon(i, s) end
    return {
        -- REQUIRED:
        STAT_MULTICRAFT = "产能",
        STAT_RESOURCEFULNESS = "充裕",
        STAT_INGENUITY = "奇思",
        STAT_CRAFTINGSPEED = "制作速度",
        EQUIP_MATCH_STRING = "装备：",
        ENCHANTED_MATCH_STRING = "附魔：",

        -- OPTIONAL (Defaulting to EN if not available):

        -- shared prof cds
        DF_ALCHEMY_TRANSMUTATIONS = "巨龙时代 - 转化",
        MIDNIGHT_ALCHEMY_TRANSMUTATIONS = "至暗之夜 - 转化",

        -- expansions

        EXPANSION_VANILLA = "经典旧世",
        EXPANSION_THE_BURNING_CRUSADE = "燃烧的远征",
        EXPANSION_WRATH_OF_THE_LICH_KING = "巫妖王之怒",
        EXPANSION_CATACLYSM = "大地的裂变",
        EXPANSION_MISTS_OF_PANDARIA = "熊猫人之谜",
        EXPANSION_WARLORDS_OF_DRAENOR = "德拉诺之王",
        EXPANSION_LEGION = "军团再临",
        EXPANSION_BATTLE_FOR_AZEROTH = "争霸艾泽拉斯",
        EXPANSION_SHADOWLANDS = "暗影国度",
        EXPANSION_DRAGONFLIGHT = "巨龙时代",
        EXPANSION_THE_WAR_WITHIN = "地心之战",
        EXPANSION_MIDNIGHT = "至暗之夜",

        -- professions

        PROFESSIONS_BLACKSMITHING = "锻造",
        PROFESSIONS_LEATHERWORKING = "制皮",
        PROFESSIONS_ALCHEMY = "炼金术",
        PROFESSIONS_HERBALISM = "草药学",
        PROFESSIONS_COOKING = "烹饪",
        PROFESSIONS_MINING = "采矿",
        PROFESSIONS_TAILORING = "裁缝",
        PROFESSIONS_ENGINEERING = "工程学",
        PROFESSIONS_ENCHANTING = "附魔",
        PROFESSIONS_FISHING = "钓鱼",
        PROFESSIONS_SKINNING = "剥皮",
        PROFESSIONS_JEWELCRAFTING = "珠宝加工",
        PROFESSIONS_INSCRIPTION = "铭文",

        -- Other Statnames

        STAT_SKILL = "技能",
        STAT_MULTICRAFT_BONUS = "产能额外获得",
        STAT_RESOURCEFULNESS_BONUS = "充裕额外返还",
        STAT_CRAFTINGSPEED_BONUS = "制作速度",
        STAT_INGENUITY_BONUS = "奇思额外返还",
        STAT_INGENUITY_LESS_CONCENTRATION = "消耗专注减少",
        STAT_PHIAL_EXPERIMENTATION = "药瓶突破",
        STAT_POTION_EXPERIMENTATION = "药水突破",

        -- Profit Breakdown Tooltips
        RESOURCEFULNESS_EXPLANATION_TOOLTIP =
        "充裕会分别触发每一种材料，并返还约30%的数量。\n\n平均返还根据每种组合结合触发概率计算得出。\n（所有材料同时触发的概率很低，但会返还很多。）\n\n平均返还材料的总成本，是按概率加权后每种组合的成本之和。",

        RECIPE_DIFFICULTY_EXPLANATION_TOOLTIP =
        "配方难度决定了不同品质的临界点。\n\n五种品质的配方，临界点位于配方难度的20%、50%、80%和100%。\n三种品质的配方，临界点位于配方难度的50%和100%。",
        MULTICRAFT_EXPLANATION_TOOLTIP =
        "产能会有概率在制作配方时获得比通常更多的物品。\n\n额外数量通常在1到2.5y之间\ny = 单次制造的基础物品数量。",
        REAGENTSKILL_EXPLANATION_TOOLTIP =
        "材料品质最多可以提供基础配方难度的40%作为技能加成。\n\n全部1星材料：0%加成\n全部2星材料：20%加成\n全部3星材料：40%加成\n\n技能加成根据不同品质的材料数量，结合其品质权重计算得出\n每种带品质的材料都有独特的权重值。\n\n再造有所不同。材料品质加成的最大值取决于\n最初制造物品所使用的材料品质。\n确切的运作方式尚不清楚。\n不过CraftSim内部会将实际达到的技能与全3星进行比较，\n并计算出加成的的最大值。",
        REAGENTFACTOR_EXPLANATION_TOOLTIP =
        "大部分情况下材料可以提供基础配方难度的40%作为技能加成。\n\n在再造的情况下，这个数值取决于之前制造所使用的材料品质。",

        -- Simulation Mode
        SIMULATION_MODE_NONE = "无",
        SIMULATION_MODE_LABEL = "模拟模式",
        SIMULATION_MODE_TITLE = "CraftSim模拟模式",
        SIMULATION_MODE_TOOLTIP =
        "CraftSim的模拟模式可以不受限制地尝试配方",
        SIMULATION_MODE_OPTIONAL = "可选 #",
        SIMULATION_MODE_FINISHING = "成品 #",
        SIMULATION_MODE_QUALITY_BUTTON_TOOLTIP = "全部使用材料品质",
        SIMULATION_MODE_CLEAR_BUTTON = "清除",
        SIMULATION_MODE_CONCENTRATION = " 专注",
        SIMULATION_MODE_CONCENTRATION_COST = "专注消耗：",
        CONCENTRATION_ESTIMATED_TIME_UNTIL = "可制造： %s",
        SIMULATION_MODE_QUALITY_METER_NEEDED = "需要：",
        SIMULATION_MODE_QUALITY_METER_MISSING = "缺少：",
        SIMULATION_MODE_QUALITY_METER_MAX = "满",

        -- Details Frame
        RECIPE_DIFFICULTY_LABEL = "配方难度：",
        MULTICRAFT_LABEL = "产能：",
        RESOURCEFULNESS_LABEL = "充裕：",
        RESOURCEFULNESS_BONUS_LABEL = "充裕材料加成：",
        INGENUITY_LABEL = "奇思：",
        INGENUITY_EXPLANATION_TOOLTIP =
        "奇思会有概率在使用专注制造时返还部分消耗的专注。",
        CONCENTRATION_LABEL = "专注：",
        REAGENT_QUALITY_BONUS_LABEL = "材料品质加成：",
        REAGENT_QUALITY_MAXIMUM_LABEL = "材料品质最大百分比：",
        EXPECTED_QUALITY_LABEL = "预期品质：",
        NEXT_QUALITY_LABEL = "下一级品质：",
        MISSING_SKILL_LABEL = "缺失技能：",
        SKILL_LABEL = "技能：",
        MULTICRAFT_BONUS_LABEL = "产能物品加成：",

        -- Statistics
        STATISTICS_CDF_EXPLANATION =
        "这是通过使用CDF（累积分布函数）的“abramowitz and stegun”近似方法（1985）计算得出。\n\n你会发现单次制造的值总是在50%左右。\n这是因为利润为0的点通常会接近平均利润。\n而达到CDF均值的概率始终为50%。\n\n然而，不同配方之间的变化率可能有很大的差异。\n如果获得正利润的可能性大于负利润，那么概率会稳步上升。\n反之亦然。",
        EXPLANATIONS_PROFIT_CALCULATION_EXPLANATION = f.r("警告：") .. "前方硬核数学！\n\n" ..
            "当制造物品时，基于专业属性，不同的结果有不同的概率。\n" ..
            "在统计学中被称作" .. f.l("概率分布。\n") ..
            "但是，你会发现到各种触发的概率之和并不等于1\n" ..
            "（对概率分布而言是必要的，否则将有100%概率发生某种情况）\n\n" ..
            "这是因为像" ..
            f.bb("充裕") .. "和" .. f.bb("产能") .. "可以" .. f.g("同时触发。\n") ..
            "所以需要先将触发概率转换成总概率为100%的" ..
            f.l("概率分布") ..
            "（意味着涵盖了所有情况）\n" ..
            "因此需要计算每次制造时" .. f.l("所有") .. "可能的结果。\n\n" ..
            "例如：\n" ..
            f.p .. "如果" .. f.bb("没有") .. "触发？\n" ..
            f.p .. "如果只触发了" .. f.bb("充裕") .. "或" .. f.bb("产能") .. "？\n" ..
            f.p .. "如果同时触发" .. f.bb("充裕") .. "和" .. f.bb("产能") .. "？\n" ..
            f.p .. "等等……\n\n" ..
            "对于一个需要考虑所有触发的配方，可能性有2的2次方，也就是4种。\n" ..
            "要得到只触发" ..
            f.bb("产能") .. "的概率，必须考虑所有其他可能性！\n" ..
            "触发" ..
            f.l("仅限") .. f.bb("产能") .. "的概率实际上是触发了" ..
            f.bb("产能") .. "且" .. f.l("没有") .. "触发" .. f.bb("充裕") .. "的概率\n" ..
            "在数学种，事件没有发生的概率等于1减去发生的概率。\n" ..
            "所以只触发" ..
            f.bb("产能") ..
            "的概率实际上是" .. f.g("产能概率 * (1-充裕概率)\n\n") ..
            "用这种方式计算每种可能性后，各个概率之和确实等于1！\n" ..
            "意味着现在可以应用统计公式了。这里最有意思的是" ..
            f.bb("期望值") .. "\n" ..
            "顾名思义，就是平均可以期望得到的数值，也就是" ..
            f.bb("每次制造的预期利润！\n") ..
            "\n" .. cm(CraftSim.MEDIA.IMAGES.EXPECTED_VALUE) .. "\n\n" ..
            "这个公式说明概率分布" ..
            f.l("X") ..
            "的期望值 " ..
            f.l("E") .. "等于所有可能值乘以对应概率的总和。\n" ..
            "所以如果有一个" ..
            f.bb("情况A的概率为30%") ..
            "且利润为" ..
            CraftSim.UTIL:FormatMoney(-100 * 10000, true) ..
            "和一个" ..
            f.bb("情况B的概率为70%") ..
            "且利润为" .. CraftSim.UTIL:FormatMoney(300 * 10000, true) .. "\n" ..
            "那么期望利润" .. f.bb("E(X) = -100*0.3 + 300*0.7") ..
            "等于" .. CraftSim.UTIL:FormatMoney((-100 * 0.3 + 300 * 0.7) * 10000, true) .. "\n" ..
            "可以在" .. f.bb("统计") .. "窗口中查看当前配方的所有情况！"
        ,

        -- Popups
        POPUP_NO_PRICE_SOURCE_SYSTEM = "没有可用的价格来源！",
        POPUP_NO_PRICE_SOURCE_TITLE = "CraftSim价格来源警告",
        POPUP_NO_PRICE_SOURCE_WARNING =
        "未找到价格来源！\n\n至少需要安装下面其中一个价格来源插件，\n才能使用CraftSim计算利润：\n\n\n",
        POPUP_NO_PRICE_SOURCE_WARNING_SUPPRESS = "不再显示警告",
        POPUP_NO_PRICE_SOURCE_WARNING_ACCEPT = "好的",

        -- Reagents Frame
        REAGENT_OPTIMIZATION_TITLE = "CraftSim材料优化",
        REAGENTS_REACHABLE_QUALITY = "可达到品质：",
        REAGENTS_MISSING = "材料不足",
        REAGENTS_AVAILABLE = "可用材料",
        REAGENTS_CHEAPER = "最便宜材料",
        REAGENTS_BEST_COMBINATION = "已分配最佳组合",
        REAGENTS_NO_COMBINATION = "未找到\n提高品质的组合",
        REAGENTS_ASSIGN = "分配",
        REAGENTS_MAXIMUM_QUALITY = "最高品质：",
        REAGENTS_AVERAGE_PROFIT_LABEL = "平均利润：",
        REAGENTS_AVERAGE_PROFIT_TOOLTIP = "使用" .. f.l("当前材料分配") .. "时" ..
            f.bb("每次制造的平均利润"),
        REAGENTS_OPTIMIZE_BEST_ASSIGNED = "已分配最佳材料",
        REAGENTS_CONCENTRATION_LABEL = "专注：",
        REAGENTS_OPTIMIZE_INFO = "Shift+左键点击数字可在聊天中输入物品链接",
        ADVANCED_OPTIMIZATION_BUTTON = "进阶优化",
        REAGENTS_OPTIMIZE_TOOLTIP = "（编辑后重置）\n使用" ..
            f.gold("专注值") .. "和" .. f.bb("成品材料") .. "进行优化",

        -- Specialization Info Frame
        SPEC_INFO_TITLE = "CraftSim专精信息",
        SPEC_INFO_SIMULATE_KNOWLEDGE_DISTRIBUTION = "模拟专业知识分配",
        SPEC_INFO_NODE_TOOLTIP = "此节点为配方提供下列属性：",
        SPEC_INFO_WORK_IN_PROGRESS = "无可用数据",

        -- Crafting Results Frame
        CRAFT_LOG_TITLE = "CraftSim制造日志",
        CRAFT_LOG_ADV_TITLE = "CraftSim高级制造日志",
        CRAFT_LOG_LOG = "制造日志",
        CRAFT_LOG_LOG_1 = "利润：",
        CRAFT_LOG_LOG_2 = "返还专注：",
        CRAFT_LOG_LOG_3 = "产能：",
        CRAFT_LOG_LOG_4 = "返还材料：",
        CRAFT_LOG_LOG_5 = "概率：",
        CRAFT_LOG_CRAFTED_ITEMS = "制造的物品",
        CRAFT_LOG_SESSION_PROFIT = "本次利润：",
        CRAFT_LOG_RESET_DATA = "重置数据",
        CRAFT_LOG_EXPORT_JSON = "导出JSON",
        CRAFT_LOG_RECIPE_STATISTICS = "配方统计",
        CRAFT_LOG_NOTHING = "尚未制造任何东西！",
        CRAFT_LOG_CALCULATION_COMPARISON_NUM_CRAFTS_PREFIX = "制造：",
        CRAFT_LOG_STATISTICS_2 = "预期平均利润：",
        CRAFT_LOG_STATISTICS_3 = "实际平均利润：",
        CRAFT_LOG_STATISTICS_4 = "实际利润：",
        CRAFT_LOG_STATISTICS_5 = "触发 - 实际/预期：",
        CRAFT_LOG_STATISTICS_7 = "产能：",
        CRAFT_LOG_STATISTICS_8 = "- 平均额外物品：",
        CRAFT_LOG_STATISTICS_9 = "充裕触发：",
        CRAFT_LOG_CALCULATION_COMPARISON_NUM_CRAFTS_PREFIX0 = "- 平均返还成本：",
        CRAFT_LOG_CALCULATION_COMPARISON_NUM_CRAFTS_PREFIX1 = "利润：",
        CRAFT_LOG_SAVED_REAGENTS = "返还材料",
        CRAFT_LOG_DISABLE_CHECKBOX = f.r("禁用") .. "制造日志",
        CRAFT_LOG_DISABLE_CHECKBOX_TOOLTIP = "启用后将停止在记录制造信息，可能会" ..
            f.g("提高性能"),
        CRAFT_LOG_REAGENT_DETAILS_TAB = "材料详情",
        CRAFT_LOG_RESULT_ANALYSIS_TAB = "成品分析",
        CRAFT_LOG_RESULT_ANALYSIS_TAB_DISTRIBUTION_LABEL = "成品分布",
        CRAFT_LOG_RESULT_ANALYSIS_TAB_DISTRIBUTION_HELP =
        "制作成品的相对分布。\n（忽略产能数量）",
        CRAFT_LOG_RESULT_ANALYSIS_TAB_MULTICRAFT = "产能",
        CRAFT_LOG_RESULT_ANALYSIS_TAB_RESOURCEFULNESS = "充裕",
        CRAFT_LOG_RESULT_ANALYSIS_TAB_YIELD_DDISTRIBUTION = "产量分布",

        -- Stats Weight Frame
        STAT_WEIGHTS_TITLE = "CraftSim平均利润",
        EXPLANATIONS_TITLE = "CraftSim平均利润说明",
        STAT_WEIGHTS_SHOW_EXPLANATION_BUTTON = "显示说明",
        STAT_WEIGHTS_HIDE_EXPLANATION_BUTTON = "隐藏说明",
        STAT_WEIGHTS_SHOW_STATISTICS_BUTTON = "显示统计",
        STAT_WEIGHTS_HIDE_STATISTICS_BUTTON = "隐藏统计",
        STAT_WEIGHTS_PROFIT_CRAFT = "每次平均利润：",
        EXPLANATIONS_BASIC_PROFIT_TAB = "基础利润计算",

        -- Recipe Info Frame
        RECIPE_INFO_TITLE = "CraftSim配方信息",
        RECIPE_INFO_OPTIONS_TOOLTIP = "显示显示数据",
        RECIPE_INFO_RESULT_ITEMS_LABEL = "制作成品: ",
        RECIPE_INFO_CRAFTING_COST_LABEL = "制造成本: ",
        RECIPE_INFO_AVG_CRAFTING_COST_LABEL = "平均制造成本: ",
        RECIPE_INFO_KNOWLEDGE_POINTS_LABEL = "专业知识: ",
        RECIPE_INFO_AVG_YIELD_LABEL = "平均产量: ",
        RECIPE_INFO_AVG_MULTICRAFT_ITEMS_LABEL = "平均额外物品: ",
        RECIPE_INFO_AVG_RESOURCEFULNESS_SAVED_LABEL = "平均返还材料: ",
        RECIPE_INFO_CONCENTRATION_PROFIT_LABEL = "专注利润: ",
        RECIPE_INFO_CONCENTRATION_COST_LABEL = "专注基础消耗: ",
        -- Recipe Info context menu option labels (stat-weight rows, default on)
        RECIPE_INFO_OPTION_AVG_PROFIT = "平均利润",
        RECIPE_INFO_OPTION_AVG_PROFIT_TOOLTIP = "显示基于专业属性的每次制造平均利润",
        RECIPE_INFO_OPTION_MULTICRAFT_WEIGHT = "每点产能利润",
        RECIPE_INFO_OPTION_MULTICRAFT_WEIGHT_TOOLTIP =
        "显示每点产能带来的利润",
        RECIPE_INFO_OPTION_RESOURCEFULNESS_WEIGHT = "每点充裕利润",
        RECIPE_INFO_OPTION_RESOURCEFULNESS_WEIGHT_TOOLTIP =
        "显示每点充裕带来的利润",
        RECIPE_INFO_OPTION_CONCENTRATION_WEIGHT = "每点专注利润",
        RECIPE_INFO_OPTION_CONCENTRATION_WEIGHT_TOOLTIP =
        "显示计算奇思返还后每点专注带来的利润",
        -- Recipe Info context menu option labels (extra rows, default off)
        RECIPE_INFO_OPTION_CRAFTING_COST = "制造成本",
        RECIPE_INFO_OPTION_CRAFTING_COST_TOOLTIP = "显示每次制造的总成本",
        RECIPE_INFO_OPTION_AVG_CRAFTING_COST = "平均制造成本",
        RECIPE_INFO_OPTION_AVG_CRAFTING_COST_TOOLTIP =
        "显示计算充裕返还后每次制造的平均成本",
        RECIPE_INFO_OPTION_RESULT_ICONS = "制作成品图标",
        RECIPE_INFO_OPTION_RESULT_ICONS_TOOLTIP = "显示每种品质的制作成品图标",
        RECIPE_INFO_OPTION_KNOWLEDGE_POINTS = "专业知识",
        RECIPE_INFO_OPTION_KNOWLEDGE_POINTS_TOOLTIP =
        "显示影响此配方的已分配/最大专业知识",
        RECIPE_INFO_OPTION_AVG_YIELD = "平均产量",
        RECIPE_INFO_OPTION_AVG_YIELD_TOOLTIP = "显示计算产能额外物品后每次制造的平均产量",
        RECIPE_INFO_OPTION_AVG_MULTICRAFT_ITEMS = "平均产能额外物品",
        RECIPE_INFO_OPTION_AVG_MULTICRAFT_ITEMS_TOOLTIP =
        "显示每次制造由产能触发额外物品的平均数量",
        RECIPE_INFO_OPTION_AVG_RESOURCEFULNESS_SAVED = "平均充裕返还成本",
        RECIPE_INFO_OPTION_AVG_RESOURCEFULNESS_SAVED_TOOLTIP =
        "显示每次制造由充裕触发返还材料的平均成本",
        RECIPE_INFO_OPTION_CONCENTRATION_PROFIT = "平均专注利润",
        RECIPE_INFO_OPTION_CONCENTRATION_PROFIT_TOOLTIP =
        "显示每次使用专注制造的平均利润",
        RECIPE_INFO_OPTION_CONCENTRATION_COST = "专注消耗",
        RECIPE_INFO_OPTION_CONCENTRATION_COST_TOOLTIP =
        "显示每次制造的专注基础消耗",
        RECIPE_INFO_OPTION_PROFIT_PER_QUALITY = "每种品质利润",
        RECIPE_INFO_OPTION_PROFIT_PER_QUALITY_TOOLTIP =
        "显示每种品质的预估利润\n（最低售价-制造成本）",
        RECIPE_INFO_QUALITY_PROFIT_LABEL = "利润：",

        -- Cost Details Frame
        PRICING_TITLE = "CraftSim定价管理",
        PRICING_EXPLANATION = "显示所有材料的可能价格概览。\n" ..
            f.bb("“来源”") ..
            "显示使用的哪种价格来源。\n\n" ..
            f.g("拍卖") ..
            " .. 拍卖行价格\n" ..
            f.l("手动") ..
            " .. 手动定价\n" ..
            f.bb("手动") ..
            "设置后会优先使用。\n\n" ..
            f.bb("右键点击") .. "任何材料或制作成品可以进行手动定价",
        PRICING_CRAFTING_COSTS = "制造成本：",
        PRICING_ITEM_HEADER = "物品",
        PRICING_DELETE_ALL_OVERRIDES = "删除所有手动定价",
        COST_OPTIMIZATION_PRICE_HEADER = "价格",
        COST_OPTIMIZATION_USED_SOURCE = "来源",
        PRICING_AVG_CRAFTING_COST = "平均制造成本",
        COST_OPTIMIZATION_SUB_RECIPE_OPTIMIZATION_TOOLTIP = "启用后，如果玩家角色或小号可以制造此物品。\n" ..
            f.l("CraftSim") .. "将根据这些" .. f.g("优化制造成本") ..
            "\n\n" ..
            f.r("由于有大量额外的计算，可能会略微降低性能"),
        COST_OPTIMIZATION_SUB_RECIPE_MAX_DEPTH_LABEL = "子配方计算深度",
        COST_OPTIMIZATION_SUB_RECIPE_INCLUDE_CONCENTRATION = "启用专注",
        COST_OPTIMIZATION_SUB_RECIPE_INCLUDE_CONCENTRATION_TOOLTIP = "启用后，" ..
            f.l("CraftSim") .. "将包含材料品质，即便需要使用专注。",
        COST_OPTIMIZATION_SUB_RECIPE_INCLUDE_COOLDOWN_RECIPES = "包含冷却配方",
        COST_OPTIMIZATION_SUB_RECIPE_INCLUDE_COOLDOWN_RECIPES_TOOLTIP = "启用后，计算自制材料时 " ..
            f.l("CraftSim") .. "将忽略配方的冷却时间。",
        COST_OPTIMIZATION_SUB_RECIPE_SELECT_RECIPE_CRAFTER = "选择配方制作者",
        PRICING_REAGENT_LIST_AH_COLUMN_AUCTION_BUYOUT = "拍卖行价格：",
        PRICING_REAGENT_LIST_OVERRIDE = "\n\n手动定价",
        PRICING_REAGENT_LIST_EXPECTED_COSTS_TOOLTIP = "\n\n正在制造 ",
        PRICING_REAGENT_LIST_EXPECTED_COSTS_PRE_ITEM = "\n- 每个物品的预期成本：",
        PRICING_REAGENT_LIST_CONCENTRATION_COST = f.gold("专注消耗："),
        PRICING_REAGENT_LIST_CONCENTRATION = "专注：",

        -- Statistics Frame
        STATISTICS_TITLE = "CraftSim统计信息",
        STATISTICS_EXPECTED_PROFIT = "预期利润（μ）",
        STATISTICS_CHANCE_OF = "",
        STATISTICS_PROFIT = "利润",
        STATISTICS_AFTER = " 的概率",
        STATISTICS_CRAFTS = "次制造：",
        STATISTICS_QUALITY_HEADER = "品质",
        STATISTICS_MULTICRAFT_HEADER = "产能",
        STATISTICS_RESOURCEFULNESS_HEADER = "充裕",
        STATISTICS_EXPECTED_PROFIT_HEADER = "预期利润",
        PROBABILITY_TABLE_TITLE = "配方概率表",
        STATISTICS_PROBABILITY_TABLE_TAB = "概率表",
        STATISTICS_CONCENTRATION_TAB = "专注",
        STATISTICS_CONCENTRATION_CURVE_GRAPH = "专注消耗折线图",
        STATISTICS_CONCENTRATION_CURVE_GRAPH_HELP = "配方基于玩家专业技能的专注消耗\n" ..
            f.bb("X轴：") .. "专业技能\n" ..
            f.bb("Y轴：") .. "专注消耗",

        -- Price Details Frame
        COST_OVERVIEW_TITLE = "CraftSim价格明细",
        PRICE_DETAILS_INV_AH = "库存/拍卖",
        PRICE_DETAILS_ITEM = "物品",
        PRICE_DETAILS_PRICE_ITEM = "价格/物品",
        PRICE_DETAILS_PROFIT_ITEM = "利润/物品",

        -- Price Override Frame
        PRICE_OVERRIDE_TITLE = "CraftSim手动定价",
        PRICE_OVERRIDE_HINT = "（现在可以直接在" .. f.bb("成本优化模块") .. "手动定价物品）",
        PRICE_OVERRIDE_REQUIRED_REAGENTS = "必要材料",
        PRICE_OVERRIDE_OPTIONAL_REAGENTS = "附加材料",
        PRICE_OVERRIDE_FINISHING_REAGENTS = "成品材料",
        PRICE_OVERRIDE_RESULT_ITEMS = "产出物品",
        PRICE_OVERRIDE_ACTIVE_OVERRIDES = "启用手动定价",
        PRICE_OVERRIDE_ACTIVE_OVERRIDES_TOOLTIP =
        "“(制作成品)” -> 配方的制作成品才考虑手动定价",
        PRICE_OVERRIDE_CLEAR_ALL = "全部清除",
        PRICE_OVERRIDE_SAVE = "保存",
        PRICE_OVERRIDE_SAVED = "已保存",
        PRICE_OVERRIDE_REMOVE = "移除",

        -- Recipe Scan Frame
        RECIPE_SCAN_TITLE = "CraftSim配方扫描",
        RECIPE_SCAN_MODE = "扫描模式",
        RECIPE_SCAN_SORT_MODE = "排序模式",
        RECIPE_SCAN_SCAN_RECIPIES = "扫描配方",
        RECIPE_SCAN_SCAN_CANCEL = "取消",
        RECIPE_SCAN_SCANNING = "正在扫描",
        RECIPE_SCAN_INCLUDE_NOT_LEARNED = "包含未学习",
        RECIPE_SCAN_INCLUDE_NOT_LEARNED_TOOLTIP = "配方扫描时包含未学习的配方",
        RECIPE_SCAN_INCLUDE_SOULBOUND = "包含灵魂绑定",
        RECIPE_SCAN_INCLUDE_SOULBOUND_TOOLTIP =
        "配方扫描时包含灵魂绑定的配方\n\n建议在手动定价模块中对此配方制造的物品\n设置价格（例如用于模拟订单佣金）",
        RECIPE_SCAN_INCLUDE_GEAR = "包含装备",
        RECIPE_SCAN_INCLUDE_GEAR_TOOLTIP = "配方扫描时包含所有种类装备的配方",
        RECIPE_SCAN_OPTIMIZE_TOOLS = "优化专业工具",
        RECIPE_SCAN_OPTIMIZE_TOOLS_TOOLTIP = "优化每个配方的专业工具以获取最大利润\n\n",
        RECIPE_SCAN_OPTIMIZE_TOOLS_WARNING =
        "如果背包中有很多工具\n扫描期间可能会降低游戏性能",
        RECIPE_SCAN_CRAFTER_HEADER = "制作者",
        RECIPE_SCAN_RECIPE_HEADER = "配方",
        RECIPE_SCAN_LEARNED_HEADER = "已学习",
        RECIPE_SCAN_RESULT_HEADER = "制作成品",
        RECIPE_SCAN_AVERAGE_PROFIT_HEADER = "平均利润",
        RECIPE_SCAN_CONCENTRATION_VALUE_HEADER = "专注值",
        RECIPE_SCAN_CONCENTRATION_COST_HEADER = "专注消耗",
        RECIPE_SCAN_TOP_GEAR_HEADER = "最佳装备",
        RECIPE_SCAN_INV_AH_HEADER = "库存",
        RECIPE_SCAN_SORT_BY_MARGIN = "按利润百分比排序",
        RECIPE_SCAN_SORT_BY_MARGIN_TOOLTIP =
        "根据制造成本按利润对利润列表排序。\n（需要重新扫描）",
        RECIPE_SCAN_USE_INSIGHT_CHECKBOX = "使用" .. f.bb("洞悉") .. "（如果可用）",
        RECIPE_SCAN_USE_INSIGHT_CHECKBOX_TOOLTIP = "如果配方允许，使用" ..
            f.bb("卓然洞悉") ..
            "或\n" .. f.bb("次级卓然洞悉") .. "作为附加材料。",
        RECIPE_SCAN_ONLY_FAVORITES_CHECKBOX = "仅限偏好",
        RECIPE_SCAN_ONLY_FAVORITES_CHECKBOX_TOOLTIP = "仅扫描偏好配方",
        RECIPE_SCAN_EQUIPPED = "已装备",
        RECIPE_SCAN_MODE_OPTIMIZE = "优化",
        RECIPE_SCAN_SORT_MODE_PROFIT = "利润",
        RECIPE_SCAN_SORT_MODE_RELATIVE_PROFIT = "相关利润",
        RECIPE_SCAN_SORT_MODE_CONCENTRATION_VALUE = "专注值",
        RECIPE_SCAN_SORT_MODE_CONCENTRATION_COST = "专注消耗",
        RECIPE_SCAN_SORT_MODE_CRAFTING_COST = "制造成本",
        RECIPE_SCAN_EXPANSION_FILTER_BUTTON = "资料片过滤",
        RECIPE_SCAN_CATEGORY_FILTER_BUTTON = "分类过滤",
        RECIPE_SCAN_CATEGORY_FILTER_ENABLE_ALL = "启用所有",
        RECIPE_SCAN_ALTPROFESSIONS_FILTER_BUTTON = "小号专业",
        RECIPE_SCAN_SCAN_ALL_BUTTON_READY = "扫描专业",
        RECIPE_SCAN_SCAN_ALL_BUTTON_SCANNING = "正在扫描...",
        RECIPE_SCAN_TAB_LABEL_SCAN = "配方扫描",
        RECIPE_SCAN_TAB_LABEL_OPTIONS = "扫描选项",
        RECIPE_SCAN_IMPORT_ALL_PROFESSIONS_CHECKBOX_LABEL = "所有已扫描的专业",
        RECIPE_SCAN_IMPORT_ALL_PROFESSIONS_CHECKBOX_TOOLTIP = f.g("是：") ..
            "导入所有已启用和已扫描专业的扫描结果\n\n" ..
            f.r("否：") .. "仅导入当前中选专业的扫描结果",
        RECIPE_SCAN_CACHED_RECIPES_TOOLTIP = "每当打开或扫描角色的配方时，" ..
            f.l("CraftSim") ..
            "会进行记录。\n\n只有" ..
            f.l("CraftSim") .. "可以记录的小号配方才会被" .. f.bb("配方扫描\n\n") ..
            "实际扫描的配方数量取决于" .. f.e("配方扫描选项"),
        RECIPE_SCAN_CONCENTRATION_TOGGLE = " 专注",
        RECIPE_SCAN_CONCENTRATION_TOGGLE_TOOLTIP = "开/关专注",
        RECIPE_SCAN_OPTIMIZE_SUBRECIPES = "优化子配方" .. f.bb("（实验性）"),
        RECIPE_SCAN_OPTIMIZE_SUBRECIPES_TOOLTIP = "启用后，" ..
            f.l("CraftSim") .. "还会优化已扫描配方中记录的材料配方，\n并使用其" ..
            f.bb("预期成本") .. "来计算最终成品的制造成本。\n\n" ..
            f.r("警告：可能会降低扫描性能"),
        RECIPE_SCAN_CACHED_RECIPES = "已扫描的配方：",
        RECIPE_SCAN_ENABLE_CONCENTRATION = f.bb("启用") .. f.gold("专注"),
        RECIPE_SCAN_ONLY_FAVORITES = f.r("仅限") .. f.bb("偏好"),
        RECIPE_SCAN_INCLUDE_SOULBOUND_ITEMS = "包含" .. f.e("灵魂绑定") .. "物品",
        RECIPE_SCAN_INCLUDE_UNLEARNED_RECIPES = "包含" .. f.r("未学习") .. "配方",
        RECIPE_SCAN_INCLUDE_GEAR_LABEL = "包含装备",
        RECIPE_SCAN_INV_COUNT_INCLUDE_ALTS_LABEL = "包含" .. f.bb("小号") .. "库存",
        RECIPE_SCAN_REAGENT_ALLOCATION = "材料分配",
        RECIPE_SCAN_REAGENT_ALLOCATION_Q1 = "全部1星",
        RECIPE_SCAN_REAGENT_ALLOCATION_Q2 = "全部2星",
        RECIPE_SCAN_REAGENT_ALLOCATION_Q3 = "全部3星",
        RECIPE_SCAN_AUTOSELECT_TOP_PROFIT = "自动选择" .. f.g("最高利润品质"),
        RECIPE_SCAN_OPTIMIZE_PROFESSION_GEAR = "优化" .. f.bb("专业装备"),
        RECIPE_SCAN_OPTIMIZE_CONCENTRATION = "优化" .. f.gold("专注"),
        RECIPE_SCAN_OPTIMIZE_FINISHING_REAGENTS = "优化" .. f.bb("成品材料"),

        -- Shared OptimizationOptions Widget
        OPTIMIZATION_OPTIONS_OPTIMIZE_PROFESSION_GEAR = "优化" .. f.bb("专业工具"),
        OPTIMIZATION_OPTIONS_INCLUDE_SOULBOUND_FINISHING_REAGENTS = "包含" ..
            f.e("灵魂绑定") .. f.bb("成品材料"),
        OPTIMIZATION_OPTIONS_ONLY_HIGHEST_QUALITY_SOULBOUND_FINISHING_REAGENTS = "仅限" ..
            f.g("最高品质") .. f.e("灵魂绑定") .. f.bb("成品材料"),
        OPTIMIZATION_OPTIONS_ONLY_HIGHEST_QUALITY_SOULBOUND_FINISHING_REAGENTS_TOOLTIP =
            "启用后，成品材料只会使用库存中最高品质的灵魂绑定材料。\n\n例如，背包中同时拥有" ..
            f.e("产能矩阵") ..
            "和" .. f.e("产能集管") .. "，只会使用产能集管。",
        OPTIMIZATION_OPTIONS_FINISHING_REAGENTS_ALGORITHM = f.bb("成品材料") .. "算法",
        OPTIMIZATION_OPTIONS_FINISHING_REAGENTS_SIMPLE = "简易",
        OPTIMIZATION_OPTIONS_FINISHING_REAGENTS_SIMPLE_TOOLTIP =
        "首先优化材料分配，然后专注，最后选择每个槽位的最佳成品材料。",
        OPTIMIZATION_OPTIONS_FINISHING_REAGENTS_PERMUTATION = "排列组合",
        OPTIMIZATION_OPTIONS_FINISHING_REAGENTS_PERMUTATION_TOOLTIP =
            "尝试所有可能的成品材料组合并分别优化材料和专注，最后选择利润最高的组合。\n\n" ..
            f.r("警告：可能会花费更长时间。"),

        RECIPE_SCAN_SEND_TO_CRAFT_QUEUE = "发送到制造队列",
        RECIPE_SCAN_CREATE_CRAFT_LIST = "创建制造列表",
        RECIPE_SCAN_SEND_TO_CRAFTQUEUE_CREATE_CRAFT_LIST = "改为" .. f.bb("创建制造列表"),
        RECIPE_SCAN_ADD_TO_CRAFT_LIST = f.g("添加") .. "到制造列表",
        RECIPE_SCAN_REMOVE_FROM_CRAFT_LIST = f.r("移除") .. "出制造列表",
        RECIPE_SCAN_CRAFT_LISTS_TOOLTIP_HEADER = f.bb("制造列表") .. "：",
        RECIPE_SCAN_PROFIT_MARGIN_THRESHOLD = "利润率阈值（%）：",
        RECIPE_SCAN_DEFAULT_QUEUE_AMOUNT = "默认队列数量：",
        RECIPE_SCAN_ADD_TO_CRAFT_QUEUE = "添加到制造队列",
        RECIPE_SCAN_SORT_BY = "排序方式",
        RECIPE_SCAN_SORT_ASCENDING = "升序",
        RECIPE_SCAN_REMOVE_FAVORITE = f.r("移除") .. "偏好",
        RECIPE_SCAN_ADD_FAVORITE = f.g("设置") .. "偏好",
        RECIPE_SCAN_FAVORITES_CRAFTER_ONLY = f.r("偏好只能由制作者修改"),
        RECIPE_SCAN_QUEUE_HINT = "点击" ..
            CreateAtlasMarkup("NPE_LeftClick", 20, 20, 2) .. " + Shift 将选中的配方添加到" ..
            f.bb("制造队列"),
        RECIPE_SCAN_REMOVE_CACHED_DATA = f.r("移除"),
        RECIPE_SCAN_REMOVE_CACHED_DATA_TOOLTIP = f.r("移除") ..
            "此角色-职业组合相关的所有缓存数据",
        RECIPE_SCAN_USE_TSM_RESTOCK = "使用" .. f.bb("TSM") .. "补货表达式",
        RECIPE_SCAN_TSM_SALE_RATE_THRESHOLD = f.bb("TSM") .. "售出率阈值：",
        RECIPE_SCAN_AUTOSELECT_OPEN_PROFESSION = "自动选择" .. f.bb("打开的专业"),
        RECIPE_SCAN_UPDATE_LAST_CRAFTING_COST = "更新" .. f.bb("最低制造成本") .. "数据库",
        RECIPE_SCAN_UPDATE_LAST_CRAFTING_COST_TOOLTIP = "启用后，" .. f.bb("最低制造成本") ..
            "数据库会更新每个扫描的配方。\n\n将允许通过CraftSim API查询每个物品的最新平均制造成本。",
        RECIPE_SCAN_ONLY_CRAFTLISTS_BUTTON = "仅限制造列表",
        RECIPE_SCAN_ONLY_CRAFTLISTS_TOOLTIP =
        "启用后，仅扫描选中的制造列表，忽略其他过滤器。",
        RECIPE_SCAN_CRAFTLISTS_SELECT_TITLE = "选择需要扫描的制造列表：",
        RECIPE_SCAN_CRAFTLISTS_NO_LISTS = f.grey("暂无制造列表"),
        CRAFT_LISTS_OPTIONS_TOOLTIP_HEADER = f.bb("选项") .. "：",
        CRAFT_LISTS_OPTIONS_TOOLTIP_RESTOCK_HEADER = f.bb("补货选项") .. "：",
        CRAFT_LISTS_OPTIONS_ONLY_PROFITABLE = "仅限正利润",

        -- Recipe Top Gear
        TOP_GEAR_TITLE = "CraftSim最佳装备",
        TOP_GEAR_AUTOMATIC = "自动",
        TOP_GEAR_AUTOMATIC_TOOLTIP =
        "配方更新时自动模拟所选模式的最佳装备。\n\n关闭此选项可能会提高性能。",
        TOP_GEAR_SIMULATE = "模拟最佳装备",
        TOP_GEAR_EQUIP = "装备",
        TOP_GEAR_SIMULATE_QUALITY = "品质：",
        TOP_GEAR_SIMULATE_EQUIPPED = "已装备最佳装备",
        TOP_GEAR_SIMULATE_PROFIT_DIFFERENCE = "平均利润差\n",
        TOP_GEAR_SIMULATE_NEW_MUTLICRAFT = "新产能\n",
        TOP_GEAR_SIMULATE_NEW_CRAFTING_SPEED = "新制作速度\n",
        TOP_GEAR_SIMULATE_NEW_RESOURCEFULNESS = "新充裕\n",
        TOP_GEAR_SIMULATE_NEW_SKILL = "新技能\n",
        TOP_GEAR_SIMULATE_UNHANDLED = "未处理的模拟模式",

        TOP_GEAR_SIM_MODES_PROFIT = "最高利润",
        TOP_GEAR_SIM_MODES_SKILL = "最高技能",
        TOP_GEAR_SIM_MODES_MULTICRAFT = "最高产能",
        TOP_GEAR_SIM_MODES_RESOURCEFULNESS = "最高充裕",
        TOP_GEAR_SIM_MODES_CRAFTING_SPEED = "最高制作速度",

        -- Options
        OPTIONS_TITLE = "CraftSim",
        OPTIONS_GENERAL_TAB = "常规",
        OPTIONS_GENERAL_PRICE_SOURCE = "价格来源",
        OPTIONS_GENERAL_CURRENT_PRICE_SOURCE = "当前价格来源：",
        OPTIONS_GENERAL_NO_PRICE_SOURCE = "未加载支持的价格来源插件！",
        OPTIONS_GENERAL_SHOW_PROFIT = "显示利润百分比",
        OPTIONS_GENERAL_SHOW_PROFIT_TOOLTIP = "在金钱旁显示利润占制造成本的百分比。",
        OPTIONS_GENERAL_REMEMBER_LAST_RECIPE = "记住上次的配方",
        OPTIONS_GENERAL_REMEMBER_LAST_RECIPE_TOOLTIP = "打开制造窗口时，选择上次的配方。",
        OPTIONS_GENERAL_SUPPORTED_PRICE_SOURCES = "支持的价格来源：",
        OPTIONS_GENERAL_INVENTORY_SOURCE = "库存来源",
        OPTIONS_GENERAL_CURRENT_INVENTORY_SOURCE = "当前库存来源：",
        OPTIONS_GENERAL_NO_INVENTORY_SOURCE = "未加载支持的库存来源插件！",
        OPTIONS_GENERAL_SUPPORTED_INVENTORY_SOURCES = "支持的库存来源：",
        OPTIONS_GENERAL_SHOW_TUTORIAL_BUTTONS_CHECKBOX = "显示模块教程按钮",
        OPTIONS_GENERAL_SHOW_TUTORIAL_BUTTONS_TOOLTIP = "显示每个模块的教程按钮",
        OPTIONS_PERFORMANCE_RAM = "制造时启用内存清理",
        OPTIONS_PERFORMANCE_RAM_CRAFTS = "制造",
        OPTIONS_PERFORMANCE_RAM_TOOLTIP =
        "启用后，CraftSim将在每隔指定次数的制造后清除内存中未使用的数据，以防止内存堆积。\n内存堆积也有可能是其他插件引起，而非CraftSim。\n清理操作会影响整个魔兽的内存占用。",
        OPTIONS_MODULES_TAB = "模块",
        OPTIONS_PROFIT_CALCULATION_TAB = "利润计算",
        OPTIONS_CRAFTING_TAB = "制造",
        OPTIONS_TSM_TAB = "TSM",
        OPTIONS_TSM_SECTION_TOOLTIP = "TradeSkillMaster价格字符串和CraftSim TSM增强选项。",
        OPTIONS_TSM_EXPRESSIONS_HEADER = "价格和补货表达式",
        OPTIONS_TSM_ENHANCED_HEADER = "TSM增强",
        OPTIONS_TSM_RESET = "重置默认",
        OPTIONS_TSM_INVALID_EXPRESSION = "表达式无效",
        OPTIONS_TSM_VALID_EXPRESSION = "表达式有效",
        OPTIONS_TSM_DEPOSIT_ENABLED_LABEL = "启用预期保证金成本",
        OPTIONS_TSM_DEPOSIT_ENABLED_TOOLTIP =
        "计算利润时扣除预期的拍卖行保证金成本。\n使用TSM价格数据来估算创建拍卖时需要支付的保证金。",
        OPTIONS_TSM_DEPOSIT_EXPRESSION_LABEL = "TSM保证金表达式",
        OPTIONS_TSM_SMART_RESTOCK_ENABLED_LABEL = "智能补货（减去库存）",
        OPTIONS_TSM_SMART_RESTOCK_ENABLED_TOOLTIP =
        "发送配方到制造队列时，从补货数量中减去已有的材料\n（背包，银行，小号，战团银行）。",
        OPTIONS_TSM_SMART_RESTOCK_INCLUDE_ALTS_LABEL = "包含所有小号角色",
        OPTIONS_TSM_SMART_RESTOCK_INCLUDE_WARBANK_LABEL = "包含战团银行",
        OPTIONS_MODULES_REAGENT_OPTIMIZATION = "材料优化模块",
        OPTIONS_MODULES_AVERAGE_PROFIT = "平均利润模块",
        OPTIONS_MODULES_TOP_GEAR = "最佳装备模块",
        OPTIONS_MODULES_COST_OVERVIEW = "成本概览模块",
        OPTIONS_MODULES_SPECIALIZATION_INFO = "专精信息模块",
        OPTIONS_MODULES_CUSTOMER_HISTORY_SIZE = "每位客户的历史消息上限",
        OPTIONS_MODULES_CUSTOMER_HISTORY_MAX_ENTRIES_PER_CLIENT = "每位客户的历史消息条数",
        OPTIONS_PROFIT_CALCULATION_OFFSET = "技能临界点+1",
        OPTIONS_PROFIT_CALCULATION_OFFSET_TOOLTIP =
        "材料组合建议将尝试达到临界点+1，而不是刚好满足所需的技能点数",
        OPTIONS_PROFIT_CALCULATION_MULTICRAFT_CONSTANT = "产能常数",
        OPTIONS_PROFIT_CALCULATION_MULTICRAFT_CONSTANT_EXPLANATION =
        "默认：2.5\n\n由测试服和巨龙时代早期的不同玩家收集的制造数据得出。\n单次产能触发所能获得的最大额外物品数量为1+C*y。\n其中y是单次制造的基础物品数量，C为2.5。\n有需要可以修改此常数。",
        OPTIONS_PROFIT_CALCULATION_RESOURCEFULNESS_CONSTANT = "充裕常数",
        OPTIONS_PROFIT_CALCULATION_RESOURCEFULNESS_CONSTANT_EXPLANATION =
        "默认：0.3\n\n由测试服和巨龙时代早期的不同玩家收集的制造数据得出。\n充裕平均返还的材料数量为所需的30%。\n有需要可以修改此常数。",
        OPTIONS_GENERAL_SHOW_NEWS_CHECKBOX = "显示" .. f.bb("更新信息") .. "弹窗",
        OPTIONS_GENERAL_SHOW_NEWS_CHECKBOX_TOOLTIP = "登录游戏时，显示" ..
            f.l("CraftSim") .. "的" .. f.bb("更新信息") .. "弹窗。",
        OPTIONS_GENERAL_HIDE_MINIMAP_BUTTON_CHECKBOX = "隐藏小地图按钮",
        OPTIONS_GENERAL_HIDE_MINIMAP_BUTTON_TOOLTIP = "启用后隐藏" ..
            f.l("CraftSim") .. "小地图按钮",
        OPTIONS_GENERAL_COIN_MONEY_FORMAT_CHECKBOX = "使用硬币图标：",
        OPTIONS_GENERAL_COIN_MONEY_FORMAT_TOOLTIP = "使用硬币图标显示金钱",
        OPTIONS_SETTINGS_COIN_TEXTURES_LABEL = "使用硬币图标显示金钱",
        OPTIONS_TOOLTIP_TAB = "提示信息",
        OPTIONS_TOOLTIP_SHOW_REGISTERED_CRAFTERS = "在物品提示中显示可制造的制作者",
        OPTIONS_TOOLTIP_SHOW_REGISTERED_CRAFTERS_HELP =
        "启用后，物品提示中将列出CraftSim记录中已学习此配方的角色（以及任何拥有此物品最近制造数据的角色）。",
        OPTIONS_TOOLTIP_REGISTERED_CRAFTERS_MAX = "显示的制作者上限",
        OPTIONS_TOOLTIP_REGISTERED_CRAFTERS_MAX_SUBLABEL =
        "超出上限的制作者将在名字列表后显示为数量。",

        -- Control Panel
        CONTROL_PANEL_MODULES_CRAFT_QUEUE_LABEL = "制造队列",
        CONTROL_PANEL_MODULES_CRAFT_QUEUE_TOOLTIP = "一站式添加配方队列并进行制造！",
        CONTROL_PANEL_MODULES_TOP_GEAR_LABEL = "最佳装备",
        CONTROL_PANEL_MODULES_TOP_GEAR_TOOLTIP =
        "根据所选模式，显示当前可用的最佳专业装备组合",
        CONTROL_PANEL_MODULES_COST_OVERVIEW_LABEL = "价格明细",
        CONTROL_PANEL_MODULES_COST_OVERVIEW_TOOLTIP = "根据物品品质，显示出售价格和利润概览",
        CONTROL_PANEL_MODULES_AVERAGE_PROFIT_LABEL = "平均利润",
        CONTROL_PANEL_MODULES_AVERAGE_PROFIT_TOOLTIP =
        "根据专业属性和每金币利润属性权重，显示平均利润。",
        CONTROL_PANEL_MODULES_RECIPE_INFO_LABEL = "配方信息",
        CONTROL_PANEL_MODULES_RECIPE_INFO_TOOLTIP =
        "显示配方数据，包括平均利润、属性权重以及可通过右键菜单自定义的附加信息。",
        CONTROL_PANEL_MODULES_REAGENT_OPTIMIZATION_LABEL = "材料优化",
        CONTROL_PANEL_MODULES_REAGENT_OPTIMIZATION_TOOLTIP =
        "提供最便宜材料组合达到目标品质的建议。",
        CONTROL_PANEL_MODULES_PRICE_OVERRIDES_LABEL = "手动定价",
        CONTROL_PANEL_MODULES_PRICE_OVERRIDES_TOOLTIP =
        "手动设置任何材料价格，以及所有或指定配方的制作成品价格。",
        CONTROL_PANEL_MODULES_SPECIALIZATION_INFO_LABEL = "专精信息",
        CONTROL_PANEL_MODULES_SPECIALIZATION_INFO_TOOLTIP =
        "显示专业的专精对配方的影响，可以模拟任何配置！",
        CONTROL_PANEL_MODULES_CRAFT_LOG_LABEL = "制造日志",
        CONTROL_PANEL_MODULES_CRAFT_LOG_TOOLTIP = "显示制造的日志和统计！",
        CONTROL_PANEL_MODULES_COST_OPTIMIZATION_LABEL = "定价管理",
        CONTROL_PANEL_MODULES_COST_OPTIMIZATION_TOOLTIP =
        "显示材料定价明细和制作成品概览的模块",
        CONTROL_PANEL_MODULES_STATISTICS_LABEL = "统计信息",
        CONTROL_PANEL_MODULES_STATISTICS_TOOLTIP =
        "显示当前配方详细制作成品统计信息的模块",
        CONTROL_PANEL_MODULES_RECIPE_SCAN_LABEL = "配方扫描",
        CONTROL_PANEL_MODULES_RECIPE_SCAN_TOOLTIP = "根据各种选项扫描配方列表的模块",
        CONTROL_PANEL_MODULES_CUSTOMER_HISTORY_LABEL = "客户历史",
        CONTROL_PANEL_MODULES_CUSTOMER_HISTORY_TOOLTIP =
        "提供与客户的对话历史、制造物品和佣金的模块",
        CONTROL_PANEL_MODULES_CRAFT_BUFFS_LABEL = "制造增益",
        CONTROL_PANEL_MODULES_CRAFT_BUFFS_TOOLTIP = "显示当前激活和缺失的制造增益的模块",
        CONTROL_PANEL_MODULES_EXPLANATIONS_LABEL = "原理说明",
        CONTROL_PANEL_MODULES_EXPLANATIONS_TOOLTIP = "显示" ..
            f.l("CraftSim") .. "计算原理详细说明的模块",
        CONTROL_PANEL_RESET_FRAMES = "重置框体位置",
        CONTROL_PANEL_OPTIONS = "选项",
        CONTROL_PANEL_NEWS = "更新信息",
        CONTROL_PANEL_EXPORTS = "导出",
        CONTROL_PANEL_EASYCRAFT_EXPORT = f.l("Easycraft") .. "导出",
        CONTROL_PANEL_EASYCRAFT_EXPORTING = "正在导出",
        CONTROL_PANEL_EASYCRAFT_EXPORT_NO_RECIPE_FOUND = "未找到可用于《地心之战》资料片导出的配方",
        CONTROL_PANEL_FORGEFINDER_EXPORT = f.l("ForgeFinder") .. "导出",
        CONTROL_PANEL_FORGEFINDER_EXPORTING = "正在导出",
        CONTROL_PANEL_EXPORT_EXPLANATION = f.l("wowforgefinder.com") ..
            "和" .. f.l("easycraft.io") ..
            "\n是用于搜索和提供" .. f.bb("魔兽世界制造订单") .. "的网站",
        CONTROL_PANEL_DEBUG = "调试工具",
        CONTROL_PANEL_TITLE = "控制面板",
        CONTROL_PANEL_SUPPORTERS_BUTTON = f.patreon("赞助者"),

        -- Supporters
        SUPPORTERS_DESCRIPTION = f.l("感谢这些超棒的人们！"),
        SUPPORTERS_DESCRIPTION_2 = f.l(
            "想支持CraftSim并在这里显示你的信息和留言吗？\n快加入社区吧！"),
        SUPPORTERS_DATE = "日期",
        SUPPORTERS_SUPPORTER = "赞助者",
        SUPPORTERS_MESSAGE = "留言",

        -- Customer History
        CUSTOMER_HISTORY_TITLE = "CraftSim客户历史",
        CUSTOMER_HISTORY_DROPDOWN_LABEL = "选择一位客户",
        CUSTOMER_HISTORY_TOTAL_TIP = "总佣金：",
        CUSTOMER_HISTORY_FROM = "来自",
        CUSTOMER_HISTORY_TO = "给",
        CUSTOMER_HISTORY_FOR = "给",
        CUSTOMER_HISTORY_CRAFT_FORMAT = "已制造%s给%s",
        CUSTOMER_HISTORY_DELETE_BUTTON = "移除客户",
        CUSTOMER_HISTORY_WHISPER_BUTTON_LABEL = "密语..",
        CUSTOMER_HISTORY_PURGE_NO_TIP_LABEL = "移除0佣金客户",
        CUSTOMER_HISTORY_PURGE_ZERO_TIPS_CONFIRMATION_POPUP =
        "确定要删除\n所有总佣金为0的客户数据？",
        CUSTOMER_HISTORY_DELETE_CUSTOMER_CONFIRMATION_POPUP = "确定要删除\n%s的所有数据？",
        CUSTOMER_HISTORY_PURGE_DAYS_INPUT_LABEL = "自动移除间隔（天）",
        CUSTOMER_HISTORY_PURGE_DAYS_INPUT_TOOLTIP =
        "当距离上次移除超过X天后，登录时CraftSim将自动移除所有低于设定佣金阈值的客户。\n设为0则CraftSim将永远不会自动移除。",
        CUSTOMER_HISTORY_CUSTOMER_HEADER = "客户",
        CUSTOMER_HISTORY_TOTAL_TIP_HEADER = "总佣金",
        CUSTOMER_HISTORY_CRAFT_HISTORY_DATE_HEADER = "日期",
        CUSTOMER_HISTORY_CRAFT_HISTORY_RESULT_HEADER = "制作成品",
        CUSTOMER_HISTORY_CRAFT_HISTORY_TIP_HEADER = "佣金",
        CUSTOMER_HISTORY_CRAFT_HISTORY_CUSTOMER_REAGENTS_HEADER = "客户材料",
        CUSTOMER_HISTORY_CRAFT_HISTORY_CUSTOMER_NOTE_HEADER = "备注",
        CUSTOMER_HISTORY_CHAT_MESSAGE_TIMESTAMP = "时间戳",
        CUSTOMER_HISTORY_CHAT_MESSAGE_SENDER = "发送者",
        CUSTOMER_HISTORY_CHAT_MESSAGE_MESSAGE = "消息",
        CUSTOMER_HISTORY_CHAT_MESSAGE_YOU = "[你]：",
        CUSTOMER_HISTORY_CRAFT_LIST_TIMESTAMP = "时间戳",
        CUSTOMER_HISTORY_CRAFT_LIST_RESULTLINK = "制作成品链接",
        CUSTOMER_HISTORY_CRAFT_LIST_TIP = "佣金",
        CUSTOMER_HISTORY_CRAFT_LIST_REAGENTS = "材料",
        CUSTOMER_HISTORY_CRAFT_LIST_SOMENOTE = "备注",
        CUSTOMER_HISTORY_TOTAL_AMOUNT = "总计",
        CUSTOMER_HISTORY_CATEGORY_ENABLE_HISTORY_RECORDING = f.bb("启用") .. f.gold("历史记录"),
        CUSTOMER_HISTORY_CATEGORY_RECORD_PATRON_ORDERS = "记录" .. f.bb("客人订单"),
        CUSTOMER_HISTORY_CATEGORY_REMOVE_CUSTOMERS = "移除客户",
        CUSTOMER_HISTORY_CATEGORY_AUTO_REMOVAL = "自动移除",
        CUSTOMER_HISTORY_CATEGORY_REMOVE_BELOW_THRESHOLD = f.l("移除低于阈值"),
        CUSTOMER_HISTORY_CATEGORY_REMOVE_ALL_CUSTOMERS = f.r("移除所有客户"),
        CUSTOMER_HISTORY_CATEGORY_REMOVE_ALL_CUSTOMER_DATA = f.r("确定移除所有客户数据？"),
        CUSTOMER_HISTORY_CATEGORY_DELETE_CUSTOMER = "删除客户",

        -- Craft Queue
        CRAFT_QUEUE_TITLE = "CraftSim制造队列",
        CRAFT_QUEUE_CRAFT_AMOUNT_LEFT_HEADER = "待制造",
        CRAFT_QUEUE_CRAFT_PROFESSION_GEAR_HEADER = "工具",
        CRAFT_QUEUE_CRAFTING_COSTS_HEADER = "制造成本",
        CRAFT_QUEUE_CRAFT_BUTTON_ROW_LABEL = "制造",
        CRAFT_QUEUE_CRAFT_BUTTON_ROW_LABEL_WRONG_GEAR = "工具不符",
        CRAFT_QUEUE_CRAFT_BUTTON_ROW_LABEL_NO_REAGENTS = "没有材料",
        CRAFT_QUEUE_ADD_OPEN_RECIPE_BUTTON_LABEL = "添加当前配方到队列",
        CRAFT_QUEUE_ADD_FIRST_CRAFTS_BUTTON_LABEL = "添加首次制造到队列",
        CRAFT_QUEUE_ADD_WORK_ORDERS_BUTTON_LABEL = "添加制造订单到队列",
        CRAFT_QUEUE_ADD_WORK_ORDERS_ALLOW_CONCENTRATION_CHECKBOX = "允许使用" .. f.gold("专注"),
        CRAFT_QUEUE_ADD_WORK_ORDERS_ALLOW_CONCENTRATION_TOOLTIP =
            "如果无法达到最低品质，则尽可能使用" .. f.l("专注"),
        CRAFT_QUEUE_ADD_WORK_ORDERS_ONLY_PROFITABLE_CHECKBOX = "仅限" .. f.g("正利润"),
        CRAFT_QUEUE_ADD_WORK_ORDERS_ONLY_PROFITABLE_TOOLTIP = "仅添加预期利润为正的制造订单到队列",
        CRAFT_QUEUE_WORK_ORDER_TYPE_BUTTON = "制造订单类型",
        CRAFT_QUEUE_ADD_WORK_ORDERS_AUTO_QUEUE_CHECKBOX = f.g("自动添加") .. f.bb("制造订单"),
        CRAFT_QUEUE_ADD_WORK_ORDERS_AUTO_QUEUE_TOOLTIP =
        "登录后首次打开专业界面时，自动添加制造订单到队列",
        CRAFT_QUEUE_PATRON_ORDERS_BUTTON = "客人订单",
        CRAFT_QUEUE_GUILD_ORDERS_BUTTON = "公会订单",
        CRAFT_QUEUE_PERSONAL_ORDERS_BUTTON = "个人订单",
        CRAFT_QUEUE_PUBLIC_ORDERS_BUTTON = "公开订单",
        CRAFT_QUEUE_PUBLIC_ORDERS_MAX_COUNT = f.b("公开订单") .. "最大数量：",
        CRAFT_QUEUE_PUBLIC_ORDERS_MAX_COUNT_TOOLTIP =
            "添加到队列的公开订单最大数量，按利润从高到低排序。\n\n设置为" ..
            f.bb("0") .. "将使用当前可用的公开次数。",
        CRAFT_QUEUE_GUILD_ORDERS_ALTS_ONLY_CHECKBOX = f.r("仅限") .. "小号角色",
        CRAFT_QUEUE_PATRON_ORDERS_FORCE_CONCENTRATION_CHECKBOX = f.r("强制") .. f.gold("使用专注"),
        CRAFT_QUEUE_PATRON_ORDERS_FORCE_CONCENTRATION_TOOLTIP =
        "尽可能强制为所有客人订单使用专注",
        CRAFT_QUEUE_PATRON_ORDERS_SPARK_RECIPES_CHECKBOX = "包含" .. f.e("火花") .. "配方",
        CRAFT_QUEUE_PATRON_ORDERS_SPARK_RECIPES_TOOLTIP = "包含使用火花作为材料的订单",
        CRAFT_QUEUE_PATRON_ORDERS_ACUITY_CHECKBOX = "包含" .. f.bb("匠人之敏/匠人之魄") .. "奖励",
        CRAFT_QUEUE_PATRON_ORDERS_ACUITY_TOOLTIP = "包含匠人之敏/匠人之魄作为奖励的订单",
        CRAFT_QUEUE_PATRON_ORDERS_POWER_RUNE_CHECKBOX = "包含" .. f.bb("强化符文") .. "奖励",
        CRAFT_QUEUE_PATRON_ORDERS_POWER_RUNE_TOOLTIP = "包含有强化符文作为奖励的订单",
        CRAFT_QUEUE_PATRON_ORDERS_KNOWLEDGE_POINTS_CHECKBOX = "包含" .. f.bb("专业知识") .. "奖励",
        CRAFT_QUEUE_PATRON_ORDERS_KNOWLEDGE_POINTS_TOOLTIP = "包含专业知识作为奖励的订单",
        CRAFT_QUEUE_PATRON_ORDERS_KNOWLEDGE_POINTS_MAX_COST = f.bb("专业知识") .. "最大成本：",
        CRAFT_QUEUE_PATRON_ORDERS_KNOWLEDGE_POINTS_MAX_COST_TOOLTIP =
        "每1点专业知识允许的最大成本\n\n格式：",
        CRAFT_QUEUE_PATRON_ORDERS_MAX_COST = f.bb("客人订单") .. "最大成本：",
        CRAFT_QUEUE_PATRON_ORDERS_MAX_COST_TOOLTIP = "每个客人订单允许的最大成本\n\n格式：",
        CRAFT_QUEUE_PATRON_ORDERS_REAGENT_BAG_VALUE = f.bb("材料包") .. "价值：",
        CRAFT_QUEUE_PATRON_ORDERS_REAGENT_BAG_VALUE_TOOLTIP = "将" ..
            f.bb("材料包奖励") .. "的价值计算到利润中。\n\n格式：",
        CRAFT_QUEUE_PATRON_ORDERS_INCLUDE_MOXIE_IN_PROFIT_CHECKBOX = "将" .. f.bb("匠人之魄") .. "计算到预期利润",
        CRAFT_QUEUE_PATRON_ORDERS_INCLUDE_MOXIE_IN_PROFIT_TOOLTIP = "启用后，" ..
            f.bb("客人订单") ..
            "和首次制造奖励的" ..
            f.bb("匠人之魄") ..
            "将根据下方设置的价值添加到预期利润中。禁用后仅显示为提示信息。",
        CRAFT_QUEUE_PATRON_ORDERS_AUTO_UPDATE_MOXIE_VALUES_CHECKBOX = "自动更新匠人之魄价值",
        CRAFT_QUEUE_PATRON_ORDERS_AUTO_UPDATE_MOXIE_VALUES_TOOLTIP =
        "启用后，CraftSim会在配方价格刷新时重新计算匠人之魄的价值，仅覆盖计算值改变的条目。",
        CRAFT_QUEUE_PATRON_ORDERS_MOXIE_VALUE_TOOLTIP = "在提示信息中显示此专业每个" ..
            f.bb("匠人之魄") ..
            "奖励的价值；当启用" ..
            f.bb("将匠人之魄计算到预期利润") ..
            "后也会用于计算预期利润。\n\n格式：",
        CRAFT_QUEUE_PATRON_REWARD_VALUES_TITLE = "匠人之魄价值",
        CRAFT_QUEUE_PATRON_REWARD_VALUES_MENU_BUTTON = "设置匠人之魄价值",
        CRAFT_QUEUE_PATRON_REWARD_VALUES_INTRO = "设置所有专业每个" ..
            f.bb("匠人之魄") ..
            "的价值；同一行的分组共享同一个值，当启用" ..
            f.bb("将匠人之魄计算到预期利润") ..
            "后会用于计算预期利润。",
        CRAFT_QUEUE_PATRON_MOXIE_SURPLUS_SUGGEST_TOOLTIP = "根据价格来源，计算至暗之夜兑换" ..
            f.bb("XX大师的盈余材料") ..
            "的平均产出（2星材料价格），得出每个" ..
            f.bb("匠人之魄") ..
            "的建议价值。\n\n" ..
            f.g("左键点击") ..
            "设置为当前值。",
        CRAFT_QUEUE_PATRON_MOXIE_SURPLUS_NO_DATA_TOOLTIP =
        "此专业无盈余材料、无价格来源，或者所有列出的材料价格为0。",
        CRAFT_QUEUE_PATRON_MOXIE_VALUES_HEADER_MOXIE = "匠人之魄",
        CRAFT_QUEUE_PATRON_MOXIE_VALUES_HEADER_ITEMS = "可能的材料",
        CRAFT_QUEUE_PATRON_MOXIE_VALUES_HEADER_CURRENT = "当前",
        CRAFT_QUEUE_PATRON_MOXIE_VALUES_HEADER_SUGGESTED = "建议",
        CRAFT_QUEUE_PATRON_MOXIE_SURPLUS_TT_REAGENT_TOTAL = "材料（预期）",
        CRAFT_QUEUE_PATRON_MOXIE_SURPLUS_TT_PER_MOXIE = "每个" .. f.bb("匠人之魄"),
        PATRON_MOXIE_SURPLUS_BAG_ITEM_TOOLTIP_EXPECTED_VALUE = "预期价值",
        CRAFT_QUEUE_CLEAR_ALL_BUTTON_LABEL = "全部清除",
        CRAFT_QUEUE_RESTOCK_FAVORITES_SMART_CONCENTRATION_QUEUING = f.bb("智能") ..
            f.gold("专注") .. f.bb("队列"),
        CRAFT_QUEUE_RESTOCK_FAVORITES_SMART_CONCENTRATION_QUEUING_TOOLTIP = "启用后，" ..
            f.l("CraftSim") ..
            "会确定" ..
            f.g("专注利润最高") ..
            "的配方，然后添加可制造的最大次数到制造队列。",
        CRAFT_QUEUE_RESTOCK_FAVORITES_OFFSET_CONCENTRATION_CRAFT_AMOUNT = "调整" ..
            f.gold("专注") .. f.bb("队列次数"),
        CRAFT_QUEUE_RESTOCK_FAVORITES_OFFSET_CONCENTRATION_CRAFT_AMOUNT_TOOLTIP =
            "启用后，专注制造将根据" ..
            f.bb("奇思") .. "调整预期制造的最大次数",
        CRAFT_QUEUE_RESTOCK_FAVORITES_QUEUE_MAIN_PROFESSIONS = "添加" .. f.bb("当前角色专业") .. "到队列",
        CRAFT_QUEUE_RESTOCK_FAVORITES_QUEUE_MAIN_PROFESSIONS_TOOLTIP =
            "启用后，CraftSim将同时处理当前角色的两种专业",
        CRAFT_QUEUE_RESTOCK_FAVORITES_OFFSET_QUEUE_AMOUNT_LABEL = "额外队列次数：",
        CRAFT_QUEUE_RESTOCK_FAVORITES_OFFSET_QUEUE_AMOUNT_TOOLTIP =
            "添加到队列时始终增加指定的额外次数",
        CRAFT_QUEUE_RESTOCK_FAVORITES_AUTO_SHOPPING_LIST = "添加到队列后" .. f.g("自动创建") ..
            f.bb("购物清单"),
        CRAFT_QUEUE_CRAFT_BUTTON_ROW_LABEL_WRONG_PROFESSION = "专业不符",
        CRAFT_QUEUE_CRAFT_BUTTON_ROW_LABEL_ON_COOLDOWN = "冷却中",
        RECIPE_COOLDOWN_CHARGES_INLINE = "（%d/%d）",
        RECIPE_COOLDOWN_CHARGES_TOOLTIP = "冷却充能：%d/%d",
        CRAFT_QUEUE_CRAFT_BUTTON_ROW_LABEL_WRONG_CRAFTER = "制作者不符",
        CRAFT_QUEUE_RECIPE_REQUIREMENTS_HEADER = "状态",
        CRAFT_QUEUE_RECIPE_REQUIREMENTS_TOOLTIP = "必须满足所有条件才能制作配方",
        CRAFT_QUEUE_STATUS_CANNOT_CRAFT_FALLBACK = "无法制造",
        CRAFT_QUEUE_RESULT_FIRST_CRAFT_TOOLTIP_TITLE = "首次制造",
        CRAFT_QUEUE_RESULT_FIRST_CRAFT_TOOLTIP =
            "首次制造此配方时增加1点专业知识。（仅" ..
            f.bb("客人订单") ..
            "奖励的匠人之魄才会在启用" ..
            f.bb("将匠人之魄计算到预期利润") ..
            "后用于计算预期利润。）",
        CRAFT_QUEUE_FIRST_CRAFT_MOXIE_GOLD_TOOLTIP = "同时获得10个匠人之魄（价值%s）",
        CRAFT_QUEUE_MOXIE_GOLD_IN_TOOLTIP = "（价值%s）",
        CRAFT_QUEUE_CRAFT_NEXT_BUTTON_LABEL = "制造下一个",
        CRAFT_QUEUE_CRAFT_AVAILABLE_AMOUNT = "最大次数",
        CRAFT_QUEUE_SHATTER_MOTE_AUTOMATIC = "自动（最便宜）",
        CRAFT_QUEUE_SHATTER_MOTE_AUTOMATIC_OWNED = "自动（已有最便宜）",
        CRAFT_QUEUE_SHATTER_RIGHT_CLICK_HINT = "\n右键点击选择微粒",
        CRAFTQUEUE_AUCTIONATOR_SHOPPING_LIST_BUTTON_LABEL = "创建Auctionator购物清单",
        CRAFT_QUEUE_QUEUE_TAB_LABEL = "制造队列",
        CRAFT_QUEUE_FLASH_TASKBAR_OPTION_LABEL =
            f.bb("制造队列") .. "完成时闪烁任务栏",
        CRAFT_QUEUE_FLASH_TASKBAR_OPTION_TOOLTIP =
            "当魔兽世界窗口最小化，且" .. f.bb("制造队列") ..
            "中的配方制造完成时，" .. f.l(" CraftSim") .. "将闪烁任务栏中魔兽世界图标",
        CRAFT_QUEUE_RESTOCK_OPTIONS_TAB_LABEL = "补货选项",
        CRAFT_QUEUE_RESTOCK_OPTIONS_TAB_TOOLTIP = "配置从配方扫描导入时的补货行为",
        CRAFT_QUEUE_RESTOCK_OPTIONS_GENERAL_PROFIT_THRESHOLD_LABEL = "利润阈值：",
        CRAFT_QUEUE_RESTOCK_OPTIONS_SALE_RATE_INPUT_LABEL = "售出率阈值：",
        CRAFT_QUEUE_RESTOCK_OPTIONS_TSM_SALE_RATE_TOOLTIP = string.format(
            [[
仅在已加载%s时可用！

这将检查%s指定品质物品的售出率
是否大于或等于设置的售出率阈值。
]], f.bb("TSM"), f.bb("任何")),
        CRAFT_QUEUE_RESTOCK_OPTIONS_TSM_SALE_RATE_TOOLTIP_GENERAL = string.format(
            [[
仅在已加载%s时可用！

这将检查%s品质物品的售出率
是否大于或等于设置的售出率阈值。
]], f.bb("TSM"), f.bb("任何")),
        CRAFT_QUEUE_RESTOCK_OPTIONS_AMOUNT_LABEL = "补货数量：",
        CRAFT_QUEUE_RESTOCK_OPTIONS_RESTOCK_TOOLTIP = "这是此配方将添加到队列的" ..
            f.bb("待制造次数") ..
            "。\n\n补货数量将减去背包和银行中已有的对应品质材料",
        CRAFT_QUEUE_RESTOCK_OPTIONS_ENABLE_RECIPE_LABEL = "启用：",
        CRAFT_QUEUE_RESTOCK_OPTIONS_GENERAL_OPTIONS_LABEL = "常规选项（所有配方）",
        CRAFT_QUEUE_RESTOCK_OPTIONS_ENABLE_RECIPE_TOOLTIP =
        "如果此选项为关闭，将根据上述的一般选项进补货",
        CRAFT_QUEUE_TOTAL_PROFIT_LABEL = "总平均利润：",
        CRAFT_QUEUE_TOTAL_CRAFTING_COSTS_LABEL = "总制造成本：",
        CRAFT_QUEUE_EDIT_RECIPE_TITLE = "编辑配方",
        CRAFT_QUEUE_EDIT_RECIPE_NAME_LABEL = "配方名称",
        CRAFT_QUEUE_EDIT_RECIPE_REAGENTS_SELECT_LABEL = "选择",
        CRAFT_QUEUE_EDIT_RECIPE_OPTIONAL_REAGENTS_LABEL = "附加材料",
        CRAFT_QUEUE_EDIT_RECIPE_FINISHING_REAGENTS_LABEL = "成品材料",
        CRAFT_QUEUE_EDIT_RECIPE_SPARK_LABEL = "必须",
        CRAFT_QUEUE_EDIT_RECIPE_PROFESSION_GEAR_LABEL = "专业装备",
        CRAFT_QUEUE_EDIT_RECIPE_OPTIMIZE_PROFIT_BUTTON = "优化",
        CRAFT_QUEUE_EDIT_RECIPE_CRAFTING_COSTS_LABEL = "制造成本：",
        CRAFT_QUEUE_EDIT_RECIPE_AVERAGE_PROFIT_LABEL = "平均利润：",
        CRAFT_QUEUE_EDIT_RECIPE_RESULTS_LABEL = "制作成品",
        CRAFT_QUEUE_EDIT_RECIPE_CONCENTRATION_CHECKBOX = "专注",
        CRAFT_QUEUE_AUCTIONATOR_SHOPPING_LIST_PER_CHARACTER_CHECKBOX = "每个角色",
        CRAFT_QUEUE_AUCTIONATOR_SHOPPING_LIST_PER_CHARACTER_CHECKBOX_TOOLTIP = "为每个制作者分别创建一份" ..
            f.bb("Auctionator购物清单") .. "，\n而非共享同一份购物清单。",
        CRAFT_QUEUE_AUCTIONATOR_SHOPPING_LIST_TARGET_MODE_CHECKBOX = "仅限指定",
        CRAFT_QUEUE_AUCTIONATOR_SHOPPING_LIST_TARGET_MODE_CHECKBOX_TOOLTIP = "仅为指定配方创建一份 " ..
            f.bb("Auctionator购物清单") .. "。",
        CRAFT_QUEUE_UNSAVED_CHANGES_TOOLTIP = f.white("未保存的队列数量。\n按回车保存"),
        CRAFT_QUEUE_STATUSBAR_LEARNED = f.white("已学习配方"),
        CRAFT_QUEUE_STATUSBAR_COOLDOWN = f.white("未处于冷却状态"),
        CRAFT_QUEUE_STATUSBAR_REAGENTS = f.white("材料可用"),
        CRAFT_QUEUE_STATUSBAR_GEAR = f.white("已装备专业装备"),
        CRAFT_QUEUE_STATUSBAR_CRAFTER = f.white("制作者符合"),
        CRAFT_QUEUE_STATUSBAR_PROFESSION = f.white("已打开专业"),
        CRAFT_QUEUE_BUTTON_EDIT = "编辑",
        CRAFT_QUEUE_BUTTON_CRAFT = "制造",
        CRAFT_QUEUE_BUTTON_CLAIM = "接单",
        CRAFT_QUEUE_BUTTON_CLAIMED = "已接单",
        CRAFT_QUEUE_BUTTON_NEXT = "下一步：",
        CRAFT_QUEUE_BUTTON_NOTHING_QUEUED = "空闲队列",
        CRAFT_QUEUE_BUTTON_ORDER = "订单",
        CRAFT_QUEUE_BUTTON_SUBMIT = "交单",
        CRAFT_QUEUE_BUTTON_EQUIP_TOOLS = "装备",
        CRAFT_QUEUE_BUTTON_SHATTER = "粉碎",
        CRAFT_QUEUE_STATUS_SHATTER_BUFF = "未激活碎裂精华增益",
        CRAFT_QUEUE_STATUS_SHATTER_AFTER_LOGIN = "登陆后需要重新粉碎",
        CRAFT_QUEUE_SHATTER_TOOLTIP_AFTER_LOGIN = shatter_post_login_tooltip,
        CRAFT_QUEUE_SHATTER_TOOLTIP_MISSING_BUFF = "\n\n" ..
            f.white("施放粉碎以获得碎裂精华。"),
        CRAFT_QUEUE_SHATTER_TOOLTIP_STALE_AND_MISSING = "\n\n" ..
            f.white("未激活碎裂精华。请施放粉碎以激活并同步登录状态。"),
        CRAFT_QUEUE_IGNORE_ACUITY_RECIPES_CHECKBOX_LABEL = "忽略匠人之敏配方",
        CRAFT_QUEUE_IGNORE_ACUITY_RECIPES_CHECKBOX_TOOLTIP =
            "不要把首次制造需要" .. f.bb("匠人之敏") .. "的配方添加到制造队列",
        CRAFT_QUEUE_AMOUNT_TOOLTIP = "\n\n待制造次数：",
        CRAFT_QUEUE_ORDER_CUSTOMER = "\n\n订单发布人：",
        CRAFT_QUEUE_ORDER_MINIMUM_QUALITY = "\n最低品质：",
        CRAFT_QUEUE_ORDER_REWARDS = "\n奖励：",
        CRAFT_QUEUE_RESTOCK_FAVORITES_OPTIONS_AUTO_SHOPPING_LIST =
        "启用后，CraftSim将在添加到队列后自动创建购物清单。",
        CRAFT_QUEUE_IGNORE_SPARK_RECIPES_CHECKBOX_LABEL = "忽略" .. f.e("火花") .. "配方",
        CRAFT_QUEUE_IGNORE_SPARK_RECIPES_CHECKBOX_TOOLTIP = "忽略需要火花材料的配方",
        CRAFT_QUEUE_MENU_AUTO_SHOW = "添加配方到队列后" .. f.g("自动打开"),
        CRAFT_QUEUE_MENU_INGENUITY_IGNORE = f.r("忽略") .. f.gold("奇思触发") .. "时减少待制造次数",
        CRAFT_QUEUE_MENU_DEQUEUE_CONCENTRATION = f.gold("专注") .. "耗尽时" .. f.r("移除"),
        CRAFT_QUEUE_MENU_DEQUEUE_CONCENTRATION_TOOLTIP =
        "剩余专注无法继续制造时，自动移除已制作的配方。",
        CRAFT_QUEUE_MENU_MIDNIGHT_SHATTER_FORCE_BUFF = f.gold("强制") .. "至暗之夜" ..
            f.bb("碎裂精华") .. "增益",
        CRAFT_QUEUE_MENU_MIDNIGHT_SHATTER_FORCE_BUFF_TOOLTIP = "启用后，CraftSim将要求在制造附魔配方前激活" ..
            f.bb("碎裂精华") .. "增益。\n\n" ..
            "粉碎按钮将显示在按钮序列中，优化配方时会假设此增益已激活。\n\n" ..
            "禁用后，完全跳过粉碎步骤，优化时不考虑此增益。",
        CRAFT_QUEUE_MENU_TWW_ENCHANT_SHATTER_FORCE_BUFF = f.gold("强制") ..
            "地心之战" ..
            f.bb("碎裂精华") .. "附魔增益",
        CRAFT_QUEUE_MENU_TWW_ENCHANT_SHATTER_FORCE_BUFF_TOOLTIP = "启用后，CraftSim将要求在制造地心之战附魔配方前激活" ..
            f.bb("碎裂精华") .. "增益。\n\n" ..
            "粉碎按钮将显示在按钮序列中，优化配方时会假设此增益已激活。\n\n" ..
            "禁用后，完全跳过粉碎步骤，优化时不考虑此增益。",
        CRAFT_QUEUE_MENU_EVERBURNING_IGNITION_FORCE_BUFF = f.gold("强制") .. "地心之战" ..
            f.bb("永燃点火装置") .. "锻造增益",
        CRAFT_QUEUE_MENU_EVERBURNING_IGNITION_FORCE_BUFF_TOOLTIP = "启用后，CraftSim将在优化地心之战锻造配方时始终假设" ..
            f.bb("永燃点火装置") ..
            "增益已激活。\n\n" ..
            "不会在队列中添加类似粉碎的前置条件。",
        CRAFT_QUEUE_TUTORIAL_QUEUE_LIST_TOOLTIP =
        "这里显示队列中的配方。\n左键点击跳转配方\n右键点击显示菜单\n中键点击删除配方",
        CRAFT_QUEUE_TUTORIAL_CRAFT_NEXT_TOOLTIP = "点击“下一步：制造”来制造第一个可制作的配方",
        CRAFT_QUEUE_TUTORIAL_QUEUE_BUTTONS_TOOLTIP =
        "这些按钮可以自动添加一系列配方到队列。\n制造列表是预设的配方列表\n首次制造是包含首次制造奖励的配方\n制造订单可以是客人、公会、个人或公开订单，会根据筛选条件添加到队列",
        CRAFT_QUEUE_TUTORIAL_SHOPPING_LIST_TOOLTIP =
        "如果已加载Auctionator插件，可以点击按钮创建一份包含配方缺少材料的购物清单。",
        CRAFT_QUEUE_TUTORIAL_QUICK_ACCESS_BAR_TOOLTIP =
        "这里显示可升级的灵魂绑定成品材料（客人订单奖励）。附魔会有一个碎裂精华的额外按钮",
        CRAFT_QUEUE_TUTORIAL_CRAFT_QUEUE_OPTIONS_TOOLTIP =
        "这里可以找到配置制造队列的常规选项",
        -- craft lists
        CRAFT_LISTS_TAB_LABEL = "制造列表",
        CRAFT_LISTS_QUEUE_BUTTON_LABEL = "添加制造列表到队列",
        CRAFT_LISTS_CREATE_BUTTON_LABEL = "创建",
        CRAFT_LISTS_DELETE_BUTTON_LABEL = f.r("删除"),
        CRAFT_LISTS_RENAME_BUTTON_LABEL = "重命名",
        CRAFT_LISTS_ADD_RECIPE_BUTTON_LABEL = "添加当前配方",
        CRAFT_LISTS_REMOVE_RECIPE_BUTTON_LABEL = f.r("移除"),
        CRAFT_LISTS_EXPORT_BUTTON_LABEL = "导出",
        CRAFT_LISTS_IMPORT_BUTTON_LABEL = "导入",
        CRAFT_LISTS_LIST_NAME_HEADER = "列表名称",
        CRAFT_LISTS_LIST_TYPE_HEADER = "作用范围",
        CRAFT_LISTS_RECIPE_NAME_HEADER = "配方",
        CRAFT_LISTS_GLOBAL_LABEL = f.bb("全局"),
        CRAFT_LISTS_CHARACTER_LABEL = f.g("角色"),
        CRAFT_LISTS_NEW_LIST_DEFAULT_NAME = "新列表",
        CRAFT_LISTS_RENAME_POPUP_TITLE = "重命名制造列表",
        CRAFT_LISTS_CREATE_POPUP_TITLE = "创建制造列表",
        CRAFT_LISTS_EXPORT_POPUP_TITLE = "导出制造列表",
        CRAFT_LISTS_IMPORT_POPUP_TITLE = "导入制造列表",
        CRAFT_LISTS_OPTIONS_ENABLE_CONCENTRATION = "启用专注",
        CRAFT_LISTS_OPTIONS_OPTIMIZE_CONCENTRATION = "优化专注",
        CRAFT_LISTS_OPTIONS_SMART_CONCENTRATION = f.bb("智能") .. "专注" .. f.bb("队列"),
        CRAFT_LISTS_OPTIONS_SMART_CONCENTRATION_TOOLTIP =
        "添加每点专注利润最高的配方到队列，尽可能耗尽专注",
        CRAFT_LISTS_OPTIONS_OFFSET_CONCENTRATION = "调整专注" .. f.bb("队列次数"),
        CRAFT_LISTS_OPTIONS_OFFSET_CONCENTRATION_TOOLTIP =
            "启用后，专注制造将根据" ..
            f.bb("奇思") .. "调整预期制造的最大次数",
        CRAFT_LISTS_OPTIONS_OPTIMIZE_TOOLS = "优化专业工具",
        CRAFT_LISTS_OPTIONS_TOP_PROFIT_QUALITY = "自动选择最高利润品质",
        CRAFT_LISTS_OPTIONS_OPTIMIZE_FINISHING = "优化成品材料",
        CRAFT_LISTS_OPTIONS_INCLUDE_SOULBOUND = "包含" .. f.e("灵魂绑定") .. f.bb("成品材料"),
        CRAFT_LISTS_OPTIONS_REAGENT_ALLOCATION = "材料分配",
        CRAFT_LISTS_OPTIONS_REAGENT_ALLOCATION_OPTIMIZE_HIGHEST = "最高品质",
        CRAFT_LISTS_OPTIONS_REAGENT_ALLOCATION_OPTIMIZE_MOST_PROFITABLE = "最高利润品质",
        CRAFT_LISTS_OPTIONS_REAGENT_ALLOCATION_TARGET_QUALITY = "目标品质",
        CRAFT_LISTS_OPTIONS_ENABLE_UNLEARNED = "启用" .. f.r("未学习") .. "配方",
        CRAFT_LISTS_OPTIONS_USE_TSM_RESTOCK = "使用" .. f.bb("TSM") .. "补货表达式",
        CRAFT_LISTS_OPTIONS_TSM_EXPRESSION = "表达式：",
        CRAFT_LISTS_OPTIONS_USE_CURRENT_CHARACTER = "当前角色制造",
        CRAFT_LISTS_OPTIONS_FIXED_CRAFTER = "固定制作者：",
        CRAFT_LISTS_OPTIONS_RESTOCK_AMOUNT = "补货数量：",
        CRAFT_LISTS_OPTIONS_OFFSET_QUEUE_AMOUNT = "额外队列次数：",
        CRAFT_LISTS_OPTIONS_OFFSET_QUEUE_AMOUNT_TOOLTIP = "添加到队列时始终增加指定的额外次数",
        CRAFT_LISTS_RESTOCK_SUBTRACT_OWNED_LABEL = "补货时减去已有材料",
        CRAFT_LISTS_RESTOCK_SUBTRACT_OWNED_TOOLTIP =
        "启用后，制造列表补货时仅添加max(0, 目标数量 - 已有数量)到清单。\n\n禁用后将无视库存，始终添加目标数量。",
        CRAFT_LISTS_RESTOCK_INCLUDE_ALT_INVENTORY_LABEL = "包含" .. f.bb("小号") .. "库存",
        CRAFT_LISTS_RESTOCK_INCLUDE_ALT_INVENTORY_TOOLTIP =
        "启用后，补货目标也会减去小号库存中的已有数量。",
        CRAFT_LISTS_OPTIONS_AUTO_SHOPPING_LIST = "添加到队列后自动创建购物清单",
        CRAFT_LISTS_OPTIONS_UPDATE_LAST_CRAFTING_COST = "更新" .. f.bb("最低制造成本") .. "数据库",
        CRAFT_LISTS_OPTIONS_UPDATE_LAST_CRAFTING_COST_TOOLTIP = "启用后，" .. f.bb("最低制造成本") ..
            "数据库会更新每个添加到队列的配方。\n\n将允许通过CraftSim API查询每个物品的最新平均制造成本。",
        CRAFT_LISTS_NO_LIST_SELECTED = f.grey("未选择列表"),
        CRAFT_LISTS_SELECT_LIST_HINT = f.grey("选择一个列表查看配方"),
        CRAFT_LISTS_RECIPE_RESTOCK_SET_MAX = "补货：",
        CRAFT_LISTS_RECIPE_RESTOCK_TAG = "补货",
        CRAFT_LISTS_RECIPE_RESTOCK_POPUP_TITLE = "补货目标（0 = 关闭）",
        CRAFT_LISTS_RECIPE_RESTOCK_POPUP_HINT = f.grey("设置为0可禁用此配方的补货"),

        -- craft buffs

        CRAFT_BUFFS_TITLE = "CraftSim制造增益",
        CRAFT_BUFFS_SIMULATE_BUTTON = "模拟增益效果",
        CRAFT_BUFF_CHEFS_HAT_TOOLTIP = f.bb("巫妖王之怒玩具") ..
            "\n需要诺森德烹饪\n将制作速度设置为" .. f.g("0.5秒"),

        -- cooldowns module

        COOLDOWNS_TITLE = "CraftSim专业冷却",
        CONTROL_PANEL_MODULES_COOLDOWNS_LABEL = "专业冷却",
        CONTROL_PANEL_MODULES_COOLDOWNS_TOOLTIP = "显示账号中的所有" ..
            f.bb("专业冷却"),
        COOLDOWNS_CRAFTER_HEADER = "制作者",
        COOLDOWNS_RECIPE_HEADER = "配方",
        COOLDOWNS_CHARGES_HEADER = "充能",
        COOLDOWNS_NEXT_HEADER = "下次充能",
        COOLDOWNS_ALL_HEADER = "充能完毕",
        COOLDOWNS_TAB_OVERVIEW = "概览",
        COOLDOWNS_TAB_BLACKLIST = "黑名单",
        COOLDOWNS_TAB_OPTIONS = "选项",
        COOLDOWNS_EXPANSION_FILTER_BUTTON = "资料片过滤器",
        COOLDOWNS_RECIPE_LIST_TEXT_TOOLTIP = f.bb("\n\n配方共享冷却：\n"),
        COOLDOWNS_RECIPE_READY = f.g("就绪"),
        COOLDOWNS_ADD_TO_BLACKLIST = "添加到黑名单",
        COOLDOWNS_BLACKLIST_RESTORE = "移除出黑名单",

        -- concentration module

        CONCENTRATION_TRACKER_TITLE = "CraftSim专注",
        CONCENTRATION_TRACKER_LABEL_CRAFTER = "制作者",
        CONCENTRATION_TRACKER_LABEL_CURRENT = "当前",
        CONCENTRATION_TRACKER_LABEL_MAX = "满",
        CONCENTRATION_TRACKER_MAX = f.g("MAX"),
        CONCENTRATION_TRACKER_MAX_VALUE = "满：",
        CONCENTRATION_TRACKER_FULL = f.g("专注值已满"),
        CONCENTRATION_TRACKER_SORT_MODE_CHARACTER = "角色",
        CONCENTRATION_TRACKER_SORT_MODE_CONCENTRATION = "专注",
        CONCENTRATION_TRACKER_SORT_MODE_PROFESSION = "专业",
        CONCENTRATION_TRACKER_FORMAT_MODE_EUROPE_MAX_DATE = "欧洲 - 最大日期",
        CONCENTRATION_TRACKER_FORMAT_MODE_AMERICA_MAX_DATE = "美国 - 最大日期",
        CONCENTRATION_TRACKER_FORMAT_MODE_HOURS_LEFT = "剩余小时",
        CONCENTRATION_TRACKER_LIST_ROW_MOXIE = "匠人之魄：%s",
        CONCENTRATION_TRACKER_LIST_ROW_MOXIE_UNKNOWN = "-",
        CONCENTRATION_TRACKER_PIN_TOOLTIP = "固定概览",
        CONCENTRATION_TRACKER_LIST_TAB_LABEL = "列表",
        CONCENTRATION_TRACKER_LIST_TAB_REMOVE_AND_BLACKLIST = "移除并添加到黑名单",
        CONCENTRATION_TRACKER_OPTIONS_TAB_LABEL = "选项",
        CONCENTRATION_TRACKER_OPTIONS_TAB_CLEAR_BLACKLIST = "清除黑名单",
        CONCENTRATION_TRACKER_OPTIONS_TAB_SORT_MODE = "排序模式：",
        CONCENTRATION_TRACKER_OPTIONS_TAB_TIME_FORMAT = "时间格式：",

        -- static popups
        STATIC_POPUPS_YES = "是",
        STATIC_POPUPS_NO = "否",

        -- frames
        FRAMES_RESETTING = "正在重置框体ID： ",
        FRAMES_WHATS_NEW = "CraftSim有什么新功能？",
        FRAMES_JOIN_DISCORD = "加入Discord！",
        FRAMES_DONATE_KOFI = "在Kofi上访问CraftSim",
        FRAMES_NO_INFO = "无信息",

        -- node data
        NODE_DATA_RANK_TEXT = "等级",
        NODE_DATA_TOOLTIP = "\n\n来自天赋的总属性：\n",
        SPECIALIZATION_INFO_TOOLTIP_LABEL = f.l("CraftSim") .. f.white("专精信息："),

        -- last crafting cost tooltip
        LAST_CRAFTING_COST_TOOLTIP_HEADER = f.l("CraftSim"),
        LAST_CRAFTING_COST_TOOLTIP_LABEL = f.white("最低制造成本："),
        LAST_CRAFTING_COST_TOOLTIP_CRAFTER = f.white("制作者："),
        LAST_CRAFTING_COST_TOOLTIP_UPDATED = f.white("更新于："),
        REGISTERED_CRAFTERS_ITEM_TOOLTIP_LABEL = f.white("可制造："),
        REGISTERED_CRAFTERS_ITEM_TOOLTIP_MORE = "+%d更多",

        -- columns
        SOURCE_COLUMN_AH = "拍卖",
        SOURCE_COLUMN_OVERRIDE = "手动",
        SOURCE_COLUMN_WO = "订单",

        -- disenchant
        DISENCHANT_TITLE = "CraftSim分解",
        DISENCHANT_BUTTON = "分解下一个",
        DISENCHANT_OPTIONS_MIN_ILVL = "最低物品等级：",
        DISENCHANT_INFO_TOOLTIP = f.bb("中键") ..
            f.white(" .. 临时添加到黑名单\n") ..
            f.bb("Shift + 中键") .. f.white(" .. 永久添加到黑名单"),

        -- banking
        OPTIONS_BANKING_TAB = "银行",
        OPTIONS_BANKING_MAX_ITEMS_PER_FRAME = "每帧最大物品数：",
        OPTIONS_BANKING_MAX_ITEMS_PER_FRAME_TOOLTIP =
        "设置使用存取命令时每帧转移的最大物品数",
    }
end
