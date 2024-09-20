---@class CraftSim
local CraftSim = select(2, ...)

local GGUI = CraftSim.GGUI
local GUTIL = CraftSim.GUTIL
local f = GUTIL:GetFormatter()

---@class CraftSim.REAGENT_OPTIMIZATION.UI
CraftSim.REAGENT_OPTIMIZATION.UI = {}

---@type CraftSim.RecipeData
CraftSim.REAGENT_OPTIMIZATION.UI.recipeData = nil

local print = CraftSim.DEBUG:SetDebugPrint(CraftSim.CONST.DEBUG_IDS.REAGENT_OPTIMIZATION)

function CraftSim.REAGENT_OPTIMIZATION.UI:Init()
    local sizeX = 310
    local sizeY = 270
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
            " " .. GUTIL:ColorizeText("WO", GUTIL.COLORS.GREY),
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

        frame.content.maxQualityLabel = GGUI.Text {
            parent = frame.content, anchorPoints = { { anchorParent = frame.content.maxQualityDropdown.frame, anchorA = "RIGHT", anchorB = "LEFT", offsetX = 16, offsetY = 2 } },
            text = "Maximum Quality: ",
            justifyOptions = { type = "H", align = "LEFT" },
        }

        frame.content.qualityText = GGUI.Text {
            parent = frame.content, anchorParent = frame.content.maxQualityLabel.frame, anchorA = "TOPLEFT", anchorB = "BOTTOMLEFT", offsetY = -10,
            justifyOptions = { type = "H", align = "LEFT" },
            text = CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.MATERIALS_REACHABLE_QUALITY)
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
            text = "Average Ø Profit: ",
            tooltipOptions = {
                anchor = "ANCHOR_CURSOR_RIGHT",
                text = f.bb("The Average Profit per Craft") .. " when using " .. f.l("this reagent allocation"),
            },
        }

        frame.content.averageProfitValue = GGUI.Text {
            parent = frame.content,
            anchorPoints = {
                { anchorParent = frame.content.averageProfitLabel.frame, anchorA = "LEFT", anchorB = "RIGHT", offsetX = 5 },
            },
            justifyOptions = { type = "H", align = "LEFT" },
        }

        frame.content.allocateButton = GGUI.Button({
            parent = frame.content,
            anchorParent = frame.content.qualityIcon.frame,
            anchorA = "LEFT",
            anchorB = "RIGHT",
            offsetX = 20,
            label = "Assign",
            sizeX = 15,
            sizeY = 20,
            adjustWidth = true,
            clickCallback = function()
                CraftSim.SIMULATION_MODE:AllocateReagents(CraftSim.REAGENT_OPTIMIZATION.UI.recipeData)
            end
        })

        local reagentListQualityIconHeaderSize = 25
        local reagentListQualityIconOffsetY = -3
        local reagentListQualityColumnWidth = 60

        frame.content.reagentList = GGUI.FrameList {
            parent = frame.content,
            anchorPoints = { { anchorParent = frame.content, offsetY = -120, anchorA = "TOP", anchorB = "TOP", offsetX = -13 } },
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

        frame.content.infoIcon = GGUI.HelpIcon {
            parent = frame.content,
            anchorParent = frame.content.reagentList.frame,
            anchorA = "BOTTOMRIGHT", anchorB = "TOPLEFT", offsetX = 45, offsetY = -5,
            text = "Shift + LMB on numbers to put the item link in chat"
        }

        frame.content.sameAllocationText = GGUI.Text {
            parent = frame.content, anchorPoints = { { anchorParent = frame.content } },
            text = f.g("Best Reagents Assigned"), hide = true,
        }

        frame:Hide()
    end

    createContent(frameNO_WO)
    createContent(frameWO)
end

---@param recipeData CraftSim.RecipeData
---@param exportMode number
function CraftSim.REAGENT_OPTIMIZATION.UI:UpdateReagentDisplay(recipeData, exportMode)
    local materialFrame = nil
    if exportMode == CraftSim.CONST.EXPORT_MODE.WORK_ORDER then
        materialFrame = GGUI:GetFrame(CraftSim.INIT.FRAMES,
            CraftSim.CONST.FRAMES.REAGENT_OPTIMIZATION_WORK_ORDER)
    else
        materialFrame = GGUI:GetFrame(CraftSim.INIT.FRAMES, CraftSim.CONST.FRAMES.REAGENT_OPTIMIZATION)
    end

    if not materialFrame then return end

    CraftSim.REAGENT_OPTIMIZATION.UI.recipeData = recipeData

    local maxQualityDropdown = materialFrame.content.maxQualityDropdown --[[@as GGUI.Dropdown]]

    maxQualityDropdown:SetVisible(recipeData.supportsQualities)
    materialFrame.content.maxQualityLabel:SetVisible(recipeData.supportsQualities)
    materialFrame.content.qualityText:SetVisible(recipeData.supportsQualities)
    materialFrame.content.qualityIcon:SetVisible(recipeData.supportsQualities)

    materialFrame.content.averageProfitValue:SetText(CraftSim.UTIL:FormatMoney(recipeData.averageProfitCached, true,
        recipeData.priceData.craftingCosts))

    if recipeData.supportsQualities then
        local recipeMaxQualities = CraftSim.DB.OPTIONS:Get("REAGENT_OPTIMIZATION_RECIPE_MAX_OPTIMIZATION_QUALITY")
        -- init dropdown
        ---@type GGUI.DropdownData[]
        local dropdownData = {}

        local qualityIconSize = 25

        for i = 1, recipeData.maxQuality do
            ---@type GGUI.DropdownData
            local dropdownDataElement = {
                label = GUTIL:GetQualityIconString(i, qualityIconSize, qualityIconSize, 0, -2),
                value = i,
            }
            tinsert(dropdownData, dropdownDataElement)
        end

        local initialValue = recipeMaxQualities[recipeData.recipeID] or recipeData.maxQuality
        maxQualityDropdown:SetData {
            data = dropdownData,
            initialValue = initialValue,
            initialLabel = GUTIL:GetQualityIconString(initialValue, qualityIconSize, qualityIconSize, 0, -2),
        }

        materialFrame.content.qualityIcon:SetQuality(recipeData.resultData.expectedQuality)
    end

    local isSameAllocation = recipeData.reagentData:EqualsQualityReagents(
        GUTIL:Filter(CraftSim.INIT.currentRecipeData.reagentData
            .requiredReagents, function(reagent)
                return reagent.hasQuality
            end))

    materialFrame.content.allocateButton:SetVisible(CraftSim.SIMULATION_MODE.isActive and not isSameAllocation)

    local reagentList = materialFrame.content.reagentList --[[@as GGUI.FrameList]]

    reagentList:Remove()

    materialFrame.content.sameAllocationText:SetVisible(isSameAllocation)
    materialFrame.content.infoIcon:SetVisible(not isSameAllocation)
    reagentList:SetVisible(not isSameAllocation)

    if not isSameAllocation then
        for _, reagent in ipairs(recipeData.reagentData.requiredReagents) do
            if reagent.hasQuality then
                reagentList:Add(function(_, columns)
                    local iconColumn = columns[1]
                    local qualityColumns = { columns[2], columns[3], columns[4] }

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
