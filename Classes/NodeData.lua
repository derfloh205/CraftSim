---@class CraftSim
local CraftSim = select(2, ...)

local GUTIL = CraftSim.GUTIL

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
        self.icon = definitionInfos[1].overrideIcon
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

---@return string
function CraftSim.NodeData:GetTooltipText()
    local header = GUTIL:IconToText(self.icon, 30, 30) .. " " .. tostring(self.name)
    local tooltipText = header ..
        "\n\n" .. GUTIL:ColorizeText(tostring(C_ProfSpecs.GetDescriptionForPath(self.nodeID)), GUTIL.COLORS.WHITE)
    for _, perkData in ipairs(self.perkData) do
        local rankText = CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.NODE_DATA_RANK_TEXT) .. perkData.threshold .. ":\n"
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
        CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.NODE_DATA_TOOLTIP) ..
        GUTIL:ColorizeText(self.professionStats:GetTooltipText(self.maxProfessionStats), GUTIL.COLORS.WHITE)

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
---@field perkData CraftSim.PerkData.Serialized[]
---@field professionStats CraftSim.ProfessionStats.Serialized
---@field maxProfessionStats CraftSim.ProfessionStats.Serialized
---@field name string
---@field icon number
---@field active boolean
---@field rank number
---@field maxRank number

---@return CraftSim.NodeData.Serialized
function CraftSim.NodeData:Serialize()
    ---@type CraftSim.NodeData.Serialized
    local serializedData = {}
    serializedData.nodeID = self.nodeID
    serializedData.name = self.name
    serializedData.icon = self.icon
    serializedData.professionStats = self.professionStats:Serialize()
    serializedData.maxProfessionStats = self.maxProfessionStats:Serialize()
    serializedData.rank = self.rank
    serializedData.maxRank = self.maxRank
    serializedData.active = self.active
    serializedData.perkData = GUTIL:Map(self.perkData, function(perkData)
        return perkData:Serialize()
    end)

    return serializedData
end

---@param serializedData CraftSim.NodeData.Serialized
---@param recipeData CraftSim.RecipeData
---@return CraftSim.NodeData
function CraftSim.NodeData:Deserialize(serializedData, recipeData)
    local nodeData = CraftSim.NodeData()
    nodeData.professionStats = CraftSim.ProfessionStats:Deserialize(serializedData.professionStats)
    nodeData.maxProfessionStats = CraftSim.ProfessionStats:Deserialize(serializedData.maxProfessionStats)
    nodeData.nodeID = serializedData.nodeID
    nodeData.recipeData = recipeData
    nodeData.name = serializedData.name
    nodeData.icon = serializedData.icon
    nodeData.active = serializedData.active
    nodeData.rank = serializedData.rank
    nodeData.maxRank = serializedData.maxRank
    nodeData.perkData = GUTIL:Map(serializedData.perkData, function(serializedPerkData)
        return CraftSim.PerkData:Deserialize(nodeData, serializedPerkData)
    end)

    return nodeData
end
