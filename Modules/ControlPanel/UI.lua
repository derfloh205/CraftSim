---@class CraftSim
local CraftSim = select(2, ...)
local CraftSimAddonName = select(1, ...)

local GGUI = CraftSim.GGUI
local GUTIL = CraftSim.GUTIL

local f = GUTIL:GetFormatter()
local L = CraftSim.UTIL:GetLocalizer()

---@class CraftSim.CONTROL_PANEL
CraftSim.CONTROL_PANEL = CraftSim.CONTROL_PANEL

---@class CraftSim.CONTROL_PANEL.UI
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
        frameID = CraftSim.CONST.FRAMES.CONTROL_PANEL,
        --backdropOptions = CraftSim.CONST.DEFAULT_BACKDROP_OPTIONS,
        frameTable = CraftSim.INIT.FRAMES,
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
        MenuUtil.CreateContextMenu(UIParent, function(ownerRegion, rootDescription)
            local function addModuleCheckbox(label, moduleSV, moduleTooltip, optionalFrameToToggle)
                local cb = rootDescription:CreateCheckbox(label, function()
                    return CraftSim.DB.OPTIONS:Get(moduleSV)
                end, function()
                    local checked = CraftSim.DB.OPTIONS:Get(moduleSV)
                    CraftSim.DB.OPTIONS:Save(moduleSV, not checked)
                    CraftSim.INIT:TriggerModuleUpdate()
                    if optionalFrameToToggle then
                        GGUI:GetFrame(CraftSim.INIT.FRAMES, optionalFrameToToggle):SetVisible(not checked)
                    end
                end)
                cb:SetTooltip(function(tooltip, elementDescription)
                    GameTooltip_AddInstructionLine(tooltip, moduleTooltip);
                end);
            end

            addModuleCheckbox(
                L(CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_REAGENT_OPTIMIZATION_LABEL),
                "MODULE_REAGENT_OPTIMIZATION",
                L(CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_REAGENT_OPTIMIZATION_TOOLTIP))

            addModuleCheckbox(
                L(CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_AVERAGE_PROFIT_LABEL),
                "MODULE_AVERAGE_PROFIT",
                L(CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_AVERAGE_PROFIT_TOOLTIP))

            addModuleCheckbox(
                L(CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_TOP_GEAR_LABEL),
                "MODULE_TOP_GEAR",
                L(CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_TOP_GEAR_TOOLTIP))

            addModuleCheckbox(
                L(CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_CRAFT_QUEUE_LABEL),
                "MODULE_CRAFT_QUEUE",
                L(CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_CRAFT_QUEUE_TOOLTIP))

            addModuleCheckbox(
                L(CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_COST_OVERVIEW_LABEL),
                "MODULE_COST_OVERVIEW",
                L(CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_COST_OVERVIEW_TOOLTIP))

            addModuleCheckbox(
                L(CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_PRICE_OVERRIDES_LABEL),
                "MODULE_PRICE_OVERRIDE",
                L(CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_PRICE_OVERRIDES_TOOLTIP))

            addModuleCheckbox(
                L(CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_CRAFT_BUFFS_LABEL),
                "MODULE_CRAFT_BUFFS",
                L(CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_CRAFT_BUFFS_TOOLTIP))

            addModuleCheckbox(
                L(CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_COOLDOWNS_LABEL),
                "MODULE_COOLDOWNS",
                L(CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_COOLDOWNS_TOOLTIP))

            addModuleCheckbox(
                L(CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_SPECIALIZATION_INFO_LABEL),
                "MODULE_SPEC_INFO",
                L(CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_SPECIALIZATION_INFO_TOOLTIP))

            addModuleCheckbox(
                L(CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_CRAFT_LOG_LABEL),
                "MODULE_CRAFT_LOG",
                L(CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_CRAFT_LOG_TOOLTIP))

            addModuleCheckbox(
                L(CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_COST_OPTIMIZATION_LABEL),
                "MODULE_COST_OPTIMIZATION",
                L(CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_COST_OPTIMIZATION_TOOLTIP))

            addModuleCheckbox(
                L(CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_STATISTICS_LABEL),
                "MODULE_STATISTICS",
                L(CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_STATISTICS_TOOLTIP))

            addModuleCheckbox(
                L(CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_RECIPE_SCAN_LABEL),
                "MODULE_RECIPE_SCAN",
                L(CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_RECIPE_SCAN_TOOLTIP))

            addModuleCheckbox(
                L(CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_CUSTOMER_HISTORY_LABEL),
                "MODULE_CUSTOMER_HISTORY",
                L(CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_CUSTOMER_HISTORY_TOOLTIP),
                CraftSim.CONST.FRAMES.CUSTOMER_HISTORY)

            addModuleCheckbox(
                L(CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_EXPLANATIONS_LABEL),
                "MODULE_EXPLANATIONS",
                L(CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_EXPLANATIONS_TOOLTIP),
                CraftSim.CONST.FRAMES.EXPLANATIONS)

            local exports = rootDescription:CreateButton("Exports")

            exports:CreateButton(L(CraftSim.CONST.TEXT.CONTROL_PANEL_EASYCRAFT_EXPORT), function()
                CraftSim.CONTROL_PANEL:EasycraftExportAll()
            end)

            exports:CreateButton(L(CraftSim.CONST.TEXT.CONTROL_PANEL_FORGEFINDER_EXPORT), function()
                CraftSim.CONTROL_PANEL:ForgeFinderExportAll()
            end)

            rootDescription:CreateButton(L(CraftSim.CONST.TEXT.CONTROL_PANEL_RESET_FRAMES), function()
                CraftSim.FRAME:ResetFrames()
            end)

            rootDescription:CreateButton(f.patreon(L(CraftSim.CONST.TEXT.CONTROL_PANEL_SUPPORTERS_BUTTON)), function()
                GGUI:GetFrame(CraftSim.INIT.FRAMES, CraftSim.CONST.FRAMES.SUPPORTERS):Show()
            end)

            rootDescription:CreateButton(L(CraftSim.CONST.TEXT.CONTROL_PANEL_OPTIONS), function()
                Settings.OpenToCategory(CraftSim.OPTIONS.category.ID)
            end)

            rootDescription:CreateButton(f.bb(L(CraftSim.CONST.TEXT.CONTROL_PANEL_NEWS)), function()
                CraftSim.NEWS:ShowNews(true)
            end)

            rootDescription:CreateButton(f.grey(L(CraftSim.CONST.TEXT.CONTROL_PANEL_DEBUG)), function()
                GGUI:GetFrame(CraftSim.INIT.FRAMES, CraftSim.CONST.FRAMES.DEBUG):Show()
            end)
        end)
    end)

    frame:Hide()
end
