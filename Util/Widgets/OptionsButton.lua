---@class CraftSim
local CraftSim = select(2, ...)

local GGUI = CraftSim.GGUI

CraftSim.WIDGETS = CraftSim.WIDGETS or {}

---@class CraftSim.WIDGETS.OptionsButton.ConstructorOptions
---@field isFilter boolean? if true, the button will use the filter texture, otherwise the options texture
---@field tooltipOptions GGUI.TooltipOptions? tooltip options for the button
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
        tooltipOptions = options.tooltipOptions,
        buttonTextureOptions = options.isFilter and {
            normal = CraftSim.MEDIA:GetImagePath(CraftSim.MEDIA.IMAGES.FILTER_BUTTON_NORMAL),
            disabled = CraftSim.MEDIA:GetImagePath(CraftSim.MEDIA.IMAGES.FILTER_BUTTON_NORMAL),
            highlight = CraftSim.MEDIA:GetImagePath(CraftSim.MEDIA.IMAGES.FILTER_BUTTON_NORMAL),
            pushed = CraftSim.MEDIA:GetImagePath(CraftSim.MEDIA.IMAGES.FILTER_BUTTON_PRESSED),
        } or CraftSim.CONST.BUTTON_TEXTURE_OPTIONS.OPTIONS,
        sizeX = options.isFilter and 14 or 20,
        sizeY = options.isFilter and 14 or 20,
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
