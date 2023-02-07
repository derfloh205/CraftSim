_, CraftSim = ...

CraftSim.MEDIA = {}

CraftSim.MEDIA.BASE_PATH = "Interface/Addons/CraftSim/Media/Images/"

local print = CraftSim.UTIL:SetDebugPrint(CraftSim.CONST.DEBUG_IDS.MEDIA)

function CraftSim.MEDIA:GetAsTextIcon(image, scale)
    if tContains(CraftSim.MEDIA.IMAGES, image) then
        scale = scale or 1
        local width = image.dimensions.x * scale
        local height = image.dimensions.y * scale

        print("file: " .. tostring(image.file))
        print("width: " .. tostring(width))
        print("height: " .. tostring(height))

        return CraftSim.UTIL:IconToText(CraftSim.MEDIA.BASE_PATH .. image.file, height, width)
    else
        print("Could not find image")
        return "<ImageNotFound>"
    end
end

CraftSim.MEDIA.IMAGES = {
    EXPECTED_VALUE = {file="expectedValue.blp",dimensions={x=128,y=32}},
    FALSE = {file="false.blp",dimensions={x=128,y=128}},
    TRUE = {file="true.blp",dimensions={x=128,y=128}},
}