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
    local sizeX = 700
    local sizeY = 550
    ---@class CraftSim.DEBUG.FRAME : GGUI.Frame
    local debugFrame = GGUI.Frame({
        anchorA = "BOTTOMRIGHT",
        anchorB = "BOTTOMRIGHT",
        sizeX = sizeX,
        sizeY = sizeY,
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
    local registeredDebugIDs = CraftSim.DEBUG:GetRegisteredDebugIDs()

    debugFrame.content.optionsButton = CraftSim.WIDGETS.OptionsButton {
        parent = debugFrame.frame,
        anchorPoints = { {
            anchorParent = debugFrame.title.frame,
            anchorA = "LEFT", anchorB = "RIGHT", offsetX = 5,
        } },
        menuUtilCallback = function(ownerRegion, rootDescription)
            local logIDs = rootDescription:CreateButton("Log IDs")

            -- dynamically create logid checkboxes use . as delimiter for categories
            local buttonCache = {}

            for _, debugID in pairs(registeredDebugIDs) do
                local splitIDs = strsplittable(".", debugID)
                local fullID = ""
                for i, splitID in ipairs(splitIDs) do
                    local previousButton
                    if i == 1 then
                        fullID = splitID
                        previousButton = logIDs
                    else
                        local previousID = fullID
                        previousButton = buttonCache[previousID]
                        fullID = string.format("%s.%s", previousID, splitID)
                    end

                    local capturedID = fullID
                    buttonCache[capturedID] = buttonCache[capturedID] or
                        previousButton:CreateCheckbox(splitID, function()
                            return debugIDTable[capturedID]
                        end, function()
                            debugIDTable[capturedID] = not debugIDTable[capturedID]
                        end)
                end
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

            rootDescription:CreateButton(f.r("Disable All"), function()
                CraftSim.DEBUG:DisableAllLogIDs()
            end)

            rootDescription:CreateButton(f.l("Clear"), function()
                CraftSim.DEBUG.frame.content.logBox:Clear()
                wipe(CraftSim.DEBUG.frame.logBuffer)
            end)

            rootDescription:CreateButton(f.bb("Copy All"), function()
                CraftSim.DEBUG.UI:ShowCopyPopup(CraftSim.DEBUG.frame)
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

    debugFrame.logBuffer = {}

    debugFrame.content.logBox = GGUI.ScrollingMessageFrame {
        parent = debugFrame.content,
        anchorParent = debugFrame.content,
        anchorA = "TOP", anchorB = "TOP", offsetY = -35, offsetX = 0,
        enableScrolling = true,
        showScrollBar = true,
        maxLines = 100000,
        sizeX = 650,
        sizeY = 500,
        justifyOptions = { type = "H", align = "LEFT" },
        copyable = true,
    }

    debugFrame.content.logBox:EnableHyperLinksForFrameAndChilds()

    debugFrame.addDebug = function(debugOutput, debugID, printLabel)
        if debugFrame:IsVisible() then
            local line
            if printLabel then
                line = "\n- " .. debugID .. ":\n" .. tostring(debugOutput)
            else
                line = "\n" .. tostring(debugOutput)
            end
            debugFrame.content.logBox:AddMessage(line)
            tinsert(debugFrame.logBuffer, line)
        end
    end

    CraftSim.DEBUG.UI:InitControlPanel(debugFrame)

    GGUI:EnableHyperLinksForFrameAndChilds(debugFrame.content)
end

function CraftSim.DEBUG.UI:ShowCopyPopup(debugFrame)
    if not debugFrame.copyPopup then
        local popup = CreateFrame("Frame", nil, UIParent, "BasicFrameTemplateWithInset")
        popup:SetSize(600, 450)
        popup:SetPoint("CENTER")
        popup:SetMovable(true)
        popup:EnableMouse(true)
        popup:RegisterForDrag("LeftButton")
        popup:SetScript("OnDragStart", popup.StartMoving)
        popup:SetScript("OnDragStop", popup.StopMovingOrSizing)
        popup:SetFrameStrata("DIALOG")

        local title = popup:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        title:SetPoint("TOP", popup, "TOP", 0, -8)
        title:SetText("Debug Log — Select All (Ctrl+A) then Copy (Ctrl+C)")

        local scrollFrame = CreateFrame("ScrollFrame", nil, popup, "UIPanelScrollFrameTemplate")
        scrollFrame:SetPoint("TOPLEFT", popup, "TOPLEFT", 10, -30)
        scrollFrame:SetPoint("BOTTOMRIGHT", popup, "BOTTOMRIGHT", -30, 10)

        local editBox = CreateFrame("EditBox", nil, scrollFrame)
        editBox:SetMultiLine(true)
        editBox:SetFontObject(ChatFontNormal)
        editBox:SetWidth(540)
        editBox:SetAutoFocus(false)
        editBox:SetScript("OnEscapePressed", function() popup:Hide() end)
        editBox:SetScript("OnShow", function(self)
            self:SetFocus()
            self:HighlightText()
        end)
        scrollFrame:SetScrollChild(editBox)

        popup.editBox = editBox
        debugFrame.copyPopup = popup
    end

    local fullText = table.concat(debugFrame.logBuffer)
    debugFrame.copyPopup.editBox:SetText(fullText)
    debugFrame.copyPopup.editBox:HighlightText()
    debugFrame.copyPopup:Show()
    debugFrame.copyPopup.editBox:SetFocus()
end

function CraftSim.DEBUG.UI:InitControlPanel(debugFrame)
    ---@class CraftSim.DEBUG.FRAME.CONTROL_PANEL : GGUI.Frame
    local controlPanel = GGUI.Frame({
        parent = debugFrame.frame,
        anchorParent = debugFrame.frame,
        anchorA = "TOPRIGHT",
        anchorB = "TOPLEFT",
        title = "CraftSim Debug Tools",
        offsetX = 10,
        sizeX = 200,
        sizeY = 550,
        backdropOptions = CraftSim.CONST.DEFAULT_BACKDROP_OPTIONS,
        frameTable = CraftSim.INIT.FRAMES,
        frameConfigTable = CraftSim.DB.OPTIONS:Get("GGUI_CONFIG"),
    })

    ---@class CraftSim.DEBUG.FRAME.CONTROL_PANEL.CONTENT : Frame
    local content = controlPanel.content

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
                local recipeData = CraftSim.MODULES.recipeData
                if recipeData then
                    CraftSim.DEBUG:InspectTable(recipeData, string.format("Open Recipe (%s)", recipeData.recipeName),
                        true)
                end
            end)

            openRecipe:CreateButton("Inspect SpecializationData", function()
                local recipeData = CraftSim.MODULES.recipeData
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

            craftQueue:CreateButton("Inspect CraftQueue.QuickBuyCache", function()
                CraftSim.DEBUG:InspectTable(CraftSim.CRAFTQ.quickBuyCache, "QuickBuyCache", true)
            end)

            local craftLog = rootDescription:CreateButton("CraftLog")

            craftLog:CreateButton("Inspect CraftSessionData", function()
                if CraftSim.CRAFT_LOG.currentSessionData then
                    CraftSim.DEBUG:InspectTable(CraftSim.CRAFT_LOG.currentSessionData, "CraftSessionData", true)
                end
            end)

            craftLog:CreateButton("Inspect Open CraftRecipeData", function()
                if CraftSim.CRAFT_LOG.currentSessionData and CraftSim.MODULES.recipeData then
                    local craftRecipeData = CraftSim.CRAFT_LOG.currentSessionData:GetCraftRecipeData(CraftSim.INIT
                        .currentRecipeData.recipeID)
                    if craftRecipeData then
                        CraftSim.DEBUG:InspectTable(craftRecipeData,
                            string.format("CraftRecipeData (%s)", CraftSim.MODULES.recipeData.recipeName), true)
                    end
                end
            end)
        end
    }

    content.dbDebugTools = GGUI.FilterButton {
        label = "Database",
        parent = content,
        anchorPoints = { {
            anchorParent = content.moduleDebugTools.frame, anchorA = "TOP", anchorB = "BOTTOM", offsetY = -5,
        } },
        sizeX = 160, sizeY = 23,
        menuUtilCallback = function(ownerRegion, rootDescription)
            local clearDBs = rootDescription:CreateButton("Clear Database")
            clearDBs:CreateButton("User Configurations", function()
                CraftSim.DB.OPTIONS:ClearAll()
            end)

            clearDBs:CreateButton("Crafter Data", function()
                CraftSim.DB.CRAFTER:ClearAll()
            end)

            clearDBs:CreateButton("Customer History", function()
                CraftSim.DB.CUSTOMER_HISTORY:ClearAll()
            end)

            clearDBs:CreateButton("Item Count Cache", function()
                CraftSim.DB.ITEM_COUNT:ClearAll()
            end)

            clearDBs:CreateButton("Price Overrides", function()
                CraftSim.DB.PRICE_OVERRIDE:ClearAll()
            end)

            clearDBs:CreateButton("Recipe Sub Crafter Data", function()
                CraftSim.DB.RECIPE_SUB_CRAFTER:ClearAll()
            end)

            local resetDBVersions = rootDescription:CreateButton("Reset DB Versions")
            local repositories = CraftSim.DB.repositories
            for _, repository in ipairs(repositories) do
                local version = repository.db.version
                if version > 0 then
                    resetDBVersions:CreateButton(
                        repository.name .. " " .. repository.db.version .. " -> " .. (repository.db.version - 1),
                        function()
                            repository.db.version = version - 1
                            CraftSim.DEBUG:SystemPrint(f.l(string.format("CraftSim DB Version for %s set to %d",
                                repository.name, repository.db.version)))
                        end)
                end
            end

            rootDescription:CreateButton(f.r("Factory Reset"), function()
                GGUI:ShowPopup {
                    title = "CraftSim " .. f.r("Factory Reset"),
                    text = "This will delete\n\n" .. f.r("ALL") .. "\n\ndata and configurations\nand reload your interface. Are you sure?",
                    sizeY = 200,
                    onAccept = function()
                        CraftSimDB = nil
                        C_UI.Reload()
                    end
                }
            end)
        end
    }
end
