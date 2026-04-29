---@class CraftSim
local CraftSim = select(2, ...)

local GUTIL = CraftSim.GUTIL

---@class CraftSim.DB
CraftSim.DB = CraftSim.DB

---@class CraftSim.DB.KNOWLEDGE_POINT_VALUE : CraftSim.DB.Repository
CraftSim.DB.KNOWLEDGE_POINT_VALUE = CraftSim.DB:RegisterRepository("KnowledgePointValueDB")

local print = CraftSim.DEBUG:RegisterDebugID("Database.knowledgePointValueDB")

---@class CraftSim.KnowledgePointValueEntry
---@field nodeID number
---@field nodeName string
---@field profession Enum.Profession
---@field expansionID CraftSim.EXPANSION_IDS
---@field currentRank number
---@field maxRank number
---@field roiPerPoint number gold value per knowledge point
---@field totalRemainingROI number total gold value of all remaining ranks
---@field affectedRecipes CraftSim.KnowledgePointValueRecipeImpact[]
---@field lastUpdated number GetTime() timestamp

---@class CraftSim.KnowledgePointValueRecipeImpact
---@field recipeID RecipeID
---@field recipeName string
---@field currentProfit number
---@field projectedProfit number
---@field profitDelta number
---@field weeklyEstimate number estimated crafts per week

function CraftSim.DB.KNOWLEDGE_POINT_VALUE:Init()
    -- Migrate from old knowledgeROIDB key if present
    if CraftSimDB.knowledgeROIDB and not CraftSimDB.KnowledgePointValueDB then
        CraftSimDB.KnowledgePointValueDB = CraftSimDB.knowledgeROIDB
        CraftSimDB.knowledgeROIDB = nil
    end

    if not CraftSimDB.KnowledgePointValueDB then
        ---@type CraftSimDB.Database
        CraftSimDB.KnowledgePointValueDB = {
            version = 0,
            ---@type table<CrafterUID, table<number, CraftSim.KnowledgePointValueEntry>>
            data = {},
        }
    end

    self.db = CraftSimDB.KnowledgePointValueDB
    CraftSimDB.KnowledgePointValueDB.data = CraftSimDB.KnowledgePointValueDB.data or {}
end

function CraftSim.DB.KNOWLEDGE_POINT_VALUE:ClearAll()
    wipe(CraftSimDB.KnowledgePointValueDB.data)
end

function CraftSim.DB.KNOWLEDGE_POINT_VALUE:CleanUp()
    -- Remove stale entries older than 7 days
    local now = time()
    local maxAge = 7 * 24 * 60 * 60
    for crafterUID, nodeEntries in pairs(CraftSimDB.KnowledgePointValueDB.data) do
        for nodeID, entry in pairs(nodeEntries) do
            if entry.lastUpdated and (now - entry.lastUpdated) > maxAge then
                nodeEntries[nodeID] = nil
            end
        end
        if not next(nodeEntries) then
            CraftSimDB.KnowledgePointValueDB.data[crafterUID] = nil
        end
    end
end

---@param crafterUID CrafterUID
---@param nodeID number
---@param entry CraftSim.KnowledgePointValueEntry
function CraftSim.DB.KNOWLEDGE_POINT_VALUE:Save(crafterUID, nodeID, entry)
    CraftSimDB.KnowledgePointValueDB.data[crafterUID] = CraftSimDB.KnowledgePointValueDB.data[crafterUID] or {}
    CraftSimDB.KnowledgePointValueDB.data[crafterUID][nodeID] = entry
end

---@param crafterUID CrafterUID
---@param nodeID number
---@return CraftSim.KnowledgePointValueEntry?
function CraftSim.DB.KNOWLEDGE_POINT_VALUE:Get(crafterUID, nodeID)
    if not CraftSimDB.KnowledgePointValueDB.data[crafterUID] then return nil end
    return CraftSimDB.KnowledgePointValueDB.data[crafterUID][nodeID]
end

---@param crafterUID CrafterUID
---@return CraftSim.KnowledgePointValueEntry[]
function CraftSim.DB.KNOWLEDGE_POINT_VALUE:GetAllSorted(crafterUID)
    local entries = {}
    if not CraftSimDB.KnowledgePointValueDB.data[crafterUID] then return entries end

    for _, entry in pairs(CraftSimDB.KnowledgePointValueDB.data[crafterUID]) do
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
function CraftSim.DB.KNOWLEDGE_POINT_VALUE:ClearForCrafter(crafterUID)
    CraftSimDB.KnowledgePointValueDB.data[crafterUID] = nil
end

--- Weekly Plan persistence ---

---@class CraftSim.KnowledgePointValue.WeeklyPlan
---@field path CraftSim.KnowledgePointValue.PathStep[]
---@field availablePoints number points available when plan was created
---@field totalGain number cumulative ROI of the full path
---@field profession Enum.Profession
---@field savedAt number time() timestamp
---@field topNodeName string? name of the best node for chat display

---@param crafterUID CrafterUID
---@param profession Enum.Profession
---@param plan CraftSim.KnowledgePointValue.WeeklyPlan
function CraftSim.DB.KNOWLEDGE_POINT_VALUE:SaveWeeklyPlan(crafterUID, profession, plan)
    CraftSimDB.KnowledgePointValueDB.data[crafterUID] = CraftSimDB.KnowledgePointValueDB.data[crafterUID] or {}
    CraftSimDB.KnowledgePointValueDB.data[crafterUID]["__weeklyPlan_" .. profession] = plan
end

---@param crafterUID CrafterUID
---@param profession Enum.Profession
---@return CraftSim.KnowledgePointValue.WeeklyPlan?
function CraftSim.DB.KNOWLEDGE_POINT_VALUE:GetWeeklyPlan(crafterUID, profession)
    if not CraftSimDB.KnowledgePointValueDB.data[crafterUID] then return nil end
    return CraftSimDB.KnowledgePointValueDB.data[crafterUID]["__weeklyPlan_" .. profession]
end
