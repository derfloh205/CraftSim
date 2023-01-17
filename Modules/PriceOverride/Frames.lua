addonName, CraftSim = ...

CraftSim.PRICE_OVERRIDE.FRAMES = {}

local function print(text, recursive, l) -- override
    if CraftSim_DEBUG and CraftSim.FRAME.GetFrame and CraftSim.FRAME:GetFrame(CraftSim.CONST.FRAMES.DEBUG) then
        CraftSim_DEBUG:print(text, CraftSim.CONST.DEBUG_IDS.FRAMES, recursive, l)
    else
        print(text)
    end
end

function CraftSim.PRICE_OVERRIDE.FRAMES:Init()
    local sizeX = 800
    local sizeY = 600
    local frameNO_WO = CraftSim.FRAME:CreateCraftSimFrame(
        "CraftSimPriceOverrideFrame", 
        "CraftSim Price Overrides", 
        ProfessionsFrame.CraftingPage.SchematicForm,
        ProfessionsFrame.CraftingPage.SchematicForm, 
        "CENTER", 
        "CENTER", 
        0, 
        0, 
        sizeX, 
        sizeY,
        CraftSim.CONST.FRAMES.PRICE_OVERRIDE)

    local frameWO = CraftSim.FRAME:CreateCraftSimFrame(
        "CraftSimPriceOverrideWOFrame", 
        "CraftSim Price Overrides " .. CraftSim.UTIL:ColorizeText("WO", CraftSim.CONST.COLORS.GREY), 
        ProfessionsFrame.OrdersPage.OrderView.OrderDetails.SchematicForm,
        ProfessionsFrame.CraftingPage.SchematicForm, 
        "CENTER", 
        "CENTER", 
        0, 
        0, 
        sizeX, 
        sizeY,
        CraftSim.CONST.FRAMES.PRICE_OVERRIDE_WORK_ORDER)

    local function createContent(frame)
        -- create tabs for the different kinds of overrides
        -- materials, optional reagents, finishing reagents, crafted items
        local contentOffsetY = -60
        local materialTab = CraftSim.FRAME:CreateTab(
            "Materials", frame.content, frame.content, "TOPLEFT", "TOPLEFT", sizeX/5, -30, true, sizeX, sizeY - 20, frame.content, frame.content, 0, contentOffsetY)

        local optionalReagentsTab = CraftSim.FRAME:CreateTab(
        "Optional Reagents", frame.content, materialTab, "LEFT", "RIGHT", 0, 0, true, sizeX, sizeY - 20, frame.content, frame.content, 0, contentOffsetY)

        local finishingReagentsTab = CraftSim.FRAME:CreateTab(
        "Finishing Reagents", frame.content, optionalReagentsTab, "LEFT", "RIGHT", 0, 0, true, sizeX, sizeY - 20, frame.content, frame.content, 0, contentOffsetY)

        local craftedItemsTab = CraftSim.FRAME:CreateTab(
        "Crafted Items", frame.content, finishingReagentsTab, "LEFT", "RIGHT", 0, 0, true, sizeX, sizeY - 20, frame.content, frame.content, 0, contentOffsetY)

        frame.content.tabs = {materialTab, optionalReagentsTab, finishingReagentsTab, craftedItemsTab}
        CraftSim.FRAME:InitTabSystem(frame.content.tabs)

        local function createOverrideFrame(parent, anchorParent, anchorA, anchorB, anchorX, anchorY, isCraftedItem)
            local overrideFrame = CreateFrame("frame", nil, parent)
            overrideFrame:SetSize(50, 50)
            overrideFrame:SetPoint(anchorA, anchorParent, anchorB, anchorX, anchorY)

            overrideFrame.itemID = nil
            overrideFrame.qualityID = nil
            overrideFrame.isCraftedItem = isCraftedItem

            overrideFrame.icon = CraftSim.FRAME:CreateIcon(overrideFrame, 0, 0, CraftSim.CONST.EMPTY_SLOT_TEXTURE, 30, 30, "LEFT", "LEFT")
            -- TODO: quality icon?

            overrideFrame.qualityIcon = CraftSim.FRAME:CreateQualityIcon(
                overrideFrame.icon, 15, 15, overrideFrame.icon, "TOPRIGHT", "TOPRIGHT", 0, 0, 3)

            local function onPriceOverrideChanged(userInput, moneyValue)
                if not userInput then
                    return
                end
                print("Changed Price Override")
                print("userInput: " .. tostring(userInput))
                print("moneyValue: " .. tostring(moneyValue))

                local isRecipeOverride = overrideFrame.recipeCheckBox:GetChecked()
                local isGlobalOverride = overrideFrame.globalCheckBox:GetChecked()
                local recipeData = CraftSim.MAIN.currentRecipeData
                if not recipeData then
                    return
                end
                local itemID = overrideFrame.itemID

                if not itemID then
                    return
                end
                
                if not isRecipeOverride and not isGlobalOverride then
                    CraftSim.PRICE_OVERRIDE:RemoveAllOverridesForItem(recipeData.recipeID, itemID)
                elseif isRecipeOverride then
                    CraftSim.PRICE_OVERRIDE:AddOverrideForRecipe(recipeData.recipeID, itemID, moneyValue)
                    CraftSim.PRICE_OVERRIDE:RemoveOverrideGlobal(itemID)
                elseif isGlobalOverride then
                    CraftSim.PRICE_OVERRIDE:AddOverrideGlobal(itemID, moneyValue)
                    CraftSim.PRICE_OVERRIDE:RemoveOverrideForRecipe(recipeData.recipeID, itemID)
                end
            end

            local function recipeCallback(self)
                if self:GetChecked() then
                    overrideFrame.globalCheckBox:SetChecked(false)
                end

                onPriceOverrideChanged(false, overrideFrame.input.getMoneyValue())
            end

            local function globalCallback(self)
                if self:GetChecked() then
                    overrideFrame.recipeCheckBox:SetChecked(false)
                end

                onPriceOverrideChanged(false, overrideFrame.input.getMoneyValue())
            end

            overrideFrame.recipeCheckBox = CraftSim.FRAME:CreateCheckboxCustomCallback("Recipe", "Override price for this recipe", false, recipeCallback, 
            overrideFrame, overrideFrame.icon, "TOPLEFT", "TOPRIGHT", 0, 2)

            overrideFrame.globalCheckBox = CraftSim.FRAME:CreateCheckboxCustomCallback("All", "Override price for all recipes", false, globalCallback, 
            overrideFrame, overrideFrame.recipeCheckBox, "TOP", "BOTTOM", 0, 10)

            if overrideFrame.isCraftedItem then
                overrideFrame.globalCheckBox:Hide()
            end

            
            overrideFrame.input = CraftSim.FRAME:CreateGoldInput(
                nil, overrideFrame, overrideFrame.icon, "TOPLEFT", "BOTTOMLEFT", 5, 0, 50, 25, 0, onPriceOverrideChanged)

            overrideFrame.goldIcon = CraftSim.FRAME:CreateGoldIcon(overrideFrame, overrideFrame.input, "LEFT", "RIGHT", 2, -2)

            overrideFrame.SetItem = function(itemID, recipeID, qualityID, isGear)

                if not itemID and not isGear then
                    overrideFrame.icon:SetScript("OnEnter", nil)
                    overrideFrame.icon:SetScript("OnLeave", nil)
                    overrideFrame.itemID = null
                    overrideFrame.qualityID = null
                    overrideFrame:Hide()
                    return
                end

                overrideFrame:Show()

                overrideFrame.qualityID = qualityID

                if overrideFrame.isCraftedItem then
                    overrideFrame.itemID = qualityID
                else
                    overrideFrame.itemID = itemID
                end


                local itemLink = nil
                local itemTexture = nil
                if not isGear then
                    local itemData = CraftSim.DATAEXPORT:GetItemFromCacheByItemID(itemID)
                    itemLink = itemData.link
                    itemTexture = itemData.itemTexture
                else
                    local itemData = Item:CreateFromItemLink(itemID)  -- this is the itemLink for gear
                    -- TODO: what if not loaded?
                    itemLink = itemID
                    itemTexture = itemData:GetItemIcon()
                end

                overrideFrame.icon:SetNormalTexture(itemTexture)

                -- check for saved price overrides

                if not qualityID then
                    overrideFrame.qualityIcon:Hide()
                else
                    overrideFrame.qualityIcon.SetQuality(qualityID)
                    overrideFrame.qualityIcon:Show()
                end
            
                overrideFrame.icon:SetScript("OnEnter", function(self) 
                    local itemName, tooltipLink = GameTooltip:GetItem()
                    GameTooltip:SetOwner(overrideFrame, "ANCHOR_RIGHT");
                    if tooltipLink ~= itemLink then
                        -- to not set it again and hide the tooltip..
                        GameTooltip:SetHyperlink(itemLink)
                    end
                    GameTooltip:Show();
                end)
                overrideFrame.icon:SetScript("OnLeave", function(self) 
                    GameTooltip:Hide();
                end)
            

            end

            return overrideFrame
        end

        local numOverrideFrames = 42

        local baseOffsetY = -30
        local baseOffsetX = -sizeX/2 + 50
        local spacingY = -70
        local spacingX = 110
        local framesPerRow = 7

        local function createOverrideFramesForTab(tab, isCraftedItem)
            tab.content.overrideFrames = {}

            local numFrames = 0
            local currentOffsetX = baseOffsetX
            for i = 1, numOverrideFrames, 1 do
                local numRow = math.floor(numFrames / framesPerRow)
                -- print("current frame: " .. tostring(numFrames))
                -- print("current column: " .. tostring(numRow))
                
                local overrideFrame = createOverrideFrame(tab.content, tab.content, "TOP", "TOP", currentOffsetX, baseOffsetY + spacingY*numRow, isCraftedItem)
                table.insert(tab.content.overrideFrames, overrideFrame)
                numFrames = numFrames + 1
                if numFrames % framesPerRow == 0 then
                    currentOffsetX = baseOffsetX
                else
                    currentOffsetX = currentOffsetX + spacingX
                end
            end
        end

        for tabNr, tab in pairs(frame.content.tabs) do
            if tabNr == 4 then
                createOverrideFramesForTab(tab, true)
            else
                createOverrideFramesForTab(tab)
            end
        end        
    end

    createContent(frameNO_WO)
    createContent(frameWO)
end

function CraftSim.PRICE_OVERRIDE.FRAMES:UpdateFrames(recipeData, exportMode)
    local priceOverrideFrame = nil
    if exportMode == CraftSim.CONST.EXPORT_MODE.WORK_ORDER then
        priceOverrideFrame = CraftSim.FRAME:GetFrame(CraftSim.CONST.FRAMES.PRICE_OVERRIDE_WORK_ORDER)
    else
        priceOverrideFrame = CraftSim.FRAME:GetFrame(CraftSim.CONST.FRAMES.PRICE_OVERRIDE)
    end

    local function updateOverrideFramesByItemList(tabNr, itemList)
        local overrideFrames = priceOverrideFrame.content.tabs[tabNr].content.overrideFrames

        for index, overrideFrame in pairs(overrideFrames) do
            local overrideItemData = itemList[index]
    
            if overrideItemData then
                if overrideItemData.isGear then
                    --print("set item #" .. tostring(index) .. " -> " .. tostring(overrideItemData.itemLink))
                    overrideFrame.SetItem(overrideItemData.itemLink, recipeData.recipeID, overrideItemData.qualityID, true)
                else
                    overrideFrame.SetItem(overrideItemData.itemID, recipeData.recipeID, overrideItemData.qualityID)
                end
            else
                overrideFrame.SetItem(nil)
            end
        end
    end

    -- update for required reagents
    

    local requiredReagents = {}

    for _, reagentData in pairs(recipeData.reagents) do
        if reagentData.differentQualities then
            for qualityID, itemInfo in pairs(reagentData.itemsInfo) do
                table.insert(requiredReagents, {
                    itemID = itemInfo.itemID,
                    qualityID = qualityID,
                })
            end
        else
            table.insert(requiredReagents, {
                itemID = reagentData.itemsInfo[1].itemID,
                qualityID = nil
            })
        end
    end

    local optionalReagents = {}
    for _, slot in pairs(recipeData.possibleOptionalReagents) do
        for _, optionalReagent in pairs(slot) do
            table.insert(optionalReagents, {
                itemID = optionalReagent.itemID,
                qualityID = optionalReagent.qualityID
            })
        end
    end

    local finishingReagents = {}
    for _, slot in pairs(recipeData.possibleFinishingReagents) do
        for _, finishingReagent in pairs(slot) do
            table.insert(finishingReagents, {
                itemID = finishingReagent.itemID,
                qualityID = finishingReagent.qualityID
            })
        end
    end

    local craftedItems = {}
    if recipeData.result.itemQualityLinks then
        print("num item quality links: " .. #recipeData.result.itemQualityLinks)
        for qualityID, itemLink in pairs(recipeData.result.itemQualityLinks) do
            table.insert(craftedItems, {
                itemLink = itemLink,
                qualityID = qualityID,
                isGear = true,
            })
        end
    elseif recipeData.result.itemID then
        table.insert(craftedItems, {
            itemID = recipeData.result.itemID,
            qualityID = nil
        })
    elseif recipeData.result.itemIDs then
        for qualityID, itemID in pairs(recipeData.result.itemIDs) do
            table.insert(craftedItems, {
                itemID = itemID,
                qualityID = qualityID
            })
        end
    end

    updateOverrideFramesByItemList(1, requiredReagents)
    updateOverrideFramesByItemList(2, optionalReagents)
    updateOverrideFramesByItemList(3, finishingReagents)
    updateOverrideFramesByItemList(4, craftedItems)


end