---@class CraftSim
local CraftSim = select(2, ...)

local GGUI = CraftSim.GGUI
local GUTIL = CraftSim.GUTIL
local f = GUTIL:GetFormatter()

---@class CraftSim.REAGENT_OPTIMIZATION.UI
CraftSim.REAGENT_OPTIMIZATION.UI = {}

---@type CraftSim.RecipeData
CraftSim.REAGENT_OPTIMIZATION.UI.recipeData = nil

local print = CraftSim.DEBUG:RegisterDebugID("Modules.ReagentOptimization.UI")

function CraftSim.REAGENT_OPTIMIZATION.UI:Init()
    local sizeX = 310
    local sizeY = 380
    local offsetX = -5
    local offsetY = -125

    local frameLevel = CraftSim.UTIL:NextFrameLevel()

    local frameWO = GGUI.Frame({
        parent = ProfessionsFrame.OrdersPage.OrderView.OrderDetails,
        anchorParent = ProfessionsFrame,
        sizeX = sizeX,
        sizeY = sizeY,
        frameID = CraftSim.CONST.FRAMES.REAGENT_OPTIMIZATION_WORK_ORDER,
        title = CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.REAGENT_OPTIMIZATION_TITLE) ..
            " " .. GUTIL:ColorizeText(CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.SOURCE_COLUMN_WO), GUTIL.COLORS.GREY),
        collapseable = true,
        closeable = true,
        moveable = true,
        anchorA = "BOTTOMLEFT",
        anchorB = "BOTTOMRIGHT",
        offsetX = offsetX,
        offsetY = offsetY,
        backdropOptions = CraftSim.CONST.DEFAULT_BACKDROP_OPTIONS,
        onCloseCallback = CraftSim.CONTROL_PANEL:HandleModuleClose("MODULE_REAGENT_OPTIMIZATION"),
        frameTable = CraftSim.INIT.FRAMES,
        frameConfigTable = CraftSim.DB.OPTIONS:Get("GGUI_CONFIG"),
        frameStrata = CraftSim.CONST.MODULES_FRAME_STRATA,
        raiseOnInteraction = true,
        frameLevel = frameLevel
    })
    local frameNO_WO = GGUI.Frame({
        parent = ProfessionsFrame.CraftingPage.SchematicForm,
        anchorParent = ProfessionsFrame,
        sizeX = sizeX,
        sizeY = sizeY,
        frameID = CraftSim.CONST.FRAMES.REAGENT_OPTIMIZATION,
        title = CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.REAGENT_OPTIMIZATION_TITLE),
        collapseable = true,
        closeable = true,
        moveable = true,
        anchorA = "BOTTOMLEFT",
        anchorB = "BOTTOMRIGHT",
        offsetX = offsetX,
        offsetY = offsetY,
        backdropOptions = CraftSim.CONST.DEFAULT_BACKDROP_OPTIONS,
        onCloseCallback = CraftSim.CONTROL_PANEL:HandleModuleClose("MODULE_REAGENT_OPTIMIZATION"),
        frameTable = CraftSim.INIT.FRAMES,
        frameConfigTable = CraftSim.DB.OPTIONS:Get("GGUI_CONFIG"),
        frameStrata = CraftSim.CONST.MODULES_FRAME_STRATA,
        raiseOnInteraction = true,
        frameLevel = frameLevel
    })

    local function createContent(frame)
        frame.content.maxQualityDropdown = GGUI.Dropdown {
            parent = frame.content, anchorParent = frame.content, anchorA = "TOP", anchorB = "TOP", offsetX = 15, offsetY = -30,
            width = 50,
            clickCallback = function(_, label, value)
                local maxOptimizationQualities = CraftSim.DB.OPTIONS:Get(
                    "REAGENT_OPTIMIZATION_RECIPE_MAX_OPTIMIZATION_QUALITY")
                local currentRecipeID = CraftSim.INIT.currentRecipeID

                if currentRecipeID then
                    maxOptimizationQualities[currentRecipeID] = value
                end

                CraftSim.INIT:TriggerModulesByRecipeType()
            end,
        }

        frame.content.highestProfitCheckbox = GGUI.Checkbox {
            parent = frame.content, anchorParent = frame.content.maxQualityDropdown.frame,
            anchorA = "LEFT", anchorB = "RIGHT", offsetX = -5, offsetY = 2,
            initialValue = CraftSim.DB.OPTIONS:Get("REAGENT_OPTIMIZATION_TOP_PROFIT_ENABLED"),
            labelOptions = {
                text = "Top Profit"
            },
            tooltip = "If enabled, all qualities up to the max quality will be optimized, and the one with the highest profit will be shown",
            clickCallback = function(_, checked)
                CraftSim.DB.OPTIONS:Save("REAGENT_OPTIMIZATION_TOP_PROFIT_ENABLED", checked)
                CraftSim.INIT:TriggerModulesByRecipeType()
            end
        }

        frame.content.maxQualityLabel = GGUI.Text {
            parent = frame.content, anchorPoints = { { anchorParent = frame.content.maxQualityDropdown.frame, anchorA = "RIGHT", anchorB = "LEFT", offsetX = 16, offsetY = 2 } },
            text = CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.REAGENTS_MAXIMUM_QUALITY),
            justifyOptions = { type = "H", align = "LEFT" },
        }

        frame.content.qualityText = GGUI.Text {
            parent = frame.content, anchorParent = frame.content.maxQualityLabel.frame, anchorA = "TOPLEFT", anchorB = "BOTTOMLEFT", offsetY = -10,
            justifyOptions = { type = "H", align = "LEFT" },
            text = CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.REAGENTS_REACHABLE_QUALITY)
        }

        frame.content.qualityIcon = GGUI.QualityIcon({
            parent = frame.content,
            anchorParent = frame.content.qualityText.frame,
            anchorA = "LEFT",
            anchorB = "RIGHT",
            offsetX = 18,
            sizeX = 25,
            sizeY = 25,
        })

        frame.content.averageProfitLabel = GGUI.Text {
            parent = frame.content,
            anchorParent = frame.content.qualityText.frame,
            anchorA = "TOPRIGHT", anchorB = "BOTTOMRIGHT", offsetY = -10,
            justifyOptions = { type = "H", align = "RIGHT" },
            text = CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.REAGENTS_AVERAGE_PROFIT_LABEL),
            tooltipOptions = {
                anchor = "ANCHOR_CURSOR_RIGHT",
                text = CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.REAGENTS_AVERAGE_PROFIT_TOOLTIP),
            },
        }

        frame.content.averageProfitValue = GGUI.Text {
            parent = frame.content,
            anchorPoints = {
                { anchorParent = frame.content.averageProfitLabel.frame, anchorA = "LEFT", anchorB = "RIGHT", offsetX = 5 },
            },
            justifyOptions = { type = "H", align = "LEFT" },
        }

        frame.content.concentrationCostLabel = GGUI.Text {
            parent = frame.content,
            anchorParent = frame.content.averageProfitLabel.frame,
            anchorA = "TOPRIGHT", anchorB = "BOTTOMRIGHT", offsetY = -10,
            justifyOptions = { type = "H", align = "RIGHT" },
            text = CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.REAGENTS_CONCENTRATION_LABEL),
        }

        frame.content.concentrationCostValue = GGUI.Text {
            parent = frame.content,
            anchorPoints = {
                { anchorParent = frame.content.concentrationCostLabel.frame, anchorA = "LEFT", anchorB = "RIGHT", offsetX = 5 },
            },
            justifyOptions = { type = "H", align = "LEFT" },
        }

        frame.content.concentrationValueLabel = GGUI.Text {
            parent = frame.content,
            anchorParent = frame.content.concentrationCostLabel.frame,
            anchorA = "TOPRIGHT", anchorB = "BOTTOMRIGHT", offsetY = -10,
            justifyOptions = { type = "H", align = "RIGHT" },
            text = "Con. Value: ",
        }

        frame.content.concentrationValueValue = GGUI.Text {
            parent = frame.content,
            anchorPoints = {
                { anchorParent = frame.content.concentrationValueLabel.frame, anchorA = "LEFT", anchorB = "RIGHT", offsetX = 5 },
            },
            justifyOptions = { type = "H", align = "LEFT" },
            text = CraftSim.UTIL:FormatMoney(0, true)
        }

        frame.content.allocateButton = GGUI.Button({
            parent = frame.content,
            anchorParent = frame.content.qualityIcon.frame,
            anchorA = "LEFT",
            anchorB = "RIGHT",
            offsetX = 20,
            label = CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.REAGENTS_ASSIGN),
            sizeX = 15,
            sizeY = 20,
            adjustWidth = true,
            clickCallback = function()
                CraftSim.SIMULATION_MODE:AllocateReagents(CraftSim.REAGENT_OPTIMIZATION.UI.recipeData)
            end
        })

        local advancedOptimizationButtonLabel = CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.ADVANCED_OPTIMIZATION_BUTTON)

        frame.content.advancedOptimizationButton = GGUI.Button({
            parent = frame.content,
            anchorParent = frame.content,
            anchorA = "TOP",
            anchorB = "TOP",
            offsetX = 0,
            offsetY = -145,
            label = advancedOptimizationButtonLabel,
            initialStatusID = "ENABLED",
            sizeX = 70,
            sizeY = 20,
            clickCallback = function()
                local reagentOptimizationFrame = CraftSim.REAGENT_OPTIMIZATION.UI:GetFrameByExportMode()
                if reagentOptimizationFrame then
                    local optimizeFinishingReagents = CraftSim.DB.OPTIONS:Get(
                        "REAGENT_OPTIMIZATION_OPTIMIZE_FINISHING_REAGENTS")
                    local optimizeConcentration = CraftSim.DB.OPTIONS:Get(
                        "REAGENT_OPTIMIZATION_OPTIMIZE_CONCENTRATION_VALUE")
                    local advancedOptimizationButton = reagentOptimizationFrame.content
                        .advancedOptimizationButton --[[@as GGUI.Button]]
                    advancedOptimizationButton:SetEnabled(false)
                    if optimizeConcentration then
                        CraftSim.REAGENT_OPTIMIZATION.UI.recipeData:OptimizeConcentration({
                            finally = function()
                                if optimizeFinishingReagents then
                                    CraftSim.REAGENT_OPTIMIZATION.UI.recipeData:OptimizeFinishingReagents {
                                        finally = function()
                                            CraftSim.REAGENT_OPTIMIZATION.UI:UpdateReagentDisplay(
                                                CraftSim.REAGENT_OPTIMIZATION.UI.recipeData)
                                            advancedOptimizationButton:SetEnabled(false) -- keep disabled until update from init
                                            advancedOptimizationButton:SetText("Optimized")
                                        end,
                                        progressUpdateCallback = function(progress)
                                            advancedOptimizationButton:SetText(string.format("Optimizing - %.2f%%",
                                                progress))
                                        end,
                                        includeLocked = CraftSim.DB.OPTIONS:Get(
                                            "REAGENT_OPTIMIZATION_OPTIMIZE_LOCKED_FINISHING_REAGENTS"),
                                        includeSoulbound = CraftSim.DB.OPTIONS:Get(
                                            "REAGENT_OPTIMIZATION_OPTIMIZE_SOULBOUND_FINISHING_REAGENTS")
                                    }
                                else
                                    CraftSim.REAGENT_OPTIMIZATION.UI:UpdateReagentDisplay(
                                        CraftSim.REAGENT_OPTIMIZATION.UI.recipeData)
                                    advancedOptimizationButton:SetEnabled(false) -- keep disabled until update from init
                                    advancedOptimizationButton:SetText("Optimized")
                                end
                            end,
                            progressUpdateCallback = function(progress)
                                advancedOptimizationButton:SetText(string.format("Optimizing - %.2f%%", progress))
                            end
                        })
                    else
                        if optimizeFinishingReagents then
                            CraftSim.REAGENT_OPTIMIZATION.UI.recipeData:OptimizeFinishingReagents {
                                finally = function()
                                    CraftSim.REAGENT_OPTIMIZATION.UI:UpdateReagentDisplay(
                                        CraftSim.REAGENT_OPTIMIZATION.UI.recipeData)
                                    advancedOptimizationButton:SetEnabled(false) -- keep disabled until update from init
                                    advancedOptimizationButton:SetText("Optimized")
                                end,
                                progressUpdateCallback = function(progress)
                                    advancedOptimizationButton:SetText(string.format("Optimizing - %.2f%%", progress))
                                end,
                                includeLocked = CraftSim.DB.OPTIONS:Get(
                                    "REAGENT_OPTIMIZATION_OPTIMIZE_LOCKED_FINISHING_REAGENTS"),
                                includeSoulbound = CraftSim.DB.OPTIONS:Get(
                                    "REAGENT_OPTIMIZATION_OPTIMIZE_SOULBOUND_FINISHING_REAGENTS")
                            }
                        else
                            CraftSim.REAGENT_OPTIMIZATION.UI:UpdateReagentDisplay(
                                CraftSim.REAGENT_OPTIMIZATION.UI.recipeData)
                            advancedOptimizationButton:SetEnabled(false) -- keep disabled until update from init
                            advancedOptimizationButton:SetText("Optimized")
                        end
                    end
                end
            end,
            tooltipOptions = {
                anchor = "ANCHOR_CURSOR_RIGHT",
                text = CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.REAGENTS_OPTIMIZE_TOOLTIP),
            }
        })

        frame.content.advancedOptimizationButton:SetStatusList {
            {
                statusID = "ENABLED",
                enabled = true,
                label = advancedOptimizationButtonLabel,
                sizeX = 15,
                adjustWidth = true
            }
        }

        frame.content.advancedOptimizationOptions = GGUI.Button {
            parent = frame.content,
            anchorPoints = { { anchorParent = frame.content.advancedOptimizationButton.frame, anchorA = "LEFT", anchorB = "RIGHT", offsetX = 5 } },
            sizeX = 20, sizeY = 20,
            buttonTextureOptions = CraftSim.CONST.BUTTON_TEXTURE_OPTIONS.OPTIONS,
            cleanTemplate = true,
            clickCallback = function(_, _)
                MenuUtil.CreateContextMenu(UIParent, function(ownerRegion, rootDescription)
                    local concentrationCB = rootDescription:CreateCheckbox(
                        "Optimize " .. f.gold("Concentration Value"),
                        function()
                            return CraftSim.DB.OPTIONS:Get("REAGENT_OPTIMIZATION_OPTIMIZE_CONCENTRATION_VALUE")
                        end, function()
                            local value = CraftSim.DB.OPTIONS:Get("REAGENT_OPTIMIZATION_OPTIMIZE_CONCENTRATION_VALUE")
                            CraftSim.DB.OPTIONS:Save("REAGENT_OPTIMIZATION_OPTIMIZE_CONCENTRATION_VALUE", not value)
                        end)

                    concentrationCB:SetTooltip(function(tooltip, elementDescription)
                        GameTooltip_AddInstructionLine(tooltip,
                            "Optimize Profit " .. f.l("per Point") .. " of " .. f.gold("Concentration"));
                    end);

                    local finishingReagentsCB = rootDescription:CreateCheckbox(
                        "Optimize " .. f.bb("Finishing Reagents"),
                        function()
                            return CraftSim.DB.OPTIONS:Get("REAGENT_OPTIMIZATION_OPTIMIZE_FINISHING_REAGENTS")
                        end, function()
                            local value = CraftSim.DB.OPTIONS:Get("REAGENT_OPTIMIZATION_OPTIMIZE_FINISHING_REAGENTS")
                            CraftSim.DB.OPTIONS:Save("REAGENT_OPTIMIZATION_OPTIMIZE_FINISHING_REAGENTS", not value)
                        end)

                    finishingReagentsCB:SetTooltip(function(tooltip, elementDescription)
                        GameTooltip_AddInstructionLine(tooltip,
                            "Optimize most profitable finishing reagents");
                    end);

                    local finishingReagentsSoulboundCB = rootDescription:CreateCheckbox(
                        "Include " .. f.e("Soulbound") .. f.bb(" Finishing Reagents"),
                        function()
                            return CraftSim.DB.OPTIONS:Get("REAGENT_OPTIMIZATION_OPTIMIZE_SOULBOUND_FINISHING_REAGENTS")
                        end, function()
                            local value = CraftSim.DB.OPTIONS:Get(
                                "REAGENT_OPTIMIZATION_OPTIMIZE_SOULBOUND_FINISHING_REAGENTS")
                            CraftSim.DB.OPTIONS:Save("REAGENT_OPTIMIZATION_OPTIMIZE_SOULBOUND_FINISHING_REAGENTS",
                                not value)
                        end)

                    finishingReagentsSoulboundCB:SetTooltip(function(tooltip, elementDescription)
                        GameTooltip_AddInstructionLine(tooltip,
                            "Suggest the usage of soulbound finishing reagents if profitable");
                    end);

                    local finishingReagentsSoulboundCB = rootDescription:CreateCheckbox(
                        "Include " .. f.r("Locked ") .. f.bb("Finishing Slots"),
                        function()
                            return CraftSim.DB.OPTIONS:Get("REAGENT_OPTIMIZATION_OPTIMIZE_LOCKED_FINISHING_REAGENTS")
                        end, function()
                            local value = CraftSim.DB.OPTIONS:Get(
                                "REAGENT_OPTIMIZATION_OPTIMIZE_LOCKED_FINISHING_REAGENTS")
                            CraftSim.DB.OPTIONS:Save("REAGENT_OPTIMIZATION_OPTIMIZE_LOCKED_FINISHING_REAGENTS",
                                not value)
                        end)

                    finishingReagentsSoulboundCB:SetTooltip(function(tooltip, elementDescription)
                        GameTooltip_AddInstructionLine(tooltip,
                            "Optimize Finishing Reagent Slots you do not have unlocked yet");
                    end);
                end)
            end
        }

        local reagentListQualityIconHeaderSize = 25
        local reagentListQualityIconOffsetY = -3
        local reagentListQualityColumnWidth = 60

        frame.content.reagentList = GGUI.FrameList {
            parent = frame.content,
            anchorPoints = { { anchorParent = frame.content, offsetY = -190, anchorA = "TOP", anchorB = "TOP", offsetX = -13 } },
            sizeY = 150, hideScrollbar = true,
            columnOptions = {
                {
                    width = 50, -- reagentIcon
                },
                {
                    label = GUTIL:GetQualityIconString(1, reagentListQualityIconHeaderSize, reagentListQualityIconHeaderSize, 0, reagentListQualityIconOffsetY),
                    width = reagentListQualityColumnWidth, -- q1
                    justifyOptions = { type = "H", align = "CENTER" },
                },
                {
                    label = GUTIL:GetQualityIconString(2, reagentListQualityIconHeaderSize, reagentListQualityIconHeaderSize, 0, reagentListQualityIconOffsetY),
                    width = reagentListQualityColumnWidth, -- q2
                    justifyOptions = { type = "H", align = "CENTER" },
                },
                {
                    label = GUTIL:GetQualityIconString(3, reagentListQualityIconHeaderSize, reagentListQualityIconHeaderSize, 0, reagentListQualityIconOffsetY),
                    width = reagentListQualityColumnWidth, -- q3
                    justifyOptions = { type = "H", align = "CENTER" },
                },
            },
            rowConstructor = function(columns)
                local iconColumn = columns[1]
                local q1Column = columns[2]
                local q2Column = columns[3]
                local q3Column = columns[4]

                iconColumn.text = GGUI.Text {
                    parent = iconColumn, anchorParent = iconColumn,
                }
                q1Column.text = GGUI.Text {
                    parent = q1Column, anchorParent = q1Column,
                }
                q2Column.text = GGUI.Text {
                    parent = q2Column, anchorParent = q2Column,
                }
                q3Column.text = GGUI.Text {
                    parent = q3Column, anchorParent = q3Column,
                }

                for _, qColumn in ipairs({ q1Column, q2Column, q3Column }) do
                    qColumn:EnableMouse(true)
                    ---@type ItemMixin?
                    qColumn.item = nil
                    GGUI:SetTooltipsByTooltipOptions(qColumn, qColumn)

                    qColumn:SetScript("OnMouseDown", function()
                        if IsShiftKeyDown() and qColumn.item then
                            qColumn.item:ContinueOnItemLoad(function()
                                ChatEdit_InsertLink(qColumn.item:GetItemLink())
                            end)
                        end
                    end)
                end
            end
        }

        frame.content.reagentListSimplified = GGUI.FrameList {
            parent = frame.content,
            anchorPoints = { { anchorParent = frame.content, offsetY = -190, anchorA = "TOP", anchorB = "TOP", offsetX = -20 } },
            sizeY = 150, hideScrollbar = true,
            columnOptions = {
                {
                    width = 50, -- reagentIcon
                },
                {
                    label = GUTIL:GetQualityIconStringSimplified(1, reagentListQualityIconHeaderSize, reagentListQualityIconHeaderSize, 0, reagentListQualityIconOffsetY),
                    width = reagentListQualityColumnWidth, -- q1
                    justifyOptions = { type = "H", align = "CENTER" },
                },
                {
                    label = GUTIL:GetQualityIconStringSimplified(2, reagentListQualityIconHeaderSize, reagentListQualityIconHeaderSize, 0, reagentListQualityIconOffsetY),
                    width = reagentListQualityColumnWidth, -- q2
                    justifyOptions = { type = "H", align = "CENTER" },
                }
            },
            rowConstructor = function(columns)
                local iconColumn = columns[1]
                local q1Column = columns[2]
                local q2Column = columns[3]

                iconColumn.text = GGUI.Text {
                    parent = iconColumn, anchorParent = iconColumn,
                }
                q1Column.text = GGUI.Text {
                    parent = q1Column, anchorParent = q1Column,
                }
                q2Column.text = GGUI.Text {
                    parent = q2Column, anchorParent = q2Column,
                }

                for _, qColumn in ipairs({ q1Column, q2Column }) do
                    qColumn:EnableMouse(true)
                    ---@type ItemMixin?
                    qColumn.item = nil
                    GGUI:SetTooltipsByTooltipOptions(qColumn, qColumn)

                    qColumn:SetScript("OnMouseDown", function()
                        if IsShiftKeyDown() and qColumn.item then
                            qColumn.item:ContinueOnItemLoad(function()
                                ChatEdit_InsertLink(qColumn.item:GetItemLink())
                            end)
                        end
                    end)
                end
            end
        }

        frame.content.infoIcon = GGUI.HelpIcon {
            parent = frame.content,
            anchorParent = frame.content,
            anchorA = "BOTTOMRIGHT", anchorB = "TOPLEFT", offsetX = 45, offsetY = -5,
            text = CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.REAGENTS_OPTIMIZE_INFO)
        }

        frame.content.sameAllocationText = GGUI.Text {
            parent = frame.content, anchorPoints = { { anchorParent = frame.content } },
            text = f.g(CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.REAGENTS_OPTIMIZE_BEST_ASSIGNED)), hide = true,
        }

        local finishingReagentIconsOffsetX = 20
        local finishingReagentIconsOffsetY = 10
        local finishingReagentIconsSize = 30

        frame.content.finishingReagentSlots = {
            GGUI.Icon {
                parent = frame.content, anchorParent = frame.content,
                anchorA = "BOTTOMLEFT", anchorB = "BOTTOMLEFT", offsetX = finishingReagentIconsOffsetX, offsetY = finishingReagentIconsOffsetY,
                sizeX = finishingReagentIconsSize, sizeY = finishingReagentIconsSize, qualityIconScale = 1.2,
                texturePath = CraftSim.CONST.ATLAS_TEXTURES.TRADESKILL_ICON_ADD,
            },
            GGUI.Icon {
                parent = frame.content, anchorParent = frame.content, offsetY = finishingReagentIconsOffsetY,
                anchorA = "BOTTOMLEFT", anchorB = "BOTTOMLEFT", offsetX = finishingReagentIconsOffsetX + finishingReagentIconsSize + 5,
                sizeX = finishingReagentIconsSize, sizeY = finishingReagentIconsSize, qualityIconScale = 1.2,
                texturePath = CraftSim.CONST.ATLAS_TEXTURES.TRADESKILL_ICON_ADD,
            }
        }

        frame:Hide()
    end

    createContent(frameNO_WO)
    createContent(frameWO)
end

function CraftSim.REAGENT_OPTIMIZATION.UI:GetFrameByExportMode()
    local exportMode = CraftSim.UTIL:GetExportModeByVisibility()
    if exportMode == CraftSim.CONST.EXPORT_MODE.WORK_ORDER then
        return GGUI:GetFrame(CraftSim.INIT.FRAMES,
            CraftSim.CONST.FRAMES.REAGENT_OPTIMIZATION_WORK_ORDER)
    else
        return GGUI:GetFrame(CraftSim.INIT.FRAMES, CraftSim.CONST.FRAMES.REAGENT_OPTIMIZATION)
    end
end

---@param recipeData CraftSim.RecipeData
function CraftSim.REAGENT_OPTIMIZATION.UI:UpdateReagentDisplay(recipeData)
    local reagentOptimizationFrame = self:GetFrameByExportMode()

    if not reagentOptimizationFrame then return end

    CraftSim.REAGENT_OPTIMIZATION.UI.recipeData = recipeData
    local advancedOptimizationButton = reagentOptimizationFrame.content
        .advancedOptimizationButton --[[@as GGUI.Button]]
    advancedOptimizationButton:SetStatus("ENABLED")

    local maxQualityDropdown = reagentOptimizationFrame.content.maxQualityDropdown --[[@as GGUI.Dropdown]]
    local finishingSlots = reagentOptimizationFrame.content.finishingReagentSlots

    for _, slot in ipairs(finishingSlots) do
        slot:Hide()
    end

    maxQualityDropdown:SetVisible(recipeData.supportsQualities)
    reagentOptimizationFrame.content.maxQualityLabel:SetVisible(recipeData.supportsQualities)
    reagentOptimizationFrame.content.qualityText:SetVisible(recipeData.supportsQualities)
    reagentOptimizationFrame.content.qualityIcon:SetVisible(recipeData.supportsQualities)

    reagentOptimizationFrame.content.averageProfitValue:SetText(CraftSim.UTIL:FormatMoney(recipeData.averageProfitCached,
        true,
        recipeData.priceData.craftingCosts))

    reagentOptimizationFrame.content.concentrationCostValue:SetText(f.gold(recipeData.concentrationCost))
    reagentOptimizationFrame.content.concentrationValueValue:SetText(CraftSim.UTIL:FormatMoney(
        recipeData:GetConcentrationValue(), true))

    if recipeData.supportsQualities then
        local recipeMaxQualities = CraftSim.DB.OPTIONS:Get("REAGENT_OPTIMIZATION_RECIPE_MAX_OPTIMIZATION_QUALITY")
        -- init dropdown
        ---@type GGUI.DropdownData[]
        local dropdownData = {}

        local qualityIconSize = 25

        for i = 1, recipeData.maxQuality do
            local qualityIconLabel
            if recipeData:HasSimplifiedQualityResult() then
                qualityIconLabel = GUTIL:GetQualityIconStringSimplified(i, qualityIconSize, qualityIconSize, 0, -2)
            else
                qualityIconLabel = GUTIL:GetQualityIconString(i, qualityIconSize, qualityIconSize, 0, -2)
            end
            ---@type GGUI.DropdownData
            local dropdownDataElement = {
                label = qualityIconLabel,
                value = i,
            }
            tinsert(dropdownData, dropdownDataElement)
        end

        local initialValue = recipeMaxQualities[recipeData.recipeID] or recipeData.maxQuality
        local initialQualityIconLabel
        if recipeData:HasSimplifiedQualityResult() then
            initialQualityIconLabel = GUTIL:GetQualityIconStringSimplified(initialValue, qualityIconSize, qualityIconSize, 0, -2)
        else
            initialQualityIconLabel = GUTIL:GetQualityIconString(initialValue, qualityIconSize, qualityIconSize, 0, -2)
        end
        maxQualityDropdown:SetData {
            data = dropdownData,
            initialValue = initialValue,
            initialLabel = initialQualityIconLabel,
        }

        if recipeData:HasSimplifiedQualityResult() then
            reagentOptimizationFrame.content.qualityIcon:SetQualitySimplified(recipeData.resultData.expectedQuality)
        else
            reagentOptimizationFrame.content.qualityIcon:SetQuality(recipeData.resultData.expectedQuality)
        end
    end

    local isSameAllocation = recipeData.reagentData:EqualsQualityReagents(
        GUTIL:Filter(CraftSim.INIT.currentRecipeData.reagentData
            .requiredReagents, function(reagent)
                return reagent.hasQuality
            end))

    local equalsFinishingAllocation = true
    for i, _ in ipairs(recipeData.reagentData.finishingReagentSlots) do
        local itemIDA = recipeData.reagentData.finishingReagentSlots[i] and
            recipeData.reagentData.finishingReagentSlots[i].activeReagent and
            recipeData.reagentData.finishingReagentSlots[i].activeReagent.item:GetItemID()
        local itemIDB = CraftSim.INIT.currentRecipeData.reagentData.finishingReagentSlots[i] and
            CraftSim.INIT.currentRecipeData.reagentData.finishingReagentSlots[i].activeReagent and
            CraftSim.INIT.currentRecipeData.reagentData.finishingReagentSlots[i].activeReagent.item:GetItemID()
        equalsFinishingAllocation = equalsFinishingAllocation and
            (itemIDA == itemIDB)
    end

    isSameAllocation = isSameAllocation and equalsFinishingAllocation

    reagentOptimizationFrame.content.allocateButton:SetVisible(CraftSim.SIMULATION_MODE.isActive and not isSameAllocation)

    local reagentListQ3 = reagentOptimizationFrame.content.reagentList --[[@as GGUI.FrameList]]
    local reagentListSimplified = reagentOptimizationFrame.content.reagentListSimplified --[[@as GGUI.FrameList]]
    reagentListQ3:Remove()
    reagentListSimplified:Remove()
    reagentListQ3:SetVisible(false)
    reagentListSimplified:SetVisible(false)
    local reagentList
    local isSimplified = recipeData:IsSimplifiedQualityRecipe()
    if isSimplified then
        reagentList = reagentListSimplified
    else
        reagentList = reagentListQ3
    end


    reagentOptimizationFrame.content.sameAllocationText:SetVisible(isSameAllocation)
    reagentOptimizationFrame.content.infoIcon:SetVisible(not isSameAllocation)
    reagentList:SetVisible(not isSameAllocation)

    if not isSameAllocation then
        for i, uiSlot in ipairs(finishingSlots) do
            local slot = recipeData.reagentData.finishingReagentSlots[i]
            if slot then
                uiSlot:SetItem(slot.activeReagent and slot.activeReagent.item:GetItemID())
                uiSlot:Show()
            end
        end
    end

    if not isSameAllocation then
        for _, reagent in ipairs(recipeData.reagentData.requiredReagents) do
            if reagent.hasQuality then
                reagentList:Add(function(_, columns)
                    local iconColumn = columns[1]
                    local qualityColumns = isSimplified and { columns[2], columns[3] } or { columns[2], columns[3], columns[4] }

                    iconColumn.text:SetText(GUTIL:IconToText(reagent.items[1].item:GetItemIcon(), 25, 25))

                    for i, reagentItem in ipairs(reagent.items) do
                        local qColumn = qualityColumns[i]
                        local allocationText = f.grey("-")
                        if reagentItem.quantity > 0 then
                            allocationText = f.white(reagentItem.quantity)
                        end
                        local text = qColumn.text --[[@as GGUI.Text]]
                        text:SetText(allocationText)
                        qColumn.item = reagentItem.item
                        ---@type GGUI.TooltipOptions
                        qColumn.tooltipOptions = {
                            anchor = "ANCHOR_RIGHT",
                            owner = qColumn,
                            itemID = reagentItem.item:GetItemID()
                        }
                    end
                end)
            end
        end
    end
    reagentList:UpdateDisplay()
end
