---@class CraftSim
local CraftSim = select(2, ...)

local GUTIL = CraftSim.GUTIL
local L = CraftSim.UTIL:GetLocalizer()
local f = GUTIL:GetFormatter()
local tinsert = tinsert or table.insert

---@class CraftSim.PRE_CRAFT_BUFF_GATE
CraftSim.PRE_CRAFT_BUFF_GATE = {}
local PCBG = CraftSim.PRE_CRAFT_BUFF_GATE

---@alias CraftSim.PreCraftBuffGateId string

---@class CraftSim.PreCraftBuffGateDefinition
---@field id CraftSim.PreCraftBuffGateId
---@field profession Enum.Profession
---@field expansionID CraftSim.EXPANSION_IDS
---@field buffID CraftSim.BuffID
---@field optionForceBuffKey CraftSim.GENERAL_OPTIONS
---@field skillLineID? number When set, used for UNIT_AURA quick-bar visibility check.
---@field castRecipeID? RecipeID Salvage/cast recipe; omit if gate does not implement a craft-queue button.
---@field castSucceededSpellIDs? number[] Spell IDs from UNIT_SPELLCAST_SUCCEEDED that clear post-login stale.
---@field staleRequiresProfessionLearned? Enum.Profession When set, IsStaleEffective is false if this profession is not learned.
---@field setStaleOnRealLogin? boolean
---@field realLoginStaleProfession? Enum.Profession Must be learned to set stale on real login (e.g. Enchanting).
---@field trackLoginStale? boolean When false, stats forcing ignores stale (e.g. Everburning placeholder).
---@field salvagedMoteOptionKey? CraftSim.GENERAL_OPTIONS Midnight / TWW mote picker option key.
---@field implementsCraftQueuePrerequisite? boolean default true when castRecipeID set
---@field quickBarEnabled? boolean Show gate action in quick access bar.
---@field quickBarUseItemID? number Optional item to use directly before falling back to craft.

PCBG.SHATTER_MOTE_SELECTION_CHEAPEST_OWNED = "__CHEAPEST_OWNED__"

---@type CraftSim.PreCraftBuffGateDefinition[]
local gates = {}

--- In-memory post-login stale (mirrors CrafterDB preCraftBuffStale).
---@type table<CraftSim.PreCraftBuffGateId, boolean>
PCBG._runtimeStale = {}

PCBG.awaitingBuffApply = false

---@type number?
PCBG._refreshGen = nil

---@type number?
PCBG._auraDebounceGen = nil

---@param def CraftSim.PreCraftBuffGateDefinition
function PCBG:RegisterGate(def)
    def.implementsCraftQueuePrerequisite = def.implementsCraftQueuePrerequisite
    if def.implementsCraftQueuePrerequisite == nil then
        def.implementsCraftQueuePrerequisite = def.castRecipeID ~= nil
    end
    if def.trackLoginStale == nil then
        def.trackLoginStale = true
    end
    tinsert(gates, def)
end

---@param gateId CraftSim.PreCraftBuffGateId
---@return CraftSim.PreCraftBuffGateDefinition?
function PCBG:GetGate(gateId)
    for _, g in ipairs(gates) do
        if g.id == gateId then
            return g
        end
    end
    return nil
end

---@param crafterUID CrafterUID
function PCBG:LoadRuntimeStaleFromDB(crafterUID)
    for _, gate in ipairs(gates) do
        if gate.trackLoginStale then
            self._runtimeStale[gate.id] = CraftSim.DB.CRAFTER:GetPreCraftBuffStaleAfterLogin(crafterUID, gate.id)
        end
    end
end

---@param initialLogin boolean
---@param isReloadingUI boolean
function PCBG:OnPlayerEnteringWorld(initialLogin, isReloadingUI)
    local crafterUID = CraftSim.UTIL:GetPlayerCrafterUID()
    self:LoadRuntimeStaleFromDB(crafterUID)
    if initialLogin and not isReloadingUI then
        for _, gate in ipairs(gates) do
            if gate.setStaleOnRealLogin and gate.realLoginStaleProfession then
                if CraftSim.UTIL:IsProfessionLearned(gate.realLoginStaleProfession) then
                    CraftSim.DB.CRAFTER:SetPreCraftBuffStaleAfterLogin(crafterUID, gate.id, true)
                    self._runtimeStale[gate.id] = true
                end
            end
        end
    end
end

---@param gateId CraftSim.PreCraftBuffGateId
---@return boolean
function PCBG:IsStaleEffective(gateId)
    local gate = self:GetGate(gateId)
    if not gate or not gate.trackLoginStale then
        return false
    end
    if gate.staleRequiresProfessionLearned and
        not CraftSim.UTIL:IsProfessionLearned(gate.staleRequiresProfessionLearned) then
        return false
    end
    return self._runtimeStale[gateId] == true
end

--- Midnight shatter stats helper (BuffData).
---@return boolean
function PCBG:IsMidnightShatterStaleAfterLoginEffective()
    return self:IsStaleEffective(CraftSim.CONST.PRE_CRAFT_BUFF_GATE_ID.MIDNIGHT_ENCHANT_SHATTER)
end

---@param gateId CraftSim.PreCraftBuffGateId
function PCBG:ClearStalePersisted(gateId)
    self._runtimeStale[gateId] = false
    CraftSim.DB.CRAFTER:SetPreCraftBuffStaleAfterLogin(CraftSim.UTIL:GetPlayerCrafterUID(), gateId, false)
end

function PCBG:ClearMidnightShatterStaleAfterLoginPersisted()
    self:ClearStalePersisted(CraftSim.CONST.PRE_CRAFT_BUFF_GATE_ID.MIDNIGHT_ENCHANT_SHATTER)
end

---@param recipeID RecipeID
function PCBG:ClearStaleIfCraftedRecipeMatches(recipeID)
    for _, gate in ipairs(gates) do
        if gate.castRecipeID == recipeID then
            self:ClearStalePersisted(gate.id)
        end
    end
end

--- Clears stale for any gate that lists this spell in castSucceededSpellIDs.
---@param spellID number
function PCBG:OnCastSucceededPlayer(spellID)
    for _, gate in ipairs(gates) do
        if gate.castSucceededSpellIDs then
            for _, sid in ipairs(gate.castSucceededSpellIDs) do
                if sid == spellID then
                    self:ClearStalePersisted(gate.id)
                    break
                end
            end
        end
    end
    self:ScheduleQueueDisplayRefreshForDelayedCraftingState()
end

function PCBG:ScheduleQueueDisplayRefreshForDelayedCraftingState()
    if not CraftSim.CRAFTQ.frame or not CraftSim.CRAFTQ.frame:IsVisible() then
        return
    end
    self.awaitingBuffApply = true
    self._refreshGen = (self._refreshGen or 0) + 1
    local gen = self._refreshGen
    local startTime = GetTimePreciseSec()
    CraftSim.CRAFTQ.UI:UpdateDisplay()

    GUTIL:WaitFor(function()
        if self._refreshGen ~= gen then
            return true
        end

        local elapsed = GetTimePreciseSec() - startTime
        if elapsed >= 1.5 then
            return true
        end

        for _, gate in ipairs(gates) do
            if gate.buffID and CraftSim.DB.OPTIONS:Get(gate.optionForceBuffKey) then
                if C_UnitAuras.GetPlayerAuraBySpellID(gate.buffID) then
                    return true
                end
            end
        end

        return false
    end, function()
        if self._refreshGen == gen then
            self.awaitingBuffApply = false
            CraftSim.CRAFTQ.UI:UpdateDisplay()
        end
    end, 0.05, 2)
end

---@return boolean
function PCBG:AnyForceBuffOptionEnabled()
    for _, gate in ipairs(gates) do
        if CraftSim.DB.OPTIONS:Get(gate.optionForceBuffKey) then
            return true
        end
    end
    return false
end

---@param craftQueue CraftSim.CRAFTQ
---@return boolean
function PCBG:ShouldRefreshCraftQueueOnAura(craftQueue)
    local qf = craftQueue.frame
    if not qf or not qf:IsVisible() then
        return false
    end
    if not self:AnyForceBuffOptionEnabled() then
        return false
    end
    local hasItems = craftQueue.craftQueue and #craftQueue.craftQueue.craftQueueItems > 0
    if hasItems or self.awaitingBuffApply then
        return true
    end
    local skillLineID = C_TradeSkillUI.GetProfessionChildSkillLineID()
    for _, gate in ipairs(gates) do
        if CraftSim.DB.OPTIONS:Get(gate.optionForceBuffKey) and gate.skillLineID and gate.skillLineID == skillLineID then
            return true
        end
    end
    return false
end

---@param unitTarget string
function PCBG:UNIT_AURA(unitTarget)
    if unitTarget ~= "player" then
        return
    end
    if not self:ShouldRefreshCraftQueueOnAura(CraftSim.CRAFTQ) then
        return
    end
    self._auraDebounceGen = (self._auraDebounceGen or 0) + 1
    local gen = self._auraDebounceGen
    C_Timer.After(0.1, function()
        if gen == self._auraDebounceGen then
            CraftSim.CRAFTQ.UI:UpdateDisplay()
        end
    end)
end

---@param unitTarget string
---@param castGUID WOWGUID
---@param spellID number
function PCBG:UNIT_SPELLCAST_SUCCEEDED(unitTarget, castGUID, spellID)
    if unitTarget ~= "player" then
        return
    end
    self:OnCastSucceededPlayer(spellID)
end

---@param recipeData CraftSim.RecipeData
---@param optKey CraftSim.GENERAL_OPTIONS
---@return ItemMixin?
function PCBG:ApplySalvageSelectionFromOption(recipeData, optKey)
    local slot = recipeData.reagentData.salvageReagentSlot
    local savedID = CraftSim.DB.OPTIONS:Get(optKey)
    if savedID == nil then
        return slot:SetCheapestItem()
    end
    if savedID == self.SHATTER_MOTE_SELECTION_CHEAPEST_OWNED then
        return slot:SetCheapestOwnedItem()
    end
    local found = GUTIL:Find(slot.possibleItems, function(item)
        return item:GetItemID() == savedID
    end)
    if found then
        slot:SetItem(savedID)
        return slot.activeItem
    end
    CraftSim.DB.OPTIONS:Save(optKey, nil)
    return slot:SetCheapestItem()
end

---@param crafterData CraftSim.CrafterData
---@param recipeID RecipeID
---@param moteOptionKey CraftSim.GENERAL_OPTIONS
---@return CraftSim.RecipeData?
function PCBG:PrepareSalvageCastRecipeData(crafterData, recipeID, moteOptionKey)
    local rd = CraftSim.RecipeData({
        recipeID = recipeID,
        crafterData = crafterData,
    })
    if not rd or not rd.learned then
        return nil
    end
    self:ApplySalvageSelectionFromOption(rd, moteOptionKey)
    rd:Update()
    return rd
end

---@param crafterData CraftSim.CrafterData
---@return CraftSim.RecipeData?
function PCBG:PrepareMidnightEnchantShatterRecipeData(crafterData)
    return self:PrepareSalvageCastRecipeData(crafterData, CraftSim.CONST.QUICK_ACCESS_RECIPE_IDS.MIDNIGHT_ENCHANTING_SHATTER,
        CraftSim.CONST.GENERAL_OPTIONS.CRAFTQUEUE_MIDNIGHT_SHATTER_MOTE_ITEMID)
end

---@param crafterData CraftSim.CrafterData
---@return CraftSim.RecipeData?
function PCBG:PrepareTwwEnchantShatterRecipeData(crafterData)
    return self:PrepareSalvageCastRecipeData(crafterData, CraftSim.CONST.QUICK_ACCESS_RECIPE_IDS.TWW_ENCHANTING_SHATTER,
        CraftSim.CONST.GENERAL_OPTIONS.CRAFTQUEUE_TWW_ENCHANT_SHATTER_MOTE_ITEMID)
end

---@param recipeData CraftSim.RecipeData
---@param optKey CraftSim.GENERAL_OPTIONS
function PCBG:ShowSalvageMoteMenu(recipeData, optKey)
    MenuUtil.CreateContextMenu(UIParent, function(_, rootDescription)
        rootDescription:CreateRadio(L("CRAFT_QUEUE_SHATTER_MOTE_AUTOMATIC"), function()
            return CraftSim.DB.OPTIONS:Get(optKey) == nil
        end, function()
            CraftSim.DB.OPTIONS:Save(optKey, nil)
            CraftSim.CRAFTQ.UI:UpdateDisplay()
        end)
        rootDescription:CreateRadio(L("CRAFT_QUEUE_SHATTER_MOTE_AUTOMATIC_OWNED"), function()
            return CraftSim.DB.OPTIONS:Get(optKey) == PCBG.SHATTER_MOTE_SELECTION_CHEAPEST_OWNED
        end, function()
            CraftSim.DB.OPTIONS:Save(optKey, PCBG.SHATTER_MOTE_SELECTION_CHEAPEST_OWNED)
            CraftSim.CRAFTQ.UI:UpdateDisplay()
        end)
        for _, item in ipairs(recipeData.reagentData.salvageReagentSlot.possibleItems) do
            local itemID = item:GetItemID()
            local itemName, itemLink = C_Item.GetItemInfo(itemID)
            local displayText = itemLink or itemName or ("#" .. tostring(itemID))
            local moteRadio = rootDescription:CreateRadio(displayText, function()
                return CraftSim.DB.OPTIONS:Get(optKey) == itemID
            end, function()
                CraftSim.DB.OPTIONS:Save(optKey, itemID)
                CraftSim.CRAFTQ.UI:UpdateDisplay()
            end)
            moteRadio:SetTooltip(function(tooltip, _)
                if tooltip.SetItemByID then
                    tooltip:SetItemByID(itemID)
                else
                    local _, il = C_Item.GetItemInfo(itemID)
                    if il and tooltip.SetHyperlink then
                        tooltip:SetHyperlink(il)
                    end
                end
            end)
        end
    end)
end

---@param recipeData CraftSim.RecipeData
function PCBG:ShowMidnightEnchantShatterMoteMenu(recipeData)
    self:ShowSalvageMoteMenu(recipeData, CraftSim.CONST.GENERAL_OPTIONS.CRAFTQUEUE_MIDNIGHT_SHATTER_MOTE_ITEMID)
end

---@param recipeData CraftSim.RecipeData
function PCBG:ShowTwwEnchantShatterMoteMenu(recipeData)
    self:ShowSalvageMoteMenu(recipeData, CraftSim.CONST.GENERAL_OPTIONS.CRAFTQUEUE_TWW_ENCHANT_SHATTER_MOTE_ITEMID)
end

---@param recipeData CraftSim.RecipeData
---@param buffID CraftSim.BuffID
---@return boolean
function PCBG:ShouldAssumeBuffActiveForProfessionStats(recipeData, buffID)
    for _, gate in ipairs(gates) do
        if gate.buffID == buffID then
            if recipeData.professionData.professionInfo.profession ~= gate.profession then
                return false
            end
            if recipeData.expansionID ~= gate.expansionID then
                return false
            end
            if not CraftSim.DB.OPTIONS:Get(gate.optionForceBuffKey) then
                return false
            end
            if gate.trackLoginStale and self:IsStaleEffective(gate.id) then
                return false
            end
            return true
        end
    end
    return false
end

--- Module-local helper for gate cast recipe setup (not exposed on CraftSim.PRE_CRAFT_BUFF_GATE).
---@param crafterData CraftSim.CrafterData
---@param gate CraftSim.PreCraftBuffGateDefinition
---@return CraftSim.RecipeData?
local function prepareRecipeForGate(crafterData, gate)
    if gate.id == CraftSim.CONST.PRE_CRAFT_BUFF_GATE_ID.MIDNIGHT_ENCHANT_SHATTER then
        return PCBG:PrepareMidnightEnchantShatterRecipeData(crafterData)
    end
    if gate.id == CraftSim.CONST.PRE_CRAFT_BUFF_GATE_ID.TWW_ENCHANT_SHATTER then
        return PCBG:PrepareTwwEnchantShatterRecipeData(crafterData)
    end
    if gate.castRecipeID and gate.salvagedMoteOptionKey then
        return PCBG:PrepareSalvageCastRecipeData(crafterData, gate.castRecipeID, gate.salvagedMoteOptionKey)
    end
    if gate.castRecipeID then
        local rd = CraftSim.RecipeData({ recipeID = gate.castRecipeID, crafterData = crafterData })
        if rd and rd.learned then
            rd:Update()
            return rd
        end
    end
    return nil
end

---@param crafterData CraftSim.CrafterData
---@param gateId CraftSim.PreCraftBuffGateId
---@return CraftSim.RecipeData?
function PCBG:PrepareCastRecipeDataForGate(crafterData, gateId)
    local gate = self:GetGate(gateId)
    if not gate then
        return nil
    end
    return prepareRecipeForGate(crafterData, gate)
end

---@param craftQueueItem CraftSim.CraftQueueItem
function PCBG:ApplyGatesToCraftQueueItem(craftQueueItem)
    craftQueueItem.pcbgData = {
        gateId = nil,
        needsStep = false,
        canCast = false,
        dueToLoginStale = false,
        dueToMissingBuff = false,
        recipeData = nil,
    }

    local rd = craftQueueItem.recipeData
    if not craftQueueItem.isCrafter or not craftQueueItem.correctProfessionOpen then
        return
    end

    for _, gate in ipairs(gates) do
        if gate.implementsCraftQueuePrerequisite and CraftSim.DB.OPTIONS:Get(gate.optionForceBuffKey) and gate.castRecipeID then
            if rd.professionData.professionInfo.profession == gate.profession and rd.expansionID == gate.expansionID then
                rd.buffData:Update()
                local buffActive = rd.buffData:IsBuffActive(gate.buffID)
                local staleEffective = gate.trackLoginStale and self:IsStaleEffective(gate.id)
                local needStep = (not buffActive) or staleEffective
                if needStep then
                    local prep = prepareRecipeForGate(rd.crafterData, gate)
                    if prep then
                        craftQueueItem.pcbgData = {
                            gateId = gate.id,
                            needsStep = true,
                            canCast = select(1, prep:CanCraft(1)),
                            dueToLoginStale = staleEffective and buffActive,
                            dueToMissingBuff = not buffActive,
                            recipeData = prep,
                        }
                        return
                    end
                end
            end
        end
    end
end

---@param skillLineID number
---@return CraftSim.PreCraftBuffGateDefinition?
function PCBG:GetQuickBarGateForSkillLine(skillLineID)
    for _, gate in ipairs(gates) do
        local quickBarAllowed = gate.salvagedMoteOptionKey or CraftSim.DB.OPTIONS:Get(gate.optionForceBuffKey)
        if (gate.implementsCraftQueuePrerequisite or gate.quickBarEnabled) and gate.skillLineID == skillLineID and
            quickBarAllowed then
            return gate
        end
    end
    return nil
end

--- Register built-in gates (midnight, TWW enchanting shatter, Everburning placeholder for stats).
local function registerBuiltinGates()
    PCBG:RegisterGate {
        id = CraftSim.CONST.PRE_CRAFT_BUFF_GATE_ID.MIDNIGHT_ENCHANT_SHATTER,
        profession = Enum.Profession.Enchanting,
        expansionID = CraftSim.CONST.EXPANSION_IDS.MIDNIGHT,
        buffID = CraftSim.CONST.BUFF_IDS.SHATTERING_ESSENCE_MIDNIGHT,
        optionForceBuffKey = CraftSim.CONST.GENERAL_OPTIONS.CRAFTQUEUE_MIDNIGHT_SHATTER_FORCE_BUFF,
        skillLineID = CraftSim.CONST.TRADESKILLLINEIDS[Enum.Profession.Enchanting][CraftSim.CONST.EXPANSION_IDS.MIDNIGHT],
        castRecipeID = CraftSim.CONST.QUICK_ACCESS_RECIPE_IDS.MIDNIGHT_ENCHANTING_SHATTER,
        castSucceededSpellIDs = { CraftSim.CONST.QUICK_ACCESS_RECIPE_IDS.MIDNIGHT_ENCHANTING_SHATTER },
        staleRequiresProfessionLearned = Enum.Profession.Enchanting,
        setStaleOnRealLogin = true,
        realLoginStaleProfession = Enum.Profession.Enchanting,
        salvagedMoteOptionKey = CraftSim.CONST.GENERAL_OPTIONS.CRAFTQUEUE_MIDNIGHT_SHATTER_MOTE_ITEMID,
    }

    PCBG:RegisterGate {
        id = CraftSim.CONST.PRE_CRAFT_BUFF_GATE_ID.TWW_ENCHANT_SHATTER,
        profession = Enum.Profession.Enchanting,
        expansionID = CraftSim.CONST.EXPANSION_IDS.THE_WAR_WITHIN,
        buffID = CraftSim.CONST.BUFF_IDS.SHATTERING_ESSENCE,
        optionForceBuffKey = CraftSim.CONST.GENERAL_OPTIONS.CRAFTQUEUE_TWW_ENCHANT_SHATTER_FORCE_BUFF,
        skillLineID = CraftSim.CONST.TRADESKILLLINEIDS[Enum.Profession.Enchanting]
            [CraftSim.CONST.EXPANSION_IDS.THE_WAR_WITHIN],
        castRecipeID = CraftSim.CONST.QUICK_ACCESS_RECIPE_IDS.TWW_ENCHANTING_SHATTER,
        castSucceededSpellIDs = { CraftSim.CONST.QUICK_ACCESS_RECIPE_IDS.TWW_ENCHANTING_SHATTER },
        staleRequiresProfessionLearned = Enum.Profession.Enchanting,
        setStaleOnRealLogin = true,
        realLoginStaleProfession = Enum.Profession.Enchanting,
        salvagedMoteOptionKey = CraftSim.CONST.GENERAL_OPTIONS.CRAFTQUEUE_TWW_ENCHANT_SHATTER_MOTE_ITEMID,
    }

    --[[ Disabled for now (can be re-enabled later as a full gate):
    PCBG:RegisterGate {
        id = CraftSim.CONST.PRE_CRAFT_BUFF_GATE_ID.TWW_BLACKSMITH_EVERBURNING,
        profession = Enum.Profession.Blacksmithing,
        expansionID = CraftSim.CONST.EXPANSION_IDS.THE_WAR_WITHIN,
        buffID = CraftSim.CONST.BUFF_IDS.EVERBURNING_IGNITION,
        optionForceBuffKey = CraftSim.CONST.GENERAL_OPTIONS.CRAFTQUEUE_EVERBURNING_IGNITION_FORCE_BUFF,
        skillLineID = CraftSim.CONST.TRADESKILLLINEIDS[Enum.Profession.Blacksmithing]
            [CraftSim.CONST.EXPANSION_IDS.THE_WAR_WITHIN],
        castRecipeID = CraftSim.CONST.QUICK_ACCESS_RECIPE_IDS.TWW_EVERBURNING_IGNITION,
        quickBarEnabled = false,
        quickBarUseItemID = 224765, -- Everburning Ignition item
        trackLoginStale = false,
        implementsCraftQueuePrerequisite = false,
    }
    ]]
end

registerBuiltinGates()
