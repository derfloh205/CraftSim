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
        "CraftSim Price Overrides " .. CraftSim.GUTIL:ColorizeText("WO", CraftSim.GUTIL.COLORS.GREY), 
        ProfessionsFrame.OrdersPage.OrderView.OrderDetails.SchematicForm,
        ProfessionsFrame.CraftingPage.SchematicForm, 
        "CENTER", 
        "CENTER", 
        0, 
        0, 
        sizeX, 
        sizeY,
        CraftSim.CONST.FRAMES.PRICE_OVERRIDE_WORK_ORDER, false, true, "DIALOG", "modulesPriceOverride")

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

        overrideOptions.itemIcon = CraftSim.GGUI.Icon({
            parent=overrideOptions,
            anchorParent=overrideOptions,
            offsetX=20,
            sizeX=30, sizeY=30,
            anchorA="TOPLEFT", anchorB="TOPLEFT",
        })

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
    
        overrideOptions.saveButton = CraftSim.FRAME:CreateButton("Save", overrideOptions, overrideOptions.itemIcon.frame, "BOTTOMLEFT", "BOTTOMRIGHT", 3, -25, 15, 25, true, function()
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

        overrideOptions.currencyInputGold = CraftSim.FRAME:CreateGoldInput(nil, overrideOptions, overrideOptions.itemIcon.frame, "LEFT", "RIGHT", 10, 0, 80, 25, 0, nil, function() overrideOptions:updateButtonStatus() end, true)
    
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

    overrideOptions.itemIcon:SetItem(overrideData.item:GetItemLink())
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
    table.foreach(recipeData.reagentData.optionalReagentSlots, function(_, slot) optionalReagents = CraftSim.GUTIL:Concat({optionalReagents, slot.possibleReagents}) end)
    table.foreach(recipeData.reagentData.finishingReagentSlots, function(_, slot) finishingReagents = CraftSim.GUTIL:Concat({finishingReagents, slot.possibleReagents}) end)
    optionalReagents = CraftSim.GUTIL:Map(optionalReagents, function(optionalReagent) 
        return {
            itemID = optionalReagent.item:GetItemID(),
            qualityID = optionalReagent.qualityID
        }
    end)
    finishingReagents = CraftSim.GUTIL:Map(finishingReagents, function(finishingReagent) 
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
                allPossibleReagents = CraftSim.GUTIL:Concat({allPossibleReagents, slot.possibleReagents})
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
                allPossibleReagents = CraftSim.GUTIL:Concat({allPossibleReagents, slot.possibleReagents})
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

    local itemsToLoad = CraftSim.GUTIL:Map(globalOverrides, function(override) return Item:CreateFromItemID(override.itemID) end)
    itemsToLoad = CraftSim.GUTIL:Concat({itemsToLoad, CraftSim.GUTIL:Map(resultOverrides, function(override) return Item:CreateFromItemID(override.itemID) end)})

    CraftSim.GUTIL:ContinueOnAllItemsLoaded(itemsToLoad, function ()
        
        local text = ""
        table.foreach(globalOverrides, function (_, priceOverrideData)
            local item = Item:CreateFromItemID(priceOverrideData.itemID)
            text = text .. item:GetItemLink() .. ": " .. CraftSim.GUTIL:FormatMoney(priceOverrideData.price) .. "\n"
        end)

        table.foreach(recipeOverrides, function (_, resultOverrideList)
            table.foreach(resultOverrideList, function (_, resultOverride)                
                local item = Item:CreateFromItemID(resultOverride.itemID)
                text = text .. item:GetItemLink() .. ": " .. CraftSim.GUTIL:FormatMoney(resultOverride.price) .. " " .. CraftSim.GUTIL:ColorizeText("(as result)", CraftSim.GUTIL.COLORS.BRIGHT_BLUE) .. "\n"
            end)
        end)

        overrideText:SetText(text)

    end)
    
end