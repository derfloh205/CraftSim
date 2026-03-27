---@class CraftSim
local CraftSim = select(2, ...)

CraftSim.LOCAL_KO = {}

---@return table<CraftSim.LOCALIZATION_IDS, string>
function CraftSim.LOCAL_KO:GetData()
    local f = CraftSim.GUTIL:GetFormatter()
    local cm = function(i, s) return CraftSim.MEDIA:GetAsTextIcon(i, s) end
    return {
        -- REQUIRED:
        STAT_MULTICRAFT = "복수 제작",
        STAT_RESOURCEFULNESS = "지혜",
        STAT_CRAFTINGSPEED = "제작 속도",
        EQUIP_MATCH_STRING = "착용 효과:",
        ENCHANTED_MATCH_STRING = "마법부여:",
        STAT_INGENUITY = "독창성",

        -- OPTIONAL (Defaulting to EN if not available):

        -- shared prof cds
        DF_ALCHEMY_TRANSMUTATIONS = "용군단 - 변환",
        MIDNIGHT_ALCHEMY_TRANSMUTATIONS = "한밤 – 변환",

        -- expansions

        EXPANSION_VANILLA = "클래식",
        EXPANSION_THE_BURNING_CRUSADE = "불타는 성전",
        EXPANSION_WRATH_OF_THE_LICH_KING = "리치 왕의 분노",
        EXPANSION_CATACLYSM = "대격변",
        EXPANSION_MISTS_OF_PANDARIA = "판다리아의 안개",
        EXPANSION_WARLORDS_OF_DRAENOR = "드레노어의 전쟁군주",
        EXPANSION_LEGION = "군단",
        EXPANSION_BATTLE_FOR_AZEROTH = "격전의 아제로스",
        EXPANSION_SHADOWLANDS = "어둠땅",
        EXPANSION_DRAGONFLIGHT = "용군단",
        EXPANSION_THE_WAR_WITHIN = "내부 전쟁",
        EXPANSION_MIDNIGHT = "미드나이트",

        -- professions

        PROFESSIONS_BLACKSMITHING = "대장기술",
        PROFESSIONS_LEATHERWORKING = "가죽세공",
        PROFESSIONS_ALCHEMY = "연금술",
        PROFESSIONS_HERBALISM = "약초채집",
        PROFESSIONS_COOKING = "요리",
        PROFESSIONS_MINING = "채광",
        PROFESSIONS_TAILORING = "재봉술",
        PROFESSIONS_ENGINEERING = "기계공학",
        PROFESSIONS_ENCHANTING = "마법부여",
        PROFESSIONS_FISHING = "낚시",
        PROFESSIONS_SKINNING = "무두질",
        PROFESSIONS_JEWELCRAFTING = "보석세공",
        PROFESSIONS_INSCRIPTION = "주문각인",

        -- Other Statnames

        STAT_SKILL = "숙련도",
        STAT_MULTICRAFT_BONUS = "복수 제작 추가 아이템",
        STAT_RESOURCEFULNESS_BONUS = "지혜 추가 아이템",
        STAT_CRAFTINGSPEED_BONUS = "제작 속도",
        STAT_INGENUITY_BONUS = "독창성 절약 집중",
        STAT_INGENUITY_LESS_CONCENTRATION = "집중 소모 감소",
        STAT_PHIAL_EXPERIMENTATION = "영약 실험 돌파",
        STAT_POTION_EXPERIMENTATION = "물약 실험 돌파",

        -- Profit Breakdown Tooltips
        RESOURCEFULNESS_EXPLANATION_TOOLTIP =         "지혜는 각 재료에 대해 개별적으로 발동하며, 해당 재료 수량의 약 30%를 절약합니다.\n\n표시되는 평균값은 모든 재료 조합과 그 확률을 계산한 평균 절약 수치입니다.\n(모든 재료가 동시에 절약될 확률은 매우 낮지만, 발생 시 매우 많은 재료를 아낄 수 있습니다)\n\n평균 총 절약 재료 비용은 각 조합의 확률을 가중치로 둔 절약 비용의 합계입니다.",

        RECIPE_DIFFICULTY_EXPLANATION_TOOLTIP =         "제작 난이도는 각 품질 단계에 도달하기 위한 숙련도 기준점을 결정합니다.\n\n5단계 품질 레시피의 경우, 숙련도가 난이도의 20%, 50%, 80%, 100%일 때 품질이 변합니다.\n3단계 품질 레시피는 50%와 100%가 기준점입니다.",
        MULTICRAFT_EXPLANATION_TOOLTIP =         "복수 제작은 레시피로 제작 시 평소보다 더 많은 아이템을 제작할 확률을 부여합니다.\n\n추가 생성량은 보통 기본 생산량(y)의 1배에서 2.5배 사이입니다.",
        REAGENTSKILL_EXPLANATION_TOOLTIP =         "재료의 품질은 기본 제작 난이도의 최대 40%까지 보너스 숙련도를 제공할 수 있습니다.\n\n모든 1성 재료: 보너스 0%\n모든 2성 재료: 보너스 20%\n모든 3성 재료: 보너스 40%\n\n숙련도는 각 품질별 재료 수량과 품질 가중치, 그리고 각 재료 아이템 고유의 가중치 값을 통해 계산됩니다.\n\n단, 재제작의 경우 다릅니다. 재제작 시 재료가 올릴 수 있는 최대 품질은 아이템이 원래 제작되었을 때 사용된 재료의 품질에 영향을 받습니다.\n정확한 공식은 공개되어 있지 않으나, CraftSim은 내부적으로 모든 3성 재료를 사용했을 때 도달 가능한 숙련도와 비교하여 최대 숙련도 상승치를 계산합니다.",
        REAGENTFACTOR_EXPLANATION_TOOLTIP =         "일반적으로 재료가 기여할 수 있는 최대 숙련도는 기본 제작 난이도의 40%입니다.\n\n하지만 재제작의 경우, 이전 제작 기록과 당시 사용된 재료 품질에 따라 이 수치가 달라질 수 있습니다.",

        -- Simulation Mode
        SIMULATION_MODE_NONE = "없음",
        SIMULATION_MODE_LABEL = "시뮬레이션 모드",
        SIMULATION_MODE_TITLE = "CraftSim 시뮬레이션 모드",
        SIMULATION_MODE_TOOLTIP =         "CraftSim의 시뮬레이션 모드를 사용하면 제한 없이 레시피를 테스트해 볼 수 있습니다.",
        SIMULATION_MODE_OPTIONAL = "선택 재료 #",
        SIMULATION_MODE_FINISHING = "마무리 재료 #",
        SIMULATION_MODE_QUALITY_BUTTON_TOOLTIP = "모든 재료 품질 최대화: ",
        SIMULATION_MODE_CLEAR_BUTTON = "초기화",
        SIMULATION_MODE_CONCENTRATION = " 집중",
        SIMULATION_MODE_CONCENTRATION_COST = "집중 소모량: ",
        CONCENTRATION_ESTIMATED_TIME_UNTIL = "제작 가능 시간: %s",
        SIMULATION_MODE_QUALITY_METER_NEEDED = "필요 숙련도: ",
        SIMULATION_MODE_QUALITY_METER_MISSING = "부족 숙련도: ",
        SIMULATION_MODE_QUALITY_METER_MAX = "최대",

        -- Details Frame
        RECIPE_DIFFICULTY_LABEL = "제작 난이도: ",
        MULTICRAFT_LABEL = "복수 제작: ",
        RESOURCEFULNESS_LABEL = "지혜: ",
        RESOURCEFULNESS_BONUS_LABEL = "지혜 아이템 보너스: ",
        INGENUITY_LABEL = "독창성: ",
        INGENUITY_EXPLANATION_TOOLTIP =         "독창성은 집중을 사용하여 제작할 때 사용한 집중의 일부를 돌려받을 확률을 부여합니다.",
        CONCENTRATION_LABEL = "집중: ",
        REAGENT_QUALITY_BONUS_LABEL = "재료 품질 보너스: ",
        REAGENT_QUALITY_MAXIMUM_LABEL = "재료 품질 최대 %: ",
        EXPECTED_QUALITY_LABEL = "예상 품질: ",
        NEXT_QUALITY_LABEL = "다음 품질: ",
        MISSING_SKILL_LABEL = "부족한 숙련도: ",
        SKILL_LABEL = "숙련도: ",
        MULTICRAFT_BONUS_LABEL = "복수 제작 아이템 보너스: ",

        -- Statistics (통계)
        STATISTICS_CDF_EXPLANATION = "이 수치는 누적 분포 함수(CDF)의 'abramowitz and stegun' 근사치(1985)를 사용하여 계산되었습니다.\n\n제작 횟수가 1회일 때 수치가 항상 50% 부근인 것을 알 수 있는데,\n이는 대부분의 경우 0이 평균 수익에 가깝기 때문입니다.\n그리고 누적 분포 함수에서 평균값을 얻을 확률은 항상 50%입니다.\n\n하지만 변화율은 제작법마다 크게 다를 수 있습니다.\n손해보다 이익을 볼 확률이 더 높다면 수치는 꾸준히 상승할 것이며,\n그 반대의 경우도 마찬가지입니다.",

        EXPLANATIONS_PROFIT_CALCULATION_EXPLANATION = f.r("경고: ") .. " 수학 주의!\n\n" ..
            "무언가를 제작할 때, 여러분의 제작 능력치에 따라 결과물에 대한 다양한 확률을 갖게 됩니다.\n" ..
            "통계학에서는 이를 " .. f.l("확률 분포") .. "라고 부릅니다.\n" ..
            "하지만 각 발동(Proc) 확률의 합이 1이 되지 않는다는 점을 발견하실 텐데,\n" ..
            "(확률 분포가 되려면 어떤 일이든 일어날 확률의 합이 100%가 되어야 합니다)\n\n" ..
            "그 이유는 " .. f.bb("재활용 ") .. "이나 " .. f.bb("복수 제작") .. " 같은 효과들이 " .. f.g("동시에 발생할 수 있기 때문입니다.\n") ..
            "따라서 먼저 우리는 발동 확률을 모든 경우의 수를 포함하는 합계 100%의 " ..
            f.l("확률 분포") .. "로 변환해야 합니다.\n" ..
            "이를 위해 한 번의 제작에서 발생할 수 있는 " .. f.l("모든") .. " 결과의 수를 계산해야 하죠.\n\n" ..
            "예를 들어: \n" ..
            f.p .. "아무것도 " .. f.bb("발동하지 않을") .. " 확률은?\n" ..
            f.p .. f.bb("재활용") .. " 혹은 " .. f.bb("복수 제작") .. " 중 하나만 발동할 확률은?\n" ..
            f.p .. f.bb("재활용") .. "과 " .. f.bb("복수 제작") .. "이 모두 발동할 확률은?\n" ..
            f.p .. "기타 등등..\n\n" ..
            "모든 발동 효과를 고려하는 제작법의 경우, 결과의 가짓수는 2의 2제곱인 4가지가 됩니다.\n" ..
            f.bb("복수 제작") .. "만 발생할 확률을 구하려면 다른 모든 가능성을 고려해야 합니다!\n" ..
            f.l("오직 ") .. f.bb("복수 제작") .. "만 발동할 확률은 실제로는 " .. f.bb("복수 제작") .. "이 발동하고\n" ..
            f.bb("재활용") .. "은 발동하지 " .. f.l("않을 ") .. "확률입니다.\n" ..
            "수학적으로 어떤 사건이 일어나지 않을 확률은 '1 - 일어날 확률'입니다.\n" ..
            "따라서 오직 " .. f.bb("복수 제작") .. "만 발동할 실제 확률은\n" ..
            f.g("복수제작확률 * (1-재활용확률)\n\n") ..
            "이런 방식으로 각 가능성을 계산하면 개별 확률의 합이 정확히 1이 됩니다!\n" ..
            "이제 통계 공식을 적용할 수 있게 된 것이죠. 우리에게 가장 흥미로운 공식은 바로 " ..
            f.bb("기댓값") .. "입니다.\n" ..
            "이름에서 알 수 있듯이, 이는 우리가 평균적으로 얻을 것이라 기대할 수 있는 값이며, 우리 상황에서는 " ..
            f.bb(" 제작당 예상 수익") .. "을 의미합니다!\n" ..
            "\n" .. cm(CraftSim.MEDIA.IMAGES.EXPECTED_VALUE) .. "\n\n" ..
            "이 공식은 확률 분포 " .. f.l("X") .. "의 기댓값 " .. f.l("E") .. "가 모든 값에 각각의 확률을 곱한 것의 합임을 알려줍니다.\n" ..
            "만약 우리가 " ..
            f.bb("30% 확률의 사례 A") .. "에서 수익이 " ..
            CraftSim.UTIL:FormatMoney(-100 * 10000, true) .. "이고,\n" ..
            f.bb("70% 확률의 사례 B") .. "에서 수익이 " .. 
            CraftSim.UTIL:FormatMoney(300 * 10000, true) .. "라면, 예상 수익은 다음과 같습니다.\n" ..
            f.bb("\nE(X) = -100*0.3 + 300*0.7  ") ..
            "결과는 " .. CraftSim.UTIL:FormatMoney((-100 * 0.3 + 300 * 0.7) * 10000, true) .. "가 됩니다.\n" ..
            "현재 제작법에 대한 모든 사례는 " .. f.bb("통계") .. " 창에서 확인하실 수 있습니다!"
        ,

        -- Popups
        POPUP_NO_PRICE_SOURCE_SYSTEM = "지원되는 가격 출처가 없습니다!",
        POPUP_NO_PRICE_SOURCE_TITLE = "CraftSim 가격 출처 경고",
        POPUP_NO_PRICE_SOURCE_WARNING =         "가격 출처를 찾을 수 없습니다!\n\nCraftSim의 이익 계산 기능을 사용하려면\n다음 가격 출처 애드온 중 하나를\n반드시 설치해야 합니다:\n\n\n",
        POPUP_NO_PRICE_SOURCE_WARNING_SUPPRESS = "이 경고를 다시 표시하지 않음",
        POPUP_NO_PRICE_SOURCE_WARNING_ACCEPT = "확인",

        -- Reagents Frame
        REAGENT_OPTIMIZATION_TITLE = "CraftSim 재료 최적화",
        REAGENTS_REACHABLE_QUALITY = "도달 가능한 품질: ",
        REAGENTS_MISSING = "재료 부족",
        REAGENTS_AVAILABLE = "재료 보유 중",
        REAGENTS_CHEAPER = "최저가 재료",
        REAGENTS_BEST_COMBINATION = "최적의 조합 할당됨",
        REAGENTS_NO_COMBINATION = "품질을 높일 수 있는\n조합을 찾지 못했습니다",
        REAGENTS_ASSIGN = "할당",
        REAGENTS_MAXIMUM_QUALITY = "최대 품질: ",
        REAGENTS_AVERAGE_PROFIT_LABEL = "평균 Ø 이익: ",
        REAGENTS_AVERAGE_PROFIT_TOOLTIP =             f.bb("제작당 평균 이익") .. " ( " .. f.l("현재 재료 배분") .. " 시)",
        REAGENTS_OPTIMIZE_BEST_ASSIGNED = "최적 재료 할당됨",
        REAGENTS_CONCENTRATION_LABEL = "집중: ",
        REAGENTS_OPTIMIZE_INFO = "숫자 위에서 Shift + 클릭 시 아이템 링크를 채팅창에 입력",
        ADVANCED_OPTIMIZATION_BUTTON = "고급 최적화",
        REAGENTS_OPTIMIZE_TOOLTIP =             "(수정 시 초기화)\n" .. 
            f.gold("집중 가치") .. " 및 " .. f.bb("마무리 재료") .. " 최적화 활성화",

        -- Specialization Info Frame
        SPEC_INFO_TITLE = "CraftSim 전문화 정보",
        SPEC_INFO_SIMULATE_KNOWLEDGE_DISTRIBUTION = "지식 포인트 배분 시뮬레이션",
        SPEC_INFO_NODE_TOOLTIP = "이 노드는 해당 레시피에 대해 다음 능력치를 부여합니다:",
        SPEC_INFO_WORK_IN_PROGRESS = "데이터 없음",

        -- Crafting Results Frame
        CRAFT_LOG_TITLE = "CraftSim 제작 기록",
        CRAFT_LOG_ADV_TITLE = "CraftSim 고급 제작 기록",
        CRAFT_LOG_LOG = "제작 로그",
        CRAFT_LOG_LOG_1 = "이익: ",
        CRAFT_LOG_LOG_2 = "절약된 집중: ",
        CRAFT_LOG_LOG_3 = "복수 제작: ",
        CRAFT_LOG_LOG_4 = "절약된 자원: ",
        CRAFT_LOG_LOG_5 = "확률: ",
        CRAFT_LOG_CRAFTED_ITEMS = "제작된 아이템",
        CRAFT_LOG_SESSION_PROFIT = "세션 총 이익: ",
        CRAFT_LOG_RESET_DATA = "데이터 초기화",
        CRAFT_LOG_EXPORT_JSON = "JSON 내보내기",
        CRAFT_LOG_RECIPE_STATISTICS = "레시피 통계",
        CRAFT_LOG_NOTHING = "아직 제작된 내역이 없습니다!",
        CRAFT_LOG_CALCULATION_COMPARISON_NUM_CRAFTS_PREFIX = "제작 횟수: ",
        CRAFT_LOG_STATISTICS_2 = "예상 Ø 이익: ",
        CRAFT_LOG_STATISTICS_3 = "실제 Ø 이익: ",
        CRAFT_LOG_STATISTICS_4 = "실제 총 이익: ",
        CRAFT_LOG_STATISTICS_5 = "발동 - 실제 / 예상: ",
        CRAFT_LOG_STATISTICS_7 = "복수 제작: ",
        CRAFT_LOG_STATISTICS_8 = "- Ø 추가 아이템: ",
        CRAFT_LOG_STATISTICS_9 = "지혜 발동: ",
        CRAFT_LOG_CALCULATION_COMPARISON_NUM_CRAFTS_PREFIX0 = "- Ø 절약 비용: ",
        CRAFT_LOG_CALCULATION_COMPARISON_NUM_CRAFTS_PREFIX1 = "이익: ",
        CRAFT_LOG_SAVED_REAGENTS = "절약된 재료",
        CRAFT_LOG_DISABLE_CHECKBOX = f.r("비활성화") .. " 제작 기록",
        CRAFT_LOG_DISABLE_CHECKBOX_TOOLTIP =             "비활성화 시 제작 중 기록을 중단하며 " ..f.g("성능이 향상") .. "될 수 있습니다.",
        CRAFT_LOG_REAGENT_DETAILS_TAB = "재료 상세",
        CRAFT_LOG_RESULT_ANALYSIS_TAB = "결과 분석",
        CRAFT_LOG_RESULT_ANALYSIS_TAB_DISTRIBUTION_LABEL = "결과 분포",
        CRAFT_LOG_RESULT_ANALYSIS_TAB_DISTRIBUTION_HELP =         "제작된 아이템 결과의 상대적 분포입니다.\n(복수 제작 수량 제외)",
        CRAFT_LOG_RESULT_ANALYSIS_TAB_MULTICRAFT = "복수 제작",
        CRAFT_LOG_RESULT_ANALYSIS_TAB_RESOURCEFULNESS = "지혜",
        CRAFT_LOG_RESULT_ANALYSIS_TAB_YIELD_DDISTRIBUTION = "생산량 분포",

        -- Stats Weight Frame
        STAT_WEIGHTS_TITLE = "CraftSim 평균 이익",
        EXPLANATIONS_TITLE = "CraftSim 평균 이익 설명",
        STAT_WEIGHTS_SHOW_EXPLANATION_BUTTON = "설명 보기",
        STAT_WEIGHTS_HIDE_EXPLANATION_BUTTON = "설명 숨기기",
        STAT_WEIGHTS_SHOW_STATISTICS_BUTTON = "통계 보기",
        STAT_WEIGHTS_HIDE_STATISTICS_BUTTON = "통계 숨기기",
        STAT_WEIGHTS_PROFIT_CRAFT = "제작당 Ø 이익: ",
        EXPLANATIONS_BASIC_PROFIT_TAB = "기본 이익 계산",

        -- Cost Details Frame
        COST_OPTIMIZATION_TITLE = "CraftSim 비용 최적화",
        COST_OPTIMIZATION_EXPLANATION =             "사용된 재료에 대해 가능한 모든 가격 개요를 확인할 수 있습니다.\n" ..
            f.bb("'사용된 출처'") ..
            " 열은 현재 어떤 가격이 계산에 사용되고 있는지 나타냅니다.\n\n" ..
            f.g("AH") ..
            " .. 경매장 가격\n" ..
            f.l("OR") ..
            " .. 가격 직접 설정(재정의)\n" ..
            f.bb("캐릭터명") ..
            " .. 직접 제작 시 예상 비용\n\n" ..
            f.l("OR") ..
            " 값이 설정되어 있으면 항상 우선적으로 사용됩니다. " ..
            f.bb("제작 비용") .. "은 " .. f.g("AH") .. " 가격보다 낮을 때만 사용됩니다.\n\n" ..
            "임의의 재료를 " .. f.bb("우클릭") .. "하여 가격을 원하는 값으로 직접 설정할 수 있습니다.",
        COST_OPTIMIZATION_CRAFTING_COSTS = "제작 비용: ",
        COST_OPTIMIZATION_ITEM_HEADER = "아이템",
        COST_OPTIMIZATION_AH_PRICE_HEADER = "경매장 가격",
        COST_OPTIMIZATION_OVERRIDE_HEADER = "직접 설정",
        COST_OPTIMIZATION_CRAFTING_HEADER = "제작",
        COST_OPTIMIZATION_USED_SOURCE = "사용된 출처",
        COST_OPTIMIZATION_REAGENT_COSTS_TAB = "재료 비용",
        COST_OPTIMIZATION_SUB_RECIPE_OPTIONS_TAB = "하위 레시피 옵션",
        COST_OPTIMIZATION_SUB_RECIPE_OPTIMIZATION = "하위 레시피 최적화 " ..
            f.bb("(실험적 기능)"),
        COST_OPTIMIZATION_SUB_RECIPE_OPTIMIZATION_TOOLTIP = 
            f.l("CraftSim") .. "이 현재 캐릭터와 부캐릭터가 해당 아이템을 제작할 수 있는 경우,\n해당 캐릭터들의 " .. f.g("최적화된 제작 비용") ..
            "을 고려합니다.\n\n" ..
            f.r("추가 계산량이 많아 성능이 다소 저하될 수 있습니다."),
        COST_OPTIMIZATION_SUB_RECIPE_MAX_DEPTH_LABEL = "하위 레시피 계산 깊이",
        COST_OPTIMIZATION_SUB_RECIPE_INCLUDE_CONCENTRATION = "집중 활성화",
        COST_OPTIMIZATION_SUB_RECIPE_INCLUDE_CONCENTRATION_TOOLTIP = "활성화 시, " ..
            f.l("CraftSim") .. "은 집중이 필요한 경우에도 재료 품질을 포함하여 계산합니다.",
        COST_OPTIMIZATION_SUB_RECIPE_INCLUDE_COOLDOWN_RECIPES = "재사용 대기시간 레시피 포함",
        COST_OPTIMIZATION_SUB_RECIPE_INCLUDE_COOLDOWN_RECIPES_TOOLTIP = "활성화 시, " ..
            f.l("CraftSim") .. "은 직접 제작 재료를 계산할 때 레시피의 재사용 대기시간 제한을 무시합니다.",
        COST_OPTIMIZATION_SUB_RECIPE_SELECT_RECIPE_CRAFTER = "레시피 제작자 선택",
        COST_OPTIMIZATION_REAGENT_LIST_AH_COLUMN_AUCTION_BUYOUT = "경매장 즉시 구매가가: ",
        COST_OPTIMIZATION_REAGENT_LIST_OVERRIDE = "\n\n직접 설정됨",
        COST_OPTIMIZATION_REAGENT_LIST_EXPECTED_COSTS_TOOLTIP = "\n\n제작 중 ",
        COST_OPTIMIZATION_REAGENT_LIST_EXPECTED_COSTS_PRE_ITEM = "\n- 아이템당 예상 비용: ",
        COST_OPTIMIZATION_REAGENT_LIST_CONCENTRATION_COST = f.gold("집중 비용: "),
        COST_OPTIMIZATION_REAGENT_LIST_CONCENTRATION = "집중: ",

        -- Statistics Frame
        STATISTICS_TITLE = "CraftSim 통계",
        STATISTICS_EXPECTED_PROFIT = "예상 이익 (μ)",
        STATISTICS_CHANCE_OF = "확률: ",
        STATISTICS_PROFIT = "이익",
        STATISTICS_AFTER = " (이후)",
        STATISTICS_CRAFTS = "제작 횟수: ",
        STATISTICS_QUALITY_HEADER = "품질",
        STATISTICS_MULTICRAFT_HEADER = "복수 제작",
        STATISTICS_RESOURCEFULNESS_HEADER = "지혜",
        STATISTICS_EXPECTED_PROFIT_HEADER = "예상 이익",
        PROBABILITY_TABLE_TITLE = "레시피 확률표",
        STATISTICS_PROBABILITY_TABLE_TAB = "확률표",
        STATISTICS_CONCENTRATION_TAB = "집중",
        STATISTICS_CONCENTRATION_CURVE_GRAPH = "집중 비용 곡선",
        STATISTICS_CONCENTRATION_CURVE_GRAPH_HELP =             "해당 레시피에 대한 플레이어 숙련도별 집중 비용\n" ..
            f.bb("X축: ") .. " 플레이어 숙련도\n" ..
            f.bb("Y축: ") .. " 집중 비용",

        -- Price Details Frame
        COST_OVERVIEW_TITLE = "CraftSim 가격 상세",
        PRICE_DETAILS_INV_AH = "보유/경매장",
        PRICE_DETAILS_ITEM = "아이템",
        PRICE_DETAILS_PRICE_ITEM = "개당 가격",
        PRICE_DETAILS_PROFIT_ITEM = "개당 이익",

        -- Price Override Frame
        PRICE_OVERRIDE_TITLE = "CraftSim 가격 직접 설정",
        PRICE_OVERRIDE_HINT = "(이제 " .. f.bb("비용 최적화 모듈") .. "에서 직접 가격을 설정할 수 있습니다)",
        PRICE_OVERRIDE_REQUIRED_REAGENTS = "필수 재료",
        PRICE_OVERRIDE_OPTIONAL_REAGENTS = "선택 재료",
        PRICE_OVERRIDE_FINISHING_REAGENTS = "마무리 재료",
        PRICE_OVERRIDE_RESULT_ITEMS = "결과 아이템",
        PRICE_OVERRIDE_ACTIVE_OVERRIDES = "활성화된 직접 설정",
        PRICE_OVERRIDE_ACTIVE_OVERRIDES_TOOLTIP =         "'(결과물)' -> 해당 아이템이 레시피의 결과물일 때만 가격 설정을 고려합니다.",
        PRICE_OVERRIDE_CLEAR_ALL = "모두 삭제",
        PRICE_OVERRIDE_SAVE = "저장",
        PRICE_OVERRIDE_SAVED = "저장됨",
        PRICE_OVERRIDE_REMOVE = "제거",

	    -- Recipe Scan Frame
        RECIPE_SCAN_TITLE = "CraftSim 레시피 스캔",
        RECIPE_SCAN_MODE = "스캔 모드",
        RECIPE_SCAN_SORT_MODE = "정렬 모드",
        RECIPE_SCAN_SCAN_RECIPIES = "레시피 스캔",
        RECIPE_SCAN_SCAN_CANCEL = "취소",
        RECIPE_SCAN_SCANNING = "스캔 중",
        RECIPE_SCAN_INCLUDE_NOT_LEARNED = "미습득 레시피 포함",
        RECIPE_SCAN_INCLUDE_NOT_LEARNED_TOOLTIP =         "배우지 않은 레시피도 레시피 스캔 결과에 포함합니다.",
        RECIPE_SCAN_INCLUDE_SOULBOUND = "귀속 아이템 포함",
        RECIPE_SCAN_INCLUDE_SOULBOUND_TOOLTIP =         "획득 시 귀속되는 레시피 결과물을 스캔에 포함합니다.\n\n해당 레시피의 제작 아이템에 대해 '가격 직접 설정' 모듈에서\n예상 수수료 등을 미리 설정해두는 것을 권장합니다.",
        RECIPE_SCAN_INCLUDE_GEAR = "장비 포함",
        RECIPE_SCAN_INCLUDE_GEAR_TOOLTIP = "모든 형태의 장비 제작 레시피를 스캔에 포함합니다.",
        RECIPE_SCAN_OPTIMIZE_TOOLS = "기술 도구 최적화",
        RECIPE_SCAN_OPTIMIZE_TOOLS_TOOLTIP =         "각 레시피별로 이익을 최대화할 수 있는 전문 기술 도구 조합을 최적화합니다.\n\n",
        RECIPE_SCAN_OPTIMIZE_TOOLS_WARNING =         "소지품에 도구가 많을 경우 스캔 중 성능이 저하될 수 있습니다.",
        RECIPE_SCAN_CRAFTER_HEADER = "제작자",
        RECIPE_SCAN_RECIPE_HEADER = "레시피",
        RECIPE_SCAN_LEARNED_HEADER = "습득 여부",
        RECIPE_SCAN_RESULT_HEADER = "결과",
        RECIPE_SCAN_AVERAGE_PROFIT_HEADER = "Ø 이익",
        RECIPE_SCAN_CONCENTRATION_VALUE_HEADER = "집중 가치",
        RECIPE_SCAN_CONCENTRATION_COST_HEADER = "집중 비용",
        RECIPE_SCAN_TOP_GEAR_HEADER = "최적 도구",
        RECIPE_SCAN_INV_AH_HEADER = "보유/경매장",
        RECIPE_SCAN_SORT_BY_MARGIN = "이익률 기준 정렬",
        RECIPE_SCAN_SORT_BY_MARGIN_TOOLTIP =         "제작 비용 대비 이익률(%)을 기준으로 목록을 정렬합니다.\n(새로 스캔해야 적용됨)",
        RECIPE_SCAN_USE_INSIGHT_CHECKBOX = "가능한 경우 " .. f.bb("통찰") .. " 사용",
        RECIPE_SCAN_USE_INSIGHT_CHECKBOX_TOOLTIP = "선택 재료를 사용할 수 있는 레시피에\n" ..
            f.bb("빛나는 통찰") .. " 또는 " .. f.bb("하급 빛나는 통찰") .. "을 적용하여 계산합니다.",
        RECIPE_SCAN_ONLY_FAVORITES_CHECKBOX = "즐겨찾기만",
        RECIPE_SCAN_ONLY_FAVORITES_CHECKBOX_TOOLTIP = "즐겨찾기에 등록된 레시피만 스캔합니다.",
        RECIPE_SCAN_EQUIPPED = "착용 중",
        RECIPE_SCAN_MODE_OPTIMIZE = "최적화",
        RECIPE_SCAN_SORT_MODE_PROFIT = "이익",
        RECIPE_SCAN_SORT_MODE_RELATIVE_PROFIT = "상대 이익",
        RECIPE_SCAN_SORT_MODE_CONCENTRATION_VALUE = "집중 가치",
        RECIPE_SCAN_SORT_MODE_CONCENTRATION_COST = "집중 비용",
        RECIPE_SCAN_SORT_MODE_CRAFTING_COST = "제작 비용",
        RECIPE_SCAN_EXPANSION_FILTER_BUTTON = "확장팩 필터",
        RECIPE_SCAN_ALTPROFESSIONS_FILTER_BUTTON = "부캐릭터 전문 기술",
        RECIPE_SCAN_SCAN_ALL_BUTTON_READY = "전문 기술 스캔",
        RECIPE_SCAN_SCAN_ALL_BUTTON_SCANNING = "스캔 중...",
        RECIPE_SCAN_TAB_LABEL_SCAN = "레시피 스캔",
        RECIPE_SCAN_TAB_LABEL_OPTIONS = "스캔 옵션",
        RECIPE_SCAN_IMPORT_ALL_PROFESSIONS_CHECKBOX_LABEL = "스캔된 모든 전문 기술",
        RECIPE_SCAN_IMPORT_ALL_PROFESSIONS_CHECKBOX_TOOLTIP = f.g("활성화: ") ..
            "활성화되어 스캔된 모든 전문 기술의 결과를 가져옵니다.\n\n" ..
            f.r("비활성화: ") .. "현재 선택된 전문 기술의 결과만 가져옵니다.",
        RECIPE_SCAN_CACHED_RECIPES_TOOLTIP =             "캐릭터로 레시피를 열거나 스캔할 때마다 " ..
            f.l("CraftSim") ..
            "이 이를 기억합니다.\n\n" .. f.l("CraftSim") .. "이 기억하는 부캐릭터의 레시피만 " .. f.bb("레시피 스캔") .. "으로 스캔할 수 있습니다.\n\n" ..
            "실제로 스캔되는 레시피의 양은 " .. f.e("레시피 스캔 옵션") .. " 설정에 따릅니다.",
        RECIPE_SCAN_CONCENTRATION_TOGGLE = " 집중",
        RECIPE_SCAN_CONCENTRATION_TOGGLE_TOOLTIP = "집중 사용 여부 전환",
        RECIPE_SCAN_OPTIMIZE_SUBRECIPES = "하위 레시피 최적화 " .. f.bb("(실험적)"),
        RECIPE_SCAN_OPTIMIZE_SUBRECIPES_TOOLTIP = "활성화 시, " ..
            f.l("CraftSim") .. "은 저장된 하위 재료 레시피의 제작도 최적화하며,\n그 " ..
            f.bb("예상 비용") .. "을 최종 제품의 제작 비용 계산에 사용합니다.\n\n" ..
            f.r("주의: 스캔 성능이 크게 저하될 수 있습니다."),
        RECIPE_SCAN_CACHED_RECIPES = "캐시된 레시피: ",
        RECIPE_SCAN_ENABLE_CONCENTRATION = f.gold("집중") .. f.bb(" 활성화"),
        RECIPE_SCAN_ONLY_FAVORITES = f.bb("즐겨찾기") .. f.r("만"),
        RECIPE_SCAN_INCLUDE_SOULBOUND_ITEMS = f.e("귀속") .. " 아이템 포함",
        RECIPE_SCAN_INCLUDE_UNLEARNED_RECIPES = f.r("미습득") .. " 레시피 포함",
        RECIPE_SCAN_INCLUDE_GEAR_LABEL = "장비 포함",
        RECIPE_SCAN_REAGENT_ALLOCATION = "재료 할당",
        RECIPE_SCAN_REAGENT_ALLOCATION_Q1 = "모두 1성",
        RECIPE_SCAN_REAGENT_ALLOCATION_Q2 = "모두 2성",
        RECIPE_SCAN_REAGENT_ALLOCATION_Q3 = "모두 3성",
        RECIPE_SCAN_AUTOSELECT_TOP_PROFIT = f.g("최고 이익 품질") .. " 자동 선택",
        RECIPE_SCAN_OPTIMIZE_PROFESSION_GEAR = f.bb("전문 기술 장비") .. " 최적화",
        RECIPE_SCAN_OPTIMIZE_CONCENTRATION = f.gold("집중") .. " 최적화",
        RECIPE_SCAN_OPTIMIZE_FINISHING_REAGENTS = f.bb("마무리에 재료") .. " 최적화",


        -- Shared OptimizationOptions Widget (공유 최적화 옵션 위젯)
        OPTIMIZATION_OPTIONS_OPTIMIZE_PROFESSION_TOOLS = f.bb("전문 기술 도구") .. " 최적화",
        OPTIMIZATION_OPTIONS_INCLUDE_SOULBOUND_FINISHING_REAGENTS = f.e("획득 시 귀속") .. f.bb(" 마무리 재료") .. " 포함",

        RECIPE_SCAN_SEND_TO_CRAFT_QUEUE = "제작 대기열로 보내기",
        RECIPE_SCAN_CREATE_CRAFT_LIST = "제작 목록 만들기",
        RECIPE_SCAN_SEND_TO_CRAFTQUEUE_CREATE_CRAFT_LIST = "대신 " .. f.bb("제작 목록") .. " 만들기",
        RECIPE_SCAN_ADD_TO_CRAFT_LIST = "제작 목록에 " .. f.g("추가"),
        RECIPE_SCAN_REMOVE_FROM_CRAFT_LIST = "제작 목록에서 " .. f.r("제거"),
        RECIPE_SCAN_CRAFT_LISTS_TOOLTIP_HEADER = f.bb("제작 목록") .. ":",
        RECIPE_SCAN_PROFIT_MARGIN_THRESHOLD = "수익률 임계값 (%): ",
        RECIPE_SCAN_DEFAULT_QUEUE_AMOUNT = "기본 대기열 수량: ",
        RECIPE_SCAN_ADD_TO_CRAFT_QUEUE = "제작 대기열에 추가",
        RECIPE_SCAN_SORT_BY = "정렬 기준",
        RECIPE_SCAN_SORT_ASCENDING = "오름차순",
        RECIPE_SCAN_REMOVE_FAVORITE = "즐겨찾기 " .. f.r("제거"),
        RECIPE_SCAN_ADD_FAVORITE = "즐겨찾기 " .. f.g("추가"),
        RECIPE_SCAN_FAVORITES_CRAFTER_ONLY = f.r("즐겨찾기는 해당 제작자 캐릭터에서만 변경할 수 있습니다."),
        RECIPE_SCAN_QUEUE_HINT = CreateAtlasMarkup("NPE_LeftClick", 20, 20, 2) .. " + Shift 키를 눌러 선택한 제작법을 " ..
            f.bb("제작 대기열") .. "에 추가합니다.",
        RECIPE_SCAN_REMOVE_CACHED_DATA = f.r("제거"),
        RECIPE_SCAN_REMOVE_CACHED_DATA_TOOLTIP = "이 캐릭터와 전문 기술 조합에 대한 " .. f.r("모든 캐시 데이터") .. "를 제거합니다.",
        RECIPE_SCAN_USE_TSM_RESTOCK = f.bb("TSM") .. " 재입고 수량 공식 사용",
        RECIPE_SCAN_TSM_SALE_RATE_THRESHOLD = f.bb("TSM") .. " 판매율 임계값: ",
        RECIPE_SCAN_AUTOSELECT_OPEN_PROFESSION = f.bb("연 전문 기술") .. " 자동 선택",

        -- Recipe Top Gear
        TOP_GEAR_TITLE = "CraftSim 최적 도구",
        TOP_GEAR_AUTOMATIC = "자동 업데이트",
        TOP_GEAR_AUTOMATIC_TOOLTIP =         "레시피가 업데이트될 때마다 선택한 모드에 맞춰 최적 도구를 자동으로 시뮬레이션합니다.\n\n이 기능을 끄면 성능이 향상될 수 있습니다.",
        TOP_GEAR_SIMULATE = "최적 도구 시뮬레이션",
        TOP_GEAR_EQUIP = "착용",
        TOP_GEAR_SIMULATE_QUALITY = "품질: ",
        TOP_GEAR_SIMULATE_EQUIPPED = "최적 도구 착용 중",
        TOP_GEAR_SIMULATE_PROFIT_DIFFERENCE = "Ø 이익 차이\n",
        TOP_GEAR_SIMULATE_NEW_MUTLICRAFT = "새 복수 제작\n",
        TOP_GEAR_SIMULATE_NEW_CRAFTING_SPEED = "새 제작 속도\n",
        TOP_GEAR_SIMULATE_NEW_RESOURCEFULNESS = "새 지혜\n",
        TOP_GEAR_SIMULATE_NEW_SKILL = "새 숙련도\n",
        TOP_GEAR_SIMULATE_UNHANDLED = "알 수 없는 시뮬레이션 모드",

        TOP_GEAR_SIM_MODES_PROFIT = "최고 이익",
        TOP_GEAR_SIM_MODES_SKILL = "최고 숙련도",
        TOP_GEAR_SIM_MODES_MULTICRAFT = "최고 복수 제작",
        TOP_GEAR_SIM_MODES_RESOURCEFULNESS = "최고 지혜",
        TOP_GEAR_SIM_MODES_CRAFTING_SPEED = "최고 제작 속도",

        -- Options
        OPTIONS_TITLE = "CraftSim 옵션",
        OPTIONS_GENERAL_TAB = "일반",
        OPTIONS_GENERAL_PRICE_SOURCE = "가격 출처",
        OPTIONS_GENERAL_CURRENT_PRICE_SOURCE = "현재 가격 출처: ",
        OPTIONS_GENERAL_NO_PRICE_SOURCE = "지원되는 가격 출처 애드온이 로드되지 않았습니다!",
        OPTIONS_GENERAL_SHOW_PROFIT = "이익 백분율 표시",
        OPTIONS_GENERAL_SHOW_PROFIT_TOOLTIP =         "골드 값 옆에 제작 비용 대비 이익의 백분율을 표시합니다.",
        OPTIONS_GENERAL_REMEMBER_LAST_RECIPE = "마지막 레시피 기억",
        OPTIONS_GENERAL_REMEMBER_LAST_RECIPE_TOOLTIP =         "제작 창을 열 때 마지막으로 선택했던 레시피를 다시 엽니다.",
        OPTIONS_GENERAL_SUPPORTED_PRICE_SOURCES = "지원되는 가격 출처:",
        OPTIONS_PERFORMANCE_RAM = "제작 중 RAM 정리 활성화",
        OPTIONS_PERFORMANCE_RAM_CRAFTS = "제작 횟수",
        OPTIONS_PERFORMANCE_RAM_TOOLTIP =         "활성화 시, 지정된 제작 횟수마다 사용하지 않는 데이터를 정리하여 RAM 점유율 상승을 방지합니다.\n메모리 누수는 타 애드온에 의해서도 발생할 수 있으며, 이 정리는 WoW 전체의 RAM 사용량에 영향을 줍니다.",
        OPTIONS_MODULES_TAB = "모듈",
        OPTIONS_PROFIT_CALCULATION_TAB = "이익 계산",
        OPTIONS_CRAFTING_TAB = "제작",
        OPTIONS_TSM_RESET = "기본값 초기화",
        OPTIONS_TSM_INVALID_EXPRESSION = "잘못된 식",
        OPTIONS_TSM_VALID_EXPRESSION = "유효한 식",
        OPTIONS_TSM_DEPOSIT_ENABLED_LABEL = "예상 보증금 비용 포함",
        OPTIONS_TSM_DEPOSIT_ENABLED_TOOLTIP = "이익 계산 시 예상되는 경매장 보증금을 차감합니다.\nTSM 데이터를 사용하여 물품 등록 시 지불할 보증금을 추정합니다.",
        OPTIONS_TSM_DEPOSIT_EXPRESSION_LABEL = "TSM 보증금 식",
        OPTIONS_TSM_SMART_RESTOCK_ENABLED_LABEL = "스마트 재입고 (인벤토리 차감)",
        OPTIONS_TSM_SMART_RESTOCK_ENABLED_TOOLTIP = "제작 대기열로 보낼 때 이미 보유 중인 아이템(가방, 은행, 부캐릭터, 전투부대 은행) 수량을 차감합니다.",
        OPTIONS_TSM_SMART_RESTOCK_INCLUDE_ALTS_LABEL = "부캐릭터 포함",
        OPTIONS_TSM_SMART_RESTOCK_INCLUDE_WARBANK_LABEL = "전투부대 은행 포함",
        OPTIONS_MODULES_REAGENT_OPTIMIZATION = "재료 최적화 모듈",
        OPTIONS_MODULES_AVERAGE_PROFIT = "평균 이익 모듈",
        OPTIONS_MODULES_TOP_GEAR = "최적 도구 모듈",
        OPTIONS_MODULES_COST_OVERVIEW = "가격 상세 모듈",
        OPTIONS_MODULES_SPECIALIZATION_INFO = "전문화 정보 모듈",
        OPTIONS_MODULES_CUSTOMER_HISTORY_SIZE = "고객당 최대 메시지 기록 수",
        OPTIONS_MODULES_CUSTOMER_HISTORY_MAX_ENTRIES_PER_CLIENT = "고객당 최대 이력 항목 수",
        OPTIONS_PROFIT_CALCULATION_OFFSET = "숙련도 기준점에 1 추가",
        OPTIONS_PROFIT_CALCULATION_OFFSET_TOOLTIP =         "재료 조합 제안 시 정확한 요구 숙련도가 아닌, 기준점 + 1 숙련도 도달을 목표로 합니다.",
        OPTIONS_PROFIT_CALCULATION_MULTICRAFT_CONSTANT = "복수 제작 상수",
        OPTIONS_PROFIT_CALCULATION_MULTICRAFT_CONSTANT_EXPLANATION =         "기본값: 2.5\n\n베타 및 용군단 초기 데이터에 따르면 복수 제작으로 얻는 최대 추가 수량은 1+C*y입니다. (y=기본 생산량, C=2.5)\n원하는 경우 이 값을 수정할 수 있습니다.",
        OPTIONS_PROFIT_CALCULATION_RESOURCEFULNESS_CONSTANT = "지혜 상수",
        OPTIONS_PROFIT_CALCULATION_RESOURCEFULNESS_CONSTANT_EXPLANATION =         "기본값: 0.3\n\n데이터에 따르면 지혜 발동 시 평균적으로 필요 수량의 약 30%를 절약합니다.\n원하는 경우 이 값을 수정할 수 있습니다.",
        OPTIONS_GENERAL_SHOW_NEWS_CHECKBOX = f.bb("새 소식") .. " 팝업 표시",
        OPTIONS_GENERAL_SHOW_NEWS_CHECKBOX_TOOLTIP = "게임 접속 시 " ..
            f.l("CraftSim") .. " 업데이트 정보가 담긴 " .. f.bb("새 소식") .. " 팝업을 표시합니다.",
        OPTIONS_GENERAL_HIDE_MINIMAP_BUTTON_CHECKBOX = "미니맵 버튼 숨기기",
        OPTIONS_GENERAL_HIDE_MINIMAP_BUTTON_TOOLTIP = f.l("CraftSim") .. " 미니맵 버튼을 숨깁니다.",
        OPTIONS_GENERAL_COIN_MONEY_FORMAT_CHECKBOX = "금화 텍스처 사용: ",
        OPTIONS_GENERAL_COIN_MONEY_FORMAT_TOOLTIP = "금액을 아이콘 형식으로 표시합니다.",

        -- Control Panel
        CONTROL_PANEL_MODULES_CRAFT_QUEUE_LABEL = "제작 대기열",
        CONTROL_PANEL_MODULES_CRAFT_QUEUE_TOOLTIP =         "레시피를 대기열에 추가하고 한곳에서 모두 제작하세요!",
        CONTROL_PANEL_MODULES_TOP_GEAR_LABEL = "최적 도구",
        CONTROL_PANEL_MODULES_TOP_GEAR_TOOLTIP =         "선택한 모드에 따라 사용 가능한 최적의 전문 기술 장비 조합을 보여줍니다.",
        CONTROL_PANEL_MODULES_COST_OVERVIEW_LABEL = "가격 상세",
        CONTROL_PANEL_MODULES_COST_OVERVIEW_TOOLTIP =         "결과물의 품질별 판매가와 이익 개요를 보여줍니다.",
        CONTROL_PANEL_MODULES_AVERAGE_PROFIT_LABEL = "평균 이익",
        CONTROL_PANEL_MODULES_AVERAGE_PROFIT_TOOLTIP =         "전문 기술 능력치와 이익 가중치를 바탕으로 한 평균 이익(포인트당 골드 가치)을 보여줍니다.",
        CONTROL_PANEL_MODULES_REAGENT_OPTIMIZATION_LABEL = "재료 최적화",
        CONTROL_PANEL_MODULES_REAGENT_OPTIMIZATION_TOOLTIP =         "특정 품질 단계에 도달하기 위한 가장 저렴한 재료 조합을 제안합니다.",
        CONTROL_PANEL_MODULES_PRICE_OVERRIDES_LABEL = "가격 직접 설정",
        CONTROL_PANEL_MODULES_PRICE_OVERRIDES_TOOLTIP =         "모든 레시피 또는 특정 레시피에 대해 재료 및 결과물의 가격을 직접 설정합니다.",
        CONTROL_PANEL_MODULES_SPECIALIZATION_INFO_LABEL = "전문화 정보",
        CONTROL_PANEL_MODULES_SPECIALIZATION_INFO_TOOLTIP =         "전문 기술 전문화가 이 레시피에 어떤 영향을 주는지 보여주고, 구성을 시뮬레이션해볼 수 있습니다.",
        CONTROL_PANEL_MODULES_CRAFT_LOG_LABEL = "제작 기록",
        CONTROL_PANEL_MODULES_CRAFT_LOG_TOOLTIP =         "제작 로그와 제작 통계를 보여줍니다.",
        CONTROL_PANEL_MODULES_COST_OPTIMIZATION_LABEL = "비용 최적화",
        CONTROL_PANEL_MODULES_COST_OPTIMIZATION_TOOLTIP =         "제작 비용에 대한 상세 정보를 보여주고 비용 최적화를 돕는 모듈입니다.",
        CONTROL_PANEL_MODULES_STATISTICS_LABEL = "통계",
        CONTROL_PANEL_MODULES_STATISTICS_TOOLTIP =         "현재 열린 레시피의 상세한 결과 통계를 보여주는 모듈입니다.",
        CONTROL_PANEL_MODULES_RECIPE_SCAN_LABEL = "레시피 스캔",
        CONTROL_PANEL_MODULES_RECIPE_SCAN_TOOLTIP =         "다양한 옵션을 바탕으로 레시피 목록을 스캔하는 모듈입니다.",
        CONTROL_PANEL_MODULES_CUSTOMER_HISTORY_LABEL = "고객 기록",
        CONTROL_PANEL_MODULES_CUSTOMER_HISTORY_TOOLTIP =         "고객과의 대화, 제작 아이템, 수수료 등의 이력을 제공하는 모듈입니다.",
        CONTROL_PANEL_MODULES_CRAFT_BUFFS_LABEL = "제작 버프",
        CONTROL_PANEL_MODULES_CRAFT_BUFFS_TOOLTIP =         "현재 활성화되었거나 누락된 제작 관련 버프를 보여줍니다.",
        CONTROL_PANEL_MODULES_EXPLANATIONS_LABEL = "계산 설명",
        CONTROL_PANEL_MODULES_EXPLANATIONS_TOOLTIP =             f.l(" CraftSim") .. "의 각종 계산 방식을 설명해주는 모듈입니다.",
        CONTROL_PANEL_RESET_FRAMES = "창 위치 초기화",
        CONTROL_PANEL_OPTIONS = "옵션",
        CONTROL_PANEL_NEWS = "새 소식",
        CONTROL_PANEL_EXPORTS = "내보내기",
        CONTROL_PANEL_EASYCRAFT_EXPORT = f.l("Easycraft") .. " 내보내기",
        CONTROL_PANEL_EASYCRAFT_EXPORTING = "내보내는 중",
        CONTROL_PANEL_EASYCRAFT_EXPORT_NO_RECIPE_FOUND =         "내부 전쟁 확장팩에서 내보낼 레시피를 찾을 수 없습니다.",
        CONTROL_PANEL_FORGEFINDER_EXPORT = f.l("ForgeFinder") .. " 내보내기",
        CONTROL_PANEL_FORGEFINDER_EXPORTING = "내보내는 중",
        CONTROL_PANEL_EXPORT_EXPLANATION = f.l("wowforgefinder.com") ..
            " 및 " .. f.l("easycraft.io") ..
            "\n등은 " .. f.bb("WoW 제작 주문") .. "을 찾거나 제안할 수 있는 웹사이트입니다.",
        CONTROL_PANEL_DEBUG = "디버그",
        CONTROL_PANEL_TITLE = "제어판",
        CONTROL_PANEL_SUPPORTERS_BUTTON = f.patreon("후원자"),

        -- Supporters
        SUPPORTERS_DESCRIPTION = f.l("모든 멋진 분들께 감사드립니다!"),
        SUPPORTERS_DESCRIPTION_2 = f.l(
            "CraftSim을 후원하고 이곳에 메시지를 남기고 싶으신가요?\n커뮤니티 가입을 고려해 보세요!"),
        SUPPORTERS_DATE = "날짜",
        SUPPORTERS_SUPPORTER = "후원자",
        SUPPORTERS_MESSAGE = "메시지",

        -- Customer History
        CUSTOMER_HISTORY_TITLE = "CraftSim 고객 기록",
        CUSTOMER_HISTORY_DROPDOWN_LABEL = "고객 선택",
        CUSTOMER_HISTORY_TOTAL_TIP = "총 수수료: ",
        CUSTOMER_HISTORY_FROM = "보낸 사람",
        CUSTOMER_HISTORY_TO = "받는 사람",
        CUSTOMER_HISTORY_FOR = "항목",
        CUSTOMER_HISTORY_CRAFT_FORMAT = "%s에게 %s 제작함",
        CUSTOMER_HISTORY_DELETE_BUTTON = "고객 삭제",
        CUSTOMER_HISTORY_WHISPER_BUTTON_LABEL = "귓속말..",
        CUSTOMER_HISTORY_PURGE_NO_TIP_LABEL = "수수료 0골드 고객 삭제",
        CUSTOMER_HISTORY_PURGE_ZERO_TIPS_CONFIRMATION_POPUP =         "총 수수료가 0인 모든 고객 데이터를\n정말로 삭제하시겠습니까?",
        CUSTOMER_HISTORY_DELETE_CUSTOMER_CONFIRMATION_POPUP =         "%s의 모든 데이터를\n정말로 삭제하시겠습니까?",
        CUSTOMER_HISTORY_PURGE_DAYS_INPUT_LABEL = "자동 삭제 주기 (일)",
        CUSTOMER_HISTORY_PURGE_DAYS_INPUT_TOOLTIP =         "설정된 일수 경과 후 로그인 시, 지정된 수수료 미만의 고객을 자동으로 삭제합니다.\n0으로 설정하면 자동으로 삭제하지 않습니다.",
        CUSTOMER_HISTORY_CUSTOMER_HEADER = "고객",
        CUSTOMER_HISTORY_TOTAL_TIP_HEADER = "총 수수료",
        CUSTOMER_HISTORY_CRAFT_HISTORY_DATE_HEADER = "날짜",
        CUSTOMER_HISTORY_CRAFT_HISTORY_RESULT_HEADER = "결과",
        CUSTOMER_HISTORY_CRAFT_HISTORY_TIP_HEADER = "수수료",
        CUSTOMER_HISTORY_CRAFT_HISTORY_CUSTOMER_REAGENTS_HEADER = "고객 재료",
        CUSTOMER_HISTORY_CRAFT_HISTORY_CUSTOMER_NOTE_HEADER = "메모",
        CUSTOMER_HISTORY_CHAT_MESSAGE_TIMESTAMP = "시간",
        CUSTOMER_HISTORY_CHAT_MESSAGE_SENDER = "발신자",
        CUSTOMER_HISTORY_CHAT_MESSAGE_MESSAGE = "메시지",
        CUSTOMER_HISTORY_CHAT_MESSAGE_YOU = "[나]: ",
        CUSTOMER_HISTORY_CRAFT_LIST_TIMESTAMP = "시간",
        CUSTOMER_HISTORY_CRAFT_LIST_RESULTLINK = "결과 링크",
        CUSTOMER_HISTORY_CRAFT_LIST_TIP = "수수료",
        CUSTOMER_HISTORY_CRAFT_LIST_REAGENTS = "재료",
        CUSTOMER_HISTORY_CRAFT_LIST_SOMENOTE = "메모",
        CUSTOMER_HISTORY_TOTAL_AMOUNT = "총 수량",
        CUSTOMER_HISTORY_CATEGORY_ENABLE_HISTORY_RECORDING = f.gold("기록 저장") .. f.bb(" 활성화"),
        CUSTOMER_HISTORY_CATEGORY_RECORD_PATRON_ORDERS = f.bb("NPC 주문") .. " 기록",
        CUSTOMER_HISTORY_CATEGORY_REMOVE_CUSTOMERS = "고객 삭제",
        CUSTOMER_HISTORY_CATEGORY_AUTO_REMOVAL = "자동 삭제",
        CUSTOMER_HISTORY_CATEGORY_REMOVE_BELOW_THRESHOLD = f.l("임계값 미만 삭제"),
        CUSTOMER_HISTORY_CATEGORY_REMOVE_ALL_CUSTOMERS = f.r("모든 고객 삭제"),
        CUSTOMER_HISTORY_CATEGORY_REMOVE_ALL_CUSTOMER_DATA = f.r("모든 고객 데이터를 삭제하시겠습니까?"),
        CUSTOMER_HISTORY_CATEGORY_DELETE_CUSTOMER = "고객 삭제",

        -- Craft Queue
        CRAFT_QUEUE_TITLE = "CraftSim 제작 대기열",
        CRAFT_QUEUE_CRAFT_AMOUNT_LEFT_HEADER = "대기 중",
        CRAFT_QUEUE_CRAFT_PROFESSION_GEAR_HEADER = "도구",
        CRAFT_QUEUE_CRAFTING_COSTS_HEADER = "제작 비용",
        CRAFT_QUEUE_CRAFT_BUTTON_ROW_LABEL = "제작",
        CRAFT_QUEUE_CRAFT_BUTTON_ROW_LABEL_WRONG_GEAR = "도구 틀림",
        CRAFT_QUEUE_CRAFT_BUTTON_ROW_LABEL_NO_REAGENTS = "재료 없음",
        CRAFT_QUEUE_ADD_OPEN_RECIPE_BUTTON_LABEL = "현재 레시피 추가",
        CRAFT_QUEUE_ADD_FIRST_CRAFTS_BUTTON_LABEL = "첫 제작 추가",
        CRAFT_QUEUE_ADD_WORK_ORDERS_BUTTON_LABEL = "제작 주문 추가",
        CRAFT_QUEUE_ADD_WORK_ORDERS_ALLOW_CONCENTRATION_CHECKBOX = f.gold("집중") .. " 허용",
        CRAFT_QUEUE_ADD_WORK_ORDERS_ALLOW_CONCENTRATION_TOOLTIP =             "최소 품질에 도달할 수 없는 경우, 가능한 경우 " .. f.l("집중") .. "을 사용합니다.",
        CRAFT_QUEUE_ADD_WORK_ORDERS_ONLY_PROFITABLE_CHECKBOX = "이익 발생 시만",
        CRAFT_QUEUE_ADD_WORK_ORDERS_ONLY_PROFITABLE_TOOLTIP = "예상 이익이 양수인 제작 주문만 대기열에 추가합니다.",
        CRAFT_QUEUE_WORK_ORDER_TYPE_BUTTON = "제작 주문 유형",
        CRAFT_QUEUE_PATRON_ORDERS_BUTTON = "NPC 주문",
        CRAFT_QUEUE_GUILD_ORDERS_BUTTON = "길드 주문",
        CRAFT_QUEUE_PERSONAL_ORDERS_BUTTON = "개인 주문",
        CRAFT_QUEUE_GUILD_ORDERS_ALTS_ONLY_CHECKBOX = f.r("부캐릭터만"),
        CRAFT_QUEUE_PATRON_ORDERS_FORCE_CONCENTRATION_CHECKBOX = f.gold("집중") .. f.r(" 강제"),
        CRAFT_QUEUE_PATRON_ORDERS_FORCE_CONCENTRATION_TOOLTIP = "가능한 경우 모든 NPC 주문에 집중 사용을 강제합니다.",
        CRAFT_QUEUE_PATRON_ORDERS_SPARK_RECIPES_CHECKBOX = f.e("불꽃") .. " 레시피 포함",
        CRAFT_QUEUE_PATRON_ORDERS_SPARK_RECIPES_TOOLTIP = "불꽃을 재료로 사용하는 주문을 포함합니다.",
        CRAFT_QUEUE_PATRON_ORDERS_ACUITY_CHECKBOX = f.bb("기민함/투지") .. " 보상 포함",
        CRAFT_QUEUE_PATRON_ORDERS_ACUITY_TOOLTIP = "장인 기민함 또는 장인의 투지를 보상으로 주는 주문을 포함합니다.",
        CRAFT_QUEUE_PATRON_ORDERS_POWER_RUNE_CHECKBOX = f.bb("강화의 룬") .. " 보상 포함",
        CRAFT_QUEUE_PATRON_ORDERS_POWER_RUNE_TOOLTIP = "증강의 룬을 보상으로 주는 주문을 포함합니다.",
        CRAFT_QUEUE_PATRON_ORDERS_KNOWLEDGE_POINTS_CHECKBOX = f.bb("지식 포인트") .. " 보상 포함",
        CRAFT_QUEUE_PATRON_ORDERS_KNOWLEDGE_POINTS_TOOLTIP = "전문 기술 지식을 보상으로 주는 주문을 포함합니다.",
        CRAFT_QUEUE_PATRON_ORDERS_KNOWLEDGE_POINTS_MAX_COST = f.bb("지식") .. "당 최대 비용: ",
        CRAFT_QUEUE_PATRON_ORDERS_KNOWLEDGE_POINTS_MAX_COST_TOOLTIP = "지식 포인트 1점을 얻기 위해 허용할 수 있는 최대 골드 비용입니다.\n\n형식: ",
        CRAFT_QUEUE_PATRON_ORDERS_MAX_COST = f.bb("NPC 주문") .. " 최대 비용: ",
        CRAFT_QUEUE_PATRON_ORDERS_MAX_COST_TOOLTIP = "NPC 주문 제작 시 허용할 최대 골드 비용입니다.\n\n형식: ",
        CRAFT_QUEUE_PATRON_ORDERS_REAGENT_BAG_VALUE = f.bb("재료 가방") .. " 가치: ",
        CRAFT_QUEUE_PATRON_ORDERS_REAGENT_BAG_VALUE_TOOLTIP = "보상으로 받는 재료 가방의 가치를 이익에 합산합니다.\n\n형식: ",
        CRAFT_QUEUE_CLEAR_ALL_BUTTON_LABEL = "모두 삭제",
        CRAFT_QUEUE_RESTOCK_FAVORITES_SMART_CONCENTRATION_QUEUING = f.bb("스마트 ") .. f.gold("집중") .. f.bb(" 대기열"),
        CRAFT_QUEUE_RESTOCK_FAVORITES_SMART_CONCENTRATION_QUEUING_TOOLTIP = "활성화 시, " ..
            f.l("CraftSim") ..
            "은 먼저 " ..
            f.g("집중 가치가 가장 높은") ..
            " 레시피를 판별한 뒤, 제작 가능한 최대 수량만큼 대기열에 추가합니다.",
        CRAFT_QUEUE_RESTOCK_FAVORITES_OFFSET_CONCENTRATION_CRAFT_AMOUNT = f.gold("집중") .. f.bb(" 대기열 수량 오프셋"),
        CRAFT_QUEUE_RESTOCK_FAVORITES_OFFSET_CONCENTRATION_CRAFT_AMOUNT_TOOLTIP = "활성화 시, " .. f.bb("독창성") .. "에 따른 예상 제작 수량만큼 집중 제작을 대기열에 추가합니다.",
        CRAFT_QUEUE_RESTOCK_FAVORITES_QUEUE_MAIN_PROFESSIONS = f.bb("현재 주 전문 기술") .. " 추가",
        CRAFT_QUEUE_RESTOCK_FAVORITES_QUEUE_MAIN_PROFESSIONS_TOOLTIP = "활성화 시, 현재 캐릭터의 두 주 전문 기술을 동시에 처리합니다.",
        CRAFT_QUEUE_RESTOCK_FAVORITES_OFFSET_QUEUE_AMOUNT_LABEL = "대기열 수량 오프셋: ",
        CRAFT_QUEUE_RESTOCK_FAVORITES_OFFSET_QUEUE_AMOUNT_TOOLTIP = "대기열에 추가할 때 항상 지정된 수량만큼 더해서 추가합니다.",
        CRAFT_QUEUE_RESTOCK_FAVORITES_AUTO_SHOPPING_LIST = "스캔 후 자동으로 쇼핑 목록 생성",
        CRAFT_QUEUE_CRAFT_BUTTON_ROW_LABEL_WRONG_PROFESSION = "전문 기술 틀림",
        CRAFT_QUEUE_CRAFT_BUTTON_ROW_LABEL_ON_COOLDOWN = "재사용 대기 중",
        CRAFT_QUEUE_CRAFT_BUTTON_ROW_LABEL_WRONG_CRAFTER = "제작자 틀림",
        CRAFT_QUEUE_RECIPE_REQUIREMENTS_HEADER = "상태",
        CRAFT_QUEUE_RECIPE_REQUIREMENTS_TOOLTIP =         "레시피를 제작하기 위해 모든 요구 사항이 충족되어야 합니다.",
        CRAFT_QUEUE_CRAFT_NEXT_BUTTON_LABEL = "다음 제작",
        CRAFT_QUEUE_CRAFT_AVAILABLE_AMOUNT = "최대",
        CRAFT_QUEUE_SHATTER_MOTE_AUTOMATIC = "자동 (최저가)",
        CRAFT_QUEUE_SHATTER_MOTE_AUTOMATIC_OWNED = "자동 (보유 중인 가장 저렴한 재료)",
        CRAFT_QUEUE_SHATTER_RIGHT_CLICK_HINT = "\n우클릭하여 티끌 선택.",
        CRAFTQUEUE_AUCTIONATOR_SHOPPING_LIST_BUTTON_LABEL = "Auctionator 쇼핑 목록 생성",
        CRAFT_QUEUE_QUEUE_TAB_LABEL = "제작 대기열",
        CRAFT_QUEUE_FLASH_TASKBAR_OPTION_LABEL = f.bb("제작 대기열") .. " 완료 시 작업표시줄 깜빡임",
        CRAFT_QUEUE_FLASH_TASKBAR_OPTION_TOOLTIP = 
            "WoW 게임 창이 최소화되어 있을 때 " .. f.bb("제작 대기열") .. 
            "에서 제작이 완료되면, " .. f.l(" CraftSim") .. "이 작업표시줄의 WoW 아이콘을 깜빡여 알립니다.",
        CRAFT_QUEUE_RESTOCK_OPTIONS_TAB_LABEL = "재입고 옵션",
        CRAFT_QUEUE_RESTOCK_OPTIONS_TAB_TOOLTIP =             "제작법 스캔(Recipe Scan)에서 가져올 때의 재입고 동작을 설정합니다.",
        CRAFT_QUEUE_RESTOCK_OPTIONS_GENERAL_PROFIT_THRESHOLD_LABEL = "수익 임계값:",
        CRAFT_QUEUE_RESTOCK_OPTIONS_SALE_RATE_INPUT_LABEL = "판매율 임계값:",
        CRAFT_QUEUE_RESTOCK_OPTIONS_TSM_SALE_RATE_TOOLTIP = string.format(
            [[
%s가 로드되어 있을 때만 사용 가능합니다!

아이템의 선택된 품질 중 %s 품질의 판매율이 
설정한 판매율 임계값보다 크거나 같은지 확인합니다.
]], f.bb("TSM"), f.bb("어느 하나라도")),
        CRAFT_QUEUE_RESTOCK_OPTIONS_TSM_SALE_RATE_TOOLTIP_GENERAL = string.format(
            [[
%s가 로드되어 있을 때만 사용 가능합니다!

아이템의 모든 품질 중 %s 품질의 판매율이 
설정한 판매율 임계값보다 크거나 같은지 확인합니다.
]], f.bb("TSM"), f.bb("어느 하나라도")),
        CRAFT_QUEUE_RESTOCK_OPTIONS_AMOUNT_LABEL = "재입고 수량:",
        CRAFT_QUEUE_RESTOCK_OPTIONS_RESTOCK_TOOLTIP = "해당 제작법으로 예약될 " ..
            f.bb("제작 횟수") ..
            "입니다.\n\n재입고 시 소지품 및 은행에 보유 중인 해당 품질 아이템의 수량이 재입고 수량에서 차감됩니다.",
        CRAFT_QUEUE_RESTOCK_OPTIONS_ENABLE_RECIPE_LABEL = "활성화:",
        CRAFT_QUEUE_RESTOCK_OPTIONS_GENERAL_OPTIONS_LABEL = "일반 옵션 (모든 제작법)",
        CRAFT_QUEUE_RESTOCK_OPTIONS_ENABLE_RECIPE_TOOLTIP =             "이 옵션을 끄면 위의 일반 옵션에 따라 제작법이 재입고됩니다.",
        CRAFT_QUEUE_TOTAL_PROFIT_LABEL = "총 평균 수익:",
        CRAFT_QUEUE_TOTAL_CRAFTING_COSTS_LABEL = "총 제작 비용:",
        CRAFT_QUEUE_EDIT_RECIPE_TITLE = "제작법 편집",
        CRAFT_QUEUE_EDIT_RECIPE_NAME_LABEL = "제작법 이름",
        CRAFT_QUEUE_EDIT_RECIPE_REAGENTS_SELECT_LABEL = "선택",
        CRAFT_QUEUE_EDIT_RECIPE_OPTIONAL_REAGENTS_LABEL = "선택 재료",
        CRAFT_QUEUE_EDIT_RECIPE_FINISHING_REAGENTS_LABEL = "마무리 재료",
        CRAFT_QUEUE_EDIT_RECIPE_SPARK_LABEL = "필수 재료",
        CRAFT_QUEUE_EDIT_RECIPE_PROFESSION_GEAR_LABEL = "전문 기술 장비",
        CRAFT_QUEUE_EDIT_RECIPE_OPTIMIZE_PROFIT_BUTTON = "수익 최적화",
        CRAFT_QUEUE_EDIT_RECIPE_CRAFTING_COSTS_LABEL = "제작 비용: ",
        CRAFT_QUEUE_EDIT_RECIPE_AVERAGE_PROFIT_LABEL = "평균 수익: ",
        CRAFT_QUEUE_EDIT_RECIPE_RESULTS_LABEL = "결과",
        CRAFT_QUEUE_EDIT_RECIPE_CONCENTRATION_CHECKBOX = " 집중 사용",
        CRAFT_QUEUE_AUCTIONATOR_SHOPPING_LIST_PER_CHARACTER_CHECKBOX = "캐릭터별 생성",
        CRAFT_QUEUE_AUCTIONATOR_SHOPPING_LIST_PER_CHARACTER_CHECKBOX_TOOLTIP = "통합 쇼핑 리스트 대신 각 제작자 캐릭터별로 " ..
            f.bb("Auctionator 쇼핑 리스트") .. "를 생성합니다.",
        CRAFT_QUEUE_AUCTIONATOR_SHOPPING_LIST_TARGET_MODE_CHECKBOX = "대상 모드 전용",
        CRAFT_QUEUE_AUCTIONATOR_SHOPPING_LIST_TARGET_MODE_CHECKBOX_TOOLTIP = "대상 모드(Target Mode) 제작법에 대해서만 " ..
            f.bb("Auctionator 쇼핑 리스트") .. "를 생성합니다.",
        CRAFT_QUEUE_UNSAVED_CHANGES_TOOLTIP = f.white("저장되지 않은 대기열 수량입니다.\nEnter를 눌러 저장하세요."),
        CRAFT_QUEUE_STATUSBAR_LEARNED = f.white("제작법 배움"),
        CRAFT_QUEUE_STATUSBAR_COOLDOWN = f.white("재사용 대기시간 아님"),
        CRAFT_QUEUE_STATUSBAR_REAGENTS = f.white("재료 보유 중"),
        CRAFT_QUEUE_STATUSBAR_GEAR = f.white("전문 기술 장비 착용됨"),
        CRAFT_QUEUE_STATUSBAR_CRAFTER = f.white("올바른 제작 캐릭터"),
        CRAFT_QUEUE_STATUSBAR_PROFESSION = f.white("전문 기술 창 열림"),
        CRAFT_QUEUE_BUTTON_EDIT = "편집",
        CRAFT_QUEUE_BUTTON_CRAFT = "제작",
        CRAFT_QUEUE_BUTTON_CLAIM = "선점",
        CRAFT_QUEUE_BUTTON_CLAIMED = "선점됨",
        CRAFT_QUEUE_BUTTON_NEXT = "다음: ",
        CRAFT_QUEUE_BUTTON_NOTHING_QUEUED = "대기열 비어 있음",
        CRAFT_QUEUE_BUTTON_ORDER = "주문",
        CRAFT_QUEUE_BUTTON_SUBMIT = "제출",
        CRAFT_QUEUE_BUTTON_EQUIP_TOOLS = "착용",
        CRAFT_QUEUE_IGNORE_ACUITY_RECIPES_CHECKBOX_LABEL = "장인의 기미 제작법 무시",
        CRAFT_QUEUE_IGNORE_ACUITY_RECIPES_CHECKBOX_TOOLTIP =             f.bb("장인의 기미") .. "가 소모되는 첫 제작 아이템을 대기열에 추가하지 않습니다.",
        CRAFT_QUEUE_AMOUNT_TOOLTIP = "\n\n예약된 제작: ",
        CRAFT_QUEUE_ORDER_CUSTOMER = "\n\n주문 고객: ",
        CRAFT_QUEUE_ORDER_MINIMUM_QUALITY = "\n최소 품질: ",
        CRAFT_QUEUE_ORDER_REWARDS = "\n보상:",
        CRAFT_QUEUE_RESTOCK_FAVORITES_OPTIONS_AUTO_SHOPPING_LIST = "활성화하면 스캔 후 자동으로 쇼핑 리스트를 생성합니다.",
        CRAFT_QUEUE_IGNORE_SPARK_RECIPES_CHECKBOX_LABEL = f.e("불꽃") .. " 제작법 무시",
        CRAFT_QUEUE_IGNORE_SPARK_RECIPES_CHECKBOX_TOOLTIP = "불꽃 재료가 필요한 제작법을 무시합니다.",
        CRAFT_QUEUE_MENU_AUTO_SHOW = f.g("자동으로 열기 ") .. "(제작법이 대기열에 추가될 때)",
        CRAFT_QUEUE_MENU_INGENUITY_IGNORE = f.gold("독창 발동 시 ") .. f.r("무시 ") .. "(대기열 수량 감소 방지)",
        CRAFT_QUEUE_MENU_DEQUEUE_CONCENTRATION = f.gold("집중 ") .. "모두 소모 시 " .. f.r("제거"),
        CRAFT_QUEUE_MENU_DEQUEUE_CONCENTRATION_TOOLTIP = "남은 집중력이 부족하여 더 이상 제작할 수 없을 때 대기열에서 자동으로 제거합니다.",
        CRAFT_QUEUE_HELP = f.bb("좌클릭") .. " .. 제작법으로 이동\n" ..
            f.bb("우클릭") .. " .. 제작법 옵션 열기\n" ..
            f.bb("휠 클릭") .. " .. 대기열에서 제거",

        -- craft lists (제작 목록)
        CRAFT_LISTS_TAB_LABEL = "제작 목록",
        CRAFT_LISTS_QUEUE_BUTTON_LABEL = "제작 목록 대기열 추가",
        CRAFT_LISTS_CREATE_BUTTON_LABEL = "만들기",
        CRAFT_LISTS_DELETE_BUTTON_LABEL = f.r("삭제"),
        CRAFT_LISTS_RENAME_BUTTON_LABEL = "이름 변경",
        CRAFT_LISTS_ADD_RECIPE_BUTTON_LABEL = "현재 제작법 추가",
        CRAFT_LISTS_REMOVE_RECIPE_BUTTON_LABEL = f.r("제거"),
        CRAFT_LISTS_EXPORT_BUTTON_LABEL = "내보내기",
        CRAFT_LISTS_IMPORT_BUTTON_LABEL = "가져오기",
        CRAFT_LISTS_LIST_NAME_HEADER = "목록 이름",
        CRAFT_LISTS_LIST_TYPE_HEADER = "범위",
        CRAFT_LISTS_RECIPE_NAME_HEADER = "제작법",
        CRAFT_LISTS_GLOBAL_LABEL = f.bb("공통"),
        CRAFT_LISTS_CHARACTER_LABEL = f.g("캐릭터"),
        CRAFT_LISTS_NEW_LIST_DEFAULT_NAME = "새 목록",
        CRAFT_LISTS_RENAME_POPUP_TITLE = "제작 목록 이름 변경",
        CRAFT_LISTS_CREATE_POPUP_TITLE = "제작 목록 만들기",
        CRAFT_LISTS_EXPORT_POPUP_TITLE = "제작 목록 내보내기",
        CRAFT_LISTS_IMPORT_POPUP_TITLE = "제작 목록 가져오기",
        CRAFT_LISTS_OPTIONS_ENABLE_CONCENTRATION = CraftSim.GUTIL:IconToText(CraftSim.CONST.CONCENTRATION_ICON, 15, 15) .. f.gold(" 집중 활성화"),
        CRAFT_LISTS_OPTIONS_OPTIMIZE_CONCENTRATION = f.gold("집중") .. " 최적화",
        CRAFT_LISTS_OPTIONS_SMART_CONCENTRATION = f.bb("스마트 ") .. f.gold("집중") .. f.bb(" 대기열 추가"),
        CRAFT_LISTS_OPTIONS_SMART_CONCENTRATION_TOOLTIP = "포인트당 집중 효율이 가장 높은 순서대로 제작법을 대기열에 추가하여 사용 가능한 집중력을 모두 소모합니다.",
        CRAFT_LISTS_OPTIONS_OFFSET_CONCENTRATION = f.gold("집중") .. f.bb(" 대기열 수량 보정"),
        CRAFT_LISTS_OPTIONS_OFFSET_CONCENTRATION_TOOLTIP = "활성화하면 " .. f.bb("독창") .. "에 따른 예상 제작 횟수만큼 집중 제작 대기열을 추가합니다.",
        CRAFT_LISTS_OPTIONS_OPTIMIZE_TOOLS = "전문 기술 도구 최적화",
        CRAFT_LISTS_OPTIONS_TOP_PROFIT_QUALITY = "최고 수익 품질 자동 선택",
        CRAFT_LISTS_OPTIONS_OPTIMIZE_FINISHING = "마무리 재료 최적화",
        CRAFT_LISTS_OPTIONS_INCLUDE_SOULBOUND = f.e("획득 시 귀속") .. f.bb(" 마무리 재료 포함"),
        CRAFT_LISTS_OPTIONS_REAGENT_ALLOCATION = "재료 배분",
        CRAFT_LISTS_OPTIONS_REAGENT_ALLOCATION_OPTIMIZE_HIGHEST = "최고 품질",
        CRAFT_LISTS_OPTIONS_REAGENT_ALLOCATION_OPTIMIZE_MOST_PROFITABLE = "최고 수익 품질",
        CRAFT_LISTS_OPTIONS_REAGENT_ALLOCATION_TARGET_QUALITY = "목표 품질",
        CRAFT_LISTS_OPTIONS_ENABLE_UNLEARNED = f.r("배우지 않은") .. " 제작법 활성화",
        CRAFT_LISTS_OPTIONS_USE_TSM_RESTOCK = f.bb("TSM") .. " 재입고 공식 사용",
        CRAFT_LISTS_OPTIONS_TSM_EXPRESSION = "공식:",        CRAFT_LISTS_OPTIONS_USE_CURRENT_CHARACTER = "현재 캐릭터로 제작",
        CRAFT_LISTS_OPTIONS_FIXED_CRAFTER = "고정 제작자: ",
        CRAFT_LISTS_OPTIONS_RESTOCK_AMOUNT = "재입고 수량: ",
        CRAFT_LISTS_OPTIONS_OFFSET_QUEUE_AMOUNT = "대기열 수량 오프셋: ",
        CRAFT_LISTS_OPTIONS_OFFSET_QUEUE_AMOUNT_TOOLTIP = "예약된 제작 횟수에 항상 지정된 수량을 더합니다.",
        CRAFT_LISTS_OPTIONS_AUTO_SHOPPING_LIST = "대기열 추가 후 자동으로 쇼핑 리스트 생성",
        CRAFT_LISTS_NO_LIST_SELECTED = f.grey("선택된 목록 없음"),
        CRAFT_LISTS_SELECT_LIST_HINT = f.grey("제작법을 보려면 목록을 선택하세요."),

        -- craft buffs (제작 버프)
        CRAFT_BUFFS_TITLE = "CraftSim 제작 버프",
        CRAFT_BUFFS_SIMULATE_BUTTON = "버프 시뮬레이션",
        CRAFT_BUFF_CHEFS_HAT_TOOLTIP = f.bb("리치 왕의 분노 장난감.") ..
            "\n노스렌드 요리 숙련도 필요\n제작 속도를 " .. f.g("0.5초") .. "로 설정합니다.",

        -- cooldowns module (재사용 대기시간 모듈)
        COOLDOWNS_TITLE = "CraftSim 재사용 대기시간",
        CONTROL_PANEL_MODULES_COOLDOWNS_LABEL = "대기시간",
        CONTROL_PANEL_MODULES_COOLDOWNS_TOOLTIP = "계정 내 모든 캐릭터의 " ..
            f.bb("전문 기술 재사용 대기시간") .. " 개요입니다.",
        COOLDOWNS_CRAFTER_HEADER = "제작자",
        COOLDOWNS_RECIPE_HEADER = "제작법",
        COOLDOWNS_CHARGES_HEADER = "충전 횟수",
        COOLDOWNS_NEXT_HEADER = "다음 충전",
        COOLDOWNS_ALL_HEADER = "충전 완료",
        COOLDOWNS_TAB_OVERVIEW = "개요",
        COOLDOWNS_TAB_OPTIONS = "옵션",
        COOLDOWNS_EXPANSION_FILTER_BUTTON = "확장팩 필터",
        COOLDOWNS_RECIPE_LIST_TEXT_TOOLTIP = f.bb("\n\n이 대기시간을 공유하는 제작법:\n"),
        COOLDOWNS_RECIPE_READY = f.g("준비됨"),
	
	    -- concentration module (집중 모듈)
        CONCENTRATION_TRACKER_TITLE = "CraftSim 집중",
        CONCENTRATION_TRACKER_LABEL_CRAFTER = "제작자",
        CONCENTRATION_TRACKER_LABEL_CURRENT = "현재",
        CONCENTRATION_TRACKER_LABEL_MAX = "최대",
        CONCENTRATION_TRACKER_MAX = f.g("최대"),
        CONCENTRATION_TRACKER_MAX_VALUE = "최대: ",
        CONCENTRATION_TRACKER_FULL = f.g("집중력 가득 참"),
        CONCENTRATION_TRACKER_SORT_MODE_CHARACTER = "캐릭터",
        CONCENTRATION_TRACKER_SORT_MODE_CONCENTRATION = "집중",
        CONCENTRATION_TRACKER_SORT_MODE_PROFESSION = "전문 기술",
        CONCENTRATION_TRACKER_FORMAT_MODE_EUROPE_MAX_DATE = "유럽식 - 최대 날짜",
        CONCENTRATION_TRACKER_FORMAT_MODE_AMERICA_MAX_DATE = "미국식 - 최대 날짜",
        CONCENTRATION_TRACKER_FORMAT_MODE_HOURS_LEFT = "남은 시간(시간)",
        CONCENTRATION_TRACKER_PIN_TOOLTIP = "개요 고정",
        CONCENTRATION_TRACKER_LIST_TAB_LABEL = "목록",
        CONCENTRATION_TRACKER_LIST_TAB_REMOVE_AND_BLACKLIST = "제거 및 차단 목록 추가",
        CONCENTRATION_TRACKER_OPTIONS_TAB_LABEL = "옵션",
        CONCENTRATION_TRACKER_OPTIONS_TAB_CLEAR_BLACKLIST = "차단 목록 초기화",
        CONCENTRATION_TRACKER_OPTIONS_TAB_SORT_MODE = "정렬 모드: ",
        CONCENTRATION_TRACKER_OPTIONS_TAB_TIME_FORMAT = "시간 형식: ",

        -- static popups (정적 팝업)
        STATIC_POPUPS_YES = "예",
        STATIC_POPUPS_NO = "아니오",

        -- frames (프레임)
        FRAMES_RESETTING = "프레임 ID 초기화 중: ",
        FRAMES_WHATS_NEW = "CraftSim 새로운 소식",
        FRAMES_JOIN_DISCORD = "디스코드 참여하기",
        FRAMES_DONATE_KOFI = "Kofi를 통해 CraftSim 후원하기",
        FRAMES_NO_INFO = "정보 없음",

        -- node data (특성 노드 데이터)
        NODE_DATA_RANK_TEXT = "등급 ",
        NODE_DATA_TOOLTIP = "\n\n전문화 특성 총 능력치:\n",
        SPECIALIZATION_INFO_TOOLTIP_LABEL = f.l("CraftSim") .. f.white(" 전문화 정보:"),

        -- columns (열 이름)
        SOURCE_COLUMN_AH = "경매장",
        SOURCE_COLUMN_OVERRIDE = "대체",
        SOURCE_COLUMN_WO = "주문",
    }
end
