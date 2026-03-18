---@class CraftSim
local CraftSim = select(2, ...)

local GGUI = CraftSim.GGUI
local GUTIL = CraftSim.GUTIL

---@class CraftSim.CRAFTQ.UI
CraftSim.CRAFTQ.UI = CraftSim.CRAFTQ.UI

local f = GUTIL:GetFormatter()

local BUFF_BAR_BUTTON_SIZE = 39  -- 1.5× the original 26 px

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

--- Creates the buff bar container and its icon buttons at the top-left of the
--- craft queue window.  Must be called after frame.content exists.
---@param frame CraftSim.CraftQueue.Frame
---@param queueTab CraftSim.CraftQueue.QueueTab
function CraftSim.CRAFTQ.UI:CreateBuffBar(frame, queueTab)
    ---@class CraftSim.CRAFTQ.BuffBar : Frame
    local buffBar = CreateFrame("Frame", nil, frame.content)
    -- Placed at the top-left of the craft queue window content area
    buffBar:SetPoint("TOPLEFT", frame.content, "TOPLEFT", 5, -5)
    buffBar:SetSize(BUFF_BAR_BUTTON_SIZE * (#PHIAL_DATA + 1), BUFF_BAR_BUTTON_SIZE) -- +1 for shatter icon

    frame.content.buffBar = buffBar

    -- "Shatter" icon button for the Enchanting salvage recipe
    ---@type GGUI.Icon
    buffBar.shatterIcon = GGUI.Icon {
        parent = buffBar,
        anchorPoints = { { anchorParent = buffBar, anchorA = "LEFT", anchorB = "LEFT" } },
        sizeX = BUFF_BAR_BUTTON_SIZE,
        sizeY = BUFF_BAR_BUTTON_SIZE,
        tooltipOptions = {
            anchor = "ANCHOR_TOP",
            owner = buffBar,
            text = "",
        },
    }
    buffBar.shatterIcon.frame:EnableMouse(true)
    buffBar.shatterIcon.frame:RegisterForClicks("LeftButtonUp")
    buffBar.shatterIcon:SetVisible(false)

    -- Phial icon buttons
    ---@type GGUI.Icon[]
    buffBar.phialIcons = {}
    local prevAnchor = buffBar.shatterIcon.frame
    for i = 1, #PHIAL_DATA do
        ---@type GGUI.Icon
        local icon = GGUI.Icon {
            parent = buffBar,
            anchorPoints = { {
                anchorParent = prevAnchor,
                anchorA = "LEFT",
                anchorB = "RIGHT",
                offsetX = 3,
            } },
            sizeX = BUFF_BAR_BUTTON_SIZE,
            sizeY = BUFF_BAR_BUTTON_SIZE,
            tooltipOptions = {
                anchor = "ANCHOR_TOP",
                owner = buffBar,
                text = "",
            },
        }
        icon.frame:EnableMouse(true)
        icon.frame:RegisterForClicks("LeftButtonUp")
        icon.phialData = PHIAL_DATA[i]
        icon:SetVisible(false)
        buffBar.phialIcons[i] = icon
        prevAnchor = icon.frame
    end
end

--- Refreshes the buff bar: shows or hides icons and updates their textures,
--- tooltips, and click handlers based on the current profession and bag contents.
--- Should be called whenever the CraftQueue UI is updated.
function CraftSim.CRAFTQ.UI:UpdateBuffBarDisplay()
    local craftQueueFrame = CraftSim.CRAFTQ.frame
    if not craftQueueFrame then return end

    local buffBar = craftQueueFrame.content.buffBar
    if not buffBar then return end

    -- Guard: profession window must be open
    local professionInfo = C_TradeSkillUI.GetChildProfessionInfo()
    if not professionInfo or not professionInfo.profession then
        buffBar.shatterIcon:SetVisible(false)
        for _, icon in ipairs(buffBar.phialIcons) do icon:SetVisible(false) end
        return
    end

    local profession = professionInfo.profession
    local expansionID = CraftSim.UTIL:GetExpansionIDBySkillLineID(
        C_TradeSkillUI.GetProfessionChildSkillLineID())

    -- ------------------------------------------------------------------ --
    -- Shatter icon
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

            -- Set the icon texture to the buff spell icon
            buffBar.shatterIcon:SetSpell(buffID)

            -- Determine the cheapest available salvage reagent.
            -- Items with no price data are only used as a fallback.
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
            if isActive then
                buffBar.shatterIcon:Desaturate()
            else
                buffBar.shatterIcon:Saturate()
            end

            if cheapestItemID then
                local cheapestItemName = C_Item.GetItemInfo(cheapestItemID) or ""
                buffBar.shatterIcon.tooltipOptions.text =
                    f.gold((spellInfo and spellInfo.name) or "Shattering Essence") ..
                    "\n" .. f.white("Craft with ") .. cheapestItemName ..
                    (isActive and ("\n" .. f.g("Buff Active")) or "")

                buffBar.shatterIcon.frame:SetScript("OnMouseUp", function()
                    local salvageLocation = GUTIL:GetItemLocationFromItemID(cheapestItemID, true)
                    if salvageLocation then
                        CraftSim.CRAFTQ.CraftSimCalledCraftRecipe = true
                        C_TradeSkillUI.CraftSalvage(shatterRecipeID, 1, salvageLocation, {}, false)
                        CraftSim.CRAFTQ.CraftSimCalledCraftRecipe = false
                    end
                end)
            else
                buffBar.shatterIcon.tooltipOptions.text =
                    f.gold("Shattering Essence") ..
                    "\n" .. f.r("No salvage reagents in bags")
                buffBar.shatterIcon.frame:SetScript("OnMouseUp", nil)
            end

            buffBar.shatterIcon:SetVisible(true)
        else
            buffBar.shatterIcon:SetVisible(false)
        end
    else
        buffBar.shatterIcon:SetVisible(false)
    end

    -- ------------------------------------------------------------------ --
    -- Phial icons
    -- ------------------------------------------------------------------ --
    for _, phialIcon in ipairs(buffBar.phialIcons) do
        local phialData = phialIcon.phialData

        if phialData.expansionID ~= expansionID then
            phialIcon:SetVisible(false)
        else
            local isActive = C_UnitAuras.GetPlayerAuraBySpellID(phialData.buffID) ~= nil
            local bestItemID = GetBestPhialFromBag(phialData.itemIDs)

            if bestItemID or isActive then
                -- Display icon via item (shows quality colouring, etc.)
                local displayItemID = bestItemID or phialData.itemIDs[#phialData.itemIDs]
                phialIcon:SetItem(displayItemID)

                if isActive then
                    phialIcon:Desaturate()
                else
                    phialIcon:Saturate()
                end

                -- Tooltip
                local itemName = C_Item.GetItemInfo(displayItemID) or ""
                local countText = ""
                if bestItemID then
                    local count = C_Item.GetItemCount(bestItemID, false, false, false, false)
                    countText = f.grey(" (" .. count .. "x)")
                end
                phialIcon.tooltipOptions.text =
                    f.gold(itemName) .. countText ..
                    "\n" .. f.white("Click to use") ..
                    (isActive and ("\n" .. f.g("Buff Active")) or "")

                if bestItemID and not isActive then
                    phialIcon.frame:SetScript("OnMouseUp", function()
                        local currentItemName = C_Item.GetItemInfo(bestItemID)
                        if currentItemName then
                            UseItemByName(currentItemName)
                        end
                    end)
                else
                    phialIcon.frame:SetScript("OnMouseUp", nil)
                end

                phialIcon:SetVisible(true)
            else
                phialIcon:SetVisible(false)
            end
        end
    end
end
