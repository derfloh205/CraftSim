---@class CraftSim
local CraftSim = select(2, ...)

local GGUI = CraftSim.GGUI
local GUTIL = CraftSim.GUTIL

local f = GUTIL:GetFormatter()
local L = CraftSim.UTIL:GetLocalizer()

---@class CraftSim.SIMULATION_MODE.UI
CraftSim.SIMULATION_MODE.UI = {}

---@class CraftSim.SIMULATION_MODE.UI.WORKORDER : GGUI.Frame
CraftSim.SIMULATION_MODE.UI.WORKORDER = nil

---@class CraftSim.SIMULATION_MODE.UI.NO_WORKORDER : GGUI.Frame
CraftSim.SIMULATION_MODE.UI.NO_WORKORDER = nil

local Logger = CraftSim.DEBUG:RegisterLogger("SimulationMode.UI")

function CraftSim.SIMULATION_MODE.UI:Init()
    local x, y = ProfessionsFrame.CraftingPage.SchematicForm:GetSize()
    local woX, woY = ProfessionsFrame.OrdersPage.OrderView.OrderDetails:GetSize()
    local sizeOffsetX = 135
    local sizeOffsetY = 55
    local offsetY = -30

    CraftSim.SIMULATION_MODE.frame = GGUI.Frame({
        parent = ProfessionsFrame.CraftingPage.SchematicForm,
        anchorParent = ProfessionsFrame.CraftingPage.SchematicForm,
        anchorA = "BOTTOMLEFT",
        anchorB = "BOTTOMLEFT",
        sizeX = x - sizeOffsetX,
        sizeY = y - sizeOffsetY,
        offsetY = offsetY,
        frameID = CraftSim.CONST.FRAMES.SIMULATION_MODE,
        backdropOptions = CraftSim.CONST.DEFAULT_BACKDROP_OPTIONS,
        frameTable = CraftSim.INIT.FRAMES,
        frameStrata = CraftSim.CONST.MODULES_FRAME_STRATA,
        frameLevel = ProfessionsFrame.CraftingPage.SchematicForm:GetFrameLevel() + 10,
        hide = true,
    })
    CraftSim.SIMULATION_MODE.frameWO = GGUI.Frame({
        parent = ProfessionsFrame.OrdersPage.OrderView.OrderDetails,
        anchorParent = ProfessionsFrame.OrdersPage.OrderView.OrderDetails,
        anchorA = "BOTTOMLEFT",
        anchorB = "BOTTOMLEFT",
        sizeX = woX,
        sizeY = woY - sizeOffsetY,
        offsetY = offsetY,
        frameID = CraftSim.CONST.FRAMES.SIMULATION_MODE_WO,
        title = L("SIMULATION_MODE_LABEL"),
        backdropOptions = CraftSim.CONST.DEFAULT_BACKDROP_OPTIONS,
        frameTable = CraftSim.INIT.FRAMES,
        frameStrata = CraftSim.CONST.MODULES_FRAME_STRATA,
        frameLevel = ProfessionsFrame.OrdersPage.OrderView.OrderDetails:GetFrameLevel() + 10,
        hide = true,
    })

    local function createContent(frame)
        local anchorPoints = {
            {
                anchorParent = frame.content,
                offsetX = 10,
                offsetY = -40,
                anchorA = "TOPLEFT",
                anchorB = "TOPLEFT",
            },
        }

        local function onHeaderClick(qualityID)
            CraftSim.SIMULATION_MODE:AllocateAllByQuality(qualityID)
        end

        local function onQuantityChanged(row, columns, qualityIndex)
            local column = columns[qualityIndex + 1]
            if not column or not column.itemID or not column.input then
                return
            end

            local itemID = column.itemID
            local quantity = column.input.currentValue

            CraftSim.SIMULATION_MODE:UpdateRequiredReagent(itemID, quantity, row)
        end

        frame.content.reagentList = CraftSim.WIDGETS.ReagentList {
            parent = frame.content,
            anchorPoints = anchorPoints,
            onHeaderClick = onHeaderClick,
            onQuantityChanged = onQuantityChanged,
        }

        local function CreateOptionalReagentItemSelector(offsetX)
            local optionalReagentDropdown = GGUI.ItemSelector({
                parent = frame.content,
                anchorParent = frame.content,
                anchorA = "BOTTOMLEFT",
                anchorB = "BOTTOMLEFT",
                offsetX = 10 + offsetX,
                offsetY = 30,
                sizeX = 30,
                sizeY = 30,
                emptyIcon = CraftSim.CONST.ATLAS_TEXTURES.TRADESKILL_ICON_ADD,
                selectionFrameOptions = {
                    backdropOptions = CraftSim.CONST.DEFAULT_BACKDROP_OPTIONS,
                    scale = 1.2,
                },
                onSelectCallback = function()
                    CraftSim.MODULES:Update()
                end
            })
            return optionalReagentDropdown
        end

        ---@type GGUI.ItemSelector[]
        frame.optionalReagentItemSelectors = {}
        local dropdownSpacingX = 35
        table.insert(frame.optionalReagentItemSelectors, CreateOptionalReagentItemSelector(0))
        table.insert(frame.optionalReagentItemSelectors,
            CreateOptionalReagentItemSelector(dropdownSpacingX))
        table.insert(frame.optionalReagentItemSelectors,
            CreateOptionalReagentItemSelector(dropdownSpacingX * 2))
        table.insert(frame.optionalReagentItemSelectors,
            CreateOptionalReagentItemSelector(dropdownSpacingX * 3))
        table.insert(frame.optionalReagentItemSelectors,
            CreateOptionalReagentItemSelector(dropdownSpacingX * 4))
        table.insert(frame.optionalReagentItemSelectors,
            CreateOptionalReagentItemSelector(dropdownSpacingX * 5))
        table.insert(frame.optionalReagentItemSelectors,
            CreateOptionalReagentItemSelector(dropdownSpacingX * 6))
    end

    createContent(CraftSim.SIMULATION_MODE.frame)
    createContent(CraftSim.SIMULATION_MODE.frameWO)

    local function createSimulationModeFrames(schematicForm, workOrder)
        local frames = {}
        local clickCallback =
        ---@param self GGUI.Checkbox
            function(self)
                Logger:LogDebug("sim mode click callback")
                CraftSim.SIMULATION_MODE.isActive = self:GetChecked()
                local bestQBox = schematicForm.AllocateBestQualityCheckbox
                if bestQBox:GetChecked() and CraftSim.SIMULATION_MODE.isActive then
                    bestQBox:Click()
                end
                if CraftSim.SIMULATION_MODE.isActive then
                    CraftSim.SIMULATION_MODE:InitializeSimulationMode(CraftSim.MODULES.recipeData)
                end

                CraftSim.MODULES:Update()
            end

        frames.toggleButton = GGUI.Checkbox {
            parent = schematicForm,
            anchorParent = schematicForm.Details,
            anchorA = "BOTTOM",
            anchorB = "TOP",
            offsetX = -65,
            offsetY = 40,
            label = L("SIMULATION_MODE_LABEL"),
            tooltip = L("SIMULATION_MODE_TOOLTIP"),
            clickCallback = clickCallback,
        }

        frames.toggleButton:Hide()


        -- DETAILS FRAME
        local simModeDetailsFrame = GGUI.Frame({
            parent = workOrder and CraftSim.SIMULATION_MODE.frameWO.frame or CraftSim.SIMULATION_MODE.frame.frame,
            anchorParent = ProfessionsFrame,
            anchorA = "TOPRIGHT",
            anchorB = "TOPRIGHT",
            offsetX = -5,
            offsetY = -155,
            sizeX = 350,
            sizeY = 410,
            frameID = (workOrder and CraftSim.CONST.FRAMES.CRAFTING_DETAILS_WO) or CraftSim.CONST.FRAMES
                .CRAFTING_DETAILS,
            frameTable = CraftSim.INIT.FRAMES,
            frameConfigTable = CraftSim.DB.OPTIONS:Get("GGUI_CONFIG"),
            frameStrata = CraftSim.CONST.MODULES_FRAME_STRATA,
            frameLevel = 50,
            raiseOnInteraction = true,
        })

        frames.detailsFrame = simModeDetailsFrame

        -- Stats FrameList (replaces old static layout)
        local labelColumnWidth = 175
        local valueColumnWidth = 105
        local modColumnWidth = 45

        simModeDetailsFrame.content.statsList = GGUI.FrameList {
            parent = simModeDetailsFrame.content,
            anchorParent = simModeDetailsFrame.content,
            anchorA = "TOPLEFT",
            anchorB = "TOPLEFT",
            offsetX = 5,
            offsetY = -10,
            sizeY = 220,
            hideScrollbar = true,
            rowHeight = 22,
            autoAdjustHeight = true,
            selectionOptions = {
                noSelectionColor = true,
                hoverRGBA = CraftSim.CONST.FRAME_LIST_SELECTION_COLORS.HOVER_LIGHT_WHITE,
            },
            columnOptions = {
                { width = labelColumnWidth },
                { width = valueColumnWidth },
                { width = modColumnWidth },
            },
            rowConstructor = function(columns, row)
                local labelColumn = columns[1]
                local valueColumn = columns[2]
                local modColumn = columns[3]

                labelColumn.text = GGUI.Text {
                    parent = labelColumn,
                    anchorParent = labelColumn,
                    anchorA = "LEFT",
                    anchorB = "LEFT",
                    justifyOptions = { type = "H", align = "LEFT" },
                    offsetX = 5,
                }

                valueColumn.text = GGUI.Text {
                    parent = valueColumn,
                    anchorParent = valueColumn,
                    anchorA = "RIGHT",
                    anchorB = "RIGHT",
                    justifyOptions = { type = "H", align = "RIGHT" },
                    scale = 0.85,
                }

                modColumn.modInput = GGUI.NumericInput {
                    parent = modColumn,
                    anchorParent = modColumn,
                    anchorA = "CENTER",
                    anchorB = "CENTER",
                    sizeX = 38,
                    sizeY = 18,
                    allowNegative = true,
                    mouseWheelStep = 1,
                    allowDecimals = false,
                    initialValue = 0,
                    onNumberValidCallback = function()
                        CraftSim.SIMULATION_MODE:OnStatModifierChanged(true)
                    end,
                    borderAdjustHeight = 1.4,
                    borderAdjustWidth = 1.25,
                }
            end,
        }

        -- Concentration toggle button (centered below the stats list)
        local concentrationLabel = GUTIL:IconToText(CraftSim.CONST.CONCENTRATION_ICON, 20, 20) ..
            " " .. CraftSim.LOCAL:GetText("SIMULATION_MODE_CONCENTRATION")
        local concentrationToggleBtn = GGUI.ToggleButton {
            parent = simModeDetailsFrame.content,
            anchorPoints = { {
                anchorParent = simModeDetailsFrame.content.statsList.frame,
                anchorA = "TOP", anchorB = "BOTTOM",
                offsetY = -6,
            } },
            label = concentrationLabel,
            adjustWidth = true,
            sizeX = 20,
            sizeY = 30,
            isOn = false,
            labelOn = concentrationLabel,
            labelOff = concentrationLabel,
            onToggleCallback = function()
                CraftSim.SIMULATION_MODE:OnStatModifierChanged(true)
            end,
        }

        simModeDetailsFrame.content.concentrationToggleBtn = concentrationToggleBtn
        frames.concentrationToggleMod = concentrationToggleBtn

        -- Quality meter widget (centered below concentration toggle button)
        simModeDetailsFrame.content.qualityMeter = CraftSim.WIDGETS.QualityMeter {
            parent = simModeDetailsFrame.content,
            anchorPoints = { {
                anchorParent = concentrationToggleBtn.frame,
                anchorA = "TOP", anchorB = "BOTTOM",
                offsetY = -10,
            } },
            sizeX = simModeDetailsFrame:GetWidth() - 30,
        }

        return frames
    end

    CraftSim.SIMULATION_MODE.UI.NO_WORKORDER =
        createSimulationModeFrames(ProfessionsFrame.CraftingPage.SchematicForm)
    CraftSim.SIMULATION_MODE.UI.WORKORDER =
        createSimulationModeFrames(ProfessionsFrame.OrdersPage.OrderView.OrderDetails.SchematicForm, true)
end

function CraftSim.SIMULATION_MODE.UI:UpdateCraftingDetailsPanel()
    local recipeData = CraftSim.SIMULATION_MODE.recipeData
    if not recipeData then
        return
    end

    local baseProfessionStats = recipeData.baseProfessionStats
    local professionStats = recipeData.professionStats
    local professionStatsMod = recipeData.professionStatModifiers
    -- Use the stored raw user inputs to initialize modInput widgets.
    -- professionStatsMod includes spec diff on top of user inputs, so using it directly
    -- would cause spec diff to be double-counted on every update cycle.
    local userMods = CraftSim.SIMULATION_MODE.userStatModifiers or {}

    local simModeFrames = CraftSim.SIMULATION_MODE.UI:GetSimulationModeFramesByVisibility()
    local detailsFrame = simModeFrames.detailsFrame

    local statsList = detailsFrame.content.statsList --[[@as GGUI.FrameList]]
    statsList:Remove()

    local function addStatRow(labelText, tooltipText, valueText, modValue, statKey)
        statsList:Add(function(row)
            local columns = row.columns
            local labelColumn = columns[1]
            local valueColumn = columns[2]
            local modColumn = columns[3]

            labelColumn.text:SetText(labelText)
            valueColumn.text:SetText(valueText)

            -- Row hover tooltip instead of legacy help button
            if tooltipText and tooltipText ~= "" then
                row.tooltipOptions = {
                    anchor = "ANCHOR_CURSOR",
                    owner = row.frame,
                    text = tooltipText,
                }
            else
                row.tooltipOptions = nil
            end

            if modValue ~= nil and statKey then
                modColumn.modInput:SetValue(modValue)
                modColumn.modInput.stat = statKey
                modColumn.modInput:Show()
                -- Store reference for UpdateProfessionStatModifiersByInputs
                if statKey == CraftSim.CONST.STAT_MAP.CRAFTING_DETAILS_RECIPE_DIFFICULTY then
                    simModeFrames.recipeDifficultyMod = modColumn.modInput
                elseif statKey == CraftSim.CONST.STAT_MAP.CRAFTING_DETAILS_MULTICRAFT then
                    simModeFrames.multicraftMod = modColumn.modInput
                elseif statKey == CraftSim.CONST.STAT_MAP.CRAFTING_DETAILS_RESOURCEFULNESS then
                    simModeFrames.resourcefulnessMod = modColumn.modInput
                elseif statKey == CraftSim.CONST.STAT_MAP.CRAFTING_DETAILS_SKILL then
                    simModeFrames.baseSkillMod = modColumn.modInput
                elseif statKey == CraftSim.CONST.STAT_MAP.CRAFTING_DETAILS_INGENUITY then
                    simModeFrames.ingenuityMod = modColumn.modInput
                end
            else
                modColumn.modInput:Hide()
            end
        end)
    end

    -- Recipe Difficulty (only for quality recipes)
    if recipeData.supportsQualities then
        local professionStatsOptionals = recipeData.reagentData:GetProfessionStatsByOptionals()
        local fullRecipeDifficulty = professionStats.recipeDifficulty.value
        local recipeDifficultyText = GUTIL:Round(fullRecipeDifficulty, 1) ..
            " (" .. baseProfessionStats.recipeDifficulty.value ..
            "+" .. professionStatsOptionals.recipeDifficulty.value ..
            "+" .. professionStatsMod.recipeDifficulty.value .. ")"
        addStatRow(
            L("RECIPE_DIFFICULTY_LABEL"),
            L("RECIPE_DIFFICULTY_EXPLANATION_TOOLTIP"),
            recipeDifficultyText,
            userMods.recipeDifficulty or 0,
            CraftSim.CONST.STAT_MAP.CRAFTING_DETAILS_RECIPE_DIFFICULTY
        )
    end

    -- Multicraft
    if recipeData.supportsMulticraft then
        local baseMulticraft = GUTIL:Round(professionStats.multicraft.value - professionStatsMod.multicraft.value, 1)
        local percentText = GUTIL:Round(professionStats.multicraft:GetPercent(), 1) .. "%"
        local multicraftText = GUTIL:Round(professionStats.multicraft.value, 1) ..
            " (" .. baseMulticraft .. "+" .. professionStatsMod.multicraft.value .. ") " .. percentText
        addStatRow(
            L("MULTICRAFT_LABEL"),
            L("MULTICRAFT_EXPLANATION_TOOLTIP"),
            multicraftText,
            userMods.multicraft or 0,
            CraftSim.CONST.STAT_MAP.CRAFTING_DETAILS_MULTICRAFT
        )

        local bonusItemsText = professionStats.multicraft:GetExtraValue() * 100 .. "%"
        addStatRow(
            L("MULTICRAFT_BONUS_LABEL"),
            nil,
            bonusItemsText,
            nil,
            nil
        )
    end

    -- Resourcefulness
    if recipeData.supportsResourcefulness then
        local baseResourcefulness = professionStats.resourcefulness.value - professionStatsMod.resourcefulness.value
        local percentText = GUTIL:Round(professionStats.resourcefulness:GetPercent(), 1) .. "%"
        local resourcefulnessText = GUTIL:Round(professionStats.resourcefulness.value) ..
            " (" .. GUTIL:Round(baseResourcefulness) ..
            "+" .. GUTIL:Round(professionStatsMod.resourcefulness.value) .. ") " .. percentText
        addStatRow(
            L("RESOURCEFULNESS_LABEL"),
            L("RESOURCEFULNESS_EXPLANATION_TOOLTIP"),
            resourcefulnessText,
            userMods.resourcefulness or 0,
            CraftSim.CONST.STAT_MAP.CRAFTING_DETAILS_RESOURCEFULNESS
        )

        local bonusItemsText = professionStats.resourcefulness:GetExtraValue() * 100 .. "%"
        addStatRow(
            L("RESOURCEFULNESS_BONUS_LABEL"),
            nil,
            bonusItemsText,
            nil,
            nil
        )
    end

    -- Ingenuity
    if recipeData.supportsIngenuity then
        local baseIngenuity = professionStats.ingenuity.value - professionStatsMod.ingenuity.value
        local percentText = GUTIL:Round(professionStats.ingenuity:GetPercent(), 1) .. "%"
        local ingenuityText = GUTIL:Round(professionStats.ingenuity.value) ..
            " (" .. GUTIL:Round(baseIngenuity) ..
            "+" .. GUTIL:Round(professionStatsMod.ingenuity.value) .. ") " .. percentText
        addStatRow(
            L("INGENUITY_LABEL"),
            L("INGENUITY_EXPLANATION_TOOLTIP"),
            ingenuityText,
            userMods.ingenuity or 0,
            CraftSim.CONST.STAT_MAP.CRAFTING_DETAILS_INGENUITY
        )
    end

    -- Skill (only for quality recipes)
    if recipeData.supportsQualities then
        local reagentSkillIncrease = recipeData.reagentData:GetSkillFromRequiredReagents()
        local skillNoReagents = professionStats.skill.value - reagentSkillIncrease
        local skillText = GUTIL:Round(professionStats.skill.value, 1) ..
            " (" .. GUTIL:Round(skillNoReagents, 1) ..
            "+" .. GUTIL:Round(reagentSkillIncrease, 1) ..
            "+" .. professionStatsMod.skill.value .. ")"
        addStatRow(
            L("SKILL_LABEL"),
            nil,
            skillText,
            userMods.skill or 0,
            CraftSim.CONST.STAT_MAP.CRAFTING_DETAILS_SKILL
        )

        -- Reagent quality stats (only if recipe has quality reagents)
        if recipeData.hasQualityReagents then
            local maxSkillFactor = recipeData.reagentData:GetMaxSkillFactor()
            local maxReagentSkillIncrease = baseProfessionStats.recipeDifficulty.value * maxSkillFactor
            local reagentSkillText = GUTIL:Round(reagentSkillIncrease, 0) ..
                " / " .. GUTIL:Round(maxReagentSkillIncrease, 0)
            addStatRow(
                L("REAGENT_QUALITY_BONUS_LABEL"),
                L("REAGENTSKILL_EXPLANATION_TOOLTIP"),
                reagentSkillText,
                nil,
                nil
            )

            local reagentMaxFactorText = GUTIL:Round(maxSkillFactor * 100, 1) .. " %"
            addStatRow(
                L("REAGENT_QUALITY_MAXIMUM_LABEL"),
                L("REAGENTFACTOR_EXPLANATION_TOOLTIP"),
                reagentMaxFactorText,
                nil,
                nil
            )
        end
    end

    -- Concentration cost and time rows (at bottom of stats list)
    local showConcentration = recipeData.supportsQualities
    if showConcentration then
        addStatRow(
            L("SIMULATION_MODE_CONCENTRATION_COST"),
            nil,
            f.gold(recipeData.concentrationCost),
            nil,
            nil
        )

        local concentrationData = recipeData.concentrationData
        local cost = recipeData.concentrationCost
        if concentrationData and cost and cost > 0 then
            if recipeData:IsCrafter() then
                concentrationData:Update()
            end
            local formatMode = CraftSim.DB.OPTIONS:Get("CONCENTRATION_TRACKER_FORMAT_MODE")
            local useUSFormat = formatMode == CraftSim.CONCENTRATION_TRACKER.UI.FORMAT_MODE.AMERICA_MAX_DATE
            local timeValueText
            if concentrationData:GetCurrentAmount() < cost then
                timeValueText = f.bb(concentrationData:GetFormattedDateUntil(cost, useUSFormat))
            else
                timeValueText = f.g("Ready")
            end
            local timeTitleText = string.gsub(
                CraftSim.LOCAL:GetText("CONCENTRATION_ESTIMATED_TIME_UNTIL"), " %%s", "")
            addStatRow(
                timeTitleText,
                nil,
                timeValueText,
                nil,
                nil
            )
        end
    end

    statsList:UpdateDisplay()

    -- Concentration toggle button visibility and state
    simModeFrames.concentrationToggleMod:SetVisible(showConcentration)
    if showConcentration then
        --simModeFrames.concentrationToggleMod:SetToggle(recipeData.concentrating)
    end

    -- Quality meter
    if recipeData.supportsQualities then
        local thresholds = CraftSim.AVERAGEPROFIT:GetQualityThresholds(recipeData.maxQuality,
            professionStats.recipeDifficulty.value, CraftSim.DB.OPTIONS:Get("QUALITY_BREAKPOINT_OFFSET"))
        detailsFrame.content.qualityMeter:Update(recipeData, thresholds)
    else
        detailsFrame.content.qualityMeter.frame:Hide()
    end
end

---@param recipeData CraftSim.RecipeData
function CraftSim.SIMULATION_MODE.UI:InitOptionalReagentItemSelectors(recipeData)
    local optionalReagentSlots = recipeData.reagentData.optionalReagentSlots
    local finishingReagentSlots = recipeData.reagentData.finishingReagentSlots

    local exportMode = CraftSim.UTIL:GetExportModeByVisibility()

    local frame = exportMode == CraftSim.CONST.EXPORT_MODE.WORK_ORDER and CraftSim.SIMULATION_MODE.frameWO or
        CraftSim.SIMULATION_MODE.frame

    local optionalReagentItemSelectors = frame.optionalReagentItemSelectors --[[@as GGUI.ItemSelector[] ]]

    -- init dropdowns
    for _, itemSelector in pairs(optionalReagentItemSelectors) do
        itemSelector:SetItems({})
        itemSelector:SetSelectedItem(nil)
        itemSelector.isCurrencySlot = false
        itemSelector.selectedCurrencyID = nil
        itemSelector.currencyOptionalSlot = nil
        itemSelector:Hide()
    end

    local selectorIndex = 1

    local requiredSelectableReagentSlot = recipeData.reagentData.requiredSelectableReagentSlot

    for _, optionalReagentSlot in pairs(GUTIL:Concat({ { requiredSelectableReagentSlot }, optionalReagentSlots, finishingReagentSlots })) do
        local currentSelector = optionalReagentItemSelectors[selectorIndex]
        selectorIndex = selectorIndex + 1

        currentSelector.currencyOptionalSlot = optionalReagentSlot
        currentSelector.isCurrencySlot = optionalReagentSlot:IsCurrency()

        currentSelector:SetItems(optionalReagentSlot:GetItemSelectorEntries())

        if optionalReagentSlot.activeReagent then
            if optionalReagentSlot.activeReagent:IsCurrency() then
                currentSelector:SetSelectedCurrency(optionalReagentSlot.activeReagent.currencyID,
                    optionalReagentSlot.activeReagent.qualityID)
            else
                currentSelector:SetSelectedItem(optionalReagentSlot.activeReagent.item)
            end
        else
            currentSelector:SetSelectedItem(nil)
        end

        currentSelector:Show()
    end
end

function CraftSim.SIMULATION_MODE.UI:UpdateVisibility()
    local recipeData = CraftSim.MODULES.recipeData
    if not recipeData then
        return -- In what case is this nil?
    end


    Logger:LogDebug("Update Visibility: hasQualityReagents " .. tostring(recipeData.hasQualityReagents))

    -- frame visiblities
    local exportMode = CraftSim.UTIL:GetExportModeByVisibility()

    if not CraftSim.SIMULATION_MODE.isActive then
        CraftSim.SIMULATION_MODE.frame:Hide()
        CraftSim.SIMULATION_MODE.frameWO:Hide()
        return
    end

    local frame = exportMode == CraftSim.CONST.EXPORT_MODE.WORK_ORDER and CraftSim.SIMULATION_MODE.frameWO or
        CraftSim.SIMULATION_MODE.frame
    local otherFrame = exportMode == CraftSim.CONST.EXPORT_MODE.WORK_ORDER and CraftSim.SIMULATION_MODE.frame or
        CraftSim.SIMULATION_MODE.frameWO
    frame:Show()
    otherFrame:Hide()

    local simModeFrames = CraftSim.SIMULATION_MODE.UI:GetSimulationModeFramesByVisibility()
    CraftSim.CRAFT_BUFFS.frame.content.simulateBuffSelector:SetEnabled(CraftSim.SIMULATION_MODE.isActive)

    local craftingDetailsFrame = simModeFrames.detailsFrame
    Logger:LogDebug("craftingDetailsFrame: " .. tostring(craftingDetailsFrame))


    if not CraftSim.SIMULATION_MODE.isActive then
        -- only hide, they will be shown automatically if available
        for _, selector in pairs(frame.optionalReagentItemSelectors) do
            selector:Hide()
        end
    end

    --CraftSim.FRAME:ToggleFrame(craftingDetailsFrame, CraftSim.SIMULATION_MODE.isActive)
end

function CraftSim.SIMULATION_MODE.UI:GetSimulationModeFramesByVisibility()
    local exportMode = CraftSim.UTIL:GetExportModeByVisibility()
    local simModeFrames = nil
    if exportMode == CraftSim.CONST.EXPORT_MODE.WORK_ORDER then
        simModeFrames = CraftSim.SIMULATION_MODE.UI.WORKORDER
    else
        simModeFrames = CraftSim.SIMULATION_MODE.UI.NO_WORKORDER
    end

    return simModeFrames
end
