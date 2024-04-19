---@class CraftSim
local CraftSim = select(2, ...)

CraftSimAPI = {}

---Fetch a CraftSim.RecipeData instance for a recipeID
---@param recipeID number
---@param isRecraft? boolean
---@param isWorkOrder? boolean
---@param crafterData? CraftSim.CrafterData
---@return CraftSim.RecipeData recipeData
function CraftSimAPI:GetRecipeData(recipeID, isRecraft, isWorkOrder, crafterData)
    return CraftSim.RecipeData(recipeID, isRecraft, isWorkOrder, crafterData)
end

---Fetch the currently open CraftSim.RecipeData instance (or the last one opened if profession window was closed)
---@return CraftSim.RecipeData | nil
function CraftSimAPI:GetOpenRecipeData()
    return CraftSim.INIT.currentRecipeData
end

---Get the whole CraftSim addon table for whatever reason. Have Fun!
function CraftSimAPI:GetCraftSim()
    return CraftSim
end

---This is an example for the usage of CraftSim's recipeData Object.
---@param recipeID RecipeID
function CraftSimAPI:exampleAPIUsage(recipeID)
    local print = CraftSim.DEBUG:SetDebugPrint(CraftSim.CONST.DEBUG_IDS.DATAEXPORT)
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
