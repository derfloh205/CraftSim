AddonName, CraftSim = ...

CraftSim.NEWS = {}

function CraftSim.NEWS:GET_NEWS()
    -- minimize names to make manual formatting easier :p
    local f = CraftSim.UTIL:GetFormatter()
    local function newP(v) return f.l("\n\n                                   --- Version " .. v .. " ---\n") end

    return 
        f.bb("                   Hello and thank you for using CraftSim!\n") .. 
        f.bb("                                 ( You are awesome! )") ..
        newP("7.3") ..
        f.p .. "Wording changes in HSV Explanation" ..
        newP("7.2.2") ..
        f.p .. "Hotfix customer service recipe whisper and crafting costs" ..
        f.p .. "Hotfix Craft Results multicraft error" ..
        newP("7.2.0") ..
        f.P .. f.g("New Options") .. " to modify the " .. f.bb("Multicraft") .. " and " .. f.bb("Resourcefulness") ..
        f.a .. "constants used in profit calculation" ..
        f.p .. "Wording fixes for Recipe Whisper formatting help text" ..
        newP("7.1.0") ..
        f.P .. "New Feature " .. f.g("Customer Service - Recipe Whisper") ..
        f.a .. "A on demand whisper to a target character containing" .. 
        f.a .. "various information about your currently open recipe." ..
        f.a .. "Automatically adds a small disclaimer at the end if any" .. 
        f.a .. "stats were modified in " .. f.bb("Simulation Mode") ..
        f.p .. "Fixed " .. f.bb("Craft Results") .. " not showing real/expected" ..
        f.a .. "for inspiration and multicraft" ..
        f.p .. "Fixed " .. f.bb("Reagent Optimization Module") .. " Assign Button" ..
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
        f.a .. "for the " .. f.bb("Specialization Info Module") .. " and " .. f.bb("Knowledge Simulation")
end