addonName, CraftSim = ...

CraftSim.NEWS = {}

function CraftSim.NEWS:GET_NEWS()
    -- minimize names to make manual formatting easier :p
    local b = CraftSim.CONST.COLORS.DARK_BLUE
    local bb = CraftSim.CONST.COLORS.BRIGHT_BLUE
    local g = CraftSim.CONST.COLORS.GREEN
    local r = CraftSim.CONST.COLORS.RED
    local l = CraftSim.CONST.COLORS.LEGENDARY
    local c = function(text, color) 
        return CraftSim.UTIL:ColorizeText(text, color)
    end
    local p = "\n" .. CraftSim.UTIL:GetQualityIconAsText(1, 15, 15) .. " "
    local s = "\n" .. CraftSim.UTIL:GetQualityIconAsText(2, 15, 15) .. " "
    local P = "\n" .. CraftSim.UTIL:GetQualityIconAsText(3, 15, 15) .. " "
    local a = "\n     "
    local function newP(v) return c("\n\n\n                                   --- Version " .. v .. " ---\n\n", l) end
    -- local tunaData = CraftSim.DATAEXPORT:GetItemFromCacheByItemID(199345, true)
    -- local frostedTunaData = CraftSim.DATAEXPORT:GetItemFromCacheByItemID(200074)
    return 
        c("                   Hello and thank you for using CraftSim!\n", bb) .. 
        "             ( Show this window any time with " .. c("/craftsim news", g) .. " )" ..
        newP("4.0") ..
        P .. "New Module: " .. c("Recipe Scan", g) .. 
        a .. "Scan all your profession's recipes based on given options" .. 
        newP("3.3") ..
        P .. "Added " .. c("Leatherworking", bb) .. 
        a .. "to experimental specialization data" ..
        a .. "Thank you " .. c("https://github.com/RosskoCholakov", bb) .. 
        a .. "for your effort!" ..
        a .. c("This is not sufficiently tested yet", r) .. 
        a .. "If you want to help testing it, toggle it on" .. 
        a .. "and verify if the crafting data/details" .. 
        a .. "blizzard shows align with CraftSim's shown" .. 
        a .. "data/results in Simulation Mode" ..
        a .. "Single profession spec nodes can be tested by ID" ..
        a .. "or by rule name" ..
        a .. "(See Data/SpecNodeData/Leatherworking.lua)" ..
        a .. "in Debug Mode (E.g: CURING_AND_TANNING_1)" ..
        s .. "Added discord invite to the patch notes!" .. 
        a .. c("Feel free to join :D", g) ..
        newP("3.2") ..
        p .. "Added missing data for optional reagent " .. c("Armor Spikes", bb) .. 
        p .. "Reimplemented the result item fetch for" .. 
        a .. "non gear recipes to use the ingame api" ..
        a .. "This now prevents any wrong sorting of qualities for" ..
        a .. "cost overview and profit calculation" ..
        newP("3.0/3.1") ..
        P .. "New " .. c("Price Override Module", g) ..
        a .. "Override prices of " .. c("any materials", bb) .. ", " .. 
        a .. c("optional and finishing reagents, ", bb) ..
        a .. "and for " .. c("crafted results", bb) .. " per recipe or for all recipes!" ..
        s .. "Added " .. c("Close Buttons", bb) .. " to all modules" ..
        newP("2.2") ..
        p .. "Fixed an error with Top Gear stat extraction" .. 
        a .. "from items with no stats" ..
        newP("2.1") ..
        p .. "Updated the multicraft extra items formula to " ..
        a .. c("(1+2.5y*bonus) / 2", bb) .. 
        a .. "instead of " ..
        a .. c("((1+2.5y) / 2)*bonus", bb) .. 
        a .. "which leads to slightly less but more" .. 
        a .. "accurate value from multicraft" ..
        p .. "Fixed an error during prospecting and" .. 
        a .. "other salvage recipes" .. 
        p .. "Fixed a bug causing the Simulate Top Gear button" ..
        a .. "to not update" .. 
        p .. "Fixed racial skill boni being applied two times" .. 
        a .. "when using experimental spec data" .. 
        p .. "Fixed Chemical Synthesis not being considered in" .. 
        a .. "Alchemy experimental spec data" ..
        newP("2.0") ..
        P .. "Implemented most modules for " .. c("Work Orders", g) ..
        a .. "Simulation Mode for work orders will follow" .. 
        a .. "in a future update." .. 
        a .. "Behaviour of the Work Order Modules during recrafting" .. 
        a .. "is not tested yet" .. 
        P .. "Introducing the " .. c("CraftSim Control Panel", g) ..
        a .. "Serving as the main module of CraftSim from now on" .. 
        a .. "it gives easy access to all different modules" ..
        s .. c("Removed", r) .. " the price override feature temporary" .. 
        a .. "This will be reimplemented as a seperate module" .. 
        a .. "in a future update"
end