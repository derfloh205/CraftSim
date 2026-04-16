---@class CraftSim
local CraftSim = select(2, ...)

local GGUI = CraftSim.GGUI
local GUTIL = CraftSim.GUTIL

---@class CraftSim.CRAFTQ
CraftSim.CRAFTQ = CraftSim.CRAFTQ

---@class CraftSim.CRAFTQ.UI
CraftSim.CRAFTQ.UI = {}

local L = CraftSim.UTIL:GetLocalizer()
local f = GUTIL:GetFormatter()

---@param loginStale boolean
---@param missingBuff boolean
---@return string
local function CraftQueueMidnightShatterReasonTooltipFromFlags(loginStale, missingBuff)
    if loginStale and missingBuff then
        return L("CRAFT_QUEUE_SHATTER_TOOLTIP_STALE_AND_MISSING")
    elseif loginStale then
        return L("CRAFT_QUEUE_SHATTER_TOOLTIP_AFTER_LOGIN")
    elseif missingBuff then
        return L("CRAFT_QUEUE_SHATTER_TOOLTIP_MISSING_BUFF")
    end
    return L("CRAFT_QUEUE_SHATTER_TOOLTIP_AFTER_LOGIN")
end

---@param craftQueueItem CraftSim.CraftQueueItem
---@return string
local function CraftQueueMidnightShatterReasonTooltipExtra(craftQueueItem)
    return CraftQueueMidnightShatterReasonTooltipFromFlags(craftQueueItem.pcbgData.dueToLoginStale,
        craftQueueItem.pcbgData.dueToMissingBuff)
end

---@param loginStale boolean
---@param missingBuff boolean
---@return string
local function MidnightShatterStatusTextFromFlags(loginStale, missingBuff)
    if loginStale and missingBuff then
        return L("CRAFT_QUEUE_STATUS_SHATTER_BUFF") .. "\n\n" .. L("CRAFT_QUEUE_STATUS_SHATTER_AFTER_LOGIN")
    elseif loginStale then
        return L("CRAFT_QUEUE_STATUS_SHATTER_AFTER_LOGIN")
    elseif missingBuff then
        return L("CRAFT_QUEUE_STATUS_SHATTER_BUFF")
    end
    return L("CRAFT_QUEUE_STATUS_SHATTER_BUFF")
end

---@param craftQueueItem CraftSim.CraftQueueItem
---@return string
local function CraftQueueMidnightShatterStatusText(craftQueueItem)
    return MidnightShatterStatusTextFromFlags(craftQueueItem.pcbgData.dueToLoginStale,
        craftQueueItem.pcbgData.dueToMissingBuff)
end

---@param gateId CraftSim.PreCraftBuffGateId
---@param crafterData CraftSim.CrafterData
---@param fallbackRecipeData CraftSim.RecipeData?
local function TriggerPreCraftGateAction(gateId, crafterData, fallbackRecipeData)
    if CraftSim.CRAFTQ:IsCraftClickLocked() then
        return
    end
    local fresh = CraftSim.PRE_CRAFT_BUFF_GATE:PrepareCastRecipeDataForGate(crafterData, gateId)
    if fresh and fresh:CanCraft(1) then
        CraftSim.CRAFTQ:BeginCraftClickLock()
        CraftSim.CRAFTQ.CraftSimCalledCraftRecipe = true
        fresh:Craft(1)
        CraftSim.CRAFTQ.CraftSimCalledCraftRecipe = false
        CraftSim.CRAFTQ:ScheduleCraftQueueDisplayRefreshForDelayedCraftingState()
        return
    end
    local rd = fresh or fallbackRecipeData
    if not rd then
        return
    end
    local salvageSlot = rd.reagentData and rd.reagentData.salvageReagentSlot
    local activeReagentSlot = salvageSlot and salvageSlot.activeItem
    if activeReagentSlot then
        CraftSim.DEBUG:SystemPrint(f.l("CraftSim: " .. "Missing Shatter Reagent: " .. activeReagentSlot:GetItemLink()))
    else
        CraftSim.CRAFTQ.craftQueue:AddRecipe({ recipeData = rd, amount = 1 })
        CraftSim.CRAFTQ.UI:UpdateDisplay()
    end
end

---@param recipeData CraftSim.RecipeData
---@param gateId CraftSim.PreCraftBuffGateId
local function ShowPreCraftBuffSalvageMoteMenu(recipeData, gateId)
    local PCBG = CraftSim.PRE_CRAFT_BUFF_GATE
    if gateId == CraftSim.CONST.PRE_CRAFT_BUFF_GATE_ID.MIDNIGHT_ENCHANT_SHATTER then
        PCBG:ShowMidnightEnchantShatterMoteMenu(recipeData)
    elseif gateId == CraftSim.CONST.PRE_CRAFT_BUFF_GATE_ID.TWW_ENCHANT_SHATTER then
        PCBG:ShowTwwEnchantShatterMoteMenu(recipeData)
    end
end

--- Single result icon and NPC reward inline icons use the same size
local CRAFT_QUEUE_RESULT_ICON_SIZE = 18
local CRAFT_QUEUE_RESULT_ICON_SPACING = 2
local CRAFT_QUEUE_RESULT_ICON_SLOTS = 4
--- Result column: four icons + three gaps + small side padding (no extra dead space)
local CRAFT_QUEUE_RESULT_COLUMN_WIDTH =
    CRAFT_QUEUE_RESULT_ICON_SIZE * 4 + CRAFT_QUEUE_RESULT_ICON_SPACING * 3 + 16

---@class CraftSim.CraftQueue.ResultColumnEntry
---@field kind "item"|"currency"|"firstcraft"
---@field item? ItemMixin
---@field currencyID? number

---@param recipeData CraftSim.RecipeData
---@param rewardRows { item?: ItemMixin, currency?: number }[]?
---@return CraftSim.CraftQueue.ResultColumnEntry[]
local function BuildCraftQueueResultEntries(recipeData, rewardRows)
    rewardRows = rewardRows or {}
    ---@type CraftSim.CraftQueue.ResultColumnEntry[]
    local entries = {}
    for _, reward in ipairs(rewardRows) do
        if reward.currency then
            tinsert(entries, { kind = "currency", currencyID = reward.currency })
        elseif reward.item then
            tinsert(entries, { kind = "item", item = reward.item })
        end
    end
    local isNpcPatronOrder = recipeData.orderData and recipeData.orderData.orderType == Enum.CraftingOrderType.Npc
    if not isNpcPatronOrder then
        tinsert(entries, 1, { kind = "item", item = recipeData.resultData.expectedItem })
    elseif #entries == 0 then
        tinsert(entries, { kind = "item", item = recipeData.resultData.expectedItem })
    end
    if recipeData.recipeInfo and recipeData.recipeInfo.firstCraft then
        tinsert(entries, { kind = "firstcraft" })
    end
    return entries
end

--- First-craft moxie (+PATRON_ORDER_FIRST_CRAFT_EXTRA_MOXIE): shown on work-order UI rows; profit includes it on NPC orders only when CRAFTQUEUE_QUEUE_PATRON_ORDERS_INCLUDE_MOXIE_IN_PROFIT is on.
---@param rewardItems { count?: number, item?: ItemMixin, currency?: number, rawItemLink?: string }[]
---@param recipeData CraftSim.RecipeData
local function ApplyFirstCraftMoxieToRewardRows(rewardItems, recipeData)
    if not recipeData.orderData then
        return
    end
    if not (recipeData.recipeInfo and recipeData.recipeInfo.firstCraft) then
        return
    end
    local moxieID = CraftSim.UTIL:GetRecipeProfessionMoxieCurrencyID(recipeData)
    if not moxieID then
        return
    end
    local add = CraftSim.CONST.PATRON_ORDER_FIRST_CRAFT_EXTRA_MOXIE
    for _, row in ipairs(rewardItems) do
        if row.currency == moxieID then
            row.count = (tonumber(row.count) or 0) + add
            return
        end
    end
    tinsert(rewardItems, { count = add, currency = moxieID, item = nil })
end

--- Patron NPC listed rewards (if any) plus first-craft moxie for work orders when applicable.
---@param recipeData CraftSim.RecipeData
---@param includeRawItemLink boolean
---@return { count?: number, item?: ItemMixin, currency?: number, rawItemLink?: string }[]
local function BuildCraftQueueRewardItemRows(recipeData, includeRawItemLink)
    local npcList = {}
    if recipeData.orderData and recipeData.orderData.orderType == Enum.CraftingOrderType.Npc then
        npcList = recipeData.orderData.npcOrderRewards or {}
    end
    local rewardItems = GUTIL:Map(npcList, function(reward)
        ---@type { count?: number, item?: ItemMixin, currency?: number, rawItemLink?: string }
        local row = {
            count = reward.count,
            item = reward.itemLink and Item:CreateFromItemLink(reward.itemLink) or nil,
            currency = reward.currencyType,
        }
        if includeRawItemLink then
            row.rawItemLink = reward.itemLink
        end
        return row
    end)
    ApplyFirstCraftMoxieToRewardRows(rewardItems, recipeData)
    return rewardItems
end

--- Result column shows at most CRAFT_QUEUE_RESULT_ICON_SLOTS icons; first-craft moxie can be clipped when listed last.
---@param recipeData CraftSim.RecipeData
---@param entries CraftSim.CraftQueue.ResultColumnEntry[]
local function PrioritizeFirstCraftMoxieInResultEntries(recipeData, entries)
    if not (recipeData.recipeInfo and recipeData.recipeInfo.firstCraft) then
        return
    end
    local moxieID = CraftSim.UTIL:GetRecipeProfessionMoxieCurrencyID(recipeData)
    if not moxieID then
        return
    end
    for i = 1, #entries do
        local e = entries[i]
        if e.kind == "currency" and e.currencyID == moxieID then
            if i > 1 then
                tremove(entries, i)
                tinsert(entries, 1, e)
            end
            return
        end
    end
end

--- Rich "Rewards" tooltip block (NPC patron rows, or any work order with first-craft moxie).
---@param recipeData CraftSim.RecipeData
---@return boolean
local function CraftQueueOrderRewardsTooltipSectionWanted(recipeData)
    if not recipeData.orderData then
        return false
    end
    if recipeData.orderData.orderType == Enum.CraftingOrderType.Npc then
        if recipeData.orderData.npcOrderRewards then
            return true
        end
        return recipeData.recipeInfo and recipeData.recipeInfo.firstCraft and
            CraftSim.UTIL:GetRecipeProfessionMoxieCurrencyID(recipeData) ~= nil
    end
    return recipeData.recipeInfo and recipeData.recipeInfo.firstCraft and
        CraftSim.UTIL:GetRecipeProfessionMoxieCurrencyID(recipeData) ~= nil
end

---@param gIcon GGUI.Icon
local function ClearResultIconSlot(gIcon)
    gIcon:SetCurrency(nil)
    gIcon:SetItem(nil)
    gIcon.frame:SetScript("OnEnter", nil)
    gIcon.frame:SetScript("OnLeave", nil)
end

---@param gIcon GGUI.Icon
---@param recipeData CraftSim.RecipeData
local function SetResultSlotFirstCraft(gIcon, recipeData)
    ClearResultIconSlot(gIcon)
    gIcon.frame:SetNormalAtlas(CraftSim.CONST.FIRST_CRAFT_KP_ICON)
    gIcon.qualityIcon:Hide()
    gIcon.frame:SetScript("OnEnter", function()
        GameTooltip:SetOwner(gIcon.frame, "ANCHOR_RIGHT")
        GameTooltip:AddLine(L("CRAFT_QUEUE_RESULT_FIRST_CRAFT_TOOLTIP_TITLE"), 1, 0.82, 0)
        GameTooltip:AddLine(L("CRAFT_QUEUE_RESULT_FIRST_CRAFT_TOOLTIP"), 1, 1, 1, true)
        local moxieID = CraftSim.UTIL:GetRecipeProfessionMoxieCurrencyID(recipeData)
        if moxieID then
            local copper = CraftSim.UTIL:GetPatronOrderMoxieCopperPerUnit(moxieID) *
                CraftSim.CONST.PATRON_ORDER_FIRST_CRAFT_EXTRA_MOXIE
            if copper > 0 then
                GameTooltip:AddLine(string.format(L("CRAFT_QUEUE_FIRST_CRAFT_MOXIE_GOLD_TOOLTIP"),
                    CraftSim.UTIL:FormatMoney(copper, true, nil, true)), 0.85, 0.85, 0.85, true)
            end
        end
        GameTooltip:Show()
    end)
    gIcon.frame:SetScript("OnLeave", GameTooltip_Hide)
end

---@param resultColumn CraftSim.CraftQueue.CraftList.ResultColumn
---@param entries CraftSim.CraftQueue.ResultColumnEntry[]
---@param recipeData CraftSim.RecipeData
local function ApplyResultColumnEntries(resultColumn, entries, recipeData)
    for i = 1, CRAFT_QUEUE_RESULT_ICON_SLOTS do
        ClearResultIconSlot(resultColumn.resultIcons[i])
        resultColumn.resultIcons[i].frame:Hide()
    end
    local n = math.min(#entries, CRAFT_QUEUE_RESULT_ICON_SLOTS)
    local row = resultColumn.iconRow
    local sz = CRAFT_QUEUE_RESULT_ICON_SIZE
    local sp = CRAFT_QUEUE_RESULT_ICON_SPACING
    if n == 0 then
        row:SetSize(1, sz)
    else
        row:SetSize(n * sz + (n - 1) * sp, sz)
    end
    for i = 1, n do
        local g = resultColumn.resultIcons[i]
        local e = entries[i]
        g.frame:Show()
        if e.kind == "item" then
            g:SetItem(e.item --[[@as ItemMixin]])
        elseif e.kind == "currency" then
            g:SetCurrency(e.currencyID)
        elseif e.kind == "firstcraft" then
            SetResultSlotFirstCraft(g, recipeData)
        end
    end
end

--- Only wrong profession gear slots; empty string if all match or equippedSet is nil.
---@param professionGearSet CraftSim.ProfessionGearSet
---@param equippedSet CraftSim.ProfessionGearSet?
---@return string suffix (includes leading newlines and header when non-empty)
local function GetCraftQueueWrongProfessionToolsTooltipBlock(professionGearSet, equippedSet)
    if not equippedSet then
        return ""
    end
    local toolIconSize = 18
    local markSize = 13
    local cross = CreateAtlasMarkup(CraftSim.CONST.ATLAS_TEXTURES.CROSS, markSize, markSize) .. " "
    local emptySlotIcon = GUTIL:IconToText(CraftSim.CONST.EMPTY_SLOT_TEXTURE, toolIconSize, toolIconSize)
    ---@type string[]
    local lines = {}

    ---@param slot "gear1"|"gear2"|"tool"
    local function appendLineIfWrong(slot)
        if professionGearSet:ExpectedSlotMatchesEquipped(slot, equippedSet) then
            return
        end
        local gear = slot == "gear1" and professionGearSet.gear1 or slot == "gear2" and professionGearSet.gear2 or
            professionGearSet.tool
        if not gear then
            return
        end
        local item = gear.item
        if item then
            local statText = ""
            if slot == "tool" then
                if gear.professionStats.craftingspeed.value > 0 then
                    statText = string.format(" (%s)", L("STAT_CRAFTINGSPEED"))
                elseif gear.professionStats.multicraft.value > 0 then
                    statText = string.format(" (%s)", L("STAT_MULTICRAFT"))
                elseif gear.professionStats.resourcefulness.value > 0 then
                    statText = string.format(" (%s)", L("STAT_RESOURCEFULNESS"))
                elseif gear.professionStats.ingenuity.value > 0 then
                    statText = string.format(" (%s)", L("STAT_INGENUITY"))
                end
            end
            tinsert(lines,
                cross .. GUTIL:IconToText(item:GetItemIcon(), toolIconSize, toolIconSize) .. " " .. item:GetItemLink() ..
                f.bb(statText))
        else
            tinsert(lines, cross .. emptySlotIcon .. f.grey(" [Empty Slot]"))
        end
    end

    if professionGearSet.gear1 then
        appendLineIfWrong("gear1")
    end
    if professionGearSet.gear2 then
        appendLineIfWrong("gear2")
    end
    if professionGearSet.tool then
        appendLineIfWrong("tool")
    end

    if #lines == 0 then
        return ""
    end
    return "\n\n" .. f.bb(L("CRAFT_QUEUE_CRAFT_PROFESSION_GEAR_HEADER")) .. "\n" .. table.concat(lines, "\n")
end

---@param allowedToCraft boolean
---@param errorTooltip string
---@param professionGearSet CraftSim.ProfessionGearSet
---@return string
local function GetCraftQueueCraftButtonRowStatusTooltipText(allowedToCraft, errorTooltip, professionGearSet)
    local equippedSet = CraftSim.ProfessionGearSet(professionGearSet.recipeData)
    equippedSet:LoadCurrentEquippedSet()
    local toolsBlock = GetCraftQueueWrongProfessionToolsTooltipBlock(professionGearSet, equippedSet)

    if allowedToCraft then
        return f.g("Ready to Craft") .. toolsBlock
    end
    local err = (errorTooltip and errorTooltip ~= "") and errorTooltip or
        f.r(L("CRAFT_QUEUE_STATUS_CANNOT_CRAFT_FALLBACK"))
    return err .. toolsBlock
end

---@param craftButton GGUI.Button
---@param allowedToCraft boolean
---@param errorTooltip string
---@param professionGearSet CraftSim.ProfessionGearSet
local function SetCraftQueueCraftButtonRowStatusTooltip(craftButton, allowedToCraft, errorTooltip, professionGearSet)
    if not craftButton.tooltipOptions then
        craftButton.tooltipOptions = {}
    end
    craftButton.tooltipOptions.anchor = craftButton.tooltipOptions.anchor or "ANCHOR_CURSOR_RIGHT"
    craftButton.tooltipOptions.textWrap = true
    craftButton.tooltipOptions.text = GetCraftQueueCraftButtonRowStatusTooltipText(allowedToCraft, errorTooltip,
        professionGearSet)
end

---@param shatterRD CraftSim.RecipeData
---@param canCastShatter boolean
---@param shatterReasonExtra string
---@param shatterHint string
---@param activeReagent ItemMixin
---@return string
local function FormatMidnightShatterTooltipAppend(shatterRD, canCastShatter, shatterReasonExtra, shatterHint,
                                                  activeReagent)
    local ownedCount = C_Item.GetItemCount(activeReagent:GetItemID(), true, false, true, true)
    local ownedCountText = " (" .. tostring(ownedCount) .. ")"
    local moteWithIcon = GUTIL:IconToText(activeReagent:GetItemIcon(), 15, 15) .. " " ..
        activeReagent:GetItemLink() .. ownedCountText
    if canCastShatter then
        return f.bb(L("CRAFT_QUEUE_BUTTON_SHATTER") .. " " .. moteWithIcon) .. "\nCosts: " ..
            CraftSim.UTIL:FormatMoney(shatterRD.priceData.craftingCosts, true) .. shatterReasonExtra .. shatterHint
    end
    return f.bb(L("CRAFT_QUEUE_BUTTON_SHATTER") .. " " .. moteWithIcon) .. f.r(" (Missing)") .. "\nCosts: " ..
        CraftSim.UTIL:FormatMoney(shatterRD.priceData.craftingCosts, true) .. shatterReasonExtra .. shatterHint
end

---@param craftButtonColumn CraftSim.CraftQueue.CraftList.CraftButtonColumn
---@param craftQueueItem CraftSim.CraftQueueItem
---@param recipeData CraftSim.RecipeData
---@param statusColumnTooltip string
local function SetCraftQueueRowShatterCraftButton(craftButtonColumn, craftQueueItem, recipeData, statusColumnTooltip)
    local craftBtn = craftButtonColumn.craftButton
    local shatterRD = craftQueueItem.pcbgData.recipeData
    local gateId = craftQueueItem.pcbgData.gateId
    local gate = gateId and CraftSim.PRE_CRAFT_BUFF_GATE:GetGate(gateId) or nil
    if not shatterRD or not gateId then
        return
    end
    craftBtn.frame:SetAlpha(craftQueueItem.pcbgData.canCast and 1 or 0.5)
    craftBtn:SetEnabled(true)
    craftBtn:SetText((gate and gate.salvagedMoteOptionKey) and L("CRAFT_QUEUE_BUTTON_SHATTER") or "")
    craftBtn.clickCallback = function(_, mouseButton)
        if mouseButton == "RightButton" and gate and gate.salvagedMoteOptionKey then
            ShowPreCraftBuffSalvageMoteMenu(shatterRD, gateId)
            return
        end
        if mouseButton ~= "LeftButton" then
            return
        end
        TriggerPreCraftGateAction(gateId, recipeData.crafterData, shatterRD)
    end
    SetCraftQueueCraftButtonRowStatusTooltip(craftBtn, craftQueueItem.allowedToCraft, statusColumnTooltip,
        recipeData.professionGearSet)
    if not (gate and gate.salvagedMoteOptionKey) then
        if craftBtn.tooltipOptions and craftBtn.tooltipOptions.text then
            craftBtn.tooltipOptions.text = craftBtn.tooltipOptions.text .. "\n\n" .. f.bb("Craft Everburning Ignition")
        end
        return
    end
    local shatterHint = L("CRAFT_QUEUE_SHATTER_RIGHT_CLICK_HINT")
    recipeData.buffData:Update()
    local shatterReasonExtra = CraftQueueMidnightShatterReasonTooltipExtra(craftQueueItem)
    local activeReagent = shatterRD.reagentData.salvageReagentSlot.activeItem
    local function appendShatterTooltipExtra(extra)
        if craftBtn.tooltipOptions and craftBtn.tooltipOptions.text and extra and extra ~= "" then
            craftBtn.tooltipOptions.text = craftBtn.tooltipOptions.text .. "\n\n" .. extra
        end
    end
    if activeReagent then
        activeReagent:ContinueOnItemLoad(function()
            local tip = FormatMidnightShatterTooltipAppend(shatterRD, craftQueueItem.pcbgData.canCast,
                shatterReasonExtra, shatterHint, activeReagent)
            appendShatterTooltipExtra(tip)
        end)
    else
        appendShatterTooltipExtra(f.bb(L("CRAFT_QUEUE_BUTTON_SHATTER")) .. shatterReasonExtra .. shatterHint)
    end
end

--- Disabled WoW buttons ignore the mouse, so GGUI's OnEnter tooltip never runs. Overlay matches the button bounds
--- and only receives mouse input while the button is disabled.
---@param gguiButton GGUI.Button
local function AttachCraftQueueButtonDisabledTooltipProxy(gguiButton)
    if gguiButton.craftQueueTooltipProxy then
        return
    end
    local btn = gguiButton.frame
    local proxy = CreateFrame("Frame", nil, btn:GetParent())
    proxy:SetPoint("TOPLEFT", btn, "TOPLEFT")
    proxy:SetPoint("BOTTOMRIGHT", btn, "BOTTOMRIGHT")
    proxy:SetFrameLevel(btn:GetFrameLevel() + 10)
    proxy:EnableMouse(false)
    proxy:Hide()
    proxy:SetScript("OnEnter", function()
        local o = gguiButton.tooltipOptions
        if not o or not o.text or o.text == "" then
            return
        end
        GameTooltip:SetOwner(o.owner or btn, o.anchor or "ANCHOR_CURSOR_RIGHT")
        GameTooltip:SetText(o.text, nil, nil, nil, nil, o.textWrap)
        GameTooltip:SetScale(o.scale or 1)
        GameTooltip:Show()
    end)
    proxy:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)
    gguiButton.craftQueueTooltipProxy = proxy
end

---@param gguiButton GGUI.Button
local function SyncCraftQueueButtonDisabledTooltipProxy(gguiButton)
    if not gguiButton or not gguiButton.craftQueueTooltipProxy then
        return
    end
    local btn = gguiButton.frame
    local proxy = gguiButton.craftQueueTooltipProxy
    proxy:ClearAllPoints()
    proxy:SetPoint("TOPLEFT", btn, "TOPLEFT")
    proxy:SetPoint("BOTTOMRIGHT", btn, "BOTTOMRIGHT")
    proxy:SetFrameLevel(btn:GetFrameLevel() + 10)
    if not btn:IsEnabled() then
        proxy:Show()
        proxy:EnableMouse(true)
    else
        proxy:Hide()
        proxy:EnableMouse(false)
    end
end

local print = CraftSim.DEBUG:RegisterDebugID("Modules.CraftQueue.UI")

local moxieValuesOptionKey = CraftSim.CONST.GENERAL_OPTIONS.CRAFTQUEUE_QUEUE_PATRON_ORDERS_MOXIE_VALUES
local moxieAutoUpdateOptionKey = CraftSim.CONST.GENERAL_OPTIONS.CRAFTQUEUE_QUEUE_PATRON_ORDERS_AUTO_UPDATE_MOXIE_VALUES

---@type table<number, Enum.Profession>
local professionByMoxieCurrencyID = {}
for profession, currencyID in pairs(CraftSim.CONST.MOXIE_CURRENCY_ID_BY_PROFESSION) do
    professionByMoxieCurrencyID[currencyID] = profession
end

---@param currencyID number
---@return number
local function GetMoxieStorageCurrencyID(currencyID)
    return CraftSim.PATRON_MOXIE_SURPLUS:GetStorageCurrencyID(currencyID)
end

---@class CraftSim.MoxieCurrencyGroup
---@field storageCurrencyID number
---@field currencyIDs number[]

---@return CraftSim.MoxieCurrencyGroup[]
local function BuildMoxieCurrencyGroups()
    ---@type table<number, CraftSim.MoxieCurrencyGroup>
    local byStorageCurrencyID = {}
    ---@type CraftSim.MoxieCurrencyGroup[]
    local groups = {}
    for _, currencyID in ipairs(CraftSim.CONST.MOXIE_CURRENCY_IDS) do
        local storageCurrencyID = GetMoxieStorageCurrencyID(currencyID)
        local group = byStorageCurrencyID[storageCurrencyID]
        if not group then
            group = {
                storageCurrencyID = storageCurrencyID,
                currencyIDs = {},
            }
            byStorageCurrencyID[storageCurrencyID] = group
            tinsert(groups, group)
        end
        tinsert(group.currencyIDs, currencyID)
    end
    return groups
end

---@param group CraftSim.MoxieCurrencyGroup
---@return string
local function GetMoxieGroupLinkLabel(group)
    ---@type string[]
    local links = {}
    for _, currencyID in ipairs(group.currencyIDs) do
        local currencyInfo = C_CurrencyInfo.GetCurrencyInfo(currencyID)
        local linkText = C_CurrencyInfo.GetCurrencyLink(currencyID, 1) or
            (currencyInfo and currencyInfo.name) or ("#" .. tostring(currencyID))
        tinsert(links, linkText)
    end
    return table.concat(links, "\n")
end

---@param storageCurrencyID number
---@return number[]
local function GetMoxieGroupItemIDs(storageCurrencyID)
    local entries = CraftSim.PATRON_MOXIE_SURPLUS:GetSpec(storageCurrencyID) or {}
    ---@type table<number, boolean>
    local seen = {}
    ---@type number[]
    local itemIDs = {}
    for _, entry in ipairs(entries) do
        if entry.itemID and not seen[entry.itemID] then
            seen[entry.itemID] = true
            tinsert(itemIDs, entry.itemID)
        end
    end
    return itemIDs
end

---@param stored table
---@param currencyID number
---@return number
local function GetPatronMoxieStoredValue(stored, currencyID)
    if type(stored) ~= "table" then
        return 0
    end
    local storageCurrencyID = GetMoxieStorageCurrencyID(currencyID)
    return tonumber(stored[storageCurrencyID] or stored[tostring(storageCurrencyID)]) or 0
end

---@param currencyID number
---@param copperTotal number
local function SavePatronMoxieCopper(currencyID, copperTotal)
    local stored = CraftSim.DB.OPTIONS:Get(moxieValuesOptionKey)
    if type(stored) ~= "table" then
        stored = {}
    end
    local value = tonumber(copperTotal) or 0
    local storageCurrencyID = GetMoxieStorageCurrencyID(currencyID)
    stored[storageCurrencyID] = value
    stored[tostring(storageCurrencyID)] = value
    -- Persist explicitly in case OPTIONS storage does not track table mutations by reference.
    CraftSim.DB.OPTIONS:Save(moxieValuesOptionKey, stored)
end

local function SyncPatronMoxieInputsFromDB()
    local rows = CraftSim.CRAFTQ.patronMoxieSurplusRows
    if not rows then
        return
    end
    local updatedValues = CraftSim.DB.OPTIONS:Get(moxieValuesOptionKey)
    for _, row in ipairs(rows) do
        if row.currencyInput and row.storageCurrencyID then
            row.currencyInput:SetValue(GetPatronMoxieStoredValue(updatedValues, row.storageCurrencyID))
        end
    end
end

--- Recomputes surplus-derived moxie values and only writes changed entries.
---@return boolean changedAny
function CraftSim.CRAFTQ.UI:AutoUpdatePatronMoxieValuesFromSurplus()
    local changedAny = false
    local updateCount = 0
    local stored = CraftSim.DB.OPTIONS:Get(moxieValuesOptionKey)
    if type(stored) ~= "table" then
        stored = {}
        CraftSim.DB.OPTIONS:Save(moxieValuesOptionKey, stored)
    end

    for _, group in ipairs(BuildMoxieCurrencyGroups()) do
        local storageCurrencyID = group.storageCurrencyID
        local suggested = CraftSim.PATRON_MOXIE_SURPLUS:ComputeCopperPerMoxie(storageCurrencyID)
        local normalizedSuggested = tonumber(suggested)
        if normalizedSuggested and normalizedSuggested > 0 then
            normalizedSuggested = math.floor(normalizedSuggested + 0.5)
            local currentValue = GetPatronMoxieStoredValue(stored, storageCurrencyID)
            if currentValue ~= normalizedSuggested then
                updateCount = updateCount + 1
                SavePatronMoxieCopper(storageCurrencyID, normalizedSuggested)
                stored[storageCurrencyID] = normalizedSuggested
                stored[tostring(storageCurrencyID)] = normalizedSuggested
                changedAny = true
            end
        end
    end

    if changedAny then
        CraftSim.DEBUG:SystemPrint(f.l("CraftSim: ") ..
            "Auto-updating " .. tostring(updateCount) .. " Moxie value(s) from current price source data")
        SyncPatronMoxieInputsFromDB()
        CraftSim.CRAFTQ.UI:RefreshPatronMoxieSurplusSuggestions()
    end

    return changedAny
end

function CraftSim.CRAFTQ.UI:InitPatronRewardValuesFrame()
    local sizeX = 520
    local sizeY = 380 -- compact moxie table popup
    local suggestColW = 78
    local itemsColW = 132

    ---@type GGUI.Frame
    CraftSim.CRAFTQ.patronRewardValuesFrame = CraftSim.GGUI.Frame({
        parent = ProfessionsFrame,
        anchorParent = ProfessionsFrame,
        sizeX = sizeX,
        sizeY = sizeY,
        frameID = CraftSim.CONST.FRAMES.CRAFTQUEUE_PATRON_REWARD_VALUES,
        title = L("CRAFT_QUEUE_PATRON_REWARD_VALUES_TITLE"),
        collapseable = true,
        closeable = true,
        moveable = true,
        hide = true,
        backdropOptions = CraftSim.CONST.DEFAULT_BACKDROP_OPTIONS,
        frameTable = CraftSim.INIT.FRAMES,
        frameConfigTable = CraftSim.DB.OPTIONS:Get("GGUI_CONFIG"),
        frameStrata = CraftSim.CONST.MODULES_FRAME_STRATA,
        raiseOnInteraction = true,
        frameLevel = CraftSim.UTIL:NextFrameLevel(),
    })

    local gFrame = CraftSim.CRAFTQ.patronRewardValuesFrame
    local content = gFrame.content

    local padX = 12
    local rowInnerW = sizeX - 2 * padX
    local currencyColW = 62
    local columnGapW = 16

    local introText = GGUI.Text({
        parent = content,
        anchorParent = content,
        anchorA = "TOPLEFT",
        anchorB = "TOPLEFT",
        offsetX = padX,
        offsetY = -35,
        text = L("CRAFT_QUEUE_PATRON_REWARD_VALUES_INTRO"),
        justifyOptions = { type = "H", align = "LEFT" },
        wrap = true,
        fixedWidth = rowInnerW,
    })

    CraftSim.CRAFTQ.patronMoxieSurplusRows = {}

    content.moxieValuesList = GGUI.FrameList({
        parent = content,
        anchorParent = introText.frame,
        anchorA = "TOPLEFT",
        anchorB = "BOTTOMLEFT",
        offsetY = -25,
        sizeY = sizeY - 95,
        showBorder = false,
        hideScrollbar = true,
        rowHeight = 58,
        columnOptions = {
            { label = L("CRAFT_QUEUE_PATRON_MOXIE_VALUES_HEADER_MOXIE"),     width = rowInnerW - itemsColW - currencyColW - suggestColW - (3 * columnGapW) - 12, justifyOptions = { type = "H", align = "CENTER" } },
            { label = "",                                                    width = columnGapW },
            { label = L("CRAFT_QUEUE_PATRON_MOXIE_VALUES_HEADER_ITEMS"),     width = itemsColW,                                                                  justifyOptions = { type = "H", align = "CENTER" } },
            { label = "",                                                    width = columnGapW },
            { label = L("CRAFT_QUEUE_PATRON_MOXIE_VALUES_HEADER_CURRENT"),   width = currencyColW,                                                               justifyOptions = { type = "H", align = "CENTER" } },
            { label = "",                                                    width = columnGapW },
            { label = L("CRAFT_QUEUE_PATRON_MOXIE_VALUES_HEADER_SUGGESTED"), width = suggestColW,                                                                justifyOptions = { type = "H", align = "CENTER" } },
        },
        rowConstructor = function(columns, row)
            local moxieCol = columns[1]
            local itemsCol = columns[3]
            local currentCol = columns[5]
            local suggestCol = columns[7]

            moxieCol.label = GGUI.Text {
                parent = moxieCol,
                anchorParent = moxieCol,
                anchorA = "TOPLEFT",
                anchorB = "TOPLEFT",
                offsetY = 0,
                text = "",
                justifyOptions = { type = "H", align = "LEFT" },
                fixedWidth = moxieCol:GetWidth() - 4,
                wrap = true,
            }

            itemsCol.iconFrames = {}
            for i = 1, 10 do
                local iconFrame = CreateFrame("Frame", nil, itemsCol)
                iconFrame:SetSize(16, 16)
                local col = (i - 1) % 5
                local line = math.floor((i - 1) / 5)
                iconFrame:SetPoint("TOPLEFT", itemsCol, "TOPLEFT", col * 18, -line * 18)
                iconFrame:SetFrameStrata("TOOLTIP")
                iconFrame:SetFrameLevel(200)
                local iconTexture = iconFrame:CreateTexture(nil, "ARTWORK")
                iconTexture:SetAllPoints(iconFrame)
                iconTexture:SetTexture(nil)
                iconFrame.texture = iconTexture
                iconFrame.itemID = nil
                iconFrame:EnableMouse(true)
                iconFrame:SetScript("OnEnter", function(frame)
                    if not frame.itemID then
                        return
                    end
                    GameTooltip:SetOwner(frame, "ANCHOR_RIGHT")
                    GameTooltip:SetHyperlink("item:" .. tostring(frame.itemID))
                    GameTooltip:Show()
                end)
                iconFrame:SetScript("OnLeave", GameTooltip_Hide)
                iconFrame:Hide()
                tinsert(itemsCol.iconFrames, iconFrame)
            end

            currentCol.input = GGUI.CurrencyInput {
                parent = currentCol, anchorParent = currentCol,
                sizeX = 60, sizeY = 22, offsetX = 0,
                anchorA = "TOPRIGHT", anchorB = "TOPRIGHT",
                offsetY = 0,
                initialValue = 0,
                borderAdjustWidth = 1,
                minValue = 0.94,
                tooltipOptions = {
                    anchor = "ANCHOR_TOP",
                    owner = currentCol,
                    text = f.white(L("CRAFT_QUEUE_PATRON_ORDERS_MOXIE_VALUE_TOOLTIP") ..
                        GUTIL:FormatMoney(1000000, false, nil, false, false)),
                },
            }

            suggestCol.button = GGUI.Button {
                parent = suggestCol,
                anchorParent = suggestCol,
                anchorA = "TOPRIGHT",
                anchorB = "TOPRIGHT",
                offsetY = 0,
                sizeX = suggestColW,
                sizeY = 22,
                label = "—",
            }
        end,
    })

    local moxieValuesList = content.moxieValuesList --[[@as GGUI.FrameList]]
    moxieValuesList:Remove()
    for _, group in ipairs(BuildMoxieCurrencyGroups()) do
        moxieValuesList:Add(function(row, columns)
            local moxieCol = columns[1]
            local itemsCol = columns[3]
            local currentCol = columns[5]
            local suggestCol = columns[7]
            local storageCurrencyID = group.storageCurrencyID
            local values = CraftSim.DB.OPTIONS:Get(moxieValuesOptionKey)
            local initial = GetPatronMoxieStoredValue(values, storageCurrencyID)
            local labelText = GetMoxieGroupLinkLabel(group)
            local itemIDs = GetMoxieGroupItemIDs(storageCurrencyID)

            moxieCol.label:SetText(labelText)
            moxieCol:EnableMouse(true)
            moxieCol:SetScript("OnEnter", function(frame)
                GameTooltip:SetOwner(frame, "ANCHOR_RIGHT")
                GameTooltip:ClearLines()
                if #group.currencyIDs == 1 then
                    GameTooltip:SetCurrencyByID(storageCurrencyID, 1)
                else
                    GameTooltip:AddLine("Grouped Moxie Currencies", 1, 1, 1, true)
                    GameTooltip:AddLine(" ")
                    for _, currencyID in ipairs(group.currencyIDs) do
                        local currencyInfo = C_CurrencyInfo.GetCurrencyInfo(currencyID)
                        local linkText = C_CurrencyInfo.GetCurrencyLink(currencyID, 1) or
                            (currencyInfo and currencyInfo.name) or ("#" .. tostring(currencyID))
                        GameTooltip:AddLine(linkText, 1, 1, 1, true)
                    end
                    GameTooltip:AddLine(" ")
                    GameTooltip:AddLine("One shared value is used for this group.", 0.8, 0.8, 0.8, true)
                end
                GameTooltip:Show()
            end)
            moxieCol:SetScript("OnLeave", GameTooltip_Hide)

            for i, iconFrame in ipairs(itemsCol.iconFrames or {}) do
                local itemID = itemIDs[i]
                if itemID then
                    iconFrame.itemID = itemID
                    iconFrame.texture:SetTexture(C_Item.GetItemIconByID(itemID))
                    iconFrame:Show()
                else
                    iconFrame.itemID = nil
                    iconFrame.texture:SetTexture(nil)
                    iconFrame:Hide()
                end
            end

            currentCol.input:SetValue(initial)
            currentCol.input.onValueValidCallback = function(input)
                SavePatronMoxieCopper(storageCurrencyID, tonumber(input.total) or 0)
                SyncPatronMoxieInputsFromDB()
            end

            suggestCol.button.clickCallback = function()
                local suggested = CraftSim.PATRON_MOXIE_SURPLUS:ComputeCopperPerMoxie(storageCurrencyID)
                if not suggested or suggested <= 0 then
                    return
                end
                currentCol.input:SetValue(suggested)
                SavePatronMoxieCopper(storageCurrencyID, suggested)
                SyncPatronMoxieInputsFromDB()
            end
            suggestCol.button.frame:SetScript("OnEnter", function(btn)
                local suggested = CraftSim.PATRON_MOXIE_SURPLUS:ComputeCopperPerMoxie(storageCurrencyID)
                GameTooltip:SetOwner(btn, "ANCHOR_LEFT")
                GameTooltip:ClearLines()
                if suggested and suggested > 0 then
                    local expectedMoxie = CraftSim.PATRON_MOXIE_SURPLUS:GetExpectedMoxie(storageCurrencyID)
                    GameTooltip:AddLine(L("CRAFT_QUEUE_PATRON_MOXIE_SURPLUS_SUGGEST_TOOLTIP"), 1, 1, 1, true)
                    if expectedMoxie and expectedMoxie > 0 then
                        GameTooltip:AddLine(" ", 1, 1, 1)
                        GameTooltip:AddDoubleLine(L("CRAFT_QUEUE_PATRON_MOXIE_SURPLUS_TT_REAGENT_TOTAL"),
                            GUTIL:FormatMoney(math.floor((suggested * expectedMoxie) + 0.5), true, nil, true), 1, 1,
                            1, 1, 1, 1)
                        GameTooltip:AddDoubleLine(L("CRAFT_QUEUE_PATRON_MOXIE_SURPLUS_TT_PER_MOXIE"),
                            GUTIL:FormatMoney(suggested, true, nil, true), 1, 1, 1, 1, 1, 1)
                    end
                else
                    GameTooltip:AddLine(L("CRAFT_QUEUE_PATRON_MOXIE_SURPLUS_NO_DATA_TOOLTIP"), 1, 0.4, 0.4, true)
                end
                GameTooltip:Show()
            end)
            suggestCol.button.frame:SetScript("OnLeave", GameTooltip_Hide)

            tinsert(CraftSim.CRAFTQ.patronMoxieSurplusRows, {
                storageCurrencyID = storageCurrencyID,
                button = suggestCol.button,
                currencyInput = currentCol.input,
            })
        end)
    end
    moxieValuesList:UpdateDisplay()

    CraftSim.CRAFTQ.UI:RefreshPatronMoxieSurplusSuggestions()
end

--- Updates surplus-derived Moxie value buttons (call after prices change or frame shown).
function CraftSim.CRAFTQ.UI:RefreshPatronMoxieSurplusSuggestions()
    local rows = CraftSim.CRAFTQ.patronMoxieSurplusRows
    if not rows then
        return
    end
    local suggestColW = 78
    for _, r in ipairs(rows) do
        local suggested = CraftSim.PATRON_MOXIE_SURPLUS:ComputeCopperPerMoxie(r.storageCurrencyID)
        if suggested and suggested > 0 then
            r.button.frame:SetEnabled(true)
            r.button:SetText(GUTIL:FormatMoney(suggested, false, nil, true), suggestColW, false)
        else
            r.button.frame:SetEnabled(false)
            r.button:SetText("—", suggestColW, false)
        end
    end
end

function CraftSim.CRAFTQ.UI:ShowPatronRewardValuesFrame()
    if not CraftSim.CRAFTQ.patronRewardValuesFrame then
        return
    end
    CraftSim.CRAFTQ.UI:RefreshPatronMoxieSurplusSuggestions()
    CraftSim.CRAFTQ.patronRewardValuesFrame:Show()
    CraftSim.CRAFTQ.patronRewardValuesFrame:Raise()
end

function CraftSim.CRAFTQ.UI:Init()
    local sizeX = 900
    local sizeY = 420

    ---@class CraftSim.CraftQueue.Frame : GGUI.Frame
    CraftSim.CRAFTQ.frame = GGUI.Frame({
        parent = ProfessionsFrame,
        anchorParent = ProfessionsFrame,
        sizeX = sizeX,
        sizeY = sizeY,
        frameID = CraftSim.CONST.FRAMES.CRAFT_QUEUE,
        title = L("CRAFT_QUEUE_TITLE"),
        collapseable = true,
        closeable = true,
        moveable = true,
        backdropOptions = CraftSim.CONST.DEFAULT_BACKDROP_OPTIONS,
        onCloseCallback = CraftSim.MODULES:HandleModuleClose("MODULE_CRAFT_QUEUE"),
        frameTable = CraftSim.INIT.FRAMES,
        frameConfigTable = CraftSim.DB.OPTIONS:Get("GGUI_CONFIG"),
        frameStrata = CraftSim.CONST.MODULES_FRAME_STRATA,
        raiseOnInteraction = true,
        frameLevel = CraftSim.UTIL:NextFrameLevel()
    })

    ---@param frame CraftSim.CraftQueue.Frame
    local function createContent(frame)
        local tabContentSizeX = 1010
        local tabContentSizeY = 330

        ---@class CraftSim.CraftQueue.Frame.Content : Frame
        frame.content = frame.content


        frame.content.craftQueueOptionsButton = CraftSim.WIDGETS.OptionsButton {
            parent = frame.content,
            anchorPoints = { { anchorParent = frame.title.frame, anchorA = "LEFT", anchorB = "RIGHT", offsetX = 5 } },
            menuUtilCallback = function(ownerRegion, rootDescription)
                local auto = rootDescription:CreateCheckbox(
                    L("CRAFT_QUEUE_MENU_AUTO_SHOW"),
                    function()
                        return CraftSim.DB.OPTIONS:Get("CRAFTQUEUE_AUTO_SHOW")
                    end, function()
                        local value = CraftSim.DB.OPTIONS:Get(
                            "CRAFTQUEUE_AUTO_SHOW")
                        CraftSim.DB.OPTIONS:Save("CRAFTQUEUE_AUTO_SHOW",
                            not value)
                    end)

                local autoShoppingListCB = rootDescription:CreateCheckbox(
                    L("CRAFT_LISTS_OPTIONS_AUTO_SHOPPING_LIST"),
                    function()
                        return CraftSim.DB.OPTIONS:Get("CRAFTQUEUE_AUTO_SHOPPING_LIST")
                    end,
                    function()
                        local value = CraftSim.DB.OPTIONS:Get("CRAFTQUEUE_AUTO_SHOPPING_LIST")
                        CraftSim.DB.OPTIONS:Save("CRAFTQUEUE_AUTO_SHOPPING_LIST", not value)
                    end)

                local ingenuityIgnoreCB = rootDescription:CreateCheckbox(
                    L("CRAFT_QUEUE_MENU_INGENUITY_IGNORE"),
                    function()
                        return CraftSim.DB.OPTIONS:Get("CRAFTQUEUE_IGNORE_INGENUITY_PROCS")
                    end, function()
                        local value = CraftSim.DB.OPTIONS:Get(
                            "CRAFTQUEUE_IGNORE_INGENUITY_PROCS")
                        CraftSim.DB.OPTIONS:Save("CRAFTQUEUE_IGNORE_INGENUITY_PROCS",
                            not value)
                    end)

                local dequeueConcentrationCB = rootDescription:CreateCheckbox(
                    L("CRAFT_QUEUE_MENU_DEQUEUE_CONCENTRATION"),
                    function()
                        return CraftSim.DB.OPTIONS:Get("CRAFTQUEUE_REMOVE_ON_ALL_CONCENTRATION_USED")
                    end, function()
                        local value = CraftSim.DB.OPTIONS:Get(
                            "CRAFTQUEUE_REMOVE_ON_ALL_CONCENTRATION_USED")
                        CraftSim.DB.OPTIONS:Save("CRAFTQUEUE_REMOVE_ON_ALL_CONCENTRATION_USED",
                            not value)
                    end)

                dequeueConcentrationCB:SetTooltip(function(tooltip, elementDescription)
                    GameTooltip_AddInstructionLine(tooltip,
                        L("CRAFT_QUEUE_MENU_DEQUEUE_CONCENTRATION_TOOLTIP"));
                end);

                local shatterForceCB = rootDescription:CreateCheckbox(
                    L("CRAFT_QUEUE_MENU_MIDNIGHT_SHATTER_FORCE_BUFF"),
                    function()
                        return CraftSim.DB.OPTIONS:Get(
                                CraftSim.CONST.GENERAL_OPTIONS.CRAFTQUEUE_MIDNIGHT_SHATTER_FORCE_BUFF) or
                            CraftSim.DB.OPTIONS:Get(
                                CraftSim.CONST.GENERAL_OPTIONS.CRAFTQUEUE_TWW_ENCHANT_SHATTER_FORCE_BUFF)
                    end, function()
                        local value = CraftSim.DB.OPTIONS:Get(
                                CraftSim.CONST.GENERAL_OPTIONS.CRAFTQUEUE_MIDNIGHT_SHATTER_FORCE_BUFF) or
                            CraftSim.DB.OPTIONS:Get(
                                CraftSim.CONST.GENERAL_OPTIONS.CRAFTQUEUE_TWW_ENCHANT_SHATTER_FORCE_BUFF)
                        CraftSim.DB.OPTIONS:Save(
                            CraftSim.CONST.GENERAL_OPTIONS.CRAFTQUEUE_MIDNIGHT_SHATTER_FORCE_BUFF, not value)
                        CraftSim.DB.OPTIONS:Save(
                            CraftSim.CONST.GENERAL_OPTIONS.CRAFTQUEUE_TWW_ENCHANT_SHATTER_FORCE_BUFF, not value)
                    end)

                shatterForceCB:SetTooltip(function(tooltip, elementDescription)
                    GameTooltip_AddInstructionLine(tooltip,
                        L("CRAFT_QUEUE_MENU_MIDNIGHT_SHATTER_FORCE_BUFF_TOOLTIP"));
                end);
            end
        }

        ---@type GGUI.BlizzardTab
        frame.content.queueTab = GGUI.BlizzardTab({
            buttonOptions = {
                parent = frame.content,
                anchorParent = frame.content,
                offsetY = -2,
                label = L("CRAFT_QUEUE_QUEUE_TAB_LABEL"),
            },
            parent = frame.content,
            anchorParent = frame.content,
            sizeX = tabContentSizeX,
            sizeY = tabContentSizeY,
            canBeEnabled = true,
            offsetY = -30,
            initialTab = true,
            top = true,
        })
        ---@class CraftSim.CraftQueue.QueueTab : GGUI.BlizzardTab
        local queueTab = frame.content.queueTab
        ---@class CraftSim.CraftQueue.QueueTab.Content
        queueTab.content = queueTab.content

        ---@type GGUI.BlizzardTab
        frame.content.craftListsTab = GGUI.BlizzardTab({
            buttonOptions = {
                parent = frame.content,
                anchorParent = frame.content.queueTab.button,
                anchorA = "LEFT",
                anchorB = "RIGHT",
                label = L("CRAFT_LISTS_TAB_LABEL"),
            },
            parent = frame.content,
            anchorParent = frame.content,
            anchorA = "TOPLEFT",
            anchorB = "TOPLEFT",
            sizeX = tabContentSizeX,
            sizeY = tabContentSizeY,
            canBeEnabled = true,
            offsetY = -80,
            offsetX = 20,
            top = true,
        })
        ---@class CraftSim.CraftQueue.CraftListsTab : GGUI.BlizzardTab
        local craftListsTab = frame.content.craftListsTab
        ---@class CraftSim.CraftQueue.CraftListsTab.Content
        craftListsTab.content = craftListsTab.content

        GGUI.BlizzardTabSystem({ queueTab, craftListsTab })

        ---@type GGUI.FrameList.ColumnOption[]
        local columnOptions = {
            {
                label = L("RECIPE_SCAN_CRAFTER_HEADER"),
                width = 100,
                justifyOptions = { type = "H", align = "CENTER" }
            },
            {
                label = L("RECIPE_SCAN_RECIPE_HEADER"),
                width = 260,
            },
            {
                label = L("RECIPE_SCAN_RESULT_HEADER"),
                width = CRAFT_QUEUE_RESULT_COLUMN_WIDTH,
                justifyOptions = { type = "H", align = "CENTER" },
            },
            {
                label = L("RECIPE_SCAN_AVERAGE_PROFIT_HEADER"),
                width = 120,
            },
            {
                label = L("CRAFT_QUEUE_CRAFTING_COSTS_HEADER"),
                width = 110,
                justifyOptions = { type = "H", align = "RIGHT" }
            },
            {
                label = GUTIL:IconToText(CraftSim.CONST.CONCENTRATION_ICON, 20, 20, 1),
                width = 50,
                justifyOptions = { type = "H", align = "CENTER" },
            },
            {
                label = L("CRAFT_QUEUE_CRAFT_AVAILABLE_AMOUNT"),
                width = 60,
                justifyOptions = { type = "H", align = "CENTER" }
            },
            {
                label = L("CRAFT_QUEUE_CRAFT_AMOUNT_LEFT_HEADER"),
                width = 50,
                justifyOptions = { type = "H", align = "CENTER" }
            },
            {
                label = "", -- craftButtonColumn
                width = 60,
                justifyOptions = { type = "H", align = "CENTER" }
            },
        }

        ---@class CraftSim.CraftQueue.CraftList : GGUI.FrameList
        queueTab.content.craftList = GGUI.FrameList({
            parent = queueTab.content,
            anchorParent = frame.title.frame,
            anchorA = "TOP",
            anchorB = "TOP",
            scale = 0.95,
            showBorder = true,
            selectionOptions = {
                hoverRGBA = { 1, 1, 1, 0.1 },
                noSelectionColor = true,
                selectionCallback = function(row)
                    ---@type CraftSim.CraftQueueItem
                    local craftQueueItem = row.craftQueueItem
                    if craftQueueItem then
                        local recipeData = craftQueueItem.recipeData
                        if recipeData then
                            if IsMouseButtonDown("LeftButton") then
                                if recipeData:IsWorkOrder() and C_CraftingOrders.ShouldShowCraftingOrderTab() and ProfessionsFrame.isCraftingOrdersTabEnabled then
                                    if not ProfessionsFrame.OrdersPage:IsVisible() then
                                        ProfessionsFrame:GetTabButton(3):Click() -- 3 is Crafting Orders Tab
                                    end
                                    -- Use fresh Blizzard order data when available to avoid tooltip taint
                                    local orderForView = recipeData.orderData
                                    local claimedOrder = C_CraftingOrders.GetClaimedOrder()
                                    if claimedOrder and claimedOrder.orderID == recipeData.orderData.orderID then
                                        orderForView = claimedOrder
                                    else
                                        local crafterOrders = C_CraftingOrders.GetCrafterOrders()
                                        if crafterOrders then
                                            for _, order in ipairs(crafterOrders) do
                                                if order.orderID == recipeData.orderData.orderID then
                                                    orderForView = order
                                                    break
                                                end
                                            end
                                        end
                                    end
                                    ProfessionsFrame.OrdersPage:ViewOrder(orderForView)
                                    CraftSim.MODULES:UpdateUI()
                                else
                                    if not ProfessionsFrame.CraftingPage:IsVisible() then
                                        ProfessionsFrame:GetTabButton(1):Click()
                                        C_TradeSkillUI.OpenRecipe(recipeData.recipeID)
                                    else
                                        RunNextFrame(function()
                                            C_TradeSkillUI.OpenRecipe(recipeData.recipeID)
                                        end)
                                    end
                                end
                            elseif IsMouseButtonDown("RightButton") then
                                CraftSim.WIDGETS.ContextMenu.Open(UIParent, function(ownerRegion, rootDescription)
                                    rootDescription:CreateTitle(recipeData.recipeName)
                                    rootDescription:CreateDivider()

                                    if recipeData:IsCrafter() then
                                        if not recipeData.professionGearSet:IsEquipped() then
                                            rootDescription:CreateButton(f.g("Equip Tools"), function()
                                                recipeData.professionGearSet:Equip()
                                            end)
                                            rootDescription:CreateButton(f.l("Force Equipped Tools"), function()
                                                recipeData:SetEquippedProfessionGearSet()
                                                CraftSim.CRAFTQ.UI:UpdateDisplay()
                                            end)
                                        end
                                    end

                                    rootDescription:CreateButton(L("CRAFT_QUEUE_BUTTON_EDIT"),
                                        function()
                                            CraftSim.CRAFTQ.UI:UpdateEditRecipeFrameDisplay(craftQueueItem)
                                            if not CraftSim.CRAFTQ.frame.content.queueTab.content.editRecipeFrame:IsVisible() then
                                                CraftSim.CRAFTQ.frame.content.queueTab.content.editRecipeFrame:Show()
                                            end
                                        end)
                                    rootDescription:CreateButton(f.r("Remove"), function()
                                        CraftSim.CRAFTQ.craftQueue:Remove(craftQueueItem, true)
                                        CraftSim.CRAFTQ.UI:UpdateDisplay()
                                    end)
                                end)
                            elseif IsMouseButtonDown("MiddleButton") then
                                CraftSim.CRAFTQ.craftQueue:Remove(craftQueueItem, true)
                                CraftSim.CRAFTQ.UI:UpdateDisplay()
                            end
                        end
                    end
                end
            },
            sizeY = 232,
            offsetY = -70,
            offsetX = -10,
            columnOptions = columnOptions,
            rowConstructor = function(columns, row)
                ---@class CraftSim.CraftQueue.CraftList.CrafterColumn : Frame
                local crafterColumn = columns[1]
                ---@class CraftSim.CraftQueue.CraftList.RecipeColumn : Frame
                local recipeColumn = columns[2]
                ---@class CraftSim.CraftQueue.CraftList.ResultColumn : Frame
                local resultColumn = columns[3]
                ---@class CraftSim.CraftQueue.CraftList.AverageProfitColumn : Frame
                local averageProfitColumn = columns[4]
                ---@class CraftSim.CraftQueue.CraftList.CraftingCostColumn : Frame
                local craftingCostsColumn = columns[5]
                ---@class CraftSim.CraftQueue.CraftList.ConcentrationColumn : Frame
                local concentrationColumn = columns[6]
                ---@class CraftSim.CraftQueue.CraftList.CraftAbleColumn : Frame
                local craftAbleColumn = columns[7]
                ---@class CraftSim.CraftQueue.CraftList.CraftAmountColumn : Frame
                local craftAmountColumn = columns[8]
                ---@class CraftSim.CraftQueue.CraftList.CraftButtonColumn : Frame
                local craftButtonColumn = columns[9]

                crafterColumn.text = GGUI.Text {
                    parent = crafterColumn, anchorParent = crafterColumn,
                    scale = 0.9
                }

                recipeColumn.text = GGUI.Text({
                    parent = recipeColumn,
                    anchorParent = recipeColumn,
                    anchorA = "LEFT",
                    anchorB = "LEFT",
                    justifyOptions = { type = "H", align = "LEFT" },
                    scale = 0.9,
                    fixedWidth = recipeColumn:GetWidth(),
                    wrap = true,
                })

                resultColumn.iconRow = CreateFrame("Frame", nil, resultColumn)
                resultColumn.iconRow:SetPoint("CENTER", resultColumn, "CENTER", 0, 0)
                resultColumn.iconRow:SetSize(1, CRAFT_QUEUE_RESULT_ICON_SIZE)

                resultColumn.resultIcons = {}
                for ri = 1, CRAFT_QUEUE_RESULT_ICON_SLOTS do
                    local anchorParent = ri == 1 and resultColumn.iconRow or resultColumn.resultIcons[ri - 1].frame
                    local anchorA, anchorB, offsetX = "LEFT", "LEFT", 0
                    if ri > 1 then
                        anchorA, anchorB, offsetX = "LEFT", "RIGHT", CRAFT_QUEUE_RESULT_ICON_SPACING
                    end
                    resultColumn.resultIcons[ri] = GGUI.Icon {
                        parent = resultColumn.iconRow,
                        anchorParent = anchorParent,
                        anchorA = anchorA,
                        anchorB = anchorB,
                        offsetX = offsetX,
                        offsetY = 0,
                        qualityIconScale = 1.2,
                        sizeX = CRAFT_QUEUE_RESULT_ICON_SIZE,
                        sizeY = CRAFT_QUEUE_RESULT_ICON_SIZE,
                    }
                    resultColumn.resultIcons[ri].frame:Hide()
                end

                ---@type GGUI.Text | GGUI.Widget
                averageProfitColumn.text = GGUI.Text(
                    {
                        parent = averageProfitColumn,
                        anchorParent = averageProfitColumn,
                        anchorA = "LEFT",
                        anchorB =
                        "LEFT",
                        scale = 0.9,

                    })

                craftingCostsColumn.text = GGUI.Text {
                    parent = craftingCostsColumn,
                    anchorParent = craftingCostsColumn,
                    anchorA = "RIGHT",
                    anchorB =
                    "RIGHT",
                    scale = 0.9,
                    justifyOptions = { type = "H", align = "RIGHT" }
                }

                concentrationColumn.text = GGUI.Text {
                    parent = concentrationColumn,
                    anchorParent = concentrationColumn,
                    scale = 0.9,
                }

                craftAbleColumn.text = GGUI.Text({
                    parent = craftAbleColumn, anchorParent = craftAbleColumn
                })

                craftAmountColumn.inputText = GGUI.Text {
                    parent = craftAmountColumn, anchorPoints = { { anchorParent = craftAmountColumn, anchorA = "LEFT", anchorB = "LEFT", offsetX = -1 } },
                    hide = true, scale = 0.95,
                }

                craftAmountColumn.input = GGUI.NumericInput({
                    parent = craftAmountColumn,
                    anchorParent = craftAmountColumn,
                    sizeX = 35,
                    borderAdjustWidth = 1.3,
                    minValue = 1,
                    initialValue = 1,
                    onEnterPressedCallback = nil, -- set dynamically on Add
                    onTabPressedCallback = function(input)
                        -- focus next editbox in the row below
                        local activeRowIndex = row:GetActiveRowIndex()
                        if activeRowIndex then
                            local nextRow = row.frameList.activeRows[activeRowIndex + 1]
                            if nextRow then
                                input.textInput.frame:ClearFocus()
                                local craftAmountColumn = nextRow.columns
                                    [8] --[[@as CraftSim.CraftQueue.CraftList.CraftAmountColumn]]
                                craftAmountColumn.input.textInput.frame:SetFocus()
                            end
                        end
                    end,
                    onNumberValidCallback = function()
                        craftAmountColumn.unsavedMarker:Show()
                    end
                })

                craftAmountColumn.unsavedMarker = GGUI.Text {
                    parent = craftAmountColumn, anchorPoints =
                { { anchorParent = craftAmountColumn.input.textInput.frame, anchorA = "TOPRIGHT", anchorB = "TOPLEFT", offsetX = -5, offsetY = -3 } },
                    text = "*", scale = 1.2,
                    tooltipOptions = {
                        anchor = "ANCHOR_CURSOR",
                        text = L("CRAFT_QUEUE_UNSAVED_CHANGES_TOOLTIP")
                    },
                    hide = true,
                }

                craftButtonColumn.craftButton = GGUI.Button({
                    parent = craftButtonColumn,
                    anchorParent = craftButtonColumn,
                    label = L("CRAFT_QUEUE_CRAFT_BUTTON_ROW_LABEL"),
                    adjustWidth = true,
                    secure = true,
                    tooltipOptions = {
                        anchor = "ANCHOR_CURSOR_RIGHT",
                        text = f.g("Ready to Craft"),
                        textWrap = true,
                    },
                })
                AttachCraftQueueButtonDisabledTooltipProxy(craftButtonColumn.craftButton)
            end
        })

        local craftQueueButtonsOffsetY = -5
        local fixedButtonWidth = 180
        ---@type GGUI.Button
        queueTab.content.queueCraftListsButton = GGUI.Button({
            parent = queueTab.content,
            anchorParent = queueTab.content.craftList.frame,
            anchorA = "TOPLEFT",
            anchorB = "BOTTOMLEFT",
            offsetY = craftQueueButtonsOffsetY,
            offsetX = 0,
            sizeX = fixedButtonWidth,
            label = L("CRAFT_LISTS_QUEUE_BUTTON_LABEL"),
            initialStatusID = "Ready",
            clickCallback = function()
                CraftSim.CRAFT_LISTS:QueueSelectedLists()
            end
        })

        queueTab.content.queueCraftListsButton:SetStatusList {
            {
                statusID = "Ready",
                enabled = true,
                sizeX = fixedButtonWidth,
                label = L("CRAFT_LISTS_QUEUE_BUTTON_LABEL"),
            },
        }

        queueTab.content.queueCraftListsButtonOptions = CraftSim.WIDGETS.OptionsButton {
            parent = queueTab.content,
            anchorPoints = { { anchorParent = queueTab.content.queueCraftListsButton.frame, anchorA = "LEFT", anchorB = "RIGHT", offsetX = 5 } },
            menuUtilCallback = function(ownerRegion, rootDescription)
                local crafterUID = CraftSim.UTIL:GetPlayerCrafterUID()
                local allLists = CraftSim.DB.CRAFT_LISTS:GetAllLists(crafterUID)

                if #allLists == 0 then
                    rootDescription:CreateTitle(f.grey("No Craft Lists created yet"))
                else
                    rootDescription:CreateTitle("Select Lists to Queue:")
                    for _, list in ipairs(allLists) do
                        local listRef = list
                        rootDescription:CreateCheckbox(
                            listRef.name,
                            function()
                                return CraftSim.DB.CRAFT_LISTS:IsSelectedForQueue(crafterUID, listRef.id)
                            end,
                            function()
                                local current = CraftSim.DB.CRAFT_LISTS:IsSelectedForQueue(crafterUID, listRef.id)
                                CraftSim.DB.CRAFT_LISTS:SetSelectedForQueue(crafterUID, listRef.id, not current)
                            end)
                    end
                end

                rootDescription:CreateDivider()

                local updateLastCostCB = rootDescription:CreateCheckbox(
                    L("CRAFT_LISTS_OPTIONS_UPDATE_LAST_CRAFTING_COST"),
                    function()
                        return CraftSim.DB.OPTIONS:Get("CRAFTQUEUE_UPDATE_LAST_CRAFTING_COST")
                    end,
                    function()
                        local value = CraftSim.DB.OPTIONS:Get("CRAFTQUEUE_UPDATE_LAST_CRAFTING_COST")
                        CraftSim.DB.OPTIONS:Save("CRAFTQUEUE_UPDATE_LAST_CRAFTING_COST", not value)
                    end)
                updateLastCostCB:SetTooltip(function(tooltip, elementDescription)
                    GameTooltip_AddInstructionLine(tooltip, L("CRAFT_LISTS_OPTIONS_UPDATE_LAST_CRAFTING_COST_TOOLTIP"))
                end)
            end
        }

        queueTab.content.addAllFirstCraftsButton = GGUI.Button({
            parent = queueTab.content,
            anchorParent = queueTab.content.queueCraftListsButton.frame,
            anchorA = "TOPLEFT",
            anchorB = "BOTTOMLEFT",
            offsetY = 0,
            sizeX = fixedButtonWidth,
            label = L("CRAFT_QUEUE_ADD_FIRST_CRAFTS_BUTTON_LABEL"),
            clickCallback = function()
                CraftSim.CRAFTQ:QueueFirstCrafts()
            end
        })

        queueTab.content.addAllFirstCraftsOptions = CraftSim.WIDGETS.OptionsButton {
            parent = queueTab.content,
            anchorPoints = { { anchorParent = queueTab.content.addAllFirstCraftsButton.frame, anchorA = "LEFT", anchorB = "RIGHT", offsetX = 5 } },
            menuUtilCallback = function(ownerRegion, rootDescription)
                local acuityCB = rootDescription:CreateCheckbox(
                    L("CRAFT_QUEUE_IGNORE_ACUITY_RECIPES_CHECKBOX_LABEL"),
                    function()
                        return CraftSim.DB.OPTIONS:Get("CRAFTQUEUE_FIRST_CRAFTS_IGNORE_ACUITY_RECIPES")
                    end, function()
                        local value = CraftSim.DB.OPTIONS:Get("CRAFTQUEUE_FIRST_CRAFTS_IGNORE_ACUITY_RECIPES")
                        CraftSim.DB.OPTIONS:Save("CRAFTQUEUE_FIRST_CRAFTS_IGNORE_ACUITY_RECIPES", not value)
                    end)

                acuityCB:SetTooltip(function(tooltip, elementDescription)
                    --GameTooltip_SetTitle(tooltip, MenuUtil.GetElementText(elementDescription));
                    GameTooltip_AddInstructionLine(tooltip,
                        L("CRAFT_QUEUE_IGNORE_ACUITY_RECIPES_CHECKBOX_TOOLTIP"));
                    --GameTooltip_AddNormalLine(tooltip, "Test Tooltip Normal Line");
                    --GameTooltip_AddErrorLine(tooltip, "Test Tooltip Colored Line");
                end);

                local sparksCB = rootDescription:CreateCheckbox(
                    L("CRAFT_QUEUE_IGNORE_SPARK_RECIPES_CHECKBOX_LABEL"),
                    function()
                        return CraftSim.DB.OPTIONS:Get("CRAFTQUEUE_FIRST_CRAFTS_IGNORE_SPARK_RECIPES")
                    end, function()
                        local value = CraftSim.DB.OPTIONS:Get("CRAFTQUEUE_FIRST_CRAFTS_IGNORE_SPARK_RECIPES")
                        CraftSim.DB.OPTIONS:Save("CRAFTQUEUE_FIRST_CRAFTS_IGNORE_SPARK_RECIPES", not value)
                    end)

                sparksCB:SetTooltip(function(tooltip, elementDescription)
                    GameTooltip_AddInstructionLine(tooltip,
                        L("CRAFT_QUEUE_IGNORE_SPARK_RECIPES_CHECKBOX_TOOLTIP"));
                end);
            end
        }

        queueTab.content.addWorkOrdersButton = GGUI.Button({
            parent = queueTab.content,
            anchorParent = queueTab.content.addAllFirstCraftsButton.frame,
            anchorA = "TOPLEFT",
            anchorB = "BOTTOMLEFT",
            offsetY = 0,
            sizeX = fixedButtonWidth,
            label = L("CRAFT_QUEUE_ADD_WORK_ORDERS_BUTTON_LABEL"),
            clickCallback = function()
                CraftSim.CRAFTQ:QueueWorkOrders()
            end
        })

        queueTab.content.addWorkOrdersOptions = CraftSim.WIDGETS.OptionsButton {
            parent = queueTab.content,
            anchorPoints = { { anchorParent = queueTab.content.addWorkOrdersButton.frame, anchorA = "LEFT", anchorB = "RIGHT", offsetX = 5 } },
            menuUtilCallback = function(ownerRegion, rootDescription)
                local concentrationCB = rootDescription:CreateCheckbox(
                    L("CRAFT_QUEUE_ADD_WORK_ORDERS_ALLOW_CONCENTRATION_CHECKBOX"),
                    function()
                        return CraftSim.DB.OPTIONS:Get("CRAFTQUEUE_WORK_ORDERS_ALLOW_CONCENTRATION")
                    end, function()
                        local value = CraftSim.DB.OPTIONS:Get("CRAFTQUEUE_WORK_ORDERS_ALLOW_CONCENTRATION")
                        CraftSim.DB.OPTIONS:Save("CRAFTQUEUE_WORK_ORDERS_ALLOW_CONCENTRATION", not value)
                    end)

                concentrationCB:SetTooltip(function(tooltip, elementDescription)
                    GameTooltip_AddInstructionLine(tooltip,
                        L("CRAFT_QUEUE_ADD_WORK_ORDERS_ALLOW_CONCENTRATION_TOOLTIP"));
                end);

                local onlyProfitableCB = rootDescription:CreateCheckbox(
                    L("CRAFT_QUEUE_ADD_WORK_ORDERS_ONLY_PROFITABLE_CHECKBOX"),
                    function()
                        return CraftSim.DB.OPTIONS:Get("CRAFTQUEUE_WORK_ORDERS_ONLY_PROFITABLE")
                    end, function()
                        local value = CraftSim.DB.OPTIONS:Get("CRAFTQUEUE_WORK_ORDERS_ONLY_PROFITABLE")
                        CraftSim.DB.OPTIONS:Save("CRAFTQUEUE_WORK_ORDERS_ONLY_PROFITABLE", not value)
                    end)

                onlyProfitableCB:SetTooltip(function(tooltip, elementDescription)
                    GameTooltip_AddInstructionLine(tooltip,
                        L("CRAFT_QUEUE_ADD_WORK_ORDERS_ONLY_PROFITABLE_TOOLTIP"))
                end);

                local autoQueueWorkOrders = rootDescription:CreateCheckbox(
                    L("CRAFT_QUEUE_ADD_WORK_ORDERS_AUTO_QUEUE_CHECKBOX"),
                    function()
                        return CraftSim.DB.OPTIONS:Get("CRAFTQUEUE_WORK_ORDERS_AUTO_QUEUE")
                    end, function()
                        local value = CraftSim.DB.OPTIONS:Get("CRAFTQUEUE_WORK_ORDERS_AUTO_QUEUE")
                        CraftSim.DB.OPTIONS:Save("CRAFTQUEUE_WORK_ORDERS_AUTO_QUEUE", not value)
                    end)

                autoQueueWorkOrders:SetTooltip(function(tooltip, elementDescription)
                    GameTooltip_AddInstructionLine(tooltip,
                        L("CRAFT_QUEUE_ADD_WORK_ORDERS_AUTO_QUEUE_TOOLTIP"))
                end);

                local orderTypeSubMenu = rootDescription:CreateButton(L("CRAFT_QUEUE_WORK_ORDER_TYPE_BUTTON"))

                orderTypeSubMenu:CreateCheckbox(L("CRAFT_QUEUE_PATRON_ORDERS_BUTTON"), function()
                    return CraftSim.DB.OPTIONS:Get("CRAFTQUEUE_WORK_ORDERS_INCLUDE_PATRON_ORDERS")
                end, function()
                    local value = CraftSim.DB.OPTIONS:Get("CRAFTQUEUE_WORK_ORDERS_INCLUDE_PATRON_ORDERS")
                    CraftSim.DB.OPTIONS:Save("CRAFTQUEUE_WORK_ORDERS_INCLUDE_PATRON_ORDERS", not value)
                end)

                orderTypeSubMenu:CreateCheckbox(L("CRAFT_QUEUE_GUILD_ORDERS_BUTTON"), function()
                    return CraftSim.DB.OPTIONS:Get("CRAFTQUEUE_WORK_ORDERS_INCLUDE_GUILD_ORDERS")
                end, function()
                    local value = CraftSim.DB.OPTIONS:Get("CRAFTQUEUE_WORK_ORDERS_INCLUDE_GUILD_ORDERS")
                    CraftSim.DB.OPTIONS:Save("CRAFTQUEUE_WORK_ORDERS_INCLUDE_GUILD_ORDERS", not value)
                end)

                orderTypeSubMenu:CreateCheckbox(L("CRAFT_QUEUE_PERSONAL_ORDERS_BUTTON"), function()
                    return CraftSim.DB.OPTIONS:Get("CRAFTQUEUE_WORK_ORDERS_INCLUDE_PERSONAL_ORDERS")
                end, function()
                    local value = CraftSim.DB.OPTIONS:Get("CRAFTQUEUE_WORK_ORDERS_INCLUDE_PERSONAL_ORDERS")
                    CraftSim.DB.OPTIONS:Save("CRAFTQUEUE_WORK_ORDERS_INCLUDE_PERSONAL_ORDERS", not value)
                end)

                orderTypeSubMenu:CreateCheckbox(L("CRAFT_QUEUE_PUBLIC_ORDERS_BUTTON"), function()
                    return CraftSim.DB.OPTIONS:Get("CRAFTQUEUE_WORK_ORDERS_INCLUDE_PUBLIC_ORDERS")
                end, function()
                    local value = CraftSim.DB.OPTIONS:Get("CRAFTQUEUE_WORK_ORDERS_INCLUDE_PUBLIC_ORDERS")
                    CraftSim.DB.OPTIONS:Save("CRAFTQUEUE_WORK_ORDERS_INCLUDE_PUBLIC_ORDERS", not value)
                end)

                local guildOrderOptions = rootDescription:CreateButton(L("CRAFT_QUEUE_GUILD_ORDERS_BUTTON"))
                local altCharsOnlyGuild = guildOrderOptions:CreateCheckbox(
                    L("CRAFT_QUEUE_GUILD_ORDERS_ALTS_ONLY_CHECKBOX"),
                    function()
                        return CraftSim.DB.OPTIONS:Get("CRAFTQUEUE_WORK_ORDERS_GUILD_ALTS_ONLY")
                    end, function()
                        local value = CraftSim.DB.OPTIONS:Get("CRAFTQUEUE_WORK_ORDERS_GUILD_ALTS_ONLY")
                        CraftSim.DB.OPTIONS:Save("CRAFTQUEUE_WORK_ORDERS_GUILD_ALTS_ONLY", not value)
                    end)

                local publicOrderOptions = rootDescription:CreateButton(L("CRAFT_QUEUE_PUBLIC_ORDERS_BUTTON"))

                GUTIL:CreateReuseableMenuUtilContextMenuFrame(publicOrderOptions, function(frame)
                    frame.label = GGUI.Text {
                        parent = frame,
                        anchorPoints = { { anchorParent = frame, anchorA = "LEFT", anchorB = "LEFT" } },
                        text = L("CRAFT_QUEUE_PUBLIC_ORDERS_MAX_COUNT"),
                        justifyOptions = { type = "H", align = "LEFT" },
                    }
                    frame.input = GGUI.NumericInput {
                        parent = frame, anchorParent = frame,
                        sizeX = 30, sizeY = 25, offsetX = 5,
                        anchorA = "RIGHT", anchorB = "RIGHT",
                        initialValue = CraftSim.DB.OPTIONS:Get("CRAFTQUEUE_PUBLIC_ORDERS_MAX_COUNT"),
                        borderAdjustWidth = 1.32,
                        minValue = 0,
                        tooltipOptions = {
                            anchor = "ANCHOR_TOP",
                            owner = frame,
                            text = f.white(L("CRAFT_QUEUE_PUBLIC_ORDERS_MAX_COUNT_TOOLTIP")),
                        },
                        onNumberValidCallback = function(input)
                            CraftSim.DB.OPTIONS:Save("CRAFTQUEUE_PUBLIC_ORDERS_MAX_COUNT",
                                tonumber(input.currentValue) or 0)
                        end,
                    }
                end, 210, 25, "CRAFTQUEUE_PUBLIC_ORDERS_MAX_COUNT_INPUT")

                local patronOrderOptions = rootDescription:CreateButton(L("CRAFT_QUEUE_PATRON_ORDERS_BUTTON"))

                local forceConcentrationCB = patronOrderOptions:CreateCheckbox(
                    L("CRAFT_QUEUE_PATRON_ORDERS_FORCE_CONCENTRATION_CHECKBOX"),
                    function()
                        return CraftSim.DB.OPTIONS:Get("CRAFTQUEUE_WORK_ORDERS_FORCE_CONCENTRATION")
                    end, function()
                        local value = CraftSim.DB.OPTIONS:Get("CRAFTQUEUE_WORK_ORDERS_FORCE_CONCENTRATION")
                        CraftSim.DB.OPTIONS:Save("CRAFTQUEUE_WORK_ORDERS_FORCE_CONCENTRATION", not value)
                    end)

                forceConcentrationCB:SetTooltip(function(tooltip, elementDescription)
                    GameTooltip_AddInstructionLine(tooltip,
                        L("CRAFT_QUEUE_PATRON_ORDERS_FORCE_CONCENTRATION_TOOLTIP"));
                end);

                local sparkCB = patronOrderOptions:CreateCheckbox(L("CRAFT_QUEUE_PATRON_ORDERS_SPARK_RECIPES_CHECKBOX"),
                    function()
                        return CraftSim.DB.OPTIONS:Get("CRAFTQUEUE_PATRON_ORDERS_SPARK_RECIPES")
                    end, function()
                        local value = CraftSim.DB.OPTIONS:Get("CRAFTQUEUE_PATRON_ORDERS_SPARK_RECIPES")
                        CraftSim.DB.OPTIONS:Save("CRAFTQUEUE_PATRON_ORDERS_SPARK_RECIPES", not value)
                    end)

                sparkCB:SetTooltip(function(tooltip, elementDescription)
                    GameTooltip_AddInstructionLine(tooltip,
                        L("CRAFT_QUEUE_PATRON_ORDERS_SPARK_RECIPES_TOOLTIP"));
                end);

                local acuityCB = patronOrderOptions:CreateCheckbox(
                    L("CRAFT_QUEUE_PATRON_ORDERS_ACUITY_CHECKBOX"),
                    function()
                        return CraftSim.DB.OPTIONS:Get("CRAFTQUEUE_PATRON_ORDERS_ACUITY")
                    end, function()
                        local value = CraftSim.DB.OPTIONS:Get("CRAFTQUEUE_PATRON_ORDERS_ACUITY")
                        CraftSim.DB.OPTIONS:Save("CRAFTQUEUE_PATRON_ORDERS_ACUITY", not value)
                    end)

                acuityCB:SetTooltip(function(tooltip, elementDescription)
                    GameTooltip_AddInstructionLine(tooltip,
                        L("CRAFT_QUEUE_PATRON_ORDERS_ACUITY_TOOLTIP"));
                end);

                local powerRuneCB = patronOrderOptions:CreateCheckbox(
                    L("CRAFT_QUEUE_PATRON_ORDERS_POWER_RUNE_CHECKBOX"),
                    function()
                        return CraftSim.DB.OPTIONS:Get("CRAFTQUEUE_PATRON_ORDERS_POWER_RUNE")
                    end, function()
                        local value = CraftSim.DB.OPTIONS:Get("CRAFTQUEUE_PATRON_ORDERS_POWER_RUNE")
                        CraftSim.DB.OPTIONS:Save("CRAFTQUEUE_PATRON_ORDERS_POWER_RUNE", not value)
                    end)

                powerRuneCB:SetTooltip(function(tooltip, elementDescription)
                    GameTooltip_AddInstructionLine(tooltip,
                        L("CRAFT_QUEUE_PATRON_ORDERS_POWER_RUNE_TOOLTIP"));
                end);

                local knowledgeCB = patronOrderOptions:CreateCheckbox(
                    L("CRAFT_QUEUE_PATRON_ORDERS_KNOWLEDGE_POINTS_CHECKBOX"),
                    function()
                        return CraftSim.DB.OPTIONS:Get("CRAFTQUEUE_PATRON_ORDERS_KNOWLEDGE_POINTS")
                    end, function()
                        local value = CraftSim.DB.OPTIONS:Get("CRAFTQUEUE_PATRON_ORDERS_KNOWLEDGE_POINTS")
                        CraftSim.DB.OPTIONS:Save("CRAFTQUEUE_PATRON_ORDERS_KNOWLEDGE_POINTS", not value)
                    end)

                knowledgeCB:SetTooltip(function(tooltip, elementDescription)
                    GameTooltip_AddInstructionLine(tooltip,
                        L("CRAFT_QUEUE_PATRON_ORDERS_KNOWLEDGE_POINTS_TOOLTIP"));
                end);

                GUTIL:CreateReuseableMenuUtilContextMenuFrame(patronOrderOptions, function(frame)
                    frame.label = GGUI.Text {
                        parent = frame,
                        anchorPoints = { { anchorParent = frame, anchorA = "LEFT", anchorB = "LEFT" } },
                        text = L("CRAFT_QUEUE_PATRON_ORDERS_KNOWLEDGE_POINTS_MAX_COST"),
                        justifyOptions = { type = "H", align = "LEFT" },
                    }
                    frame.input = GGUI.CurrencyInput {
                        parent = frame, anchorParent = frame,
                        sizeX = 60, sizeY = 25, offsetX = 5,
                        anchorA = "RIGHT", anchorB = "RIGHT",
                        initialValue = CraftSim.DB.OPTIONS:Get("CRAFTQUEUE_QUEUE_PATRON_ORDERS_KP_MAX_COST"),
                        borderAdjustWidth = 1,
                        minValue = 0.94,
                        tooltipOptions = {
                            anchor = "ANCHOR_TOP",
                            owner = frame,
                            text = f.white(L("CRAFT_QUEUE_PATRON_ORDERS_KNOWLEDGE_POINTS_MAX_COST_TOOLTIP") .. GUTIL:FormatMoney(1000000, false, nil, false, false)),
                        },
                        onValueValidCallback = function(input)
                            CraftSim.DB.OPTIONS:Save("CRAFTQUEUE_QUEUE_PATRON_ORDERS_KP_MAX_COST",
                                tonumber(input.total))
                        end,
                    }
                end, 210, 25, "CRAFTQUEUE_QUEUE_PATRON_ORDERS_KP_MAX_COST_INPUT")

                GUTIL:CreateReuseableMenuUtilContextMenuFrame(patronOrderOptions, function(frame)
                    frame.label = GGUI.Text {
                        parent = frame,
                        anchorPoints = { { anchorParent = frame, anchorA = "LEFT", anchorB = "LEFT" } },
                        text = L("CRAFT_QUEUE_PATRON_ORDERS_MAX_COST"),
                        justifyOptions = { type = "H", align = "LEFT" },
                    }
                    frame.input = GGUI.CurrencyInput {
                        parent = frame, anchorParent = frame,
                        sizeX = 60, sizeY = 25, offsetX = 5,
                        anchorA = "RIGHT", anchorB = "RIGHT",
                        initialValue = CraftSim.DB.OPTIONS:Get("CRAFTQUEUE_QUEUE_PATRON_ORDERS_MAX_COST"),
                        borderAdjustWidth = 1,
                        minValue = 0.94,
                        tooltipOptions = {
                            anchor = "ANCHOR_TOP",
                            owner = frame,
                            text = f.white(L("CRAFT_QUEUE_PATRON_ORDERS_MAX_COST_TOOLTIP") .. GUTIL:FormatMoney(1000000, false, nil, false, false)),
                        },
                        onValueValidCallback = function(input)
                            CraftSim.DB.OPTIONS:Save("CRAFTQUEUE_QUEUE_PATRON_ORDERS_MAX_COST",
                                tonumber(input.total))
                        end,
                    }
                end, 210, 25, "CRAFTQUEUE_QUEUE_PATRON_ORDERS_MAX_COST_INPUT")

                GUTIL:CreateReuseableMenuUtilContextMenuFrame(patronOrderOptions, function(frame)
                    frame.label = GGUI.Text {
                        parent = frame,
                        anchorPoints = { { anchorParent = frame, anchorA = "LEFT", anchorB = "LEFT" } },
                        text = L("CRAFT_QUEUE_PATRON_ORDERS_REAGENT_BAG_VALUE"),
                        justifyOptions = { type = "H", align = "LEFT" },
                    }
                    frame.input = GGUI.CurrencyInput {
                        parent = frame, anchorParent = frame,
                        sizeX = 60, sizeY = 25, offsetX = 5,
                        anchorA = "RIGHT", anchorB = "RIGHT",
                        initialValue = CraftSim.DB.OPTIONS:Get("CRAFTQUEUE_QUEUE_PATRON_ORDERS_REAGENT_BAG_VALUE"),
                        borderAdjustWidth = 1,
                        minValue = 0.94,
                        tooltipOptions = {
                            anchor = "ANCHOR_TOP",
                            owner = frame,
                            text = f.white(L("CRAFT_QUEUE_PATRON_ORDERS_REAGENT_BAG_VALUE_TOOLTIP") .. GUTIL:FormatMoney(1000000, false, nil, false, false)),
                        },
                        onValueValidCallback = function(input)
                            CraftSim.DB.OPTIONS:Save("CRAFTQUEUE_QUEUE_PATRON_ORDERS_REAGENT_BAG_VALUE",
                                tonumber(input.total))
                        end,
                    }
                end, 210, 25, "CRAFTQUEUE_QUEUE_PATRON_ORDERS_REAGENT_BAG_VALUE_INPUT")

                patronOrderOptions:CreateDivider()

                local includeMoxieProfitCB = patronOrderOptions:CreateCheckbox(
                    L("CRAFT_QUEUE_PATRON_ORDERS_INCLUDE_MOXIE_IN_PROFIT_CHECKBOX"),
                    function()
                        return CraftSim.DB.OPTIONS:Get("CRAFTQUEUE_QUEUE_PATRON_ORDERS_INCLUDE_MOXIE_IN_PROFIT")
                    end, function()
                        local value = CraftSim.DB.OPTIONS:Get("CRAFTQUEUE_QUEUE_PATRON_ORDERS_INCLUDE_MOXIE_IN_PROFIT")
                        CraftSim.DB.OPTIONS:Save("CRAFTQUEUE_QUEUE_PATRON_ORDERS_INCLUDE_MOXIE_IN_PROFIT", not value)
                    end)

                includeMoxieProfitCB:SetTooltip(function(tooltip, elementDescription)
                    GameTooltip_AddInstructionLine(tooltip,
                        L("CRAFT_QUEUE_PATRON_ORDERS_INCLUDE_MOXIE_IN_PROFIT_TOOLTIP"));
                end);

                local autoUpdateMoxieValuesCB = patronOrderOptions:CreateCheckbox(
                    L("CRAFT_QUEUE_PATRON_ORDERS_AUTO_UPDATE_MOXIE_VALUES_CHECKBOX"),
                    function()
                        return CraftSim.DB.OPTIONS:Get(moxieAutoUpdateOptionKey)
                    end, function()
                        local value = CraftSim.DB.OPTIONS:Get(moxieAutoUpdateOptionKey)
                        local enabled = not value
                        CraftSim.DB.OPTIONS:Save(moxieAutoUpdateOptionKey, enabled)
                        if enabled then
                            CraftSim.CRAFTQ.UI:AutoUpdatePatronMoxieValuesFromSurplus()
                        end
                    end)

                autoUpdateMoxieValuesCB:SetTooltip(function(tooltip, elementDescription)
                    GameTooltip_AddInstructionLine(tooltip,
                        L("CRAFT_QUEUE_PATRON_ORDERS_AUTO_UPDATE_MOXIE_VALUES_TOOLTIP"));
                end);

                -- 210x20 matches MenuUtil checkbox row height (custom inputs above stay 25px tall).
                GUTIL:CreateReuseableMenuUtilContextMenuFrame(patronOrderOptions, function(menuRowFrame)
                    local function openPatronMoxieValues()
                        CraftSim.CRAFTQ.UI:ShowPatronRewardValuesFrame()
                        if CloseMenus then
                            CloseMenus()
                        end
                    end

                    local hit = CreateFrame("Frame", nil, menuRowFrame)
                    hit:SetAllPoints(menuRowFrame)
                    hit:EnableMouse(true)
                    menuRowFrame:SetClipsChildren(true)

                    local hl = hit:CreateTexture(nil, "ARTWORK")
                    hl:SetTexture("Interface/QuestFrame/UI-QuestTitleHighlight")
                    hl:SetBlendMode("ADD")
                    hl:SetAlpha(0.9)
                    hl:SetVertexColor(1, 0.92, 0.62)
                    hl:SetPoint("TOPLEFT", hit, "TOPLEFT", -10, 0)
                    hl:SetPoint("BOTTOMRIGHT", hit, "BOTTOMRIGHT", 10, 0)
                    hl:Hide()

                    hit:SetScript("OnEnter", function()
                        hl:Show()
                    end)
                    hit:SetScript("OnLeave", function()
                        hl:Hide()
                    end)
                    hit:SetScript("OnMouseUp", function(_, btn)
                        if btn == "LeftButton" then
                            openPatronMoxieValues()
                        end
                    end)

                    GGUI.Text({
                        parent = hit,
                        anchorPoints = { { anchorParent = hit, anchorA = "LEFT", anchorB = "LEFT" } },
                        text = L("CRAFT_QUEUE_PATRON_REWARD_VALUES_MENU_BUTTON"),
                        justifyOptions = { type = "H", align = "LEFT" },
                    })
                end, 210, 20, "CRAFTQUEUE_PATRON_REWARD_VALUES_MENU_ROW")
            end
        }

        ---@type GGUI.Button
        queueTab.content.clearAllButton = GGUI.Button({
            parent = queueTab.content,
            anchorParent = queueTab.content.addWorkOrdersButton.frame,
            anchorA = "TOPLEFT",
            anchorB = "BOTTOMLEFT",
            offsetY = 0,
            sizeX = fixedButtonWidth,
            label = f.l(L("CRAFT_QUEUE_CLEAR_ALL_BUTTON_LABEL")),
            clickCallback = function()
                CraftSim.CRAFTQ:ClearAll()
            end
        })

        ---@type GGUI.Button
        queueTab.content.craftNextButton = GGUI.Button({
            parent = queueTab.content,
            anchorParent = queueTab.content.craftList.frame,
            anchorA = "TOPRIGHT",
            anchorB = "BOTTOMRIGHT",
            offsetY = craftQueueButtonsOffsetY,
            offsetX = 0,
            adjustWidth = true,
            label = L("CRAFT_QUEUE_CRAFT_NEXT_BUTTON_LABEL"),
            clickCallback = nil,
        })

        if select(2, C_AddOns.IsAddOnLoaded(CraftSim.CONST.SUPPORTED_PRICE_API_ADDONS[2])) then
            ---@type GGUI.Button
            queueTab.content.createAuctionatorShoppingList = GGUI.Button({
                parent = queueTab.content,
                anchorParent = queueTab.content,
                anchorA = "BOTTOM",
                anchorB = "BOTTOM",
                adjustWidth = true,
                sizeX = 15,
                offsetY = -2,
                offsetX = 5,
                clickCallback = function()
                    CraftSim.CRAFTQ:CreateAuctionatorShoppingList()
                end,
                label = L("CRAFTQUEUE_AUCTIONATOR_SHOPPING_LIST_BUTTON_LABEL")
            })
        end

        -- summaries

        queueTab.content.totalAverageProfitLabel = GGUI.Text({
            parent = queueTab.content,
            anchorParent = queueTab.content.craftList.frame,
            scale = 0.95,
            anchorA = "TOP",
            anchorB = "BOTTOM",
            offsetX = 0,
            offsetY = -15,
            text = L("CRAFT_QUEUE_TOTAL_PROFIT_LABEL"),
            justifyOptions = { type = "H", align = "RIGHT" }
        })
        queueTab.content.totalAverageProfit = GGUI.Text({
            parent = queueTab.content,
            anchorParent = queueTab.content.totalAverageProfitLabel.frame,
            scale = 1,
            anchorA = "LEFT",
            anchorB = "RIGHT",
            offsetX = 5,
            text = CraftSim.UTIL:FormatMoney(0, true),
            justifyOptions = { type = "H", align = "LEFT" }
        })
        queueTab.content.totalCraftingCostsLabel = GGUI.Text({
            parent = queueTab.content,
            anchorParent = queueTab.content.totalAverageProfitLabel.frame,
            scale = 0.95,
            anchorA = "TOPRIGHT",
            anchorB = "BOTTOMRIGHT",
            offsetY = -19,
            text = L("CRAFT_QUEUE_TOTAL_CRAFTING_COSTS_LABEL"),
            justifyOptions = { type = "H", align = "RIGHT" }
        })
        queueTab.content.totalCraftingCosts = GGUI.Text({
            parent = queueTab.content,
            anchorParent = queueTab.content.totalCraftingCostsLabel.frame,
            scale = 1,
            anchorA = "LEFT",
            anchorB = "RIGHT",
            offsetX = 5,
            text = CraftSim.UTIL:FormatMoney(0, true),
            justifyOptions = { type = "H", align = "RIGHT" }
        })

        queueTab.content.editRecipeFrame = CraftSim.CRAFTQ.UI:InitEditRecipeFrame(queueTab.content, frame.content)

        CraftSim.CRAFTQ.UI:InitCraftListsTab(craftListsTab, frame)

        self:InitializeQuickAccessBar(frame)


        local auctionatorHelpPanelDef
        if select(2, C_AddOns.IsAddOnLoaded(CraftSim.CONST.SUPPORTED_PRICE_API_ADDONS[2])) then
            auctionatorHelpPanelDef =
            {
                button = {
                    frame = queueTab.content.createAuctionatorShoppingList.frame,
                    includeFrameWidth = true,
                    offsetX = 5,
                    offsetY = 10,
                },
                highlight = {
                    frame = queueTab.content.createAuctionatorShoppingList.frame,
                    offsetX = -4,
                    offsetY = 4,
                    extraWidth = 8,
                    extraHeight = 8,
                },
                toolTipDir = "RIGHT",
                toolTipText = L("CRAFT_QUEUE_TUTORIAL_SHOPPING_LIST_TOOLTIP"),
            }
        end

        frame.content.queueTutorialButton = GGUI.TutorialButton({
            parent = frame.content,
            anchorPoints = {
                {
                    anchorParent = frame.content,
                    anchorA = "TOPRIGHT",
                    anchorB = "TOPRIGHT",
                    offsetX = -70,
                    offsetY = 5,
                },
            },
            scale = 0.7,
            glowOnInit = false,
            autoToggleMode = "helpPlate",
            helpPlateParent = queueTab.content,
            helpPlateDefinition = {
                parent = queueTab.content,
                steps = {
                    {
                        button = {
                            offsetX = queueTab.content.craftList.frame:GetWidth() / 2,
                            offsetY = -queueTab.content.craftList.frame:GetHeight() / 2 + 20,
                            frame = queueTab.content.craftList.frame,
                        },
                        highlight = {
                            frame = queueTab.content.craftList.frame,
                            offsetX = 0,
                            offsetY = 0,
                            extraWidth = 20,
                            extraHeight = 0,
                        },
                        toolTipDir = "LEFT",
                        toolTipText = L("CRAFT_QUEUE_TUTORIAL_QUEUE_LIST_TOOLTIP"),
                    },
                    {
                        button = {
                            frame = queueTab.content.craftNextButton.frame,
                            includeFrameWidth = true,
                            offsetX = 5,
                            offsetY = 8,
                        },
                        highlight = {
                            frame = queueTab.content.craftNextButton.frame,
                            offsetX = -4,
                            offsetY = 4,
                            extraWidth = 8,
                            extraHeight = 8,
                        },
                        toolTipDir = "RIGHT",
                        toolTipText = L("CRAFT_QUEUE_TUTORIAL_CRAFT_NEXT_TOOLTIP"),
                    },
                    {
                        button = {
                            frame = queueTab.content.queueCraftListsButton.frame,
                            includeFrameWidth = true,
                            offsetX = 30,
                            offsetY = -30,
                        },
                        highlight = {
                            frame = queueTab.content.queueCraftListsButton.frame,
                            offsetX = -4,
                            offsetY = 4,
                            extraWidth = 35,
                            extraHeight = 85,
                        },
                        toolTipDir = "RIGHT",
                        toolTipText = L("CRAFT_QUEUE_TUTORIAL_QUEUE_BUTTONS_TOOLTIP"),
                    },
                    {
                        button = {
                            frame = queueTab.content.quickBarFrame.frame,
                            includeFrameWidth = true,
                            offsetX = 50,
                            offsetY = -8,
                        },
                        highlight = {
                            frame = queueTab.content.quickBarFrame.frame,
                            offsetX = -4,
                            offsetY = -5,
                            extraWidth = 60,
                            extraHeight = -15,
                        },
                        toolTipDir = "RIGHT",
                        toolTipText = L("CRAFT_QUEUE_TUTORIAL_QUICK_ACCESS_BAR_TOOLTIP"),
                    },
                    {
                        button = {
                            frame = frame.content.craftQueueOptionsButton.frame,
                            includeFrameWidth = true,
                            offsetX = 5,
                            offsetY = 10,
                        },
                        highlight = {
                            frame = frame.content.craftQueueOptionsButton.frame,
                            offsetX = -4,
                            offsetY = 4,
                            extraWidth = 8,
                            extraHeight = 8,
                        },
                        toolTipDir = "RIGHT",
                        toolTipText = L("CRAFT_QUEUE_TUTORIAL_CRAFT_QUEUE_OPTIONS_TOOLTIP"),
                    },
                    auctionatorHelpPanelDef
                },
            },
        })
    end

    createContent(CraftSim.CRAFTQ.frame)

    CraftSim.CRAFTQ.UI:InitPatronRewardValuesFrame()

    -- add to queue button in crafting ui
    CraftSim.CRAFTQ.queueRecipeButton = GGUI.Button {
        parent = ProfessionsFrame.CraftingPage.SchematicForm,
        anchorPoints = { {
            anchorParent = ProfessionsFrame.CraftingPage.SchematicForm.TrackRecipeCheckbox,
            anchorA = "RIGHT", anchorB = "LEFT", offsetX = -18, offsetY = -19,
        } },
        adjustWidth = true,
        sizeX = 15,
        label = "+ CraftQueue",
        tooltipOptions = {
            anchor = "ANCHOR_CURSOR_RIGHT",
            text = CreateAtlasMarkup("NPE_LeftClick", 20, 20, 2) .. " + Shift to " .. f.g("optimize") .. " recipe before adding it to the queue",
        },
        clickCallback = function(_, _)
            CraftSim.CRAFTQ:QueueOpenRecipe()
        end,
    }

    CraftSim.CRAFTQ.queueRecipeButtonOptions = CraftSim.WIDGETS.OptimizationOptions {
        parent = ProfessionsFrame.CraftingPage.SchematicForm,
        anchorPoints = { {
            anchorParent = CraftSim.CRAFTQ.queueRecipeButton.frame,
            anchorA = "LEFT", anchorB = "RIGHT", offsetX = 5,
        } },
        optimizationOptionsID = CraftSim.CONST.OPTIMIZATION_OPTIONS_IDS.CRAFTQUEUE_ADD_RECIPE,
        showOptions = {
            AUTOSELECT_TOP_PROFIT_QUALITY = true,
            OPTIMIZE_PROFESSION_TOOLS     = true,
            OPTIMIZE_CONCENTRATION        = true,
        },
        defaults = {
            AUTOSELECT_TOP_PROFIT_QUALITY = true,
            OPTIMIZE_PROFESSION_TOOLS     = true,
            OPTIMIZE_CONCENTRATION        = true,
        },
        recipeDataProvider = function()
            return CraftSim.MODULES.recipeData
        end,
    }

    -- add to queue button in crafting ui for work orders
    CraftSim.CRAFTQ.queueRecipeButtonWO = GGUI.Button {
        parent = ProfessionsFrame.OrdersPage.OrderView.OrderDetails.SchematicForm,
        anchorPoints = { {
            anchorParent = ProfessionsFrame.OrdersPage.OrderView.OrderDetails.SchematicForm.TrackRecipeCheckbox,
            anchorA = "RIGHT", anchorB = "LEFT", offsetX = -15,
        } },
        adjustWidth = true,
        sizeX = 15,
        label = "+ CraftQueue",
        clickCallback = function(_, _)
            CraftSim.CRAFTQ:QueueOpenRecipe()
        end,
    }

    CraftSim.CRAFTQ.queueRecipeButtonOptionsWO = CraftSim.WIDGETS.OptimizationOptions {
        parent = ProfessionsFrame.OrdersPage.OrderView.OrderDetails.SchematicForm,
        anchorPoints = { {
            anchorParent = CraftSim.CRAFTQ.queueRecipeButtonWO.frame,
            anchorA = "LEFT", anchorB = "RIGHT", offsetX = 5,
        } },
        optimizationOptionsID = CraftSim.CONST.OPTIMIZATION_OPTIONS_IDS.CRAFTQUEUE_ADD_RECIPE,
        showOptions = {
            AUTOSELECT_TOP_PROFIT_QUALITY = true,
            OPTIMIZE_PROFESSION_TOOLS     = true,
            OPTIMIZE_CONCENTRATION        = true,
        },
        defaults = {
            AUTOSELECT_TOP_PROFIT_QUALITY = true,
            OPTIMIZE_PROFESSION_TOOLS     = true,
            OPTIMIZE_CONCENTRATION        = true,
        },
        recipeDataProvider = function()
            return CraftSim.MODULES.recipeData
        end,
    }

    CraftSim.CRAFTQ.frame:HookScript("OnShow", function()
        RunNextFrame(function()
            if CraftSim.CRAFTQ.frame:IsVisible() then
                CraftSim.CRAFTQ.UI:UpdateDisplay()
            end
        end)
    end)
end

---@param craftListsTab CraftSim.CraftQueue.CraftListsTab
---@param parentFrame CraftSim.CraftQueue.Frame
function CraftSim.CRAFTQ.UI:InitCraftListsTab(craftListsTab, parentFrame)
    ---@class CraftSim.CraftQueue.CraftListsTab.Content
    local content = craftListsTab.content

    -- Selected list state
    ---@type number?
    content.selectedListID = nil
    ---@type boolean
    content.selectedListIsGlobal = false

    local recipesPanelWidth = 330
    local panelHeight = 265

    -- ===== LEFT PANEL: Craft Lists =====

    ---@type GGUI.FrameList
    content.craftListsList = GGUI.FrameList {
        parent = content,
        anchorParent = content,
        anchorA = "TOPLEFT",
        anchorB = "TOPLEFT",
        offsetX = 5,
        offsetY = 0,
        sizeY = panelHeight,
        showBorder = true,
        selectionOptions = {
            hoverRGBA = { 1, 1, 1, 0.1 },
            selectedRGBA = { 0.3, 0.7, 1, 0.3 },
            selectionCallback = function(row, userInput, alreadySelected)
                if not row.listID then return end
                if IsMouseButtonDown("RightButton") then
                    -- show context menu for list
                    CraftSim.WIDGETS.ContextMenu.Open(row.frame, {
                        {
                            type = "button",
                            label = L("CRAFT_LISTS_EXPORT_BUTTON_LABEL"),
                            onClick = function()
                                local crafterUID = CraftSim.UTIL:GetPlayerCrafterUID()
                                local exportString = CraftSim.DB.CRAFT_LISTS:ExportList(
                                    row.listID, crafterUID)
                                if exportString == "" then return end
                                CraftSim.UTIL:ShowTextCopyBox(exportString)
                            end
                        },
                        {
                            type = "button",

                            label = L("CRAFT_LISTS_RENAME_BUTTON_LABEL"),
                            onClick = function()
                                local crafterUID = CraftSim.UTIL:GetPlayerCrafterUID()
                                local currentList = CraftSim.DB.CRAFT_LISTS:GetList(
                                    row.listID, crafterUID)
                                CraftSim.CRAFTQ.UI:ShowCraftListNamePopup(
                                    L("CRAFT_LISTS_RENAME_POPUP_TITLE"),
                                    currentList and currentList.name or "",
                                    row.isGlobal,
                                    function(name, isGlobal)
                                        if name and name ~= "" then
                                            CraftSim.DB.CRAFT_LISTS:RenameList(
                                                row.listID, name, crafterUID)
                                            CraftSim.CRAFTQ.UI:UpdateCraftListsDisplay()
                                        end
                                    end, true)
                            end
                        },
                        {
                            type = "button",
                            label = L("CRAFT_LISTS_DELETE_BUTTON_LABEL"),
                            onClick = function()
                                if not content.selectedListID then return end
                                local crafterUID = CraftSim.UTIL:GetPlayerCrafterUID()
                                CraftSim.DB.CRAFT_LISTS:DeleteList(
                                    row.listID, crafterUID)
                                content.selectedListID = nil
                                content.selectedListIsGlobal = false
                                CraftSim.CRAFTQ.UI:UpdateCraftListsDisplay()
                                CraftSim.CRAFTQ.UI:UpdateCraftListsRecipeDisplay()
                            end
                        },
                    })
                elseif IsMouseButtonDown("LeftButton") then
                    -- select list and show recipes
                    content.selectedListID = row.listID
                    content.selectedListIsGlobal = row.isGlobal
                    CraftSim.CRAFTQ.UI:UpdateCraftListsRecipeDisplay()
                elseif IsMouseButtonDown("MiddleButton") then
                    local crafterUID = CraftSim.UTIL:GetPlayerCrafterUID()
                    CraftSim.DB.CRAFT_LISTS:DeleteList(
                        row.listID, crafterUID)
                    content.selectedListID = nil
                    content.selectedListIsGlobal = false
                    CraftSim.CRAFTQ.UI:UpdateCraftListsDisplay()
                    CraftSim.CRAFTQ.UI:UpdateCraftListsRecipeDisplay()
                end
            end,
        },
        columnOptions = {
            {
                label = L("CRAFT_LISTS_LIST_NAME_HEADER"),
                width = 300,
            },
            {
                label = L("CRAFT_LISTS_LIST_TYPE_HEADER"),
                width = 70,
                justifyOptions = { type = "H", align = "CENTER" },
            },
        },
        rowConstructor = function(columns, row)
            local nameColumn = columns[1]
            local typeColumn = columns[2]

            nameColumn.text = GGUI.Text {
                parent = nameColumn,
                anchorParent = nameColumn,
                anchorA = "LEFT",
                anchorB = "LEFT",
                justifyOptions = { type = "H", align = "LEFT" },
                scale = 0.9,
                fixedWidth = nameColumn:GetWidth() - 2,
                wrap = false,
                offsetX = 5,
            }

            typeColumn.text = GGUI.Text {
                parent = typeColumn,
                anchorParent = typeColumn,
                scale = 0.8,
                justifyOptions = { type = "H", align = "CENTER" },
            }
        end,
    }

    -- Buttons below the list panel
    local buttonOffsetY = -3

    content.createListButton = GGUI.Button {
        parent = content,
        anchorParent = content.craftListsList.frame,
        anchorA = "TOPLEFT",
        anchorB = "BOTTOMLEFT",
        offsetY = buttonOffsetY,
        offsetX = 0,
        adjustWidth = true,
        label = L("CRAFT_LISTS_CREATE_BUTTON_LABEL"),
        clickCallback = function()
            -- Show popup to enter list name
            CraftSim.CRAFTQ.UI:ShowCraftListNamePopup(
                L("CRAFT_LISTS_CREATE_POPUP_TITLE"),
                "",
                false, -- not global by default
                function(name, isGlobal)
                    if name and name ~= "" then
                        local crafterUID = CraftSim.UTIL:GetPlayerCrafterUID()
                        CraftSim.DB.CRAFT_LISTS:CreateList(name, isGlobal, crafterUID)
                        CraftSim.CRAFTQ.UI:UpdateCraftListsDisplay()
                    end
                end)
        end,
    }

    content.importListButton = GGUI.Button {
        parent = content,
        anchorParent = content.createListButton.frame,
        anchorA = "LEFT",
        anchorB = "RIGHT",
        offsetX = 3,
        adjustWidth = true,
        label = L("CRAFT_LISTS_IMPORT_BUTTON_LABEL"),
        tooltipOptions = {
            anchor = "ANCHOR_TOP",
            text = "Right-click for more Import Options",
        },
        clickCallback = function()
            if IsMouseButtonDown("LeftButton") then
                CraftSim.CRAFTQ.UI:ShowCraftListImportPopup(function(importString, isGlobal)
                    if importString and importString ~= "" then
                        local crafterUID = CraftSim.UTIL:GetPlayerCrafterUID()
                        local success = CraftSim.DB.CRAFT_LISTS:ImportList(importString, isGlobal, crafterUID)
                        if success then
                            CraftSim.CRAFTQ.UI:UpdateCraftListsDisplay()
                        else
                            CraftSim.DEBUG:SystemPrint(f.r("Failed to import craft list!"))
                        end
                    end
                end)
            elseif IsMouseButtonDown("RightButton") then
                CraftSim.WIDGETS.ContextMenu.Open(content.importListButton.frame, {
                    {
                        type = "button",
                        label = "Import " .. f.bb("Favorites"),
                        onClick = function()
                            local crafterUID = CraftSim.UTIL:GetPlayerCrafterUID()
                            local favoriteRecipes = CraftSim.DB.CRAFTER:GetFavoriteRecipeProfessions(CraftSim.UTIL
                                :GetPlayerCrafterUID())
                            local totalFavorites = 0
                            for _, recipeIDList in pairs(favoriteRecipes or {}) do
                                totalFavorites = totalFavorites + #recipeIDList
                            end
                            if favoriteRecipes and totalFavorites > 0 then
                                local newList = CraftSim.DB.CRAFT_LISTS:CreateList(crafterUID .. " Favorites", false,
                                    crafterUID)
                                for profession, recipeIDList in pairs(favoriteRecipes) do
                                    for _, recipeID in ipairs(recipeIDList) do
                                        CraftSim.DB.CRAFT_LISTS:AddRecipe(newList.id, crafterUID, recipeID)
                                    end
                                end
                            end
                            CraftSim.CRAFTQ.UI:UpdateCraftListsDisplay()
                        end
                    },
                })
            end
        end,
    }

    -- ===== RIGHT PANEL: Recipes in Selected List =====

    content.recipeList = GGUI.FrameList {
        parent = content,
        anchorParent = content.craftListsList.frame,
        anchorA = "TOPLEFT",
        anchorB = "TOPRIGHT",
        offsetX = 30,
        offsetY = 0,
        sizeY = panelHeight,
        showBorder = true,
        selectionOptions = {
            hoverRGBA = { 1, 1, 1, 0.1 },
            selectedRGBA = { 1, 0.3, 0.3, 0.2 },
            selectionCallback = function(row, userInput, alreadySelected)
                if IsMouseButtonDown("MiddleButton") then
                    local crafterUID = CraftSim.UTIL:GetPlayerCrafterUID()
                    CraftSim.DB.CRAFT_LISTS:RemoveRecipe(
                        content.selectedListID,
                        crafterUID,
                        row.recipeID)
                    CraftSim.CRAFTQ.UI:UpdateCraftListsRecipeDisplay()
                elseif IsMouseButtonDown("RightButton") then
                    -- show context menu for recipe
                    local crafterUID = CraftSim.UTIL:GetPlayerCrafterUID()
                    local recipeEntry = CraftSim.DB.CRAFT_LISTS:GetRecipeEntry(
                        content.selectedListID,
                        crafterUID,
                        row.recipeID)
                    CraftSim.WIDGETS.ContextMenu.Open(row.frame, {
                        {
                            type = "custom",
                            build = function(rootDescription)
                                GUTIL:CreateReuseableMenuUtilContextMenuFrame(rootDescription, function(frame)
                                        frame.label = GGUI.Text {
                                            parent = frame,
                                            anchorPoints = { { anchorParent = frame, anchorA = "LEFT", anchorB = "LEFT" } },
                                            text = L("CRAFT_LISTS_RECIPE_RESTOCK_SET_MAX"),
                                            justifyOptions = { type = "H", align = "LEFT" },
                                        }
                                        frame.input = GGUI.NumericInput {
                                            parent = frame, anchorParent = frame,
                                            sizeX = 60, sizeY = 25, offsetX = 5,
                                            anchorA = "RIGHT", anchorB = "RIGHT",
                                            initialValue = recipeEntry and recipeEntry.restockMaxAmount or 0,
                                            borderAdjustWidth = 1,
                                            minValue = 0,
                                            tooltipOptions = {
                                                anchor = "ANCHOR_TOP",
                                                owner = frame,
                                                text = L("CRAFT_LISTS_RECIPE_RESTOCK_POPUP_HINT"),
                                            },
                                            onNumberValidCallback = function(input)
                                                local maxAmount = input.currentValue
                                                CraftSim.DB.CRAFT_LISTS:SetRecipeRestockOptions(
                                                    content.selectedListID,
                                                    crafterUID,
                                                    row.recipeID,
                                                    maxAmount)
                                                CraftSim.CRAFTQ.UI:UpdateCraftListsRecipeDisplay()
                                            end
                                        }
                                    end, 100, 20,
                                    "CRAFT_LIST_RECIPE_RESTOCK_CONTEXT_INPUT:" ..
                                    content.selectedListID .. ":" .. row.recipeID)
                            end
                        },
                        {
                            type = "button",
                            label = f.r("Remove Recipe"),
                            onClick = function()
                                local crafterUID = CraftSim.UTIL:GetPlayerCrafterUID()
                                CraftSim.DB.CRAFT_LISTS:RemoveRecipe(
                                    content.selectedListID,
                                    crafterUID,
                                    row.recipeID)
                                CraftSim.CRAFTQ.UI:UpdateCraftListsRecipeDisplay()
                            end
                        },
                    })
                end
            end,
        },
        columnOptions = {
            {
                label = L("CRAFT_LISTS_RECIPE_NAME_HEADER"),
                width = recipesPanelWidth,
            },
        },
        rowConstructor = function(columns, row)
            local nameColumn = columns[1]
            nameColumn.text = GGUI.Text {
                parent = nameColumn,
                anchorParent = nameColumn,
                anchorA = "LEFT",
                anchorB = "LEFT",
                justifyOptions = { type = "H", align = "LEFT" },
                scale = 0.9,
                fixedWidth = nameColumn:GetWidth() - 2,
                wrap = false,
                offsetX = 5,
            }
        end,
    }

    content.selectedListLabel = GGUI.Text {
        parent = content,
        anchorParent = content.recipeList.frame,
        anchorA = "BOTTOM",
        anchorB = "TOP",
        offsetY = 5,
        text = L("CRAFT_LISTS_NO_LIST_SELECTED"),
        scale = 1.0,
    }

    content.addRecipeButton = GGUI.Button {
        parent = content,
        anchorParent = content.recipeList.frame,
        anchorA = "TOPLEFT",
        anchorB = "BOTTOMLEFT",
        offsetY = buttonOffsetY,
        adjustWidth = true,
        label = L("CRAFT_LISTS_ADD_RECIPE_BUTTON_LABEL"),
        clickCallback = function()
            if not content.selectedListID then return end
            local recipeData = CraftSim.MODULES.recipeData
            if not recipeData then
                CraftSim.DEBUG:SystemPrint(f.r("No recipe open!"))
                return
            end
            local recipeInfo = recipeData.recipeInfo
            if recipeInfo and (recipeInfo.isDummyRecipe or recipeInfo.isGatheringRecipe
                    or recipeInfo.isRecraft or recipeInfo.isSalvageRecipe) then
                CraftSim.DEBUG:SystemPrint(f.r("This recipe type cannot be added to a Craft List!"))
                return
            end
            local crafterUID = CraftSim.UTIL:GetPlayerCrafterUID()
            CraftSim.DB.CRAFT_LISTS:AddRecipe(
                content.selectedListID,
                crafterUID,
                recipeData.recipeID)
            CraftSim.CRAFTQ.UI:UpdateCraftListsRecipeDisplay()
        end,
    }

    content.listOptionsButton = CraftSim.WIDGETS.OptionsButton {
        parent = content,
        anchorPoints = { { anchorParent = content.addRecipeButton.frame, anchorA = "LEFT", anchorB = "RIGHT", offsetX = 3 } },
        tooltipOptions = {
            anchor = "ANCHOR_TOP",
            text = "Configure the " .. f.bb("selected") .. " Craft List",
        },
        menuUtilCallback = function(ownerRegion, rootDescription)
            if not content.selectedListID then
                rootDescription:CreateTitle(f.grey("No list selected"))
                return
            end
            local crafterUID = CraftSim.UTIL:GetPlayerCrafterUID()
            local list = CraftSim.DB.CRAFT_LISTS:GetList(
                content.selectedListID,
                crafterUID)
            if not list then return end

            list.options = list.options or CraftSim.DB.CRAFT_LISTS.DefaultOptions()
            local opts = list.options

            rootDescription:CreateTitle(f.bb(list.name) .. " Options:")

            rootDescription:CreateCheckbox(
                L("CRAFT_LISTS_OPTIONS_ENABLE_CONCENTRATION"),
                function() return opts.enableConcentration end,
                function() opts.enableConcentration = not opts.enableConcentration end)

            rootDescription:CreateCheckbox(
                L("CRAFT_LISTS_OPTIONS_ENABLE_UNLEARNED"),
                function() return opts.enableUnlearned end,
                function() opts.enableUnlearned = not opts.enableUnlearned end)

            rootDescription:CreateCheckbox(
                L("CRAFT_QUEUE_ADD_WORK_ORDERS_ONLY_PROFITABLE_CHECKBOX"),
                function() return opts.onlyProfitable end,
                function() opts.onlyProfitable = not opts.onlyProfitable end)

            local optimizationButton = rootDescription:CreateButton("Optimization")

            -- Reagent Allocation submenu
            local RA = CraftSim.RECIPE_SCAN.SCAN_MODES
            local reagentAllocationButton = optimizationButton:CreateButton(L("CRAFT_LISTS_OPTIONS_REAGENT_ALLOCATION"))

            reagentAllocationButton:CreateRadio(
                L("RECIPE_SCAN_REAGENT_ALLOCATION_Q1") ..
                " " .. GUTIL:GetQualityIconString(1, 20, 20) .. " | " .. GUTIL:GetQualityIconStringSimplified(1, 20, 20),
                function() return (opts.reagentAllocation or "OPTIMIZE_HIGHEST") == RA.Q1 end,
                function() opts.reagentAllocation = RA.Q1 end)
            reagentAllocationButton:CreateRadio(
                L("RECIPE_SCAN_REAGENT_ALLOCATION_Q2") ..
                " " .. GUTIL:GetQualityIconString(2, 20, 20) .. " | " .. GUTIL:GetQualityIconStringSimplified(2, 20, 20),
                function() return (opts.reagentAllocation or "OPTIMIZE_HIGHEST") == RA.Q2 end,
                function() opts.reagentAllocation = RA.Q2 end)
            reagentAllocationButton:CreateRadio(
                L("RECIPE_SCAN_REAGENT_ALLOCATION_Q3") .. " " .. GUTIL:GetQualityIconString(3, 20, 20),
                function() return (opts.reagentAllocation or "OPTIMIZE_HIGHEST") == RA.Q3 end,
                function() opts.reagentAllocation = RA.Q3 end)

            -- Optimize sub-submenu
            local reagentAllocationOptimizeButton = reagentAllocationButton:CreateButton(L("RECIPE_SCAN_MODE_OPTIMIZE"))

            reagentAllocationOptimizeButton:CreateRadio(
                L("CRAFT_LISTS_OPTIONS_REAGENT_ALLOCATION_OPTIMIZE_HIGHEST"),
                function()
                    local ra = opts.reagentAllocation or "OPTIMIZE_HIGHEST"
                    return ra == "OPTIMIZE_HIGHEST" or ra == "OPTIMIZE"
                end,
                function() opts.reagentAllocation = "OPTIMIZE_HIGHEST" end)

            reagentAllocationOptimizeButton:CreateRadio(
                L("CRAFT_LISTS_OPTIONS_REAGENT_ALLOCATION_OPTIMIZE_MOST_PROFITABLE"),
                function() return (opts.reagentAllocation or "OPTIMIZE_HIGHEST") == "OPTIMIZE_MOST_PROFITABLE" end,
                function() opts.reagentAllocation = "OPTIMIZE_MOST_PROFITABLE" end)

            -- Target Quality sub-submenu
            local targetQualityButton = reagentAllocationOptimizeButton:CreateButton(
                L("CRAFT_LISTS_OPTIONS_REAGENT_ALLOCATION_TARGET_QUALITY"))

            for i = 1, 5 do
                local qualityID = i
                local allocationValue = "OPTIMIZE_TARGET_" .. qualityID
                local qualityLabel = GUTIL:GetQualityIconString(qualityID, 20, 20)
                if qualityID <= 2 then
                    qualityLabel = qualityLabel .. " | " .. GUTIL:GetQualityIconStringSimplified(qualityID, 20, 20)
                end
                targetQualityButton:CreateRadio(
                    qualityLabel,
                    function() return (opts.reagentAllocation or "OPTIMIZE_HIGHEST") == allocationValue end,
                    function() opts.reagentAllocation = allocationValue end)
            end

            optimizationButton:CreateCheckbox(
                L("CRAFT_LISTS_OPTIONS_OPTIMIZE_CONCENTRATION"),
                function() return opts.optimizeConcentration end,
                function() opts.optimizeConcentration = not opts.optimizeConcentration end)

            optimizationButton:CreateCheckbox(
                L("CRAFT_LISTS_OPTIONS_OPTIMIZE_TOOLS"),
                function() return opts.optimizeProfessionTools end,
                function() opts.optimizeProfessionTools = not opts.optimizeProfessionTools end)

            optimizationButton:CreateCheckbox(
                L("CRAFT_LISTS_OPTIONS_OPTIMIZE_FINISHING"),
                function() return opts.optimizeFinishingReagents end,
                function() opts.optimizeFinishingReagents = not opts.optimizeFinishingReagents end)

            local FA = CraftSim.WIDGETS.OptimizationOptions.FINISHING_REAGENTS_ALGORITHM
            local finishingAlgorithmButton = optimizationButton:CreateButton(
                L("OPTIMIZATION_OPTIONS_FINISHING_REAGENTS_ALGORITHM"))

            local simpleRadio = finishingAlgorithmButton:CreateRadio(
                L("OPTIMIZATION_OPTIONS_FINISHING_REAGENTS_SIMPLE"),
                function() return (opts.finishingReagentsAlgorithm or FA.SIMPLE) ~= FA.PERMUTATION end,
                function() opts.finishingReagentsAlgorithm = FA.SIMPLE end)
            simpleRadio:SetTooltip(function(tooltip, _)
                GameTooltip_AddInstructionLine(tooltip,
                    L("OPTIMIZATION_OPTIONS_FINISHING_REAGENTS_SIMPLE_TOOLTIP"))
            end)

            local permutationRadio = finishingAlgorithmButton:CreateRadio(
                L("OPTIMIZATION_OPTIONS_FINISHING_REAGENTS_PERMUTATION"),
                function() return (opts.finishingReagentsAlgorithm or FA.SIMPLE) == FA.PERMUTATION end,
                function() opts.finishingReagentsAlgorithm = FA.PERMUTATION end)
            permutationRadio:SetTooltip(function(tooltip, _)
                GameTooltip_AddInstructionLine(tooltip,
                    L("OPTIMIZATION_OPTIONS_FINISHING_REAGENTS_PERMUTATION_TOOLTIP"))
            end)

            finishingAlgorithmButton:CreateCheckbox(
                L("CRAFT_LISTS_OPTIONS_INCLUDE_SOULBOUND"),
                function() return opts.includeSoulboundFinishingReagents end,
                function() opts.includeSoulboundFinishingReagents = not opts.includeSoulboundFinishingReagents end)

            local onlyHighestSBCB = finishingAlgorithmButton:CreateCheckbox(
                L("OPTIMIZATION_OPTIONS_ONLY_HIGHEST_QUALITY_SOULBOUND_FINISHING_REAGENTS"),
                function() return opts.onlyHighestQualitySoulboundFinishingReagents end,
                function()
                    opts.onlyHighestQualitySoulboundFinishingReagents = not opts
                        .onlyHighestQualitySoulboundFinishingReagents
                end)
            onlyHighestSBCB:SetTooltip(function(tooltip, _)
                GameTooltip_AddInstructionLine(tooltip,
                    L("OPTIMIZATION_OPTIONS_ONLY_HIGHEST_QUALITY_SOULBOUND_FINISHING_REAGENTS_TOOLTIP"))
            end)

            local restockingButton = rootDescription:CreateButton("Restocking")

            local subtractStockListCB = restockingButton:CreateCheckbox(
                L("CRAFT_LISTS_RESTOCK_SUBTRACT_OWNED_LABEL"),
                function()
                    return opts.subtractInventory
                end,
                function()
                    opts.subtractInventory = not opts.subtractInventory
                end)
            subtractStockListCB:SetTooltip(function(tooltip, _)
                GameTooltip_AddInstructionLine(tooltip, L("CRAFT_LISTS_RESTOCK_SUBTRACT_OWNED_TOOLTIP"))
            end)

            local offsetConCB = restockingButton:CreateCheckbox(
                L("CRAFT_LISTS_OPTIONS_OFFSET_CONCENTRATION"),
                function() return opts.offsetConcentrationCraftAmount end,
                function() opts.offsetConcentrationCraftAmount = not opts.offsetConcentrationCraftAmount end)
            offsetConCB:SetTooltip(function(tooltip)
                GameTooltip_AddInstructionLine(tooltip, L("CRAFT_LISTS_OPTIONS_OFFSET_CONCENTRATION_TOOLTIP"))
            end)

            local smartCB = restockingButton:CreateCheckbox(
                L("CRAFT_LISTS_OPTIONS_SMART_CONCENTRATION"),
                function() return opts.smartConcentrationQueuing end,
                function() opts.smartConcentrationQueuing = not opts.smartConcentrationQueuing end)
            smartCB:SetTooltip(function(tooltip)
                GameTooltip_AddInstructionLine(tooltip, L("CRAFT_LISTS_OPTIONS_SMART_CONCENTRATION_TOOLTIP"))
            end)

            -- Queue options
            GUTIL:CreateReuseableMenuUtilContextMenuFrame(restockingButton, function(frame)
                frame.label = GGUI.Text {
                    parent = frame,
                    anchorPoints = { { anchorParent = frame, anchorA = "LEFT", anchorB = "LEFT" } },
                    text = L("CRAFT_LISTS_OPTIONS_OFFSET_QUEUE_AMOUNT"),
                    justifyOptions = { type = "H", align = "LEFT" },
                }
                frame.input = GGUI.NumericInput {
                    parent = frame, anchorParent = frame,
                    sizeX = 30, sizeY = 25, offsetX = 5,
                    anchorA = "RIGHT", anchorB = "RIGHT",
                    initialValue = opts.offsetQueueAmount or 0,
                    borderAdjustWidth = 1.32,
                    minValue = 0,
                    tooltipOptions = {
                        anchor = "ANCHOR_TOP",
                        owner = frame,
                        text = L("CRAFT_LISTS_OPTIONS_OFFSET_QUEUE_AMOUNT_TOOLTIP"),
                    },
                    onNumberValidCallback = function(input)
                        opts.offsetQueueAmount = tonumber(input.currentValue) or 0
                    end,
                }
            end, 200, 25, "CRAFT_LISTS_OFFSET_QUEUE_AMOUNT_INPUT")


            -- TSM options
            if TSM_API then
                restockingButton:CreateDivider()
                local tsmButton = restockingButton:CreateButton(f.bb("TSM"))

                tsmButton:CreateCheckbox(
                    L("CRAFT_LISTS_OPTIONS_USE_TSM_RESTOCK"),
                    function() return opts.useTSMRestockExpression end,
                    function() opts.useTSMRestockExpression = not opts.useTSMRestockExpression end)

                GUTIL:CreateReuseableMenuUtilContextMenuFrame(tsmButton, function(frame)
                    if not frame.expressionLabel then
                        frame.expressionLabel = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
                        frame.expressionLabel:SetPoint("LEFT", frame, "LEFT", 5, 0)
                        frame.expressionLabel:SetText(L("CRAFT_LISTS_OPTIONS_TSM_EXPRESSION"))

                        frame.editBox = CreateFrame("EditBox", nil, frame, "InputBoxTemplate")
                        frame.editBox:SetSize(130, 20)
                        frame.editBox:SetPoint("CENTER", frame, "CENTER", 15, 0)
                        frame.editBox:SetAutoFocus(false)
                        frame.editBox:SetFontObject("ChatFontNormal")
                        frame.editBox:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
                        frame.editBox:SetScript("OnEnterPressed", function(self) self:ClearFocus() end)

                        frame.validationText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
                        frame.validationText:SetPoint("LEFT", frame.editBox, "RIGHT", 5, 0)
                    end

                    local currentExpr = opts.tsmRestockExpression or "1"
                    frame.editBox:SetText(currentExpr)

                    local function validateAndSave(expr)
                        if TSM_API.IsCustomPriceValid(expr) then
                            frame.validationText:SetText(CreateAtlasMarkup(CraftSim.CONST.ATLAS_TEXTURES.CHECKMARK, 18,
                                18))
                            opts.tsmRestockExpression = expr
                        else
                            frame.validationText:SetText(CreateAtlasMarkup(CraftSim.CONST.ATLAS_TEXTURES.CROSS, 18, 18))
                        end
                    end

                    validateAndSave(currentExpr)
                    -- Re-register on each open so the closure captures the current opts reference
                    frame.editBox:SetScript("OnTextChanged", function(self)
                        validateAndSave(self:GetText())
                    end)
                end, 230, 30, "CRAFT_LISTS_TSM_EXPRESSION_INPUT")
            end
        end,
    }
end

--- Update the craft lists display (left panel)
function CraftSim.CRAFTQ.UI:UpdateCraftListsDisplay()
    if not CraftSim.CRAFTQ.frame or not CraftSim.CRAFTQ.frame.content then return end
    local craftListsTab = CraftSim.CRAFTQ.frame.content.craftListsTab --[[@as CraftSim.CraftQueue.CraftListsTab?]]
    if not craftListsTab then return end
    local content = craftListsTab.content

    local crafterUID = CraftSim.UTIL:GetPlayerCrafterUID()
    local allLists = CraftSim.DB.CRAFT_LISTS:GetAllLists(crafterUID)

    content.craftListsList:Remove()

    for _, list in ipairs(allLists) do
        local listRef = list
        local isGlobal = listRef.isGlobal
        content.craftListsList:Add(function(row)
            row.listID = listRef.id
            row.isGlobal = isGlobal
            row.listData = listRef

            local nameColumn = row.columns[1]
            local typeColumn = row.columns[2]

            nameColumn.text:SetText(listRef.name)
            typeColumn.text:SetText(isGlobal and L("CRAFT_LISTS_GLOBAL_LABEL")
                or L("CRAFT_LISTS_CHARACTER_LABEL"))

            row.tooltipOptions = {
                anchor = "ANCHOR_CURSOR",
                textCallback = function()
                    return CraftSim.CRAFT_LISTS:BuildOptionsTooltipText(listRef)
                end,
            }
        end)
    end

    content.craftListsList:UpdateDisplay()
end

--- Update the recipe display for the selected craft list (right panel)
function CraftSim.CRAFTQ.UI:UpdateCraftListsRecipeDisplay()
    if not CraftSim.CRAFTQ.frame or not CraftSim.CRAFTQ.frame.content then return end
    local craftListsTab = CraftSim.CRAFTQ.frame.content.craftListsTab --[[@as CraftSim.CraftQueue.CraftListsTab?]]
    if not craftListsTab then return end
    local content = craftListsTab.content

    content.recipeList:Remove()

    if not content.selectedListID then
        content.selectedListLabel:SetText(L("CRAFT_LISTS_SELECT_LIST_HINT"))
        content.recipeList:UpdateDisplay()
        return
    end

    local crafterUID = CraftSim.UTIL:GetPlayerCrafterUID()
    local list = CraftSim.DB.CRAFT_LISTS:GetList(
        content.selectedListID,
        crafterUID)

    if not list then
        content.recipeList:UpdateDisplay()
        return
    end

    content.selectedListLabel:SetText(f.bb(list.name))

    local recipeEntries = list.recipeEntries or {}
    if #recipeEntries == 0 then
        recipeEntries = {}
        for _, recipeID in ipairs(list.recipeIDs or {}) do
            tinsert(recipeEntries, {
                recipeID = recipeID,
                restockMaxAmount = 0,
            })
        end
    end

    for _, recipeEntry in ipairs(recipeEntries) do
        local id = recipeEntry.recipeID
        local entry = recipeEntry
        content.recipeList:Add(function(row)
            row.recipeID = id
            local nameColumn = row.columns[1]
            local recipeInfo = C_TradeSkillUI.GetRecipeInfo(id)
            local name = (recipeInfo and recipeInfo.name) or (f.grey("Unknown Recipe (ID: " .. tostring(id) .. ")"))
            local icon = (recipeInfo and recipeInfo.icon) and GUTIL:IconToText(recipeInfo.icon, 18, 18) or "<i>"
            local profession = C_TradeSkillUI.GetProfessionInfoByRecipeID(id).profession
            local professionIcon = CraftSim.CONST.PROFESSION_ICONS[profession] or "inv_misc_questionmark"
            local professionIconText = GUTIL:IconToText(professionIcon, 18, 18)
            local restockText = ""
            local target = math.max(0, tonumber(entry.restockMaxAmount) or 0)
            if target > 0 then
                restockText = " " .. f.l("[" .. tostring(target) .. "]")
            end
            nameColumn.text:SetText(professionIconText .. " " .. icon .. " " .. name .. restockText)

            local tipItemID, tipItemLink = CraftSim.ResultData.GetCraftListTooltipItemIDOrLink(id, recipeInfo)
            row.tooltipOptions = {
                owner = row.frame,
                anchor = "ANCHOR_CURSOR_RIGHT",
            }
            if tipItemID then
                row.tooltipOptions.itemID = tipItemID
                row.tooltipOptions.itemLink = nil
                row.tooltipOptions.text = nil
            elseif tipItemLink then
                row.tooltipOptions.itemID = nil
                row.tooltipOptions.itemLink = tipItemLink
                row.tooltipOptions.text = nil
            else
                row.tooltipOptions.itemID = nil
                row.tooltipOptions.itemLink = nil
                row.tooltipOptions.text = name .. "\n" .. f.grey("Recipe ID: " .. tostring(id))
            end
        end)
    end

    content.recipeList:UpdateDisplay()
end

--- Show a popup dialog to enter/confirm a craft list name
---@param title string
---@param defaultName string
---@param isGlobal boolean
---@param callback fun(name: string, isGlobal: boolean)
---@param isRename boolean?
function CraftSim.CRAFTQ.UI:ShowCraftListNamePopup(title, defaultName, isGlobal, callback, isRename)
    local popupFrame = GGUI.Frame {
        parent = UIParent,
        anchorParent = UIParent,
        sizeX = 350, sizeY = isRename and 100 or 120,
        frameID = "CRAFT_LIST_NAME_POPUP",
        frameTable = {},
        title = title,
        backdropOptions = CraftSim.CONST.DEFAULT_BACKDROP_OPTIONS,
        frameStrata = "DIALOG",
        closeable = true,
        moveable = true,
    }

    local nameEditBox = CreateFrame("EditBox", nil, popupFrame.content, "InputBoxTemplate")
    nameEditBox:SetPoint("TOP", popupFrame.content, "TOP", 0, -30)
    nameEditBox:SetSize(280, 25)
    nameEditBox:SetAutoFocus(true)
    nameEditBox:SetFontObject("ChatFontNormal")
    nameEditBox:SetText(defaultName or "")
    nameEditBox:SetScript("OnEscapePressed", function() nameEditBox:ClearFocus() end)
    nameEditBox:SetScript("OnEnterPressed", function() nameEditBox:ClearFocus() end)
    popupFrame.content.nameEditBox = nameEditBox

    popupFrame.content.globalCB = GGUI.Checkbox {
        parent = popupFrame.content,
        anchorParent = nameEditBox,
        anchorA = "TOPLEFT",
        anchorB = "BOTTOMLEFT",
        offsetY = -5,
        initialValue = isGlobal,
        labelOptions = {
            text = L("CRAFT_LISTS_GLOBAL_LABEL") .. " (visible to all characters)",
        },
    }

    popupFrame.content.globalCB:SetVisible(not isRename) -- hide global option when renaming, as it cannot be changed during rename

    popupFrame.content.confirmButton = GGUI.Button {
        parent = popupFrame.content,
        anchorParent = popupFrame.content,
        anchorA = "BOTTOM",
        anchorB = "BOTTOM",
        offsetY = 10,
        label = "Confirm",
        adjustWidth = true,
        clickCallback = function()
            local name = nameEditBox:GetText()
            local global = popupFrame.content.globalCB:GetChecked()
            popupFrame:Hide()
            if callback then callback(name, global) end
        end,
    }

    popupFrame:Show()
end

--- Show a popup to paste an import string
---@param callback function(importString: string, isGlobal: boolean)
function CraftSim.CRAFTQ.UI:ShowCraftListImportPopup(callback)
    local popupFrame = GGUI.Frame {
        parent = UIParent,
        anchorParent = UIParent,
        sizeX = 500, sizeY = 130,
        frameID = "CRAFT_LIST_IMPORT_POPUP",
        frameTable = {},
        title = L("CRAFT_LISTS_IMPORT_POPUP_TITLE"),
        backdropOptions = CraftSim.CONST.DEFAULT_BACKDROP_OPTIONS,
        frameStrata = "DIALOG",
        closeable = true,
        moveable = true,
    }

    local importEditBox = CreateFrame("EditBox", nil, popupFrame.content, "InputBoxTemplate")
    importEditBox:SetPoint("TOP", popupFrame.content, "TOP", 0, -30)
    importEditBox:SetSize(460, 25)
    importEditBox:SetAutoFocus(true)
    importEditBox:SetFontObject("ChatFontNormal")
    importEditBox:SetText("")
    importEditBox:SetScript("OnEscapePressed", function() importEditBox:ClearFocus() end)
    importEditBox:SetScript("OnEnterPressed", function() importEditBox:ClearFocus() end)
    popupFrame.content.importEditBox = importEditBox

    popupFrame.content.globalCB = GGUI.Checkbox {
        parent = popupFrame.content,
        anchorParent = importEditBox,
        anchorA = "TOPLEFT",
        anchorB = "BOTTOMLEFT",
        offsetY = -5,
        initialValue = false,
        labelOptions = {
            text = L("CRAFT_LISTS_GLOBAL_LABEL") .. " (visible to all characters)",
        },
    }

    popupFrame.content.confirmButton = GGUI.Button {
        parent = popupFrame.content,
        anchorParent = popupFrame.content,
        anchorA = "BOTTOM",
        anchorB = "BOTTOM",
        offsetY = 10,
        label = "Import",
        adjustWidth = true,
        clickCallback = function()
            local importString = importEditBox:GetText()
            local isGlobal = popupFrame.content.globalCB:GetChecked()
            popupFrame:Hide()
            if callback then callback(importString, isGlobal) end
        end,
    }

    popupFrame:Show()
end

---@param frame GGUI.Frame
function CraftSim.CRAFTQ.UI:InitializeQuickAccessBar(frame)
    local content = frame.content.queueTab.content

    content.quickBarFrame = GGUI.Frame {
        parent = content, anchorParent = content,
        anchorA = "TOPLEFT", anchorB = "TOPLEFT", offsetY = 70, offsetX = 75,
        sizeX = 200, sizeY = 70,
    }

    local quickBarFrameButtonSize = 30
    content.quickBarFrame.buttonList = GGUI.FrameList {
        parent = content.quickBarFrame.frame, anchorParent = content.quickBarFrame.frame,
        horizontal = true, offsetY = 0,
        rowHeight = 35,
        hideScrollbar = true,
        sizeY = 50,
        autoAdjustHeight = true,
        columnOptions = {
            {
                width = 30, -- icon
            },
        },
        anchorA = "LEFT", anchorB = "LEFT",
        rowConstructor = function(columns, row)
            local buttonColumn = columns[1]
            buttonColumn.macroButton = GGUI.Button {
                parent = buttonColumn, anchorParent = buttonColumn, sizeX = quickBarFrameButtonSize, sizeY = quickBarFrameButtonSize, anchorA = "CENTER",
                anchorB = "CENTER",
                macro = true,
                macroText = "",
                tooltipOptions = {
                    anchor = "ANCHOR_TOP",
                    text = "",
                },
                fontOptions = {
                    fontFile = CraftSim.CONST.FONT_FILES.ROBOTO,
                    scale = 3,
                    flags = "THICKOUTLINE",
                },
                borderOptions = {
                    colorRGBA = { 1, 1, 1, 1 },
                    borderSize = 10,
                    showBorder = false,
                },
            }
            buttonColumn.recipeCraftButton = GGUI.Button {
                parent = buttonColumn, anchorParent = buttonColumn, sizeX = quickBarFrameButtonSize, sizeY = quickBarFrameButtonSize, anchorA = "CENTER",
                anchorB = "CENTER",
                tooltipOptions = {
                    anchor = "ANCHOR_TOP",
                    text = "",
                },
                fontOptions = {
                    fontFile = CraftSim.CONST.FONT_FILES.ROBOTO,
                    scale = 3,
                    flags = "THICKOUTLINE",
                },
                borderOptions = {
                    colorRGBA = { 1, 1, 1, 1 },
                    borderSize = 10,
                    showBorder = false,
                },
            }
        end,
    }
end

---@param parent frame
---@param anchorParent Region
---@return CraftSim.CRAFTQ.EditRecipeFrame editRecipeFrame
function CraftSim.CRAFTQ.UI:InitEditRecipeFrame(parent, anchorParent)
    local editFrameX = 600
    local editFrameY = 350
    ---@class CraftSim.CRAFTQ.EditRecipeFrame : GGUI.Frame
    local editRecipeFrame = GGUI.Frame {
        parent = parent, anchorParent = anchorParent,
        sizeX = editFrameX, sizeY = editFrameY, backdropOptions = CraftSim.CONST.DEFAULT_BACKDROP_OPTIONS,
        frameID = CraftSim.CONST.FRAMES.CRAFT_QUEUE_EDIT_RECIPE, frameTable = CraftSim.INIT.FRAMES,
        title = L("CRAFT_QUEUE_EDIT_RECIPE_TITLE"),
        frameStrata = "DIALOG", closeable = true, closeOnClickOutside = true, moveable = true, frameConfigTable = CraftSim.DB.OPTIONS:Get("GGUI_CONFIG"),
    }

    ---@type CraftSim.CraftQueueItem?
    editRecipeFrame.craftQueueItem = nil

    ---@class CraftSim.CRAFTQ.EditRecipeFrame.Content
    editRecipeFrame.content = editRecipeFrame.content

    editRecipeFrame.content.recipeName = GGUI.Text {
        parent = editRecipeFrame.content, anchorParent = editRecipeFrame.title.frame, anchorA = "TOP", anchorB = "BOTTOM",
        text = L("CRAFT_QUEUE_EDIT_RECIPE_NAME_LABEL"), scale = 1.5, offsetY = -10,
    }

    -- required reagent frames (only for quality reagents as the non quality ones are fixed anyway)
    local qIconSize = 15
    local qButtonSize = 20 -- kept for layout reference
    local qButtonSpacingX = 25
    local qButtonBaseOffsetX = 50
    local qButtonBaseOffsetY = -70

    -- required quality reagents list (FrameList-based, shared with SimulationMode)
    local reagentAnchorPoints = {
        {
            anchorParent = editRecipeFrame.content,
            offsetX = qButtonBaseOffsetX,
            offsetY = qButtonBaseOffsetY - 30,
            anchorA = "TOPLEFT",
            anchorB = "TOPLEFT",
        },
    }

    local function setAllReagentsByQuality(qualityID)
        if not editRecipeFrame.craftQueueItem or not editRecipeFrame.craftQueueItem.recipeData then
            return
        end

        local recipeData = editRecipeFrame.craftQueueItem.recipeData
        if recipeData:IsSimplifiedQualityRecipe() and qualityID == 3 then
            return
        end

        recipeData.reagentData:SetReagentsMaxByQuality(qualityID)
        recipeData:Update()
        CraftSim.CRAFTQ.UI:UpdateFrameListByCraftQueue()
        CraftSim.CRAFTQ.UI:UpdateEditRecipeFrameDisplay(editRecipeFrame.craftQueueItem)
    end

    local function onReagentQuantityChanged(row, columns, qualityIndex)
        if not editRecipeFrame.craftQueueItem or not editRecipeFrame.craftQueueItem.recipeData then
            return
        end

        local recipeData = editRecipeFrame.craftQueueItem.recipeData
        local reagent = row.reagent --[[@as CraftSim.Reagent?]]
        if not reagent then
            return
        end

        local simplified = recipeData:IsSimplifiedQualityRecipe()
        local requiredQuantity = reagent.requiredQuantity

        local qInputs = {}
        qInputs[1] = columns[2].input --[[@as GGUI.NumericInput]]
        qInputs[2] = columns[3].input --[[@as GGUI.NumericInput]]
        local maxIndex = 2
        if not simplified then
            qInputs[3] = columns[4].input --[[@as GGUI.NumericInput]]
            maxIndex = 3
        end

        local function getTotal()
            local total = 0
            for i = 1, maxIndex do
                local input = qInputs[i]
                total = total + (tonumber(input.currentValue) or 0)
            end
            return total
        end

        local total = getTotal()
        if total > requiredQuantity then
            local diff = total - requiredQuantity
            local changedInput = qInputs[qualityIndex]
            local newQuantity = math.max((tonumber(changedInput.currentValue) or 0) - diff, 0)
            changedInput.textInput:SetText(newQuantity)
            changedInput.currentValue = newQuantity
        end

        total = getTotal()

        local requiredText = (simplified and columns[4].text) or columns[5].text --[[@as GGUI.Text]]

        if total == requiredQuantity then
            requiredText:SetColor(GUTIL.COLORS.WHITE)

            -- propagate into reagent items
            reagent.items[1].quantity = qInputs[1].currentValue
            reagent.items[2].quantity = qInputs[2].currentValue
            if not simplified and qInputs[3] then
                reagent.items[3].quantity = qInputs[3].currentValue
            elseif reagent.items[3] then
                reagent.items[3].quantity = 0
            end

            recipeData:Update()
            CraftSim.CRAFTQ.UI:UpdateFrameListByCraftQueue()
            CraftSim.CRAFTQ.UI:UpdateEditRecipeFrameDisplay(editRecipeFrame.craftQueueItem)
        else
            requiredText:SetColor(GUTIL.COLORS.RED)
        end
    end

    editRecipeFrame.content.reagentList = CraftSim.WIDGETS.ReagentList {
        parent = editRecipeFrame.content,
        anchorPoints = reagentAnchorPoints,
        onHeaderClick = setAllReagentsByQuality,
        onQuantityChanged = onReagentQuantityChanged,
    }

    local oRFrameX = 100
    local oRFrameY = 65
    local optionalReagentsFrame = CreateFrame("frame", nil, editRecipeFrame.content)
    optionalReagentsFrame:SetSize(oRFrameX, oRFrameY)
    optionalReagentsFrame:SetPoint("TOPLEFT", editRecipeFrame.content.reagentList.frame, "TOPRIGHT", 0, 20)

    optionalReagentsFrame.collapse = function()
        optionalReagentsFrame:SetSize(oRFrameX, 0.1)
    end
    optionalReagentsFrame.decollapse = function()
        optionalReagentsFrame:SetSize(oRFrameX, oRFrameY)
    end
    optionalReagentsFrame.SetCollapsed = function(self, collapse)
        if collapse then
            optionalReagentsFrame.collapse()
        else
            optionalReagentsFrame.decollapse()
        end
    end

    editRecipeFrame.content.optionalReagentsFrame = optionalReagentsFrame

    -- optional reagent slots
    editRecipeFrame.content.optionalReagentsTitle = GGUI.Text {
        parent = optionalReagentsFrame, anchorParent = optionalReagentsFrame, anchorA = "TOPLEFT", anchorB = "TOPLEFT",
        text = L("CRAFT_QUEUE_EDIT_RECIPE_OPTIONAL_REAGENTS_LABEL"), justifyOptions = { type = "H", align = "LEFT" }
    }
    ---@class CraftSim.CRAFTQ.EditRecipeFrame.OptionalReagentSelector : GGUI.ItemSelector
    ---@field slot CraftSim.OptionalReagentSlot?

    ---@type CraftSim.CRAFTQ.EditRecipeFrame.OptionalReagentSelector[]
    editRecipeFrame.content.optionalReagentSelectors = {}
    local itemSelectorSizeX = 25
    local itemSelectorSizeY = 25
    local itemSelectorBaseOffsetX = 0
    local itemSelectorBaseOffsetY = -10
    local itemSelectorSpacingX = itemSelectorSizeX + 5
    local function CreateItemSelector(parent, anchorParent, saveTable, onSelectCallback, anchorA, anchorB, offsetX,
                                      offsetY)
        local numSelectors = #saveTable
        table.insert(saveTable, GGUI.ItemSelector {
            parent = parent, anchorParent = anchorParent, anchorA = "TOPLEFT", anchorB = "BOTTOMLEFT",
            offsetX = itemSelectorBaseOffsetX + itemSelectorSpacingX * numSelectors,
            offsetY = itemSelectorBaseOffsetY,
            sizeX = itemSelectorSizeX, sizeY = itemSelectorSizeY, selectionFrameOptions = {
            backdropOptions = CraftSim.CONST.DEFAULT_BACKDROP_OPTIONS,
            title = L("CRAFT_QUEUE_EDIT_RECIPE_REAGENTS_SELECT_LABEL"), anchorA = anchorA, anchorB = anchorB, offsetX = offsetX, offsetY = offsetY
        },
            emptyIcon = CraftSim.CONST.ATLAS_TEXTURES.TRADESKILL_ICON_ADD, isAtlas = true, onSelectCallback = onSelectCallback
        })
    end

    ---@param itemSelector CraftSim.CRAFTQ.EditRecipeFrame.OptionalReagentSelector
    ---@param selectedItem ItemMixin?
    ---@param selectedCurrencyID number?
    local function OnSelectOptionalReagent(itemSelector, selectedItem, selectedCurrencyID)
        local currentCraftQueueUID = editRecipeFrame.craftQueueItem.recipeData:GetRecipeCraftQueueUID()
        if itemSelector and itemSelector.slot then
            if selectedCurrencyID then
                itemSelector.slot:SetCurrencyReagent(selectedCurrencyID)
            elseif not selectedItem and itemSelector.slot:IsCurrency() then
                itemSelector.slot:SetCurrencyReagent(nil)
            else
                print("setting reagent: " .. tostring(selectedItem and selectedItem:GetItemLink()))
                itemSelector.slot:SetReagent((selectedItem and selectedItem:GetItemID()) or nil)
            end
            editRecipeFrame.craftQueueItem.recipeData:Update()

            -- Update craftQueueUID if it has changed
            local newCraftQueueUID = editRecipeFrame.craftQueueItem.recipeData:GetRecipeCraftQueueUID()
            if currentCraftQueueUID ~= newCraftQueueUID then
                -- if there is already another mapping with the same uid, merge the others amount into the current one
                if CraftSim.CRAFTQ.craftQueue.recipeCrafterMap[newCraftQueueUID] then
                    local existingItem = CraftSim.CRAFTQ.craftQueue.recipeCrafterMap[newCraftQueueUID]
                    editRecipeFrame.craftQueueItem.amount = existingItem.amount + editRecipeFrame.craftQueueItem.amount
                    -- remove old item from craftqueue
                    CraftSim.CRAFTQ.craftQueue:Remove(existingItem)
                else
                    -- if not just update the mapping
                    CraftSim.CRAFTQ.craftQueue.recipeCrafterMap[newCraftQueueUID] = editRecipeFrame.craftQueueItem
                    CraftSim.CRAFTQ.craftQueue.recipeCrafterMap[currentCraftQueueUID] = nil
                    editRecipeFrame.craftQueueItem.craftQueueUID = newCraftQueueUID
                end
            end

            CraftSim.CRAFTQ.UI:UpdateFrameListByCraftQueue()
            CraftSim.CRAFTQ.UI:UpdateEditRecipeFrameDisplay(editRecipeFrame.craftQueueItem)
        end
    end

    local numOptionalReagentSelectors = 3
    for _ = 1, numOptionalReagentSelectors do
        CreateItemSelector(optionalReagentsFrame, editRecipeFrame.content.optionalReagentsTitle.frame,
            editRecipeFrame.content.optionalReagentSelectors, OnSelectOptionalReagent)
    end

    editRecipeFrame.content.finishingReagentsTitle = GGUI.Text {
        parent = editRecipeFrame.content, anchorParent = optionalReagentsFrame, anchorA = "TOPLEFT", anchorB = "BOTTOMLEFT",
        text = L("CRAFT_QUEUE_EDIT_RECIPE_FINISHING_REAGENTS_LABEL"), justifyOptions = { type = "H", align = "LEFT" }
    }

    ---@type CraftSim.CRAFTQ.EditRecipeFrame.OptionalReagentSelector[]
    editRecipeFrame.content.finishingReagentSelectors = {}
    local numFinishingReagentSelectors = 3
    for _ = 1, numFinishingReagentSelectors do
        CreateItemSelector(editRecipeFrame.content, editRecipeFrame.content.finishingReagentsTitle.frame,
            editRecipeFrame.content.finishingReagentSelectors, OnSelectOptionalReagent)
    end

    editRecipeFrame.content.requiredSelectableReagentTitle = GGUI.Text {
        parent = editRecipeFrame.content, anchorParent = optionalReagentsFrame, anchorA = "TOPLEFT", anchorB = "BOTTOMLEFT", offsetY = -65,
        text = L("CRAFT_QUEUE_EDIT_RECIPE_SPARK_LABEL"), justifyOptions = { type = "H", align = "LEFT" }
    }


    ---@type CraftSim.CRAFTQ.EditRecipeFrame.OptionalReagentSelector[]
    editRecipeFrame.content.requiredSelectableReagentSelectors = {}
    CreateItemSelector(editRecipeFrame.content, editRecipeFrame.content.requiredSelectableReagentTitle.frame,
        editRecipeFrame.content.requiredSelectableReagentSelectors, OnSelectOptionalReagent)

    editRecipeFrame.content.professionGearTitle = GGUI.Text {
        parent = editRecipeFrame.content, anchorParent = editRecipeFrame.content.optionalReagentsTitle.frame, anchorA = "LEFT", anchorB = "RIGHT", offsetX = 20,
        text = L("CRAFT_QUEUE_EDIT_RECIPE_PROFESSION_GEAR_LABEL"), justifyOptions = { type = "H", align = "LEFT" }
    }

    ---@class CraftSim.CRAFTQ.EditRecipeFrame.ProfessionGearSelector : GGUI.ItemSelector
    ---@field professionGear CraftSim.ProfessionGear?

    ---@type CraftSim.CRAFTQ.EditRecipeFrame.ProfessionGearSelector[]
    editRecipeFrame.content.professionGearSelectors = {}

    ---@param itemSelector CraftSim.CRAFTQ.EditRecipeFrame.ProfessionGearSelector
    ---@param item ItemMixin?
    local function OnSelectProfessionGear(itemSelector, item)
        print("on select professiongear: " .. tostring(item and item:GetItemLink()))
        if itemSelector and itemSelector.professionGear then
            if item then
                print("setting gear: " .. tostring(item:GetItemLink()))
                item:ContinueOnItemLoad(function()
                    itemSelector.professionGear:SetItem(item:GetItemLink())
                    editRecipeFrame.craftQueueItem.recipeData.professionGearSet:UpdateProfessionStats()
                    editRecipeFrame.craftQueueItem.recipeData:Update()
                    CraftSim.CRAFTQ.UI:UpdateFrameListByCraftQueue()
                    CraftSim.CRAFTQ.UI:UpdateEditRecipeFrameDisplay(editRecipeFrame.craftQueueItem)
                end)
            else
                print("setting gear to no gear")
                itemSelector.professionGear:SetItem(nil)
                editRecipeFrame.craftQueueItem.recipeData.professionGearSet:UpdateProfessionStats()
                editRecipeFrame.craftQueueItem.recipeData:Update()
                CraftSim.CRAFTQ.UI:UpdateFrameListByCraftQueue()
                CraftSim.CRAFTQ.UI:UpdateEditRecipeFrameDisplay(editRecipeFrame.craftQueueItem)
            end
        end
    end

    for _ = 1, 3 do
        CreateItemSelector(editRecipeFrame.content, editRecipeFrame.content.professionGearTitle.frame,
            editRecipeFrame.content.professionGearSelectors, OnSelectProfessionGear, "TOPRIGHT", "TOPLEFT", 0, -25)
    end

    editRecipeFrame.content.optimizeProfitButton = GGUI.Button {
        parent = editRecipeFrame.content, anchorParent = editRecipeFrame.content.professionGearTitle.frame, anchorA = "TOPLEFT", anchorB = "BOTTOMLEFT", offsetY = -50,
        label = L("CRAFT_QUEUE_EDIT_RECIPE_OPTIMIZE_PROFIT_BUTTON"), sizeX = 150,
        clickCallback = function(optimizeButton)
            if editRecipeFrame.craftQueueItem and editRecipeFrame.craftQueueItem.recipeData then
                local recipeData                  = editRecipeFrame.craftQueueItem.recipeData
                local OPT_ID                      = CraftSim.CONST.OPTIMIZATION_OPTIONS_IDS.CRAFTQUEUE_EDIT_RECIPE
                local KEYS                        = CraftSim.WIDGETS.OptimizationOptions.OPTION_KEYS
                local FA                          = CraftSim.WIDGETS.OptimizationOptions.FINISHING_REAGENTS_ALGORITHM
                local optimizeProfessionGear      = CraftSim.DB.OPTIMIZATION_OPTIONS:Get(OPT_ID,
                    KEYS.OPTIMIZE_PROFESSION_TOOLS, true)
                local optimizeConcentration       = CraftSim.DB.OPTIMIZATION_OPTIONS:Get(OPT_ID,
                    KEYS.OPTIMIZE_CONCENTRATION, true)
                local optimizeFinishingReagents   = CraftSim.DB.OPTIMIZATION_OPTIONS:Get(OPT_ID,
                    KEYS.OPTIMIZE_FINISHING_REAGENTS, true)
                local finishingAlgorithm          = CraftSim.DB.OPTIMIZATION_OPTIONS:Get(OPT_ID,
                    KEYS.FINISHING_REAGENTS_ALGORITHM, FA.SIMPLE)

                -- Never consider locked finishing slots in Craft Queue, but ALWAYS include soulbound
                -- when optimizing via Craft Queue.
                local includeLockedFinishing      = false
                local includeSoulboundFinishing   = CraftSim.DB.OPTIMIZATION_OPTIONS:Get(OPT_ID,
                    KEYS.INCLUDE_SOULBOUND_FINISHING_REAGENTS, false)
                local onlyHighestQualitySoulbound = CraftSim.DB.OPTIMIZATION_OPTIONS:Get(OPT_ID,
                    KEYS.ONLY_HIGHEST_QUALITY_SOULBOUND_FINISHING_REAGENTS, false)
                local queueAmount                 = editRecipeFrame.craftQueueItem.amount or 1

                local function finalizeOptimize()
                    if includeSoulboundFinishing then
                        -- Ensure selected soulbound finishing reagents can cover the queued amount.
                        recipeData:AdjustSoulboundFinishingForAmount(queueAmount)
                    end
                    CraftSim.CRAFTQ.UI:UpdateFrameListByCraftQueue()
                    CraftSim.CRAFTQ.UI:UpdateEditRecipeFrameDisplay(editRecipeFrame.craftQueueItem)
                    optimizeButton:SetEnabled(true)
                    optimizeButton:SetText(L("CRAFT_QUEUE_EDIT_RECIPE_OPTIMIZE_PROFIT_BUTTON"))
                end

                local optimizeTopProfit = CraftSim.DB.OPTIMIZATION_OPTIONS:Get(OPT_ID, KEYS
                    .AUTOSELECT_TOP_PROFIT_QUALITY, true)

                optimizeButton:SetEnabled(false)
                recipeData:Optimize {
                    optimizeGear = optimizeProfessionGear,
                    optimizeReagentOptions = { highestProfit = optimizeTopProfit },
                    optimizeConcentration = optimizeConcentration,
                    optimizeConcentrationProgressCallback = function(progress)
                        optimizeButton:SetText(string.format("CON: %.0f%%", progress))
                    end,
                    optimizeFinishingReagentsOptions = optimizeFinishingReagents and {
                        includeLocked = includeLockedFinishing,
                        includeSoulbound = includeSoulboundFinishing,
                        onlyHighestQualitySoulbound = onlyHighestQualitySoulbound,
                        permutationBased = finishingAlgorithm == FA.PERMUTATION,
                        progressUpdateCallback = function(progress)
                            optimizeButton:SetText(string.format("FIN: %.0f%%", progress))
                        end,
                    } or nil,
                    finally = function()
                        finalizeOptimize()
                    end,
                }
            end
        end
    }

    editRecipeFrame.content.optimizeProfitButtonOptions = CraftSim.WIDGETS.OptimizationOptions {
        parent = editRecipeFrame.content,
        anchorPoints = { { anchorParent = editRecipeFrame.content.optimizeProfitButton.frame, anchorA = "LEFT", anchorB = "RIGHT", offsetX = 5 } },
        optimizationOptionsID = CraftSim.CONST.OPTIMIZATION_OPTIONS_IDS.CRAFTQUEUE_EDIT_RECIPE,
        showOptions = {
            AUTOSELECT_TOP_PROFIT_QUALITY                     = true,
            OPTIMIZE_PROFESSION_TOOLS                         = true,
            OPTIMIZE_CONCENTRATION                            = true,
            OPTIMIZE_FINISHING_REAGENTS                       = true,
            INCLUDE_SOULBOUND_FINISHING_REAGENTS              = true,
            ONLY_HIGHEST_QUALITY_SOULBOUND_FINISHING_REAGENTS = true,
            FINISHING_REAGENTS_ALGORITHM                      = true,
        },
        defaults = {
            AUTOSELECT_TOP_PROFIT_QUALITY                     = true,
            OPTIMIZE_PROFESSION_TOOLS                         = true,
            OPTIMIZE_CONCENTRATION                            = true,
            OPTIMIZE_FINISHING_REAGENTS                       = true,
            INCLUDE_SOULBOUND_FINISHING_REAGENTS              = false,
            ONLY_HIGHEST_QUALITY_SOULBOUND_FINISHING_REAGENTS = false,
            FINISHING_REAGENTS_ALGORITHM                      = CraftSim.WIDGETS.OptimizationOptions.FINISHING_REAGENTS_ALGORITHM.SIMPLE,
        },
        recipeDataProvider = function()
            return editRecipeFrame.craftQueueItem and editRecipeFrame.craftQueueItem.recipeData
        end,
    }

    editRecipeFrame.content.resultTitle = GGUI.Text {
        parent = editRecipeFrame.content, anchorParent = editRecipeFrame.content.optimizeProfitButton.frame, anchorA = "TOPLEFT", anchorB = "BOTTOMLEFT",
        offsetY = -40, text = L("CRAFT_QUEUE_EDIT_RECIPE_RESULTS_LABEL"),
    }

    editRecipeFrame.content.concentrationCB = GGUI.Checkbox {
        parent = editRecipeFrame.content, anchorParent = editRecipeFrame.content.resultTitle.frame, anchorA = "BOTTOMLEFT", anchorB = "TOPLEFT",
        offsetY = 5, scale = 2,
        labelOptions = {
            text = GUTIL:IconToText(CraftSim.CONST.CONCENTRATION_ICON, 15, 15) .. L("CRAFT_QUEUE_EDIT_RECIPE_CONCENTRATION_CHECKBOX")
        },
        clickCallback = function(_, checked)
            if editRecipeFrame.craftQueueItem and editRecipeFrame.craftQueueItem.recipeData then
                editRecipeFrame.craftQueueItem.recipeData.concentrating = checked
                editRecipeFrame.craftQueueItem.concentrating = checked
                editRecipeFrame.craftQueueItem.recipeData:Update()
                CraftSim.CRAFTQ.UI:UpdateFrameListByCraftQueue()
                CraftSim.CRAFTQ.UI:UpdateEditRecipeFrameDisplay(editRecipeFrame.craftQueueItem)
            end
        end
    }
    do
        local cbFrame = editRecipeFrame.content.concentrationCB.frame
        cbFrame:SetScript("OnEnter", function()
            local frame = GGUI:GetFrame(CraftSim.INIT.FRAMES, CraftSim.CONST.FRAMES.CRAFT_QUEUE_EDIT_RECIPE)
            local craftQueueItem = frame.craftQueueItem
            if not craftQueueItem or not craftQueueItem.recipeData or not craftQueueItem.recipeData.supportsQualities then return end
            local recipeData = craftQueueItem.recipeData
            local concentrationData = recipeData.concentrationData
            local cost = recipeData.concentrationCost
            if not concentrationData or not cost or cost <= 0 then return end
            if recipeData:IsCrafter() then
                concentrationData:Update()
            end
            local formatMode = CraftSim.DB.OPTIONS:Get("CONCENTRATION_TRACKER_FORMAT_MODE")
            local useUSFormat = formatMode == CraftSim.CONCENTRATION_TRACKER.UI.FORMAT_MODE.AMERICA_MAX_DATE
            if concentrationData:GetCurrentAmount() < cost then
                local estimatedText = concentrationData:GetEstimatedTimeUntilEnoughText(cost, useUSFormat)
                if estimatedText then
                    GameTooltip:SetOwner(cbFrame, "ANCHOR_RIGHT")
                    GameTooltip:ClearLines()
                    GameTooltip:SetText(estimatedText)
                    GameTooltip:Show()
                end
            end
        end)
        cbFrame:SetScript("OnLeave", function()
            GameTooltip:Hide()
        end)
    end

    editRecipeFrame.content.resultList = GGUI.FrameList {
        parent = editRecipeFrame.content, anchorParent = editRecipeFrame.content.resultTitle.frame, anchorA = "TOPLEFT", anchorB = "BOTTOMLEFT",
        hideScrollbar = true, offsetX = -10, sizeY = 100, rowHeight = 30,
        columnOptions = {
            {
                width = 40, -- icon
            },
        },
        rowConstructor = function(columns, row)
            local iconColumn = columns[1]

            ---@type QualityID
            row.qualityID = nil

            iconColumn.icon = GGUI.Icon {
                parent = iconColumn, anchorParent = iconColumn, sizeX = 30, sizeY = 30, anchorA = "LEFT", anchorB = "LEFT", offsetX = 3,
            }
        end
    }

    -- bottom stats block (4 rows, 2 columns), centered near the bottom of the window
    editRecipeFrame.content.statsFrame = CreateFrame("frame", nil, editRecipeFrame.content)
    editRecipeFrame.content.statsFrame:SetSize(320, 80)
    -- center horizontally on the whole content frame, with a fixed vertical offset from the bottom
    editRecipeFrame.content.statsFrame:SetPoint("BOTTOM", editRecipeFrame.content, "BOTTOM", 0, 5)
    local statsFrame = editRecipeFrame.content.statsFrame

    editRecipeFrame.content.craftingCostsTitle = GGUI.Text {
        parent = statsFrame,
        anchorParent = statsFrame,
        anchorA = "TOPLEFT", anchorB = "TOPLEFT",
        justifyOptions = { type = "H", align = "RIGHT" },
        fixedWidth = 150,
        text = L("CRAFT_QUEUE_EDIT_RECIPE_CRAFTING_COSTS_LABEL"),
    }
    editRecipeFrame.content.craftingCostsValue = GGUI.Text {
        parent = statsFrame,
        anchorParent = editRecipeFrame.content.craftingCostsTitle.frame,
        anchorA = "LEFT", anchorB = "RIGHT",
        offsetX = 5, offsetY = 1,
        text = CraftSim.UTIL:FormatMoney(0, true),
        justifyOptions = { type = "H", align = "LEFT" },
        scale = 0.9,
    }
    editRecipeFrame.content.averageProfitTitle = GGUI.Text {
        parent = statsFrame,
        anchorParent = editRecipeFrame.content.craftingCostsTitle.frame,
        anchorA = "TOPLEFT", anchorB = "BOTTOMLEFT",
        offsetY = -7,
        justifyOptions = { type = "H", align = "RIGHT" },
        fixedWidth = 150,
        text = L("CRAFT_QUEUE_EDIT_RECIPE_AVERAGE_PROFIT_LABEL"),
    }
    editRecipeFrame.content.averageProfitValue = GGUI.Text {
        parent = statsFrame,
        anchorParent = editRecipeFrame.content.averageProfitTitle.frame,
        anchorA = "LEFT", anchorB = "RIGHT",
        offsetX = 5, offsetY = 1,
        text = CraftSim.UTIL:FormatMoney(0, true),
        justifyOptions = { type = "H", align = "LEFT" },
        scale = 0.9,
    }
    editRecipeFrame.content.concentrationValueTitle = GGUI.Text {
        parent = statsFrame,
        anchorParent = editRecipeFrame.content.averageProfitTitle.frame,
        anchorA = "TOPLEFT", anchorB = "BOTTOMLEFT",
        offsetY = -7,
        justifyOptions = { type = "H", align = "RIGHT" },
        fixedWidth = 150,
        text = "Concentration Value:",
    }
    editRecipeFrame.content.concentrationValue = GGUI.Text {
        parent = statsFrame,
        anchorParent = editRecipeFrame.content.concentrationValueTitle.frame,
        anchorA = "LEFT", anchorB = "RIGHT",
        offsetX = 5, offsetY = 1,
        text = CraftSim.UTIL:FormatMoney(0, true),
        justifyOptions = { type = "H", align = "LEFT" },
        scale = 0.9,
    }
    editRecipeFrame.content.concentrationDateTitle = GGUI.Text {
        parent = statsFrame,
        anchorParent = editRecipeFrame.content.concentrationValueTitle.frame,
        anchorA = "TOPLEFT", anchorB = "BOTTOMLEFT",
        offsetY = -7,
        justifyOptions = { type = "H", align = "RIGHT" },
        fixedWidth = 150,
        text = string.gsub(CraftSim.LOCAL:GetText("CONCENTRATION_ESTIMATED_TIME_UNTIL"), " %%s", ""),
    }
    editRecipeFrame.content.concentrationDateValue = GGUI.Text {
        parent = statsFrame,
        anchorParent = editRecipeFrame.content.concentrationDateTitle.frame,
        anchorA = "LEFT", anchorB = "RIGHT",
        offsetX = 5, offsetY = 1,
        text = "",
        justifyOptions = { type = "H", align = "LEFT" },
        scale = 0.9,
    }

    editRecipeFrame:Hide()
    return editRecipeFrame
end

function CraftSim.CRAFTQ.UI:UpdateFrameListByCraftQueue()
    -- multiples should be possible (different reagent setup)
    -- but if there already is a configuration just increase the count?

    print("CraftQueue Update List", false, true)

    CraftSim.DEBUG:StartProfiling("FrameListUpdate")

    local queueTab = CraftSim.CRAFTQ.frame.content.queueTab --[[@as GGUI.BlizzardTab]]
    local craftList = queueTab.content.craftList --[[@as GGUI.FrameList]]

    local craftQueue = CraftSim.CRAFTQ.craftQueue or CraftSim.CraftQueue()

    craftQueue:UpdateSubRecipes()
    craftQueue:RefreshQueuedRecipeCooldownData()
    for _, craftQueueItem in pairs(craftQueue.craftQueueItems) do
        craftQueueItem:CalculateCanCraft()
    end

    CraftSim.DEBUG:StartProfiling("- FrameListUpdate Sort Queue")
    craftQueue:FilterSortByPriority()
    CraftSim.DEBUG:StopProfiling("- FrameListUpdate Sort Queue")

    craftList:Remove()

    CraftSim.DEBUG:StartProfiling("- FrameListUpdate Add Rows")
    for _, craftQueueItem in pairs(craftQueue.craftQueueItems) do
        craftList:Add(
            function(row)
                self:UpdateCraftQueueRowByCraftQueueItem(row, craftQueueItem)
            end)
    end

    CraftSim.DEBUG:StopProfiling("- FrameListUpdate Add Rows")

    --- sort by craftable status
    craftList:UpdateDisplay()

    self:UpdateCraftQueueTotalProfitDisplay()

    craftQueue:CacheQueueItems()


    CraftSim.DEBUG:StopProfiling("FrameListUpdate")
end

---@param recipeData CraftSim.RecipeData
function CraftSim.CRAFTQ.UI:UpdateAddOpenRecipeButton(recipeData)
    local exportMode = CraftSim.UTIL:GetExportModeByVisibility()

    local button = CraftSim.CRAFTQ.queueRecipeButton
    local buttonOptions = CraftSim.CRAFTQ.queueRecipeButtonOptions
    local buttonWO = CraftSim.CRAFTQ.queueRecipeButtonWO
    local buttonOptionsWO = CraftSim.CRAFTQ.queueRecipeButtonOptionsWO

    local isTradeSkillAllowed = not CraftSim.CONST.GATHERING_PROFESSIONS
        [recipeData.professionData.professionInfo.profession] and not C_TradeSkillUI.IsTradeSkillGuild() and
        not C_TradeSkillUI.IsTradeSkillLinked() and not C_TradeSkillUI.IsNPCCrafting() and
        not C_TradeSkillUI.IsRuneforging()

    local isRecipeAllowed = not recipeData.isSalvageRecipe and not recipeData.isRecraft and not recipeData
        .isBaseRecraftRecipe

    -- reset state if changed by anything
    button:SetEnabled(true)
    button:SetText("+ CraftQueue")
    buttonWO:SetEnabled(true)
    buttonWO:SetText("+ CraftQueue")

    button:SetVisible(isTradeSkillAllowed and isRecipeAllowed and exportMode == CraftSim.CONST.EXPORT_MODE
        .NON_WORK_ORDER)
    buttonOptions:SetVisible(isTradeSkillAllowed and isRecipeAllowed and exportMode == CraftSim.CONST.EXPORT_MODE
        .NON_WORK_ORDER)
    buttonWO:SetVisible(isTradeSkillAllowed and isRecipeAllowed and exportMode == CraftSim.CONST.EXPORT_MODE.WORK_ORDER)
    buttonOptionsWO:SetVisible(isTradeSkillAllowed and isRecipeAllowed and
        exportMode == CraftSim.CONST.EXPORT_MODE.WORK_ORDER)
end

function CraftSim.CRAFTQ.UI:UpdateQuickAccessBarDisplay()
    local quickBar = CraftSim.CRAFTQ.frame.content.queueTab.content.quickBarFrame --[[@as GGUI.Frame]]
    local buttonList = quickBar.buttonList --[[@as GGUI.FrameList]]

    buttonList:Remove()
    -- add soulbound upcraft reagents first, then add shatter spell
    for _, data in ipairs(CraftSim.CONST.SOULBOUND_UPCRAFT_REAGENTS_DATA) do
        local reagentItem = Item:CreateFromItemID(data.preItemID)
        local upcraftItem = Item:CreateFromItemID(data.upcraftItemID)
        reagentItem:ContinueOnItemLoad(function()
            buttonList:Add(function(row)
                local macroButton = row.columns[1].macroButton --[[@as GGUI.Button]]
                local recipeCraftButton = row.columns[1].recipeCraftButton --[[@as GGUI.Button]]
                macroButton:Show()
                recipeCraftButton:Hide()
                macroButton:SetMacroText("/use item:" .. data.preItemID)
                macroButton:SetTexture {
                    normal = reagentItem:GetItemIcon(),
                    pushed = reagentItem:GetItemIcon(),
                    highlight = reagentItem:GetItemIcon(),
                    highlightBlendmode = "ADD",
                }
                local itemCountPre = C_Item.GetItemCount(data.preItemID)
                macroButton:SetText(f.white("x" .. itemCountPre))

                if itemCountPre >= 5 then
                    macroButton:SetBorder(true, { 0, 1, 0, 0.8 })
                else
                    macroButton:SetBorder(true, { 1, 0, 0, 0.8 })
                end

                local items = { reagentItem, upcraftItem }

                GUTIL:ContinueOnAllItemsLoaded(items, function()
                    local reagentItemLink = reagentItem:GetItemLink() or "Unknown Item"
                    local upcraftItemLink = upcraftItem:GetItemLink() or "Unknown Item"
                    local missingDiff = 5 - itemCountPre
                    local missingText = missingDiff <= 0 and "" or
                        f.r("\nMissing " .. missingDiff .. "x " .. reagentItemLink)
                    macroButton.tooltipOptions = {
                        anchor = "ANCHOR_CURSOR_RIGHT",
                        text = f.bb("Convert 5x ") .. reagentItemLink .. "  -> " .. upcraftItemLink .. missingText
                    }
                end)
            end)
        end)
    end

    -- If current profession skill line has an enabled pre-craft buff gate, add Shatter to the quick bar.
    local skillLineID = C_TradeSkillUI.GetProfessionChildSkillLineID()
    local gate = CraftSim.PRE_CRAFT_BUFF_GATE:GetQuickBarGateForSkillLine(skillLineID)
    if gate and gate.castRecipeID then
        local recipeData = CraftSim.PRE_CRAFT_BUFF_GATE:PrepareCastRecipeDataForGate(
            CraftSim.UTIL:GetPlayerCrafterData(),
            gate.id)
        if recipeData then
            if not gate.salvagedMoteOptionKey then
                local useItemID = gate.quickBarUseItemID
                local resultItem = recipeData.resultData and recipeData.resultData.expectedItem
                if not useItemID and resultItem then
                    useItemID = resultItem:GetItemID()
                end
                local useItem = useItemID and Item:CreateFromItemID(useItemID) or nil
                local itemCount = useItemID and C_Item.GetItemCount(useItemID, true, false, true, true) or 0
                buttonList:Add(function(row)
                    local recipeCraftButton = row.columns[1].recipeCraftButton --[[@as GGUI.Button]]
                    local macroButton = row.columns[1].macroButton --[[@as GGUI.Button]]
                    local useAvailable = useItemID and itemCount > 0
                    if useAvailable then
                        macroButton:Show()
                        recipeCraftButton:Hide()
                        macroButton:SetMacroText("/use item:" .. tostring(useItemID))
                        local texture = useItem and useItem:GetItemIcon() or recipeData.recipeIcon
                        macroButton:SetTexture {
                            normal = texture,
                            pushed = texture,
                            highlight = texture,
                            highlightBlendmode = "ADD",
                        }
                        macroButton:SetText(f.white("x" .. tostring(itemCount)))
                        macroButton:SetBorder(true, { 0, 1, 0, 0.8 })
                        if useItem then
                            useItem:ContinueOnItemLoad(function()
                                macroButton.tooltipOptions = {
                                    anchor = "ANCHOR_CURSOR_RIGHT",
                                    text = f.bb("Use ") .. (useItem:GetItemLink() or "Everburning Ignition"),
                                }
                            end)
                        end
                    else
                        macroButton:Hide()
                        recipeCraftButton:Show()
                        recipeCraftButton:SetTexture {
                            normal = recipeData.recipeIcon,
                            pushed = recipeData.recipeIcon,
                            highlight = recipeData.recipeIcon,
                            highlightBlendmode = "ADD",
                        }
                        recipeCraftButton:SetText("")
                        local canCraftNow = recipeData:CanCraft(1)
                        recipeCraftButton:SetBorder(true, canCraftNow and { 0, 1, 0, 0.8 } or { 1, 0, 0, 0.8 })
                        recipeCraftButton.tooltipOptions = {
                            anchor = "ANCHOR_CURSOR_RIGHT",
                            textWrap = true,
                            text = canCraftNow and f.bb("Craft Everburning Ignition")
                                or f.bb("Queue Everburning Ignition") ..
                                "\n\n" .. f.white("Missing reagents for immediate cast."),
                        }
                        recipeCraftButton.clickCallback = function(_, mouseButton)
                            if mouseButton ~= "LeftButton" then
                                return
                            end
                            local fresh = CraftSim.PRE_CRAFT_BUFF_GATE:PrepareCastRecipeDataForGate(
                                CraftSim.UTIL:GetPlayerCrafterData(), gate.id)
                            if fresh and fresh:CanCraft(1) then
                                fresh:Craft()
                                CraftSim.CRAFTQ:ScheduleCraftQueueDisplayRefreshForDelayedCraftingState()
                            elseif fresh then
                                CraftSim.CRAFTQ.craftQueue:AddRecipe({ recipeData = fresh, amount = 1 })
                                CraftSim.CRAFTQ.UI:UpdateDisplay()
                            end
                        end
                    end
                end)
                buttonList:UpdateDisplay()
                return
            end
            local shatterHint = L("CRAFT_QUEUE_SHATTER_RIGHT_CLICK_HINT")
            buttonList:Add(function(row)
                local recipeCraftButton = row.columns[1].recipeCraftButton --[[@as GGUI.Button]]
                local macroButton = row.columns[1].macroButton --[[@as GGUI.Button]]
                macroButton:Hide()
                recipeCraftButton:Show()

                recipeCraftButton:SetTexture {
                    normal = recipeData.recipeIcon,
                    pushed = recipeData.recipeIcon,
                    highlight = recipeData.recipeIcon,
                    highlightBlendmode = "ADD",
                }

                recipeData:Update()
                local buffActive = recipeData.buffData:IsBuffActive(gate.buffID)
                local staleEffective = CraftSim.PRE_CRAFT_BUFF_GATE:IsStaleEffective(gate.id)
                local buffOkForQueue = buffActive and not staleEffective
                local loginStaleForFlags = staleEffective and buffActive
                local missingBuffForFlags = not buffActive
                local allowedToCraft = buffOkForQueue
                local statusColumnTooltip = not buffOkForQueue and
                    f.r(MidnightShatterStatusTextFromFlags(loginStaleForFlags, missingBuffForFlags)) or ""
                local reasonExtra = not buffOkForQueue and
                    CraftQueueMidnightShatterReasonTooltipFromFlags(loginStaleForFlags, missingBuffForFlags) or ""

                local function applyQuickBarShatterTooltip()
                    local activeReagentSlot = recipeData.reagentData.salvageReagentSlot.activeItem
                    local base = GetCraftQueueCraftButtonRowStatusTooltipText(allowedToCraft, statusColumnTooltip,
                        recipeData.professionGearSet)
                    local append
                    if activeReagentSlot then
                        append = FormatMidnightShatterTooltipAppend(recipeData, recipeData:CanCraft(1), reasonExtra,
                            shatterHint, activeReagentSlot)
                    else
                        append = f.bb(L("CRAFT_QUEUE_BUTTON_SHATTER")) .. reasonExtra .. shatterHint
                    end
                    recipeCraftButton.tooltipOptions = {
                        anchor = "ANCHOR_CURSOR_RIGHT",
                        textWrap = true,
                        text = base .. "\n\n" .. append,
                    }
                end

                local activeReagent = recipeData.reagentData.salvageReagentSlot.activeItem
                if activeReagent then
                    activeReagent:ContinueOnItemLoad(function()
                        applyQuickBarShatterTooltip()
                        if buffOkForQueue then
                            recipeCraftButton:SetBorder(true, { 1, 0, 0, 0.8 })
                        elseif recipeData:CanCraft(1) then
                            recipeCraftButton:SetBorder(true, { 0, 1, 0, 0.8 })
                        else
                            recipeCraftButton:SetBorder(true, { 1, 0, 0, 0.8 })
                        end
                    end)
                else
                    applyQuickBarShatterTooltip()
                    recipeCraftButton:SetBorder(true, { 1, 0, 0, 0.8 })
                end

                recipeCraftButton.clickCallback = function(_, mouseButton)
                    if mouseButton == "RightButton" then
                        ShowPreCraftBuffSalvageMoteMenu(recipeData, gate.id)
                        return
                    end
                    if mouseButton ~= "LeftButton" then
                        return
                    end
                    TriggerPreCraftGateAction(gate.id, CraftSim.UTIL:GetPlayerCrafterData(), recipeData)
                end
            end)
        end
    end

    buttonList:UpdateDisplay()
end

function CraftSim.CRAFTQ.UI:UpdateQueueDisplay()
    --- use a cache to prevent multiple redundant calls of ItemCount thus increasing performance
    CraftSim.CRAFTQ.itemCountCache = {}

    CraftSim.CRAFTQ.UI:UpdateFrameListByCraftQueue()
    local craftQueueFrame = CraftSim.CRAFTQ.frame
    local queueTab = craftQueueFrame.content.queueTab --[[@as CraftSim.CraftQueue.QueueTab]]

    --- update craft next button
    local itemsPresent = CraftSim.CRAFTQ.craftQueue and #CraftSim.CRAFTQ.craftQueue.craftQueueItems > 0
    if itemsPresent then
        -- set the craft next button to the same status as the button in the queue on pos 1
        -- if first item can be crafted (so if anything can be crafted cause the items are sorted by craftable status)
        local firstRow = queueTab.content.craftList.activeRows[1]
        local craftButton = firstRow.columns[9].craftButton --[[@as GGUI.Button]]
        local button = craftButton.frame --[[@as Button]]
        queueTab.content.craftNextButton:SetEnabled(button:IsEnabled())
        queueTab.content.craftNextButton.clickCallback = function(_, mouseButton)
            if CraftSim.CRAFTQ:IsCraftClickLocked() then
                return
            end

            local currentFirstRow = queueTab.content.craftList.activeRows[1]
            if not currentFirstRow then
                return
            end

            local currentCraftButton = currentFirstRow.columns[9].craftButton --[[@as GGUI.Button]]
            local currentButton = currentCraftButton.frame --[[@as Button]]
            local currentCallback = currentCraftButton.clickCallback
            if currentButton and currentButton:IsEnabled() and currentCallback then
                currentCallback(currentCraftButton, mouseButton or "LeftButton")
            end
        end
        queueTab.content.craftNextButton:SetText(L("CRAFT_QUEUE_BUTTON_NEXT") .. button:GetText(), 10,
            true)
    else
        queueTab.content.craftNextButton:SetEnabled(false)
        queueTab.content.craftNextButton:SetText(L("CRAFT_QUEUE_BUTTON_NOTHING_QUEUED"), 10, true)
    end

    if queueTab.content.createAuctionatorShoppingList then
        queueTab.content.createAuctionatorShoppingList:SetEnabled(CraftSim.CRAFTQ.craftQueue and
            #CraftSim.CRAFTQ.craftQueue.craftQueueItems > 0)
    end

    --- disable cache
    CraftSim.CRAFTQ.itemCountCache = nil
end

function CraftSim.CRAFTQ.UI:UpdateCraftQueueTotalProfitDisplay()
    local queueTab = CraftSim.CRAFTQ.frame.content.queueTab --[[@as GGUI.BlizzardTab]]
    local craftList = queueTab.content.craftList --[[@as GGUI.FrameList]]

    local totalAverageProfit = 0
    local totalCraftingCosts = 0

    for _, row in ipairs(craftList.activeRows) do
        local craftQueueItem = row.craftQueueItem --[[@as CraftSim.CraftQueueItem]]
        -- do not count subrecipes in the total profit or crafting costs
        if not craftQueueItem.recipeData:IsSubRecipe() then
            totalAverageProfit = totalAverageProfit + row.averageProfit
            totalCraftingCosts = totalCraftingCosts + row.craftingCosts
        end
    end

    queueTab.content.totalAverageProfit:SetText(CraftSim.UTIL:FormatMoney(totalAverageProfit, true, totalCraftingCosts))
    queueTab.content.totalCraftingCosts:SetText(f.r(CraftSim.UTIL:FormatMoney(totalCraftingCosts)))
end

function CraftSim.CRAFTQ.UI:UpdateDisplay()
    CraftSim.CRAFTQ.UI:UpdateQuickAccessBarDisplay()
    CraftSim.CRAFTQ.UI:UpdateQueueDisplay()
    CraftSim.CRAFTQ.UI:UpdateCraftListsDisplay()
    CraftSim.CRAFTQ.UI:UpdateCraftListsRecipeDisplay()
end

---@param craftQueueItem CraftSim.CraftQueueItem
function CraftSim.CRAFTQ.UI:UpdateEditRecipeFrameDisplay(craftQueueItem)
    ---@type CraftSim.CRAFTQ.EditRecipeFrame
    local editRecipeFrame = GGUI:GetFrame(CraftSim.INIT.FRAMES, CraftSim.CONST.FRAMES.CRAFT_QUEUE_EDIT_RECIPE)
    local recipeData = craftQueueItem.recipeData
    recipeData.reagentData:RefreshSlotStatus()
    recipeData:RefreshCooldownDataIfProfessionOpen()
    craftQueueItem:CalculateCanCraft()
    editRecipeFrame.craftQueueItem = craftQueueItem
    ---@type CraftSim.CRAFTQ.EditRecipeFrame.Content
    editRecipeFrame.content = editRecipeFrame.content

    editRecipeFrame.content.recipeName:SetText(GUTIL:IconToText(recipeData.recipeIcon, 15, 15) ..
        " " .. recipeData.recipeName .. CraftSim.UTIL:GetRecipeCooldownChargesInlineSuffix(recipeData))
    editRecipeFrame.content.averageProfitValue:SetText(CraftSim.UTIL:FormatMoney(recipeData.averageProfitCached, true,
        recipeData.priceData.craftingCosts))
    local concentrationCostText = ""
    if editRecipeFrame.craftQueueItem.concentrating then
        concentrationCostText = " + " ..
            GUTIL:IconToText(CraftSim.CONST.CONCENTRATION_ICON, 15, 15) ..
            " " .. f.gold(editRecipeFrame.craftQueueItem.recipeData.concentrationCost)
    end

    local craftingCosts
    if recipeData.orderData then
        craftingCosts = recipeData.priceData.craftingCostsNoOrderReagents
    else
        craftingCosts = recipeData.priceData.craftingCosts
    end
    editRecipeFrame.content.craftingCostsValue:SetText(GUTIL:ColorizeText(
        CraftSim.UTIL:FormatMoney(craftingCosts), GUTIL.COLORS.RED) .. concentrationCostText)
    local concentrationValue = recipeData:GetConcentrationValue()
    editRecipeFrame.content.concentrationValue:SetText(CraftSim.UTIL:FormatMoney(concentrationValue, true))
    if recipeData.supportsQualities and recipeData.concentrationData and recipeData.concentrationCost > 0 then
        local concentrationData = recipeData.concentrationData
        if craftQueueItem.isCrafter then
            concentrationData:Update()
        end
        local requiredAmount = recipeData.concentrationCost * craftQueueItem.amount
        local formatMode = CraftSim.DB.OPTIONS:Get("CONCENTRATION_TRACKER_FORMAT_MODE")
        local useUSFormat = formatMode == CraftSim.CONCENTRATION_TRACKER.UI.FORMAT_MODE.AMERICA_MAX_DATE
        if concentrationData:GetCurrentAmount() < requiredAmount then
            editRecipeFrame.content.concentrationDateTitle:SetVisible(true)
            editRecipeFrame.content.concentrationDateValue:SetText(f.bb(concentrationData:GetFormattedDateUntil(
                requiredAmount, useUSFormat)))
            editRecipeFrame.content.concentrationDateValue:SetVisible(true)
        else
            editRecipeFrame.content.concentrationDateTitle:SetVisible(true)
            editRecipeFrame.content.concentrationDateValue:SetText(f.g("Ready"))
            editRecipeFrame.content.concentrationDateValue:SetVisible(true)
        end
    else
        editRecipeFrame.content.concentrationDateTitle:SetVisible(false)
        editRecipeFrame.content.concentrationDateValue:SetVisible(false)
    end

    -- required quality reagents
    if recipeData.hasQualityReagents then
        editRecipeFrame.content.reagentList:Populate(recipeData)
    else
        editRecipeFrame.content.reagentList:Hide()
    end

    -- optionals
    local optionalSelectors = editRecipeFrame.content.optionalReagentSelectors
    editRecipeFrame.content.optionalReagentsFrame:SetCollapsed(#recipeData.reagentData.optionalReagentSlots == 0)
    editRecipeFrame.content.optionalReagentsTitle:SetVisible(#recipeData.reagentData.optionalReagentSlots > 0)
    for selectorIndex, selector in pairs(optionalSelectors) do
        local optionalSlot = recipeData.reagentData.optionalReagentSlots[selectorIndex]
        if optionalSlot then
            selector.slot = optionalSlot
            selector:SetItems(optionalSlot:GetItemSelectorEntries())
            if optionalSlot.activeReagent then
                if optionalSlot.activeReagent:IsCurrency() then
                    selector:SetSelectedCurrency(optionalSlot.activeReagent.currencyID,
                        optionalSlot.activeReagent.qualityID)
                else
                    selector:SetSelectedItem(optionalSlot.activeReagent.item)
                end
            else
                selector:SetSelectedItem(nil)
            end
            selector:Show()
        else
            selector.slot = nil
            selector:SetItems({})
            selector:Hide()
        end
    end

    -- finishing
    local finishingSelectors = editRecipeFrame.content.finishingReagentSelectors
    editRecipeFrame.content.finishingReagentsTitle:SetVisible(#recipeData.reagentData.finishingReagentSlots > 0)
    for selectorIndex, selector in pairs(finishingSelectors) do
        local finishingSlot = recipeData.reagentData.finishingReagentSlots[selectorIndex]
        if finishingSlot then
            selector.slot = finishingSlot
            selector:SetItems(finishingSlot:GetItemSelectorEntries())
            if finishingSlot.activeReagent then
                if finishingSlot.activeReagent:IsCurrency() then
                    selector:SetSelectedCurrency(finishingSlot.activeReagent.currencyID,
                        finishingSlot.activeReagent.qualityID)
                else
                    selector:SetSelectedItem(finishingSlot.activeReagent.item)
                end
            else
                selector:SetSelectedItem(nil)
            end
            selector:Show()
        else
            selector.slot = nil
            selector:SetItems({})
            selector:Hide()
        end
    end

    -- Required Selectable
    local requiredSelectableReagentSelector = editRecipeFrame.content.requiredSelectableReagentSelectors[1]
    editRecipeFrame.content.requiredSelectableReagentTitle:SetVisible(recipeData.reagentData
        :HasRequiredSelectableReagent())
    local requiredSelectableReagentSlot = recipeData.reagentData.requiredSelectableReagentSlot
    if requiredSelectableReagentSlot then
        requiredSelectableReagentSelector.slot = requiredSelectableReagentSlot
        requiredSelectableReagentSelector:SetItems(requiredSelectableReagentSlot:GetItemSelectorEntries())
        if requiredSelectableReagentSlot.activeReagent then
            if requiredSelectableReagentSlot.activeReagent:IsCurrency() then
                requiredSelectableReagentSelector:SetSelectedCurrency(
                    requiredSelectableReagentSlot.activeReagent.currencyID,
                    requiredSelectableReagentSlot.activeReagent.qualityID)
            else
                requiredSelectableReagentSelector:SetSelectedItem(requiredSelectableReagentSlot.activeReagent.item)
            end
        else
            requiredSelectableReagentSelector:SetSelectedItem(nil)
        end
        requiredSelectableReagentSelector:Show()
    else
        requiredSelectableReagentSelector.slot = nil
        requiredSelectableReagentSelector:SetItems({})
        requiredSelectableReagentSelector:Hide()
    end

    local gearSelectors = editRecipeFrame.content.professionGearSelectors
    local professionGearSet = recipeData.professionGearSet
    -- profession gear  1 - gear 1, 2 - gear 2, 3 - tool
    if not recipeData.isCooking then
        gearSelectors[1]:SetSelectedItem(professionGearSet.gear1.item)
        gearSelectors[1].professionGear = professionGearSet.gear1
        gearSelectors[1]:Show()
        gearSelectors[2]:SetSelectedItem(professionGearSet.gear2.item)
        gearSelectors[2].professionGear = professionGearSet.gear2
        gearSelectors[3]:SetSelectedItem(professionGearSet.tool.item)
        gearSelectors[3].professionGear = professionGearSet.tool

        -- fill the selectors with profession items from the players bag but exclude for each selector all items that are selected
        local inventoryGear = CraftSim.TOPGEAR:GetProfessionGearFromInventory(recipeData)
        local equippedGear = CraftSim.ProfessionGearSet(recipeData)
        equippedGear:LoadCurrentEquippedSet()
        local equippedGearList = CraftSim.GUTIL:Filter(equippedGear:GetProfessionGearList(),
            function(gear) return gear and gear.item ~= nil end)
        ---@type CraftSim.ProfessionGear[]
        local allGear = CraftSim.GUTIL:Concat({ inventoryGear, equippedGearList })

        allGear = GUTIL:ToSet(allGear, function(gear)
            local compareLink = gear.item:GetItemLink():gsub("Player.':", "")
            return compareLink
        end)

        local gearSlotItems = GUTIL:Filter(allGear, function(gear)
            local isGearItem = gear.item:GetInventoryType() == Enum.InventoryType.IndexProfessionGearType
            if not isGearItem then
                return false
            end

            if gearSelectors[1].professionGear:Equals(gear) or gearSelectors[2].professionGear:Equals(gear) then
                return false
            end
            return true
        end)
        local toolSlotItems = GUTIL:Filter(allGear, function(gear)
            local isToolItem = gear.item:GetInventoryType() == Enum.InventoryType.IndexProfessionToolType
            if not isToolItem then
                return false
            end

            if gearSelectors[3].professionGear:Equals(gear) then
                return false
            end
            return true
        end)

        gearSelectors[1]:SetItems(GUTIL:Map(gearSlotItems, function(g) return g.item end))
        gearSelectors[2]:SetItems(GUTIL:Map(gearSlotItems, function(g) return g.item end))
        gearSelectors[3]:SetItems(GUTIL:Map(toolSlotItems, function(g) return g.item end))
    else
        gearSelectors[1]:Hide()
        gearSelectors[1].professionGear = nil
        gearSelectors[2]:SetSelectedItem(professionGearSet.gear2.item)
        gearSelectors[2].professionGear = professionGearSet.gear2
        gearSelectors[3]:SetSelectedItem(professionGearSet.tool.item)
        gearSelectors[3].professionGear = professionGearSet.tool

        -- fill the selectors with profession items from the players bag but exclude for each selector all items that are selected
        local inventoryGear = CraftSim.TOPGEAR:GetProfessionGearFromInventory(recipeData)
        local equippedGear = CraftSim.ProfessionGearSet(recipeData)
        equippedGear:LoadCurrentEquippedSet()
        local equippedGearList = CraftSim.GUTIL:Filter(equippedGear:GetProfessionGearList(),
            function(gear) return gear and gear.item ~= nil end)
        local allGear = CraftSim.GUTIL:Concat({ inventoryGear, equippedGearList })

        local gearSlotItems = GUTIL:Filter(allGear, function(gear)
            local isGearItem = gear.item:GetInventoryType() == Enum.InventoryType.IndexProfessionGearType
            if not isGearItem then
                return false
            end

            if gearSelectors[2].professionGear:Equals(gear) then
                return false
            end
            return true
        end)
        local toolSlotItems = GUTIL:Filter(allGear, function(gear)
            local isToolItem = gear.item:GetInventoryType() == Enum.InventoryType.IndexProfessionToolType
            if not isToolItem then
                return false
            end

            if gearSelectors[3].professionGear:Equals(gear) then
                return false
            end
            return true
        end)

        gearSelectors[2]:SetItems(GUTIL:Map(gearSlotItems, function(g) return g.item end))
        gearSelectors[3]:SetItems(GUTIL:Map(toolSlotItems, function(g) return g.item end))
    end

    local resultData = recipeData.resultData

    local resultList = editRecipeFrame.content.resultList --[[@as GGUI.FrameList]]

    resultList:Remove()

    resultList:Add(function(row, columns)
        local iconColumn = columns[1]
        row.qualityID = resultData.expectedQuality --[[@as QualityID]]

        iconColumn.icon:SetItem(resultData.expectedItem)
    end)

    resultList:UpdateDisplay()

    editRecipeFrame.content.concentrationCB:SetVisible(craftQueueItem.recipeData.supportsQualities)

    editRecipeFrame.content.concentrationCB:SetChecked(craftQueueItem.concentrating)
end

---@param row GGUI.FrameList.Row
---@param craftQueueItem CraftSim.CraftQueueItem
function CraftSim.CRAFTQ.UI:UpdateCraftQueueRowByCraftQueueItem(row, craftQueueItem)
    local recipeData = craftQueueItem.recipeData
    local profilingID = "- FrameListUpdate Add Recipe: " .. craftQueueItem.recipeData.recipeName
    CraftSim.DEBUG:StartProfiling(profilingID)
    local columns = row.columns
    local crafterColumn = columns[1] --[[@as CraftSim.CraftQueue.CraftList.CrafterColumn]]
    local recipeColumn = columns[2] --[[@as CraftSim.CraftQueue.CraftList.RecipeColumn]]
    local resultColumn = columns[3] --[[@as CraftSim.CraftQueue.CraftList.ResultColumn]]
    local averageProfitColumn = columns[4] --[[@as CraftSim.CraftQueue.CraftList.AverageProfitColumn]]
    local craftingCostsColumn = columns[5] --[[@as CraftSim.CraftQueue.CraftList.CraftingCostColumn]]
    local concentrationColumn = columns[6] --[[@as CraftSim.CraftQueue.CraftList.ConcentrationColumn]]
    local craftAbleColumn = columns[7] --[[@as CraftSim.CraftQueue.CraftList.CraftAbleColumn]]
    local craftAmountColumn = columns[8] --[[@as CraftSim.CraftQueue.CraftList.CraftAmountColumn]]
    local craftButtonColumn = columns[9] --[[@as CraftSim.CraftQueue.CraftList.CraftButtonColumn]]

    row.craftQueueItem = craftQueueItem

    crafterColumn.text:SetText(recipeData:GetFormattedCrafterText(false, true, 20, 20))

    -- update price data and profit?
    recipeData.priceData:Update()
    recipeData:GetAverageProfit()

    if recipeData.orderData then
        row.craftingCosts = recipeData.priceData.craftingCostsNoOrderReagents * craftQueueItem.amount
    else
        row.craftingCosts = recipeData.priceData.craftingCosts * craftQueueItem.amount
    end

    row.averageProfit = (recipeData.averageProfitCached or recipeData:GetAverageProfit()) *
        craftQueueItem.amount

    local upCraftText = ""
    if recipeData:IsSubRecipe() then
        local upgradeArrow = CreateAtlasMarkup(CraftSim.CONST.ATLAS_TEXTURES.UPGRADE_ARROW_2, 10, 10)
        upCraftText = " " ..
            upgradeArrow --.. "(" .. craftQueueItem.recipeData.subRecipeDepth .. ")"
    end
    if recipeData.orderData then
        upCraftText = upCraftText .. " " .. CraftSim.UTIL:GetOrderTypeText(recipeData.orderData.orderType)
    end
    local firstCraftText = ""
    if recipeData.recipeInfo and recipeData.recipeInfo.firstCraft then
        firstCraftText = string.format(" %s %s", CreateAtlasMarkup(CraftSim.CONST.FIRST_CRAFT_KP_ICON, 15, 15),
            f.bb("1KP"))
    end
    local recipeRestockMaxText = ""
    local recipeEntry = CraftSim.DB.CRAFT_LISTS:GetRecipeEntry(recipeData.craftListID, recipeData:GetCrafterUID(),
        recipeData.recipeID)
    if recipeEntry then
        local recipeRestockMax = recipeEntry.restockMaxAmount
        if recipeRestockMax and recipeRestockMax > 0 then
            recipeRestockMaxText = " " .. f.l("[" .. tostring(recipeRestockMax) .. "]")
        end
    end

    recipeColumn.text:SetText(recipeData.recipeName ..
        recipeRestockMaxText ..
        upCraftText .. CraftSim.UTIL:GetRecipeCooldownChargesInlineSuffix(recipeData) .. firstCraftText)

    ApplyResultColumnEntries(resultColumn, BuildCraftQueueResultEntries(recipeData, {}), recipeData)
    local rewardItems = BuildCraftQueueRewardItemRows(recipeData, false)
    local rewardItemMixins = GUTIL:Filter(GUTIL:Map(rewardItems, function(r) return r.item end), function(m)
        return m ~= nil
    end)
    GUTIL:ContinueOnAllItemsLoaded(rewardItemMixins, function()
        local entries = BuildCraftQueueResultEntries(recipeData, rewardItems)
        PrioritizeFirstCraftMoxieInResultEntries(recipeData, entries)
        ApplyResultColumnEntries(resultColumn, entries, recipeData)
    end)

    if craftQueueItem.recipeData:IsSubRecipe() then
        averageProfitColumn.text:SetText(f.g("-"))
        craftingCostsColumn.text:SetText(f.g("-"))
    else
        averageProfitColumn.text:SetText(CraftSim.UTIL:FormatMoney(select(1, row.averageProfit), true, row.craftingCosts))
        craftingCostsColumn.text:SetText(f.r(CraftSim.UTIL:FormatMoney(row.craftingCosts)))
    end

    local concentrationData = craftQueueItem.recipeData.concentrationData
    local concentrationTimeLine = ""
    if craftQueueItem.recipeData.concentrating and concentrationData then
        if craftQueueItem.isCrafter then
            concentrationData:Update() -- consider concentration usage on crafting before refresh
        end
        local concentrationCost = craftQueueItem.recipeData.concentrationCost * craftQueueItem.amount
        local currentAmount = concentrationData:GetCurrentAmount()
        if concentrationCost <= currentAmount then
            concentrationColumn.text:SetText(f.g(concentrationCost))
        elseif craftQueueItem.recipeData.concentrationCost < currentAmount then
            concentrationColumn.text:SetText(f.l(concentrationCost))
        else
            concentrationColumn.text:SetText(f.r(concentrationCost))
        end
        if concentrationCost > currentAmount then
            local formatMode = CraftSim.DB.OPTIONS:Get("CONCENTRATION_TRACKER_FORMAT_MODE")
            local useUSFormat = formatMode == CraftSim.CONCENTRATION_TRACKER.UI.FORMAT_MODE.AMERICA_MAX_DATE
            local estimatedText = concentrationData:GetEstimatedTimeUntilEnoughText(concentrationCost, useUSFormat)
            if estimatedText then
                concentrationTimeLine = "\n" .. estimatedText
            end
        end
    else
        concentrationColumn.text:SetText(f.g("-"))
    end

    local craftOrderInfoText = ""

    if recipeData.orderData then
        craftOrderInfoText = L("CRAFT_QUEUE_ORDER_CUSTOMER") .. f.bb(recipeData.orderData.customerName or "<?>")

        if recipeData.orderData.orderType == Enum.CraftingOrderType.Npc then
            craftOrderInfoText = craftOrderInfoText .. f.grey(" (NPC)")
        end

        if recipeData.orderData.customerNotes and recipeData.orderData.customerNotes ~= "" then
            craftOrderInfoText = craftOrderInfoText .. f.grey("\n" .. recipeData.orderData.customerNotes)
        end

        if recipeData.orderData.minQuality then
            craftOrderInfoText = craftOrderInfoText ..
                L("CRAFT_QUEUE_ORDER_MINIMUM_QUALITY") ..
                GUTIL:GetQualityIconString(recipeData.orderData.minQuality, 15, 15)
        end
    end

    local firstCraftRewardLine = ""
    if recipeData.recipeInfo and recipeData.recipeInfo.firstCraft then
        firstCraftRewardLine = "\n- " .. CreateAtlasMarkup(CraftSim.CONST.FIRST_CRAFT_KP_ICON, 20, 20) .. " First Craft"
    end

    -- if we got npcOrderRewards than we need to delay the tooltip display data

    local cooldownChargesTooltipLine = ""
    do
        local cdTip = recipeData:GetCooldownDataForRecipeCrafter()
        if cdTip and cdTip.isCooldownRecipe then
            local curTip = cdTip:GetCurrentCharges() or 0
            cooldownChargesTooltipLine = f.white("\n" ..
                string.format(L("RECIPE_COOLDOWN_CHARGES_TOOLTIP"), curTip, cdTip.maxCharges))
        end
    end
    local tooltipHeader = recipeData:GetFormattedCrafterText(true, true, 20, 20) ..
        "\n" .. f.bb(recipeData.recipeName) .. cooldownChargesTooltipLine .. "\n\n"

    if CraftQueueOrderRewardsTooltipSectionWanted(recipeData) then
        craftOrderInfoText = craftOrderInfoText .. L("CRAFT_QUEUE_ORDER_REWARDS")
        local rewardItems = BuildCraftQueueRewardItemRows(recipeData, true)
        GUTIL:ContinueOnAllItemsLoaded(GUTIL:Map(rewardItems, function(reward) return reward.item end), function()
            for _, reward in ipairs(rewardItems) do
                if reward.currency then
                    local currencyLink = C_CurrencyInfo.GetCurrencyLink(reward.currency, reward.count)
                    local currencyInfo = C_CurrencyInfo.GetBasicCurrencyInfo(reward.currency, reward.count)
                    if currencyInfo then
                        local line = "\n- " ..
                            GUTIL:IconToText(currencyInfo.icon, 20, 20) ..
                            " " .. (currencyLink or currencyInfo.name or "<?>") .. " x" .. reward.count
                        if tContains(CraftSim.CONST.MOXIE_CURRENCY_IDS, reward.currency) then
                            local perUnit = CraftSim.UTIL:GetPatronOrderMoxieCopperPerUnit(reward.currency)
                            local count = tonumber(reward.count) or 0
                            local moxieCopper = perUnit * count
                            if moxieCopper > 0 then
                                line = line ..
                                    string.format(L("CRAFT_QUEUE_MOXIE_GOLD_IN_TOOLTIP"),
                                        CraftSim.UTIL:FormatMoney(moxieCopper, true, nil, true))
                            end
                        end
                        craftOrderInfoText = craftOrderInfoText .. line
                    end
                elseif reward.item then
                    local itemLink = reward.item:GetItemLink()
                    local itemName = reward.item:GetItemName()
                    local displayText = itemLink
                    if not displayText or displayText:match("%[%]") then
                        displayText = itemName and ("[" .. itemName .. "]") or reward.rawItemLink or "<?>"
                    end
                    craftOrderInfoText = craftOrderInfoText ..
                        "\n- " ..
                        GUTIL:IconToText(reward.item:GetItemIcon(), 20, 20) ..
                        " " .. displayText .. " x" .. reward.count
                end
            end

            -- Show gold reward under the Rewards section too
            if recipeData.orderData then
                local tipAmount = tonumber(recipeData.orderData.tipAmount) or 0
                local cutAmount = tonumber(recipeData.orderData.consortiumCut) or 0
                local commission = tipAmount - cutAmount
                if commission > 0 then
                    craftOrderInfoText = craftOrderInfoText ..
                        "\n- " .. CraftSim.UTIL:FormatMoney(commission, true) .. " (included in profit)"
                end
            end

            craftOrderInfoText = craftOrderInfoText .. firstCraftRewardLine

            row.tooltipOptions = {
                text = tooltipHeader .. recipeData.reagentData:GetTooltipText(craftQueueItem.amount,
                        craftQueueItem.recipeData:GetCrafterUID()) ..
                    f.white(craftOrderInfoText) .. concentrationTimeLine,
                owner = row.frame,
                anchor = "ANCHOR_CURSOR",
            }
        end)
    else
        local moxieID = (recipeData.recipeInfo and recipeData.recipeInfo.firstCraft) and
            CraftSim.UTIL:GetRecipeProfessionMoxieCurrencyID(recipeData) or nil
        local moxieCount = CraftSim.CONST.PATRON_ORDER_FIRST_CRAFT_EXTRA_MOXIE
        local moxieLine = ""
        if moxieID then
            local currencyLink = C_CurrencyInfo.GetCurrencyLink(moxieID, moxieCount)
            local currencyInfo = C_CurrencyInfo.GetBasicCurrencyInfo(moxieID, moxieCount)
            if currencyInfo then
                moxieLine = "\n- " ..
                    GUTIL:IconToText(currencyInfo.icon, 20, 20) ..
                    " " .. (currencyLink or currencyInfo.name or "<?>") .. " x" .. moxieCount
                local moxieCopper = CraftSim.UTIL:GetPatronOrderMoxieCopperPerUnit(moxieID) * moxieCount
                if moxieCopper > 0 then
                    moxieLine = moxieLine ..
                        string.format(L("CRAFT_QUEUE_MOXIE_GOLD_IN_TOOLTIP"),
                            CraftSim.UTIL:FormatMoney(moxieCopper, true))
                end
            end
        end
        if firstCraftRewardLine ~= "" or moxieLine ~= "" then
            craftOrderInfoText = craftOrderInfoText .. "\nRewards:" .. moxieLine .. firstCraftRewardLine
        end
        row.tooltipOptions = {
            text = tooltipHeader .. recipeData.reagentData:GetTooltipText(craftQueueItem.amount,
                    craftQueueItem.recipeData:GetCrafterUID()) ..
                f.white(craftOrderInfoText) .. concentrationTimeLine,
            owner = row.frame,
            anchor = "ANCHOR_CURSOR",
        }
    end

    local craftAbleAmount = math.min(craftQueueItem.craftAbleAmount, craftQueueItem.amount)

    if craftAbleAmount == 0 or not craftQueueItem.allowedToCraft then
        craftAbleColumn.text:SetText(f.r(craftAbleAmount))
    elseif craftAbleAmount == craftQueueItem.amount then
        craftAbleColumn.text:SetText(f.g(craftAbleAmount))
    else
        craftAbleColumn.text:SetText(f.l(craftAbleAmount))
    end

    row.frame:SetSize(row:GetWidth(), row.frameList.rowHeight)
    craftAmountColumn.input.textInput:SetText(craftQueueItem.amount, false)
    craftAmountColumn.input.onEnterPressedCallback =
        function(_, value)
            craftQueueItem.amount = value or 1
            craftAmountColumn.unsavedMarker:Hide()
            CraftSim.CRAFTQ.UI:UpdateQueueDisplay()
        end

    craftAmountColumn.input:SetVisible(not craftQueueItem.recipeData:IsSubRecipe())

    craftAmountColumn.inputText:SetVisible(craftQueueItem.recipeData:IsSubRecipe())
    craftAmountColumn.inputText:SetText(craftQueueItem.amount)

    craftButtonColumn.craftButton.clickCallback = nil

    local statusColumnTooltip = ""
    local craftClickLocked = CraftSim.CRAFTQ:IsCraftClickLocked()

    if not craftQueueItem.learned then
        local nL = (statusColumnTooltip ~= "" and "\n\n") or ""
        statusColumnTooltip = statusColumnTooltip .. f.r(nL .. "Not Learned")
    end
    if not craftQueueItem.notOnCooldown then
        local nL = (statusColumnTooltip ~= "" and "\n\n") or ""
        statusColumnTooltip = statusColumnTooltip .. f.r(nL .. "On Cooldown")
    end
    if not craftQueueItem.isCrafter then
        local nL = (statusColumnTooltip ~= "" and "\n\n") or ""
        statusColumnTooltip = statusColumnTooltip .. f.r(nL .. "Alt Character")
    end
    if not craftQueueItem.canCraftOnce then
        local nL = (statusColumnTooltip ~= "" and "\n\n") or ""
        statusColumnTooltip = statusColumnTooltip .. f.r(nL .. "Missing Reagents")
    end
    if not craftQueueItem.gearEquipped then
        local nL = (statusColumnTooltip ~= "" and "\n\n") or ""
        statusColumnTooltip = statusColumnTooltip .. f.r(nL .. "Wrong Profession Tools")
    end
    if not craftQueueItem.correctProfessionOpen then
        local nL = (statusColumnTooltip ~= "" and "\n\n") or ""
        statusColumnTooltip = statusColumnTooltip .. f.r(nL .. "Wrong Profession")
    end
    if craftQueueItem.pcbgData.needsStep then
        local nL = (statusColumnTooltip ~= "" and "\n\n") or ""
        statusColumnTooltip = statusColumnTooltip .. f.r(nL .. CraftQueueMidnightShatterStatusText(craftQueueItem))
    end

    craftButtonColumn.craftButton:SetText(L("CRAFT_QUEUE_BUTTON_CRAFT"))
    craftButtonColumn.craftButton.frame:SetAlpha(1)

    if recipeData.orderData and craftQueueItem.isCrafter and craftQueueItem.correctProfessionOpen then
        local accessToOrders = C_TradeSkillUI.IsNearProfessionSpellFocus(recipeData.professionData.professionInfo
            .profession)

        if accessToOrders then
            local claimedOrder = C_CraftingOrders.GetClaimedOrder()

            if claimedOrder and claimedOrder.orderID == recipeData.orderData.orderID then
                local pendingSubmit = CraftSim.CRAFTQ:IsPendingWorkOrderSubmit(recipeData.orderData.orderID)
                if claimedOrder.isFulfillable then
                    CraftSim.CRAFTQ:ClearPendingWorkOrderSubmit(recipeData.orderData.orderID)
                    craftButtonColumn.craftButton:SetEnabled(true)
                    craftButtonColumn.craftButton:SetText(L("CRAFT_QUEUE_BUTTON_SUBMIT"))

                    craftButtonColumn.craftButton.clickCallback = function()
                        -- Disarm stale callbacks immediately so spam clicks cannot trigger a second action
                        -- while Blizzard updates claimed-order state.
                        craftButtonColumn.craftButton.clickCallback = nil
                        local queueTab = CraftSim.CRAFTQ.frame and CraftSim.CRAFTQ.frame.content and
                            CraftSim.CRAFTQ.frame.content.queueTab
                        if queueTab and queueTab.content and queueTab.content.craftNextButton then
                            queueTab.content.craftNextButton.clickCallback = nil
                        end
                        CraftSim.CRAFTQ:BeginCraftClickLock()
                        CraftSim.CRAFTQ:ClearPendingWorkOrderSubmit(recipeData.orderData.orderID)
                        C_CraftingOrders.FulfillOrder(recipeData.orderData.orderID, "",
                            recipeData.professionData.professionInfo.profession)
                        CraftSim.CRAFTQ.craftQueue:Remove(craftQueueItem)
                        self:UpdateDisplay()
                    end
                elseif pendingSubmit then
                    craftButtonColumn.craftButton:SetEnabled(true)
                    craftButtonColumn.craftButton:SetText(L("CRAFT_QUEUE_BUTTON_CRAFT"))
                elseif claimedOrder.minQuality and (craftQueueItem.recipeData.resultData.expectedQuality < claimedOrder.minQuality) then
                    craftButtonColumn.craftButton:SetEnabled(false)
                    craftButtonColumn.craftButton:SetText(GUTIL:GetQualityIconString(claimedOrder.minQuality, 25, 25))
                elseif not craftQueueItem.gearEquipped then
                    craftButtonColumn.craftButton:SetEnabled(true)
                    craftButtonColumn.craftButton:SetText(L("CRAFT_QUEUE_BUTTON_EQUIP_TOOLS"))
                    craftButtonColumn.craftButton.clickCallback = function()
                        recipeData.professionGearSet:Equip()
                    end
                elseif craftQueueItem.pcbgData.needsStep and craftQueueItem.pcbgData.recipeData then
                    SetCraftQueueRowShatterCraftButton(craftButtonColumn, craftQueueItem, recipeData,
                        statusColumnTooltip)
                elseif craftQueueItem.allowedToCraft then
                    craftButtonColumn.craftButton:SetEnabled(true)
                    craftButtonColumn.craftButton:SetText(L("CRAFT_QUEUE_BUTTON_CRAFT"))
                    craftButtonColumn.craftButton.clickCallback = function()
                        if CraftSim.CRAFTQ:IsCraftClickLocked() then
                            return
                        end
                        local currentClaimedOrder = C_CraftingOrders.GetClaimedOrder()
                        if not (currentClaimedOrder and recipeData.orderData and
                                currentClaimedOrder.orderID == recipeData.orderData.orderID) then
                            CraftSim.CRAFTQ.UI:UpdateDisplay()
                            return
                        end
                        local orderID = recipeData.orderData and recipeData.orderData.orderID
                        if CraftSim.CRAFTQ:IsPendingWorkOrderSubmit(orderID) then
                            CraftSim.CRAFTQ.UI:UpdateDisplay()
                            return
                        end
                        -- Mark immediately to block double-craft clicks before crafted-result event arrives.
                        CraftSim.CRAFTQ:MarkPendingWorkOrderSubmit(orderID)
                        CraftSim.CRAFTQ:BeginCraftClickLock()
                        CraftSim.CRAFTQ.CraftSimCalledCraftRecipe = true
                        recipeData:Craft(math.min(craftQueueItem.craftAbleAmount, craftQueueItem.amount))
                        CraftSim.CRAFTQ.CraftSimCalledCraftRecipe = false
                        CraftSim.CRAFTQ.UI:UpdateDisplay()
                    end
                else
                    craftButtonColumn.craftButton:SetEnabled(false)
                    craftButtonColumn.craftButton:SetText(L("CRAFT_QUEUE_BUTTON_CLAIMED"))
                end
            elseif claimedOrder then
                craftButtonColumn.craftButton:SetEnabled(false)
                craftButtonColumn.craftButton:SetText(L("CRAFT_QUEUE_BUTTON_CRAFT"))
            else
                craftButtonColumn.craftButton:SetEnabled(true)
                craftButtonColumn.craftButton:SetText(L("CRAFT_QUEUE_BUTTON_CLAIM"))
                craftButtonColumn.craftButton.clickCallback = function()
                    C_CraftingOrders.ClaimOrder(recipeData.orderData.orderID,
                        recipeData.professionData.professionInfo.profession)
                end
            end
        else
            craftButtonColumn.craftButton:SetEnabled(false) --[[@as GGUI.Button]]
            craftButtonColumn.craftButton:SetText(L("CRAFT_QUEUE_BUTTON_ORDER"))
        end
    else
        local shouldEquipTools = craftQueueItem.isCrafter and craftQueueItem.correctProfessionOpen and
            not craftQueueItem.gearEquipped
        if shouldEquipTools then
            craftButtonColumn.craftButton:SetEnabled(true)
            craftButtonColumn.craftButton:SetText(L("CRAFT_QUEUE_BUTTON_EQUIP_TOOLS"))
            craftButtonColumn.craftButton.clickCallback = function()
                recipeData.professionGearSet:Equip()
            end
        elseif craftQueueItem.pcbgData.needsStep and craftQueueItem.pcbgData.recipeData then
            SetCraftQueueRowShatterCraftButton(craftButtonColumn, craftQueueItem, recipeData, statusColumnTooltip)
        else
            craftButtonColumn.craftButton:SetEnabled(craftQueueItem.allowedToCraft)
            if craftQueueItem.allowedToCraft then
                craftButtonColumn.craftButton:SetText(L("CRAFT_QUEUE_BUTTON_CRAFT"))
                craftButtonColumn.craftButton.clickCallback = function()
                    if CraftSim.CRAFTQ:IsCraftClickLocked() then
                        return
                    end
                    CraftSim.CRAFTQ:BeginCraftClickLock()
                    CraftSim.CRAFTQ.CraftSimCalledCraftRecipe = true
                    CraftSim.CRAFTQ.currentlyCraftedCraftListID = craftQueueItem.recipeData.craftListID
                    recipeData:Craft(math.min(craftQueueItem.craftAbleAmount, craftQueueItem.amount))
                    CraftSim.CRAFTQ.currentlyCraftedCraftListID = nil
                    CraftSim.CRAFTQ.CraftSimCalledCraftRecipe = false
                    CraftSim.CRAFTQ.UI:UpdateDisplay()
                end
            end
        end
    end

    local craftBtn = craftButtonColumn.craftButton
    if craftBtn.frame:GetText() == L("CRAFT_QUEUE_BUTTON_SUBMIT") then
        craftBtn.tooltipOptions = nil
    elseif craftQueueItem.pcbgData.needsStep and craftQueueItem.pcbgData.recipeData then
        -- tooltip set in SetCraftQueueRowShatterCraftButton
    else
        SetCraftQueueCraftButtonRowStatusTooltip(craftBtn, craftQueueItem.allowedToCraft,
            statusColumnTooltip, craftQueueItem.recipeData.professionGearSet)
    end
    SyncCraftQueueButtonDisabledTooltipProxy(craftBtn)

    CraftSim.DEBUG:StopProfiling(profilingID)
end
