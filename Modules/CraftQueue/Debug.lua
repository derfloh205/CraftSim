---@class CraftSim
local CraftSim = select(2, ...)

local GUTIL = CraftSim.GUTIL

---@class CraftSim.CRAFTQ : CraftSim.Module
CraftSim.CRAFTQ = CraftSim.CRAFTQ

---@class CraftSim.CRAFTQ.DEBUG : CraftSim.Module.Debug
CraftSim.CRAFTQ.DEBUG = { label = "Craft Queue" }

function CraftSim.CRAFTQ.DEBUG:Inspect_CraftQueueItems()
    if not CraftSim.CRAFTQ.craftQueue then return end
    local nameMap = {}
    for index, cqi in pairs(CraftSim.CRAFTQ.craftQueue.craftQueueItems) do
        nameMap["[" .. index .. "] " .. cqi.recipeData:GetCrafterUID() .. "-" .. cqi.recipeData.recipeName] =
            cqi
    end
    CraftSim.DEBUG:InspectTable(nameMap, "CraftQueueItems", true)
end

function CraftSim.CRAFTQ.DEBUG:Inspect_QuickBuyCache()
    if not CraftSim.CRAFTQ.quickBuyCache then return end
    CraftSim.DEBUG:InspectTable(CraftSim.CRAFTQ.quickBuyCache, "QuickBuyCache", true)
end
