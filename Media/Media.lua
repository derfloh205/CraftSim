---@class CraftSim
local CraftSim = select(2, ...)

CraftSim.MEDIA = {}

CraftSim.MEDIA.BASE_PATH = "Interface/Addons/CraftSim/Media/Images/"

local print = CraftSim.DEBUG:RegisterDebugID("Media")

function CraftSim.MEDIA:GetAsTextIcon(image, scale)
    if tContains(CraftSim.MEDIA.IMAGES, image) then
        scale = scale or 1
        local width = image.dimensions.x * scale
        local height = image.dimensions.y * scale

        -- a print here causes a stack overflow... so be careful with debugging here
        return CraftSim.GUTIL:IconToText(CraftSim.MEDIA.BASE_PATH .. image.file, height, width, 0, 0, image.dimensions.x,
            image.dimensions.y)
    else
        return "<ImageNotFound>"
    end
end

CraftSim.MEDIA.IMAGES = {
    EXPECTED_VALUE = { file = "expectedValue.blp", dimensions = { x = 128, y = 32 } },
    FALSE = { file = "false.blp", dimensions = { x = 128, y = 128 } },
    TRUE = { file = "true.blp", dimensions = { x = 128, y = 128 } },
    HSV_EXAMPLE = { file = "hsvVisualization.blp", dimensions = { x = 256, y = 64 } },
    ARROW_UP = { file = "upArrow.blp", dimensions = { x = 64, y = 64 } },
    ARROW_DOWN = { file = "downArrow.blp", dimensions = { x = 64, y = 64 } },
    PIXEL_HEART = { file = "pixelHeart.blp", dimensions = { x = 64, y = 64 } },
    KOFI = { file = "kofi.blp", dimensions = { x = 64, y = 64 } },
    PAYPAL = { file = "paypal.blp", dimensions = { x = 64, y = 64 } },
    EDIT_PEN = { file = "edit.blp", dimensions = { x = 25, y = 25 } },
    PIN = { file = "pin.tga", dimensions = { x = 32, y = 32 } },
}

function CraftSim.MEDIA:GetImagePath(image)
    return CraftSim.MEDIA.BASE_PATH .. image.file
end
