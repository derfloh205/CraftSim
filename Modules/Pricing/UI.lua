---@class CraftSim
local CraftSim = select(2, ...)

---@class CraftSim.PRICING
CraftSim.PRICING = CraftSim.PRICING

---@class CraftSim.PRICING.UI
CraftSim.PRICING.UI = {}

local GGUI = CraftSim.GGUI
local GUTIL = CraftSim.GUTIL

CraftSim.PRICING.frame = nil
CraftSim.PRICING.frameWO = nil

local print = CraftSim.DEBUG:RegisterDebugID("Modules.Pricing.UI")
local f = CraftSim.GUTIL:GetFormatter()
local L = CraftSim.UTIL:GetLocalizer()

function CraftSim.PRICING.UI:Init()
    local sizeX = 600
    local sizeY = 280
    local offsetX = -5
    local offsetY = -120

    local frameLevel = CraftSim.UTIL:NextFrameLevel()

    CraftSim.PRICING.frame = GGUI.Frame({
        parent = ProfessionsFrame.CraftingPage.SchematicForm,
        anchorParent = ProfessionsFrame,
        anchorA = "BOTTOM",
        anchorB = "BOTTOM",
        sizeX = sizeX,
        sizeY = sizeY,
        offsetY = offsetY,
        offsetX = offsetX,
        frameID = CraftSim.CONST.FRAMES.PRICING,
        title = L("PRICING_TITLE"),
        collapseable = true,
        closeable = true,
        moveable = true,
        backdropOptions = CraftSim.CONST.DEFAULT_BACKDROP_OPTIONS,
        onCloseCallback = CraftSim.CONTROL_PANEL:HandleModuleClose("MODULE_PRICING"),
        frameTable = CraftSim.INIT.FRAMES,
        frameConfigTable = CraftSim.DB.OPTIONS:Get("GGUI_CONFIG"),
        frameStrata = CraftSim.CONST.MODULES_FRAME_STRATA,
        raiseOnInteraction = true,
        frameLevel = frameLevel
    })
    CraftSim.PRICING.frameWO = GGUI.Frame({
        parent = ProfessionsFrame.OrdersPage.OrderView.OrderDetails.SchematicForm,
        anchorParent = ProfessionsFrame,
        anchorA = "BOTTOM",
        anchorB = "BOTTOM",
        sizeX = sizeX,
        sizeY = sizeY,
        offsetY = offsetY,
        offsetX = offsetX,
        frameID = CraftSim.CONST.FRAMES.COST_OPTIMIZATION_WO,
        title = L("PRICING_TITLE") .. " " ..
            CraftSim.GUTIL:ColorizeText(L("SOURCE_COLUMN_WO"),
                CraftSim.GUTIL.COLORS.GREY),
        collapseable = true,
        closeable = true,
        moveable = true,
        backdropOptions = CraftSim.CONST.DEFAULT_BACKDROP_OPTIONS,
        onCloseCallback = CraftSim.CONTROL_PANEL:HandleModuleClose("MODULE_PRICING"),
        frameTable = CraftSim.INIT.FRAMES,
        frameConfigTable = CraftSim.DB.OPTIONS:Get("GGUI_CONFIG"),
        frameStrata = CraftSim.CONST.MODULES_FRAME_STRATA,
        raiseOnInteraction = true,
        frameLevel = frameLevel
    })

    local function createContent(frame)
        local content = frame.content

        content.craftingCostsTitle = GGUI.Text({
            parent = content,
            anchorParent = frame.title.frame,
            anchorA = "TOP",
            anchorB = "BOTTOM",
            offsetX = -30,
            offsetY = -10,
            text = L("PRICING_CRAFTING_COSTS"),
        })
        content.craftingCostsValue = GGUI.Text({
            parent = content,
            anchorParent = content.craftingCostsTitle.frame,
            anchorA = "LEFT",
            anchorB = "RIGHT",
            text = CraftSim.UTIL:FormatMoney(123456789),
            justifyOptions = { type = "H", align = "LEFT" }
        })

        GGUI.HelpIcon({
            parent = content,
            anchorParent = frame.title.frame,
            anchorA = "LEFT",
            anchorB = "RIGHT",
            offsetX = 5,
            text = L("PRICING_EXPLANATION")
        })

        ---@type GGUI.CurrencyInput
        content.contextMenuOverridePriceInput = nil

        content.reagentList = GGUI.FrameList({
            parent = content,
            anchorParent = content,
            anchorA = "BOTTOMLEFT",
            anchorB = "BOTTOMLEFT",
            offsetY = 5,
            offsetX = 5,
            sizeY = 190,
            rowHeight = 20,
            showBorder = true,
            savedVariablesTableLayoutConfig = CraftSim.DB.OPTIONS:Get("FRAME_LIST_LAYOUT_CONFIGS")
                ["PRICING_REAGENT_LIST"],
            selectionOptions = {
                hoverRGBA = CraftSim.CONST.FRAME_LIST_SELECTION_COLORS.HOVER_LIGHT_WHITE,
                noSelectionColor = true,
                selectionCallback = function(row, userInput)
                    local item = row.item --[[@as ItemMixin]]
                    local recipeID = row.recipeID --[[@as RecipeID]]

                    if IsMouseButtonDown("RightButton") then
                        CraftSim.WIDGETS.ContextMenu.Open(UIParent, function(ownerRegion, rootDescription)
                            rootDescription:CreateTitle(item:GetItemLink())
                            rootDescription:CreateDivider()

                            local priceOverrideData = CraftSim.DB.PRICE_OVERRIDE:GetGlobalOverride(item:GetItemID())
                            local currentOverridePrice = 0
                            if priceOverrideData then
                                currentOverridePrice = priceOverrideData.price
                            end

                            GUTIL:CreateReuseableMenuUtilContextMenuFrame(rootDescription, function(frame)
                                frame.label = GGUI.Text {
                                    parent = frame,
                                    anchorPoints = { { anchorParent = frame, anchorA = "LEFT", anchorB = "LEFT" } },
                                    text = "Override Price: ",
                                    justifyOptions = { type = "H", align = "LEFT" },
                                }
                                frame.input = GGUI.CurrencyInput {
                                    parent = frame, anchorParent = frame,
                                    sizeX = 100, sizeY = 25, offsetX = 5,
                                    anchorA = "RIGHT", anchorB = "RIGHT",
                                    borderAdjustWidth = 0.95,
                                    initialValue = currentOverridePrice,
                                    tooltipOptions = {
                                        owner = frame,
                                        anchor = "ANCHOR_TOP",
                                        text = f.white("Format: " .. GUTIL:FormatMoney(1000000, false, nil, false, false)),
                                    },
                                }
                                content.contextMenuOverridePriceInput = frame.input
                            end, 200, 25, "COST_OPTIMIZATION_PRICE_OVERRIDE_INPUT")

                            if content.contextMenuOverridePriceInput then
                                content.contextMenuOverridePriceInput:SetValue(currentOverridePrice)
                            end

                            rootDescription:CreateButton(f.g("Save Price Override"), function()
                                local inputValue = content.contextMenuOverridePriceInput.total or 0
                                CraftSim.DB.PRICE_OVERRIDE:SaveGlobalOverride({
                                    itemID = item:GetItemID(),
                                    price = tonumber(inputValue),
                                    recipeID = recipeID,
                                    qualityID = C_TradeSkillUI.GetItemReagentQualityByItemInfo(item:GetItemID())
                                })
                                CraftSim.MODULES:UpdateUI()
                            end)

                            if priceOverrideData then
                                rootDescription:CreateButton(f.l("Delete Price Override"),
                                    function()
                                        CraftSim.DB.PRICE_OVERRIDE:DeleteGlobalOverride(item:GetItemID())
                                        CraftSim.MODULES:UpdateUI()
                                    end)
                            end
                        end)
                    end
                end
            },
            columnOptions = {
                {
                    label = L("PRICING_ITEM_HEADER"),
                    width = 40,
                    justifyOptions = { type = "H", align = "CENTER" },
                    resizable = true,
                },
                {
                    label = L("COST_OPTIMIZATION_PRICE_HEADER"),
                    width = 110,
                    sortFunc = function(rowA, rowB)
                        local priceA = rowA.price
                        local priceB = rowB.price
                        return priceA > priceB
                    end,
                    resizable = true,
                    resizeCallback = function(priceColumn, newWidth)
                        local text = priceColumn.text --[[@as GGUI.Text]]
                        text:SetWidth(newWidth - 10)
                    end
                },
                {
                    label = L("COST_OPTIMIZATION_USED_SOURCE"),
                    width = 80,
                    justifyOptions = { type = "H", align = "CENTER" },
                    resizable = true,
                },
            },
            rowConstructor = function(columns)
                ---@class CraftSim.COST_OPTIMIZATION.UI.REAGENT_LIST.ITEM_COLUMN : Frame
                local itemColumn = columns[1]
                ---@class CraftSim.COST_OPTIMIZATION.UI.REAGENT_LIST.PRICE_COLUMN : Frame
                local priceColumn = columns[2]
                ---@class CraftSim.COST_OPTIMIZATION.UI.REAGENT_LIST.SOURCE_COLUMN : Frame
                local sourceColumn = columns[3]

                itemColumn.itemIcon = GGUI.Icon({
                    parent = itemColumn,
                    anchorParent = itemColumn,
                    sizeX = 20,
                    sizeY = 20,
                    qualityIconScale = 1.3
                })

                priceColumn.text = GGUI.Text({
                    parent = priceColumn,
                    anchorParent = priceColumn,
                    anchorA = "LEFT",
                    anchorB = "LEFT",
                    justifyOptions = { type = "H", align = "LEFT" },
                    text = CraftSim.UTIL:FormatMoney(123456789),
                    fixedWidth = 110,
                    scale = 0.9,
                })

                sourceColumn.text = GGUI.Text({
                    parent = sourceColumn,
                    anchorParent = sourceColumn,
                    text = CraftSim.GUTIL:ColorizeText(
                        L("SOURCE_COLUMN_AH"), CraftSim.GUTIL.COLORS.GREEN),
                    scale = 0.9,
                })
                function sourceColumn:SetAH()
                    sourceColumn.text:SetText(CraftSim.GUTIL:ColorizeText(
                        L("SOURCE_COLUMN_AH"), CraftSim.GUTIL.COLORS.GREEN))
                end

                function sourceColumn:SetOverride()
                    sourceColumn.text:SetText(CraftSim.GUTIL:ColorizeText(
                        L("SOURCE_COLUMN_OVERRIDE"),
                        CraftSim.GUTIL.COLORS.LEGENDARY))
                end

                function sourceColumn:SetUnknown()
                    sourceColumn.text:SetText(CraftSim.GUTIL:ColorizeText("-", CraftSim.GUTIL.COLORS.RED))
                end
            end
        })

        ---@type GGUI.CurrencyInput
        content.resultContextMenuOverridePriceInput = nil

        content.resultItemsList = GGUI.FrameList({
            parent = content,
            anchorParent = content.reagentList.frame,
            anchorA = "TOPLEFT",
            anchorB = "TOPRIGHT",
            offsetX = 20,
            sizeY = 190,
            showBorder = true,
            selectionOptions = {
                hoverRGBA = CraftSim.CONST.FRAME_LIST_SELECTION_COLORS.HOVER_LIGHT_WHITE,
                noSelectionColor = true,
                selectionCallback = function(row, userInput)
                    local item = row.item --[[@as ItemMixin]]
                    local recipeID = row.recipeID --[[@as RecipeID]]
                    local qualityID = row.qualityID --[[@as number]]

                    if IsMouseButtonDown("RightButton") and item and recipeID and qualityID then
                        CraftSim.WIDGETS.ContextMenu.Open(UIParent, function(ownerRegion, rootDescription)
                            rootDescription:CreateTitle(item:GetItemLink())
                            rootDescription:CreateDivider()

                            local priceOverrideData = CraftSim.DB.PRICE_OVERRIDE:GetResultOverride(recipeID, qualityID)
                            local currentOverridePrice = 0
                            if priceOverrideData then
                                currentOverridePrice = priceOverrideData.price
                            end

                            GUTIL:CreateReuseableMenuUtilContextMenuFrame(rootDescription, function(frame)
                                frame.label = GGUI.Text {
                                    parent = frame,
                                    anchorPoints = { { anchorParent = frame, anchorA = "LEFT", anchorB = "LEFT" } },
                                    text = "Override Price: ",
                                    justifyOptions = { type = "H", align = "LEFT" },
                                }
                                frame.input = GGUI.CurrencyInput {
                                    parent = frame, anchorParent = frame,
                                    sizeX = 100, sizeY = 25, offsetX = 5,
                                    anchorA = "RIGHT", anchorB = "RIGHT",
                                    borderAdjustWidth = 0.95,
                                    initialValue = currentOverridePrice,
                                    tooltipOptions = {
                                        owner = frame,
                                        anchor = "ANCHOR_TOP",
                                        text = f.white("Format: " .. GUTIL:FormatMoney(1000000, false, nil, false, false)),
                                    },
                                }
                                content.resultContextMenuOverridePriceInput = frame.input
                            end, 200, 25, "PRICING_RESULT_PRICE_OVERRIDE_INPUT")

                            if content.resultContextMenuOverridePriceInput then
                                content.resultContextMenuOverridePriceInput:SetValue(currentOverridePrice)
                            end

                            rootDescription:CreateButton(f.g("Save Price Override"), function()
                                local inputValue = content.resultContextMenuOverridePriceInput.total or 0
                                CraftSim.DB.PRICE_OVERRIDE:SaveResultOverride({
                                    recipeID = recipeID,
                                    itemID = item:GetItemID(),
                                    price = tonumber(inputValue),
                                    qualityID = qualityID,
                                })
                                CraftSim.MODULES:UpdateUI()
                            end)

                            if priceOverrideData then
                                rootDescription:CreateButton(f.l("Delete Price Override"),
                                    function()
                                        CraftSim.DB.PRICE_OVERRIDE:DeleteResultOverride(recipeID, qualityID)
                                        CraftSim.MODULES:UpdateUI()
                                    end)
                            end
                        end)
                    end
                end
            },
            columnOptions = {
                {
                    label = L("PRICE_DETAILS_INV_AH"),
                    width = 60,
                    justifyOptions = { type = "H", align = "CENTER" },
                },
                {
                    label = L("PRICE_DETAILS_ITEM"),
                    width = 60,
                    justifyOptions = { type = "H", align = "CENTER" },
                },
                {
                    label = L("PRICE_DETAILS_PRICE_ITEM"),
                    width = 90,
                },
                {
                    label = L("PRICING_AVG_CRAFTING_COST"),
                    width = 90,
                },
            },
            rowConstructor = function(columns)
                local invColumn = columns[1]
                local itemColumn = columns[2]
                local priceColumn = columns[3]
                local avgCostColumn = columns[4]

                invColumn.text = GGUI.Text({
                    parent = invColumn, anchorParent = invColumn, scale = 0.9,
                })

                itemColumn.icon = GGUI.Icon({
                    parent = itemColumn,
                    anchorParent = itemColumn,
                    sizeX = 20,
                    sizeY = 20,
                    qualityIconScale = 1.3
                })

                priceColumn.text = GGUI.Text({
                    parent = priceColumn,
                    anchorParent = priceColumn,
                    justifyOptions = { type = "H", align = "LEFT" },
                    fixedWidth = priceColumn:GetWidth(),
                    scale = 0.9,
                })

                avgCostColumn.text = GGUI.Text({
                    parent = avgCostColumn,
                    anchorParent = avgCostColumn,
                    justifyOptions = { type = "H", align = "LEFT" },
                    fixedWidth = avgCostColumn:GetWidth(),
                    scale = 0.9,
                })
            end
        })

        GGUI:EnableHyperLinksForFrameAndChilds(frame.content)
        frame:Hide()
    end

    createContent(CraftSim.PRICING.frame)
    createContent(CraftSim.PRICING.frameWO)
end

---@param recipeData CraftSim.RecipeData
function CraftSim.PRICING:UpdateDisplay(recipeData)
    local costOptimizationFrame = nil
    local exportMode = CraftSim.UTIL:GetExportModeByVisibility()
    if exportMode == CraftSim.CONST.EXPORT_MODE.WORK_ORDER then
        costOptimizationFrame = CraftSim.PRICING.frameWO
    else
        costOptimizationFrame = CraftSim.PRICING.frame
    end

    print("Pricing - Reagent List Update", false, true)

    costOptimizationFrame.content.craftingCostsValue:SetText(CraftSim.UTIL:FormatMoney(
        recipeData.priceData.craftingCosts))

    local reagentList = costOptimizationFrame.content.reagentList --[[@as GGUI.FrameList]]
    reagentList:Remove()

    ---@type ItemMixin[]
    local itemList = {}

    if recipeData.isSalvageRecipe then
        for _, reagent in ipairs(recipeData.reagentData.salvageReagentSlot.possibleItems) do
            tinsert(itemList, reagent)
        end
    end

    for _, reagent in ipairs(recipeData.reagentData.requiredReagents) do
        for _, reagentItem in pairs(reagent.items) do
            tinsert(itemList, reagentItem.item)
        end
    end

    ---@type CraftSim.OptionalReagent[]
    local possibleOptionals = {}
    local slots = CraftSim.GUTIL:Concat({ recipeData.reagentData.optionalReagentSlots, recipeData.reagentData
        .finishingReagentSlots })

    if recipeData.reagentData:HasRequiredSelectableReagent() then
        tinsert(slots, recipeData.reagentData.requiredSelectableReagentSlot)
    end

    for _, slot in pairs(slots) do
        tAppendAll(possibleOptionals, slot.possibleReagents)
    end

    for _, optional in ipairs(possibleOptionals) do
        if not optional:IsCurrency() then
            tinsert(itemList, optional.item)
        end
    end

    for _, reagentItemMixin in pairs(itemList) do
        reagentList:Add(function(row, columns)
            local itemColumn = columns[1] --[[@as CraftSim.COST_OPTIMIZATION.UI.REAGENT_LIST.ITEM_COLUMN]]
            local priceColumn = columns[2] --[[@as CraftSim.COST_OPTIMIZATION.UI.REAGENT_LIST.PRICE_COLUMN]]
            local sourceColumn = columns[3] --[[@as CraftSim.COST_OPTIMIZATION.UI.REAGENT_LIST.SOURCE_COLUMN]]

            itemColumn.itemIcon:SetItem(reagentItemMixin)
            local tooltip = ""
            local itemID = reagentItemMixin:GetItemID()
            local reagentPriceInfo = recipeData.priceData.reagentPriceInfos[itemID]
            local price = reagentPriceInfo.itemPrice
            local priceInfo = reagentPriceInfo.priceInfo

            row.price = price
            row.item = reagentItemMixin
            row.recipeID = recipeData.recipeID

            -- Show used price in the price column
            priceColumn.text:SetText(CraftSim.UTIL:FormatMoney(price))

            -- Build tooltip with original AH price info
            if priceInfo.noAHPriceFound then
                tooltip = tooltip ..
                    L("PRICING_REAGENT_LIST_AH_COLUMN_AUCTION_BUYOUT") ..
                    f.grey("-")
            else
                tooltip = tooltip ..
                    L("PRICING_REAGENT_LIST_AH_COLUMN_AUCTION_BUYOUT") ..
                    CraftSim.UTIL:FormatMoney(priceInfo.ahPrice)
            end

            if priceInfo.isOverride then
                tooltip = tooltip ..
                    L("PRICING_REAGENT_LIST_OVERRIDE") ..
                    CraftSim.UTIL:FormatMoney(priceInfo.ahPrice) .. "\n"
                sourceColumn:SetOverride()
            elseif priceInfo.isAHPrice then
                sourceColumn:SetAH()
            else
                sourceColumn:SetUnknown()
            end

            row.tooltipOptions = {
                anchor = "ANCHOR_CURSOR",
                owner = row.frame,
                text = f.white(tooltip),
            }
        end)
    end

    reagentList:UpdateDisplay()
    CraftSim.PRICING.UI:UpdateResultItemsList(recipeData, costOptimizationFrame)
end

---@param recipeData CraftSim.RecipeData
---@param costOptimizationFrame GGUI.Frame
function CraftSim.PRICING.UI:UpdateResultItemsList(recipeData, costOptimizationFrame)
    local resultItemsList = costOptimizationFrame.content.resultItemsList --[[@as GGUI.FrameList]]
    resultItemsList:Remove()

    local priceData = recipeData.priceData
    local resultData = recipeData.resultData
    local itemQualityList = resultData.itemsByQuality

    CraftSim.GUTIL:ContinueOnAllItemsLoaded(itemQualityList, function()
        for qualityID, resultItem in pairs(itemQualityList) do
            resultItemsList:Add(function(row)
                local invColumn = row.columns[1]
                local itemColumn = row.columns[2]
                local priceColumn = row.columns[3]
                local avgCostColumn = row.columns[4]

                local itemLink = resultItem:GetItemLink()
                itemColumn.icon:SetItem(resultItem)

                local priceOverride = CraftSim.DB.PRICE_OVERRIDE:GetResultOverridePrice(recipeData.recipeID, qualityID)
                local price = priceOverride or CraftSim.PRICE_SOURCE:GetMinBuyoutByItemLink(itemLink)

                priceColumn.text:SetText(CraftSim.UTIL:FormatMoney(price) ..
                    ((priceOverride and CraftSim.GUTIL:ColorizeText(" (OR)", CraftSim.GUTIL.COLORS.LEGENDARY)) or ""))

                avgCostColumn.text:SetText(CraftSim.UTIL:FormatMoney(priceData.averageCraftingCosts))

                local itemCount = C_Item.GetItemCount(itemLink, true, false, true)
                local ahCount = CraftSim.PRICE_SOURCE:GetAuctionAmount(itemLink)

                if ahCount then
                    invColumn.text:SetText((itemCount or 0) .. "/" .. ahCount)
                else
                    invColumn.text:SetText(itemCount or 0)
                end

                row.item = resultItem
                row.recipeID = recipeData.recipeID
                row.qualityID = qualityID
            end)
        end

        resultItemsList:UpdateDisplay()
    end)
end
