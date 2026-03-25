---@class CraftSim
local CraftSim = select(2, ...)

local GGUI = CraftSim.GGUI
local GUTIL = CraftSim.GUTIL

local L = CraftSim.UTIL:GetLocalizer()
local f = GUTIL:GetFormatter()

---@class CraftSim.CRAFT_LISTS
CraftSim.CRAFT_LISTS = {}

local print = CraftSim.DEBUG:RegisterDebugID("Modules.CraftQueue.CraftLists")

--- Queue all craft lists that are selected for queue by the current character
---@param crafterUID? CrafterUID
function CraftSim.CRAFT_LISTS:QueueSelectedLists(crafterUID)
    crafterUID = crafterUID or CraftSim.UTIL:GetPlayerCrafterUID()
    CraftSim.CRAFTQ.craftQueue = CraftSim.CRAFTQ.craftQueue or CraftSim.CraftQueue()

    local allLists = CraftSim.DB.CRAFT_LISTS:GetAllLists(crafterUID)
    local selectedLists = GUTIL:Filter(allLists, function(list)
        return CraftSim.DB.CRAFT_LISTS:IsSelectedForQueue(crafterUID, list.id)
    end)

    if #selectedLists == 0 then
        return
    end

    local queueListsButton = CraftSim.CRAFTQ.frame and
        CraftSim.CRAFTQ.frame.content and
        CraftSim.CRAFTQ.frame.content.queueTab and
        CraftSim.CRAFTQ.frame.content.queueTab.content and
        CraftSim.CRAFTQ.frame.content.queueTab.content.queueCraftListsButton --[[@as GGUI.Button?]]

    if queueListsButton then
        queueListsButton:SetEnabled(false)
    end

    local function finishQueue()
        if queueListsButton then
            queueListsButton:SetStatus("Ready")
        end
        CraftSim.CRAFTQ.UI:UpdateDisplay()
        -- auto shopping list is a general CraftQueue option
        if CraftSim.DB.OPTIONS:Get("CRAFTQUEUE_RESTOCK_FAVORITES_AUTO_SHOPPING_LIST")
            and CraftSim.CRAFTQ.CreateAuctionatorShoppingList then
            CraftSim.CRAFTQ:CreateAuctionatorShoppingList()
        end
    end

    local listIndex = 1

    local function processNextList()
        if listIndex > #selectedLists then
            finishQueue()
            return
        end

        local list = selectedLists[listIndex]
        listIndex = listIndex + 1

        CraftSim.CRAFT_LISTS:QueueList(list, crafterUID, processNextList)
    end

    processNextList()
end

--- Queue a single craft list
---@param list CraftSim.CraftList
---@param crafterUID? CrafterUID
---@param finally? function called after all recipes in the list are queued
function CraftSim.CRAFT_LISTS:QueueList(list, crafterUID, finally)
    crafterUID = crafterUID or CraftSim.UTIL:GetPlayerCrafterUID()
    CraftSim.CRAFTQ.craftQueue = CraftSim.CRAFTQ.craftQueue or CraftSim.CraftQueue()

    if not list or not list.recipeIDs or #list.recipeIDs == 0 then
        if finally then finally() end
        return
    end

    local options = list.options or CraftSim.DB.CRAFT_LISTS.DefaultOptions()

    local playerCrafterData = CraftSim.UTIL:GetPlayerCrafterData()

    ---@type CraftSim.RecipeData[]
    local optimizedRecipes = {}

    local queueListsButton = CraftSim.CRAFTQ.frame and
        CraftSim.CRAFTQ.frame.content and
        CraftSim.CRAFTQ.frame.content.queueTab and
        CraftSim.CRAFTQ.frame.content.queueTab.content and
        CraftSim.CRAFTQ.frame.content.queueTab.content.queueCraftListsButton --[[@as GGUI.Button?]]

    local function finalizeRecipe()
        if options.enableConcentration and options.smartConcentrationQueuing then
            ---@type table<CrafterUID, table<number, CraftSim.RecipeData[]>>
            local crafterUIDProfessionMap = {}

            -- need to map per crafter and per skillline id cause they are all individual concentration currencies
            for _, recipeData in ipairs(optimizedRecipes) do
                if recipeData.concentrating and recipeData.concentrationCost > 0 then
                    local professionSkillLineID = recipeData.professionData.skillLineID
                    local crafterUID = recipeData:GetCrafterUID()
                    crafterUIDProfessionMap[crafterUID] = crafterUIDProfessionMap[crafterUID] or {}
                    crafterUIDProfessionMap[crafterUID][professionSkillLineID] = crafterUIDProfessionMap[crafterUID][professionSkillLineID] or {}
                    tinsert(crafterUIDProfessionMap[crafterUID][professionSkillLineID], recipeData)
                end
            end

            for crafterUID, professionMap in pairs(crafterUIDProfessionMap) do
                for professionSkillLineID, recipeDataList in pairs(professionMap) do
                    local concentrationData = recipeDataList[1].concentrationData
                    table.sort(recipeDataList,
                        function(recipeDataA, recipeDataB)
                            return recipeDataA:GetConcentrationValue() > recipeDataB:GetConcentrationValue()
                        end)
                    local currentConcentration = concentrationData and concentrationData:GetCurrentAmount() or 0
                    for _, recipeData in ipairs(recipeDataList) do
                        if recipeData.concentrationCost > 0 then
                            local concentrationCosts = recipeData.concentrationCost
                            if options.offsetConcentrationCraftAmount then
                                local ingenuityChance = recipeData.professionStats.ingenuity:GetPercent(true)
                                local ingenuityRefund = 0.5 + recipeData.professionStats.ingenuity:GetExtraValue()
                                concentrationCosts = concentrationCosts -
                                    (concentrationCosts * ingenuityChance * ingenuityRefund)
                            end
                            local queueableAmount = math.floor(currentConcentration / concentrationCosts)
                            if queueableAmount > 0 then
                                local offsetAmount = tonumber(options.offsetQueueAmount) or 0
                                local totalAmount = queueableAmount + offsetAmount
                                recipeData:AdjustSoulboundFinishingForAmount(totalAmount)
                                CraftSim.CRAFTQ:AddRecipe { recipeData = recipeData, amount = totalAmount }
                                currentConcentration = currentConcentration - (concentrationCosts * queueableAmount)
                                break
                            end
                        end
                    end
                end
            end

            CraftSim.CRAFTQ.UI:UpdateDisplay()
        end
    end

    ---@param frameDistributor GUTIL.FrameDistributor
    ---@param recipeID RecipeID
    local function processRecipe(frameDistributor, recipeID)
        local recipeInfo = C_TradeSkillUI.GetRecipeInfo(recipeID)

        if not recipeInfo or recipeInfo.isDummyRecipe or recipeInfo.isGatheringRecipe
            or recipeInfo.isRecraft or recipeInfo.isSalvageRecipe then
            frameDistributor:Continue()
            return
        end

        local recipeData = CraftSim.RecipeData { recipeID = recipeID, crafterData = playerCrafterData }

        if not recipeData then
            frameDistributor:Continue()
            return
        end

        recipeData.craftListID = list.id

        recipeData:SetEquippedProfessionGearSet()
        recipeData:SetCheapestQualityReagentsMax()
        recipeData:Update()

        if recipeData.supportsQualities and options.enableConcentration then
            recipeData.concentrating = true
            recipeData:Update()
        end

        local iconSize = 15
        local recipeIcon = GUTIL:IconToText(recipeData.recipeIcon, iconSize, iconSize)
        local professionIcon = GUTIL:IconToText(CraftSim.CONST.PROFESSION_ICONS[recipeData.professionData.professionInfo.profession], iconSize, iconSize)
        local bagIcon = CreateAtlasMarkup("Banker", iconSize, iconSize)
        local concentrationIcon = GUTIL:IconToText(CraftSim.CONST.CONCENTRATION_ICON, iconSize, iconSize)

        recipeData:Optimize {
            optimizeReagentOptions = options.autoselectTopProfitQuality and { highestProfit = true },
            optimizeConcentration = options.optimizeConcentration,
            optimizeConcentrationProgressCallback = function(progress)
                if queueListsButton then
                    queueListsButton:SetText(string.format("%.0f%% - %s %s %s - %.0f%%",
                    progress,
                    professionIcon,
                    recipeIcon,
                    concentrationIcon,
                    progress))
                end
            end,
            optimizeGear = options.optimizeProfessionTools,
            optimizeFinishingReagentsOptions = options.optimizeFinishingReagents and {
                includeLocked = false,
                includeSoulbound = options.includeSoulboundFinishingReagents,
                progressUpdateCallback = function(progress)
                    if queueListsButton then
                        queueListsButton:SetText(string.format("%.0f%% - %s %s %s - %.0f%%",
                        progress,
                        professionIcon,
                        recipeIcon,
                        bagIcon,
                        progress))
                    end
                end,
            } or nil,
            finally = function()
                if options.smartConcentrationQueuing then
                    tinsert(optimizedRecipes, recipeData)
                else
                    local offsetAmount = tonumber(options.offsetQueueAmount) or 0
                    local totalAmount = 1 + offsetAmount
                    recipeData:AdjustSoulboundFinishingForAmount(totalAmount)
                    CraftSim.CRAFTQ.craftQueue:AddRecipe { recipeData = recipeData, amount = totalAmount }
                    CraftSim.CRAFTQ.UI:UpdateDisplay()
                end
                frameDistributor:Continue()
            end,
        }
    end

    GUTIL.FrameDistributor {
        iterationTable = list.recipeIDs,
        iterationsPerFrame = 1,
        maxIterations = 1000,
        finally = function()
            finalizeRecipe()
            if finally then finally() end
        end,
        continue = function(frameDistributor, _, recipeID)
            processRecipe(frameDistributor, recipeID)
        end,
    }:Continue()
end
