---@class CraftSim
local CraftSim = select(2, ...)

local print = CraftSim.DEBUG:SetDebugPrint(CraftSim.CONST.DEBUG_IDS.CRAFT_LOG)

---@class CraftSim.CraftSessionData : CraftSim.CraftSimObject
---@overload fun(): CraftSim.CraftSessionData
CraftSim.CraftSessionData = CraftSim.CraftSimObject:extend()

function CraftSim.CraftSessionData:new()
    self.totalProfit = 0
    self.numCrafts = 0
    ---@type CraftSim.CraftResultItem[]
    self.totalItems = {}
    ---@type CraftSim.CraftResultSavedReagent[]
    self.totalSavedReagents = {}
    ---@type table<RecipeID, CraftSim.CraftRecipeData>
    self.craftRecipeData = {}
    ---@type CraftSim.CraftResult[]
    self.craftResults = {}
end

---@param recipeID number
---@return CraftSim.CraftRecipeData craftRecipeData
function CraftSim.CraftSessionData:GetCraftRecipeData(recipeID)
    self.craftRecipeData[recipeID] = self.craftRecipeData[recipeID] or CraftSim.CraftRecipeData(recipeID)
    return self.craftRecipeData[recipeID]
end

---@param craftResult CraftSim.CraftResult
function CraftSim.CraftSessionData:AddCraftResult(craftResult)
    print("SessionData: AddCraftResult")
    self.numCrafts = self.numCrafts + 1
    table.insert(self.craftResults, craftResult) -- TODO: check for RAM bloat when crafting alot!!

    local craftGarbageCollectEnabled = CraftSim.DB.OPTIONS:Get("CRAFTING_GARBAGE_COLLECTION_ENABLED")
    local craftGarbageCollectCrafts = CraftSim.DB.OPTIONS:Get("CRAFTING_GARBAGE_COLLECTION_CRAFTS")

    --TODO: Move
    -- if enabled and the correct number of modulo crafts -> collect garbage
    if craftGarbageCollectEnabled and craftGarbageCollectCrafts > 0 then
        if (self.numCrafts % craftGarbageCollectCrafts) == 0 then
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
            craftResultItemB.quantity = craftResultItemB.quantity +
                (craftResultItemA.quantity + craftResultItemA.quantityMulticraft)
            craftResultItemB.quantityMulticraft = craftResultItemB.quantityMulticraft +
                craftResultItemA.quantityMulticraft
        else
            table.insert(self.totalItems, craftResultItemA:Copy())
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
