---@class CraftSim
local CraftSim = select(2, ...)

---@class CraftSim.REAGENT_SHOPPING
CraftSim.REAGENT_SHOPPING = CraftSim.REAGENT_SHOPPING

---@class CraftSim.REAGENT_SHOPPING.UI
CraftSim.REAGENT_SHOPPING.UI = {}

---@class CraftSim.REAGENT_SHOPPING.FRAME : GGUI.Frame
CraftSim.REAGENT_SHOPPING.frame = nil

local GUTIL = CraftSim.GUTIL
local GGUI = CraftSim.GGUI
local L = CraftSim.UTIL:GetLocalizer()
local f = GUTIL:GetFormatter()
local LID = CraftSim.CONST.TEXT

local print = CraftSim.DEBUG:RegisterDebugID("Modules.ReagentShopping.UI")

function CraftSim.REAGENT_SHOPPING.UI:Init()
    local sizeX = 600
    local sizeY = 400

    ---@class CraftSim.REAGENT_SHOPPING.FRAME : GGUI.Frame
    CraftSim.REAGENT_SHOPPING.frame = GGUI.Frame({
        parent = ProfessionsFrame,
        anchorParent = ProfessionsFrame,
        anchorA = "TOPRIGHT",
        anchorB = "BOTTOMRIGHT",
        sizeX = sizeX,
        sizeY = sizeY,
        frameID = CraftSim.CONST.FRAMES.REAGENT_SHOPPING,
        title = L(CraftSim.CONST.TEXT.REAGENT_SHOPPING_TITLE),
        collapseable = true,
        closeable = true,
        moveable = true,
        backdropOptions = CraftSim.CONST.DEFAULT_BACKDROP_OPTIONS,
        onCloseCallback = CraftSim.CONTROL_PANEL:HandleModuleClose("MODULE_REAGENT_SHOPPING"),
        frameTable = CraftSim.INIT.FRAMES,
        frameConfigTable = CraftSim.DB.OPTIONS:Get("GGUI_CONFIG"),
        frameStrata = CraftSim.CONST.MODULES_FRAME_STRATA,
        raiseOnInteraction = true,
        frameLevel = CraftSim.UTIL:NextFrameLevel()
    })

    ---@class CraftSim.REAGENT_SHOPPING.FRAME.CONTENT : Frame
    local content = CraftSim.REAGENT_SHOPPING.frame.content

    -- Shopping List Tab
    content.shoppingListTab = GGUI.BlizzardTab({
        buttonOptions = {
            parent = content,
            anchorParent = content,
            offsetY = -2,
            label = L(LID.REAGENT_SHOPPING_TAB_SHOPPING_LIST),
        },
        parent = content,
        anchorParent = content,
        sizeX = sizeX,
        sizeY = sizeY,
        canBeEnabled = true,
        offsetY = -30,
        initialTab = true,
        top = true,
    })

    -- Options Tab
    content.optionsTab = GGUI.BlizzardTab({
        buttonOptions = {
            parent = content,
            anchorParent = content.shoppingListTab.button,
            anchorA = "LEFT",
            anchorB = "RIGHT",
            label = L(LID.REAGENT_SHOPPING_TAB_OPTIONS),
        },
        parent = content,
        anchorParent = content,
        sizeX = sizeX,
        sizeY = sizeY,
        canBeEnabled = true,
        offsetY = -30,
        top = true,
    })

    self:InitializeShoppingListTab(content.shoppingListTab)
    self:InitializeOptionsTab(content.optionsTab)

    GGUI.BlizzardTabSystem { content.shoppingListTab, content.optionsTab }
end

---@param shoppingListTab GGUI.BlizzardTab
function CraftSim.REAGENT_SHOPPING.UI:InitializeShoppingListTab(shoppingListTab)
    local content = shoppingListTab.content

    -- Reagent List
    content.reagentList = GGUI.FrameList {
        parent = content, anchorParent = content, anchorA = "TOPLEFT", anchorB = "TOPLEFT",
        offsetY = -30, offsetX = 10,
        showBorder = true, sizeY = 260, autoAdjustHeight = false,
        selectionOptions = {
            noSelectionColor = true,
            hoverRGBA = CraftSim.CONST.FRAME_LIST_SELECTION_COLORS.HOVER_LIGHT_WHITE,
        },
        columnOptions = {
            {
                label = L(LID.REAGENT_SHOPPING_ITEM_HEADER),
                width = 200,
            },
            {
                label = L(LID.REAGENT_SHOPPING_NEEDED_HEADER),
                width = 60,
                justifyOptions = { type = "H", align = "CENTER" },
            },
            {
                label = L(LID.REAGENT_SHOPPING_INVENTORY_HEADER),
                width = 60,
                justifyOptions = { type = "H", align = "CENTER" },
            },
            {
                label = L(LID.REAGENT_SHOPPING_TO_BUY_HEADER),
                width = 60,
                justifyOptions = { type = "H", align = "CENTER" },
            },
            {
                label = L(LID.REAGENT_SHOPPING_UNIT_PRICE_HEADER),
                width = 90,
                justifyOptions = { type = "H", align = "RIGHT" },
            },
            {
                label = L(LID.REAGENT_SHOPPING_TOTAL_PRICE_HEADER),
                width = 90,
                justifyOptions = { type = "H", align = "RIGHT" },
            },
        },
        rowConstructor = function(columns, row)
            ---@class CraftSim.REAGENT_SHOPPING.ShoppingList.Row : GGUI.FrameList.Row
            row = row
            row.itemID = nil

            ---@class CraftSim.REAGENT_SHOPPING.ShoppingList.ItemColumn : Frame
            local itemColumn = columns[1]
            ---@class CraftSim.REAGENT_SHOPPING.ShoppingList.NeededColumn : Frame
            local neededColumn = columns[2]
            ---@class CraftSim.REAGENT_SHOPPING.ShoppingList.InventoryColumn : Frame
            local inventoryColumn = columns[3]
            ---@class CraftSim.REAGENT_SHOPPING.ShoppingList.ToBuyColumn : Frame
            local toBuyColumn = columns[4]
            ---@class CraftSim.REAGENT_SHOPPING.ShoppingList.UnitPriceColumn : Frame
            local unitPriceColumn = columns[5]
            ---@class CraftSim.REAGENT_SHOPPING.ShoppingList.TotalPriceColumn : Frame
            local totalPriceColumn = columns[6]

            itemColumn.text = GGUI.Text {
                parent = itemColumn, anchorParent = itemColumn,
                justifyOptions = { type = "H", align = "LEFT" },
                anchorA = "LEFT", anchorB = "LEFT", fixedWidth = 200,
            }
            neededColumn.text = GGUI.Text {
                parent = neededColumn, anchorParent = neededColumn,
            }
            inventoryColumn.text = GGUI.Text {
                parent = inventoryColumn, anchorParent = inventoryColumn,
            }
            toBuyColumn.text = GGUI.Text {
                parent = toBuyColumn, anchorParent = toBuyColumn,
            }
            unitPriceColumn.text = GGUI.Text {
                parent = unitPriceColumn, anchorParent = unitPriceColumn,
                justifyOptions = { type = "H", align = "RIGHT" },
                anchorA = "RIGHT", anchorB = "RIGHT",
            }
            totalPriceColumn.text = GGUI.Text {
                parent = totalPriceColumn, anchorParent = totalPriceColumn,
                justifyOptions = { type = "H", align = "RIGHT" },
                anchorA = "RIGHT", anchorB = "RIGHT",
            }
        end,
    }

    -- Bottom controls
    content.totalCostLabel = GGUI.Text {
        parent = content, anchorParent = content.reagentList.frame,
        anchorA = "TOPLEFT", anchorB = "BOTTOMLEFT",
        offsetY = -10, offsetX = 5,
        text = L(LID.REAGENT_SHOPPING_TOTAL_COST_LABEL) .. ": " .. f.white("0g"),
    }

    content.refreshButton = GGUI.Button({
        parent = content,
        anchorParent = content.reagentList.frame,
        anchorA = "TOPRIGHT",
        anchorB = "BOTTOMRIGHT",
        offsetY = -5, offsetX = 0,
        label = L(LID.REAGENT_SHOPPING_REFRESH_BUTTON),
        sizeX = 100, sizeY = 25,
        adjustWidth = true,
        clickCallback = function()
            CraftSim.REAGENT_SHOPPING:BuildShoppingList()
            CraftSim.REAGENT_SHOPPING.UI:UpdateDisplay()
        end,
    })

    content.clearButton = GGUI.Button({
        parent = content,
        anchorParent = content.refreshButton.frame,
        anchorA = "RIGHT",
        anchorB = "LEFT",
        offsetX = -5,
        label = L(LID.REAGENT_SHOPPING_CLEAR_BUTTON),
        sizeX = 80, sizeY = 25,
        adjustWidth = true,
        clickCallback = function()
            CraftSim.REAGENT_SHOPPING:ClearList()
            CraftSim.REAGENT_SHOPPING.UI:UpdateDisplay()
        end,
    })

    content.exportAuctionatorButton = GGUI.Button({
        parent = content,
        anchorParent = content.clearButton.frame,
        anchorA = "RIGHT",
        anchorB = "LEFT",
        offsetX = -5,
        label = L(LID.REAGENT_SHOPPING_EXPORT_AUCTIONATOR_BUTTON),
        sizeX = 150, sizeY = 25,
        adjustWidth = true,
        clickCallback = function()
            CraftSim.REAGENT_SHOPPING:ExportToAuctionator()
        end,
    })
end

---@param optionsTab GGUI.BlizzardTab
function CraftSim.REAGENT_SHOPPING.UI:InitializeOptionsTab(optionsTab)
    local content = optionsTab.content

    content.infoText = GGUI.Text {
        parent = content, anchorParent = content,
        anchorA = "TOP", anchorB = "TOP",
        offsetY = -20,
        text = L(LID.REAGENT_SHOPPING_OPTIONS_INFO),
    }
end

function CraftSim.REAGENT_SHOPPING.UI:UpdateDisplay()
    local shoppingList = CraftSim.REAGENT_SHOPPING.shoppingList
    local reagentList = CraftSim.REAGENT_SHOPPING.frame.content.shoppingListTab.content.reagentList
    local content = CraftSim.REAGENT_SHOPPING.frame.content.shoppingListTab.content

    reagentList:Remove()

    for _, listItem in pairs(shoppingList) do
        reagentList:Add(
        ---@param row CraftSim.REAGENT_SHOPPING.ShoppingList.Row
            function(row)
                row.itemID = listItem.itemID
                local columns = row.columns
                local itemColumn = columns[1] --[[@as CraftSim.REAGENT_SHOPPING.ShoppingList.ItemColumn]]
                local neededColumn = columns[2] --[[@as CraftSim.REAGENT_SHOPPING.ShoppingList.NeededColumn]]
                local inventoryColumn = columns[3] --[[@as CraftSim.REAGENT_SHOPPING.ShoppingList.InventoryColumn]]
                local toBuyColumn = columns[4] --[[@as CraftSim.REAGENT_SHOPPING.ShoppingList.ToBuyColumn]]
                local unitPriceColumn = columns[5] --[[@as CraftSim.REAGENT_SHOPPING.ShoppingList.UnitPriceColumn]]
                local totalPriceColumn = columns[6] --[[@as CraftSim.REAGENT_SHOPPING.ShoppingList.TotalPriceColumn]]

                local itemName = listItem.itemName
                if listItem.isVendorItem then
                    itemName = f.bb(itemName) .. " " .. GUTIL:IconToText("Interface\\Icons\\INV_Misc_Coin_01", 13, 13)
                else
                    itemName = f.white(itemName)
                end

                itemColumn.text:SetText(itemName)
                neededColumn.text:SetText(f.white(listItem.neededQuantity))
                inventoryColumn.text:SetText(f.g(listItem.inventoryQuantity))
                toBuyColumn.text:SetText(f.l(listItem.toBuyQuantity))
                unitPriceColumn.text:SetText(CraftSim.UTIL:FormatMoney(listItem.unitPrice, true))
                totalPriceColumn.text:SetText(CraftSim.UTIL:FormatMoney(listItem.totalPrice, true))
            end)
    end

    reagentList:UpdateDisplay()

    -- Update total cost
    local totalCost = CraftSim.REAGENT_SHOPPING:GetTotalCost()
    content.totalCostLabel:SetText(
        L(LID.REAGENT_SHOPPING_TOTAL_COST_LABEL) .. ": " .. CraftSim.UTIL:FormatMoney(totalCost, true))
end
