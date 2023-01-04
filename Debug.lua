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

    local function print(text, r) -- override
        CraftSim_DEBUG:print(text, CraftSim.CONST.DEBUG_IDS.SPECDATA, r)
    end
    
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
    print(statsFromData, CraftSim.CONST.DEBUG_IDS.SPECDATA, true)
end

function CraftSim_DEBUG:print(debugOutput, debugID, recursive, noLabel)
    
    if CraftSimOptions["enableDebugID_" .. debugID] then
        if type(debugOutput) == "table" then
            CraftSim.UTIL:PrintTable(debugOutput, debugID, recursive)
        else
            local debugFrame = CraftSim.FRAME:GetFrame(CraftSim.CONST.FRAMES.DEBUG)
            debugFrame.addDebug(debugOutput, debugID, noLabel)
        end
    end
end