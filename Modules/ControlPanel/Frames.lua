---@class CraftSim
local CraftSim = select(2, ...)
local CraftSimAddonName = select(1, ...)

local GGUI = CraftSim.GGUI

---@class CraftSim.CONTROL_PANEL
CraftSim.CONTROL_PANEL = CraftSim.CONTROL_PANEL

---@class CraftSim.CONTROL_PANEL.FRAMES
CraftSim.CONTROL_PANEL.FRAMES = {}

function CraftSim.CONTROL_PANEL.FRAMES:Init()
    local currentVersion = C_AddOns.GetAddOnMetadata(CraftSimAddonName, "Version")

    ---@class CraftSim.CONTROL_PANEL.FRAME : GGUI.Frame
    local frame = GGUI.Frame({
        parent = ProfessionsFrame,
        anchorParent = ProfessionsFrame,
        anchorA = "BOTTOM",
        anchorB = "TOP",
        offsetY = -5,
        sizeX = 950,
        sizeY = 125,
        frameID = CraftSim.CONST.FRAMES.CONTROL_PANEL,
        title = "CraftSim " .. currentVersion .. " - " .. CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CONTROL_PANEL_TITLE),
        collapseable = true,
        moveable = true,
        backdropOptions = CraftSim.CONST.DEFAULT_BACKDROP_OPTIONS,
        frameTable = CraftSim.INIT.FRAMES,
        frameConfigTable = CraftSim.DB.OPTIONS:Get("GGUI_CONFIG"),
        frameStrata = CraftSim.CONST.MODULES_FRAME_STRATA,
        raiseOnInteraction = true,
        frameLevel = CraftSim.UTIL:NextFrameLevel()
    })

    CraftSim.CONTROL_PANEL.frame = frame

    ---@param option CraftSim.GENERAL_OPTIONS
    ---@return GGUI.Checkbox
    local createModuleCheckbox = function(label, description, anchorA, anchorParent, anchorB, offsetX, offsetY,
                                          option, optionalFrameToToggle)
        local cb = GGUI.Checkbox {
            parent = frame.content, anchorParent = anchorParent,
            label = label, tooltip = description, anchorA = anchorA, anchorB = anchorB,
            offsetX = offsetX, offsetY = offsetY,
            initialValue = CraftSim.DB.OPTIONS:Get(option),
            clickCallback = function(_, checked)
                CraftSim.DB.OPTIONS:Save(option, checked)
                CraftSim.INIT:TriggerModuleUpdate()
                if optionalFrameToToggle then
                    GGUI:GetFrame(CraftSim.INIT.FRAMES, optionalFrameToToggle):SetVisible(checked)
                end
            end
        }
        return cb
    end

    frame:Hide()

    local cbBaseOffsetX = 20
    local cbBaseOffsetY = -30
    local cbSpacingY = -20

    ---@class CraftSim.CONTROL_PANEL.FRAME.CONTENT
    frame.content = frame.content

    frame.content.newsButton = GGUI.Button({
        label = CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CONTROL_PANEL_NEWS),
        parent = frame.content,
        anchorParent = frame.content,
        anchorA = "TOPRIGHT",
        anchorB = "TOPRIGHT",
        offsetX = -30,
        offsetY = cbBaseOffsetY + 5,
        sizeX = 15,
        sizeY = 25,
        adjustWidth = true,
        clickCallback = function()
            CraftSim.NEWS:ShowNews(true)
        end
    })

    frame.content.debugButton = GGUI.Button({
        label = CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CONTROL_PANEL_DEBUG),
        parent = frame.content,
        anchorParent = frame.content.newsButton.frame,
        anchorA = "TOPLEFT",
        anchorB = "BOTTOMLEFT",
        sizeX = 15,
        sizeY = 25,
        adjustWidth = true,
        clickCallback = function()
            GGUI:GetFrame(CraftSim.INIT.FRAMES, CraftSim.CONST.FRAMES.DEBUG):Show()
        end
    })

    frame.content.exportForgeFinderButton = GGUI.Button({
        label = CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CONTROL_PANEL_FORGEFINDER_EXPORT),
        parent = frame.content,
        anchorParent = frame.content.debugButton.frame,
        anchorA = "RIGHT",
        anchorB = "LEFT",
        sizeX = 15,
        sizeY = 25,
        adjustWidth = true,
        clickCallback = function()
            CraftSim.CONTROL_PANEL:ForgeFinderExportAll()
        end,
        initialStatusID = "READY",
    })

    frame.content.exportForgeFinderButton:SetStatusList({
        {
            statusID = "READY",
            label = CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CONTROL_PANEL_FORGEFINDER_EXPORT),
            enabled = true,
        }
    })

    GGUI.HelpIcon({
        parent = frame.content,
        anchorParent = frame.content.exportForgeFinderButton.frame,
        anchorA = "RIGHT",
        anchorB = "LEFT",
        offsetX = -3,
        text = CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CONTROL_PANEL_FORGEFINDER_EXPLANATION)
    })

    local pixelHeart = CraftSim.MEDIA:GetAsTextIcon(CraftSim.MEDIA.IMAGES.PIXEL_HEART, 0.2)
    frame.content.supportersButton = GGUI.Button({
        parent = frame.content,
        anchorParent = frame.content.debugButton.frame,
        anchorA = "TOPRIGHT",
        anchorB = "BOTTOMRIGHT",
        label = pixelHeart .. CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CONTROL_PANEL_SUPPORTERS_BUTTON) .. pixelHeart,
        sizeX = 25,
        sizeY = 25,
        adjustWidth = true,
        clickCallback = function()
            GGUI:GetFrame(CraftSim.INIT.FRAMES, CraftSim.CONST.FRAMES.SUPPORTERS):Show()
        end
    })

    frame.content.optionsButton = GGUI.Button({
        parent = frame.content,
        anchorParent = frame.content.newsButton.frame,
        anchorA = "RIGHT",
        anchorB = "LEFT",
        sizeX = 15,
        sizeY = 25,
        adjustWidth = true,
        clickCallback = function()
            InterfaceOptionsFrame_OpenToCategory(CraftSim.OPTIONS.optionsPanel)
        end,
        label = CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CONTROL_PANEL_OPTIONS)
    })

    frame.content.resetFramesButton = GGUI.Button({
        parent = frame.content,
        anchorParent = frame.content.optionsButton.frame,
        anchorA = "RIGHT",
        anchorB = "LEFT",
        sizeX = 20,
        sizeY = 25,
        adjustWidth = true,
        clickCallback = function()
            CraftSim.FRAME:ResetFrames()
        end,
        label = CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CONTROL_PANEL_RESET_FRAMES)
    })


    -- 1. Column
    frame.content.MODULE_REAGENT_OPTIMIZATION = createModuleCheckbox(
        CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_REAGENT_OPTIMIZATION_LABEL),
        CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_REAGENT_OPTIMIZATION_TOOLTIP),
        "TOPLEFT", frame.content, "TOPLEFT", cbBaseOffsetX, cbBaseOffsetY, "MODULE_REAGENT_OPTIMIZATION")

    frame.content.MODULE_AVERAGE_PROFIT = createModuleCheckbox(
        CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_AVERAGE_PROFIT_LABEL),
        CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_AVERAGE_PROFIT_TOOLTIP),
        "TOP", frame.content.MODULE_REAGENT_OPTIMIZATION.frame, "TOP", 0, cbSpacingY, "MODULE_AVERAGE_PROFIT")

    frame.content.MODULE_TOP_GEAR = createModuleCheckbox(
        CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_TOP_GEAR_LABEL),
        CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_TOP_GEAR_TOOLTIP),
        "TOP", frame.content.MODULE_AVERAGE_PROFIT.frame, "TOP", 0, cbSpacingY, "MODULE_TOP_GEAR")

    frame.content.MODULE_CRAFT_QUEUE = createModuleCheckbox(
        CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_CRAFT_QUEUE_LABEL),
        CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_CRAFT_QUEUE_TOOLTIP),
        "TOP", frame.content.MODULE_TOP_GEAR.frame, "TOP", 0, cbSpacingY, "MODULE_CRAFT_QUEUE")


    -- 2. Column
    frame.content.MODULE_COST_OVERVIEW = createModuleCheckbox(
        CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_COST_OVERVIEW_LABEL),
        CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_COST_OVERVIEW_TOOLTIP),
        "LEFT", frame.content.MODULE_REAGENT_OPTIMIZATION.frame, "RIGHT", 155, 0, "MODULE_COST_OVERVIEW")

    frame.content.MODULE_PRICE_OVERRIDE = createModuleCheckbox(
        CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_PRICE_OVERRIDES_LABEL),
        CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_PRICE_OVERRIDES_TOOLTIP),
        "TOP", frame.content.MODULE_COST_OVERVIEW.frame, "TOP", 0, cbSpacingY, "MODULE_PRICE_OVERRIDE")

    frame.content.MODULE_CRAFT_BUFFS = createModuleCheckbox(
        CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_CRAFT_BUFFS_LABEL),
        CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_CRAFT_BUFFS_TOOLTIP),
        "TOP", frame.content.MODULE_PRICE_OVERRIDE.frame, "TOP", 0, cbSpacingY, "MODULE_CRAFT_BUFFS")

    frame.content.MODULE_COOLDOWNS = createModuleCheckbox(
        CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_COOLDOWNS_LABEL),
        CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_COOLDOWNS_TOOLTIP),
        "TOP", frame.content.MODULE_CRAFT_BUFFS.frame, "TOP", 0, cbSpacingY, "MODULE_COOLDOWNS")


    -- 3. Column
    frame.content.MODULE_SPEC_INFO = createModuleCheckbox(
        CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_SPECIALIZATION_INFO_LABEL),
        CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_SPECIALIZATION_INFO_TOOLTIP),
        "LEFT", frame.content.MODULE_COST_OVERVIEW.frame, "RIGHT", 125, 0, "MODULE_SPEC_INFO")

    frame.content.MODULE_CRAFT_RESULTS = createModuleCheckbox(
        CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_CRAFT_RESULTS_LABEL),
        CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_CRAFT_RESULTS_TOOLTIP),
        "TOP", frame.content.MODULE_SPEC_INFO.frame, "TOP", 0, cbSpacingY, "MODULE_CRAFT_RESULTS")

    frame.content.MODULE_COST_OPTIMIZATION = createModuleCheckbox(
        CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_COST_OPTIMIZATION_LABEL),
        CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_COST_OPTIMIZATION_TOOLTIP),
        "TOP", frame.content.MODULE_CRAFT_RESULTS.frame, "TOP", 0, cbSpacingY, "MODULE_COST_OPTIMIZATION")
    frame.content.MODULE_STATISTICS = createModuleCheckbox(
        CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_STATISTICS_LABEL),
        CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_STATISTICS_TOOLTIP),
        "TOP", frame.content.MODULE_COST_OPTIMIZATION.frame, "TOP", 0, cbSpacingY, "MODULE_STATISTICS")


    -- 4. Column
    frame.content.MODULE_RECIPE_SCAN = createModuleCheckbox(
        CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_RECIPE_SCAN_LABEL),
        CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_RECIPE_SCAN_TOOLTIP),
        "LEFT", frame.content.MODULE_SPEC_INFO.frame, "RIGHT", 125, 0, "MODULE_RECIPE_SCAN")

    frame.content.MODULE_CUSTOMER_SERVICE = createModuleCheckbox(
        CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_CUSTOMER_SERVICE_LABEL),
        CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_CUSTOMER_SERVICE_TOOLTIP),
        "TOP", frame.content.MODULE_RECIPE_SCAN.frame, "TOP", 0, cbSpacingY, "MODULE_CUSTOMER_SERVICE")

    frame.content.MODULE_CUSTOMER_HISTORY = createModuleCheckbox(
        CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_CUSTOMER_HISTORY_LABEL),
        CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_CUSTOMER_HISTORY_TOOLTIP),
        "TOP", frame.content.MODULE_CUSTOMER_SERVICE.frame, "TOP", 0, cbSpacingY, "MODULE_CUSTOMER_HISTORY",
        CraftSim.CONST.FRAMES.CUSTOMER_HISTORY)

    frame.content.MODULE_EXPLANATIONS = createModuleCheckbox(
        CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_EXPLANATIONS_LABEL),
        CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_EXPLANATIONS_TOOLTIP),
        "TOP", frame.content.MODULE_CUSTOMER_HISTORY.frame, "TOP", 0, cbSpacingY, "MODULE_EXPLANATIONS",
        CraftSim.CONST.FRAMES.EXPLANATIONS)
end
