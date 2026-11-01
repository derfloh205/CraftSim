---@class CraftSim
local CraftSim = select(2, ...)
local CraftSimAddonName = select(1, ...)

local GGUI = CraftSim.GGUI
local GUTIL = CraftSim.GUTIL

local f = GUTIL:GetFormatter()
local L = CraftSim.LOCAL:GetLocalizer()

---@class CraftSim.CONTROL_PANEL : CraftSim.Module
CraftSim.CONTROL_PANEL = CraftSim.CONTROL_PANEL

---@class CraftSim.CONTROL_PANEL.UI : CraftSim.Module.UI
CraftSim.CONTROL_PANEL.UI = {}

function CraftSim.CONTROL_PANEL.UI:Init()
    -- Guard against double-init (MODULES:Init + legacy callers). A second frame would
    -- orphan the first and leave Simulate/CraftSim stacked on top of each other.
    if CraftSim.CONTROL_PANEL.frame then
        return
    end

    local currentVersion = C_AddOns.GetAddOnMetadata(CraftSimAddonName, "Version")
    -- Wide enough for the CraftSim dropdown (~160) + gap + Simulate toggle.
    local controlPanelWidth = 260
    local craftSimButtonWidth = 160

    local frame = GGUI.Frame({
        parent = ProfessionsFrame,
        anchorParent = ProfessionsFrame.NineSlice.TopEdge,
        anchorA = "TOPLEFT",
        anchorB = "TOPLEFT",
        offsetX = 23,
        offsetY = -13,
        sizeX = controlPanelWidth,
        sizeY = 30,
        frameID = CraftSim.CONST.FRAMES.CONTROL_PANEL,
        frameTable = CraftSim.INIT.FRAMES,
        -- Not moveable: omit frameConfigTable so old saved CENTER offsets cannot
        -- relocate this chrome strip or collapse its layout after /reload.
        frameStrata = CraftSim.CONST.MODULES_FRAME_STRATA,
        frameLevel = CraftSim.UTIL:NextFrameLevel(),
        hide = true,
    })

    ---@class CraftSim.CONTROL_PANEL.FRAME : GGUI.Frame
    CraftSim.CONTROL_PANEL.frame = frame
    if self.module then
        self.module.frame = frame
    end

    frame.content.controlPanelButton = CreateFrame("DropdownButton", nil, frame.content,
        "WowStyle1FilterDropdownTemplate") --[[@as Button]]
    frame.content.controlPanelButton:SetText(f.l(" CraftSim ") .. f.white(currentVersion))
    -- SetWidth after SetText: WowStyle1FilterDropdownTemplate can reflow wider than SetSize.
    frame.content.controlPanelButton:SetSize(craftSimButtonWidth, 23)
    frame.content.controlPanelButton:SetWidth(craftSimButtonWidth)
    -- Left-align so Simulate has stable room to the right (CENTER + narrow frame
    -- pinned Simulate on top of the dropdown chevron).
    frame.content.controlPanelButton:ClearAllPoints()
    frame.content.controlPanelButton:SetPoint("LEFT", frame.content, "LEFT", 0, 0)

    frame.content.controlPanelButton:HookScript("OnClick", function()
        CraftSim.WIDGETS.ContextMenu.Open(UIParent, function(ownerRegion, rootDescription)
            ---@param moduleID CraftSim.ModuleID
            ---@param data CraftSim.Module.ControlPanelData
            local function addModuleCheckbox(moduleID, data)
                local label = data.label
                local tooltip = data.tooltip

                local cb = rootDescription:CreateCheckbox(label, function()
                    return CraftSim.DB.OPTIONS:IsModuleEnabled(moduleID)
                end, function()
                    local checked = CraftSim.DB.OPTIONS:IsModuleEnabled(moduleID)
                    if not checked then
                        GUTIL:TriggerCustomEvent("CRAFTSIM_MODULE_OPENED", moduleID)
                    else
                        GUTIL:TriggerCustomEvent("CRAFTSIM_MODULE_CLOSED", moduleID)
                    end
                end)
                cb:SetTooltip(function(tt, _)
                    GameTooltip_AddInstructionLine(tt, tooltip);
                end);
            end

            local controlPanelModules = GUTIL:Map(CraftSim.MODULES.modules, function(module, _)
                if module.controlPanelData then
                    return module
                end
                return nil
            end)

            table.sort(controlPanelModules, function(a, b)
                local aSort = a.controlPanelData.sortOrder or math.huge
                local bSort = b.controlPanelData.sortOrder or math.huge
                return aSort < bSort
            end)

            for _, module in ipairs(controlPanelModules) do
                addModuleCheckbox(
                    module.moduleID,
                    module.controlPanelData)
            end

            rootDescription:CreateDivider()

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

            rootDescription:CreateButton(f.bb(L("CONTROL_PANEL_PATCH_NOTES")), function()
                CraftSim.PATCH_NOTES:ShowPatchNotes(true)
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
            CraftSim.SIMULATION_MODE.isActive = value
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

function CraftSim.CONTROL_PANEL.UI:VisibleByContext()
    return CraftSim.MODULES:VisibleByContext()
end
