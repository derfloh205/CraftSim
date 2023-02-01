AddonName, CraftSim = ...

CraftSim_DEBUG = {}

CraftSim_DEBUG.isMute = false

function CraftSim_DEBUG:PrintRecipeIDs()
    local recipeInfo = ProfessionsFrame.CraftingPage.SchematicForm:GetRecipeInfo()
    local itemID = CraftSim.ENCHANT_RECIPE_DATA[recipeInfo.recipeID]
    if recipeInfo.isEnchantingRecipe then
         itemID = CraftSim.ENCHANT_RECIPE_DATA[recipeInfo.recipeID].q1
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
    CraftSim_DEBUG.isMute = true
    local exportMode = ProfessionsFrame.OrdersPage:IsVisible() and CraftSim.CONST.EXPORT_MODE.WORK_ORDER or CraftSim.CONST.EXPORT_MODE.NON_WORK_ORDER
    local recipeDataV1 = CraftSim.DATAEXPORT:exportRecipeData(CraftSim.MAIN.currentRecipeID, exportMode)
    if not recipeDataV1 then
        CraftSim_DEBUG.isMute = false
        print("No recipe opened", false, true)
        return
    end
    local recipeDataV2 = CopyTable(recipeDataV1)
    local statsUI =  CraftSim.DATAEXPORT:handlePlayerProfessionStatsV1(recipeDataV1, recipeDataV1.operationInfo)
    local statsBuildUp =  CraftSim.DATAEXPORT:handlePlayerProfessionStatsV2(recipeDataV1, recipeDataV1.operationInfo)

    CraftSim_DEBUG.isMute = false
    print("Stat Compare - UI / Specdata:", false, true)
    print("Total Skill: " .. tostring(recipeDataV1.stats.skill) .. " / " .. tostring(recipeDataV2.stats.skill))
    print("Skill No Reagents: " .. tostring(recipeDataV1.stats.skillNoReagents) .. " / " .. tostring(recipeDataV2.stats.skillNoReagents))
    print("Skill No Items: " .. tostring(recipeDataV1.stats.skillNoItems) .. " / " .. tostring(recipeDataV2.stats.skillNoItems))
    if recipeDataV1.stats.inspiration then
        print("Inspiration: " .. tostring(recipeDataV1.stats.inspiration.value) .. " / " .. tostring(recipeDataV2.stats.inspiration.value))
        print("Inspiration %: " .. tostring(recipeDataV1.stats.inspiration.percent) .. " / " .. tostring(recipeDataV2.stats.inspiration.percent))
        print("Inspiration Skill: " .. tostring(recipeDataV1.stats.inspiration.bonusskill) .. " / " .. tostring(recipeDataV2.stats.inspiration.bonusskill))
    end
    if recipeDataV1.stats.multicraft then
        print("Multicraft: " .. tostring(recipeDataV1.stats.multicraft.value) .. " / " .. tostring(recipeDataV2.stats.multicraft.value))
        print("Multicraft %: " .. tostring(recipeDataV1.stats.multicraft.percent) .. " / " .. tostring(recipeDataV2.stats.multicraft.percent))
    end
    if recipeDataV1.stats.resourcefulness then
        print("Resourcefulness: " .. tostring(recipeDataV1.stats.resourcefulness.value) .. " / " .. tostring(recipeDataV2.stats.resourcefulness.value))
        print("Resourcefulness %: " .. tostring(recipeDataV1.stats.resourcefulness.percent) .. " / " .. tostring(recipeDataV2.stats.resourcefulness.percent))
    end
    if recipeDataV1.stats.craftingspeed then
        print("CraftingSpeed: " .. tostring(recipeDataV1.stats.craftingspeed.value) .. " / " .. tostring(recipeDataV2.stats.craftingspeed.value))
        print("CraftingSpeed %: " .. tostring(recipeDataV1.stats.craftingspeed.percent) .. " / " .. tostring(recipeDataV2.stats.craftingspeed.percent))
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

    local recipeData = CraftSim.MAIN.currentRecipeData

    if not recipeData or not recipeData.specNodeData then
        print("CraftSim Debug Error: No recipeData or not specNodeData", false, true)
        return
    end
    
    local professionID = recipeData.professionID

    local professionNodes = CraftSim.SPEC_DATA:GetNodes(professionID)
    local ruleNodes = CraftSim.SPEC_DATA.RULE_NODES()[professionID]
    if type(nodeID) == "string" then
        local nodeEntry_1 = ruleNodes[nodeID]
        if not nodeEntry_1 then
            print("Error: node not found: " .. tostring(nodeID))
        end
        nodeID = ruleNodes[nodeID].nodeID
    end
    local debugNode = CraftSim.UTIL:FilterTable(professionNodes, function(node) 
        return node.nodeID == nodeID
    end)
    print("Debug Node: " .. tostring(debugNode[1].name), false, true)


    local statsFromData = CraftSim.SPEC_DATA:GetStatsFromSpecNodeData(recipeData, ruleNodes, nodeID, true)

    print("Stats from node: ")
    print(statsFromData, CraftSim.CONST.DEBUG_IDS.SPECDATA, true)
end

function CraftSim_DEBUG:print(debugOutput, debugID, recursive, printLabel)
    
    if CraftSimOptions["enableDebugID_" .. debugID] and not CraftSim_DEBUG.isMute then
        if type(debugOutput) == "table" then
            CraftSim.UTIL:PrintTable(debugOutput, debugID, recursive)
        else
            local debugFrame = CraftSim.FRAME:GetFrame(CraftSim.CONST.FRAMES.DEBUG)
            debugFrame.addDebug(debugOutput, debugID, printLabel)
        end
    end
end