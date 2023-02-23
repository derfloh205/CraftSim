AddonName, CraftSim = ...

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
        itemID = CraftSim.UTIL:GetItemIDByLink(recipeInfo.hyperlink)
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
            local debugFrame = CraftSim.FRAME:GetFrame(CraftSim.CONST.FRAMES.DEBUG)
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
    })

    testFrame.content.testIcon = CraftSim.GGUI.Icon({
        parent=testFrame.content,
        anchorParent=testFrame.content,
        anchorA="TOP",
        anchorB="TOP",
        offsetY=-50
    })

    local testID = 191500
    testFrame.content.testIcon:SetItem(testID)
end