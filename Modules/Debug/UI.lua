---@class CraftSim
local CraftSim = select(2, ...)

---@class CraftSim.DEBUG
CraftSim.DEBUG = CraftSim.DEBUG

---@class CraftSim.DEBUG.UI
CraftSim.DEBUG.UI = {}

local GUTIL = CraftSim.GUTIL
local GGUI = CraftSim.GGUI

local f = GUTIL:GetFormatter()

function CraftSim.DEBUG.UI:Init()
    local sizeX = 400
    local sizeY = 400
    ---@class CraftSim.DEBUG.FRAME : GGUI.Frame
    local debugFrame = GGUI.Frame({
        anchorA = "BOTTOMRIGHT",
        anchorB = "BOTTOMRIGHT",
        sizeX = sizeX,
        sizeY = sizeY,
        frameID = CraftSim.CONST.FRAMES.DEBUG,
        title = "CraftSim Log",
        closeable = true,
        moveable = true,
        backdropOptions = CraftSim.CONST.DEFAULT_BACKDROP_OPTIONS,
        parent = UIParent,
        anchorParent = UIParent,
        frameTable = CraftSim.INIT.FRAMES,
        frameConfigTable = CraftSim.DB.OPTIONS:Get("GGUI_CONFIG"),
        frameStrata = CraftSim.CONST.MODULES_FRAME_STRATA,
        raiseOnInteraction = true,
        frameLevel = 50,
    })

    local debugIDTable = CraftSim.DB.OPTIONS:Get("DEBUG_IDS")

    debugFrame.content.optionsButton = CraftSim.WIDGETS.OptionsButton {
        parent = debugFrame.frame,
        anchorPoints = { {
            anchorParent = debugFrame.title.frame,
            anchorA = "LEFT", anchorB = "RIGHT", offsetX = 5,
        } },
        menuUtilCallback = function(ownerRegion, rootDescription)
            local logIDs = rootDescription:CreateButton("Log IDs")

            for _, debugID in pairs(CraftSim.CONST.DEBUG_IDS) do
                logIDs:CreateCheckbox(debugID, function()
                    return debugIDTable[debugID]
                end, function()
                    debugIDTable[debugID] = not debugIDTable[debugID]
                end)
            end

            rootDescription:CreateCheckbox(
                "Enable Autoscroll",
                function()
                    return CraftSim.DB.OPTIONS:Get("DEBUG_AUTO_SCROLL")
                end, function()
                    local value = CraftSim.DB.OPTIONS:Get(
                        "DEBUG_AUTO_SCROLL")
                    CraftSim.DB.OPTIONS:Save("DEBUG_AUTO_SCROLL",
                        not value)
                end)

            rootDescription:CreateButton(f.l("Clear"), function()
                CraftSim.DEBUG.frame.content.logBox:Clear()
            end)
        end
    }

    CraftSim.DEBUG.frame = debugFrame

    CraftSim.DEBUG.UI:InitDebugFrame(debugFrame)
end

---@param debugFrame GGUI.Frame
function CraftSim.DEBUG.UI:InitDebugFrame(debugFrame)
    CraftSim.FRAME:ToggleFrame(debugFrame, CraftSim.DB.OPTIONS:Get("DEBUG_VISIBLE"))

    debugFrame:HookScript("OnShow", function() CraftSim.DB.OPTIONS:Save("DEBUG_VISIBLE", true) end)
    debugFrame:HookScript("OnHide", function() CraftSim.DB.OPTIONS:Save("DEBUG_VISIBLE", false) end)

    debugFrame.content.logBox = GGUI.ScrollingMessageFrame {
        parent = debugFrame.content,
        anchorParent = debugFrame.content,
        anchorA = "TOP", anchorB = "TOP", offsetY = -35, offsetX = 0,
        enableScrolling = true,
        showScrollBar = true,
        maxLines = 100000,
        sizeX = 350,
        sizeY = 350,
        justifyOptions = { type = "H", align = "LEFT" },
        copyable = true,
    }

    debugFrame.content.logBox:EnableHyperLinksForFrameAndChilds()

    debugFrame.addDebug = function(debugOutput, debugID, printLabel)
        if debugFrame:IsVisible() then
            if printLabel then
                debugFrame.content.logBox:AddMessage("\n- " .. debugID .. ":\n" .. tostring(debugOutput))
            else
                debugFrame.content.logBox:AddMessage("\n" .. tostring(debugOutput))
            end
        end
    end

    CraftSim.DEBUG.UI:InitControlPanel(debugFrame)

    GGUI:EnableHyperLinksForFrameAndChilds(debugFrame.content)
end

function CraftSim.DEBUG.UI:InitControlPanel(debugFrame)
    local tabSizeX = 400
    local tabSizeY = 400

    ---@class CraftSim.DEBUG.FRAME.CONTROL_PANEL : GGUI.Frame
    local controlPanel = GGUI.Frame({
        parent = debugFrame.frame,
        anchorParent = debugFrame.frame,
        anchorA = "TOPRIGHT",
        anchorB = "TOPLEFT",
        title = "CraftSim Debug Tools",
        offsetX = 10,
        sizeX = 400,
        sizeY = 400,
        frameID = CraftSim.CONST.FRAMES.DEBUG_CONTROL,
        backdropOptions = CraftSim.CONST.DEFAULT_BACKDROP_OPTIONS,
        frameTable = CraftSim.INIT.FRAMES,
        frameConfigTable = CraftSim.DB.OPTIONS:Get("GGUI_CONFIG"),
    })

    ---@class CraftSim.DEBUG.FRAME.CONTROL_PANEL.CONTENT : Frame
    local content = controlPanel.content

    content.reloadButton = GGUI.Button({
        label = "Reload UI",
        parent = controlPanel.content,
        anchorParent = controlPanel.content,
        anchorA = "TOPRIGHT",
        anchorB = "TOPRIGHT",
        sizeX = 15,
        sizeY = 25,
        adjustWidth = true,
        clickCallback = function()
            C_UI.Reload()
        end,
        offsetX = -15,
        offsetY = -10,
    })



    content.moduleDebugTools = GGUI.FilterButton {
        label = "Modules",
        parent = content,
        anchorPoints = { {
            anchorParent = content, anchorA = "TOP", anchorB = "TOP", offsetY = -40
        } },
        sizeX = 160, sizeY = 23,
        menuUtilCallback = function(ownerRegion, rootDescription)
            local main = rootDescription:CreateButton("Main")
            main:CreateButton("Inspect CraftSim Addon Table", function()
                CraftSim.DEBUG:InspectTable(CraftSim, "CraftSim", true)
            end)

            local openRecipe = main:CreateButton("Open Recipe")

            openRecipe:CreateButton("Inspect RecipeData", function()
                local recipeData = CraftSim.INIT.currentRecipeData
                if recipeData then
                    CraftSim.DEBUG:InspectTable(recipeData, string.format("Open Recipe (%s)", recipeData.recipeName),
                        true)
                end
            end)

            openRecipe:CreateButton("Inspect SpecializationData", function()
                local recipeData = CraftSim.INIT.currentRecipeData
                if recipeData and recipeData
                    .specializationData then
                    CraftSim.DEBUG:InspectTable(recipeData.specializationData,
                        string.format("Specialization Data (%s)", recipeData.recipeName),
                        true)
                end
            end)

            local recipeScan = rootDescription:CreateButton("Recipe Scan")

            recipeScan:CreateButton("Inspect Displayed Results", function()
                local recipeScanTab = CraftSim.RECIPE_SCAN.frame.content.recipeScanTab
                local professionList = recipeScanTab.content.professionList --[[@as GGUI.FrameList]]
                local selectedRow = professionList.selectedRow --[[@as CraftSim.RECIPE_SCAN.PROFESSION_LIST.ROW]]

                if selectedRow then
                    local nameMap = {}
                    for index, recipeData in ipairs(selectedRow.currentResults) do
                        nameMap["[" .. index .. "] " .. recipeData.recipeName] = recipeData
                    end
                    CraftSim.DEBUG:InspectTable(nameMap,
                        "Recipe Scan Results: " .. tostring(selectedRow.crafterProfessionUID), true)
                end
            end)

            local craftQueue = rootDescription:CreateButton("CraftQueue")

            craftQueue:CreateButton("Inspect CraftQueueItems", function()
                local nameMap = {}
                for index, cqi in pairs(CraftSim.CRAFTQ.craftQueue.craftQueueItems) do
                    nameMap["[" .. index .. "] " .. cqi.recipeData:GetCrafterUID() .. "-" .. cqi.recipeData.recipeName] =
                        cqi
                end
                CraftSim.DEBUG:InspectTable(nameMap, "CraftQueueItems", true)
            end)
        end
    }
end
