AddonName, CraftSim = ...

CraftSim.NEWS = {}

function CraftSim.NEWS:GET_NEWS()
    -- minimize names to make manual formatting easier :p
    local f = CraftSim.UTIL:GetFormatter()
    local function newP(v) return f.l("\n\n                                   --- Version " .. v .. " ---\n") end

    return 
        f.bb("                   Hello and thank you for using CraftSim!\n") .. 
        f.bb("                                 ( You are awesome! )") ..
        newP("8.2.3") ..
        f.p .. "Smaller tweaks to " .. f.l("ForgeFinder") .. " export" ..
        f.p .. "Fixed " .. f.bb("Top Gear") .. " not showing for Work Orders" ..
        newP("8.2.1") ..
        f.P .. f.bb("Craft Data") .. " is now always used if existing and lower" ..
        f.a .. "than current ah price" ..
        f.a .. "Removed the " .. f.bb("Use Craft Data") .. " toggle in price override due" ..
        f.a .. "to redundancy" ..
        f.s .. f.bb("Recipe Scan") .. " now shows the recipeNames wrapped, colorized" ..
        f.a .. "and scaled down a bit" ..
        f.p .. "Added a Cancel button to " .. f.bb("Recipe Scan") ..
        f.a .. "Because some recipes, especially " .. f.e("Life Bound Gear") ..
        f.a .. " for " .. f.bb("Leatherworking").. " decrease performance when" .. 
        f.a .. "optimizing materials due to over 150 required reagents" ..
        f.p .. "Fixed FrameStrata of " .. f.bb("Simulation Mode Details") .. " Frame" ..
        f.p .. "Fixed an error when using CraftSim without a " .. f.bb("Price Source") ..
        f.p .. "Adjusted exported data for the " .. f.l("ForgeFinder") .. " export" ..
        f.a .. f.bb("Note: ") .. "CraftSim already provides this export, although" ..
        f.a .. f.l("ForgeFinder") .. " is still working on it" ..
        newP("8.2.0") ..
        f.P .. f.bb("Recipe Scan") .. " and " .. f.bb("Recipe Export") .. " now offer" ..
        f.a .. "an export than can be used on " .. f.l("www.wowforgefinder.com") ..
        f.s .. f.bb("Recipe Scan: ") .. " redesigned result list, now shows " ..
        f.a .. "total inventory and auction house count of a recipe's items" ..
        f.a .. "AH count is only shown when " .. f.bb("TSM") .. " is loaded." ..
        f.a .. "(It is not necessary to set it as price source)" ..
        f.p .. "Fixed " .. f.bb("Profit Calculation") .. " for recipes that support" .. 
        f.a .. "only inspiration and resourcefulness not considering" ..
        f.a .. "extra inspiration skill from specializations" ..
        newP("8.1.0") ..
        f.s .. f.l("Expected Costs") .. " from saved " .. f.bb("Craft Data") .. " is now only" ..
        f.a .. "used when lower than the auction house price." ..
        f.s .. f.bb("Cost Details") .. " now shows all possible prices and" ..
        f.a .. "which one of them is used" ..
        f.p .. "Fixed " .. f.bb("Craft Data") .. " for guaranteed items not considering" ..
        f.a .. "the amount of crafted items" ..
        f.p .. "AH Count (if available) and Inventory Count of items now show" ..
        f.a .. "in " .. f.bb("Price Details") ..
        newP("8.0.0") ..
        f.P .. "New Module: " .. f.g("Craft Data") ..
        f.a .. "This module allows you to take a " .. f.bb("'Snapshot'") ..
        f.a .. "of your recipe's " .. f.bb("Craft Configurations") .. 
        f.a .. "You can also setup a " .. f.bb("Price Override") .. 
        f.a .. "to use an item's " .. f.bb("Craft Data") .. " as material price" ..
        f.a .. "when calculating crafting costs!" ..
        f.a .. f.bb("Craft Data") .. " can also be shared with other players" ..
        f.a .. "and you can switch between saved data of different characters" ..
        f.a .. "for an item" ..
        f.P .. "New Module: " .. f.g("Cost Details") ..
        f.a .. "View the " .. f.bb("AH Price") .. " and the price used by CraftSim" ..
        f.a .. "for each material used in your currently viewed recipe!" ..
        f.P .. f.g("All Item Icons") .. " can now be " .. f.bb("shift-clicked") .. " to insert the" ..
        f.a .. "respective item link into the active chat" ..
        f.s .. "Module windows now stay anchored to the ProfessionsFrame" ..
        f.a .. "and position/collapsed status is saved and restored over sessions" ..
        f.s .. "Reworked " .. f.bb("Cost Overview") .. " to " .. f.g("Price Details") ..
        f.a .. "Now displays only information about the resulting items" ..
        f.s .. f.l("API Update: ") .. "RecipeData.ResultData" ..
        f.a .. "now includes a craft chance per quality table and" ..
        f.a .. "an expected crafts per quality table" .. 
        f.p .. "Added a workaround to blizzard's Crafting API's" .. 
        f.a .. "wierd late-loading of multicraft data" ..
        f.a .. "(This caused first calculations of recipes and " .. f.bb("Recipe Scans") ..
        f.a .. "made right after a fresh login to show an incorrect profit" .. 
        f.a .. "due to missing multicraft values)" ..
        f.p .. "Added a workaround to blizzard firing multiple refresh events" ..
        f.a .. "upon finishing a craft to improve crafting performance"
end