---@class CraftSim
local CraftSim = select(2, ...)

local GGUI = CraftSim.GGUI
local GUTIL = CraftSim.GUTIL
local f = GUTIL:GetFormatter()
local L = CraftSim.UTIL:GetLocalizer()

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

---@class CraftSim.PRICE_OVERRIDE.UI
CraftSim.PRICE_OVERRIDE.UI = {}

local print = CraftSim.DEBUG:RegisterDebugID("Modules.PriceOverride.UI")

function CraftSim.PRICE_OVERRIDE.UI:Init()
    local sizeX = 450
    local sizeY = 300

    local frameNO_WO = GGUI.Frame({
        parent = ProfessionsFrame.CraftingPage.SchematicForm,
        anchorParent = ProfessionsFrame.CraftingPage.SchematicForm,
        sizeX = sizeX,
        sizeY = sizeY,
        frameID = CraftSim.CONST.FRAMES.PRICE_OVERRIDE,
        title = CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.PRICE_OVERRIDE_TITLE),
        collapseable = true,
        closeable = true,
        moveable = true,
        backdropOptions = CraftSim.CONST.DEFAULT_BACKDROP_OPTIONS,
        frameStrata = "DIALOG",
        onCloseCallback = CraftSim.CONTROL_PANEL:HandleModuleClose("MODULE_PRICE_OVERRIDE"),
        frameTable = CraftSim.INIT.FRAMES,
        frameConfigTable = CraftSim.DB.OPTIONS:Get("GGUI_CONFIG"),
    })
    local frameWO = GGUI.Frame({
        parent = ProfessionsFrame.OrdersPage.OrderView.OrderDetails.SchematicForm,
        anchorParent = ProfessionsFrame.CraftingPage.SchematicForm,
        sizeX = sizeX,
        sizeY = sizeY,
        frameID = CraftSim.CONST.FRAMES.PRICE_OVERRIDE_WORK_ORDER,
        title = CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.PRICE_OVERRIDE_TITLE) ..
            " " ..
            CraftSim.GUTIL:ColorizeText(CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.SOURCE_COLUMN_WO),
                CraftSim.GUTIL.COLORS.GREY),
        collapseable = true,
        closeable = true,
        moveable = true,
        backdropOptions = CraftSim.CONST.DEFAULT_BACKDROP_OPTIONS,
        frameStrata = "DIALOG",
        onCloseCallback = CraftSim.CONTROL_PANEL:HandleModuleClose("MODULE_PRICE_OVERRIDE"),
        frameTable = CraftSim.INIT.FRAMES,
        frameConfigTable = CraftSim.DB.OPTIONS:Get("GGUI_CONFIG"),
    })

    local function createContentV2(frame)
        local overrideOptions = nil

        ---@param overrideData CraftSim.PRICE_OVERRIDE.overrideDropdownData
        local function selectionCallback(_, _, overrideData)
            print("Selected itemID: " .. tostring(overrideData.item:GetItemID()))
            frame.currentDropdownData = overrideData
            CraftSim.PRICE_OVERRIDE.UI:UpdateOverrideItem(overrideData)
            overrideOptions:updateButtonStatus()
        end

        GGUI.Text {
            parent = frame.content,
            anchorPoints = { { anchorParent = frame.title.frame, anchorA = "TOP", anchorB = "BOTTOM", offsetY = -3 } },
            text = f.r("(You can now override prices directly in the " .. f.bb("Cost Optimization Module") .. ")"),
            scale = 0.9,
        }

        frame.recipeID = nil

        frame.content.itemDropdown = GGUI.Dropdown({
            parent = frame.content,
            anchorParent = frame.title.frame,
            anchorA = "TOP",
            anchorB = "TOP",
            offsetY = -30,
            width = 150,
            clickCallback = selectionCallback
        })

        frame.content.overrideOptions = CreateFrame("Frame", nil, frame.content)
        frame.content.overrideOptions:SetSize(200, 80)
        frame.content.overrideOptions:SetPoint("TOP", frame.content.itemDropdown.frame, "BOTTOM", 0, 0)

        overrideOptions = frame.content.overrideOptions

        overrideOptions:Hide()

        overrideOptions.itemIcon = GGUI.Icon({
            parent = overrideOptions,
            anchorParent = overrideOptions,
            offsetX = 20,
            sizeX = 30,
            sizeY = 30,
            anchorA = "TOPLEFT",
            anchorB = "TOPLEFT",
        })

        function overrideOptions:updateButtonStatus()
            local currentData = frame.currentDropdownData

            local overrideData = nil
            if currentData.isResult then
                overrideData = CraftSim.DB.PRICE_OVERRIDE:GetResultOverride(frame.recipeID, currentData.qualityID)
            else
                overrideData = CraftSim.DB.PRICE_OVERRIDE:GetGlobalOverride(currentData.item:GetItemID())
            end

            overrideOptions.removeButton:SetEnabled(overrideData)

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

        overrideOptions.saveButton = GGUI.Button({
            parent = overrideOptions,
            anchorParent = overrideOptions.itemIcon.frame,
            anchorA = "BOTTOMLEFT",
            anchorB = "BOTTOMRIGHT",
            offsetX = 3,
            offsetY = -25,
            sizeX = 25,
            sizeY = 25,
            adjustWidth = true,
            clickCallback = function()
                CraftSim.PRICE_OVERRIDE:SaveOverrideDataByDropdown(frame.recipeID, frame.currentDropdownData)
                overrideOptions:updateButtonStatus()
                CraftSim.INIT:TriggerModuleUpdate()
            end,
            initialStatus = "READY",
            label = CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.PRICE_OVERRIDE_SAVE),
        })
        overrideOptions.saveButton:SetStatusList({
            {
                statusID = "READY",
                enabled = true,
                label = CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.PRICE_OVERRIDE_SAVE),
            },
            {
                statusID = "SAVED",
                enabled = false,
                label = CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.PRICE_OVERRIDE_SAVED),
            },
            {
                statusID = "INVALID",
                enabled = false,
                label = CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.PRICE_OVERRIDE_SAVE),
            },
        })

        overrideOptions.removeButton = GGUI.Button({
            parent = overrideOptions,
            anchorParent = overrideOptions.saveButton.frame,
            anchorA = "LEFT",
            anchorB = "RIGHT",
            offsetX = 3,
            sizeX = 15,
            sizeY = 25,
            adjustWidth = true,
            clickCallback = function()
                CraftSim.PRICE_OVERRIDE:DeleteOverrideDataByDropdown(frame.recipeID, frame.currentDropdownData)
                overrideOptions:updateButtonStatus()
                overrideOptions.currencyInputGold:SetValue(0)
                CraftSim.INIT:TriggerModuleUpdate()
            end,
            label = CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.PRICE_OVERRIDE_REMOVE),
        })

        overrideOptions.currencyInputGold = GGUI.CurrencyInput({
            parent = overrideOptions,
            anchorParent = overrideOptions.itemIcon.frame,
            anchorA = "LEFT",
            anchorB = "RIGHT",
            offsetX = 10,
            sizeX = 80,
            sizeY = 25,
            onValidationChangedCallback = function() overrideOptions:updateButtonStatus() end,
            showFormatHelpIcon = true,
            initialValue = 0,

        })

        frame.content.scrollFrame1, frame.content.activeOverridesBox = CraftSim.FRAME:CreateScrollFrame(frame.content,
            -170, 50, -50, 30)
        local title = CraftSim.FRAME:CreateText(
            CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.PRICE_OVERRIDE_ACTIVE_OVERRIDES), frame.content,
            frame.content.scrollFrame1, "BOTTOM", "TOP", 0, 0)
        CraftSim.FRAME:CreateHelpIcon(
            CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.PRICE_OVERRIDE_ACTIVE_OVERRIDES_TOOLTIP), frame.content, title,
            "LEFT",
            "RIGHT", 3, 0)


        frame.content.clearAllButton = GGUI.Button({
            label = CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.PRICE_OVERRIDE_CLEAR_ALL),
            parent = frame.content,
            anchorParent = title,
            anchorA = "LEFT",
            anchorB = "RIGHT",
            offsetX = 30,
            sizeX = 15,
            sizeY = 18,
            adjustWidth = true,
            clickCallback = function()
                CraftSim.DB.PRICE_OVERRIDE:ClearAll()
                if frame.currentDropdownData then
                    overrideOptions:updateButtonStatus()
                end
                CraftSim.INIT:TriggerModuleUpdate()
            end
        })


        frame.content.activeOverridesBox.overrideList = CraftSim.FRAME:CreateText("", frame.content.activeOverridesBox,
            frame.content.activeOverridesBox,
            "TOPLEFT", "TOPLEFT", 0, 0, 0.85, nil, { type = "H", value = "LEFT" })
        GGUI:EnableHyperLinksForFrameAndChilds(frame.content)
    end

    createContentV2(frameNO_WO)
    createContentV2(frameWO)
end

---@param overrideData CraftSim.PRICE_OVERRIDE.overrideDropdownData
function CraftSim.PRICE_OVERRIDE.UI:UpdateOverrideItem(overrideData)
    local exportMode = CraftSim.UTIL:GetExportModeByVisibility()
    local priceOverrideFrame = nil
    if exportMode == CraftSim.CONST.EXPORT_MODE.WORK_ORDER then
        priceOverrideFrame = GGUI:GetFrame(CraftSim.INIT.FRAMES, CraftSim.CONST.FRAMES
            .PRICE_OVERRIDE_WORK_ORDER)
    else
        priceOverrideFrame = GGUI:GetFrame(CraftSim.INIT.FRAMES, CraftSim.CONST.FRAMES.PRICE_OVERRIDE)
    end

    local overrideOptions = priceOverrideFrame.content.overrideOptions

    overrideOptions:Show()

    overrideOptions.itemIcon:SetItem(overrideData.item:GetItemLink())
end

---@param recipeData CraftSim.RecipeData
---@param exportMode number
function CraftSim.PRICE_OVERRIDE.UI:UpdateDisplay(recipeData, exportMode)
    local priceOverrideFrame = nil
    if exportMode == CraftSim.CONST.EXPORT_MODE.WORK_ORDER then
        priceOverrideFrame = GGUI:GetFrame(CraftSim.INIT.FRAMES, CraftSim.CONST.FRAMES
            .PRICE_OVERRIDE_WORK_ORDER)
    else
        priceOverrideFrame = GGUI:GetFrame(CraftSim.INIT.FRAMES, CraftSim.CONST.FRAMES.PRICE_OVERRIDE)
    end

    CraftSim.PRICE_OVERRIDE.UI:UpdateOverrideList(priceOverrideFrame)

    if priceOverrideFrame.recipeID == recipeData.recipeID then
        -- same recipe, stay
    else
        -- recipe was changed, reload and hide the options again
        priceOverrideFrame.content.overrideOptions:Hide()
        priceOverrideFrame.recipeID = recipeData.recipeID

        -- collect items to wait for and continue when everything has loaded to prevent empty links
        local items = {}
        local reagentData = recipeData.reagentData

        table.foreach(reagentData.requiredReagents or {}, function(_, reagent)
            table.foreach(reagent.items, function(_, reagentItem)
                table.insert(items, reagentItem.item)
            end)
        end)

        local allPossibleOptionalReagents = {}
        table.foreach(reagentData.optionalReagentSlots, function(_, slot)
            allPossibleOptionalReagents = CraftSim.GUTIL:Concat({ allPossibleOptionalReagents, slot.possibleReagents })
        end)
        table.foreach(allPossibleOptionalReagents, function(_, optionalReagent)
            table.insert(items, optionalReagent.item)
        end)

        local allPossibleFinishingReagents = {}
        table.foreach(reagentData.finishingReagentSlots, function(_, slot)
            allPossibleFinishingReagents = CraftSim.GUTIL:Concat({ allPossibleFinishingReagents, slot.possibleReagents })
        end)
        table.foreach(allPossibleFinishingReagents, function(_, optionalReagent)
            table.insert(items, optionalReagent.item)
        end)

        local dropdownData = {}

        CraftSim.GUTIL:ContinueOnAllItemsLoaded(items, function()
            local reagentData = recipeData.reagentData
            if #reagentData.requiredReagents > 0 then
                local dropdownEntry = {
                    label = CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT
                        .PRICE_OVERRIDE_REQUIRED_REAGENTS),
                    value = {},
                    isCategory = true
                }
                table.foreach(reagentData.requiredReagents, function(_, reagent)
                    table.foreach(reagent.items, function(_, reagentItem)
                        local reagentLabel = reagentItem.item:GetItemLink()
                        table.insert(dropdownEntry.value, {
                            label = reagentLabel,
                            value = CraftSim.PRICE_OVERRIDE.OverrideDropdownData(reagentItem.item, false),
                        })
                    end)
                end)
                table.insert(dropdownData, dropdownEntry)
            end

            if #reagentData.optionalReagentSlots > 0 then
                local dropdownEntry = {
                    label = CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT
                        .PRICE_OVERRIDE_OPTIONAL_REAGENTS),
                    value = {},
                    isCategory = true
                }
                local allPossibleReagents = {}
                table.foreach(reagentData.optionalReagentSlots, function(_, slot)
                    allPossibleReagents = CraftSim.GUTIL:Concat({ allPossibleReagents, slot.possibleReagents })
                end)
                table.foreach(allPossibleReagents, function(_, optionalReagent)
                    local reagentLabel = optionalReagent.item:GetItemLink()
                    table.insert(dropdownEntry.value, {
                        label = reagentLabel,
                        value = CraftSim.PRICE_OVERRIDE.OverrideDropdownData(optionalReagent.item, false),
                    })
                end)
                table.insert(dropdownData, dropdownEntry)
            end

            if #reagentData.finishingReagentSlots > 0 then
                local dropdownEntry = {
                    label = CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT
                        .PRICE_OVERRIDE_FINISHING_REAGENTS),
                    value = {},
                    isCategory = true
                }
                local allPossibleReagents = {}
                table.foreach(reagentData.finishingReagentSlots, function(_, slot)
                    allPossibleReagents = CraftSim.GUTIL:Concat({ allPossibleReagents, slot.possibleReagents })
                end)
                table.foreach(allPossibleReagents, function(_, optionalReagent)
                    local reagentLabel = optionalReagent.item:GetItemLink()
                    table.insert(dropdownEntry.value, {
                        label = reagentLabel,
                        value = CraftSim.PRICE_OVERRIDE.OverrideDropdownData(optionalReagent.item, false),
                    })
                end)
                table.insert(dropdownData, dropdownEntry)
            end

            if #recipeData.resultData.itemsByQuality > 0 then
                local dropdownEntry = { label = CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.PRICE_OVERRIDE_RESULT_ITEMS), value = {}, isCategory = true }
                table.foreach(recipeData.resultData.itemsByQuality, function(qualityID, item)
                    table.insert(dropdownEntry.value, {
                        label = item:GetItemLink(),
                        value = CraftSim.PRICE_OVERRIDE.OverrideDropdownData(item, true, qualityID),
                    })
                end)
                table.insert(dropdownData, dropdownEntry)
            end

            priceOverrideFrame.content.itemDropdown:SetData({ data = dropdownData })
        end)
    end
end

function CraftSim.PRICE_OVERRIDE.UI:UpdateOverrideList(priceOverrideFrame)
    local overrideText = priceOverrideFrame.content.activeOverridesBox.overrideList

    local globalOverrides = CraftSim.DB.PRICE_OVERRIDE:GetGlobalOverrides()
    local recipeOverrides = CraftSim.DB.PRICE_OVERRIDE:GetResultOverrides()
    local resultOverrides = {}
    table.foreach(recipeOverrides, function(_, resultOverrideList)
        table.foreach(resultOverrideList, function(_, resultOverride)
            table.insert(resultOverrides, Item:CreateFromItemID(resultOverride.itemID))
        end)
    end)

    local itemsToLoad = CraftSim.GUTIL:Map(globalOverrides,
        function(override) return Item:CreateFromItemID(override.itemID) end)
    itemsToLoad = CraftSim.GUTIL:Concat({ itemsToLoad, CraftSim.GUTIL:Map(resultOverrides,
        function(override) return Item:CreateFromItemID(override.itemID) end) })

    CraftSim.GUTIL:ContinueOnAllItemsLoaded(itemsToLoad, function()
        local text = ""
        table.foreach(globalOverrides, function(_, priceOverrideData)
            local item = Item:CreateFromItemID(priceOverrideData.itemID)
            text = text .. item:GetItemLink() .. ": " .. CraftSim.UTIL:FormatMoney(priceOverrideData.price) .. "\n"
        end)

        table.foreach(recipeOverrides, function(_, resultOverrideList)
            table.foreach(resultOverrideList, function(_, resultOverride)
                local item = Item:CreateFromItemID(resultOverride.itemID)
                text = text ..
                    item:GetItemLink() ..
                    ": " ..
                    CraftSim.UTIL:FormatMoney(resultOverride.price) ..
                    " " .. CraftSim.GUTIL:ColorizeText("(as result)", CraftSim.GUTIL.COLORS.BRIGHT_BLUE) .. "\n"
            end)
        end)

        overrideText:SetText(text)
    end)
end
