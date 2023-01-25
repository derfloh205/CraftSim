AddonName, CraftSim = ...

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

    return 
        c("                   Hello and thank you for using CraftSim!\n", bb) .. 
        "             ( Show this window any time with " .. c("/craftsim news", g) .. " )" ..
        newP("5.5") ..
        s .. "Added a small workaround to make" .. 
        a .. "the CraftSim Modules appear after a" ..
        a .. "fresh login and first time clicking on a profession" ..
        s .. "New Statistics Panel in the " .. c("Average Profit Module", g) .. 
        a .. "showing the probability table of the craft and the" .. 
        a .. "confidence to have a positive profit after a certain" .. 
        a .. "number of crafts" ..
        s .. "Switched to a statistics based expected profit calculation" ..
        p .. "Fixed Resourcefulness proc being counted multiple times" .. 
        a .. "for prospecting due to a bug on blizzard's side" ..
        p .. "The Crafted Items List in the " .. 
        a .. c("Craft Results Module", bb) .. " is now sorted by quality" ..
        p .. "Jewelcrafting Experimental Data:" .. 
        a .. "Primalist Gems are now affected by Faceting and " .. 
        a .. "their respective elemental node" ..
        newP("5.4") ..
        p .. c("TSM Price Expressions", bb) .. " can now be reset to the" .. 
        a .. "default 'first(DBRecent, DBMinbuyout)'" ..
        p .. "Bonus Inspiration from Incense is now considered" .. 
        a .. "when switching to Simulation Mode" ..
        p .. "Added Option to not be reminded to use a price source" ..
        newP("5.3") ..
        P .. "Added an option to automatically simulate Top Gear" ..
        s .. "The " .. c("Craft Results Module", g) .. " now buffers" .. 
        a .. "multiple craft results and assigns them to one craft" ..
        newP("5.2") ..
        p .. "Resourcefulness now uses a simpler calculation method" ..
        newP("5.1") ..
        P .. c("Craft Results Module", g) .. " redesigned" ..
        a .. "Now with more statistics!" ..
        p .. "The " .. c("Price Override Module", g) .. " now supports decimals" ..
        p .. "Fixed Jewelcrafting Experimental Data" .. 
        a .. "not showing the first spec" ..
        p .. "Fixed Alchemy Experimental Data not considering" .. 
        a .. "Chemical Synthesis for some Reagents" ..
        newP("5.0") ..
        P .. "New Module: " .. c("Craft Results", g) ..
        a .. "Logs your crafting outputs and shows you the total" .. 
        a .. "crafted profit for your open recipe or in total" ..
        a .. "for your current session!" ..
        newP("4.1") ..
        s .. "New Options Tab: " .. c("Profit Calculation", g) ..
        a .. "This tab will include options to make the average profit" ..
        a .. "calculations more customizeable" ..
        s .. "New option to ignore the possible minimum of" .. 
        a .. "1 material saved per procc" ..
        a .. "(instead of 30%) for resourcefulness" ..
        p .. "Fixed Optimizing Recipe Scans ignoring Non-Quality Recipes" ..
        p .. "Fixed Optimizing Recipe Scans sometimes" .. 
        a .. "not optimizing materials" .. 
        p .. "Fixed Recipe Scan skipping Enchanting Recipes" ..
        p .. "Fixed CraftSim producing errors when viewing" .. 
        a .. "another player's profession via link or guild list" ..
        newP("4.0") ..
        P .. "New Module: " .. c("Recipe Scan", g) .. 
        a .. "Scan all your profession's recipes based on given options" .. 
        a .. "Sorting and more planned for future updates!" ..
        s .. c("Auctionator DB", bb) .. " Updates now trigger a module refresh" .. 
        a .. "This means switching to another recipe and back" .. 
        a .. "is no longer necessary to refresh the modules" ..
        p .. "Moved the " .. c("Reset Frames", bb) .. " Button to the Control Panel" ..
        p .. "Fixed the Simulate Knowledge Button not collapsing correctly" ..
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
        a .. c("Feel free to join :D", g)
end