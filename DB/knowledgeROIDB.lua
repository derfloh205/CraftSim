---@class CraftSim
local CraftSim = select(2, ...)

local GUTIL = CraftSim.GUTIL

---@class CraftSim.DB
CraftSim.DB = CraftSim.DB

---@class CraftSim.DB.KNOWLEDGE_ROI : CraftSim.DB.Repository
CraftSim.DB.KNOWLEDGE_ROI = CraftSim.DB:RegisterRepository("KnowledgeROIDB")

local print = CraftSim.DEBUG:RegisterDebugID("Database.knowledgeROIDB")

---@class CraftSim.KnowledgeROIEntry
---@field nodeID number
---@field nodeName string
---@field profession Enum.Profession
---@field expansionID CraftSim.EXPANSION_IDS
---@field currentRank number
---@field maxRank number
---@field roiPerPoint number gold value per knowledge point
---@field totalRemainingROI number total gold value of all remaining ranks
---@field affectedRecipes CraftSim.KnowledgeROIRecipeImpact[]
---@field lastUpdated number GetTime() timestamp

---@class CraftSim.KnowledgeROIRecipeImpact
---@field recipeID RecipeID
---@field recipeName string
---@field currentProfit number
---@field projectedProfit number
---@field profitDelta number
---@field weeklyEstimate number estimated crafts per week

function CraftSim.DB.KNOWLEDGE_ROI:Init()
    if not CraftSimDB.knowledgeROIDB then
        ---@type CraftSimDB.Database
        CraftSimDB.knowledgeROIDB = {
            version = 0,
            ---@type table<CrafterUID, table<number, CraftSim.KnowledgeROIEntry>>
            data = {},
        }
    end

    self.db = CraftSimDB.knowledgeROIDB
    CraftSimDB.knowledgeROIDB.data = CraftSimDB.knowledgeROIDB.data or {}
end

function CraftSim.DB.KNOWLEDGE_ROI:ClearAll()
    wipe(CraftSimDB.knowledgeROIDB.data)
end

function CraftSim.DB.KNOWLEDGE_ROI:CleanUp()
    -- Remove stale entries older than 7 days
    local now = time()
    local maxAge = 7 * 24 * 60 * 60
    for crafterUID, nodeEntries in pairs(CraftSimDB.knowledgeROIDB.data) do
        for nodeID, entry in pairs(nodeEntries) do
            if entry.lastUpdated and (now - entry.lastUpdated) > maxAge then
                nodeEntries[nodeID] = nil
            end
        end
        if not next(nodeEntries) then
            CraftSimDB.knowledgeROIDB.data[crafterUID] = nil
        end
    end
end

---@param crafterUID CrafterUID
---@param nodeID number
---@param entry CraftSim.KnowledgeROIEntry
function CraftSim.DB.KNOWLEDGE_ROI:Save(crafterUID, nodeID, entry)
    CraftSimDB.knowledgeROIDB.data[crafterUID] = CraftSimDB.knowledgeROIDB.data[crafterUID] or {}
    CraftSimDB.knowledgeROIDB.data[crafterUID][nodeID] = entry
end

---@param crafterUID CrafterUID
---@param nodeID number
---@return CraftSim.KnowledgeROIEntry?
function CraftSim.DB.KNOWLEDGE_ROI:Get(crafterUID, nodeID)
    if not CraftSimDB.knowledgeROIDB.data[crafterUID] then return nil end
    return CraftSimDB.knowledgeROIDB.data[crafterUID][nodeID]
end

---@param crafterUID CrafterUID
---@return CraftSim.KnowledgeROIEntry[]
function CraftSim.DB.KNOWLEDGE_ROI:GetAllSorted(crafterUID)
    local entries = {}
    if not CraftSimDB.knowledgeROIDB.data[crafterUID] then return entries end

    for _, entry in pairs(CraftSimDB.knowledgeROIDB.data[crafterUID]) do
        if entry.currentRank < entry.maxRank then
            tinsert(entries, entry)
        end
    end

    table.sort(entries, function(a, b)
        return a.roiPerPoint > b.roiPerPoint
    end)

    return entries
end

---@param crafterUID CrafterUID
function CraftSim.DB.KNOWLEDGE_ROI:ClearForCrafter(crafterUID)
    CraftSimDB.knowledgeROIDB.data[crafterUID] = nil
end
