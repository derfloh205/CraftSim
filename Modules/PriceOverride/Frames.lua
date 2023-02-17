AddonName, CraftSim = ...

CraftSim.PRICE_OVERRIDE.FRAMES = {}

local print = CraftSim.UTIL:SetDebugPrint(CraftSim.CONST.DEBUG_IDS.PRICE_OVERRIDE)

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
        CraftSim.CONST.FRAMES.PRICE_OVERRIDE, false, true, "DIALOG", "modulesPriceOverride")

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
        CraftSim.CONST.FRAMES.PRICE_OVERRIDE_WORK_ORDER, false, true, "DIALOG", "modulesPriceOverride")

    local function createContent(frame)
        frame:Hide()
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

        frame.content.resetAllButton = CraftSim.FRAME:CreateButton("Reset All", 
        frame.content, materialTab, "TOPRIGHT", "TOPLEFT", -65, 0, 15, 25, true, function(self)
            CraftSim.PRICE_OVERRIDE:ResetAll()
            local exportMode = CraftSim.UTIL:GetExportModeByVisibility()
            local recipeData = CraftSim.MAIN.currentRecipeData
            if not recipeData then
                return
            end
            CraftSim.MAIN:TriggerModulesErrorSafe(false, recipeData.recipeID, exportMode)
        end)

        frame.content.resetRecipeButton = CraftSim.FRAME:CreateButton("Reset Recipe", 
        frame.content, frame.content.resetAllButton, "TOPLEFT", "BOTTOMLEFT", 0, 0, 15, 25, true, function(self)
            local exportMode = CraftSim.UTIL:GetExportModeByVisibility()
            local recipeData = CraftSim.MAIN.currentRecipeData
            if not recipeData then
                return
            end
            CraftSim.PRICE_OVERRIDE:ResetRecipe(recipeData.recipeID)
            CraftSim.MAIN:TriggerModulesErrorSafe(false, recipeData.recipeID, exportMode)
        end)

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
                overrideFrame.icon, 20, 20, overrideFrame.icon, "TOPRIGHT", "TOPRIGHT", 5, 5, 3)

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

                -- reload modules to adapt to price change
                local exportMode = CraftSim.UTIL:GetExportModeByVisibility()
                CraftSim.MAIN:TriggerModulesErrorSafe(false, recipeData.recipeID, exportMode)
            end

            local function recipeCallback(self)
                if self:GetChecked() then
                    overrideFrame.globalCheckBox:SetChecked(false)
                end
                onPriceOverrideChanged(true, overrideFrame.input.getMoneyValue())
            end

            local function globalCallback(self)
                if self:GetChecked() then
                    overrideFrame.recipeCheckBox:SetChecked(false)
                end

                onPriceOverrideChanged(true, overrideFrame.input.getMoneyValue())
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

                local priceOverride, isGlobal = nil, nil

                overrideFrame:Show()

                overrideFrame.qualityID = qualityID

                if overrideFrame.isCraftedItem then
                    overrideFrame.itemID = qualityID
                else
                    overrideFrame.itemID = itemID
                end


                local function updateIconAndTooltip(itemLink, itemTexture)
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

                    overrideFrame.icon:SetNormalTexture(itemTexture or CraftSim.CONST.EMPTY_SLOT_TEXTURE) -- if not loaded
                end

                local itemLink = nil
                local itemTexture = nil
                if not isCraftedItem then
                    priceOverride, isGlobal = CraftSim.PRICE_OVERRIDE:GetPriceOverrideForItem(recipeID, itemID)
                    local itemData = Item:CreateFromItemID(itemID)
                    itemData:ContinueOnItemLoad(function() 
                        updateIconAndTooltip(itemData:GetItemLink(), itemData:GetItemIcon())
                    end)
                else
                    priceOverride, isGlobal = CraftSim.PRICE_OVERRIDE:GetPriceOverrideForItem(recipeID, qualityID)

                    print("found price override for qualityID " .. tostring(qualityID) .. ": " .. tostring(priceOverride))
                    if isGear then
                        local itemData = Item:CreateFromItemLink(itemID)  -- this is the itemLink for gear
                        itemLink = itemID
                        itemData:ContinueOnItemLoad(function() 
                            updateIconAndTooltip(itemLink, itemData:GetItemIcon())
                        end)
                    else
                        local itemData = Item:CreateFromItemID(itemID)
                        itemData:ContinueOnItemLoad(function() 
                            updateIconAndTooltip(itemData:GetItemLink(), itemData:GetItemIcon())
                        end)
                    end
                end
                --print("found price override for qualityID " .. tostring(qualityID) .. ": " .. tostring(priceOverride) .. " isGear: " .. tostring(isGear))

                if priceOverride then
                    -- only override text if the input field is not currently focused
                    if not overrideFrame.input:HasFocus() then
                        overrideFrame.input:SetText(priceOverride / 10000) -- copper to gold
                        print("Override Input Field: " .. tostring(priceOverride / 10000))
                    else
                        print("Do not override input, it has focus")
                    end
                    if isGlobal then
                        overrideFrame.recipeCheckBox:SetChecked(false)
                        overrideFrame.globalCheckBox:SetChecked(true)
                    else
                        overrideFrame.recipeCheckBox:SetChecked(true)
                        overrideFrame.globalCheckBox:SetChecked(false)
                    end
                else
                    overrideFrame.input:SetText("0")
                    overrideFrame.recipeCheckBox:SetChecked(false)
                    overrideFrame.globalCheckBox:SetChecked(false)
                end

                if not qualityID then
                    overrideFrame.qualityIcon:Hide()
                else
                    overrideFrame.qualityIcon.SetQuality(qualityID)
                    overrideFrame.qualityIcon:Show()
                end
            
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

---@param recipeData CraftSim.RecipeData
---@param exportMode number
function CraftSim.PRICE_OVERRIDE.FRAMES:UpdateDisplay(recipeData, exportMode)
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
    
    local requiredReagents = {}

    table.foreach(recipeData.reagentData.requiredReagents, function (_, reagent)
        table.foreach(reagent.items, function (_, reagentItem)
            table.insert(requiredReagents, {
                itemID = reagentItem.item:GetItemID(),
                qualityID = reagentItem.qualityID,  
            })
        end)
    end)

    local optionalReagents = {}
    local finishingReagents = {}
    table.foreach(recipeData.reagentData.optionalReagentSlots, function(_, slot) optionalReagents = CraftSim.UTIL:Concat({optionalReagents, slot.possibleReagents}) end)
    table.foreach(recipeData.reagentData.finishingReagentSlots, function(_, slot) finishingReagents = CraftSim.UTIL:Concat({finishingReagents, slot.possibleReagents}) end)
    optionalReagents = CraftSim.UTIL:Map(optionalReagents, function(optionalReagent) 
        return {
            itemID = optionalReagent.item:GetItemID(),
            qualityID = optionalReagent.qualityID
        }
    end)
    finishingReagents = CraftSim.UTIL:Map(finishingReagents, function(finishingReagent) 
        return {
            itemID = finishingReagent.item:GetItemID(),
            qualityID = finishingReagent.qualityID
        }
    end)

    local craftedItems = {}
    table.foreach(recipeData.resultData.itemsByQuality, function (index, item)
        table.insert(craftedItems, {
            itemLink = item:GetItemLink(),
            isGear = recipeData.isGear,
            qualityID = index,
            itemID = item:GetItemID()
        })
    end)

    updateOverrideFramesByItemList(1, requiredReagents)
    updateOverrideFramesByItemList(2, optionalReagents)
    updateOverrideFramesByItemList(3, finishingReagents)
    updateOverrideFramesByItemList(4, craftedItems)


end