---@class CraftSim
local CraftSim = select(2, ...)

---@class CraftSim.CraftResult : CraftSim.CraftSimObject
---@overload fun(recipeData: CraftSim.RecipeData, craftingItemResultData: CraftingItemResultData): CraftSim.CraftResult
CraftSim.CraftResult = CraftSim.CraftSimObject:extend()

---@param recipeData CraftSim.RecipeData
---@param craftingItemResultData CraftingItemResultData[]
function CraftSim.CraftResult:new(recipeData, craftingItemResultData)
    self.recipeID = recipeData.recipeID
    ---@type CraftSim.CraftResultItem[]
    self.craftResultItems = {}
    ---@type CraftSim.CraftResultSavedReagent[]
    self.savedReagents = {}
    self.expectedQuality = recipeData.resultData.expectedQuality
    self.triggeredMulticraft = false
    self.triggeredResourcefulness = false
    self.triggeredIngenuity = false
    self.savedConcentration = 0
    self.usedConcentration = 0
    self.ingenuityRefund = 0

    for _, craftingItemResult in pairs(craftingItemResultData) do
        if craftingItemResult.multicraft and craftingItemResult.multicraft > 0 then
            self.triggeredMulticraft = true
        end

        if craftingItemResult.hasIngenuityProc then
            self.triggeredIngenuity = true
            self.savedConcentration = craftingItemResult.ingenuityRefund or 0
        end

        self.ingenuityRefund = craftingItemResult.ingenuityRefund or 0
        self.usedConcentration = craftingItemResult.concentrationSpent or 0

        table.insert(self.craftResultItems,
            CraftSim.CraftResultItem(craftingItemResult.hyperlink, craftingItemResult.quantity,
                craftingItemResult.multicraft, craftingItemResult.craftingQuality))
    end

    -- just take resourcefulness from the first craftResult
    -- this is because of a blizzard bug where the same proc is listed in every craft result
    self.savedCosts = 0
    if craftingItemResultData[1].resourcesReturned then
        self.triggeredResourcefulness = true
        for _, craftingResourceReturnInfo in pairs(craftingItemResultData[1].resourcesReturned) do
            local craftResultSavedReagent = CraftSim.CraftResultSavedReagent(recipeData,
                craftingResourceReturnInfo.itemID, craftingResourceReturnInfo.quantity)
            self.savedCosts = self.savedCosts + craftResultSavedReagent.savedCosts
            table.insert(self.savedReagents, craftResultSavedReagent)
        end
    end


    local mcChance = ((recipeData.supportsCraftingStats and recipeData.supportsMulticraft) and recipeData.professionStats.multicraft:GetPercent(true)) or
        1
    local resChance = ((recipeData.supportsCraftingStats and recipeData.supportsResourcefulness) and recipeData.professionStats.resourcefulness:GetPercent(true)) or
        1

    self.expectedAverageSavedCosts = (recipeData.supportsCraftingStats and CraftSim.CALC:GetResourcefulnessSavedCosts(recipeData) * resChance) or
        0

    if mcChance < 1 then
        mcChance = (self.triggeredMulticraft and mcChance) or (1 - mcChance)
    end

    local totalResChance = 1
    local numProcced = #self.savedReagents
    if resChance < 1 and self.triggeredResourcefulness then
        totalResChance = resChance ^ numProcced
    elseif resChance < 1 then
        totalResChance = (1 - resChance) ^ numProcced
    end

    self.craftingChance = mcChance * totalResChance

    local craftProfit = CraftSim.CRAFT_LOG:GetProfitForCraft(recipeData, self)

    self.profit = craftProfit
    self.expectedAverageProfit = CraftSim.CALC:GetAverageProfit(recipeData)
end

---@return number
function CraftSim.CraftResult:GetMulticraftExtraItems()
    local multicraftExtraItems = 0
    for _, craftResultItemA in ipairs(self.craftResultItems) do
        self.observedStats.totalMulticraftExtraItems = self.observedStats.totalMulticraftExtraItems +
            craftResultItemA.quantityMulticraft

        local craftResultItemB = CraftSim.GUTIL:Find(self.totalItems, function(craftResultItemB)
            local itemLinkA = craftResultItemA.item:GetItemLink() -- for gear its possible to match by itemlink
            local itemLinkB = craftResultItemB.item:GetItemLink()
            local itemIDA = craftResultItemA.item:GetItemID()
            local itemIDB = craftResultItemB.item:GetItemID()

            if itemLinkA and itemLinkB then -- if one or both are nil aka not loaded, we dont want to match..
                return itemLinkA == itemLinkB
            else
                return itemIDA == itemIDB
            end
        end)
        if craftResultItemB then
            craftResultItemB.quantity = craftResultItemB.quantity +
                (craftResultItemA.quantity + craftResultItemA.quantityMulticraft)
            craftResultItemB.quantityMulticraft = craftResultItemB.quantityMulticraft +
                craftResultItemA.quantityMulticraft
        else
            table.insert(self.totalItems, craftResultItemA:Copy())
        end
    end

    return multicraftExtraItems
end

function CraftSim.CraftResult:Debug()
    local debugLines = {
        "recipeID: " .. tostring(self.recipeID),
        "profit: " .. CraftSim.UTIL:FormatMoney(self.profit, true),
        "expectedAverageProfit: " .. CraftSim.UTIL:FormatMoney(self.expectedAverageProfit, true),
        "expectedAverageSavedCosts: " .. CraftSim.UTIL:FormatMoney(self.expectedAverageSavedCosts, true),
        "expectedQuality: " .. tostring(self.expectedQuality),
        "craftingChance: " .. tostring((self.craftingChance or 0) * 100) .. "%",
        "triggeredMulticraft: " .. tostring(self.triggeredMulticraft),
        "triggeredResourcefulness: " .. tostring(self.triggeredResourcefulness),
    }
    if #self.craftResultItems > 0 then
        table.insert(debugLines, "Items:")
        table.foreach(self.craftResultItems, function(_, resultItem)
            local lines = resultItem:Debug()
            lines = CraftSim.GUTIL:Map(lines, function(line) return "-" .. line end)
            debugLines = CraftSim.GUTIL:Concat({ debugLines, lines })
        end)
    end

    if #self.savedReagents > 0 then
        table.insert(debugLines, "SavedReagents:")
        table.foreach(self.savedReagents, function(_, savedReagent)
            local lines = savedReagent:Debug()
            lines = CraftSim.GUTIL:Map(lines, function(line) return "-" .. line end)
            debugLines = CraftSim.GUTIL:Concat({ debugLines, lines })
        end)
    end


    return debugLines
end

function CraftSim.CraftResult:GetJSON(indent)
    indent = indent or 0
    local jb = CraftSim.JSONBuilder(indent)
    jb:Begin()
    jb:Add("recipeID", self.recipeID)
    jb:Add("profit", self.profit)
    jb:Add("expectedAverageProfit", self.expectedAverageProfit)
    jb:Add("expectedAverageSavedCosts", self.expectedAverageSavedCosts)
    jb:Add("expectedQuality", self.expectedQuality)
    jb:Add("craftingChance", self.craftingChance)
    jb:Add("triggeredMulticraft", self.triggeredMulticraft)
    jb:Add("triggeredResourcefulness", self.triggeredResourcefulness)
    jb:AddList("craftResultItems", self.craftResultItems)
    jb:AddList("savedReagents", self.savedReagents, true)
    jb:End()
    return jb.json
end
