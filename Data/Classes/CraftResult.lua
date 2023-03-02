_, CraftSim = ...

---@class CraftSim.CraftResult
CraftSim.CraftResult = CraftSim.Object:extend()

---@param recipeData CraftSim.RecipeData
---@param craftingItemResultData CraftingItemResultData[]
function CraftSim.CraftResult:new(recipeData, craftingItemResultData)
    self.recipeID = recipeData.recipeID
    ---@type CraftSim.CraftResultItem[]
    self.craftResultItems = {}
    ---@type CraftSim.CraftResultSavedReagent[]
    self.savedReagents = {}
    self.expectedQuality = recipeData.resultData.expectedQuality
    self.triggeredInspiration = false
    self.triggeredMulticraft = false
    self.triggeredResourcefulness = false

    for _, craftingItemResult in pairs(craftingItemResultData) do
        
        if craftingItemResult.isCrit then
            self.triggeredInspiration = true
        end
        
        if craftingItemResult.multicraft and craftingItemResult.multicraft > 0 then
            self.triggeredMulticraft = true
        end
        
        table.insert(self.craftResultItems, CraftSim.CraftResultItem(craftingItemResult.hyperlink, craftingItemResult.quantity, craftingItemResult.multicraft, craftingItemResult.craftingQuality))
    end

    -- just take resourcefulness from the first craftResult
    -- this is because of a blizzard bug where the same proc is listed in every craft result
    self.savedCosts = 0
    if craftingItemResultData[1].resourcesReturned then
        self.triggeredResourcefulness = true
        for _, craftingResourceReturnInfo in pairs(craftingItemResultData[1].resourcesReturned) do
            local craftResultSavedReagent = CraftSim.CraftResultSavedReagent(recipeData, craftingResourceReturnInfo.itemID, craftingResourceReturnInfo.quantity)
            self.savedCosts = self.savedCosts + craftResultSavedReagent.savedCosts
            table.insert(self.savedReagents, craftResultSavedReagent)
        end
    end

    local inspChance = ((recipeData.supportsCraftingStats and recipeData.supportsInspiration) and recipeData.professionStats.inspiration:GetPercent(true)) or 1
    local mcChance = ((recipeData.supportsCraftingStats and recipeData.supportsMulticraft) and recipeData.professionStats.multicraft:GetPercent(true)) or 1
    local resChance = ((recipeData.supportsCraftingStats and recipeData.supportsResourcefulness) and recipeData.professionStats.resourcefulness:GetPercent(true)) or 1
    
    self.expectedAverageSavedCosts = (recipeData.supportsCraftingStats and CraftSim.CALC:getResourcefulnessSavedCosts(recipeData)*resChance) or 0

    if inspChance < 1 then
        inspChance = (self.triggeredInspiration and inspChance) or (1-inspChance)
    end

    if mcChance < 1 then
        mcChance = (self.triggeredMulticraft and mcChance) or (1-mcChance)
    end

    local totalResChance = 1
    local numProcced = #self.savedReagents
    if resChance < 1 and self.triggeredResourcefulness then
        totalResChance = resChance ^ numProcced
    elseif resChance < 1 then
        totalResChance = (1-resChance) ^ numProcced
    end

    self.craftingChance = inspChance*mcChance*totalResChance

    local craftProfit = CraftSim.CRAFT_RESULTS:GetProfitForCraft(recipeData, self) 

    self.profit = craftProfit
    self.expectedAverageProfit = CraftSim.CALC:GetAverageProfit(recipeData)
end

function CraftSim.CraftResult:Debug()
    local debugLines = {
        "recipeID: " .. tostring(self.recipeID),
        "profit: " .. CraftSim.GUTIL:FormatMoney(self.profit, true),
        "expectedAverageProfit: " .. CraftSim.GUTIL:FormatMoney(self.expectedAverageProfit, true),
        "expectedAverageSavedCosts: " .. CraftSim.GUTIL:FormatMoney(self.expectedAverageSavedCosts, true),
        "expectedQuality: " .. tostring(self.expectedQuality),
        "craftingChance: " .. tostring((self.craftingChance or 0)*100) .. "%",
        "triggeredInspiration: " .. tostring(self.triggeredInspiration),
        "triggeredMulticraft: " .. tostring(self.triggeredMulticraft),
        "triggeredResourcefulness: " .. tostring(self.triggeredResourcefulness),
    }
    if #self.craftResultItems > 0 then
        table.insert(debugLines, "Items:")
        table.foreach(self.craftResultItems, function (_, resultItem)
            local lines = resultItem:Debug()
            lines = CraftSim.GUTIL:Map(lines, function (line) return "-" .. line end)
            debugLines = CraftSim.GUTIL:Concat({debugLines, lines})
        end)
    end

    if #self.savedReagents > 0 then
        table.insert(debugLines, "SavedReagents:")
        table.foreach(self.savedReagents, function (_, savedReagent)
            local lines = savedReagent:Debug()
            lines = CraftSim.GUTIL:Map(lines, function (line) return "-" .. line end)
            debugLines = CraftSim.GUTIL:Concat({debugLines, lines})
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
    jb:Add("triggeredInspiration", self.triggeredInspiration)
    jb:Add("triggeredMulticraft", self.triggeredMulticraft)
    jb:Add("triggeredResourcefulness", self.triggeredResourcefulness)
    jb:AddList("craftResultItems", self.craftResultItems)
    jb:AddList("savedReagents", self.savedReagents, true)
    jb:End()
    return jb.json
end