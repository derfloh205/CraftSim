AddonName, CraftSim = ...

---@class CraftSim.PRICE_OVERRIDE.overrideDropdownData
---@field item ItemMixin
---@field isResult boolean
---@field qualityID number

CraftSim.PRICE_OVERRIDE.OverrideDropdownData = CraftSim.Object:extend()
function CraftSim.PRICE_OVERRIDE.OverrideDropdownData:new(item, isResult, qualityID)
    self.item = item
    self.isResult = isResult
    self.qualityID = qualityID 
end

CraftSim.PRICE_OVERRIDE.FRAMES = {}

local print = CraftSim.UTIL:SetDebugPrint(CraftSim.CONST.DEBUG_IDS.PRICE_OVERRIDE)

function CraftSim.PRICE_OVERRIDE.FRAMES:Init()
    local sizeX = 400
    local sizeY = 300
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

    local function createContentV2(frame)

        local overrideOptions = nil

        ---@param overrideData CraftSim.PRICE_OVERRIDE.overrideDropdownData
        local function selectionCallback(_, overrideData)
            print("Selected itemID: " .. tostring(overrideData.item:GetItemID()))
            frame.currentDropdownData = overrideData
            CraftSim.PRICE_OVERRIDE.FRAMES:UpdateOverrideItem(overrideData)
            overrideOptions:updateButtonStatus()
        end

        frame.recipeID = nil

        frame.content.itemDropdown = CraftSim.FRAME:initDropdownMenu(nil, frame.content, frame.title, "Override Item", 0, -30, 150, {}, selectionCallback, "", true)

        frame.content.overrideOptions = CreateFrame("Frame", nil, frame.content)
        frame.content.overrideOptions:SetSize(200, 80)
        frame.content.overrideOptions:SetPoint("TOP", frame.content.itemDropdown, "BOTTOM", 0, 0)

        overrideOptions = frame.content.overrideOptions

        overrideOptions:Hide()

        overrideOptions.itemIcon = CraftSim.FRAME:CreateIcon(overrideOptions, 20, 0, CraftSim.CONST.EMPTY_SLOT_TEXTURE, 30, 30, "TOPLEFT", "TOPLEFT", overrideOptions)
        function overrideOptions:updateButtonStatus()
            local currentData = frame.currentDropdownData
            local price = nil
            if currentData.isResult then
                price = CraftSim.PRICE_OVERRIDE:GetResultOverridePrice(frame.recipeID, currentData.qualityID)
            else
                price = CraftSim.PRICE_OVERRIDE:GetGlobalOverridePrice(currentData.item:GetItemID())
            end

            local valid = overrideOptions.currencyInputGold.isValid

            print("button update: price:" .. tostring(price))

            overrideOptions.removeButton:SetEnabled(price)
            if price then
                -- check if same price as currently set
                if valid then
                    local inputInfo = overrideOptions.currencyInputGold:GetInfo()
                    local priceInput = inputInfo.total
                    if price == priceInput then
                        overrideOptions.saveButton:SetStatus("SAVED")
                    else
                        overrideOptions.saveButton:SetStatus("READY")
                    end
                else
                    overrideOptions.saveButton:SetStatus("INVALID")
                end
            elseif valid then
                overrideOptions.saveButton:SetStatus("READY")
            else
                overrideOptions.saveButton:SetStatus("INVALID")
            end
        end
    
        overrideOptions.saveButton = CraftSim.FRAME:CreateButton("Save", overrideOptions, overrideOptions.itemIcon, "BOTTOMLEFT", "BOTTOMRIGHT", 3, -25, 15, 25, true, function()
            CraftSim.PRICE_OVERRIDE:SaveOverrideData(frame.recipeID, frame.currentDropdownData)
            overrideOptions:updateButtonStatus()
            CraftSim.MAIN:TriggerModulesErrorSafe()
        end)

        overrideOptions.removeButton = CraftSim.FRAME:CreateButton("Remove", overrideOptions, overrideOptions.saveButton, "LEFT", "RIGHT", 3, 0, 15, 25, true, function()
            CraftSim.PRICE_OVERRIDE:RemoveOverrideData(frame.recipeID, frame.currentDropdownData)
            overrideOptions:updateButtonStatus()
            overrideOptions.currencyInputGold:SetText("")
            CraftSim.MAIN:TriggerModulesErrorSafe()
        end)

        function overrideOptions.saveButton:SetStatus(status)
            if status == "SAVED" then
                overrideOptions.saveButton:SetText("Saved")
                overrideOptions.saveButton:SetEnabled(false)
            elseif status == "READY" then
                overrideOptions.saveButton:SetText("Save")
                overrideOptions.saveButton:SetEnabled(true)
            elseif status == "INVALID" then
                overrideOptions.saveButton:SetText("Save")
                overrideOptions.saveButton:SetEnabled(false)
            end
        end

        overrideOptions.currencyInputGold = CraftSim.FRAME:CreateGoldInput(nil, overrideOptions, overrideOptions.itemIcon, "LEFT", "RIGHT", 10, 0, 80, 25, 0, nil, function() overrideOptions:updateButtonStatus() end, true)
    
        frame.content.scrollFrame1, frame.content.activeOverridesBox = CraftSim.FRAME:CreateScrollFrame(frame.content, -170, 50, -50, 30)
        local title = CraftSim.FRAME:CreateText("Active Overrides", frame.content, frame.content.scrollFrame1, "BOTTOM", "TOP", 0, 0)
        CraftSim.FRAME:CreateHelpIcon("'(as result)' -> price override only considered when item is a result of a recipe", frame.content, title, "LEFT", "RIGHT", 3, 0)
        frame.content.clearAllButton = CraftSim.FRAME:CreateButton("Clear All", frame.content, title, "LEFT", "RIGHT", 30, 0, 15, 18, true, function()
            CraftSim.PRICE_OVERRIDE:ClearAll()
            if frame.currentDropdownData then
                overrideOptions:updateButtonStatus()
            end
            CraftSim.MAIN:TriggerModulesErrorSafe()
        end)
        
        frame.content.activeOverridesBox.overrideList = CraftSim.FRAME:CreateText("", frame.content.activeOverridesBox, frame.content.activeOverridesBox, "TOPLEFT", "TOPLEFT", 0, 0, 0.85, nil, {type="H", value="LEFT"})
        CraftSim.FRAME:EnableHyperLinksForFrameAndChilds(frame)
    end

    createContentV2(frameNO_WO)
    createContentV2(frameWO)
end

---@param overrideData CraftSim.PRICE_OVERRIDE.overrideDropdownData
function CraftSim.PRICE_OVERRIDE.FRAMES:UpdateOverrideItem(overrideData)
    local exportMode = CraftSim.UTIL:GetExportModeByVisibility()
    local priceOverrideFrame = nil
    if exportMode == CraftSim.CONST.EXPORT_MODE.WORK_ORDER then
        priceOverrideFrame = CraftSim.FRAME:GetFrame(CraftSim.CONST.FRAMES.PRICE_OVERRIDE_WORK_ORDER)
    else
        priceOverrideFrame = CraftSim.FRAME:GetFrame(CraftSim.CONST.FRAMES.PRICE_OVERRIDE)
    end

    local overrideOptions = priceOverrideFrame.content.overrideOptions

    overrideOptions:Show()

    overrideOptions.itemIcon.SetItem(overrideData.item:GetItemID())
    local qualityID = CraftSim.GUTIL:GetQualityIDFromLink(overrideData.item:GetItemLink())
    overrideOptions.itemIcon.SetQuality(qualityID)
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

---@param recipeData CraftSim.RecipeData
---@param exportMode number
function CraftSim.PRICE_OVERRIDE.FRAMES:UpdateDisplayV2(recipeData, exportMode)
    local priceOverrideFrame = nil
    if exportMode == CraftSim.CONST.EXPORT_MODE.WORK_ORDER then
        priceOverrideFrame = CraftSim.FRAME:GetFrame(CraftSim.CONST.FRAMES.PRICE_OVERRIDE_WORK_ORDER)
    else
        priceOverrideFrame = CraftSim.FRAME:GetFrame(CraftSim.CONST.FRAMES.PRICE_OVERRIDE)
    end

    CraftSim.PRICE_OVERRIDE.FRAMES:UpdateOverrideList(priceOverrideFrame)

    if priceOverrideFrame.recipeID == recipeData.recipeID then
        -- same recipe, stay
    else
        -- recipe was changed, reload and hide the options again
        priceOverrideFrame.content.overrideOptions:Hide()
        priceOverrideFrame.recipeID = recipeData.recipeID
    
        -- TODO: probably after waiting for load? Check if necessary
    
        local dropdownData = {
        }
        local reagentData = recipeData.reagentData
        if #reagentData.requiredReagents > 0 then
            local dropdownEntry = {label="Required Reagents", value = {}}
            table.foreach(reagentData.requiredReagents, function (_, reagent)
                table.foreach(reagent.items, function (_, reagentItem)
                    local reagentLabel = reagentItem.item:GetItemLink()
                    table.insert(dropdownEntry.value, {
                        label=reagentLabel,
                        value= CraftSim.PRICE_OVERRIDE.OverrideDropdownData(reagentItem.item, false),
                    })
                end)
            end)
            table.insert(dropdownData, dropdownEntry)
        end
    
        if #reagentData.optionalReagentSlots > 0 then
            local dropdownEntry = {label="Optional Reagents", value = {}}
            local allPossibleReagents = {}
            table.foreach(reagentData.optionalReagentSlots, function (_, slot)
                allPossibleReagents = CraftSim.UTIL:Concat({allPossibleReagents, slot.possibleReagents})
            end)
            table.foreach(allPossibleReagents, function (_, optionalReagent)
                local reagentLabel = optionalReagent.item:GetItemLink()
                table.insert(dropdownEntry.value, {
                    label=reagentLabel,
                    value=CraftSim.PRICE_OVERRIDE.OverrideDropdownData(optionalReagent.item, false),
                })
            end)
            table.insert(dropdownData, dropdownEntry)
        end
    
        if #reagentData.finishingReagentSlots > 0 then
            local dropdownEntry = {label="Finishing Reagents", value = {}}
            local allPossibleReagents = {}
            table.foreach(reagentData.finishingReagentSlots, function (_, slot)
                allPossibleReagents = CraftSim.UTIL:Concat({allPossibleReagents, slot.possibleReagents})
            end)
            table.foreach(allPossibleReagents, function (_, optionalReagent)
                local reagentLabel = optionalReagent.item:GetItemLink()
                table.insert(dropdownEntry.value, {
                    label=reagentLabel,
                    value=CraftSim.PRICE_OVERRIDE.OverrideDropdownData(optionalReagent.item, false),
                })
            end)
            table.insert(dropdownData, dropdownEntry)
        end
    
        if #recipeData.resultData.itemsByQuality > 0 then
            local dropdownEntry = {label="Result Items", value = {}}
            table.foreach(recipeData.resultData.itemsByQuality, function (qualityID, item)
                table.insert(dropdownEntry.value, {
                    label=item:GetItemLink(),
                    value=CraftSim.PRICE_OVERRIDE.OverrideDropdownData(item, true, qualityID),
                })
            end)
            table.insert(dropdownData, dropdownEntry)
        end
    
        CraftSim.FRAME:initializeDropdownByData(priceOverrideFrame.content.itemDropdown, dropdownData, "")
    end
end

function CraftSim.PRICE_OVERRIDE.FRAMES:UpdateOverrideList(priceOverrideFrame)


    local overrideText = priceOverrideFrame.content.activeOverridesBox.overrideList

    local globalOverrides = CraftSimPriceOverridesV2.globalOverrides or {}
    local recipeOverrides = CraftSimPriceOverridesV2.recipeResultOverrides or {}
    local resultOverrides = {}
    table.foreach(recipeOverrides, function (_, resultOverrideList)
        table.foreach(resultOverrideList, function (_, resultOverride)
            table.insert(resultOverrides, Item:CreateFromItemID(resultOverride.itemID))
        end)
    end)

    local itemsToLoad = CraftSim.UTIL:Map(globalOverrides, function(override) return Item:CreateFromItemID(override.itemID) end)
    itemsToLoad = CraftSim.UTIL:Concat({itemsToLoad, CraftSim.UTIL:Map(resultOverrides, function(override) return Item:CreateFromItemID(override.itemID) end)})

    CraftSim.UTIL:ContinueOnAllItemsLoaded(itemsToLoad, function ()
        
        local text = ""
        table.foreach(globalOverrides, function (_, priceOverrideData)
            local item = Item:CreateFromItemID(priceOverrideData.itemID)
            text = text .. item:GetItemLink() .. ": " .. CraftSim.UTIL:FormatMoney(priceOverrideData.price) .. "\n"
        end)

        table.foreach(recipeOverrides, function (_, resultOverrideList)
            table.foreach(resultOverrideList, function (_, resultOverride)                
                local item = Item:CreateFromItemID(resultOverride.itemID)
                text = text .. item:GetItemLink() .. ": " .. CraftSim.UTIL:FormatMoney(resultOverride.price) .. " " .. CraftSim.UTIL:ColorizeText("(as result)", CraftSim.CONST.COLORS.BRIGHT_BLUE) .. "\n"
            end)
        end)

        overrideText:SetText(text)

    end)
    
end