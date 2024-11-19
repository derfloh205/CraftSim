---@class CraftSim
local CraftSim = select(2, ...)

local print = CraftSim.DEBUG:RegisterDebugID("Classes.CraftSessionData")

---@class CraftSim.CraftSessionData : CraftSim.CraftSimObject
---@overload fun(): CraftSim.CraftSessionData
CraftSim.CraftSessionData = CraftSim.CraftSimObject:extend()

function CraftSim.CraftSessionData:new()
    self.totalProfit = 0
    self.numCrafts = 0
    ---@type CraftSim.CraftResultItem[]
    self.totalItems = {}
    ---@type CraftSim.CraftResultReagent[]
    self.totalReagents = {}
    ---@type CraftSim.CraftResultReagent[]
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
---@param enableAdvData boolean
function CraftSim.CraftSessionData:AddCraftResult(craftResult, enableAdvData)
    print("SessionData: AddCraftResult")
    self.numCrafts = self.numCrafts + 1
    table.insert(self.craftResults, craftResult)

    local craftGarbageCollectEnabled = CraftSim.DB.OPTIONS:Get("CRAFTING_GARBAGE_COLLECTION_ENABLED")
    local craftGarbageCollectCrafts = CraftSim.DB.OPTIONS:Get("CRAFTING_GARBAGE_COLLECTION_CRAFTS")

    -- if enabled and the correct number of modulo crafts -> collect garbage
    if craftGarbageCollectEnabled and craftGarbageCollectCrafts > 0 then
        if (self.numCrafts % craftGarbageCollectCrafts) == 0 then
            collectgarbage()
        end
    end

    self.totalProfit = self.totalProfit + craftResult.profit

    if enableAdvData then
        CraftSim.CRAFT_LOG:MergeCraftResultItemData(self.totalItems, craftResult.craftResultItems)
        CraftSim.CRAFT_LOG:MergeReagentsItemData(self.totalReagents, craftResult.reagents)
        CraftSim.CRAFT_LOG:MergeReagentsItemData(self.totalSavedReagents, craftResult.savedReagents)
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
