---@class CraftSim
local CraftSim = select(2, ...)

local GGUI = CraftSim.GGUI
local GUTIL = CraftSim.GUTIL

---@class CraftSim.OPTIMIZATION.UI
CraftSim.OPTIMIZATION.UI = {}

local L = CraftSim.UTIL:GetLocalizer()
local print = CraftSim.DEBUG:RegisterDebugID("Modules.Optimization.UI")

--- Creates a shim object that wraps a tab content frame to mimic the interface
--- expected by each sub-module's CreateContent function (frame.content, frame.title.frame).
---@param tabContent Frame the BlizzardTab's content frame
---@param frameID string the CONST.FRAMES ID for backward compatibility lookups
---@return table shim
local function createSubModuleShim(tabContent, frameID)
    local shim = {}
    shim.content = tabContent
    shim.frameID = frameID

    -- Fake title anchor: sub-module content functions use frame.title.frame as an anchor point.
    -- We place it at the very top of the tab content area.
    local titleFrame = CreateFrame("Frame", nil, tabContent)
    titleFrame:SetSize(1, 1)
    titleFrame:SetPoint("TOPLEFT", tabContent, "TOPLEFT", 0, 0)
    shim.title = { frame = titleFrame }

    -- Frame-like methods for compatibility with code that calls Show/Hide/etc on these frame refs
    function shim:Show() tabContent:Show() end
    function shim:Hide() tabContent:Hide() end
    function shim:SetVisible(visible)
        if visible then tabContent:Show() else tabContent:Hide() end
    end
    function shim:IsVisible() return tabContent:IsVisible() end
    -- Position management is handled by the parent Optimization frame
    function shim:RestoreSavedConfig(parent) end
    function shim:ResetPosition() end

    return shim
end

--- Creates the tab structure for one variant (NO_WO or WO) of the Optimization frame.
---@param optFrame GGUI.Frame
---@param sizeX number
---@param sizeY number
local function createOptimizationFrameContent(optFrame, sizeX, sizeY)
    local content = optFrame.content

    -- ===== Top-level tabs =====
    content.priceDetailsTab = GGUI.BlizzardTab {
        buttonOptions = {
            parent = content,
            anchorParent = content,
            label = "Prices",
            offsetY = -2,
        },
        top = true,
        initialTab = true,
        parent = content, anchorParent = content,
        sizeX = sizeX - 5,
        sizeY = sizeY - 5,
    }

    content.costOptTab = GGUI.BlizzardTab {
        buttonOptions = {
            parent = content,
            anchorParent = content.priceDetailsTab.button,
            label = "Costs",
            anchorA = "LEFT", anchorB = "RIGHT",
        },
        top = true,
        parent = content, anchorParent = content,
        sizeX = sizeX - 5,
        sizeY = sizeY - 5,
    }

    content.priceOverrideTab = GGUI.BlizzardTab {
        buttonOptions = {
            parent = content,
            anchorParent = content.costOptTab.button,
            label = "Overrides",
            anchorA = "LEFT", anchorB = "RIGHT",
        },
        top = true,
        parent = content, anchorParent = content,
        sizeX = sizeX - 5,
        sizeY = sizeY - 5,
    }

    content.reagentOptTab = GGUI.BlizzardTab {
        buttonOptions = {
            parent = content,
            anchorParent = content.priceOverrideTab.button,
            label = "Reagents",
            anchorA = "LEFT", anchorB = "RIGHT",
        },
        top = true,
        parent = content, anchorParent = content,
        sizeX = sizeX - 5,
        sizeY = sizeY - 5,
    }

    content.topGearTab = GGUI.BlizzardTab {
        buttonOptions = {
            parent = content,
            anchorParent = content.reagentOptTab.button,
            label = "Top Gear",
            anchorA = "LEFT", anchorB = "RIGHT",
        },
        top = true,
        parent = content, anchorParent = content,
        sizeX = sizeX - 5,
        sizeY = sizeY - 5,
    }

    GGUI.BlizzardTabSystem {
        content.priceDetailsTab,
        content.costOptTab,
        content.priceOverrideTab,
        content.reagentOptTab,
        content.topGearTab,
    }
end

function CraftSim.OPTIMIZATION.UI:Init()
    local sizeX = 560
    local sizeY = 420
    local offsetX = -5
    local offsetY = 140

    local frameLevel = CraftSim.UTIL:NextFrameLevel()

    -- ===== NON-WORK-ORDER frame =====
    CraftSim.OPTIMIZATION.frame = GGUI.Frame({
        parent = ProfessionsFrame.CraftingPage.SchematicForm,
        anchorParent = ProfessionsFrame,
        anchorA = "BOTTOMLEFT",
        anchorB = "BOTTOMRIGHT",
        offsetX = offsetX,
        offsetY = offsetY,
        sizeX = sizeX,
        sizeY = sizeY,
        frameID = CraftSim.CONST.FRAMES.OPTIMIZATION,
        title = L(CraftSim.CONST.TEXT.OPTIMIZATION_TITLE),
        collapseable = true,
        closeable = true,
        moveable = true,
        backdropOptions = CraftSim.CONST.DEFAULT_BACKDROP_OPTIONS,
        onCloseCallback = CraftSim.CONTROL_PANEL:HandleModuleClose("MODULE_OPTIMIZATION"),
        frameTable = CraftSim.INIT.FRAMES,
        frameConfigTable = CraftSim.DB.OPTIONS:Get("GGUI_CONFIG"),
        frameStrata = CraftSim.CONST.MODULES_FRAME_STRATA,
        raiseOnInteraction = true,
        frameLevel = frameLevel
    })

    -- ===== WORK-ORDER frame =====
    CraftSim.OPTIMIZATION.frameWO = GGUI.Frame({
        parent = ProfessionsFrame.OrdersPage.OrderView.OrderDetails.SchematicForm,
        anchorParent = ProfessionsFrame,
        anchorA = "BOTTOMLEFT",
        anchorB = "BOTTOMRIGHT",
        offsetX = offsetX,
        offsetY = offsetY,
        sizeX = sizeX,
        sizeY = sizeY,
        frameID = CraftSim.CONST.FRAMES.OPTIMIZATION_WO,
        title = L(CraftSim.CONST.TEXT.OPTIMIZATION_TITLE) ..
            " " .. GUTIL:ColorizeText(L(CraftSim.CONST.TEXT.SOURCE_COLUMN_WO), GUTIL.COLORS.GREY),
        collapseable = true,
        closeable = true,
        moveable = true,
        backdropOptions = CraftSim.CONST.DEFAULT_BACKDROP_OPTIONS,
        onCloseCallback = CraftSim.CONTROL_PANEL:HandleModuleClose("MODULE_OPTIMIZATION"),
        frameTable = CraftSim.INIT.FRAMES,
        frameConfigTable = CraftSim.DB.OPTIONS:Get("GGUI_CONFIG"),
        frameStrata = CraftSim.CONST.MODULES_FRAME_STRATA,
        raiseOnInteraction = true,
        frameLevel = frameLevel
    })

    createOptimizationFrameContent(CraftSim.OPTIMIZATION.frame, sizeX, sizeY)
    createOptimizationFrameContent(CraftSim.OPTIMIZATION.frameWO, sizeX, sizeY)

    -- ===== Create sub-module shims and populate tab content =====
    local function initSubModules(optFrame, isWO)
        local content = optFrame.content

        -- Price Details
        local pdFrameID = isWO and CraftSim.CONST.FRAMES.PRICE_DETAILS_WORK_ORDER or CraftSim.CONST.FRAMES.PRICE_DETAILS
        local pdShim = createSubModuleShim(content.priceDetailsTab.content, pdFrameID)
        CraftSim.INIT.FRAMES[pdFrameID] = pdShim
        if isWO then
            CraftSim.PRICE_DETAILS.frameWO = pdShim
        else
            CraftSim.PRICE_DETAILS.frame = pdShim
        end
        CraftSim.PRICE_DETAILS.UI:CreateContent(pdShim)

        -- Cost Optimization
        local coFrameID = isWO and CraftSim.CONST.FRAMES.COST_OPTIMIZATION_WO or CraftSim.CONST.FRAMES.COST_OPTIMIZATION
        local coShim = createSubModuleShim(content.costOptTab.content, coFrameID)
        CraftSim.INIT.FRAMES[coFrameID] = coShim
        if isWO then
            CraftSim.COST_OPTIMIZATION.frameWO = coShim
        else
            CraftSim.COST_OPTIMIZATION.frame = coShim
        end
        CraftSim.COST_OPTIMIZATION.UI:CreateContent(coShim)

        -- Price Override
        local poFrameID = isWO and CraftSim.CONST.FRAMES.PRICE_OVERRIDE_WORK_ORDER or CraftSim.CONST.FRAMES.PRICE_OVERRIDE
        local poShim = createSubModuleShim(content.priceOverrideTab.content, poFrameID)
        CraftSim.INIT.FRAMES[poFrameID] = poShim
        CraftSim.PRICE_OVERRIDE.UI:CreateContent(poShim)

        -- Reagent Optimization
        local roFrameID = isWO and CraftSim.CONST.FRAMES.REAGENT_OPTIMIZATION_WORK_ORDER or CraftSim.CONST.FRAMES.REAGENT_OPTIMIZATION
        local roShim = createSubModuleShim(content.reagentOptTab.content, roFrameID)
        CraftSim.INIT.FRAMES[roFrameID] = roShim
        CraftSim.REAGENT_OPTIMIZATION.UI:CreateContent(roShim)

        -- Top Gear
        local tgFrameID = isWO and CraftSim.CONST.FRAMES.TOP_GEAR_WORK_ORDER or CraftSim.CONST.FRAMES.TOP_GEAR
        local tgShim = createSubModuleShim(content.topGearTab.content, tgFrameID)
        CraftSim.INIT.FRAMES[tgFrameID] = tgShim
        CraftSim.TOPGEAR.UI:CreateContent(tgShim)
    end

    initSubModules(CraftSim.OPTIMIZATION.frame, false)
    initSubModules(CraftSim.OPTIMIZATION.frameWO, true)

    CraftSim.OPTIMIZATION.frame:Hide()
    CraftSim.OPTIMIZATION.frameWO:Hide()
end
