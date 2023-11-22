CraftSimAddonName, CraftSim = ...

CraftSim_DEBUG = {}

CraftSim_DEBUG.isMute = false

function CraftSim_DEBUG:PrintRecipeIDs(recipeID)
    recipeID = recipeID or CraftSim.MAIN.currentRecipeData.recipeID
    local recipeInfo = C_TradeSkillUI.GetRecipeInfo(recipeID)

    if not recipeInfo then
        print("No RecipeInfo found")
        return
    end

    local itemID = nil
    if recipeInfo.isEnchantingRecipe then
        local enchantOutput = CraftSim.ENCHANT_RECIPE_DATA[recipeInfo.recipeID]
        if enchantOutput then
            itemID = CraftSim.ENCHANT_RECIPE_DATA[recipeInfo.recipeID].q1
        else
            print("no output for enchanting recipe found")
            return
        end
    else
        itemID = CraftSim.GUTIL:GetItemIDByLink(recipeInfo.hyperlink)
    end
    local itemName, itemLink, itemQuality, itemLevel, itemMinLevel, itemType, itemSubType,
    itemStackCount, itemEquipLoc, itemTexture, sellPrice, classID, subclassID, bindType,
    expacID, setID, isCraftingReagent
    = GetItemInfo(itemID) 
    ---@diagnostic disable-next-line: missing-parameter
    local data = C_TradeSkillUI.GetCategoryInfo(recipeInfo.categoryID)

    print("--")
    print("RecipeID: " .. recipeInfo.recipeID)
    print("ItemLevel: " .. tostring(recipeInfo.itemLevel))
    print("SubTypeID: " .. subclassID)
    print("SubType: " .. itemSubType)
    print("Category: " .. data.name)
    print("ID: " .. recipeInfo.categoryID)
    print("ParentCategoryID: " .. tostring(data.parentCategoryID))
    print("ParentSectionID: " .. tostring(data.parentSectionID))
end

function CraftSim_DEBUG:CompareStatData()
    local function print(text, r, l) -- override
        CraftSim_DEBUG:print(text, CraftSim.CONST.DEBUG_IDS.SPECDATA, r, l)
    end
    
end

function CraftSim_DEBUG:TestAllocationSkillFetchV2()
    CraftSim.REAGENT_OPTIMIZATION:GetCurrentReagentAllocationSkillIncrease(CraftSim.MAIN.currentRecipeData)
end
function CraftSim_DEBUG:TestAllocationSkillFetchV1()
    local skillIncrease = CraftSim.REAGENT_OPTIMIZATION:GetCurrentReagentAllocationSkillIncreaseOLD(CraftSim.MAIN.currentRecipeData)
    print("Skill Increase: " .. tostring(skillIncrease))
end

function CraftSim_DEBUG:TestMaxReagentIncreaseFactor()
   print("Factor: " .. CraftSim.REAGENT_OPTIMIZATION:GetMaxReagentIncreaseFactor(CraftSim.MAIN.currentRecipeData))
end

function CraftSim_DEBUG:CheckSpecNode(nodeID)

    local function print(text, r, l) -- override
        CraftSim_DEBUG:print(text, CraftSim.CONST.DEBUG_IDS.SPECDATA, r, l)
    end

end

function CraftSim_DEBUG:print(debugOutput, debugID, recursive, printLabel, level)
    if CraftSimOptions["enableDebugID_" .. debugID] and not CraftSim_DEBUG.isMute then
        if type(debugOutput) == "table" then
            CraftSim.UTIL:PrintTable(debugOutput, debugID, recursive, level)
        else
            local debugFrame = CraftSim.GGUI:GetFrame(CraftSim.MAIN.FRAMES, CraftSim.CONST.FRAMES.DEBUG)
            debugFrame.addDebug(debugOutput, debugID, printLabel)
        end
    end
end

---This is an example for the usage of CraftSim's recipeData Object. It will most like
---@param recipeID any
function CraftSim_DEBUG:exampleAPIUsage(recipeID)
    local print = CraftSim.UTIL:SetDebugPrint(CraftSim.CONST.DEBUG_IDS.DATAEXPORT)
    local recipeData = CraftSim.RecipeData(recipeID)
    
    local reagentList = { -- draconium ore q1 q2 q3
        {
            itemID = 189143,
            quantity = 0,
        },
        {
            itemID = 188658,
            quantity = 0,
        },
        {
            itemID = 190311,
            quantity = 0,
        },
        { -- khaz ore q3
            itemID = 190314,
            quantity = 0,
        },
    }

    recipeData:SetReagents(reagentList)
    print("Reagent Data:")
    print(recipeData.reagentData)
    recipeData:SetOptionalReagent(191513) -- stable fluid draconium Q3 = 25% more inspiration skill
    recipeData:UpdateProfessionStats()
    recipeData.resultData:Update()

    print("ResultData: ")
    print(recipeData.resultData)

    print("Skill: " .. recipeData.professionStats.skill.value)
    print("Inspiration Skill: " .. recipeData.professionStats.inspiration.extraValue)

    recipeData.priceData:Update()

    print(recipeData.priceData)
end

function CraftSim_DEBUG:GGUITest()
    local testFrame = CraftSim.GGUI.Frame({
        title="DEBUG TEST",
        sizeX= 300,
        sizeY= 300,
        backdropOptions = {
            bgFile="Interface\\CharacterFrame\\UI-Party-Background",
        },
        closeable=true,
        collapseable=true,
        moveable=true,
        scrollableContent=true,
        frameTable=CraftSim.MAIN.FRAMES,
        frameConfigTable=CraftSimGGUIConfig,
    })

    local testIcon = CraftSim.GGUI.Icon({
        parent=testFrame.content,
        anchorParent=testFrame.content,
        anchorA="TOP",
        anchorB="TOP",
        offsetY=-50
    })

    local testID = 191500
    testIcon:SetItem(testID)


    local testDropdown = CraftSim.GGUI.Dropdown({
        parent=testFrame.content,
        anchorParent=testIcon.frame,
        anchorA="TOP",
        anchorB="BOTTOM",
        initialData= {{label="Test1", value=1}, {label="Test2", value=2}, {label="TestCategory", isCategory=true, value={{label="Test1", value={someTable=1}}, {label="Test2", value=2}}}},
        clickCallback = function(_, label, value) print("clicked on: " .. tostring(label) .. " with value " .. tostring(value)) end
    })

    local testText = CraftSim.GGUI.Text({
        parent=testFrame.content,
        anchorParent=testDropdown.frame,
        anchorA="TOP",
        anchorB="BOTTOM",
        offsetY=-10,
        text="Test!!!"
    })

    local testButton = CraftSim.GGUI.Button({
        parent=testFrame.content,
        anchorParent=testText.frame,
        anchorA="TOP",
        anchorB="BOTTOM",
        label="Test Button 1",
        adjustWidth=true,
        initialStatusID="1",
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
            statusID="1",
            anchorA="TOP",
            anchorB="BOTTOM",
            label="Test Button 1",
        },
        {
            statusID="2",
            anchorA="LEFT",
            anchorB="RIGHT",
            label="Test Button 2",
        },
        {
            statusID="3",
            anchorA="BOTTOM",
            anchorB="TOP",
            label="Test Button 3",
        },
        {
            statusID="4",
            anchorA="RIGHT",
            anchorB="LEFT",
            label="Test Button 4",
        },
    })

    local numericInput = CraftSim.GGUI.NumericInput({
        parent=testFrame.frame,
        anchorParent=testButton.frame,
        anchorA="TOP",
        anchorB="BOTTOM",
        incrementOneButtons=true,
        maxValue=10,
        minValue=0,
        borderAdjustWidth=0.95,
        borderWidth=25,
    })


end