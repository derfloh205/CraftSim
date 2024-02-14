---@class CraftSim
local CraftSim = select(2, ...)

---@class CraftSim.DEBUG
CraftSim.DEBUG = CraftSim.DEBUG

---@class CraftSim.DEBUG.TEST
CraftSim.DEBUG.TEST = {}

local GUTIL = CraftSim.GUTIL
local GGUI = CraftSim.GGUI

function CraftSim.DEBUG.TEST:CachedRecipesTest()
    for crafter, professions in pairs(CraftSimRecipeDataCache.cachedRecipeIDs) do
        print("Recipes from: " .. tostring(crafter))
        local name, realm = strsplit("-", crafter)
        for _, recipeIDs in pairs(professions) do
            for _, recipeID in pairs(recipeIDs) do
                local recipeData = CraftSim.RecipeData(recipeID, nil, nil, { name = name, realm = realm })

                recipeData:OptimizeProfit({
                    optimizeGear = true,
                    optimizeReagents = true,
                })

                recipeData:Update()

                print("- " ..
                    tostring(recipeData.recipeName) .. ": " .. GUTIL:FormatMoney(recipeData.averageProfitCached, true))

                DevTool:AddData(recipeData, recipeData.recipeName)
            end
        end
    end
end

function CraftSim.DEBUG.TEST:FrameDistributedIterationTest()
    local someTable = {}

    for i = 1, 1000 do
        someTable["someKey" .. i] = {
            someValue = i
        }
    end

    CraftSim.GUTIL:FrameDistributedIteration(someTable, function(key, value)
            print("Hello from " .. tostring(key) .. ": " .. tostring(value.someValue))

            if IsMouseButtonDown("LeftButton") then
                print("command to stop!")
                return false
            end
        end,
        function()
            print("I am finally finished!")
        end, 300, 1000)
end

---@param duplicateAmount number
---@param tip number
function CraftSim.DEBUG.TEST:DuplicateTestDataForCustomerHistoryLegacy(duplicateAmount, tip)
    tip = tip or 0
    local playerRealm = GetRealmName()
    if CraftSimCustomerHistory and CraftSimCustomerHistory.realm and CraftSimCustomerHistory.realm[playerRealm] then
        ---@type table<string, CraftSim.CustomerHistory.Legacy>
        local realmData = CraftSimCustomerHistory.realm[playerRealm]
        for customerKey, customerHistory in pairs(realmData) do
            if type(customerHistory) == 'table' then
                -- multiply chatHistory and craftHistory to the 200 to generate some data
                if customerHistory.history and #customerHistory.history > 1 then
                    local chatHistoryEntry = CraftSim.GUTIL:Find(customerHistory.history,
                        function(h) return h.from or h.to end)
                    ---@type CraftSim.CustomerHistory.Craft.Legacy
                    local craftHistoryEntry = CraftSim.GUTIL:Find(customerHistory.history,
                        function(h) return h.crafted end)
                    customerHistory.history = {}
                    craftHistoryEntry.commission = 0
                    craftHistoryEntry.timestamp = 1702625675325
                    while #customerHistory.history < 200 do
                        table.insert(customerHistory.history, chatHistoryEntry)
                        table.insert(customerHistory.history, craftHistoryEntry)
                    end
                end

                -- then take this history and put it into the history the given amount of time
                CraftSimCustomerHistory.realm[playerRealm] = {}
                local tipAlternator = 5
                for i = 1, duplicateAmount do
                    local newKey = "Customer" .. i .. "-" .. playerRealm
                    ---@type CraftSim.CustomerHistory.Legacy
                    CraftSimCustomerHistory.realm[playerRealm][newKey] = CopyTable(customerHistory)

                    if i % tipAlternator == 0 then
                        local firstCraft, index = CraftSim.GUTIL:Find(
                            CraftSimCustomerHistory.realm[playerRealm][newKey].history, function(h) return h.crafted end)
                        local craft = CopyTable(firstCraft)
                        craft.commission = tip
                        CraftSimCustomerHistory.realm[playerRealm][newKey].history[index] = craft
                    end
                end

                DevTool:AddData(recipeData, recipeData.recipeName)
            end
        end
    end
end

function CraftSim.DEBUG.TEST:GGUITest()
    local testFrame = CraftSim.GGUI.Frame({
        title = "DEBUG TEST",
        sizeX = 300,
        sizeY = 300,
        backdropOptions = {
            bgFile = "Interface\\CharacterFrame\\UI-Party-Background",
        },
        closeable = true,
        collapseable = true,
        moveable = true,
        scrollableContent = true,
        frameTable = CraftSim.MAIN.FRAMES,
        frameConfigTable = CraftSimGGUIConfig,
    })

    local testIcon = CraftSim.GGUI.Icon({
        parent = testFrame.content,
        anchorParent = testFrame.content,
        anchorA = "TOP",
        anchorB = "TOP",
        offsetY = -50
    })

    local testID = 191500
    testIcon:SetItem(testID)


    local testDropdown = CraftSim.GGUI.Dropdown({
        parent = testFrame.content,
        anchorParent = testIcon.frame,
        anchorA = "TOP",
        anchorB = "BOTTOM",
        initialData = { { label = "Test1", value = 1 }, { label = "Test2", value = 2 }, { label = "TestCategory", isCategory = true, value = { { label = "Test1", value = { someTable = 1 } }, { label = "Test2", value = 2 } } } },
        clickCallback = function(_, label, value)
            print("clicked on: " ..
                tostring(label) .. " with value " .. tostring(value))
        end
    })

    local testText = CraftSim.GGUI.Text({
        parent = testFrame.content,
        anchorParent = testDropdown.frame,
        anchorA = "TOP",
        anchorB = "BOTTOM",
        offsetY = -10,
        text = "Test!!!"
    })

    local testButton = CraftSim.GGUI.Button({
        parent = testFrame.content,
        anchorParent = testText.frame,
        anchorA = "TOP",
        anchorB = "BOTTOM",
        label = "Test Button 1",
        adjustWidth = true,
        initialStatusID = "1",
        clickCallback = function(button)
            local statusID = button:GetStatus()
            if statusID == "1" then
                button:SetStatus("2")
            elseif statusID == "2" then
                button:SetStatus("3")
            elseif statusID == "3" then
                button:SetStatus("4")
            elseif statusID == "4" then
                button:SetStatus("1")
            end
        end,
    })

    testButton:SetStatusList({
        {
            statusID = "1",
            anchorA = "TOP",
            anchorB = "BOTTOM",
            label = "Test Button 1",
        },
        {
            statusID = "2",
            anchorA = "LEFT",
            anchorB = "RIGHT",
            label = "Test Button 2",
        },
        {
            statusID = "3",
            anchorA = "BOTTOM",
            anchorB = "TOP",
            label = "Test Button 3",
        },
        {
            statusID = "4",
            anchorA = "RIGHT",
            anchorB = "LEFT",
            label = "Test Button 4",
        },
    })

    local numericInput = CraftSim.GGUI.NumericInput({
        parent = testFrame.frame,
        anchorParent = testButton.frame,
        anchorA = "TOP",
        anchorB = "BOTTOM",
        incrementOneButtons = true,
        maxValue = 10,
        minValue = 0,
        borderAdjustWidth = 0.95,
        borderWidth = 25,
    })
end

function CraftSim.DEBUG.TEST:TestAllocationSkillFetchV2()
    CraftSim.REAGENT_OPTIMIZATION:GetCurrentReagentAllocationSkillIncrease(CraftSim.MAIN.currentRecipeData)
end

function CraftSim.DEBUG.TEST:TestAllocationSkillFetchV1()
    local skillIncrease = CraftSim.REAGENT_OPTIMIZATION:GetCurrentReagentAllocationSkillIncreaseOLD(CraftSim.MAIN
        .currentRecipeData)
    print("Skill Increase: " .. tostring(skillIncrease))
end

function CraftSim.DEBUG.TEST:TestMaxReagentIncreaseFactor()
    print("Factor: " .. CraftSim.REAGENT_OPTIMIZATION:GetMaxReagentIncreaseFactor(CraftSim.MAIN.currentRecipeData))
end
