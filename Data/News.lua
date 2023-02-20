AddonName, CraftSim = ...

CraftSim.NEWS = {}

function CraftSim.NEWS:GET_NEWS()
    -- minimize names to make manual formatting easier :p
    local f = CraftSim.UTIL:GetFormatter()
    local function newP(v) return f.l("\n\n                                   --- Version " .. v .. " ---\n") end

    return 
        f.bb("                   Hello and thank you for using CraftSim!\n") .. 
        f.bb("                                 ( You are awesome! )") ..
        newP("7.1.0") ..
        f.P .. "New Feature " .. f.g("Customer Service - Recipe Whisper") ..
        f.a .. "A on demand whisper to a target character containing various info" .. 
        f.a .. "about your currently open recipe." ..
        f.a .. "Automatically adds a small disclaimer at the end if any stats were" .. 
        f.a .. "manually increased or decreased in " .. f.bb("Simulation Mode") ..
        f.p .. "Fixed " .. f.bb("Craft Results") .. " not showing real/expected" ..
        f.a .. "for inspiration and multicraft" ..
        newP("7.0.0") ..
        f.P .. f.g("Refactored ") .. f.l("ALL") .. " of CraftSim's Backend" ..
        f.a .. "to an " .. f.bb("Object Orientated") .. " Design." .. 
        f.a .. "This makes newer modules and features " .. f.g("much easier to develop!") ..
        f.a .. "Also enables easy to use " .. f.g("ingame API functions") .. " for CraftSim." ..
        f.P .. f.g("API") .. " added to fetch CraftSim's new " .. f.g("RecipeData") .. " object." ..
        f.a .. "Also added an " .. f.bb("API_README.md") ..
        f.s .. f.r("Disabled") .. " the " .. f.bb("Tooltip, Auto Reply") .. 
        f.a .. " and " .. f.bb("Account Sync") .. " Features until reworked." ..
        f.s .. f.r("Removed") .. " Experimental Data Toggle." .. 
        f.a .. "Profession Stats are now always fetched from the ingame API!" ..
        f.a .. "Manually mapped specialization data is now only used" .. 
        f.a .. "for the " .. f.bb("Specialization Info Module") .. " and " .. f.bb("Knowledge Simulation") ..
        newP("6.7.2") ..
        f.P .. f.bb("HSV Consideration Explanation") .. " added" ..
        f.s .. "New Options Tab: " .. f.g("Crafting") ..
        f.a .. "Coming with a new option to automatically clear" .. 
        f.a .. "your RAM after a specified number of crafts" ..
        f.p .. f.bb("Craft Results") .. " now show resourcefulness real saved costs" ..
        f.a .. "and expected saved costs instead of the number of procs" ..
        f.a .. "This is because there are 'hidden' procs that do not" .. 
        f.a .. "save anything and screw up the expected numbers." ..
        f.a .. "However they are considered in the calculations" ..
        f.p .. "Fixed " .. f.bb("Leatherworking Experimental Data") .. 
        f.a .. "Curing and Tanning Node for Reagents" ..
        newP("6.6") ..
        f.P .. f.bb("Basic Profit Explanation ") .. "added. (More Infos soon to come)" ..
        f.p .. "Added a system for custom icons/images in CraftSim" ..
        f.a .. "and used this to rework the checkmarks/crosses" .. 
        f.a .. "in the Recipe Scan and Statistics Frame" ..
        newP("6.5.1") ..
        f.s .. "Profit Statistics: Chance of profit > 0" .. 
        f.a .. "per number of crafts reworked" ..
        f.a .. "It is now using an approximation of the" .. 
        f.a .. "Cumulative Distribution Function (CDF)" ..
        newP("6.4.1") ..
        f.s .. "The " .. f.l("Hidden Skill Value ") .. "(HSV) now considers cases where skill" ..
        f.a .. "from inspiration + hsv can yield you the next quality" ..
        f.p .. "Experimental Data should now also consider" .. 
        f.a .. "the buff " .. f.bb("Alchemically Inspired") ..
        f.p .. "Fixed an error when crafting non-stat recipes" .. 
        f.a .. "(e.g. old world recipes)" ..
        f.p .. "Live Preview now includes a checkbox to" .. 
        f.a .. "switch optimization modes (Guaranteed & Inspiration)" ..
        f.p .. "Live Preview update requests now time out after 5 seconds" ..
        f.p .. "The " .. f.bb("Auto Reply") .. " Feature will be " .. f.r("removed ") .. "soon" ..
        f.a .. "It will be replaced by an on demand recipe info whisper" ..
        f.p .. "Fixed experimental data double counting incense inspiration"
end