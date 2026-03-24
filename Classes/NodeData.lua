---@class CraftSim
local CraftSim = select(2, ...)

local GUTIL = CraftSim.GUTIL

local f = GUTIL:GetFormatter()
local L = CraftSim.UTIL:GetLocalizer()

---@class CraftSim.NodeData : CraftSim.CraftSimObject
---@overload fun(recipeData: CraftSim.RecipeData?, baseNodeData: CraftSim.RawPerkData?, perkMap?: table<number, CraftSim.RawPerkData>): CraftSim.NodeData
CraftSim.NodeData = CraftSim.CraftSimObject:extend()

local print = CraftSim.DEBUG:RegisterDebugID("Classes.RecipeData.SpecializationData.NodeData")

---@param recipeData CraftSim.RecipeData?
---@param baseNodeData CraftSim.RawPerkData
---@param perkMap table<number, CraftSim.RawPerkData>
function CraftSim.NodeData:new(recipeData, baseNodeData, perkMap)
    if not recipeData then
        return
    end
    self.nodeID             = baseNodeData.nodeID
    self.recipeData         = recipeData
    self.maxRank            = baseNodeData.maxRank

    ---@type CraftSim.ProfessionStats
    self.professionStats    = CraftSim.ProfessionStats()
    ---@type CraftSim.ProfessionStats
    self.maxProfessionStats = CraftSim.ProfessionStats()

    local configID          = C_ProfSpecs.GetConfigIDForSkillLine(self.recipeData.professionData.skillLineID)
    local nodeInfo          = C_Traits.GetNodeInfo(configID, self.nodeID)

    self.rank               = nodeInfo.activeRank -
        1 -- (a node with 30 max rank will have 31 if maxxed out, so >0 will be active)

    self.active             = false

    local entryIDs          = nodeInfo.entryIDs
    local entryInfos        = GUTIL:Map(entryIDs, function(entryID)
        return C_Traits.GetEntryInfo(configID, entryID)
    end)
    local definitionInfos   = GUTIL:Map(entryInfos, function(entryInfo)
        return C_Traits.GetDefinitionInfo(entryInfo.definitionID)
    end)
    if definitionInfos[1] then
        -- each entry of a node has the same overrideName but could have different descriptions, this is used for the professions to contain the node names..
        self.name = definitionInfos[1].overrideName
    end
    self.name = self.name or "<nodeName?>"
    ---@type CraftSim.PerkData[]
    self.perkData = {}

    for perkID, perkData in pairs(perkMap or {}) do
        tinsert(self.perkData, CraftSim.PerkData(self, perkID, perkData))
    end

    table.sort(self.perkData, function(a, b)
        return a.threshold < b.threshold
    end)

    -- for base node equality stat assignments

    self.raw_stats = baseNodeData.stats or {}

    self.equalsSkill = 0
    self.equalsMulticraft = 0
    self.equalsResourcefulness = 0
    self.equalsIngenuity = 0
    self.equalsResourcefulnessExtraItemsFactor = 0
    self.equalsIngenuityExtraConcentrationFactor = 0
    self.equalsCraftingspeed = 0

    for stat, amount in pairs(self.raw_stats) do
        amount = amount or 0
        if stat == "skill" then
            self.equalsSkill = amount
        elseif stat == "multicraft" then
            self.equalsMulticraft = amount
        elseif stat == "resourcefulness" then
            self.equalsResourcefulness = amount
        elseif stat == "ingenuity" then
            self.equalsIngenuity = amount
        elseif stat == "reagentssavedfromresourcefulness" then
            self.equalsResourcefulnessExtraItemsFactor = amount / 100
        elseif stat == "ingenuityrefundincrease" then
            self.equalsIngenuityExtraConcentrationFactor = amount / 100
        elseif stat == "craftingspeed" then
            self.equalsCraftingspeed = amount / 100
        end
    end
end

function CraftSim.NodeData:Debug()
    local debugLines = {
        "nodeName: " .. tostring(self.name),
        "nodeID: " .. tostring(self.nodeID),
        "active: " .. tostring(self.active),
        "rank: " .. tostring(self.rank) .. " / " .. tostring(self.maxRank),
    }
    return debugLines
end

function CraftSim.NodeData:Update()
    self.active = self.rank >= 0
    for _, perkData in pairs(self.perkData) do
        perkData:Update()
    end

    self:UpdateProfessionStats()
end

function CraftSim.NodeData:UpdateRank()
    local configID = C_ProfSpecs.GetConfigIDForSkillLine(self.recipeData.professionData.skillLineID)
    local nodeInfo = C_Traits.GetNodeInfo(configID, self.nodeID)
    if nodeInfo and nodeInfo.activeRank then
        self.rank = nodeInfo.activeRank - 1
    else
        self.rank = -1
    end
end

function CraftSim.NodeData:UpdateProfessionStats()
    -- always clear stats even if not affected or active
    -- this is important so that stats change to 0 when its not active anymore in the simulator!
    self.professionStats:Clear()
    self.maxProfessionStats:Clear()

    -- first add based on stat equalities (for max always add based on maxRank)

    local rank = self.rank
    local maxRank = self.maxRank

    self.professionStats.skill.value = math.max(0, rank * self.equalsSkill)
    self.maxProfessionStats.skill.value = math.max(0, maxRank * self.equalsSkill)

    self.professionStats.multicraft.value = math.max(0, rank * self.equalsMulticraft)
    self.maxProfessionStats.multicraft.value = math.max(0, maxRank * self.equalsMulticraft)

    self.professionStats.resourcefulness.value = math.max(0, rank * self.equalsResourcefulness)
    self.maxProfessionStats.resourcefulness.value = math.max(0, maxRank * self.equalsResourcefulness)

    self.professionStats.ingenuity.value = math.max(0, rank * self.equalsIngenuity)
    self.maxProfessionStats.ingenuity.value = math.max(0, maxRank * self.equalsIngenuity)

    self.professionStats.craftingspeed.value = math.max(0, rank * self.equalsCraftingspeed)
    self.maxProfessionStats.craftingspeed.value = math.max(0, maxRank * self.equalsCraftingspeed)

    self.professionStats.resourcefulness:SetExtraValue(math.max(0, rank * self.equalsResourcefulnessExtraItemsFactor))
    self.maxProfessionStats.resourcefulness:SetExtraValue(math.max(0,
        maxRank * self.equalsResourcefulnessExtraItemsFactor))

    self.professionStats.ingenuity:SetExtraValue(math.max(0, rank * self.equalsIngenuityExtraConcentrationFactor))
    self.maxProfessionStats.ingenuity:SetExtraValue(math.max(0, maxRank * self
        .equalsIngenuityExtraConcentrationFactor))

    -- then add stats from perks
    for _, perkData in pairs(self.perkData) do
        -- for maxProfessionStats always add
        self.maxProfessionStats:add(perkData.professionStats)

        -- otherwise only if active
        if perkData.active then
            self.professionStats:add(perkData.professionStats)
        end
    end
end

---@param recipeData CraftSim.RecipeData
---@return boolean
function CraftSim.NodeData:HasRelevantStats(recipeData)
    local maxStats = self.maxProfessionStats

    -- skill and craftingspeed are always relevant
    if maxStats.skill.value > 0 then return true end
    if maxStats.craftingspeed.value > 0 then return true end

    -- check conditional stats: only relevant if the recipe supports them
    local conditionalStats = {
        { stat = maxStats.multicraft,       supported = recipeData.supportsMulticraft },
        { stat = maxStats.resourcefulness,  supported = recipeData.supportsResourcefulness },
        { stat = maxStats.ingenuity,        supported = recipeData.supportsIngenuity },
    }
    for _, entry in pairs(conditionalStats) do
        if entry.supported then
            if entry.stat.value > 0 then return true end
            for _, v in pairs(entry.stat.extraValues) do
                if v > 0 then return true end
            end
        end
    end

    return false
end

---@return string
function CraftSim.NodeData:GetName()
    if self.name then return self.name end
    local configID = C_ProfSpecs.GetConfigIDForSkillLine(self.recipeData.professionData.skillLineID)
    local nodeInfo = C_Traits.GetNodeInfo(configID, self.nodeID)
    if nodeInfo and nodeInfo.entryIDs then
        local entryInfos = GUTIL:Map(nodeInfo.entryIDs, function(entryID)
            return C_Traits.GetEntryInfo(configID, entryID)
        end)
        local definitionInfos = GUTIL:Map(entryInfos, function(entryInfo)
            return C_Traits.GetDefinitionInfo(entryInfo.definitionID)
        end)
        if definitionInfos[1] then
            return definitionInfos[1].overrideName or "<nodeName?>"
        end
    end
    return "<nodeName?>"
end

---@return number? icon
function CraftSim.NodeData:GetIcon()
    local entryIDs = C_Traits.GetNodeInfo(C_ProfSpecs.GetConfigIDForSkillLine(self.recipeData.professionData.skillLineID), self.nodeID).entryIDs
    local entryInfos = GUTIL:Map(entryIDs, function(entryID)
        return C_Traits.GetEntryInfo(C_ProfSpecs.GetConfigIDForSkillLine(self.recipeData.professionData.skillLineID), entryID)
    end)
    local definitionInfos   = GUTIL:Map(entryInfos, function(entryInfo)
        return C_Traits.GetDefinitionInfo(entryInfo.definitionID)
    end)
    if definitionInfos[1] then
        return definitionInfos[1].overrideIcon
    end

    return nil
end

---@return string
function CraftSim.NodeData:GetTooltipText()
    local icon = self:GetIcon()
    local header = GUTIL:IconToText(icon, 30, 30) .. " " .. self:GetName()
    local tooltipText = header ..
        "\n\n" .. GUTIL:ColorizeText(tostring(C_ProfSpecs.GetDescriptionForPath(self.nodeID)), GUTIL.COLORS.WHITE)
    for _, perkData in ipairs(self.perkData) do
        local rankText = L(CraftSim.CONST.TEXT.NODE_DATA_RANK_TEXT) .. perkData.threshold .. ":\n"
        local perkDescription = C_ProfSpecs.GetDescriptionForPerk(perkData.perkID)

        if perkData.active then
            rankText = GUTIL:ColorizeText(rankText, GUTIL.COLORS.GREEN)
            perkDescription = GUTIL:ColorizeText(perkDescription, GUTIL.COLORS.WHITE)
        else
            rankText = GUTIL:ColorizeText(rankText, GUTIL.COLORS.GREY)
            perkDescription = GUTIL:ColorizeText(perkDescription, GUTIL.COLORS.GREY)
        end
        tooltipText = tooltipText .. "\n\n" .. rankText .. perkDescription
    end

    tooltipText = tooltipText ..
        L(CraftSim.CONST.TEXT.NODE_DATA_TOOLTIP) ..
        GUTIL:ColorizeText(self.professionStats:GetTooltipText(self.maxProfessionStats), GUTIL.COLORS.WHITE)

    local currentCrafterUID = self.recipeData and self.recipeData:GetCrafterUID()
    if currentCrafterUID then
        local crafterUIDRankMap = CraftSim.DB.CRAFTER:GetCrafterUIDsWithNodeActive(self.nodeID, currentCrafterUID)
        if next(crafterUIDRankMap) then
            tooltipText = tooltipText .. "\n\n"
            for crafterUID, rank in pairs(crafterUIDRankMap) do
                local crafterClass = CraftSim.DB.CRAFTER:GetClass(crafterUID)
                local crafterNameColored = C_ClassColor.GetClassColor(crafterClass):WrapTextInColorCode(crafterUID)
                tooltipText = tooltipText .. crafterNameColored .. ": " .. rank .. "/" .. self.maxRank .. "\n"
            end
        end
    end

    return tooltipText
end

function CraftSim.NodeData:GetJSON(indent)
    indent = indent or 0
    local jb = CraftSim.JSONBuilder(indent)
    jb:Begin()
    jb:Add("nodeID", self.nodeID)
    jb:Add("active", self.active)
    jb:Add("rank", self.rank)
    jb:Add("maxRank", self.maxRank)
    jb:Add("nodeName", self.name)
    jb:Add("professionStats", self.professionStats)
    jb:AddList("perkData", self.perkData)
    jb:End()
    return jb.json
end

---@class CraftSim.NodeData.Serialized
---@field nodeID number
---@field rank number

---@return CraftSim.NodeData.Serialized
function CraftSim.NodeData:Serialize()
    ---@type CraftSim.NodeData.Serialized
    return {
        nodeID = self.nodeID,
        rank = self.rank,
    }
end

---@param serializedData CraftSim.NodeData.Serialized
---@param recipeData CraftSim.RecipeData
---@return CraftSim.NodeData?
function CraftSim.NodeData:Deserialize(serializedData, recipeData)
    local expansionID = recipeData.professionData.expansionID
    local professionID = recipeData.professionData.professionInfo.profession
    local expansionSpecData = CraftSim.SPECIALIZATION_DATA.NODE_DATA[expansionID]
    if not expansionSpecData then return nil end

    local professionSpecData = expansionSpecData[professionID]
    if not professionSpecData then return nil end

    local rawNodeDataList = professionSpecData.nodeData
    local rawBaseNodeData = rawNodeDataList[serializedData.nodeID]
    if not rawBaseNodeData then return nil end

    -- Build the perkMap for this node from static data
    local perkMap = {}
    for perkID, rawPerkData in pairs(rawNodeDataList) do
        if rawPerkData.nodeID == serializedData.nodeID and rawPerkData.maxRank == 1 then
            perkMap[perkID] = rawPerkData
        end
    end

    return CraftSim.NodeData:BuildFromStaticData(recipeData, rawBaseNodeData, perkMap, serializedData.rank)
end

--- Builds a NodeData object from static SPECIALIZATION_DATA without calling
--- character-specific WoW APIs (C_Traits.GetNodeInfo activeRank etc.).
--- Name is intentionally omitted so it is fetched lazily via GetName() when needed for display.
---@param recipeData CraftSim.RecipeData
---@param rawBaseNodeData CraftSim.RawPerkData
---@param perkMap table<number, CraftSim.RawPerkData>
---@param rank number
---@return CraftSim.NodeData
function CraftSim.NodeData:BuildFromStaticData(recipeData, rawBaseNodeData, perkMap, rank)
    local nodeData = CraftSim.NodeData()
    nodeData.nodeID             = rawBaseNodeData.nodeID
    nodeData.recipeData         = recipeData
    nodeData.maxRank            = rawBaseNodeData.maxRank
    nodeData.professionStats    = CraftSim.ProfessionStats()
    nodeData.maxProfessionStats = CraftSim.ProfessionStats()
    nodeData.rank               = rank
    nodeData.active             = false
    -- icon is available in the static raw data; name is fetched lazily via GetName()
    nodeData.icon               = rawBaseNodeData.icon

    -- Populate equals* multipliers from static raw_stats (needed by UpdateProfessionStats)
    nodeData.raw_stats                               = rawBaseNodeData.stats or {}
    nodeData.equalsSkill                             = 0
    nodeData.equalsMulticraft                        = 0
    nodeData.equalsResourcefulness                   = 0
    nodeData.equalsIngenuity                         = 0
    nodeData.equalsResourcefulnessExtraItemsFactor   = 0
    nodeData.equalsIngenuityExtraConcentrationFactor = 0
    nodeData.equalsCraftingspeed                     = 0

    for stat, amount in pairs(nodeData.raw_stats) do
        amount = amount or 0
        if stat == "skill" then
            nodeData.equalsSkill = amount
        elseif stat == "multicraft" then
            nodeData.equalsMulticraft = amount
        elseif stat == "resourcefulness" then
            nodeData.equalsResourcefulness = amount
        elseif stat == "ingenuity" then
            nodeData.equalsIngenuity = amount
        elseif stat == "reagentssavedfromresourcefulness" then
            nodeData.equalsResourcefulnessExtraItemsFactor = amount / 100
        elseif stat == "ingenuityrefundincrease" then
            nodeData.equalsIngenuityExtraConcentrationFactor = amount / 100
        elseif stat == "craftingspeed" then
            nodeData.equalsCraftingspeed = amount / 100
        end
    end

    -- Build perkData from static perkMap.
    -- C_ProfSpecs.GetUnlockRankForPerk returns static game data (threshold rank),
    -- safe to call regardless of current character.
    nodeData.perkData = {}
    for perkID, perkRawData in pairs(perkMap) do
        tinsert(nodeData.perkData, CraftSim.PerkData(nodeData, perkID, perkRawData))
    end
    table.sort(nodeData.perkData, function(a, b)
        return a.threshold < b.threshold
    end)

    -- Derive active, professionStats and maxProfessionStats from rank + static data.
    -- Update() uses self.rank as-is and does NOT call UpdateRank() (which would overwrite
    -- the saved rank with the current character's rank from the WoW API).
    nodeData:Update()

    return nodeData
end
