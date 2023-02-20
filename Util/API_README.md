# **CraftSim Ingame API**

## *CraftSimAPI:GetRecipeData(recipeID, isRecraft)*

This lets you fetch a RecipeData instance for a recipeID.
This object represents a recipe in CraftSim and offers various methods to manipulate the recipe or extract information from.
It is implemented in [RecipeData.lua](../Data/Classes/RecipeData.lua)

### recipeData:Update()

This processes all changes done to the recipeData and updates its resultData and professionStats.
It is important to call this after you change professionGearSet or reagentData. Some methods call it automatically.

### recipeData:OptimizeProfit(optimizeInspiration?: boolean)

Optimizes reagentData and professionGearSet in order to achieve the highest possible profit for this recipe. Automatically calls Update().

*optimizeInspiration* can be set to optimize for reaching the highest possible inspiration breakpoint.
Automatically calls Update()

### recipeData:GetAverageProfit()

Calculates the average profit based on professionGearSet, reagentData, resultData and professionStats. 

It has two return values. The first is the average profit in copper and the second is a table containing the 'Proc to Profit' probability distribution of the recipe.

### recipeData:OptimizeQuality(optimizeInspiration?: boolean)

Optimizes reagentData and professionGearSet in order to achieve the highest possible quality. 

*optimizeInspiration* can be set to optimize for reaching the highest possible inspiration breakpoint.
Automatically calls Update()

### recipeData:OptimizeGear(mode: string)

Optimizes professionGearSet based on the given mode. Automatically calls Update() if a better professionGearSet was set.
Possible modes are
- "Top Profit"
- "Top Skill"
- "Top Inspiration"
- "Top Multicraft"
- "Top Resourcefulness"
- "Top Crafting Speed"

### recipeData:OptimizeReagents(optimizeInspiration?: boolean)

Optimizes the quality based required reagents for highest achievable quality with lowest cost.

*optimizeInspiration* can be set to optimize for reaching the highest possible inspiration breakpoint.
Automatically calls Update()

### recipeData:SetAllReagentsBySchematicForm()

This sets all required and optional reagents based on the set reagents in the visible default blizzard crafting GUI.

### recipeData:SetOptionalReagents(itemIDList: number[])

Takes a list of itemIDs of optional reagents which will, if available, be set as active in the reagentData.
Automatically calls Update()

### recipeData:SetReagents(reagentList: ReagentListItem[])

Takes a list of *ReagentListItem* objects to set the required reagents of the recipe. Per default all quality based reagents are set to quantity 0 and all non quality reagents are set to their required quantity.

#### ReagentListItem
    {
        itemID: number,
        quantity: number
    }

### recipeData:SetEquippedProfessionGearSet()

Sets the recipeData's professionGearSet to the currently equipped profession gear for this recipe's profession.
Automatically calls Update()


### Example

An example that uses CraftSim's API to fetch a recipeData object, optimizes gear and reagents for profit (using inspiration breakpoints) and then prints the resulting profit

    local recipeData = CraftSimAPI:GetRecipeData(367713)
    recipeData:OptimizeProfit(true)
    local averageProfit = recipeData:GetAverageProfit()
    print(averageProfit)