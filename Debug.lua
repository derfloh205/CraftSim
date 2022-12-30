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