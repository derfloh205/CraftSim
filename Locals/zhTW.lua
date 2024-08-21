---@class CraftSim
local CraftSim = select(2, ...)

CraftSim.LOCAL_TW = {}

function CraftSim.LOCAL_TW:GetData()
    local f = CraftSim.GUTIL:GetFormatter()
    local cm = function(i, s) return CraftSim.MEDIA:GetAsTextIcon(i, s) end
    return {
        -- REQUIRED:
        [CraftSim.CONST.TEXT.STAT_MULTICRAFT] = "複數製造",
        [CraftSim.CONST.TEXT.STAT_RESOURCEFULNESS] = "精明",
        [CraftSim.CONST.TEXT.STAT_CRAFTINGSPEED] = "製造速度",
        [CraftSim.CONST.TEXT.EQUIP_MATCH_STRING] = "裝備：",
        [CraftSim.CONST.TEXT.ENCHANTED_MATCH_STRING] = "附魔：",

        -- OPTIONAL (Defaulting to EN if not available):
        -- Other Statnames

        [CraftSim.CONST.TEXT.STAT_SKILL] = "技能",
        [CraftSim.CONST.TEXT.STAT_MULTICRAFT_BONUS] = "複數製造額外物品",
        [CraftSim.CONST.TEXT.STAT_RESOURCEFULNESS_BONUS] = "精明額外物品",
        [CraftSim.CONST.TEXT.STAT_CRAFTINGSPEED_BONUS] = "製造速度",
        [CraftSim.CONST.TEXT.STAT_PHIAL_EXPERIMENTATION] = "藥瓶突破",
        [CraftSim.CONST.TEXT.STAT_POTION_EXPERIMENTATION] = "藥水突破",

        -- Profit Breakdown Tooltips
        [CraftSim.CONST.TEXT.RESOURCEFULNESS_EXPLANATION_TOOLTIP] =
        "精明會個別觸發每一種材料，然後節省約 30% 的數量。\n\n它節省的平均值是每一組合及其機率的平均節省值。\n（所有材料同時觸發機率很低，但節省很多。）\n\n平均總節省的材料成本是所有組合的節省材料成本，並根據其機率進行加權。",

        -- unused currently
        [CraftSim.CONST.TEXT.RECIPE_DIFFICULTY_EXPLANATION_TOOLTIP] =
        "配方難度決定了不同品質的臨界點。\n\n對於有五種品質的配方，它們分別在 20%、50%、80% 和 100% 的配方技能難度。\n對於有三個品質的配方，它們分別在 50% 和 100%。",
        [CraftSim.CONST.TEXT.MULTICRAFT_EXPLANATION_TOOLTIP] =
        "複數製造給你一個使用配方製作比你通常會製作的更多物品的機率。\n\n額外數量通常介於 1 到 2.5y 之間\ny = 1 次製作通常產生的數量。",
        [CraftSim.CONST.TEXT.REAGENTSKILL_EXPLANATION_TOOLTIP] =
        "你的材料品質可以給你最多 40% 的基礎配方難度作為獎勵技能。\n\n所有 Q1 材料：0% 獎勵\n所有 Q2 材料：20% 獎勵\n所有 Q3 材料：40% 獎勵\n\n技能是藉由每種品質的材料數量乘以它們的品質\n以及每個個別龍族飛行製作材料物品獨有的特定權重值來計算的\n\n然而，這對於重新製作卻不同。在那裡，試劑可以增加品質的最大值\n取決於最初製作物品所使用的材料品質。\n確切的運作方式尚不清楚。\n然而，CraftSim 在內部將達到的技能與所有 q3 進行比較，並計算\n基於此的最大技能提升。",
        [CraftSim.CONST.TEXT.REAGENTFACTOR_EXPLANATION_TOOLTIP] =
        "材料對配方所能貢獻的最大值在大部分時間是基礎配方難度的 40%。\n\n然而，在重新製作的情況下，這個數值會根據之前的製作而有所不同\n以及之前使用過的材料品質。",

        -- Simulation Mode
        [CraftSim.CONST.TEXT.SIMULATION_MODE_NONE] = "無",
        [CraftSim.CONST.TEXT.SIMULATION_MODE_LABEL] = "模擬模式",
        [CraftSim.CONST.TEXT.SIMULATION_MODE_TITLE] = "CraftSim 模擬模式",
        [CraftSim.CONST.TEXT.SIMULATION_MODE_TOOLTIP] = "CraftSim 的模擬模式可以無極限的玩弄配方",
        [CraftSim.CONST.TEXT.SIMULATION_MODE_OPTIONAL] = "選擇性 #",
        [CraftSim.CONST.TEXT.SIMULATION_MODE_FINISHING] = "正在完成 #",

        -- Details Frame
        [CraftSim.CONST.TEXT.RECIPE_DIFFICULTY_LABEL] = "配方難度：",
        [CraftSim.CONST.TEXT.MULTICRAFT_LABEL] = "複數製造：",
        [CraftSim.CONST.TEXT.RESOURCEFULNESS_LABEL] = "精明：",
        [CraftSim.CONST.TEXT.RESOURCEFULNESS_BONUS_LABEL] = "精明節省加成: ",
        [CraftSim.CONST.TEXT.MATERIAL_QUALITY_BONUS_LABEL] = "材料品質加成: ",
        [CraftSim.CONST.TEXT.MATERIAL_QUALITY_MAXIMUM_LABEL] = "材料品質最大佔比: ",
        [CraftSim.CONST.TEXT.EXPECTED_QUALITY_LABEL] = "預期品質: ",
        [CraftSim.CONST.TEXT.NEXT_QUALITY_LABEL] = "下一級品質: ",
        [CraftSim.CONST.TEXT.MISSING_SKILL_LABEL] = "不足技能: ",
        [CraftSim.CONST.TEXT.SKILL_LABEL] = "技能: ",
        [CraftSim.CONST.TEXT.MULTICRAFT_BONUS_LABEL] = "複數製造加成: ",

        -- Statistics
        [CraftSim.CONST.TEXT.STATISTICS_CDF_EXPLANATION] =
        "這使用 abramowitz and stegun 近似值（1985）計算CDF（累積分布函數）\n\n你會注意到 1 件中它的比例總是大約 50%。\n這是因為 0 在大多數時間都接近平均利潤。\n而且 CDF 的均值總有 50% 的機率。\n\n然而，不同配方之間的變化率可能有很大的差異。\n如果有可能獲得正利潤而不是負利潤，它將會穩定增加。\n對於其他方向的變化當然也是一樣。",

        [CraftSim.CONST.TEXT.EXPLANATIONS_PROFIT_CALCULATION_EXPLANATION] =
            f.r("警告：") .. "前方高能數學！\n\n" ..
            "當你製作物品時，你有不同的機率可以使不同的結果基於你的製作數據。\n" ..
            "而在統計學，這被稱作 " .. f.l("機率分配。\n") ..
            "但是，你會注意到你的程序不同可能性並不會加起來到 1\n" ..
            "（這對於這樣的分配是需要的，因為這表示你擁有 100% 機率去讓任何事情發生）\n\n" ..
            "這是因為程序像是 " .. f.bb("靈感") .. "和" .. f.bb("複數製造") .. " 可以 " .. f.g("同時發生。\n") ..
            "所以我們首先需要把我們的程序可能性轉換成有著 100% 總機率的 " .. f.l("機率分配 ") .. "（這意謂著所有狀況都被覆蓋到了）\n" ..
            "我們需要計算製作的" .. f.l("每一個") .. "可能結果以達成這件事\n\n" ..
            "例如：\n" ..
            f.p .. "假如" .. f.bb("沒有") .. "任何程序發生呢？" ..
            f.p .. "假如" .. f.bb("所有") .. "程序都發生呢？" ..
            f.p .. "假如只有" .. f.bb("靈感") .. " 和 " .. f.bb("複數製造") .. "發生呢？" ..
            f.p .. "等等諸如此類的狀況\n\n" ..
            "對於一個考量所有三個程序的配方，這將會有 2 的 3 次方個可能結果，也就是整整 8 個。\n" ..
            "要獲得只有 " .. f.bb("靈感") .. " 發生的可能性，我們必須考量所有其他程序！\n" ..
            "只有 " .. f.l("僅有") .. f.bb("靈感") .. "發生的可能性實際上是" .. f.bb("靈感") .. "發生的可能性\n" ..
            "但是 " .. f.l("沒有") .. "發生" .. f.bb("複數製造") .. "或" .. f.bb("精明。\n") ..
            "而數學告訴我們，某事沒有發生的機率是它發生的機率的 1 減掉該機率。\n" ..
            "所以只有" .. f.bb("靈感") .. "發生的可能性實際上是" .. f.g("靈感可能性 * (1-複數製造機率) * (1-精明機率)\n\n") ..
            "在用這種方式計算每個可能性後，各別可能性確實會加起來到 1！\n" ..
            "這意味著我們現在可以用統計公式了。對我們來說最有趣的是 " .. f.bb("期望值") .. "\n" ..
            "正如其名，期望值是指我們平均可以獲得的價值，或者在我們的例子中，也就是 " .. f.bb("製作的期望利潤！\n") ..
            "\n" .. cm(CraftSim.MEDIA.IMAGES.EXPECTED_VALUE) .. "\n\n" ..
            "這告訴我們機率分配 " .. f.l("X") .. " 的期望值 " .. f.l("E") .. " 是所有數值與其可能性的乘積的總和。\n" ..
            "所以如果我們有一個 " ..
            f.bb("情況 A 機率 30%") ..
            " 利潤 " .. f.m(-100 * 10000) ..
            " 和一個" .. f.bb("情況 B 機率 70%") .. " 利潤 " .. f.m(300 * 10000) .. " 那該情況的期望利潤就是\n" ..
            f.bb("\nE(X) = -100*0.3 + 300*0.7 ") .. " 是 " .. f.m((-100 * 0.3 + 300 * 0.7) * 10000) .. "\n" ..
            "你可以在" .. f.bb("統計資料") .. "視窗中檢視當前配方的所有情況！"
        ,

        -- Popups
        [CraftSim.CONST.TEXT.POPUP_NO_PRICE_SOURCE_SYSTEM] = "沒有可用的價格來源!",
        [CraftSim.CONST.TEXT.POPUP_NO_PRICE_SOURCE_TITLE] = "CraftSim 價格來源警告",
        [CraftSim.CONST.TEXT.POPUP_NO_PRICE_SOURCE_WARNING] = "沒有找到價格來源!\n\n至少需要安裝下面其中一個價格來源插件，CraftSim 才能計算利潤:\n\n\n",
        [CraftSim.CONST.TEXT.POPUP_NO_PRICE_SOURCE_WARNING_SUPPRESS] = "不要再顯示警告",

        -- Materials Frame
        [CraftSim.CONST.TEXT.REAGENT_OPTIMIZATION_TITLE] = "CraftSim 材料最佳化",
        [CraftSim.CONST.TEXT.MATERIALS_REACHABLE_QUALITY] = "可達到品質: ",
        [CraftSim.CONST.TEXT.MATERIALS_MISSING] = "缺少材料",
        [CraftSim.CONST.TEXT.MATERIALS_AVAILABLE] = "可用材料",
        [CraftSim.CONST.TEXT.MATERIALS_CHEAPER] = "最便宜材料",
        [CraftSim.CONST.TEXT.MATERIALS_BEST_COMBINATION] = "已分配最佳組合",
        [CraftSim.CONST.TEXT.MATERIALS_NO_COMBINATION] = "無法找到提高\n品質的組合",
        [CraftSim.CONST.TEXT.MATERIALS_ASSIGN] = "分配",

        -- Specialization Info Frame
        [CraftSim.CONST.TEXT.SPEC_INFO_TITLE] = "CraftSim 專精資訊",
        [CraftSim.CONST.TEXT.SPEC_INFO_SIMULATE_KNOWLEDGE_DISTRIBUTION] = "模擬知識分配",
        [CraftSim.CONST.TEXT.SPEC_INFO_NODE_TOOLTIP] = "該節點為您提供該配方的下列屬性:",
        [CraftSim.CONST.TEXT.SPEC_INFO_WORK_IN_PROGRESS] = "專精資訊仍在製作中",

        -- Crafting Results Frame
        [CraftSim.CONST.TEXT.CRAFT_RESULTS_TITLE] = "CraftSim 製造結果",
        [CraftSim.CONST.TEXT.CRAFT_RESULTS_LOG] = "製造記錄",
        [CraftSim.CONST.TEXT.CRAFT_RESULTS_LOG_1] = "利潤: ",
        [CraftSim.CONST.TEXT.CRAFT_RESULTS_LOG_2] = "獲得靈感!",
        [CraftSim.CONST.TEXT.CRAFT_RESULTS_LOG_3] = "複數製造: ",
        [CraftSim.CONST.TEXT.CRAFT_RESULTS_LOG_4] = "節省資源!: ",
        [CraftSim.CONST.TEXT.CRAFT_RESULTS_LOG_5] = "機率: ",
        [CraftSim.CONST.TEXT.CRAFT_RESULTS_CRAFTED_ITEMS] = "製造的物品",
        [CraftSim.CONST.TEXT.CRAFT_RESULTS_SESSION_PROFIT] = "此次利潤",
        [CraftSim.CONST.TEXT.CRAFT_RESULTS_RESET_DATA] = "重置資料",
        [CraftSim.CONST.TEXT.CRAFT_RESULTS_EXPORT_JSON] = "匯出 JSON",
        [CraftSim.CONST.TEXT.CRAFT_RESULTS_RECIPE_STATISTICS] = "配方統計資料",
        [CraftSim.CONST.TEXT.CRAFT_RESULTS_NOTHING] = "尚未製造任何東西!",
        [CraftSim.CONST.TEXT.CRAFT_RESULTS_STATISTICS_1] = "製造: ",
        [CraftSim.CONST.TEXT.CRAFT_RESULTS_STATISTICS_2] = "預期 Φ 利潤: ",
        [CraftSim.CONST.TEXT.CRAFT_RESULTS_STATISTICS_3] = "實際 Φ 利潤: ",
        [CraftSim.CONST.TEXT.CRAFT_RESULTS_STATISTICS_4] = "實際利潤: ",
        [CraftSim.CONST.TEXT.CRAFT_RESULTS_STATISTICS_5] = "過程 - 實際 / 期望: ",
        [CraftSim.CONST.TEXT.CRAFT_RESULTS_STATISTICS_6] = "靈感: ",
        [CraftSim.CONST.TEXT.CRAFT_RESULTS_STATISTICS_7] = "複數製造: ",
        [CraftSim.CONST.TEXT.CRAFT_RESULTS_STATISTICS_8] = "- Φ 額外物品: ",
        [CraftSim.CONST.TEXT.CRAFT_RESULTS_STATISTICS_9] = "精明過程: ",
        [CraftSim.CONST.TEXT.CRAFT_RESULTS_STATISTICS_10] = "- Φ 節省成本: ",
        [CraftSim.CONST.TEXT.CRAFT_RESULTS_STATISTICS_11] = "利潤: ",
        [CraftSim.CONST.TEXT.CRAFT_RESULTS_SAVED_REAGENTS] = "節省材料",
        [CraftSim.CONST.TEXT.CRAFT_RESULTS_DISABLE_CHECKBOX] = f.l("停用記錄製造結果"),
        [CraftSim.CONST.TEXT.CRAFT_RESULTS_DISABLE_CHECKBOX_TOOLTIP] = "啟用此選項會停止在製造時記錄任何製造結果，並且會" .. f.g("增加效能"),

        -- Stats Weight Frame
        [CraftSim.CONST.TEXT.STAT_WEIGHTS_TITLE] = "CraftSim 平均利潤",
        [CraftSim.CONST.TEXT.EXPLANATIONS_TITLE] = "CraftSim 平均利潤說明",
        [CraftSim.CONST.TEXT.STAT_WEIGHTS_SHOW_EXPLANATION_BUTTON] = "顯示說明",
        [CraftSim.CONST.TEXT.STAT_WEIGHTS_HIDE_EXPLANATION_BUTTON] = "隱藏說明",
        [CraftSim.CONST.TEXT.STAT_WEIGHTS_SHOW_STATISTICS_BUTTON] = "顯示統計資料",
        [CraftSim.CONST.TEXT.STAT_WEIGHTS_HIDE_STATISTICS_BUTTON] = "隱藏統計資料",
        [CraftSim.CONST.TEXT.STAT_WEIGHTS_PROFIT_CRAFT] = "Φ 利潤 / 製造: ",
        [CraftSim.CONST.TEXT.EXPLANATIONS_BASIC_PROFIT_TAB] = "基本利潤計算",

        -- Cost Details Frame
        [CraftSim.CONST.TEXT.COST_OPTIMIZATION_TITLE] = "CraftSim 成本明細",
        [CraftSim.CONST.TEXT.COST_OPTIMIZATION_EXPLANATION] = "所有材料可能價格概述如下。\n" ..
            f.bb("'使用來源'") ..
            " 欄位指示哪一個價格已被使用。\n\n" ..
            f.g("拍賣場") ..
            " .. 拍賣場價格\n" ..
            f.l("或") ..
            " .. 重訂價格\n" ..
            f.bb("任何名稱") ..
            " .. 製作者的製作資料預估成本\n\n" .. f.l("或") .. " 已設定則會優先使用。 " .. f.bb("製造資料") .. " 僅在低於 " .. f.g("拍賣場") .. " 時才會使用。",
        [CraftSim.CONST.TEXT.COST_OPTIMIZATION_CRAFTING_COSTS] = "製造成本: ",
        [CraftSim.CONST.TEXT.COST_OPTIMIZATION_ITEM_HEADER] = "物品",
        [CraftSim.CONST.TEXT.COST_OPTIMIZATION_AH_PRICE_HEADER] = "拍賣價格",
        [CraftSim.CONST.TEXT.COST_OPTIMIZATION_OVERRIDE_HEADER] = "重訂價格",
        [CraftSim.CONST.TEXT.COST_OPTIMIZATION_CRAFTING_HEADER] = "製造資料",
        [CraftSim.CONST.TEXT.COST_OPTIMIZATION_USED_SOURCE] = "使用來源",

        -- Statistics Frame
        [CraftSim.CONST.TEXT.STATISTICS_TITLE] = "CraftSim 統計資料",
        [CraftSim.CONST.TEXT.STATISTICS_EXPECTED_PROFIT] = "預期利潤 (μ)",
        [CraftSim.CONST.TEXT.STATISTICS_CHANCE_OF] = "製造後",
        [CraftSim.CONST.TEXT.STATISTICS_PROFIT] = "利潤",
        [CraftSim.CONST.TEXT.STATISTICS_AFTER] = " 的機率",
        [CraftSim.CONST.TEXT.STATISTICS_CRAFTS] = "製造: ",
        [CraftSim.CONST.TEXT.STATISTICS_QUALITY_HEADER] = "品質",
        [CraftSim.CONST.TEXT.STATISTICS_CHANCE_HEADER] = "機率",
        [CraftSim.CONST.TEXT.STATISTICS_EXPECTED_CRAFTS_HEADER] = "Φ 預期製造",
        [CraftSim.CONST.TEXT.STATISTICS_MULTICRAFT_HEADER] = "複數製造",
        [CraftSim.CONST.TEXT.STATISTICS_RESOURCEFULNESS_HEADER] = "精明",
        [CraftSim.CONST.TEXT.STATISTICS_HSV_NEXT] = "HSV提升",
        [CraftSim.CONST.TEXT.STATISTICS_HSV_SKIP] = "HSV跳過",
        [CraftSim.CONST.TEXT.STATISTICS_EXPECTED_PROFIT_HEADER] = "預期利潤",
        [CraftSim.CONST.TEXT.PROBABILITY_TABLE_TITLE] = "配方概率表",
        [CraftSim.CONST.TEXT.STATISTICS_EXPECTED_COSTS_HEADER] = "每件物品的 Φ 預期成本",
        [CraftSim.CONST.TEXT.STATISTICS_EXPECTED_COSTS_WITH_RETURN_HEADER] = "Φ 銷售回報",

        -- Price Details Frame
        [CraftSim.CONST.TEXT.COST_OVERVIEW_TITLE] = "CraftSim 價格明細",
        [CraftSim.CONST.TEXT.PRICE_DETAILS_INV_AH] = "Inv/AH",
        [CraftSim.CONST.TEXT.PRICE_DETAILS_ITEM] = "物品",
        [CraftSim.CONST.TEXT.PRICE_DETAILS_PRICE_ITEM] = "價格/物品",
        [CraftSim.CONST.TEXT.PRICE_DETAILS_PROFIT_ITEM] = "利潤/物品",

        -- Price Override Frame
        [CraftSim.CONST.TEXT.PRICE_OVERRIDE_TITLE] = "CraftSim 重訂價格",
        [CraftSim.CONST.TEXT.PRICE_OVERRIDE_REQUIRED_REAGENTS] = "必要材料",
        [CraftSim.CONST.TEXT.PRICE_OVERRIDE_OPTIONAL_REAGENTS] = "選擇性材料",
        [CraftSim.CONST.TEXT.PRICE_OVERRIDE_FINISHING_REAGENTS] = "完成材料",
        [CraftSim.CONST.TEXT.PRICE_OVERRIDE_RESULT_ITEMS] = "產出物品",
        [CraftSim.CONST.TEXT.PRICE_OVERRIDE_ACTIVE_OVERRIDES] = "啟用的重訂價格",
        [CraftSim.CONST.TEXT.PRICE_OVERRIDE_ACTIVE_OVERRIDES_TOOLTIP] = "'(產出物品)' -> 當物品是配方生產出來的才考慮重訂價格",
        [CraftSim.CONST.TEXT.PRICE_OVERRIDE_CLEAR_ALL] = "全部清除",
        [CraftSim.CONST.TEXT.PRICE_OVERRIDE_SAVE] = "儲存",
        [CraftSim.CONST.TEXT.PRICE_OVERRIDE_SAVED] = "已儲存",
        [CraftSim.CONST.TEXT.PRICE_OVERRIDE_REMOVE] = "移除",

        -- Recipe Scan Frame
        [CraftSim.CONST.TEXT.RECIPE_SCAN_TITLE] = "CraftSim 配方掃描",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_MODE] = "掃描模式",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_SCAN_RECIPIES] = "掃描配方",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_SCAN_CANCEL] = "取消",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_SCANNING] = "正在掃描",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_INCLUDE_NOT_LEARNED] = "包含尚未學會",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_INCLUDE_NOT_LEARNED_TOOLTIP] = "配方掃描中要包含你還沒學會的配方",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_INCLUDE_SOULBOUND] = "包含靈魂綁定",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_INCLUDE_SOULBOUND_TOOLTIP] =
        "配方掃描中要包含靈魂綁定的配方\n\n建議在重訂價格模組對該配方的製造物品\n設定價格 (例如模擬目標佣金)",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_INCLUDE_GEAR] = "包含裝備",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_INCLUDE_GEAR_TOOLTIP] = "在配方掃描中包含所有種類的裝備配方",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_OPTIMIZE_TOOLS] = "最佳化專業工具",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_OPTIMIZE_TOOLS_TOOLTIP] = "為每個配方最佳化你的專業工具以獲取利潤\n\n",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_OPTIMIZE_TOOLS_WARNING] = "如果你的背包中有很多工具\n掃描期間可能會降低遊戲效能",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_RECIPE_HEADER] = "配方",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_LEARNED_HEADER] = "已學會",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_AVERAGE_PROFIT_HEADER] = "平均利潤",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_TOP_GEAR_HEADER] = "最佳裝備",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_INV_AH_HEADER] = "Inv/AH",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_SORT_BY_MARGIN] = "依利潤 % 排序",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_SORT_BY_MARGIN_TOOLTIP] = "依據和製造花費相關的利潤排序利潤清單。\n(需要重新掃描)",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_USE_INSIGHT_CHECKBOX] = "使用" .. f.bb("洞見") .. " (如果可以的話)",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_USE_INSIGHT_CHECKBOX_TOOLTIP] = "如果配方允許，使用" ..
            f.bb("卓越洞見") .. "或\n" .. f.bb("次級卓越洞見") .. "作為選擇性的材料。",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_ONLY_FAVORITES_CHECKBOX] = "只有最愛",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_ONLY_FAVORITES_CHECKBOX_TOOLTIP] = "只掃描最愛的配方",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_EQUIPPED] = "已裝備",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_MODE_Q1] = "材料品質 1",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_MODE_Q2] = "材料品質 2",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_MODE_Q3] = "材料品質 3",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_MODE_OPTIMIZE] = "最佳化材料",

        -- Recipe Top Gear
        [CraftSim.CONST.TEXT.TOP_GEAR_TITLE] = "CraftSim 最佳裝備",
        [CraftSim.CONST.TEXT.TOP_GEAR_AUTOMATIC] = "自動",
        [CraftSim.CONST.TEXT.TOP_GEAR_AUTOMATIC_TOOLTIP] = "配方更新時自動模擬所選模式的最佳裝備。\n\n關閉此選項可以增進效能。",
        [CraftSim.CONST.TEXT.TOP_GEAR_SIMULATE] = "模擬最佳裝備",
        [CraftSim.CONST.TEXT.TOP_GEAR_EQUIP] = "裝備",
        [CraftSim.CONST.TEXT.TOP_GEAR_SIMULATE_QUALITY] = "品質: ",
        [CraftSim.CONST.TEXT.TOP_GEAR_SIMULATE_EQUIPPED] = "已穿上最佳裝備",
        [CraftSim.CONST.TEXT.TOP_GEAR_SIMULATE_PROFIT_DIFFERENCE] = "Φ 利潤差\n",
        [CraftSim.CONST.TEXT.TOP_GEAR_SIMULATE_NEW_MUTLICRAFT] = "新的複數製造\n",
        [CraftSim.CONST.TEXT.TOP_GEAR_SIMULATE_NEW_CRAFTING_SPEED] = "新的製造速度\n",
        [CraftSim.CONST.TEXT.TOP_GEAR_SIMULATE_NEW_RESOURCEFULNESS] = "新的精明\n",
        [CraftSim.CONST.TEXT.TOP_GEAR_SIMULATE_NEW_SKILL] = "新的技能\n",
        [CraftSim.CONST.TEXT.TOP_GEAR_SIMULATE_UNHANDLED] = "未處理的模擬模式",

        [CraftSim.CONST.TEXT.TOP_GEAR_SIM_MODES_PROFIT] = "最佳利潤",
        [CraftSim.CONST.TEXT.TOP_GEAR_SIM_MODES_SKILL] = "最佳技能",
        [CraftSim.CONST.TEXT.TOP_GEAR_SIM_MODES_MULTICRAFT] = "最佳複數製造",
        [CraftSim.CONST.TEXT.TOP_GEAR_SIM_MODES_RESOURCEFULNESS] = "最佳精明",
        [CraftSim.CONST.TEXT.TOP_GEAR_SIM_MODES_CRAFTING_SPEED] = "最佳製造速度",

        -- Options
        [CraftSim.CONST.TEXT.OPTIONS_TITLE] = "專業製造模擬器",
        [CraftSim.CONST.TEXT.OPTIONS_GENERAL_TAB] = "一般",
        [CraftSim.CONST.TEXT.OPTIONS_GENERAL_PRICE_SOURCE] = "價格來源",
        [CraftSim.CONST.TEXT.OPTIONS_GENERAL_CURRENT_PRICE_SOURCE] = "當前價格來源: ",
        [CraftSim.CONST.TEXT.OPTIONS_GENERAL_NO_PRICE_SOURCE] = "沒有載入支援的價格來源插件!",
        [CraftSim.CONST.TEXT.OPTIONS_GENERAL_SHOW_PROFIT] = "顯示利潤百分比",
        [CraftSim.CONST.TEXT.OPTIONS_GENERAL_SHOW_PROFIT_TOOLTIP] = "除了金錢，還要顯示利潤佔造製成本的百分本。",
        [CraftSim.CONST.TEXT.OPTIONS_GENERAL_REMEMBER_LAST_RECIPE] = "記住上次的配方",
        [CraftSim.CONST.TEXT.OPTIONS_GENERAL_REMEMBER_LAST_RECIPE_TOOLTIP] = "打開製造視窗時，再次打開上次選擇的配方。",
        [CraftSim.CONST.TEXT.OPTIONS_GENERAL_DETAILED_TOOLTIP] = "詳細的上次製造資訊",
        [CraftSim.CONST.TEXT.OPTIONS_GENERAL_DETAILED_TOOLTIP_TOOLTIP] = "在物品的浮動提示資訊中顯示上次使用的材料組合的完整清單。",
        [CraftSim.CONST.TEXT.OPTIONS_GENERAL_SUPPORTED_PRICE_SOURCES] = "支援的價格來源:",
        [CraftSim.CONST.TEXT.OPTIONS_PERFORMANCE_RAM] = "製造時啟用記憶體清理",
        [CraftSim.CONST.TEXT.OPTIONS_PERFORMANCE_RAM_TOOLTIP] =
        "啟用時，CraftSim 會在每次指定數量的製造後清除記憶體中未使用的資料，以防止記憶體堆積。\n記憶體堆積也有可能是其他插件引起的，並且不是只有 CraftSim。\n清理會影響整個魔獸的記憶體使用量。",
        [CraftSim.CONST.TEXT.OPTIONS_MODULES_TAB] = "模組",
        [CraftSim.CONST.TEXT.OPTIONS_PROFIT_CALCULATION_TAB] = "利潤計算",
        [CraftSim.CONST.TEXT.OPTIONS_CRAFTING_TAB] = "製造",
        [CraftSim.CONST.TEXT.OPTIONS_TSM_RESET] = "恢復成預設值",
        [CraftSim.CONST.TEXT.OPTIONS_TSM_INVALID_EXPRESSION] = "語法不正確",
        [CraftSim.CONST.TEXT.OPTIONS_TSM_VALID_EXPRESSION] = "語法正確",
        [CraftSim.CONST.TEXT.OPTIONS_MODULES_MATERIALS] = "材料最佳化模組",
        [CraftSim.CONST.TEXT.OPTIONS_MODULES_AVERAGE_PROFIT] = "平均利潤模組",
        [CraftSim.CONST.TEXT.OPTIONS_MODULES_TOP_GEAR] = "最佳裝備模組",
        [CraftSim.CONST.TEXT.OPTIONS_MODULES_COST_OVERVIEW] = "成本概覽模組",
        [CraftSim.CONST.TEXT.OPTIONS_MODULES_SPECIALIZATION_INFO] = "專精資訊模組",
        [CraftSim.CONST.TEXT.OPTIONS_MODULES_CUSTOMER_HISTORY_SIZE] = "每個客戶的歷史訊息上限",
        [CraftSim.CONST.TEXT.OPTIONS_PROFIT_CALCULATION_OFFSET] = "技能斷點 + 1",
        [CraftSim.CONST.TEXT.OPTIONS_PROFIT_CALCULATION_OFFSET_TOOLTIP] = "材料組合建議會嘗試達到斷點 + 1 而不是剛好符合需要的技能點數",
        [CraftSim.CONST.TEXT.OPTIONS_PROFIT_CALCULATION_MULTICRAFT_CONSTANT] = "複數製造常數",
        [CraftSim.CONST.TEXT.OPTIONS_PROFIT_CALCULATION_MULTICRAFT_CONSTANT_EXPLANATION] =
        "預設：2.5\n\n來自 beta 以及早期搜集不同玩家數據的製作數據顯示。\n一次複數製造中額外能獲得的道具數量最多為 1+C*y。\nC 中 y 是數量的基本製作道具，而 C 為 2.5。\n如果想要的話可以修改此處的值。",
        [CraftSim.CONST.TEXT.OPTIONS_PROFIT_CALCULATION_RESOURCEFULNESS_CONSTANT] = "精明常數",
        [CraftSim.CONST.TEXT.OPTIONS_PROFIT_CALCULATION_RESOURCEFULNESS_CONSTANT_EXPLANATION] =
        "預設：0.3\n\n來自 beta 以及早期搜集不同玩家數據的製作數據顯示。\n平均節省的物品數量為所需數量的 30%。\n如果想要的話可以修改此處的值。",
        [CraftSim.CONST.TEXT.OPTIONS_GENERAL_SHOW_NEWS_CHECKBOX] = "顯示" .. f.bb("更新資訊"),
        [CraftSim.CONST.TEXT.OPTIONS_GENERAL_SHOW_NEWS_CHECKBOX_TOOLTIP] = "登入遊戲時，顯示 " ..
            f.l("CraftSim") .. f.bb(" 更新資訊") .. "的彈出視窗。",

        -- Control Panel
        [CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_CRAFT_QUEUE_LABEL] = "製作排程",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_CRAFT_QUEUE_TOOLTIP] = "在同一個地方排程並製造你的配方!",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_TOP_GEAR_LABEL] = "最佳裝備",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_TOP_GEAR_TOOLTIP] = "依據選擇的模式來顯示最佳的可用專業裝備組合",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_COST_OVERVIEW_LABEL] = "價格明細",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_COST_OVERVIEW_TOOLTIP] = "按物品品質顯示銷售價格和利潤概覽",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_AVERAGE_PROFIT_LABEL] = "平均利潤",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_AVERAGE_PROFIT_TOOLTIP] = "依據你的專業屬性和利潤比重來顯示平均利潤，每個點數多少金。",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_REAGENT_OPTIMIZATION_LABEL] = "材料最佳化",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_REAGENT_OPTIMIZATION_TOOLTIP] = "建議使用最便宜材料便能達到最高品質/靈感的門檻",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_PRICE_OVERRIDES_LABEL] = "重訂價格",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_PRICE_OVERRIDES_TOOLTIP] =
        "取代所有配方或特定配方的任何材料、可選材料和製造結果的價格。也可以設定物品使用製造資料的價格。",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_CRAFT_DATA_LABEL] = "製造資料",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_CRAFT_DATA_TOOLTIP] = "編輯已儲存的配置，以製作不同品質的商品，並在浮動提示資訊中顯示並計算製作成本。",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_SPECIALIZATION_INFO_LABEL] = "專精資訊",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_SPECIALIZATION_INFO_TOOLTIP] = "顯示你的專業專精會如何影響這個配方，可以模擬任何配置!",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_CRAFT_RESULTS_LABEL] = "製造結果",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_CRAFT_RESULTS_TOOLTIP] = "顯示製造的日誌和統計資料!",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_COST_OPTIMIZATION_LABEL] = "成本明細",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_COST_OPTIMIZATION_TOOLTIP] = "顯示製造成本詳細資訊的模組",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_RECIPE_SCAN_LABEL] = "配方掃描",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_RECIPE_SCAN_TOOLTIP] = "依據多種不同的選項掃描你的配方列表",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_CUSTOMER_HISTORY_LABEL] = "客戶記錄",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_CUSTOMER_HISTORY_TOOLTIP] = "提供與客戶對談的歷史記錄、製作過的物品和佣金的模組",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_RESET_FRAMES] = "重置框架位置",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_OPTIONS] = "選項",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_NEWS] = "更新資訊",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_FORGEFINDER_EXPORT] = f.l("ForgeFinder") .. " 匯出",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_FORGEFINDER_EXPORTING] = "正在匯出",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_FORGEFINDER_EXPLANATION] = f.l("www.wowforgefinder.com") ..
            "\n是個尋找和提供" .. f.bb("魔獸世界製造訂單") .. "的網站。",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_DEBUG] = "除錯",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_TITLE] = "控制台",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_SUPPORTERS_BUTTON] = f.patreon("贊助者"),

        -- Supporters
        [CraftSim.CONST.TEXT.SUPPORTERS_DESCRIPTION] = f.l("感謝這些超棒der！"),
        [CraftSim.CONST.TEXT.SUPPORTERS_DESCRIPTION_2] = f.l("您是否想要支持 CraftSim 並且在這裡留下你名字和訊息?\n請考慮斗內 <3"),
        [CraftSim.CONST.TEXT.SUPPORTERS_DATE] = "日期",
        [CraftSim.CONST.TEXT.SUPPORTERS_SUPPORTER] = "贊助者",
        [CraftSim.CONST.TEXT.SUPPORTERS_TYPE] = "類型",
        [CraftSim.CONST.TEXT.SUPPORTERS_MESSAGE] = "留言",

        -- Customer History
        [CraftSim.CONST.TEXT.CUSTOMER_HISTORY_TITLE] = "CraftSim 客戶記錄",
        [CraftSim.CONST.TEXT.CUSTOMER_HISTORY_DROPDOWN_LABEL] = "選擇客戶",
        [CraftSim.CONST.TEXT.CUSTOMER_HISTORY_TOTAL_TIP] = "總共提示: ",
        [CraftSim.CONST.TEXT.CUSTOMER_HISTORY_FROM] = "來自",
        [CraftSim.CONST.TEXT.CUSTOMER_HISTORY_TO] = "給",
        [CraftSim.CONST.TEXT.CUSTOMER_HISTORY_FOR] = "給",
        [CraftSim.CONST.TEXT.CUSTOMER_HISTORY_CRAFT_FORMAT] = "製造 %s 給 %s",
        [CraftSim.CONST.TEXT.CUSTOMER_HISTORY_DELETE_BUTTON] = "移除客戶",
        [CraftSim.CONST.TEXT.CUSTOMER_HISTORY_WHISPER_BUTTON_LABEL] = "密語..",
        [CraftSim.CONST.TEXT.CUSTOMER_HISTORY_PURGE_NO_TIP_LABEL] = "移除 0 小費客戶",
        [CraftSim.CONST.TEXT.CUSTOMER_HISTORY_PURGE_ZERO_TIPS_CONFIRMATION_POPUP] = "是否確定要刪除小費總計為 0 的所有客戶資料?",
        [CraftSim.CONST.TEXT.CUSTOMER_HISTORY_DELETE_CUSTOMER_CONFIRMATION_POPUP] = "是否確定要刪除 %s 的所有資料?",
        [CraftSim.CONST.TEXT.CUSTOMER_HISTORY_DELETE_CUSTOMER_POPUP_TITLE] = "刪除客戶歷史記錄",
        [CraftSim.CONST.TEXT.CUSTOMER_HISTORY_PURGE_ZERO_TIPS_CONFIRMATION_POPUP_TITLE] = "刪除 0 小費客戶歷史記錄",
        [CraftSim.CONST.TEXT.CUSTOMER_HISTORY_PURGE_DAYS_INPUT_LABEL] = "自動移除天數",
        [CraftSim.CONST.TEXT.CUSTOMER_HISTORY_PURGE_DAYS_INPUT_TOOLTIP] =
        "CraftSim 會在每次登入後，自動刪除上次刪除後 X 天的所有 0 小費客戶。\n設為 0 時，CraftSim 將完全不會自動刪除。",
        [CraftSim.CONST.TEXT.CUSTOMER_HISTORY_CUSTOMER_HEADER] = "客戶",
        [CraftSim.CONST.TEXT.CUSTOMER_HISTORY_TOTAL_TIP_HEADER] = "小費總計",
        [CraftSim.CONST.TEXT.CUSTOMER_HISTORY_CRAFT_HISTORY_DATE_HEADER] = "日期",
        [CraftSim.CONST.TEXT.CUSTOMER_HISTORY_CRAFT_HISTORY_RESULT_HEADER] = "結果",
        [CraftSim.CONST.TEXT.CUSTOMER_HISTORY_CRAFT_HISTORY_TIP_HEADER] = "小費",
        [CraftSim.CONST.TEXT.CUSTOMER_HISTORY_CRAFT_HISTORY_CUSTOMER_REAGENTS_HEADER] = "客戶材料",
        [CraftSim.CONST.TEXT.CUSTOMER_HISTORY_CRAFT_HISTORY_CUSTOMER_NOTE_HEADER] = "備註",

        -- Craft Queue
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_TITLE] = "CraftSim 製造排程",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_CRAFT_AMOUNT_LEFT_HEADER] = "排程中",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_CRAFT_PROFESSION_GEAR_HEADER] = "專業裝備",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_CRAFTING_COSTS_HEADER] = "製造成本",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_CRAFT_BUTTON_ROW_LABEL] = "製造",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_CRAFT_BUTTON_ROW_LABEL_WRONG_GEAR] = "工具錯誤",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_CRAFT_BUTTON_ROW_LABEL_NO_MATS] = "沒有材料",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_ADD_OPEN_RECIPE_BUTTON_LABEL] = "加入開放材料",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_CLEAR_ALL_BUTTON_LABEL] = "全部清除",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_IMPORT_RECIPE_SCAN_BUTTON_LABEL] = "根據配方掃描補貨",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_CRAFT_BUTTON_ROW_LABEL_WRONG_PROFESSION] = "專業錯誤",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_CRAFT_BUTTON_ROW_LABEL_ON_COOLDOWN] = "冷卻中",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_CRAFT_NEXT_BUTTON_LABEL] = "製造下一個",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_CRAFT_AVAILABLE_AMOUNT] = "可製造",
        [CraftSim.CONST.TEXT.CRAFTQUEUE_AUCTIONATOR_SHOPPING_LIST_BUTTON_LABEL] = "建立拍賣小幫手購物清單",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_QUEUE_TAB_LABEL] = "製造排程",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_RESTOCK_OPTIONS_TAB_LABEL] = "補貨選項",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_RESTOCK_OPTIONS_GENERAL_PROFIT_THRESHOLD_LABEL] = "利潤門檻:",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_RESTOCK_OPTIONS_SALE_RATE_INPUT_LABEL] = "銷售比率門檻:",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_RESTOCK_OPTIONS_TSM_SALE_RATE_TOOLTIP] = string.format(
            [[
只有已載入 %s 時才可使用！

這會檢查已選擇的物品品質的%s銷售比率
是否大於或等於設定的銷售比率門檻。
]], f.bb("TSM"), f.bb("任何")),
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_RESTOCK_OPTIONS_TSM_SALE_RATE_TOOLTIP_GENERAL] = string.format(
            [[
只有已載入 %s 時才可使用！

這會檢查物品品質的%s銷售比率
是否大於或等於設定的銷售比率門檻。
]], f.bb("TSM"), f.bb("任何")),
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_RESTOCK_OPTIONS_AMOUNT_LABEL] = "補貨數量:",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_RESTOCK_OPTIONS_RESTOCK_TOOLTIP] = "這是該配方即將排程的" ..
            f.bb("製作數量") .. "。\n\n您在背包與銀行中擁有該星級數量的物品將從補貨數量中扣除",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_RESTOCK_OPTIONS_ENABLE_RECIPE_LABEL] = "啟用:",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_RESTOCK_OPTIONS_GENERAL_OPTIONS_LABEL] = "一般選項 (所有配方)",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_RESTOCK_OPTIONS_ENABLE_RECIPE_TOOLTIP] = "如果此選項為關閉，將根據上述的一般選項進補貨",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_TOTAL_PROFIT_LABEL] = "總計 Φ 利潤:",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_TOTAL_CRAFTING_COSTS_LABEL] = "總計製造成本:",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_EDIT_RECIPE_TITLE] = "編輯配方",

        -- static popups
        [CraftSim.CONST.TEXT.STATIC_POPUPS_YES] = "是",
        [CraftSim.CONST.TEXT.STATIC_POPUPS_NO] = "否",
    }
end
