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

    debugFrame.content.optionsButton = CraftSim.WIDGETS.OptionsButton {
        parent = debugFrame.frame,
        anchorPoints = { {
            anchorParent = debugFrame.title.frame,
            anchorA = "LEFT", anchorB = "RIGHT", offsetX = 5,
        } },
        menuUtilCallback = function(ownerRegion, rootDescription)
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
        anchorA = "TOP", anchorB = "TOP", offsetY = -35, offsetX = 10,
        enableScrolling = true,
        maxLines = 100000,
        sizeX = 370,
        sizeY = 360,
        justifyOptions = { type = "H", align = "LEFT" },
    }

    debugFrame.content.logBox:EnableHyperLinksForFrameAndChilds()

    debugFrame.addDebug = function(debugOutput, debugID, printLabel)
        if debugFrame:IsVisible() then
            if printLabel then
                debugFrame.content.logBox:AddMessage("- " .. debugID .. ":\n" .. tostring(debugOutput))
            else
                debugFrame.content.logBox:AddMessage(tostring(debugOutput))
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
        title = "Debug Control",
        offsetX = 10,
        sizeX = 400,
        sizeY = 400,
        frameID = CraftSim.CONST.FRAMES.DEBUG_CONTROL,
        backdropOptions = CraftSim.CONST.DEFAULT_BACKDROP_OPTIONS,
        frameTable = CraftSim.INIT.FRAMES,
        frameConfigTable = CraftSim.DB.OPTIONS:Get("GGUI_CONFIG"),
    })

    ---@class CraftSim.DEBUG.FRAME.CONTROL_PANEL.CONTENT : Frame
    controlPanel.content = controlPanel.content

    controlPanel.content.reloadButton = GGUI.Button({
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

    controlPanel.content.logTab = GGUI.BlizzardTab {
        buttonOptions = {
            label = "Log Options", offsetY = -3,
        },
        initialTab = true,
        top = true,
        parent = controlPanel.content, anchorParent = controlPanel.content,
        sizeX = tabSizeX,
        sizeY = tabSizeY
    }

    controlPanel.content.dbTab = GGUI.BlizzardTab {
        buttonOptions = {
            label = "DB", anchorA = "LEFT", anchorB = "RIGHT",
            anchorParent = controlPanel.content.logTab.button
        },
        top = true,
        parent = controlPanel.content, anchorParent = controlPanel.content,
        sizeX = tabSizeX,
        sizeY = tabSizeY
    }

    controlPanel.content.modulesTab = GGUI.BlizzardTab {
        buttonOptions = {
            label = "Modules", anchorA = "LEFT", anchorB = "RIGHT",
            anchorParent = controlPanel.content.dbTab.button
        },
        top = true,
        parent = controlPanel.content, anchorParent = controlPanel.content,
        sizeX = tabSizeX,
        sizeY = tabSizeY
    }

    GGUI.BlizzardTabSystem { controlPanel.content.logTab, controlPanel.content.dbTab, controlPanel.content.modulesTab }

    CraftSim.DEBUG.UI:InitLogOptionsTab(controlPanel.content.logTab)
    CraftSim.DEBUG.UI:InitCacheTab(controlPanel.content.dbTab)
    CraftSim.DEBUG.UI:InitModuleDebugToolsTab(controlPanel.content.modulesTab)
end

function CraftSim.DEBUG.UI:InitLogOptionsTab(logOptionsTab)
    local content = logOptionsTab.content

    local debugIDTable = CraftSim.DB.OPTIONS:Get("DEBUG_IDS")

    content.debugIDSelector = GGUI.CheckboxSelector {
        parent = content,
        anchorPoints = {
            {
                anchorParent = content,
                anchorA = "TOP", anchorB = "TOP", offsetY = -40,
            }
        },
        label = "Debug Log IDs",
        savedVariablesTable = debugIDTable,
        sizeX = 100,
        sizeY = 25,
        initialItems = GUTIL:Map(CraftSim.CONST.DEBUG_IDS, function(debugID)
            ---@type GGUI.CheckboxSelector.CheckboxItem
            local item = {
                name = debugID,
                initialValue = debugIDTable[debugID],
                savedVariableProperty = debugID,
                selectionID = debugID,
            }
            return item
        end),
        onSelectCallback = function(_, selectedItem, selectedValue)
            debugIDTable[selectedItem] = selectedValue
        end
    }
end

---@deprecated
function CraftSim.DEBUG.UI:InitCacheTab(cacheTab)
    local content = cacheTab.content

    content.clearCacheButton = GGUI.Button({
        label = "Clear All Caches",
        parent = content,
        anchorParent = content,
        anchorA = "TOP",
        anchorB = "TOP",
        offsetY = -50,
        sizeX = 15,
        sizeY = 25,
        adjustWidth = true,
        clickCallback = function()
            CraftSim.DB:ClearAll()
        end
    })

    content.cacheList = GGUI.FrameList {
        columnOptions = {
            {
                label = "",
                width = 180,
            },
            {
                label = "",
                width = 70,
            },
            {
                label = "",
                width = 70,
            }
        },
        parent = content,
        anchorParent = content,
        anchorA = "TOP",
        anchorB = "TOP",
        offsetY = -80,
        offsetX = -10,
        sizeY = 300,
        rowConstructor = function(columns)
            local nameColumn = columns[1]
            local clearColumn = columns[2]
            local inspectColumn = columns[3]

            nameColumn.text = GGUI.Text {
                parent = nameColumn, anchorParent = nameColumn,
                anchorA = "LEFT", anchorB = "LEFT", justifyOptions = { type = "H", align = "LEFT" }, offsetX = 5,
            }

            clearColumn.clearButton = GGUI.Button {
                parent = clearColumn, anchorParent = clearColumn,
                label = "Clear", adjustWidth = true, sizeX = 15, scale = 0.9,
            }

            inspectColumn.inspectButton = GGUI.Button {
                parent = inspectColumn, anchorParent = inspectColumn,
                label = "Inspect", adjustWidth = true, sizeX = 15, scale = 0.9,
            }
        end,
        showBorder = true,
    }

    local caches = CraftSim.DEBUG:GetCacheGlobalsList()

    for _, cacheName in ipairs(caches) do
        content.cacheList:Add(function(row)
            local columns = row.columns
            local nameColumn = columns[1]
            local clearColumn = columns[2]
            local inspectColumn = columns[3]

            nameColumn.text:SetText(cacheName)

            local clearButton = clearColumn.clearButton --[[@as GGUI.Button]]

            clearButton.clickCallback = function()
                CraftSim.DEBUG:SystemPrint(f.l("CraftSim ") .. "Button deprecated and will be implemented anew")
            end

            local inspectButton = inspectColumn.inspectButton --[[@as GGUI.Button]]

            inspectButton.clickCallback = function()
                if DevTool then
                    DevTool.MainWindow:Show()
                    DevTool:AddData(_G[cacheName] or {}, cacheName)
                else
                    DisplayTableInspectorWindow(_G[cacheName])
                end
            end
        end)
    end

    content.cacheList:UpdateDisplay()
end

function CraftSim.DEBUG.UI:InitModuleDebugToolsTab(moduleToolsTab)
    local content = moduleToolsTab.content

    local tabX = 380
    local tabY = 320
    local tabButtonOffsetY = -60
    local tabOffsetY = -20

    content.mainTab = GGUI.BlizzardTab {
        buttonOptions = {
            parent = content, anchorParent = content,
            label = "Main",
            offsetY = tabButtonOffsetY,
            offsetX = 10,
        },
        top = true,
        initialTab = true,
        parent = content, anchorParent = content,
        sizeX = tabX, sizeY = tabY,
        offsetY = tabOffsetY,
        backdropOptions = CraftSim.CONST.BACKDROPS.OPTIONS_CONTENT_FRAME,
    }

    content.recipeScanTab = GGUI.BlizzardTab {
        buttonOptions = {
            parent = content, anchorParent = content.mainTab.button,
            anchorA = "LEFT", anchorB = "RIGHT",
            label = "Recipe Scan",
        },
        top = true,
        parent = content, anchorParent = content,
        sizeX = tabX, sizeY = tabY,
        offsetY = tabOffsetY,
        backdropOptions = CraftSim.CONST.BACKDROPS.OPTIONS_CONTENT_FRAME,
    }

    content.craftQueueTab = GGUI.BlizzardTab {
        buttonOptions = {
            parent = content, anchorParent = content.recipeScanTab.button,
            anchorA = "LEFT", anchorB = "RIGHT",
            label = "Craft Queue",
        },
        top = true,
        parent = content, anchorParent = content,
        sizeX = tabX, sizeY = tabY,
        offsetY = tabOffsetY,
        backdropOptions = CraftSim.CONST.BACKDROPS.OPTIONS_CONTENT_FRAME,
    }

    content.specInfoTab = GGUI.BlizzardTab {
        buttonOptions = {
            parent = content, anchorParent = content.craftQueueTab.button,
            anchorA = "LEFT", anchorB = "RIGHT",
            label = "Spec Info",
        },
        top = true,
        parent = content, anchorParent = content,
        sizeX = tabX, sizeY = tabY,
        offsetY = tabOffsetY,
        backdropOptions = CraftSim.CONST.BACKDROPS.OPTIONS_CONTENT_FRAME,
    }

    CraftSim.DEBUG.UI:InitModuleToolsMainTab(content.mainTab)
    CraftSim.DEBUG.UI:InitModuleToolsRecipeScanTab(content.recipeScanTab)
    CraftSim.DEBUG.UI:InitModuleToolsCraftQueueTab(content.craftQueueTab)
    CraftSim.DEBUG.UI:InitModuleToolsSpecInfoTab(content.specInfoTab)

    GGUI.BlizzardTabSystem { content.mainTab, content.recipeScanTab, content.craftQueueTab, content.specInfoTab }
end

function CraftSim.DEBUG.UI:InitModuleToolsMainTab(mainTab)
    local content = mainTab.content

    content.inspectCraftSimButton = GGUI.Button {
        label = "Inspect CraftSim",
        parent = content,
        anchorParent = content,
        anchorA = "TOPLEFT", anchorB = "TOPLEFT", offsetY = -20, offsetX = 20,
        adjustWidth = true, sizeX = 15, sizeY = 25,
        clickCallback = function()
            if DevTool then
                DevTool.MainWindow:Show()
                DevTool:AddData(CraftSim, "CraftSim")
            end
        end
    }

    content.inspectOpenRecipeButton = GGUI.Button {
        label = "Inspect Open Recipe",
        parent = content,
        anchorParent = content.inspectCraftSimButton.frame,
        anchorA = "TOPLEFT", anchorB = "BOTTOMLEFT",
        adjustWidth = true, sizeX = 15, sizeY = 25,
        clickCallback = function()
            if DevTool then
                DevTool.MainWindow:Show()
                DevTool:AddData(CraftSim.INIT.currentRecipeData, "Open RecipeData")
            end
        end
    }

    content.inspectOpenRecipeButton = GGUI.Button {
        label = "Inspect Specialization Data",
        parent = content,
        anchorParent = content.inspectOpenRecipeButton.frame,
        anchorA = "TOPLEFT", anchorB = "BOTTOMLEFT",
        adjustWidth = true, sizeX = 15, sizeY = 25,
        clickCallback = function()
            if DevTool then
                DevTool.MainWindow:Show()
                DevTool:AddData(CraftSim.INIT.currentRecipeData.specializationData, "Open Recipe - SpecializationData")
            end
        end
    }
end

function CraftSim.DEBUG.UI:InitModuleToolsRecipeScanTab(recipeScanTab)
    local content = recipeScanTab.content

    content.inspectResultsButton = GGUI.Button {
        parent = content, anchorParent = content,
        label = "Inspect Displayed Recipe Scan Results", adjustWidth = true, sizeX = 15,
        anchorA = "TOPLEFT", anchorB = "TOPLEFT", offsetX = 20, offsetY = -20,
        clickCallback = function()
            if DevTool then
                local recipeScanTab = CraftSim.RECIPE_SCAN.frame.content.recipeScanTab
                local professionList = recipeScanTab.content.professionList --[[@as GGUI.FrameList]]
                local selectedRow = professionList.selectedRow --[[@as CraftSim.RECIPE_SCAN.PROFESSION_LIST.ROW]]

                if selectedRow then
                    DevTool.MainWindow:Show()
                    local nameMap = {}
                    for index, recipeData in ipairs(selectedRow.currentResults) do
                        nameMap["[" .. index .. "] " .. recipeData.recipeName] = recipeData
                    end
                    DevTool:AddData(nameMap,
                        "Recipe Scan Results: " .. tostring(selectedRow.crafterProfessionUID))
                end
            end
        end
    }
end

function CraftSim.DEBUG.UI:InitModuleToolsCraftQueueTab(craftQueueTab)
    local content = craftQueueTab.content

    content.inspectQueueButton = GGUI.Button {
        parent = content, anchorParent = content,
        label = "Inspect CraftQueueItems", adjustWidth = true, sizeX = 15,
        anchorA = "TOPLEFT", anchorB = "TOPLEFT", offsetX = 20, offsetY = -20,
        clickCallback = function()
            if DevTool then
                DevTool.MainWindow:Show()
                local nameMap = {}
                for index, cqi in pairs(CraftSim.CRAFTQ.craftQueue.craftQueueItems) do
                    nameMap["[" .. index .. "] " .. cqi.recipeData:GetCrafterUID() .. "-" .. cqi.recipeData.recipeName] =
                        cqi
                end
                DevTool:AddData(nameMap, "CraftQueueItems")
            end
        end
    }
end

function CraftSim.DEBUG.UI:InitModuleToolsSpecInfoTab(specInfoTab)
    local content = specInfoTab.content

    content.showOutdatedNodes = GGUI.Button({
        label = "Fetch Outdated Nodes",
        parent = content,
        anchorParent = content,
        anchorA = "TOPLEFT",
        anchorB = "TOPLEFT",
        sizeX = 15,
        sizeY = 25,
        adjustWidth = true,
        clickCallback = function()
            CraftSim.DEBUG:ShowOutdatedSpecNodes()
        end,
        offsetX = 10,
        offsetY = -10
    })
end
