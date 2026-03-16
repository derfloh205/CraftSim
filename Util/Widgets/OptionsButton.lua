---@class CraftSim
local CraftSim = select(2, ...)

local GGUI = CraftSim.GGUI

CraftSim.WIDGETS = CraftSim.WIDGETS or {}

---@class CraftSim.WIDGETS.OptionsButton.ConstructorOptions
---@field parent Frame
---@field anchorPoints GGUI.AnchorPoint[]
---@field menuUtilCallback? fun(ownerRegion: Region, rootDescription: any) legacy: same as menu (function)
---@field menu? fun(ownerRegion: Region, rootDescription: any) | CraftSim.WIDGETS.ContextMenu.Item[] menu content: callback or config table for ContextMenu.Build

---@class CraftSim.WIDGETS.OptionsButton : GGUI.Button
---@overload fun(options: CraftSim.WIDGETS.OptionsButton.ConstructorOptions): CraftSim.WIDGETS.OptionsButton
CraftSim.WIDGETS.OptionsButton = GGUI.Button:extend()
---@param options CraftSim.WIDGETS.OptionsButton.ConstructorOptions
function CraftSim.WIDGETS.OptionsButton:new(options)
    local menuConfig = options.menu or options.menuUtilCallback
    ---@type GGUI.Button.ConstructorOptions
    local buttonOptions = {
        parent = options.parent,
        anchorPoints = options.anchorPoints,
        cleanTemplate = true,
        buttonTextureOptions = CraftSim.CONST.BUTTON_TEXTURE_OPTIONS.OPTIONS,
        sizeX = 20,
        sizeY = 20,
        clickCallback = function(button, mouseButton)
            if type(menuConfig) == "function" then
                CraftSim.WIDGETS.ContextMenu.Open(UIParent, menuConfig)
            else
                CraftSim.WIDGETS.ContextMenu.Open(UIParent, menuConfig or {})
            end
        end
    }

    CraftSim.WIDGETS.OptionsButton.super.new(self, buttonOptions)
end
