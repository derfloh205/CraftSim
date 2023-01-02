addonName, CraftSim = ...

CraftSim_DEBUG = {}

function CraftSim_DEBUG:PrintRecipeIDs()
    local recipeInfo = ProfessionsFrame.CraftingPage.SchematicForm:GetRecipeInfo()
    local itemID = CraftSim.UTIL:GetItemIDByLink(recipeInfo.hyperlink)
    local itemName, itemLink, itemQuality, itemLevel, itemMinLevel, itemType, itemSubType,
    itemStackCount, itemEquipLoc, itemTexture, sellPrice, classID, subclassID, bindType,
    expacID, setID, isCraftingReagent
    = GetItemInfo(itemID) 
    local data = C_TradeSkillUI.GetCategoryInfo(recipeInfo.categoryID)

    print("--")
    print("RecipeID: " .. recipeInfo.recipeID)
    print("SubTypeID: " .. subclassID)
    print("SubType: " .. itemSubType)
    print("Category: " .. data.name)
    print("ID: " .. recipeInfo.categoryID)
end

function CraftSim_DEBUG:CheckSpecNode(nodeID)
    local professionID = CraftSim.MAIN.currentRecipeData.professionID
    local recipeData = CraftSim.MAIN.currentRecipeData

    if not recipeData or not recipeData.specNodeData then
        print("CraftSim Debug Error: No recipeData or not specNodeData")
        return
    end

    local professionNodes = CraftSim.SPEC_DATA:GetNodes(professionID)
    local debugNode = CraftSim.UTIL:FilterTable(professionNodes, function(node) 
        return node.nodeID == nodeID
    end)
    print("Debug Node: " .. tostring(debugNode[1].name))

    local ruleNodes = CraftSim.SPEC_DATA.RULE_NODES()[professionID]

    local statsFromData = CraftSim.SPEC_DATA:GetStatsFromSpecNodeData(recipeData, ruleNodes, nodeID, true)

    print("Stats from node: ")
    CraftSim.UTIL:PrintTable(statsFromData, true)
end