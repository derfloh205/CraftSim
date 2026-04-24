---@class CraftSim
local CraftSim = select(2, ...)

local GGUI = CraftSim.GGUI
local GUTIL = CraftSim.GUTIL

local f = GUTIL:GetFormatter()
local L = CraftSim.LOCAL:GetLocalizer()

---@class CraftSim.SIMULATION_MODE.UI : CraftSim.Module.UI
CraftSim.SIMULATION_MODE.UI = {}

---@class CraftSim.SIMULATION_MODE.FRAME : GGUI.Frame
CraftSim.SIMULATION_MODE.frame = nil

---@class CraftSim.SIMULATION_MODE.FRAME : GGUI.Frame
CraftSim.SIMULATION_MODE.frameWO = nil

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
        backdropOptions = CraftSim.CONST.DEFAULT_BACKDROP_OPTIONS,
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
        title = L("SIMULATION_MODE_LABEL"),
        backdropOptions = CraftSim.CONST.DEFAULT_BACKDROP_OPTIONS,
        frameStrata = CraftSim.CONST.MODULES_FRAME_STRATA,
        frameLevel = ProfessionsFrame.OrdersPage.OrderView.OrderDetails:GetFrameLevel() + 10,
        hide = true,
    })

    local function createContent(frame, isWorkOrder)
        ---@class CraftSim.SIMULATION_MODE.FRAME : GGUI.Frame
        local frame = frame
        local schematicForm = isWorkOrder and ProfessionsFrame.OrdersPage.OrderView.OrderDetails.SchematicForm or
            ProfessionsFrame.CraftingPage.SchematicForm

        -- Reagent Frames (Required + Optionals)
        do
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
                    offsetX = 15 + offsetX,
                    offsetY = 30,
                    sizeX = 30,
                    sizeY = 30,
                    emptyIcon = CraftSim.CONST.ATLAS_TEXTURES.TRADESKILL_ICON_ADD,
                    selectionFrameOptions = {
                        backdropOptions = CraftSim.CONST.DEFAULT_BACKDROP_OPTIONS,
                        scale = 1.2,
                    },
                    onSelectCallback = function()
                        CraftSim.SIMULATION_MODE:OnStatModifierChanged(true)
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
        -- Crafting Details List
        do
            -- DETAILS FRAME
            local detailsFrame = GGUI.Frame({
                parent = frame.frame,
                anchorParent = ProfessionsFrame,
                anchorA = "TOPRIGHT",
                anchorB = "TOPRIGHT",
                offsetX = -5,
                offsetY = -155,
                sizeX = 350,
                sizeY = 410,
                frameConfigTable = CraftSim.DB.OPTIONS:Get("GGUI_CONFIG"),
                frameStrata = CraftSim.CONST.MODULES_FRAME_STRATA,
                frameLevel = 50,
                raiseOnInteraction = true,
            })

            frame.content.detailsFrame = detailsFrame

            local labelColumnWidth = 175
            local valueColumnWidth = 105
            local modColumnWidth = 45

            detailsFrame.content.statsList = GGUI.FrameList {
                parent = detailsFrame.content,
                anchorParent = detailsFrame.content,
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
            local concentrationToggleButton = GGUI.ToggleButton {
                parent = detailsFrame.content,
                anchorPoints = { {
                    anchorParent = detailsFrame.content.statsList.frame,
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

            detailsFrame.content.concentrationToggleButton = concentrationToggleButton

            -- Quality meter widget (centered below concentration toggle button)
            detailsFrame.content.qualityMeter = CraftSim.WIDGETS.QualityMeter {
                parent = detailsFrame.content,
                anchorPoints = { {
                    anchorParent = concentrationToggleButton.frame,
                    anchorA = "TOP", anchorB = "BOTTOM",
                    offsetY = -10,
                } },
                sizeX = detailsFrame:GetWidth() - 30,
            }
        end
    end

    createContent(CraftSim.SIMULATION_MODE.frame)
    createContent(CraftSim.SIMULATION_MODE.frameWO, true)
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

    ---@class CraftSim.SIMULATION_MODE.FRAME : GGUI.Frame
    local frame = CraftSim.UTIL:IsWorkOrder() and CraftSim.SIMULATION_MODE.frameWO or CraftSim.SIMULATION_MODE.frame
    local detailsFrame = frame.content.detailsFrame

    local statsList = detailsFrame.content.statsList --[[@as GGUI.FrameList]]
    statsList:Remove()

    local function addStatRow(label, tooltipText, value, modValue, statKey)
        statsList:Add(function(row)
            local columns = row.columns
            local labelText = columns[1].text --[[@as GGUI.Text]]
            local valueText = columns[2].text --[[@as GGUI.Text]]
            local modColumn = columns[3]
            local modInput = modColumn.modInput --[[@as GGUI.NumericInput]]

            labelText:SetText(label)
            valueText:SetText(value)

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
                modInput:SetValue(modValue)
                modInput.stat = statKey
                modInput:Show()
                -- Store reference for UpdateProfessionStatModifiersByInputs
                if statKey == CraftSim.CONST.STAT_MAP.CRAFTING_DETAILS_RECIPE_DIFFICULTY then
                    frame.recipeDifficultyMod = modInput
                elseif statKey == CraftSim.CONST.STAT_MAP.CRAFTING_DETAILS_MULTICRAFT then
                    frame.multicraftMod = modInput
                elseif statKey == CraftSim.CONST.STAT_MAP.CRAFTING_DETAILS_RESOURCEFULNESS then
                    frame.resourcefulnessMod = modInput
                elseif statKey == CraftSim.CONST.STAT_MAP.CRAFTING_DETAILS_SKILL then
                    frame.baseSkillMod = modInput
                elseif statKey == CraftSim.CONST.STAT_MAP.CRAFTING_DETAILS_INGENUITY then
                    frame.ingenuityMod = modInput
                end
            else
                modInput:Hide()
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
    frame.content.detailsFrame.content.concentrationToggleButton:SetVisible(showConcentration)
    if showConcentration then
        frame.content.detailsFrame.content.concentrationToggleButton:SetToggle(recipeData.concentrating)
    end

    -- Quality meter
    if recipeData.supportsQualities then
        local thresholds = CraftSim.RECIPE_INFO:GetQualityThresholds(recipeData.maxQuality,
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
        itemSelector.slot = nil
        itemSelector:Hide()
    end

    local selectorIndex = 1

    local requiredSelectableReagentSlot = recipeData.reagentData.requiredSelectableReagentSlot
    for _, optionalReagentSlot in pairs(GUTIL:Concat({ { requiredSelectableReagentSlot }, optionalReagentSlots, finishingReagentSlots })) do
        local currentSelector = optionalReagentItemSelectors[selectorIndex]
        if not currentSelector or not optionalReagentSlot then
            break
        end
        selectorIndex = selectorIndex + 1

        currentSelector.slot = optionalReagentSlot
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

function CraftSim.SIMULATION_MODE.UI:VisibleByContext()
    return CraftSim.SIMULATION_MODE.isActive
end

function CraftSim.SIMULATION_MODE.UI:Update()
    CraftSim.SIMULATION_MODE.frame:Hide()
    CraftSim.SIMULATION_MODE.frameWO:Hide()

    if not CraftSim.SIMULATION_MODE.isActive then
        return
    end

    local recipeData = CraftSim.SIMULATION_MODE.recipeData
    if not recipeData then
        return
    end

    Logger:LogVerbose("Update Visibility: hasQualityReagents " .. tostring(recipeData.hasQualityReagents))

    local frame = CraftSim.UTIL:IsWorkOrder() and CraftSim.SIMULATION_MODE.frameWO or
        CraftSim.SIMULATION_MODE.frame --[[@as CraftSim.SIMULATION_MODE.FRAME]]
    frame:Show()

    -- TODO: move to buff module and react to event
    --CraftSim.CRAFT_BUFFS.frame.content.simulateBuffSelector:SetEnabled(CraftSim.SIMULATION_MODE.isActive)

    -- Rebuild selector visibility/options from current simulated recipe state.
    -- This ensures optional + finishing reagent selectors are visible after UI refreshes.
    self:InitOptionalReagentItemSelectors(recipeData)
end
