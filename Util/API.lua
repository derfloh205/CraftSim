_, CraftSim = ...

CraftSimAPI = {}

---@documentation https://wowpedia.fandom.com/wiki/Struct_CraftingReagentInfo
---@param callerID string The identifier of the calling instance (script, addon, ..)
---@param recipeID number The recipeID of a profession recipe
---@param requiredReagentsInfoTbl? CraftingReagentInfo[] A list of required crafting reagents
---@param optionalReagentsInfoTbl? CraftingReagentInfo[] A list of optional crafting reagents
---@param finishingReagentsInfoTbl? CraftingReagentInfo[] A list of finishing crafting reagents
---@return number averageProfit The expected profit of that recipe configuration based on the users price source
---@return table probabilityTable? The probability distribution of the recipe configuration {profit, chance}[]
function CraftSimAPI.GetAverageProfit(callerID, recipeID, requiredReagentsInfoTbl, optionalReagentsInfoTbl, finishingReagentsInfoTbl)
    if not callerID then
        error("CraftSim API Error: No CallerID specified")
    end

    if not recipeID then
        error("CraftSim API Error (Caller: " .. tostring(callerID) .. ") -> recipeID nil")
    end

    -- TODO: use pcall
    local recipeData = CraftSim.DATAEXPORT:exportRecipeData(recipeID, CraftSim.CONST.EXPORT_MODE.SCAN, 
        {scanReagents=requiredReagentsInfoTbl, optionalReagents=optionalReagentsInfoTbl, finishingReagents=finishingReagentsInfoTbl})

    if not recipeData then
        error("CraftSim API Error (Caller: " .. tostring(callerID) .. ") -> Could not export recipe data of recipeID: " .. tostring(recipeID))
    end
    
    local priceData = CraftSim.PRICEDATA:GetPriceData(recipeData, recipeData.recipeType)
    
    if not priceData then
        error("CraftSim API Error (Caller: " .. tostring(callerID) .. ") -> Could not export price data of recipeID: " .. tostring(recipeID))
    end

    local averageProfit, probabilityTable = CraftSim.CALC:getMeanProfit(recipeData, priceData)

    return averageProfit, probabilityTable
end