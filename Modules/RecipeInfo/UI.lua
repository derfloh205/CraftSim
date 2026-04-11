---@class CraftSim
local CraftSim = select(2, ...)

local GGUI = CraftSim.GGUI
local GUTIL = CraftSim.GUTIL

local f = GUTIL:GetFormatter()
local L = CraftSim.UTIL:GetLocalizer()

---@class CraftSim.RECIPE_INFO
CraftSim.RECIPE_INFO = CraftSim.RECIPE_INFO

---@class CraftSim.RECIPE_INFO.UI
CraftSim.RECIPE_INFO.UI = {}

local print = CraftSim.DEBUG:RegisterDebugID("Modules.RecipeInfo.UI")

local ROW_HEIGHT = 18
local LIST_TOP_OFFSET = -30
local HEADER_HEIGHT = 30
local ICONS_ROW_HEIGHT = 26
local FRAME_PADDING = 10
local MIN_FRAME_HEIGHT = 60
local NAME_COLUMN_WIDTH = 130
local VALUE_COLUMN_WIDTH = 180
local ICON_SIZE = 20
local MAX_RESULT_ICONS = 5

local function GetFrameMinHeight(numRows, showIcons)
    local height = HEADER_HEIGHT + math.abs(LIST_TOP_OFFSET) + (numRows * ROW_HEIGHT) + FRAME_PADDING
    if showIcons then
        height = height + ICONS_ROW_HEIGHT
    end
    return math.max(height, MIN_FRAME_HEIGHT)
end

local function UpdateFrameHeight(frame, numRows, showIcons)
    local height = GetFrameMinHeight(numRows, showIcons)
    frame.frame:SetHeight(height)
end

local function UpdateIconsSection(frame, recipeData)
    local iconsSection = frame.content.resultIconsSection
    if not iconsSection then return end

    local showIcons = CraftSim.DB.OPTIONS:Get("RECIPE_INFO_SHOW_RESULT_ICONS")
    if not showIcons or not recipeData then
        iconsSection:Hide()
        return
    end

    local numIcons = 0
    for i = 1, MAX_RESULT_ICONS do
        local icon = iconsSection["icon" .. i]
        if icon then
            local item = recipeData.resultData.itemsByQuality[i]
            if item then
                icon:SetItem(item)
                icon:Show()
                numIcons = i
            else
                icon:Hide()
            end
        end
    end

    if numIcons > 0 then
        iconsSection:Show()
    else
        iconsSection:Hide()
    end
end

local function createContent(frame)
    local moneyColumnWidth = VALUE_COLUMN_WIDTH

    frame.content.profitList = GGUI.FrameList {
        parent = frame.content, anchorParent = frame.content,
        anchorA = "TOP", anchorB = "TOP", offsetY = LIST_TOP_OFFSET, scale = 0.95,
        sizeY = 200,
        rowHeight = ROW_HEIGHT,
        columnOptions = {
            {
                width = NAME_COLUMN_WIDTH,
            },
            {
                width = moneyColumnWidth,
            }
        },
        hideScrollbar = true,
        selectionOptions = { noSelectionColor = true, hoverRGBA = CraftSim.CONST.FRAME_LIST_SELECTION_COLORS.HOVER_LIGHT_WHITE },
        rowConstructor = function(columns, row)
            local nameColumn = columns[1]
            local valueColumn = columns[2]

            nameColumn.text = GGUI.Text {
                parent = nameColumn, anchorParent = nameColumn, anchorA = "RIGHT", anchorB = "RIGHT",
                justifyOptions = { type = "H", align = "RIGHT" }
            }
            valueColumn.text = GGUI.Text {
                parent = valueColumn, anchorParent = valueColumn, anchorA = "LEFT", anchorB = "LEFT",
                justifyOptions = { type = "H", align = "LEFT" }, fixedWidth = moneyColumnWidth,
            }
        end
    }

    -- Result item icons section (placed below the FrameList, anchored dynamically)
    local iconsSection = CreateFrame("Frame", nil, frame.content)
    iconsSection:SetSize(NAME_COLUMN_WIDTH + VALUE_COLUMN_WIDTH, ICONS_ROW_HEIGHT)
    iconsSection:SetPoint("TOP", frame.content.profitList.frame, "BOTTOM", 0, -2)
    frame.content.resultIconsSection = iconsSection

    -- Label for icons row
    iconsSection.label = GGUI.Text {
        parent = iconsSection,
        anchorParent = iconsSection,
        anchorA = "RIGHT",
        anchorB = "RIGHT",
        offsetX = -VALUE_COLUMN_WIDTH,
        justifyOptions = { type = "H", align = "RIGHT" },
        text = L("RECIPE_INFO_RESULT_ITEMS_LABEL"),
    }

    -- Create icon slots for up to MAX_RESULT_ICONS item qualities
    for i = 1, MAX_RESULT_ICONS do
        local icon = GGUI.Icon {
            parent = iconsSection,
            anchorParent = iconsSection,
            anchorA = "LEFT",
            anchorB = "LEFT",
            offsetX = NAME_COLUMN_WIDTH * 0.95 + (i - 1) * (ICON_SIZE + 3),
            offsetY = 0,
            sizeX = ICON_SIZE,
            sizeY = ICON_SIZE,
            qualityIconScale = 1.3,
        }
        iconsSection["icon" .. i] = icon
    end

    iconsSection:Hide()

    frame.content.priceOverrideWarning = GGUI.Texture {
        atlas = "Ping_Chat_Warning",
        sizeX = 25, sizeY = 25,
        parent = frame.content,
        anchorParent = frame.content,
        anchorA = "TOPLEFT", anchorB = "TOPLEFT",
        offsetX = 15, offsetY = -8,
        tooltipOptions = {
            anchor = "ANCHOR_CURSOR_RIGHT",
            text = f.l("Price Overrides Active"),
        },
    }

    frame.content.optionsButton = CraftSim.WIDGETS.OptionsButton {
        parent = frame.content,
        anchorPoints = {
            { anchorParent = frame.title.frame, anchorA = "LEFT", anchorB = "RIGHT", offsetX = 5 }
        },
        tooltipOptions = {
            anchor = "ANCHOR_CURSOR_RIGHT",
            text = L("RECIPE_INFO_OPTIONS_TOOLTIP"),
        },
        menuUtilCallback = function(ownerRegion, rootDescription)
            local function addToggleCheckbox(label, optionKey, tooltip)
                local cb = rootDescription:CreateCheckbox(label,
                    function()
                        return CraftSim.DB.OPTIONS:Get(optionKey)
                    end,
                    function()
                        CraftSim.DB.OPTIONS:Save(optionKey, not CraftSim.DB.OPTIONS:Get(optionKey))
                        if CraftSim.MODULES.recipeData then
                            CraftSim.RECIPE_INFO.UI:UpdateDisplay(CraftSim.MODULES.recipeData,
                                CraftSim.RECIPE_INFO:CalculateStatWeights(CraftSim.MODULES.recipeData))
                        end
                    end)
                if tooltip then
                    cb:SetTooltip(function(tt, _)
                        GameTooltip_AddInstructionLine(tt, tooltip)
                    end)
                end
            end

            addToggleCheckbox(L("RECIPE_INFO_OPTION_CRAFTING_COST"), "RECIPE_INFO_SHOW_CRAFTING_COST",
                L("RECIPE_INFO_OPTION_CRAFTING_COST_TOOLTIP"))
            addToggleCheckbox(L("RECIPE_INFO_OPTION_AVG_CRAFTING_COST"), "RECIPE_INFO_SHOW_AVG_CRAFTING_COST",
                L("RECIPE_INFO_OPTION_AVG_CRAFTING_COST_TOOLTIP"))
            addToggleCheckbox(L("RECIPE_INFO_OPTION_RESULT_ICONS"), "RECIPE_INFO_SHOW_RESULT_ICONS",
                L("RECIPE_INFO_OPTION_RESULT_ICONS_TOOLTIP"))
            addToggleCheckbox(L("RECIPE_INFO_OPTION_KNOWLEDGE_POINTS"), "RECIPE_INFO_SHOW_KNOWLEDGE_POINTS",
                L("RECIPE_INFO_OPTION_KNOWLEDGE_POINTS_TOOLTIP"))
            addToggleCheckbox(L("RECIPE_INFO_OPTION_AVG_YIELD"), "RECIPE_INFO_SHOW_AVG_YIELD",
                L("RECIPE_INFO_OPTION_AVG_YIELD_TOOLTIP"))
            addToggleCheckbox(L("RECIPE_INFO_OPTION_AVG_MULTICRAFT_ITEMS"), "RECIPE_INFO_SHOW_AVG_MULTICRAFT_ITEMS",
                L("RECIPE_INFO_OPTION_AVG_MULTICRAFT_ITEMS_TOOLTIP"))
            addToggleCheckbox(L("RECIPE_INFO_OPTION_AVG_RESOURCEFULNESS_SAVED"),
                "RECIPE_INFO_SHOW_AVG_RESOURCEFULNESS_SAVED",
                L("RECIPE_INFO_OPTION_AVG_RESOURCEFULNESS_SAVED_TOOLTIP"))
            addToggleCheckbox(L("RECIPE_INFO_OPTION_CONCENTRATION_PROFIT"), "RECIPE_INFO_SHOW_CONCENTRATION_PROFIT",
                L("RECIPE_INFO_OPTION_CONCENTRATION_PROFIT_TOOLTIP"))
            addToggleCheckbox(L("RECIPE_INFO_OPTION_CONCENTRATION_COST"), "RECIPE_INFO_SHOW_CONCENTRATION_COST",
                L("RECIPE_INFO_OPTION_CONCENTRATION_COST_TOOLTIP"))
        end
    }

    frame:Hide()
end

function CraftSim.RECIPE_INFO.UI:Init()
    local sizeX = 320
    local sizeY = 110
    local offsetX = -10
    local offsetY = 30

    CraftSim.RECIPE_INFO.frame = GGUI.Frame({
        parent = ProfessionsFrame.CraftingPage.SchematicForm,
        anchorParent = ProfessionsFrame,
        anchorA = "BOTTOMRIGHT",
        anchorB = "BOTTOMRIGHT",
        sizeX = sizeX,
        sizeY = sizeY,
        offsetX = offsetX,
        offsetY = offsetY,
        frameID = CraftSim.CONST.FRAMES.AVERAGE_PROFIT,
        title = CraftSim.LOCAL:GetText("RECIPE_INFO_TITLE"),
        collapseable = true,
        closeable = true,
        moveable = true,
        backdropOptions = CraftSim.CONST.DEFAULT_BACKDROP_OPTIONS,
        onCloseCallback = CraftSim.CONTROL_PANEL:HandleModuleClose("MODULE_AVERAGE_PROFIT"),
        frameTable = CraftSim.INIT.FRAMES,
        frameConfigTable = CraftSim.DB.OPTIONS:Get("GGUI_CONFIG"),
        frameStrata = CraftSim.CONST.MODULES_FRAME_STRATA,
        raiseOnInteraction = true,
        frameLevel = CraftSim.UTIL:NextFrameLevel(),
    })

    CraftSim.RECIPE_INFO.frameWO = GGUI.Frame({
        parent = ProfessionsFrame.OrdersPage.OrderView.OrderDetails,
        anchorParent = ProfessionsFrame,
        anchorA = "BOTTOMRIGHT",
        anchorB = "BOTTOMRIGHT",
        sizeX = sizeX,
        sizeY = sizeY,
        offsetX = offsetX,
        offsetY = offsetY,
        frameID = CraftSim.CONST.FRAMES.AVERAGE_PROFIT_WO,
        title = CraftSim.LOCAL:GetText("RECIPE_INFO_TITLE") ..
            " " .. GUTIL:ColorizeText(CraftSim.LOCAL:GetText("SOURCE_COLUMN_WO"), GUTIL.COLORS.GREY),
        collapseable = true,
        closeable = true,
        moveable = true,
        backdropOptions = CraftSim.CONST.DEFAULT_BACKDROP_OPTIONS,
        onCloseCallback = CraftSim.CONTROL_PANEL:HandleModuleClose("MODULE_AVERAGE_PROFIT"),
        frameTable = CraftSim.INIT.FRAMES,
        frameConfigTable = CraftSim.DB.OPTIONS:Get("GGUI_CONFIG"),
        frameStrata = CraftSim.CONST.MODULES_FRAME_STRATA,
        raiseOnInteraction = true,
        frameLevel = CraftSim.UTIL:NextFrameLevel(),
        raiseOnClick = true
    })

    createContent(CraftSim.RECIPE_INFO.frame)
    createContent(CraftSim.RECIPE_INFO.frameWO)
end

---@param recipeData CraftSim.RecipeData
---@param statWeights CraftSim.Statweights
function CraftSim.RECIPE_INFO.UI:UpdateDisplay(recipeData, statWeights)
    local recipeInfoFrame = self:GetFrameByExportMode()
    local showProfitPercentage = CraftSim.DB.OPTIONS:Get("SHOW_PROFIT_PERCENTAGE")

    local craftingCosts = recipeData.priceData.craftingCosts

    local priceOverrideWarningIcon = recipeInfoFrame.content.priceOverrideWarning --[[@as GGUI.Texture]]
    priceOverrideWarningIcon:SetVisible(recipeData.priceData:PriceOverridesActive())

    local profitList = recipeInfoFrame.content.profitList --[[@as GGUI.FrameList]]
    profitList:Remove()

    local function addToList(name, value, tooltip)
        profitList:Add(function(row, columns)
            local nameColumn = columns[1]
            local valueColumn = columns[2]

            nameColumn.text:SetText(name)
            valueColumn.text:SetText(value)

            if tooltip then
                row.tooltipOptions = {
                    anchor = "ANCHOR_CURSOR",
                    owner = row.frame,
                    text = tooltip,
                }
            else
                row.tooltipOptions = nil
            end
        end)
    end

    -- Default data: stat weights (always shown when available)
    if statWeights ~= nil then
        if statWeights.averageProfit then
            local relativeValue = showProfitPercentage and craftingCosts or nil
            addToList(L("STAT_WEIGHTS_PROFIT_CRAFT"),
                CraftSim.UTIL:FormatMoney(statWeights.averageProfit, true, relativeValue),
                f.white(f.bb("Average") .. " profit per craft considering your crafting stats"))
        end
        if statWeights.multicraftWeight then
            addToList(L("MULTICRAFT_LABEL"), CraftSim.UTIL:FormatMoney(statWeights.multicraftWeight),
                f.white("Profit increase " .. f.l("per point ") .. f.bb("Multicraft")))
        end
        if statWeights.resourcefulnessWeight then
            addToList(L("RESOURCEFULNESS_LABEL"),
                CraftSim.UTIL:FormatMoney(statWeights.resourcefulnessWeight),
                f.white("Profit increase " .. f.l("per point ") .. f.bb("Resourcefulness")))
        end
        if statWeights.concentrationWeight then
            addToList(L("CONCENTRATION_LABEL"),
                CraftSim.UTIL:FormatMoney(statWeights.concentrationWeight),
                f.white("Profit " .. f.l("per point ") .. f.bb("Concentration")) .. " considering " .. f.bb("Ingenuity"))
        end
    end

    -- Optional data (user-configurable)
    if CraftSim.DB.OPTIONS:Get("RECIPE_INFO_SHOW_CRAFTING_COST") then
        addToList(L("RECIPE_INFO_CRAFTING_COST_LABEL"),
            CraftSim.UTIL:FormatMoney(craftingCosts, true),
            f.white("Total " .. f.bb("crafting cost") .. " for one craft"))
    end

    if CraftSim.DB.OPTIONS:Get("RECIPE_INFO_SHOW_AVG_CRAFTING_COST") then
        local avgCraftingCost = recipeData.priceData.averageCraftingCosts
        addToList(L("RECIPE_INFO_AVG_CRAFTING_COST_LABEL"),
            CraftSim.UTIL:FormatMoney(avgCraftingCost, true),
            f.white(f.bb("Average") .. " crafting cost per craft considering " .. f.l("Resourcefulness") .. " and " ..
                f.l("Multicraft")))
    end

    if CraftSim.DB.OPTIONS:Get("RECIPE_INFO_SHOW_KNOWLEDGE_POINTS") and recipeData.specializationData then
        local allocatedKP, maxKP = CraftSim.RECIPE_INFO:GetKnowledgePoints(recipeData)
        addToList(L("RECIPE_INFO_KNOWLEDGE_POINTS_LABEL"),
            f.white(tostring(allocatedKP) .. " / " .. tostring(maxKP)),
            f.white("Knowledge Points " .. f.l("allocated") .. " / " .. f.bb("max possible") ..
                " for nodes affecting this recipe"))
    end

    if CraftSim.DB.OPTIONS:Get("RECIPE_INFO_SHOW_AVG_YIELD") and recipeData.supportsMulticraft then
        local expectedYield = recipeData.resultData.expectedYieldPerCraft
        addToList(L("RECIPE_INFO_AVG_YIELD_LABEL"),
            f.white(string.format("%.2f", expectedYield)),
            f.white(f.bb("Average yield") .. " per craft considering " .. f.l("Multicraft") .. " chance and amount"))
    end

    if CraftSim.DB.OPTIONS:Get("RECIPE_INFO_SHOW_AVG_MULTICRAFT_ITEMS") and recipeData.supportsMulticraft then
        local _, expectedExtraItems = CraftSim.CALC:GetExpectedItemAmountMulticraft(recipeData)
        addToList(L("RECIPE_INFO_AVG_MULTICRAFT_ITEMS_LABEL"),
            f.white(string.format("%.2f", expectedExtraItems)),
            f.white(f.bb("Average extra items") .. " per craft from " .. f.l("Multicraft") .. " procs"))
    end

    if CraftSim.DB.OPTIONS:Get("RECIPE_INFO_SHOW_AVG_RESOURCEFULNESS_SAVED") and recipeData.supportsResourcefulness then
        local avgSaved = recipeData.priceData.resourcefulnessSavedCostsAverage
        addToList(L("RECIPE_INFO_AVG_RESOURCEFULNESS_SAVED_LABEL"),
            CraftSim.UTIL:FormatMoney(avgSaved, true),
            f.white(f.bb("Average saved costs") .. " per craft from " .. f.l("Resourcefulness") .. " procs"))
    end

    if CraftSim.DB.OPTIONS:Get("RECIPE_INFO_SHOW_CONCENTRATION_PROFIT") and
        recipeData.supportsQualities and recipeData.concentrationCost > 0 then
        local _, concentrationProfit = recipeData:GetConcentrationValue()
        local relativeValue = showProfitPercentage and craftingCosts or nil
        addToList(L("RECIPE_INFO_CONCENTRATION_PROFIT_LABEL"),
            CraftSim.UTIL:FormatMoney(concentrationProfit, true, relativeValue),
            f.white(f.bb("Average profit") .. " per craft when using " .. f.l("Concentration")))
    end

    if CraftSim.DB.OPTIONS:Get("RECIPE_INFO_SHOW_CONCENTRATION_COST") and recipeData.concentrationCost > 0 then
        addToList(L("RECIPE_INFO_CONCENTRATION_COST_LABEL"),
            f.white(tostring(recipeData.concentrationCost)),
            f.white(f.bb("Concentration cost") .. " for one craft (before " .. f.l("Ingenuity") .. " reduction)"))
    end

    profitList:UpdateDisplay()

    -- Update icons section
    UpdateIconsSection(recipeInfoFrame, recipeData)

    -- Dynamically adjust frame height based on row count
    local numRows = #profitList.activeRows
    local showIcons = CraftSim.DB.OPTIONS:Get("RECIPE_INFO_SHOW_RESULT_ICONS") and
        recipeData.resultData and next(recipeData.resultData.itemsByQuality) ~= nil
    UpdateFrameHeight(recipeInfoFrame, numRows, showIcons)
end

---@return GGUI.Frame
function CraftSim.RECIPE_INFO.UI:GetFrameByExportMode()
    local exportMode = CraftSim.UTIL:GetExportModeByVisibility()

    if exportMode == CraftSim.CONST.EXPORT_MODE.WORK_ORDER then
        return CraftSim.RECIPE_INFO.frameWO
    else
        return CraftSim.RECIPE_INFO.frame
    end
end
