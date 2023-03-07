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

    local frameNO_WO = CraftSim.GGUI.Frame({
        parent=ProfessionsFrame.CraftingPage.SchematicForm, 
        anchorParent=ProfessionsFrame.CraftingPage.SchematicForm,
        sizeX=sizeX,sizeY=sizeY,
        frameID=CraftSim.CONST.FRAMES.PRICE_OVERRIDE, 
        title="CraftSim Price Overrides",
        collapseable=true,
        closeable=true,
        moveable=true,
        backdropOptions=CraftSim.CONST.DEFAULT_BACKDROP_OPTIONS,
        frameStrata="DIALOG",
        onCloseCallback=CraftSim.FRAME:HandleModuleClose("modulesPriceOverride"),
    })
    local frameWO = CraftSim.GGUI.Frame({
        parent=ProfessionsFrame.OrdersPage.OrderView.OrderDetails.SchematicForm, 
        anchorParent=ProfessionsFrame.CraftingPage.SchematicForm,
        sizeX=sizeX,sizeY=sizeY,
        frameID=CraftSim.CONST.FRAMES.PRICE_OVERRIDE_WORK_ORDER, 
        title="CraftSim Price Overrides " .. CraftSim.GUTIL:ColorizeText("WO", CraftSim.GUTIL.COLORS.GREY),
        collapseable=true,
        closeable=true,
        moveable=true,
        backdropOptions=CraftSim.CONST.DEFAULT_BACKDROP_OPTIONS,
        frameStrata="DIALOG",
        onCloseCallback=CraftSim.FRAME:HandleModuleClose("modulesPriceOverride"),
    })

    local function createContentV2(frame)

        local overrideOptions = nil

        ---@param overrideData CraftSim.PRICE_OVERRIDE.overrideDropdownData
        local function selectionCallback(_, _, overrideData)
            print("Selected itemID: " .. tostring(overrideData.item:GetItemID()))
            frame.currentDropdownData = overrideData
            CraftSim.PRICE_OVERRIDE.FRAMES:UpdateOverrideItem(overrideData)
            overrideOptions:updateButtonStatus()
        end

        frame.recipeID = nil

        frame.content.itemDropdown = CraftSim.GGUI.Dropdown({
            parent=frame.content, anchorParent=frame.title.frame, anchorA="TOP", anchorB="TOP", offsetY=-30, width=150,
            clickCallback=selectionCallback
        })

        frame.content.overrideOptions = CreateFrame("Frame", nil, frame.content)
        frame.content.overrideOptions:SetSize(200, 80)
        frame.content.overrideOptions:SetPoint("TOP", frame.content.itemDropdown.frame, "BOTTOM", 0, 0)

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

            local overrideData = nil
            if currentData.isResult then
                overrideData = CraftSim.PRICE_OVERRIDE:GetResultOverride(frame.recipeID, currentData.qualityID)
            else
                overrideData = CraftSim.PRICE_OVERRIDE:GetGlobalOverride(currentData.item:GetItemID())
            end

            overrideOptions.removeButton:SetEnabled(overrideData)

            if overrideOptions.useCraftDataCB:GetChecked() then

                if overrideData and overrideData.useCraftData then
                    if overrideData.useCraftData then
                        overrideOptions.saveButton:SetStatus("SAVED")
                    end
                else
                    overrideOptions.saveButton:SetStatus("READY")
                end

                return
            end

            local valid = overrideOptions.currencyInputGold.isValid

            if overrideData and overrideData.price then
                -- check if same price as currently set
                if valid then
                    local priceInput = overrideOptions.currencyInputGold.total
                    if overrideData.price == priceInput then
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
    
        overrideOptions.saveButton = CraftSim.GGUI.Button({
            parent=overrideOptions,anchorParent=overrideOptions.itemIcon.frame,anchorA="BOTTOMLEFT",anchorB="BOTTOMRIGHT",offsetX=3,offsetY=-25,sizeX=15,sizeY=25,adjustWidth=true,
            clickCallback=function ()
                CraftSim.PRICE_OVERRIDE:SaveOverrideData(frame.recipeID, frame.currentDropdownData)
                overrideOptions:updateButtonStatus()
                CraftSim.MAIN:TriggerModulesErrorSafe()
            end,
            initialStatus="READY",
            label="Save",
        })
        overrideOptions.saveButton:SetStatusList({
            {
                statusID="READY",
                enabled=true,
                label="Save",
            },
            {
                statusID="SAVED",
                enabled=false,
                label="Saved",
            },
            {
                statusID="INVALID",
                enabled=false,
                label="Save",
            },
        })

        overrideOptions.removeButton = CraftSim.GGUI.Button({
            parent=overrideOptions,anchorParent=overrideOptions.saveButton.frame,anchorA="LEFT",anchorB="RIGHT",offsetX=3,sizeX=15,sizeY=25,adjustWidth=true,
            clickCallback=function ()
                CraftSim.PRICE_OVERRIDE:RemoveOverrideData(frame.recipeID, frame.currentDropdownData)
                overrideOptions:updateButtonStatus()
                overrideOptions.currencyInputGold:SetValue(0)
                CraftSim.MAIN:TriggerModulesErrorSafe()
            end,
            label="Remove",
        })

        overrideOptions.currencyInputGold = CraftSim.GGUI.CurrencyInput({
            parent=overrideOptions,anchorParent=overrideOptions.itemIcon.frame,anchorA="LEFT",anchorB="RIGHT",offsetX=10,sizeX=80,sizeY=25,
            onValidationChangedCallback=function() overrideOptions:updateButtonStatus() end,
            showFormatHelpIcon=true, initialValue=0,

        })
        overrideOptions.useCraftDataCB = CraftSim.GGUI.Checkbox({
            parent=overrideOptions, anchorParent=overrideOptions.currencyInputGold.textInput.frame, anchorA="LEFT", anchorB="RIGHT", offsetX=30,
            label="Craft Data",
            tooltip=CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CRAFT_DATA_OVERRIDE_EXPLANATION),
            clickCallback=function (self, checked)
                if checked then
                    overrideOptions.currencyInputGold:Hide()
                    overrideOptions.craftDataUsageText:Show()
                else
                    overrideOptions.currencyInputGold:Show()
                    overrideOptions.craftDataUsageText:Hide()
                end
                overrideOptions:updateButtonStatus()
            end
        })

        overrideOptions.craftDataUsageText = CraftSim.GGUI.Text({
            parent=overrideOptions, anchorParent=overrideOptions.currencyInputGold.textInput.frame, 
            text = CraftSim.GUTIL:ColorizeText("Use Craft Data", CraftSim.GUTIL.COLORS.BRIGHT_BLUE), anchorA="LEFT", anchorB="LEFT"
        })

        overrideOptions.craftDataUsageText:Hide()
    
        frame.content.scrollFrame1, frame.content.activeOverridesBox = CraftSim.FRAME:CreateScrollFrame(frame.content, -170, 50, -50, 30)
        local title = CraftSim.FRAME:CreateText("Active Overrides", frame.content, frame.content.scrollFrame1, "BOTTOM", "TOP", 0, 0)
        CraftSim.FRAME:CreateHelpIcon("'(as result)' -> price override only considered when item is a result of a recipe", frame.content, title, "LEFT", "RIGHT", 3, 0)


        frame.content.clearAllButton = CraftSim.GGUI.Button({
            label="Clear All", parent=frame.content,anchorParent=title,anchorA="LEFT",anchorB="RIGHT",offsetX=30,sizeX=15,sizeY=18,adjustWidth=true,
            clickCallback=function ()
                CraftSim.PRICE_OVERRIDE:ClearAll()
                if frame.currentDropdownData then
                    overrideOptions:updateButtonStatus()
                end
                CraftSim.MAIN:TriggerModulesErrorSafe()
            end
        })

        
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
        priceOverrideFrame = CraftSim.GGUI:GetFrame(CraftSim.CONST.FRAMES.PRICE_OVERRIDE_WORK_ORDER)
    else
        priceOverrideFrame = CraftSim.GGUI:GetFrame(CraftSim.CONST.FRAMES.PRICE_OVERRIDE)
    end

    local overrideOptions = priceOverrideFrame.content.overrideOptions

    overrideOptions:Show()

    overrideOptions.itemIcon:SetItem(overrideData.item:GetItemLink())

    if overrideData.isResult then
        overrideOptions.useCraftDataCB:SetChecked(false)
        overrideOptions.useCraftDataCB:Hide(false)
        overrideOptions.craftDataUsageText:Hide()
        overrideOptions.currencyInputGold:Show()
    else
        local priceOverrideData = CraftSim.PRICE_OVERRIDE:GetGlobalOverride(overrideData.item:GetItemID())

        overrideOptions.useCraftDataCB:Show()
        if priceOverrideData then
            if priceOverrideData.useCraftData then
                overrideOptions.useCraftDataCB:SetChecked(true)
                overrideOptions.craftDataUsageText:Show()
                overrideOptions.currencyInputGold:Hide()
            else
                overrideOptions.useCraftDataCB:SetChecked(false)
                overrideOptions.craftDataUsageText:Hide()
                overrideOptions.currencyInputGold:Show()
            end
        end
  
    end
end

---@param recipeData CraftSim.RecipeData
---@param exportMode number
function CraftSim.PRICE_OVERRIDE.FRAMES:UpdateDisplay(recipeData, exportMode)
    local priceOverrideFrame = nil
    if exportMode == CraftSim.CONST.EXPORT_MODE.WORK_ORDER then
        priceOverrideFrame = CraftSim.GGUI:GetFrame(CraftSim.CONST.FRAMES.PRICE_OVERRIDE_WORK_ORDER)
    else
        priceOverrideFrame = CraftSim.GGUI:GetFrame(CraftSim.CONST.FRAMES.PRICE_OVERRIDE)
    end

    CraftSim.PRICE_OVERRIDE.FRAMES:UpdateOverrideList(priceOverrideFrame)

    if priceOverrideFrame.recipeID == recipeData.recipeID then
        -- same recipe, stay
    else
        -- recipe was changed, reload and hide the options again
        priceOverrideFrame.content.overrideOptions:Hide()
        priceOverrideFrame.recipeID = recipeData.recipeID
        
        local dropdownData = {
        }
        local reagentData = recipeData.reagentData
        if #reagentData.requiredReagents > 0 then
            local dropdownEntry = {label="Required Reagents", value = {}, isCategory=true}
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
            local dropdownEntry = {label="Optional Reagents", value = {}, isCategory=true}
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
            local dropdownEntry = {label="Finishing Reagents", value = {}, isCategory=true}
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
            local dropdownEntry = {label="Result Items", value = {}, isCategory=true}
            table.foreach(recipeData.resultData.itemsByQuality, function (qualityID, item)
                table.insert(dropdownEntry.value, {
                    label=item:GetItemLink(),
                    value=CraftSim.PRICE_OVERRIDE.OverrideDropdownData(item, true, qualityID),
                })
            end)
            table.insert(dropdownData, dropdownEntry)
        end
    
        --CraftSim.FRAME:initializeDropdownByData(priceOverrideFrame.content.itemDropdown, dropdownData, "")
        priceOverrideFrame.content.itemDropdown:SetData({data=dropdownData})
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
            if priceOverrideData.useCraftData then
                text = text .. item:GetItemLink() .. ": " .. CraftSim.GUTIL:ColorizeText("Use Craft Data", CraftSim.GUTIL.COLORS.BRIGHT_BLUE) .. "\n"
            else
                text = text .. item:GetItemLink() .. ": " .. CraftSim.GUTIL:FormatMoney(priceOverrideData.price) .. "\n"
            end
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