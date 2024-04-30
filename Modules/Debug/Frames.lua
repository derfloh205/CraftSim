---@class CraftSim
local CraftSim = select(2, ...)

---@class CraftSim.DEBUG
CraftSim.DEBUG = CraftSim.DEBUG

---@class CraftSim.DEBUG.FRAMES
CraftSim.DEBUG.FRAMES = {}

local GUTIL = CraftSim.GUTIL
local GGUI = CraftSim.GGUI

local f = GUTIL:GetFormatter()

function CraftSim.DEBUG.FRAMES:Init()
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
        collapseable = true,
        closeable = true,
        moveable = true,
        scrollableContent = true,
        backdropOptions = CraftSim.CONST.DEFAULT_BACKDROP_OPTIONS,
        parent = UIParent,
        anchorParent = UIParent,
        frameTable = CraftSim.INIT.FRAMES,
        frameConfigTable = CraftSim.DB.OPTIONS:Get("GGUI_CONFIG"),
        frameStrata = CraftSim.CONST.MODULES_FRAME_STRATA,
        raiseOnInteraction = true,
        frameLevel = 50,
    })

    CraftSim.DEBUG.frame = debugFrame

    CraftSim.DEBUG.FRAMES:InitDebugFrame(debugFrame)
end

function CraftSim.DEBUG.FRAMES:InitDebugFrame(debugFrame)
    CraftSim.FRAME:ToggleFrame(debugFrame, CraftSim.DB.OPTIONS:Get("DEBUG_VISIBLE"))

    debugFrame:HookScript("OnShow", function() CraftSim.DB.OPTIONS:Save("DEBUG_VISIBLE", true) end)
    debugFrame:HookScript("OnHide", function() CraftSim.DB.OPTIONS:Save("DEBUG_VISIBLE", false) end)

    debugFrame.content.debugBox = CreateFrame("EditBox", nil, debugFrame.content)
    debugFrame.content.debugBox:SetPoint("TOP", debugFrame.content, "TOP", 0, -20)
    debugFrame.content.debugBox:SetText("")
    debugFrame.content.debugBox:SetWidth(debugFrame.content:GetWidth() - 15)
    debugFrame.content.debugBox:SetHeight(20)
    debugFrame.content.debugBox:SetMultiLine(true)
    debugFrame.content.debugBox:SetAutoFocus(false)
    debugFrame.content.debugBox:SetFontObject("ChatFontNormal")
    debugFrame.content.debugBox:SetScript("OnEscapePressed", function() debugFrame.content.debugBox:ClearFocus() end)
    debugFrame.content.debugBox:SetScript("OnEnterPressed", function() debugFrame.content.debugBox:ClearFocus() end)

    debugFrame.content.autoScrollCB = GGUI.Checkbox {
        parent = debugFrame.frame, anchorParent = debugFrame.frame, anchorA = "TOPLEFT", anchorB = "TOPLEFT", offsetX = 20, offsetY = -15,
        initialValue = CraftSim.DB.OPTIONS:Get("DEBUG_AUTO_SCROLL"),
        label = "Autoscroll",
        clickCallback = function(_, checked)
            CraftSim.DB.OPTIONS:Save("DEBUG_AUTO_SCROLL", checked)
        end
    }

    debugFrame.content.clearButton = GGUI.Button({
        label = "Clear Log",
        parent = debugFrame.frame,
        anchorParent = debugFrame.frame,
        anchorA = "TOPRIGHT",
        anchorB = "TOPRIGHT",
        offsetY = -10,
        offsetX = -60,
        sizeX = 15,
        sizeY = 25,
        adjustWidth = true,
        clickCallback = function()
            CraftSim.DEBUG.frame.content.debugBox:SetText("")
        end,
    })

    debugFrame.addDebug = function(debugOutput, debugID, printLabel)
        if debugFrame:IsVisible() then -- to not make it too bloated over time
            local currentOutput = debugFrame.content.debugBox:GetText()
            if printLabel then
                debugFrame.content.debugBox:SetText(currentOutput ..
                    "\n\n- " .. debugID .. ":\n" .. tostring(debugOutput))
            else
                debugFrame.content.debugBox:SetText(currentOutput .. "\n" .. tostring(debugOutput))
            end
        end
    end

    debugFrame.frame.scrollFrame:HookScript("OnScrollRangeChanged", function()
        if CraftSim.DB.OPTIONS:Get("DEBUG_AUTO_SCROLL") then
            debugFrame.frame.scrollFrame:SetVerticalScroll(debugFrame.frame.scrollFrame:GetVerticalScrollRange())
        end
    end)

    CraftSim.DEBUG.FRAMES:InitControlPanel(debugFrame)

    GGUI:EnableHyperLinksForFrameAndChilds(debugFrame.content)
end

function CraftSim.DEBUG.FRAMES:InitControlPanel(debugFrame)
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
            label = "Debug IDs", offsetY = -3,
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

    CraftSim.DEBUG.FRAMES:InitLogOptionsTab(controlPanel.content.logTab)
    CraftSim.DEBUG.FRAMES:InitCacheTab(controlPanel.content.dbTab)
    CraftSim.DEBUG.FRAMES:InitModuleDebugToolsTab(controlPanel.content.modulesTab)
end

function CraftSim.DEBUG.FRAMES:InitLogOptionsTab(logOptionsTab)
    local content = logOptionsTab.content

    content.debugIDList = GGUI.FrameList {
        columnOptions = {
            {
                label = "",
                width = 100,
            },
            {
                label = "",
                width = 220,
            }
        },
        parent = content, anchorParent = content, sizeY = 340, anchorA = "TOP", anchorB = "TOP", offsetY = -40, showBorder = true, offsetX = -10,
        rowConstructor = function(columns)
            local checkBoxRow = columns[1]
            local labelRow = columns[2]

            checkBoxRow.cb = GGUI.Checkbox {
                parent = checkBoxRow, anchorParent = checkBoxRow,
            }

            labelRow.text = GGUI.Text {
                parent = labelRow, anchorParent = labelRow, anchorA = "LEFT", anchorB = "LEFT", justifyOptions = { type = "H", align = "LEFT" }
            }
        end
    }

    local debugIDs = CraftSim.CONST.DEBUG_IDS


    for _, debugID in pairs(debugIDs) do
        content.debugIDList:Add(function(row)
            local columns = row.columns
            local checkBoxRow = columns[1]
            local labelRow = columns[2]

            row.debugID = debugID
            labelRow.text:SetText(debugID)

            local cb = checkBoxRow.cb --[[@as GGUI.Checkbox]]

            local debugIDs = CraftSim.DB.OPTIONS:Get("DEBUG_IDS")

            cb:SetChecked(debugIDs[debugID])
            cb.clickCallback = function(_, checked)
                debugIDs[debugID] = checked
            end
        end)
    end

    content.debugIDList:UpdateDisplay(function(rowA, rowB)
        return rowA.debugID > rowB.debugID
    end)
end

---@deprecated
function CraftSim.DEBUG.FRAMES:InitCacheTab(cacheTab)
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

function CraftSim.DEBUG.FRAMES:InitModuleDebugToolsTab(moduleToolsTab)
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

    CraftSim.DEBUG.FRAMES:InitModuleToolsMainTab(content.mainTab)
    CraftSim.DEBUG.FRAMES:InitModuleToolsRecipeScanTab(content.recipeScanTab)
    CraftSim.DEBUG.FRAMES:InitModuleToolsCraftQueueTab(content.craftQueueTab)
    CraftSim.DEBUG.FRAMES:InitModuleToolsSpecInfoTab(content.specInfoTab)

    GGUI.BlizzardTabSystem { content.mainTab, content.recipeScanTab, content.craftQueueTab, content.specInfoTab }
end

function CraftSim.DEBUG.FRAMES:InitModuleToolsMainTab(mainTab)
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
end

function CraftSim.DEBUG.FRAMES:InitModuleToolsRecipeScanTab(recipeScanTab)
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

function CraftSim.DEBUG.FRAMES:InitModuleToolsCraftQueueTab(craftQueueTab)
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

function CraftSim.DEBUG.FRAMES:InitModuleToolsSpecInfoTab(specInfoTab)
    local content = specInfoTab.content

    content.nodeDebugInput = GGUI.TextInput {
        parent = content, anchorParent = content,
        anchorA = "TOP", anchorB = "TOP", offsetX = -50, offsetY = -40, sizeX = 120, sizeY = 20,
    }

    content.debugNodeButton = GGUI.Button({
        label = "Debug Node",
        parent = content,
        anchorParent = content.nodeDebugInput.frame,
        anchorA = "LEFT",
        anchorB = "RIGHT",
        sizeX = 15,
        sizeY = 25,
        adjustWidth = true,
        clickCallback = function()
            local nodeIdentifier = content.nodeDebugInput:GetText()
            CraftSim.DEBUG:CheckSpecNode(nodeIdentifier)
        end,
        offsetX = 10,
    })


    content.compareData = GGUI.Button({
        label = "Compare UI/Spec Data",
        parent = content,
        anchorParent = content.nodeDebugInput.frame,
        anchorA = "TOPLEFT",
        anchorB = "TOPLEFT",
        sizeX = 15,
        sizeY = 25,
        adjustWidth = true,
        clickCallback = function()
            CraftSim.DEBUG:CompareStatData()
        end,
        offsetX = -5,
        offsetY = -25,
    })
end
