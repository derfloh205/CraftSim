---@class CraftSim
local CraftSim = select(2, ...)

---@class CraftSim.PRICE_DETAILS.UI
CraftSim.PRICE_DETAILS.UI = {}

CraftSim.PRICE_DETAILS.frame = nil
CraftSim.PRICE_DETAILS.frameWO = nil

local print = CraftSim.DEBUG:RegisterDebugID("Modules.PriceDetails.UI")

function CraftSim.PRICE_DETAILS.UI:Init()
    local sizeX = 410
    local sizeY = 200
    local offsetX = -5
    local offsetY = 140

    local frameLevel = CraftSim.UTIL:NextFrameLevel()

    CraftSim.PRICE_DETAILS.frame = CraftSim.GGUI.Frame({
        parent = ProfessionsFrame.CraftingPage.SchematicForm,
        anchorParent = ProfessionsFrame,
        anchorA = "BOTTOMLEFT",
        anchorB = "BOTTOMRIGHT",
        offsetX = offsetX,
        offsetY = offsetY,
        sizeX = sizeX,
        sizeY = sizeY,
        frameID = CraftSim.CONST.FRAMES.PRICE_DETAILS,
        title = CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.COST_OVERVIEW_TITLE),
        collapseable = true,
        closeable = true,
        moveable = true,
        backdropOptions = CraftSim.CONST.DEFAULT_BACKDROP_OPTIONS,
        onCloseCallback = CraftSim.CONTROL_PANEL:HandleModuleClose("MODULE_COST_OVERVIEW"),
        frameTable = CraftSim.INIT.FRAMES,
        frameConfigTable = CraftSim.DB.OPTIONS:Get("GGUI_CONFIG"),
        frameStrata = CraftSim.CONST.MODULES_FRAME_STRATA,
        raiseOnInteraction = true,
        frameLevel = frameLevel
    })

    CraftSim.PRICE_DETAILS.frameWO = CraftSim.GGUI.Frame({
        parent = ProfessionsFrame.OrdersPage.OrderView.OrderDetails.SchematicForm,
        anchorParent = ProfessionsFrame,
        anchorA = "BOTTOMLEFT",
        anchorB = "BOTTOMRIGHT",
        offsetX = offsetX,
        offsetY = offsetY,
        sizeX = sizeX,
        sizeY = sizeY,
        frameID = CraftSim.CONST.FRAMES.PRICE_DETAILS_WORK_ORDER,
        title = CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.COST_OVERVIEW_TITLE) ..
            " " ..
            CraftSim.GUTIL:ColorizeText(CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.SOURCE_COLUMN_WO),
                CraftSim.GUTIL.COLORS.GREY),
        collapseable = true,
        closeable = true,
        moveable = true,
        backdropOptions = CraftSim.CONST.DEFAULT_BACKDROP_OPTIONS,
        onCloseCallback = CraftSim.CONTROL_PANEL:HandleModuleClose("MODULE_COST_OVERVIEW"),
        frameTable = CraftSim.INIT.FRAMES,
        frameConfigTable = CraftSim.DB.OPTIONS:Get("GGUI_CONFIG"),
        frameStrata = CraftSim.CONST.MODULES_FRAME_STRATA,
        raiseOnInteraction = true,
        frameLevel = frameLevel
    })

    local function createContent(frame)
        ---@type GGUI.FrameList | GGUI.Widget
        frame.content.priceDetailsList = CraftSim.GGUI.FrameList({
            parent = frame.content,
            anchorParent = frame.title.frame,
            anchorA = "TOP",
            anchorB = "BOTTOM",
            offsetY = -30,
            offsetX = -10,
            sizeY = 140,
            columnOptions = {
                {
                    label = CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.PRICE_DETAILS_INV_AH),
                    width = 60,
                    justifyOptions = { type = "H", align = "CENTER" }
                },
                {
                    label = CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.PRICE_DETAILS_ITEM),
                    width = 60,
                    justifyOptions = { type = "H", align = "CENTER" }
                },
                {
                    label = CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.PRICE_DETAILS_PRICE_ITEM),
                    width = 110,
                },
                {
                    label = CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.PRICE_DETAILS_PROFIT_ITEM),
                    width = 130,
                }
            },
            rowConstructor = function(columns)
                local invColumn = columns[1]
                local itemColumn = columns[2]
                local priceColumn = columns[3]
                local profitColumn = columns[4]

                invColumn.text = CraftSim.GGUI.Text({
                    parent = invColumn, anchorParent = invColumn
                })

                itemColumn.icon = CraftSim.GGUI.Icon({
                    parent = itemColumn,
                    anchorParent = itemColumn,
                    sizeX = 25,
                    sizeY = 25,
                    qualityIconScale = 1.4
                })

                priceColumn.text = CraftSim.GGUI.Text({
                    parent = priceColumn,
                    anchorParent = priceColumn,
                    justifyOptions = { type = "H", align = "LEFT" },
                    fixedWidth = priceColumn:GetWidth()
                })
                profitColumn.text = CraftSim.GGUI.Text({
                    parent = profitColumn,
                    anchorParent = profitColumn,
                    justifyOptions = { type = "H", align = "LEFT" },
                    fixedWidth = profitColumn:GetWidth()
                })
            end
        })


        CraftSim.GGUI:EnableHyperLinksForFrameAndChilds(frame.content)
        frame:Hide()
    end

    createContent(CraftSim.PRICE_DETAILS.frame)
    createContent(CraftSim.PRICE_DETAILS.frameWO)
end

---@param recipeData CraftSim.RecipeData
---@param exportMode number
function CraftSim.PRICE_DETAILS.UI:UpdateDisplay(recipeData, exportMode)
    local priceDetailsFrame = nil
    if exportMode == CraftSim.CONST.EXPORT_MODE.WORK_ORDER then
        priceDetailsFrame = CraftSim.PRICE_DETAILS.frameWO
    else
        priceDetailsFrame = CraftSim.PRICE_DETAILS.frame
    end

    local priceData = recipeData.priceData
    local resultData = recipeData.resultData

    local itemQualityList = resultData.itemsByQuality

    priceDetailsFrame.content.priceDetailsList:Remove()

    CraftSim.GUTIL:ContinueOnAllItemsLoaded(itemQualityList, function()
        for qualityID, resultItem in pairs(itemQualityList) do
            priceDetailsFrame.content.priceDetailsList:Add(function(row)
                local invColumn = row.columns[1]
                local itemColumn = row.columns[2]
                local priceColumn = row.columns[3]
                local profitColumn = row.columns[4]

                local itemLink = resultItem:GetItemLink()
                itemColumn.icon:SetItem(resultItem)
                local priceOverride = CraftSim.DB.PRICE_OVERRIDE:GetResultOverridePrice(recipeData.recipeID, qualityID)
                local price = priceOverride or CraftSim.PRICE_SOURCE:GetMinBuyoutByItemLink(itemLink)
                local profit = (price * CraftSim.CONST.AUCTION_HOUSE_CUT) -
                    (priceData.craftingCosts / recipeData.baseItemAmount)
                priceColumn.text:SetText(CraftSim.UTIL:FormatMoney(price) ..
                    ((priceOverride and CraftSim.GUTIL:ColorizeText(" (OR)", CraftSim.GUTIL.COLORS.LEGENDARY)) or ""))
                profitColumn.text:SetText(CraftSim.UTIL:FormatMoney(profit, true))

                local itemCount = C_Item.GetItemCount(itemLink, true, false, true)
                local ahCount = CraftSim.PRICE_SOURCE:GetAuctionAmount(itemLink)

                if ahCount then
                    invColumn.text:SetText((itemCount or 0) .. "/" .. ahCount)
                else
                    invColumn.text:SetText(itemCount or 0)
                end
            end)
        end

        priceDetailsFrame.content.priceDetailsList:UpdateDisplay()
    end)
end
