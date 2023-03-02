_, CraftSim = ...

local print = CraftSim.UTIL:SetDebugPrint(CraftSim.CONST.DEBUG_IDS.CRAFT_DATA)

CraftSim.CRAFTDATA.FRAMES = {}

CraftSim.CRAFTDATA.frame = nil

function CraftSim.CRAFTDATA.FRAMES:Init()

    ---@type GGUI.Frame | GGUI.Widget
    local craftDataFrame = CraftSim.GGUI.Frame({
        parent=ProfessionsFrame,anchorFrame=UIParent,
        sizeX=400,sizeY=400,
        title="CraftSim Craft Data",
        backdropOptions=CraftSim.CONST.DEFAULT_BACKDROP_OPTIONS,
        collapseable=true,moveable=true,closeable=true,
        onCloseCallback=CraftSim.FRAME:HandleModuleClose("modulesCraftData"),
        frameID=CraftSim.CONST.FRAMES.CRAFT_DATA,
        frameStrata="DIALOG",
    })

    ---@type GGUI.Dropdown | GGUI.Widget
    craftDataFrame.content.resultsDropdown = CraftSim.GGUI.Dropdown({
        parent=craftDataFrame.content,anchorParent=craftDataFrame.title.frame,
        anchorA="TOP", anchorB="BOTTOM", offsetY=-30,
    })

    CraftSim.CRAFTDATA.frame = craftDataFrame
end

---@param recipeData CraftSim.RecipeData
function CraftSim.CRAFTDATA.FRAMES:UpdateDisplay(recipeData)
    
    local craftDataFrame = CraftSim.CRAFTDATA.frame

    -- only active for non gear stuff? TODO
    
    -- set current recipeID, only populate dropdown if recipeID is different from the previous one
    if craftDataFrame.recipeID ~= recipeData.recipeID then
        craftDataFrame.recipeID = recipeData.recipeID

        CraftSim.GUTIL:ContinueOnAllItemsLoaded(recipeData.resultData.itemsByQuality, function ()
            print("Populate dropdown")
            local dropdownData = {}
            table.foreach(recipeData.resultData.itemsByQuality, function (_, item)
                table.insert(dropdownData, {
                    label = item:GetItemLink(),
                    value = item,
                })
            end)

            craftDataFrame.content.resultsDropdown:SetData({data=dropdownData})
        end)

    else

    end
end

