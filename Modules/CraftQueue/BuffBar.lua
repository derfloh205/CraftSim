---@class CraftSim
local CraftSim = select(2, ...)

local GGUI = CraftSim.GGUI
local GUTIL = CraftSim.GUTIL

---@class CraftSim.CRAFTQ.UI
CraftSim.CRAFTQ.UI = CraftSim.CRAFTQ.UI

local f = GUTIL:GetFormatter()

local BUFF_BAR_BUTTON_SIZE = 26

---@class CraftSim.CRAFTQ.BuffBarPhialData
---@field buffID number
---@field itemIDs number[]
---@field expansionID CraftSim.EXPANSION_IDS

--- Phial data for buff bar buttons
---@type CraftSim.CRAFTQ.BuffBarPhialData[]
local PHIAL_DATA = {
    -- TWW
    {
        buffID = CraftSim.CONST.BUFF_IDS.PHIAL_OF_CONCENTRATED_INGENUITY,
        itemIDs = CraftSim.CONST.ITEM_IDS.PHIALS_TWW.PHIAL_OF_CONCENTRATED_INGENUITY,
        expansionID = CraftSim.CONST.EXPANSION_IDS.THE_WAR_WITHIN,
    },
    {
        buffID = CraftSim.CONST.BUFF_IDS.PHIAL_OF_BOUNTIFUL_SEASONS,
        itemIDs = CraftSim.CONST.ITEM_IDS.PHIALS_TWW.PHIAL_OF_BOUNTIFUL_SEASONS,
        expansionID = CraftSim.CONST.EXPANSION_IDS.THE_WAR_WITHIN,
    },
    {
        buffID = CraftSim.CONST.BUFF_IDS.PHIAL_OF_AMBIDEXTERITY,
        itemIDs = CraftSim.CONST.ITEM_IDS.PHIALS_TWW.PHIAL_OF_AMBIDEXTERITY,
        expansionID = CraftSim.CONST.EXPANSION_IDS.THE_WAR_WITHIN,
    },
    -- Midnight
    {
        buffID = CraftSim.CONST.BUFF_IDS.HARANIR_PHIAL_OF_INGENUITY,
        itemIDs = CraftSim.CONST.ITEM_IDS.PHIALS_MIDNIGHT.HARANIR_PHIAL_OF_INGENUITY,
        expansionID = CraftSim.CONST.EXPANSION_IDS.MIDNIGHT,
    },
}

--- Returns the item ID of the best quality phial (highest quality first) that
--- the player has in their bags, or nil if none are present.
---@param itemIDs number[]
---@return number? bestItemID
local function GetBestPhialFromBag(itemIDs)
    for i = #itemIDs, 1, -1 do
        local itemID = itemIDs[i]
        if C_Item.GetItemCount(itemID, false, false, false, false) > 0 then
            return itemID
        end
    end
    return nil
end

--- Returns the first salvage recipe ID for the currently open profession trade
--- skill, or nil when no salvage recipe is known/available.
---@return number? recipeID
local function FindSalvageRecipeForCurrentProfession()
    local recipeIDs = C_TradeSkillUI.GetFilteredRecipeIDs()
    if not recipeIDs then return nil end
    for _, recipeID in ipairs(recipeIDs) do
        local recipeInfo = C_TradeSkillUI.GetRecipeInfo(recipeID)
        if recipeInfo and recipeInfo.isSalvageRecipe and not recipeInfo.isDummyRecipe then
            return recipeID
        end
    end
    return nil
end

--- Creates and styles a buff bar icon button on the given parent frame.
--- The button has no label and uses a plain icon with highlight texture.
---@param parent Frame
---@param anchorParent Region
---@param anchorA string
---@param anchorB string
---@param offsetX number
---@param offsetY number
---@return GGUI.Button
local function CreateIconButton(parent, anchorParent, anchorA, anchorB, offsetX, offsetY)
    local btn = GGUI.Button({
        parent = parent,
        anchorPoints = { {
            anchorParent = anchorParent,
            anchorA = anchorA,
            anchorB = anchorB,
            offsetX = offsetX,
            offsetY = offsetY,
        } },
        sizeX = BUFF_BAR_BUTTON_SIZE,
        sizeY = BUFF_BAR_BUTTON_SIZE,
        cleanTemplate = true,
        secure = true,
        tooltipOptions = {
            anchor = "ANCHOR_TOP",
            owner = parent,
            text = "",
        },
    })
    -- Set up placeholder icon texture (replaced dynamically on each update)
    btn.frame:SetNormalTexture("Interface\\Icons\\INV_MISC_QUESTIONMARK")
    btn.frame:GetNormalTexture():SetAllPoints()
    btn.frame:SetPushedTexture("Interface\\Icons\\INV_MISC_QUESTIONMARK")
    btn.frame:GetPushedTexture():SetAllPoints()
    btn.frame:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square", "ADD")
    return btn
end

--- Creates the buff bar container and its buttons above the craft list in the
--- queue tab.  Must be called after queueTab.content.craftList has been created.
---@param frame CraftSim.CraftQueue.Frame
---@param queueTab CraftSim.CraftQueue.QueueTab
function CraftSim.CRAFTQ.UI:CreateBuffBar(frame, queueTab)
    ---@class CraftSim.CRAFTQ.BuffBar : Frame
    local buffBar = CreateFrame("Frame", nil, queueTab.content)
    -- Align the buff bar so that it sits just above the craft list.
    -- The craft list is anchored to frame.title.frame TOP at offsetY = -98 after
    -- this change; the buff bar occupies the space between -70 and -96.
    buffBar:SetPoint("TOPLEFT", queueTab.content.craftList.frame, "TOPLEFT", 0, BUFF_BAR_BUTTON_SIZE + 2)
    buffBar:SetPoint("TOPRIGHT", queueTab.content.craftList.frame, "TOPRIGHT", 0, BUFF_BAR_BUTTON_SIZE + 2)
    buffBar:SetHeight(BUFF_BAR_BUTTON_SIZE)

    queueTab.content.buffBar = buffBar

    -- "Shatter" button for the Enchanting salvage recipe
    ---@type GGUI.Button
    buffBar.shatterButton = CreateIconButton(buffBar, buffBar, "LEFT", "LEFT", 0, 0)
    buffBar.shatterButton:SetVisible(false)

    -- Phial buttons
    ---@type GGUI.Button[]
    buffBar.phialButtons = {}
    local prevAnchor = buffBar.shatterButton.frame
    for i = 1, #PHIAL_DATA do
        local btn = CreateIconButton(buffBar, prevAnchor, "LEFT", "RIGHT", 3, 0)
        btn.phialData = PHIAL_DATA[i]
        btn:SetVisible(false)
        buffBar.phialButtons[i] = btn
        prevAnchor = btn.frame
    end
end

--- Refreshes the buff bar: shows or hides buttons and sets their icons, tooltips,
--- and secure attributes based on the current profession and bag contents.
--- Should be called whenever the CraftQueue UI is updated.
function CraftSim.CRAFTQ.UI:UpdateBuffBarDisplay()
    local craftQueueFrame = CraftSim.CRAFTQ.frame
    if not craftQueueFrame then return end

    local queueTab = craftQueueFrame.content.queueTab --[[@as CraftSim.CraftQueue.QueueTab]]
    if not queueTab or not queueTab.content.buffBar then return end

    local buffBar = queueTab.content.buffBar

    -- Guard: profession window must be open
    local professionInfo = C_TradeSkillUI.GetChildProfessionInfo()
    if not professionInfo or not professionInfo.profession then
        buffBar.shatterButton:SetVisible(false)
        for _, btn in ipairs(buffBar.phialButtons) do btn:SetVisible(false) end
        return
    end

    local profession = professionInfo.profession
    local expansionID = CraftSim.UTIL:GetExpansionIDBySkillLineID(
        C_TradeSkillUI.GetProfessionChildSkillLineID())

    -- ------------------------------------------------------------------ --
    -- Shatter button
    -- ------------------------------------------------------------------ --
    local isShatterExpansion = expansionID == CraftSim.CONST.EXPANSION_IDS.THE_WAR_WITHIN
        or expansionID == CraftSim.CONST.EXPANSION_IDS.MIDNIGHT

    if profession == Enum.Profession.Enchanting and isShatterExpansion then
        local shatterRecipeID = FindSalvageRecipeForCurrentProfession()
        if shatterRecipeID then
            -- Determine the correct buff ID for this expansion.
            -- isShatterExpansion guarantees we are in TWW or Midnight, so the
            -- Midnight check covers the only non-TWW case.
            local buffID = (expansionID == CraftSim.CONST.EXPANSION_IDS.MIDNIGHT)
                and CraftSim.CONST.BUFF_IDS.SHATTERING_ESSENCE_MIDNIGHT
                or CraftSim.CONST.BUFF_IDS.SHATTERING_ESSENCE
            local spellInfo = C_Spell.GetSpellInfo(buffID)
            if spellInfo and spellInfo.iconID then
                buffBar.shatterButton.frame:SetNormalTexture(spellInfo.iconID)
                buffBar.shatterButton.frame:GetNormalTexture():SetAllPoints()
                buffBar.shatterButton.frame:SetPushedTexture(spellInfo.iconID)
                buffBar.shatterButton.frame:GetPushedTexture():SetAllPoints()
            end

            -- Determine the cheapest available salvage reagent.
            -- Items with no price data (price == 0) are only used as a fallback
            -- when no priced alternative is present in the bags.
            local salvageItemIDs = C_TradeSkillUI.GetSalvagableItemIDs(shatterRecipeID)
            local cheapestItemID = nil
            local firstAvailableItemID = nil
            local cheapestPrice = math.huge
            if salvageItemIDs then
                for _, itemID in ipairs(salvageItemIDs) do
                    local count = C_Item.GetItemCount(itemID, false, false, false, false)
                    if count > 0 then
                        if not firstAvailableItemID then
                            firstAvailableItemID = itemID
                        end
                        local price = CraftSim.PRICE_SOURCE:GetMinBuyoutByItemID(itemID, true)
                        if price > 0 and price < cheapestPrice then
                            cheapestPrice = price
                            cheapestItemID = itemID
                        end
                    end
                end
            end
            -- Fall back to any available item when no price data exists
            cheapestItemID = cheapestItemID or firstAvailableItemID

            local isActive = C_UnitAuras.GetPlayerAuraBySpellID(buffID) ~= nil
            buffBar.shatterButton.frame:GetNormalTexture():SetDesaturation(isActive and 0.5 or 0)

            if cheapestItemID then
                local cheapestItemName = C_Item.GetItemInfo(cheapestItemID) or ""
                buffBar.shatterButton.tooltipOptions.text =
                    f.gold((spellInfo and spellInfo.name) or "Shattering Essence") ..
                    "\n" .. f.white("Craft with ") .. cheapestItemName ..
                    (isActive and ("\n" .. f.g("Buff Active")) or "")

                buffBar.shatterButton:SetEnabled(true)
                buffBar.shatterButton.clickCallback = function()
                    local salvageLocation = GUTIL:GetItemLocationFromItemID(cheapestItemID, true)
                    if salvageLocation then
                        CraftSim.CRAFTQ.CraftSimCalledCraftRecipe = true
                        C_TradeSkillUI.CraftSalvage(shatterRecipeID, 1, salvageLocation, {}, false)
                        CraftSim.CRAFTQ.CraftSimCalledCraftRecipe = false
                    end
                end
            else
                buffBar.shatterButton.tooltipOptions.text =
                    f.gold("Shattering Essence") ..
                    "\n" .. f.r("No salvage reagents in bags")
                buffBar.shatterButton:SetEnabled(false)
                buffBar.shatterButton.clickCallback = nil
            end

            buffBar.shatterButton:SetVisible(true)
        else
            buffBar.shatterButton:SetVisible(false)
        end
    else
        buffBar.shatterButton:SetVisible(false)
    end

    -- ------------------------------------------------------------------ --
    -- Phial buttons
    -- ------------------------------------------------------------------ --
    for _, phialButton in ipairs(buffBar.phialButtons) do
        local phialData = phialButton.phialData

        if phialData.expansionID ~= expansionID then
            phialButton:SetVisible(false)
        else
            local isActive = C_UnitAuras.GetPlayerAuraBySpellID(phialData.buffID) ~= nil
            local bestItemID = GetBestPhialFromBag(phialData.itemIDs)

            if bestItemID or isActive then
                -- Update icon
                local displayItemID = bestItemID or phialData.itemIDs[#phialData.itemIDs]
                local itemIcon = select(10, C_Item.GetItemInfo(displayItemID))
                if itemIcon then
                    phialButton.frame:SetNormalTexture(itemIcon)
                    phialButton.frame:GetNormalTexture():SetAllPoints()
                    phialButton.frame:SetPushedTexture(itemIcon)
                    phialButton.frame:GetPushedTexture():SetAllPoints()
                end

                -- Desaturate if buff is already active (visual feedback)
                phialButton.frame:GetNormalTexture():SetDesaturation(isActive and 0.5 or 0)

                -- Update tooltip
                local itemName = C_Item.GetItemInfo(displayItemID) or ""
                local countText = ""
                if bestItemID then
                    local count = C_Item.GetItemCount(bestItemID, false, false, false, false)
                    countText = f.grey(" (" .. count .. "x)")
                end
                phialButton.tooltipOptions.text =
                    f.gold(itemName) .. countText ..
                    "\n" .. f.white("Click to use") ..
                    (isActive and ("\n" .. f.g("Buff Active")) or "")

                if bestItemID and not isActive then
                    -- Use SecureActionButtonTemplate to handle the item use.
                    -- Attributes can only be changed outside of combat.
                    if not InCombatLockdown() then
                        phialButton.frame:SetAttribute("type", "item")
                        phialButton.frame:SetAttribute("item", "item:" .. bestItemID)
                    end
                    phialButton:SetEnabled(true)
                elseif isActive then
                    -- Buff already active – disable to avoid accidental re-use
                    if not InCombatLockdown() then
                        phialButton.frame:SetAttribute("type", "")
                    end
                    phialButton:SetEnabled(false)
                else
                    if not InCombatLockdown() then
                        phialButton.frame:SetAttribute("type", "")
                    end
                    phialButton:SetEnabled(false)
                end

                phialButton:SetVisible(true)
            else
                phialButton:SetVisible(false)
            end
        end
    end
end
