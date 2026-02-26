---@class CraftSim
local CraftSim = select(2, ...)

local GUTIL = CraftSim.GUTIL

---@class CraftSim.BuffData : CraftSim.CraftSimObject
---@overload fun(recipeData: CraftSim.RecipeData): CraftSim.BuffData
CraftSim.BuffData = CraftSim.CraftSimObject:extend()

local L = CraftSim.UTIL:GetLocalizer()

local debug = false

local print = CraftSim.DEBUG:RegisterDebugID("Classes.RecipeData.BuffData")

---@param recipeData CraftSim.RecipeData
function CraftSim.BuffData:new(recipeData)
    self.recipeData = recipeData
    ---@type CraftSim.ProfessionStats
    self.professionStats = CraftSim.ProfessionStats()
    ---@type table<number, CraftSim.Buff>
    self.buffs = {}
    self:CreateBuffsByRecipeData()
end

---@param buffID CraftSim.BuffID
---@return boolean isActive
function CraftSim.BuffData:IsBuffActive(buffID)
    local buff = GUTIL:Find(self.buffs, function(buff)
        return buff.buffID == buffID
    end)

    return buff and buff.active
end

function CraftSim.BuffData:CreateBuffsByRecipeData()
    -- by professionID and professionStats

    local profession = self.recipeData.professionData.professionInfo.profession

    print("Creating initial buff data objects: " .. tostring(profession), false, true)

    -- TWW Buffs
    if self.recipeData.expansionID == CraftSim.CONST.EXPANSION_IDS.THE_WAR_WITHIN then
        local currentSeason = CraftSim.UTIL:GetCurrentSeason()
        -- only gives resourcefulness / is relevant in winter and spring
        if currentSeason == 0 or currentSeason == 1 then
            tAppendAll(self.buffs, CraftSim.CRAFT_BUFFS:CreatePhialOfBountifulSeasonsBuffs(self.recipeData))
        end

        tAppendAll(self.buffs, CraftSim.CRAFT_BUFFS:CreatePhialOfAmbidexterityBuffs(self.recipeData))
        tAppendAll(self.buffs, CraftSim.CRAFT_BUFFS:CreatePhialOfConcentratedIngenuityBuffs(self.recipeData))
        tinsert(self.buffs, CraftSim.CRAFT_BUFFS:CreateWeaversTutelageBuff(self.recipeData))
        tinsert(self.buffs, CraftSim.CRAFT_BUFFS:CreateWeaversProdigyBuff(self.recipeData))

        if profession == Enum.Profession.Jewelcrafting then
            -- Crushing
            if self.recipeData.recipeID == 434020 then
                tinsert(self.buffs, CraftSim.CRAFT_BUFFS:CreateJewelersPurseBuff(self.recipeData))
            end
        end

        if profession == Enum.Profession.Tailoring then
            -- Unraveling Only
            if self.recipeData.recipeID == 446926 then
                tinsert(self.buffs, CraftSim.CRAFT_BUFFS:CreateSeveredSatchelBuff(self.recipeData))
            end
        end

        if profession == Enum.Profession.Leatherworking then
            -- for reagent category only
            if self.recipeData.categoryID == 2051 then
                tinsert(self.buffs, CraftSim.CRAFT_BUFFS:CreateHideshapersWorkbagBuff(self.recipeData))
            end
        end

        if profession == Enum.Profession.Blacksmithing then
            tinsert(self.buffs, CraftSim.CRAFT_BUFFS:CreateEverburningIgnitionBuff(self.recipeData))
        end

        if profession == Enum.Profession.Enchanting then
            tinsert(self.buffs, CraftSim.CRAFT_BUFFS:CreateShatteringEssenceBuffTWW(self.recipeData))
        end

        if profession == Enum.Profession.Alchemy then
            -- only for potions (check if the potion spec talent is enabled for this recipe)
            local isPotionRecipe = CraftSim.SPECIALIZATION_DATA:IsRecipeDataAffectedByNodeID(self.recipeData, 99040) -- potion - bulkproduction
            local isFlaskRecipe = CraftSim.SPECIALIZATION_DATA:IsRecipeDataAffectedByNodeID(self.recipeData, 98952)  -- flask - bulkproduction
            local isPhialRecipe = CraftSim.SPECIALIZATION_DATA:IsRecipeDataAffectedByNodeID(self.recipeData, 98951)  -- flask - profession phials
            if isPotionRecipe then
                tinsert(self.buffs, CraftSim.CRAFT_BUFFS:CreatePotionSpillOverBuff(self.recipeData))
            end
            if isPhialRecipe then
                tinsert(self.buffs, CraftSim.CRAFT_BUFFS:CreatePhialSpillOverBuff(self.recipeData))
            end
            if isFlaskRecipe and not isPhialRecipe then
                tinsert(self.buffs, CraftSim.CRAFT_BUFFS:CreateFlaskSpillOverBuff(self.recipeData))
            end
            -- if tww alchemy experimentation recipe
            if self.recipeData.recipeID == 430345 or self.recipeData.recipeID == 427174 then
                tinsert(self.buffs, CraftSim.CRAFT_BUFFS:CreateConcoctorsClutchBuff(self.recipeData))
            end
        end

        if profession == Enum.Profession.Engineering then
            tinsert(self.buffs, CraftSim.CRAFT_BUFFS:CreateInventorsGuileBuff(self.recipeData))

            -- tinkering essentials
            -- not really affect the recipes I think but may be neat to see
            if self.recipeData.categoryID == 2107 then
                tinsert(self.buffs, CraftSim.CRAFT_BUFFS:CreateProdigysToolboxBuff(self.recipeData))
            end
        end

        if profession == Enum.Profession.Inscription then
            -- Improved Ciphers
            if CraftSim.SPECIALIZATION_DATA:IsRecipeDataAffectedByNodeID(self.recipeData, 101626) then
                tinsert(self.buffs, CraftSim.CRAFT_BUFFS:CreateImprovedCiphersBuff(self.recipeData))
            end

            -- Improved Milling
            if CraftSim.SPECIALIZATION_DATA:IsRecipeDataAffectedByNodeID(self.recipeData, 101625) then
                tinsert(self.buffs, CraftSim.CRAFT_BUFFS:CreateImprovedMillingBuff(self.recipeData))
            end

            -- Improved Inks
            if CraftSim.SPECIALIZATION_DATA:IsRecipeDataAffectedByNodeID(self.recipeData, 101624) then
                tinsert(self.buffs, CraftSim.CRAFT_BUFFS:CreateImprovedInksBuff(self.recipeData))
            end

            -- Improved Contracts
            if CraftSim.SPECIALIZATION_DATA:IsRecipeDataAffectedByNodeID(self.recipeData, 101874) then
                tinsert(self.buffs, CraftSim.CRAFT_BUFFS:CreateImprovedContractsBuff(self.recipeData))
            end

            -- Improved Missives
            if CraftSim.SPECIALIZATION_DATA:IsRecipeDataAffectedByNodeID(self.recipeData, 101873) then
                tinsert(self.buffs, CraftSim.CRAFT_BUFFS:CreateImprovedMissivesBuff(self.recipeData))
            end

            -- Improved Vantus
            if CraftSim.SPECIALIZATION_DATA:IsRecipeDataAffectedByNodeID(self.recipeData, 101872) then
                tinsert(self.buffs, CraftSim.CRAFT_BUFFS:CreateImprovedVantusBuff(self.recipeData))
            end

            if self.recipeData.categoryID == 2064 then
                tinsert(self.buffs, CraftSim.CRAFT_BUFFS:CreateDarkmoonDuffleBuff(self.recipeData))
            end
        end
    end

    -- DF Buffs
    if self.recipeData.expansionID == CraftSim.CONST.EXPANSION_IDS.DRAGONFLIGHT then

        if self.recipeData.supportsCraftingspeed then
        --- General
        tAppendAll(self.buffs, CraftSim.CRAFT_BUFFS:CreateQuickPhialBuffs(self.recipeData))
        end

        if self.recipeData.supportsQualities then
            --- general
            tinsert(self.buffs, CraftSim.CRAFT_BUFFS:CreateIncenseBuff(self.recipeData))

            -- alchemy
            if profession == Enum.Profession.Alchemy then
                tinsert(self.buffs, CraftSim.CRAFT_BUFFS:CreateAlchemicallyInspiredBuff(self.recipeData))
            end

            --- enchanting
            if profession == Enum.Profession.Enchanting then
                -- elemental shatter fire
                if self.recipeData.reagentData:HasOneOfReagents({ 190320, 190321 }) then
                    tinsert(self.buffs, CraftSim.CRAFT_BUFFS:CreateElementalShatterFireBuff(self.recipeData))
                end

                -- elemental shatter frost
                if self.recipeData.reagentData:HasOneOfReagents({ 190328, 190329 }) then
                    tinsert(self.buffs, CraftSim.CRAFT_BUFFS:CreateElementalShatterFrostBuff(self.recipeData))
                end

                -- elemental shatter earth
                if self.recipeData.reagentData:HasOneOfReagents({ 190316, 190315 }) then
                    tinsert(self.buffs, CraftSim.CRAFT_BUFFS:CreateElementalShatterEarthBuff(self.recipeData))
                end

                -- elemental shatter air
                if self.recipeData.reagentData:HasOneOfReagents({ 190326, 190327 }) then
                    tinsert(self.buffs, CraftSim.CRAFT_BUFFS:CreateElementalShatterAirBuff(self.recipeData))
                end

                -- elemental shatter order
                if self.recipeData.reagentData:HasOneOfReagents({ 391812, 190324 }) then
                    tinsert(self.buffs, CraftSim.CRAFT_BUFFS:CreateElementalShatterOrderBuff(self.recipeData))
                end
            end
        end
    end

    if self.recipeData.expansionID == CraftSim.CONST.EXPANSION_IDS.MIDNIGHT then
        if self.recipeData.professionData.professionInfo.profession == Enum.Profession.Enchanting then
            tinsert(self.buffs, CraftSim.CRAFT_BUFFS:CreateShatteringEssenceBuffMidnight(self.recipeData))
        end

        if self.recipeData.supportsQualities then
            tAppendAll(self.buffs, CraftSim.CRAFT_BUFFS:CreateHaranirPhialOfIngenuityBuffs(self.recipeData))
        end
    end

    if self.recipeData.isCooking then
        -- cooking hat toy
        tinsert(self.buffs, CraftSim.CRAFT_BUFFS:CreateChefsHatBuff(self.recipeData))
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
