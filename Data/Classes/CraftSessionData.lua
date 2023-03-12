_, CraftSim = ...

local print = CraftSim.UTIL:SetDebugPrint(CraftSim.CONST.DEBUG_IDS.CRAFT_RESULTS)

---@class CraftSim.CraftSessionData
CraftSim.CraftSessionData = CraftSim.Object:extend()

function CraftSim.CraftSessionData:new()
    self.totalProfit = 0
    self.numCrafts = 0
    ---@type CraftSim.CraftResultItem[]
    self.totalItems = {}
    ---@type CraftSim.CraftResultSavedReagent[]
    self.totalSavedReagents = {}
    ---@type CraftSim.CraftRecipeData[]
    self.craftRecipeData = {}
    ---@type CraftSim.CraftResult[]
    self.craftResults = {}
end

---@param recipeID number
---@return CraftSim.CraftRecipeData? craftRecipeData
function CraftSim.CraftSessionData:GetCraftRecipeData(recipeID)
    print("GetCraftRecipeData: " .. tostring(recipeID))
    print("numRecipeData: " .. #self.craftRecipeData)
    table.foreach(self.craftRecipeData, function (_, data)
        print("data recipe id: " .. tostring(data.recipeID))
    end)
    return CraftSim.GUTIL:Find(self.craftRecipeData, function (craftRecipeData)
        return craftRecipeData.recipeID == recipeID
    end)
end

---@param craftResult CraftSim.CraftResult
function CraftSim.CraftSessionData:AddCraftResult(craftResult)
    print("SessionData: AddCraftResult")
    self.numCrafts = self.numCrafts + 1
    table.insert(self.craftResults, craftResult) -- TODO: check for RAM bloat when crafting alot!!

    -- if enabled and the correct number of modulo crafts -> collect garbage
    if CraftSimOptions.craftGarbageCollectEnabled and CraftSimOptions.craftGarbageCollectCrafts > 0 then
        if (self.numCrafts % CraftSimOptions.craftGarbageCollectCrafts) == 0 then
            collectgarbage()
        end
    end

    self.totalProfit = self.totalProfit + craftResult.profit

    for _, craftResultItemA in pairs(craftResult.craftResultItems) do
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
            -- as this should be the same reference, this is also updated in the CraftRecipeData
            craftResultItemB.quantity = craftResultItemB.quantity + (craftResultItemA.quantity - craftResultItemA.quantityMulticraft)
            craftResultItemB.quantityMulticraft = craftResultItemB.quantityMulticraft + craftResultItemA.quantityMulticraft
        else
            table.insert(self.totalItems, craftResultItemA)
        end
    end

    for _, savedReagentA in pairs(craftResult.savedReagents) do
        local savedReagentB = CraftSim.GUTIL:Find(self.totalSavedReagents, function(savedReagentB) 
            return savedReagentA.item:GetItemID() == savedReagentB.item:GetItemID()
        end)

        if savedReagentB then
            -- as this should be the same reference, this is also updated in the CraftRecipeData
            savedReagentB.quantity = savedReagentB.quantity + savedReagentA.quantity
        else
            table.insert(self.totalSavedReagents, savedReagentA)
        end
    end

    print("b4 GetCraftRecipeData: " .. tostring(craftResult.recipeID))
    print(craftResult)
    local craftRecipeData = self:GetCraftRecipeData(craftResult.recipeID)
    if not craftRecipeData then
        print("CraftSessionData: Create new CraftRecipeData")
        craftRecipeData = CraftSim.CraftRecipeData(craftResult.recipeID)
    else
        print("CraftSessionData: Reuse craftRecipeData")
    end

    craftRecipeData:AddCraftResult(craftResult)

    print("craftRecipeData:")
    print(craftRecipeData)
end

function CraftSim.CraftSessionData:GetJSON(intend)
    intend = intend or 0
    local jb = CraftSim.JSONBuilder(intend)
    jb:Begin()
    jb:Add("totalProfit", self.totalProfit)
    jb:Add("numCrafts", self.numCrafts)
    jb:AddList("totalItems", self.totalItems)
    jb:AddList("totalSavedReagents", self.totalSavedReagents)
    jb:AddList("craftRecipeData", self.craftRecipeData, true)
    jb:End()
    return jb.json
end