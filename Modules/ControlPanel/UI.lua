---@class CraftSim
local CraftSim = select(2, ...)
local CraftSimAddonName = select(1, ...)

local GGUI = CraftSim.GGUI
local GUTIL = CraftSim.GUTIL

local f = GUTIL:GetFormatter()
local L = CraftSim.UTIL:GetLocalizer()

---@class CraftSim.CONTROL_PANEL : CraftSim.Module
CraftSim.CONTROL_PANEL = CraftSim.CONTROL_PANEL

---@class CraftSim.CONTROL_PANEL.UI : CraftSim.Module.UI
CraftSim.CONTROL_PANEL.UI = {}

function CraftSim.CONTROL_PANEL.UI:Init()
    local currentVersion = C_AddOns.GetAddOnMetadata(CraftSimAddonName, "Version")

    ---@class CraftSim.CONTROL_PANEL.FRAME : GGUI.Frame
    local frame = GGUI.Frame({
        parent = ProfessionsFrame,
        anchorParent = ProfessionsFrame.NineSlice.TopEdge,
        anchorA = "TOPLEFT",
        anchorB = "TOPLEFT",
        offsetX = 23,
        offsetY = -13,
        sizeX = 180,
        sizeY = 30,
        frameConfigTable = CraftSim.DB.OPTIONS:Get("GGUI_CONFIG"),
        frameStrata = CraftSim.CONST.MODULES_FRAME_STRATA,
        frameLevel = CraftSim.UTIL:NextFrameLevel()
    })

    CraftSim.CONTROL_PANEL.frame = frame

    frame.content.controlPanelButton = CreateFrame("DropdownButton", nil, frame.content,
        "WowStyle1FilterDropdownTemplate") --[[@as Button]]
    frame.content.controlPanelButton:SetText(f.l(" CraftSim ") .. f.white(currentVersion))
    frame.content.controlPanelButton:SetSize(160, 23)
    frame.content.controlPanelButton:SetPoint("CENTER", frame.content, "CENTER")

    frame.content.controlPanelButton:HookScript("OnClick", function()
        CraftSim.WIDGETS.ContextMenu.Open(UIParent, function(ownerRegion, rootDescription)
            local function addModuleCheckbox(label, moduleSV, moduleTooltip, optionalFrameToToggle)
                local cb = rootDescription:CreateCheckbox(label, function()
                    return CraftSim.DB.OPTIONS:Get(moduleSV)
                end, function()
                    local checked = CraftSim.DB.OPTIONS:Get(moduleSV)
                    CraftSim.DB.OPTIONS:Save(moduleSV, not checked)
                    CraftSim.MODULES:Update()
                    if optionalFrameToToggle then
                        GGUI:GetFrame(CraftSim.INIT.FRAMES, optionalFrameToToggle):SetVisible(not checked)
                    end
                end)
                cb:SetTooltip(function(tooltip, elementDescription)
                    GameTooltip_AddInstructionLine(tooltip, moduleTooltip);
                end);
            end

            -- addModuleCheckbox(
            --     L("CONTROL_PANEL_MODULES_REAGENT_OPTIMIZATION_LABEL"),
            --     "MODULE_REAGENT_OPTIMIZATION",
            --     L("CONTROL_PANEL_MODULES_REAGENT_OPTIMIZATION_TOOLTIP"))

            -- addModuleCheckbox(
            --     L("CONTROL_PANEL_MODULES_RECIPE_INFO_LABEL"),
            --     "MODULE_AVERAGE_PROFIT",
            --     L("CONTROL_PANEL_MODULES_RECIPE_INFO_TOOLTIP"))

            -- addModuleCheckbox(
            --     L("CONTROL_PANEL_MODULES_TOP_GEAR_LABEL"),
            --     "MODULE_TOP_GEAR",
            --     L("CONTROL_PANEL_MODULES_TOP_GEAR_TOOLTIP"))

            -- addModuleCheckbox(
            --     L("CONTROL_PANEL_MODULES_CRAFT_QUEUE_LABEL"),
            --     "MODULE_CRAFT_QUEUE",
            --     L("CONTROL_PANEL_MODULES_CRAFT_QUEUE_TOOLTIP"))

            -- addModuleCheckbox(
            --     L("CONTROL_PANEL_MODULES_COST_OPTIMIZATION_LABEL"),
            --     "MODULE_PRICING",
            --     L("CONTROL_PANEL_MODULES_COST_OPTIMIZATION_TOOLTIP"))

            -- addModuleCheckbox(
            --     L("CONTROL_PANEL_MODULES_CRAFT_BUFFS_LABEL"),
            --     "MODULE_CRAFT_BUFFS",
            --     L("CONTROL_PANEL_MODULES_CRAFT_BUFFS_TOOLTIP"))

            -- addModuleCheckbox(
            --     L("CONTROL_PANEL_MODULES_COOLDOWNS_LABEL"),
            --     "MODULE_COOLDOWNS",
            --     L("CONTROL_PANEL_MODULES_COOLDOWNS_TOOLTIP"))

            -- addModuleCheckbox(
            --     L("CONTROL_PANEL_MODULES_SPECIALIZATION_INFO_LABEL"),
            --     "MODULE_SPEC_INFO",
            --     L("CONTROL_PANEL_MODULES_SPECIALIZATION_INFO_TOOLTIP"))

            -- addModuleCheckbox(
            --     L("CONTROL_PANEL_MODULES_CRAFT_LOG_LABEL"),
            --     "MODULE_CRAFT_LOG",
            --     L("CONTROL_PANEL_MODULES_CRAFT_LOG_TOOLTIP"))

            -- addModuleCheckbox(
            --     L("CONTROL_PANEL_MODULES_STATISTICS_LABEL"),
            --     "MODULE_STATISTICS",
            --     L("CONTROL_PANEL_MODULES_STATISTICS_TOOLTIP"))

            -- addModuleCheckbox(
            --     L("CONTROL_PANEL_MODULES_RECIPE_SCAN_LABEL"),
            --     "MODULE_RECIPE_SCAN",
            --     L("CONTROL_PANEL_MODULES_RECIPE_SCAN_TOOLTIP"))

            -- addModuleCheckbox(
            --     L("CONTROL_PANEL_MODULES_CUSTOMER_HISTORY_LABEL"),
            --     "MODULE_CUSTOMER_HISTORY",
            --     L("CONTROL_PANEL_MODULES_CUSTOMER_HISTORY_TOOLTIP"),
            --     CraftSim.MODULES.modules["MODULE_CUSTOMER_HISTORY"].frame)

            -- addModuleCheckbox(
            --     L("CONTROL_PANEL_MODULES_EXPLANATIONS_LABEL"),
            --     "MODULE_EXPLANATIONS",
            --     L("CONTROL_PANEL_MODULES_EXPLANATIONS_TOOLTIP"),
            --     CraftSim.MODULES.modules["MODULE_EXPLANATIONS"].frame)

            local exports = rootDescription:CreateButton(L("CONTROL_PANEL_EXPORTS"))

            exports:CreateButton(L("CONTROL_PANEL_EASYCRAFT_EXPORT"), function()
                CraftSim.CONTROL_PANEL:EasycraftExportAll()
            end)

            exports:CreateButton(L("CONTROL_PANEL_FORGEFINDER_EXPORT"), function()
                CraftSim.CONTROL_PANEL:ForgeFinderExportAll()
            end)

            rootDescription:CreateButton(L("CONTROL_PANEL_RESET_FRAMES"), function()
                CraftSim.FRAME:ResetFrames()
            end)

            rootDescription:CreateButton(f.patreon(L("CONTROL_PANEL_SUPPORTERS_BUTTON")), function()
                GGUI:GetFrame(CraftSim.INIT.FRAMES, CraftSim.CONST.FRAMES.SUPPORTERS):Show()
            end)

            rootDescription:CreateButton(L("CONTROL_PANEL_OPTIONS"), function()
                Settings.OpenToCategory(CraftSim.OPTIONS.category:GetID())
            end)

            rootDescription:CreateButton(f.bb(L("CONTROL_PANEL_NEWS")), function()
                CraftSim.NEWS:ShowNews(true)
            end)

            rootDescription:CreateButton(f.grey(L("CONTROL_PANEL_DEBUG")), function()
                CraftSim.DEBUG.frame:Show()
            end)
        end)
    end)

    frame:Hide()

    -- Simulation Mode Toggle Button
    frame.content.simulateToggle = GGUI.ToggleButton({
        parent = frame.content,
        anchorParent = frame.content.controlPanelButton,
        adjustWidth = true,
        sizeX = 15,
        sizeY = 20,
        anchorA = "LEFT",
        anchorB = "RIGHT",
        offsetX = 5,
        label = L("SIMULATION_MODE_LABEL"),
        tooltipOptions = {
            anchor = "ANCHOR_TOP",
            text = L("SIMULATION_MODE_TOOLTIP"),
        },
        onToggleCallback = function(_, value)
            CraftSim.SIMULATION_MODE.isActive = not value
            if CraftSim.SIMULATION_MODE.isActive then
                GUTIL:TriggerCustomEvent("CRAFTSIM_SIMULATION_MODE_ENABLED")
            else
                GUTIL:TriggerCustomEvent("CRAFTSIM_SIMULATION_MODE_DISABLED")
            end
        end
    })
end

function CraftSim.CONTROL_PANEL.UI:Update()

end
