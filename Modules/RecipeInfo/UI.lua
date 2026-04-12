---@class CraftSim
local CraftSim           = select(2, ...)

local GGUI               = CraftSim.GGUI
local GUTIL              = CraftSim.GUTIL

local f                  = GUTIL:GetFormatter()
local L                  = CraftSim.UTIL:GetLocalizer()

---@class CraftSim.RECIPE_INFO
CraftSim.RECIPE_INFO     = CraftSim.RECIPE_INFO

---@class CraftSim.RECIPE_INFO.UI
CraftSim.RECIPE_INFO.UI  = {}

local print              = CraftSim.DEBUG:RegisterDebugID("Modules.RecipeInfo.UI")

local NAME_COLUMN_WIDTH  = 130
local VALUE_COLUMN_WIDTH = 180
local ROW_HEIGHT         = 20
local LIST_TOP_OFFSET    = -30 -- list starts this many px below the content top (covers the title bar)
local FRAME_BOTTOM_PAD   = 10  -- extra space kept at the bottom of the parent frame
local MAX_RESULT_ICONS   = 5
local ICON_SIZE          = 16  -- fits inside ROW_HEIGHT = 20

local function createContent(frame)
    local moneyColumnWidth = VALUE_COLUMN_WIDTH

    frame.content.profitList = GGUI.FrameList {
        parent                   = frame.content,
        anchorParent             = frame.content,
        anchorA                  = "TOP",
        anchorB                  = "TOP",
        offsetY                  = LIST_TOP_OFFSET,
        scale                    = 0.95,
        rowHeight                = ROW_HEIGHT,
        columnOptions            = {
            { width = NAME_COLUMN_WIDTH },
            { width = moneyColumnWidth },
        },
        hideScrollbar            = true,
        autoAdjustHeight         = true,
        autoAdjustHeightCallback = function(newListHeight)
            -- resize the parent GGUI frame so it wraps the list snugly
            local totalHeight = math.abs(LIST_TOP_OFFSET) + newListHeight + FRAME_BOTTOM_PAD
            frame.frame:SetHeight(totalHeight)
            frame.content:SetHeight(totalHeight)
        end,
        selectionOptions         = {
            noSelectionColor = true,
            hoverRGBA        = CraftSim.CONST.FRAME_LIST_SELECTION_COLORS.HOVER_LIGHT_WHITE,
        },
        rowConstructor           = function(columns, row)
            local nameColumn  = columns[1]
            local valueColumn = columns[2]

            nameColumn.text   = GGUI.Text {
                parent         = nameColumn,
                anchorParent   = nameColumn,
                anchorA        = "RIGHT",
                anchorB        = "RIGHT",
                justifyOptions = { type = "H", align = "RIGHT" },
            }

            -- text element for money / plain-text value rows
            valueColumn.text  = GGUI.Text {
                parent         = valueColumn,
                anchorParent   = valueColumn,
                anchorA        = "LEFT",
                anchorB        = "LEFT",
                justifyOptions = { type = "H", align = "LEFT" },
                fixedWidth     = moneyColumnWidth,
            }

            -- icon slots for the result-icons row (hidden by default)
            for i = 1, MAX_RESULT_ICONS do
                valueColumn["icon" .. i] = GGUI.Icon {
                    parent           = valueColumn,
                    anchorParent     = valueColumn,
                    anchorA          = "LEFT",
                    anchorB          = "LEFT",
                    offsetX          = (i - 1) * (ICON_SIZE + 3),
                    sizeX            = ICON_SIZE,
                    sizeY            = ICON_SIZE,
                    qualityIconScale = 1.3,
                }
                valueColumn["icon" .. i]:Hide()
            end
        end,
    }

    frame.content.priceOverrideWarning = GGUI.Texture {
        atlas          = "Ping_Chat_Warning",
        sizeX          = 25,
        sizeY          = 25,
        parent         = frame.content,
        anchorParent   = frame.content,
        anchorA        = "TOPLEFT",
        anchorB        = "TOPLEFT",
        offsetX        = 15,
        offsetY        = -8,
        tooltipOptions = {
            anchor = "ANCHOR_CURSOR_RIGHT",
            text   = f.l("Price Overrides Active"),
        },
    }

    frame.content.optionsButton = CraftSim.WIDGETS.OptionsButton {
        parent           = frame.content,
        anchorPoints     = {
            { anchorParent = frame.title.frame, anchorA = "LEFT", anchorB = "RIGHT", offsetX = 5 },
        },
        tooltipOptions   = {
            anchor = "ANCHOR_CURSOR_RIGHT",
            text   = L("RECIPE_INFO_OPTIONS_TOOLTIP"),
        },
        menuUtilCallback = function(ownerRegion, rootDescription)
            local function addToggleCheckbox(label, optKey, tooltip)
                local cb = rootDescription:CreateCheckbox(
                    label,
                    function()
                        return CraftSim.RECIPE_INFO:GetDisplayOptions()[optKey]
                    end,
                    function()
                        local opts = CraftSim.RECIPE_INFO:GetDisplayOptions()
                        opts[optKey] = not opts[optKey]
                        if CraftSim.MODULES.recipeData then
                            CraftSim.RECIPE_INFO.UI:UpdateDisplay(
                                CraftSim.MODULES.recipeData,
                                CraftSim.RECIPE_INFO:CalculateStatWeights(CraftSim.MODULES.recipeData))
                        end
                    end)
                if tooltip then
                    cb:SetTooltip(function(tt, _)
                        GameTooltip_AddInstructionLine(tt, tooltip)
                    end)
                end
            end

            -- Default-on rows (stat weights)
            addToggleCheckbox(L("RECIPE_INFO_OPTION_AVG_PROFIT"), "AVG_PROFIT",
                L("RECIPE_INFO_OPTION_AVG_PROFIT_TOOLTIP"))
            addToggleCheckbox(L("RECIPE_INFO_OPTION_MULTICRAFT_WEIGHT"), "MULTICRAFT_WEIGHT",
                L("RECIPE_INFO_OPTION_MULTICRAFT_WEIGHT_TOOLTIP"))
            addToggleCheckbox(L("RECIPE_INFO_OPTION_RESOURCEFULNESS_WEIGHT"), "RESOURCEFULNESS_WEIGHT",
                L("RECIPE_INFO_OPTION_RESOURCEFULNESS_WEIGHT_TOOLTIP"))
            addToggleCheckbox(L("RECIPE_INFO_OPTION_CONCENTRATION_WEIGHT"), "CONCENTRATION_WEIGHT",
                L("RECIPE_INFO_OPTION_CONCENTRATION_WEIGHT_TOOLTIP"))
            -- Extra rows (default off)
            addToggleCheckbox(L("RECIPE_INFO_OPTION_CRAFTING_COST"), "CRAFTING_COST",
                L("RECIPE_INFO_OPTION_CRAFTING_COST_TOOLTIP"))
            addToggleCheckbox(L("RECIPE_INFO_OPTION_AVG_CRAFTING_COST"), "AVG_CRAFTING_COST",
                L("RECIPE_INFO_OPTION_AVG_CRAFTING_COST_TOOLTIP"))
            addToggleCheckbox(L("RECIPE_INFO_OPTION_RESULT_ICONS"), "RESULT_ICONS",
                L("RECIPE_INFO_OPTION_RESULT_ICONS_TOOLTIP"))
            addToggleCheckbox(L("RECIPE_INFO_OPTION_KNOWLEDGE_POINTS"), "KNOWLEDGE_POINTS",
                L("RECIPE_INFO_OPTION_KNOWLEDGE_POINTS_TOOLTIP"))
            addToggleCheckbox(L("RECIPE_INFO_OPTION_AVG_YIELD"), "AVG_YIELD", L("RECIPE_INFO_OPTION_AVG_YIELD_TOOLTIP"))
            addToggleCheckbox(L("RECIPE_INFO_OPTION_AVG_MULTICRAFT_ITEMS"), "AVG_MULTICRAFT_ITEMS",
                L("RECIPE_INFO_OPTION_AVG_MULTICRAFT_ITEMS_TOOLTIP"))
            addToggleCheckbox(L("RECIPE_INFO_OPTION_AVG_RESOURCEFULNESS_SAVED"), "AVG_RESOURCEFULNESS_SAVED",
                L("RECIPE_INFO_OPTION_AVG_RESOURCEFULNESS_SAVED_TOOLTIP"))
            addToggleCheckbox(L("RECIPE_INFO_OPTION_CONCENTRATION_PROFIT"), "CONCENTRATION_PROFIT",
                L("RECIPE_INFO_OPTION_CONCENTRATION_PROFIT_TOOLTIP"))
            addToggleCheckbox(L("RECIPE_INFO_OPTION_CONCENTRATION_COST"), "CONCENTRATION_COST",
                L("RECIPE_INFO_OPTION_CONCENTRATION_COST_TOOLTIP"))
        end,
    }

    frame:Hide()
end

function CraftSim.RECIPE_INFO.UI:Init()
    local sizeX                  = 320
    local sizeY                  = 105
    local offsetX                = -10
    local offsetY                = 30

    CraftSim.RECIPE_INFO.frame   = GGUI.Frame({
        parent             = ProfessionsFrame.CraftingPage.SchematicForm,
        anchorParent       = ProfessionsFrame,
        anchorA            = "BOTTOMRIGHT",
        anchorB            = "BOTTOMRIGHT",
        sizeX              = sizeX,
        sizeY              = sizeY,
        offsetX            = offsetX,
        offsetY            = offsetY,
        frameID            = CraftSim.CONST.FRAMES.AVERAGE_PROFIT,
        title              = CraftSim.LOCAL:GetText("RECIPE_INFO_TITLE"),
        collapseable       = true,
        closeable          = true,
        moveable           = true,
        backdropOptions    = CraftSim.CONST.DEFAULT_BACKDROP_OPTIONS,
        onCloseCallback    = CraftSim.CONTROL_PANEL:HandleModuleClose("MODULE_AVERAGE_PROFIT"),
        frameTable         = CraftSim.INIT.FRAMES,
        frameConfigTable   = CraftSim.DB.OPTIONS:Get("GGUI_CONFIG"),
        frameStrata        = CraftSim.CONST.MODULES_FRAME_STRATA,
        raiseOnInteraction = true,
        frameLevel         = CraftSim.UTIL:NextFrameLevel(),
    })

    CraftSim.RECIPE_INFO.frameWO = GGUI.Frame({
        parent             = ProfessionsFrame.OrdersPage.OrderView.OrderDetails,
        anchorParent       = ProfessionsFrame,
        anchorA            = "BOTTOMRIGHT",
        anchorB            = "BOTTOMRIGHT",
        sizeX              = sizeX,
        sizeY              = sizeY,
        offsetX            = offsetX,
        offsetY            = offsetY,
        frameID            = CraftSim.CONST.FRAMES.AVERAGE_PROFIT_WO,
        title              = CraftSim.LOCAL:GetText("RECIPE_INFO_TITLE") ..
            " " .. GUTIL:ColorizeText(CraftSim.LOCAL:GetText("SOURCE_COLUMN_WO"), GUTIL.COLORS.GREY),
        collapseable       = true,
        closeable          = true,
        moveable           = true,
        backdropOptions    = CraftSim.CONST.DEFAULT_BACKDROP_OPTIONS,
        onCloseCallback    = CraftSim.CONTROL_PANEL:HandleModuleClose("MODULE_AVERAGE_PROFIT"),
        frameTable         = CraftSim.INIT.FRAMES,
        frameConfigTable   = CraftSim.DB.OPTIONS:Get("GGUI_CONFIG"),
        frameStrata        = CraftSim.CONST.MODULES_FRAME_STRATA,
        raiseOnInteraction = true,
        frameLevel         = CraftSim.UTIL:NextFrameLevel(),
        raiseOnClick       = true,
    })

    createContent(CraftSim.RECIPE_INFO.frame)
    createContent(CraftSim.RECIPE_INFO.frameWO)
end

---@param recipeData CraftSim.RecipeData
---@param statWeights CraftSim.Statweights
function CraftSim.RECIPE_INFO.UI:UpdateDisplay(recipeData, statWeights)
    local recipeInfoFrame      = self:GetFrameByExportMode()
    local opts                 = CraftSim.RECIPE_INFO:GetDisplayOptions()
    local showProfitPct        = CraftSim.DB.OPTIONS:Get("SHOW_PROFIT_PERCENTAGE")
    local craftingCosts        = recipeData.priceData.craftingCosts

    local priceOverrideWarning = recipeInfoFrame.content.priceOverrideWarning --[[@as GGUI.Texture]]
    priceOverrideWarning:SetVisible(recipeData.priceData:PriceOverridesActive())

    local profitList = recipeInfoFrame.content.profitList --[[@as GGUI.FrameList]]
    profitList:Remove()

    -- Helper: add a plain text row (hides icon slots)
    local function addTextRow(name, value, tooltip)
        profitList:Add(function(row, columns)
            local nameColumn  = columns[1]
            local valueColumn = columns[2]

            nameColumn.text:SetText(name)
            valueColumn.text:SetText(value)

            -- ensure icon slots are hidden
            for i = 1, MAX_RESULT_ICONS do
                if valueColumn["icon" .. i] then
                    valueColumn["icon" .. i]:Hide()
                end
            end

            row.tooltipOptions = tooltip and {
                anchor = "ANCHOR_CURSOR",
                owner  = row.frame,
                text   = tooltip,
            } or nil
        end)
    end

    -- Helper: add the result-icons row (shows icons, hides text)
    local function addIconsRow()
        profitList:Add(function(row, columns)
            local nameColumn  = columns[1]
            local valueColumn = columns[2]

            nameColumn.text:SetText(L("RECIPE_INFO_RESULT_ITEMS_LABEL"))
            valueColumn.text:SetText("")

            for i = 1, MAX_RESULT_ICONS do
                local icon = valueColumn["icon" .. i]
                if icon then
                    local item = recipeData.resultData.itemsByQuality[i]
                    if item then
                        icon:SetItem(item)
                        icon:Show()
                    else
                        icon:Hide()
                    end
                end
            end

            row.tooltipOptions = {
                anchor = "ANCHOR_CURSOR",
                owner  = row.frame,
                text   = f.white(f.bb("Icons") .. " for each possible result item quality"),
            }
        end)
    end

    -- ── Stat-weight rows (default on, individually toggleable) ───────────────
    if opts.AVG_PROFIT then
        local relative = showProfitPct and craftingCosts or nil
        addTextRow(
            L("STAT_WEIGHTS_PROFIT_CRAFT"),
            CraftSim.UTIL:FormatMoney(statWeights and statWeights.averageProfit or 0, true, relative),
            f.white(f.bb("Average") .. " profit per craft considering your crafting stats"))
    end

    if opts.MULTICRAFT_WEIGHT and statWeights and recipeData.supportsMulticraft then
        local formatted = CraftSim.UTIL:FormatMoney(statWeights.multicraftWeight)
        if formatted ~= "" then
            addTextRow(
                L("MULTICRAFT_LABEL"),
                formatted,
                f.white("Profit increase " .. f.l("per point ") .. f.bb("Multicraft")))
        end
    end

    if opts.RESOURCEFULNESS_WEIGHT and statWeights and recipeData.supportsResourcefulness then
        local formatted = CraftSim.UTIL:FormatMoney(statWeights.resourcefulnessWeight)
        if formatted ~= "" then
            addTextRow(
                L("RESOURCEFULNESS_LABEL"),
                formatted,
                f.white("Profit increase " .. f.l("per point ") .. f.bb("Resourcefulness")))
        end
    end

    if opts.CONCENTRATION_WEIGHT and statWeights and recipeData.supportsQualities and recipeData.concentrationCost > 0 then
        local formatted = CraftSim.UTIL:FormatMoney(statWeights.concentrationWeight)
        if formatted ~= "" then
            addTextRow(
                L("CONCENTRATION_LABEL"),
                formatted,
                f.white("Profit " .. f.l("per point ") .. f.bb("Concentration") .. " considering " .. f.bb("Ingenuity")))
        end
    end

    -- ── Extra rows (default off) ─────────────────────────────────────────────
    if opts.CRAFTING_COST then
        addTextRow(
            L("RECIPE_INFO_CRAFTING_COST_LABEL"),
            CraftSim.UTIL:FormatMoney(craftingCosts, true),
            f.white("Total " .. f.bb("crafting cost") .. " for one craft"))
    end

    if opts.AVG_CRAFTING_COST then
        addTextRow(
            L("RECIPE_INFO_AVG_CRAFTING_COST_LABEL"),
            CraftSim.UTIL:FormatMoney(recipeData.priceData.averageCraftingCosts, true),
            f.white(f.bb("Average") .. " crafting cost per craft considering " ..
                f.l("Resourcefulness") .. " and " .. f.l("Multicraft")))
    end

    if opts.RESULT_ICONS then
        addIconsRow()
    end

    if opts.KNOWLEDGE_POINTS and recipeData.specializationData then
        local allocated, maxKP = CraftSim.RECIPE_INFO:GetKnowledgePoints(recipeData)
        addTextRow(
            L("RECIPE_INFO_KNOWLEDGE_POINTS_LABEL"),
            f.white(tostring(allocated) .. " / " .. tostring(maxKP)),
            f.white("Knowledge Points " .. f.l("allocated") .. " / " .. f.bb("max possible") ..
                " for nodes affecting this recipe"))
    end

    if opts.AVG_YIELD and recipeData.supportsMulticraft then
        addTextRow(
            L("RECIPE_INFO_AVG_YIELD_LABEL"),
            f.white(string.format("%.2f", recipeData.resultData.expectedYieldPerCraft)),
            f.white(f.bb("Average yield") .. " per craft considering " ..
                f.l("Multicraft") .. " chance and amount"))
    end

    if opts.AVG_MULTICRAFT_ITEMS and recipeData.supportsMulticraft then
        local _, extraItems = CraftSim.CALC:GetExpectedItemAmountMulticraft(recipeData)
        addTextRow(
            L("RECIPE_INFO_AVG_MULTICRAFT_ITEMS_LABEL"),
            f.white(string.format("%.2f", extraItems)),
            f.white(f.bb("Average extra items") .. " per craft from " .. f.l("Multicraft") .. " procs"))
    end

    if opts.AVG_RESOURCEFULNESS_SAVED and recipeData.supportsResourcefulness then
        addTextRow(
            L("RECIPE_INFO_AVG_RESOURCEFULNESS_SAVED_LABEL"),
            CraftSim.UTIL:FormatMoney(recipeData.priceData.resourcefulnessSavedCostsAverage, true),
            f.white(f.bb("Average saved costs") .. " per craft from " ..
                f.l("Resourcefulness") .. " procs"))
    end

    if opts.CONCENTRATION_PROFIT and recipeData.supportsQualities and recipeData.concentrationCost > 0 then
        local _, concProfit = recipeData:GetConcentrationValue()
        local relative      = showProfitPct and craftingCosts or nil
        addTextRow(
            L("RECIPE_INFO_CONCENTRATION_PROFIT_LABEL"),
            CraftSim.UTIL:FormatMoney(concProfit, true, relative),
            f.white(f.bb("Average profit") .. " per craft when using " .. f.l("Concentration")))
    end

    if opts.CONCENTRATION_COST and recipeData.concentrationCost > 0 then
        addTextRow(
            L("RECIPE_INFO_CONCENTRATION_COST_LABEL"),
            f.white(tostring(recipeData.concentrationCost)),
            f.white(f.bb("Base Concentration cost") .. " for one craft (not accounting for " ..
                f.l("Ingenuity") .. " refund)"))
    end

    -- autoAdjustHeight handles resizing after this call
    profitList:UpdateDisplay()
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
