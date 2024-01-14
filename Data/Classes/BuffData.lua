---@class CraftSim
local CraftSim = select(2, ...)

local GUTIL = CraftSim.GUTIL

---@class CraftSim.BuffData
---@overload fun(recipeData: CraftSim.RecipeData): CraftSim.BuffData
CraftSim.BuffData = CraftSim.Object:extend()

local L = CraftSim.UTIL:GetLocalizer()

local debug = false

local print = CraftSim.UTIL:SetDebugPrint(CraftSim.CONST.DEBUG_IDS.BUFFDATA)

---@param recipeData CraftSim.RecipeData
function CraftSim.BuffData:new(recipeData)
    self.recipeData = recipeData
    ---@type CraftSim.ProfessionStats
    self.professionStats = CraftSim.ProfessionStats()
    ---@type table<number, CraftSim.Buff>
    self.buffs = {}
    self:CreateBuffsByRecipeData()
end

function CraftSim.BuffData:CreateBuffsByRecipeData()
    -- by professionID and professionStats
    if self.recipeData.supportsInspiration then
        --- General Buffs
        table.insert(self.buffs, CraftSim.CRAFT_BUFFS:CreateIncenseBuff(self.recipeData))

        --- Alchemy
        if debug or self.recipeData.professionData.professionInfo.profession == Enum.Profession.Alchemy then
            table.insert(self.buffs, CraftSim.CRAFT_BUFFS:CreateAlchemicallyInspiredBuff(self.recipeData))
        end
    end

    if self.recipeData.supportsCraftingspeed then
        --- General
        tAppendAll(self.buffs, CraftSim.CRAFT_BUFFS:CreateQuickPhialBuffs(self.recipeData))
    end

    if self.recipeData.isCooking then
        -- cooking hat toy
        table.insert(self.buffs, CraftSim.CRAFT_BUFFS:CreateChefsHatBuff(self.recipeData))
    end

    if self.recipeData.supportsQualities then
        --- enchanting
        if self.recipeData.professionData.professionInfo.profession == Enum.Profession.Enchanting then
            -- elemental shatter fire
            if self.recipeData.reagentData:HasOneOfReagents({ 190320, 190321 }) then
                table.insert(self.buffs, CraftSim.CRAFT_BUFFS:CreateElementalShatterFireBuff(self.recipeData))
            end

            -- elemental shatter frost
            if self.recipeData.reagentData:HasOneOfReagents({ 190328, 190329 }) then
                table.insert(self.buffs, CraftSim.CRAFT_BUFFS:CreateElementalShatterFrostBuff(self.recipeData))
            end

            -- elemental shatter earth
            if self.recipeData.reagentData:HasOneOfReagents({ 190316, 190315 }) then
                table.insert(self.buffs, CraftSim.CRAFT_BUFFS:CreateElementalShatterEarthBuff(self.recipeData))
            end

            -- elemental shatter air
            if self.recipeData.reagentData:HasOneOfReagents({ 190326, 190327 }) then
                table.insert(self.buffs, CraftSim.CRAFT_BUFFS:CreateElementalShatterAirBuff(self.recipeData))
            end

            -- elemental shatter order
            if self.recipeData.reagentData:HasOneOfReagents({ 391812, 190324 }) then
                table.insert(self.buffs, CraftSim.CRAFT_BUFFS:CreateElementalShatterOrderBuff(self.recipeData))
            end
        end
    end
end

function CraftSim.BuffData:UpdateBuffs()
    for _, buff in pairs(self.buffs) do
        buff:Update()
    end
end

function CraftSim.BuffData:UpdateProfessionStats()
    --- check for current buffs and adapt professionStats
    self.professionStats:Clear()

    for _, buff in pairs(self.buffs) do
        if buff.active then
            self.professionStats:add(buff.professionStats)
        end
    end
end

function CraftSim.BuffData:Update()
    self:UpdateBuffs()
    self:UpdateProfessionStats()
end

---@param UIDToValueMap table<string, boolean> -- buffUID -> active
function CraftSim.BuffData:SetBuffsByUIDToValueMap(UIDToValueMap)
    for buffUID, active in pairs(UIDToValueMap) do
        self:SetBuffByUID(buffUID, active)
    end
end

---@param buffUID string
---@param active boolean
function CraftSim.BuffData:SetBuffByUID(buffUID, active)
    local buff = GUTIL:Find(self.buffs, function(buff)
        return buff:GetUID() == buffUID
    end)

    if buff then
        print("Setting " .. buff.name .. ": " .. tostring(active))
        buff.active = active
    end
end

function CraftSim.BuffData:Debug()
    local debugLines = {
        "Buffs: ",
    }

    local statLines = GUTIL:Map(self.buffs, function(buff)
        return buff:Debug()
    end)
    statLines = CraftSim.GUTIL:Map(statLines, function(line) return "-" .. line end)
    debugLines = CraftSim.GUTIL:Concat({ debugLines, statLines })

    return debugLines
end

function CraftSim.BuffData:GetJSON(indent)
    indent = indent or 0
    local jb = CraftSim.JSONBuilder(indent)
    jb:Begin()
    jb:Add("professionStats", self.professionStats)
    jb:AddList("buffs", self.buffs, true)
    jb:End()
    return jb.json
end
