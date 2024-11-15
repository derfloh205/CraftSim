---@class CraftSim
local CraftSim = select(2, ...)

local GGUI = CraftSim.GGUI
local GUTIL = CraftSim.GUTIL
local L = CraftSim.UTIL:GetLocalizer()
local f = CraftSim.GUTIL:GetFormatter()

---@class Craftsim.WIDGETS
CraftSim.WIDGETS = {}

---@class CraftSim.WIDGETS.OptionsButton.ConstructorOptions
---@field parent Frame
---@field anchorPoints GGUI.AnchorPoint[]
---@field menuUtilCallback fun(ownerRegion: Region, rootDescription: any)

---@class CraftSim.WIDGETS.OptionsButton : GGUI.Button
---@overload fun(options: CraftSim.WIDGETS.OptionsButton.ConstructorOptions): CraftSim.WIDGETS.OptionsButton
CraftSim.WIDGETS.OptionsButton = GGUI.Button:extend()
---@param options CraftSim.WIDGETS.OptionsButton.ConstructorOptions
function CraftSim.WIDGETS.OptionsButton:new(options)
    ---@type GGUI.Button.ConstructorOptions
    local buttonOptions = {
        parent = options.parent,
        anchorPoints = options.anchorPoints,
        cleanTemplate = true,
        buttonTextureOptions = CraftSim.CONST.BUTTON_TEXTURE_OPTIONS.OPTIONS,
        sizeX = 20,
        sizeY = 20,
        clickCallback = function(button, mouseButton)
            MenuUtil.CreateContextMenu(UIParent, function(ownerRegion, rootDescription)
                options.menuUtilCallback(ownerRegion, rootDescription)
            end)
        end
    }

    CraftSim.WIDGETS.OptionsButton.super.new(self, buttonOptions)
end
