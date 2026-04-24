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
    ---@class CraftSim.DEBUG.FRAME : GGUI.Frame
    local debugFrame = GGUI.Frame({
        parent = UIParent,
        anchorParent = UIParent,
        anchorA = "BOTTOMRIGHT",
        anchorB = "BOTTOMRIGHT",
        closeable = true,
        moveable = true,
        title = "CraftSim Debug Tools",
        sizeX = 220,
        sizeY = 200,
        backdropOptions = CraftSim.CONST.DEFAULT_BACKDROP_OPTIONS,
        frameConfigTable = CraftSim.DB.OPTIONS:Get("GGUI_CONFIG"),
        frameStrata = CraftSim.CONST.MODULES_FRAME_STRATA,
        raiseOnInteraction = true,
        frameLevel = 50,
    })

    CraftSim.DEBUG.frame = debugFrame

    CraftSim.DEBUG.UI:InitDebugFrame(debugFrame)
end

---@param debugFrame GGUI.Frame
function CraftSim.DEBUG.UI:InitDebugFrame(debugFrame)
    CraftSim.FRAME:ToggleFrame(debugFrame, CraftSim.DB.OPTIONS:Get("DEBUG_VISIBLE"))

    debugFrame:SetVisible(CraftSim.DB.OPTIONS:Get("DEBUG_VISIBLE"))

    debugFrame:HookScript("OnShow", function() CraftSim.DB.OPTIONS:Save("DEBUG_VISIBLE", true) end)
    debugFrame:HookScript("OnHide", function() CraftSim.DB.OPTIONS:Save("DEBUG_VISIBLE", false) end)

    ---@class CraftSim.DEBUG.FRAME.CONTROL_PANEL.CONTENT : Frame
    local content = debugFrame.content

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
                    local craftRecipeData = CraftSim.CRAFT_LOG.currentSessionData:GetCraftRecipeData(CraftSim.MODULES
                        .recipeData.recipeID)
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
            local clearDBs = rootDescription:CreateButton("Wipe Database")
            local resetDBVersions = rootDescription:CreateButton("Reset DB Versions")
            local repositories = CraftSim.DB.repositories
            for _, repository in ipairs(repositories) do
                local version = repository.db.version
                if version > 0 then
                    clearDBs:CreateButton(repository.name, function()
                        repository:ClearAll()
                    end)
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

    content.logTools = GGUI.Button {
        label = "View Logs",
        parent = content,
        macro = true,
        macroText = "/logs",

        anchorPoints = { {
            anchorParent = content.dbDebugTools.frame, anchorA = "TOP", anchorB = "BOTTOM", offsetY = -5,
        } },
        sizeX = 160, sizeY = 23,
        tooltipOptions = {
            anchor = "ANCHOR_TOP",
            text = "View logs using " .. f.bb("LogSink: Table") .. " addon",
        },
    }

    content.logOptions = CraftSim.WIDGETS.OptionsButton {
        parent = content,
        anchorPoints = { {
            anchorParent = content.logTools.frame, anchorA = "LEFT", anchorB = "RIGHT", offsetX = 5,
        } },
        menuUtilCallback = function(ownerRegion, rootDescription)
            rootDescription:CreateCheckbox("Log Events to DevTool", function()
                return CraftSim.DB.OPTIONS:Get("EVENT_DEV_TOOL_LOGGING_ENABLED")
            end, function()
                local newValue = not CraftSim.DB.OPTIONS:Get("EVENT_DEV_TOOL_LOGGING_ENABLED")
                CraftSim.DB.OPTIONS:Save("EVENT_DEV_TOOL_LOGGING_ENABLED", newValue)
                GUTIL:SetEventDevToolLogging(newValue)
            end)

            ---@type table<number, string>
            local logLevelsSorted = {}
            for key, value in pairs(CraftSim.LibLog.LogLevel) do
                logLevelsSorted[value] = key
            end
            for i = 0, 6 do
                local loglevel = logLevelsSorted[i]
                rootDescription:CreateRadio(loglevel, function()
                    return CraftSim.DB.OPTIONS:Get("DEBUG_MINIMUM_LOG_LEVEL") == i
                end, function()
                    CraftSim.DEBUG:SetMinimumLogLevel(i)
                    CraftSim.DB.OPTIONS:Save("DEBUG_MINIMUM_LOG_LEVEL", i)
                    return MenuResponse.Refresh
                end)
            end
        end
    }
end
