AddonName, CraftSim = ...

CraftSim.NEWS = {}

function CraftSim.NEWS:GET_NEWS()
    -- minimize names to make manual formatting easier :p
    local f = CraftSim.UTIL:GetFormatter()
    local function newP(v) return f.l("\n\n                                   --- Version " .. v .. " ---\n") end

    return 
        f.bb("                   Hello and thank you for using CraftSim!\n") .. 
        f.bb("                                 ( You are awesome! )") ..
        newP("8.6.2") ..
        f.p .. "Fixed" ..  f.g(" Live Preview") .. " link not opening the Live Preview" .. 
        f.p .. "Added CraftSim to the new ingame " .. f.g("Addon Compartment") ..
        f.p .. "Added a neat little gold icon for CraftSim in the addon list" ..
        f.a .. "and in the new addon compartment" ..
        newP("8.6.1") ..
        f.P .. f.g("10.1 Fixes") ..
        f.s .. "I want to apologize for not updating a lot" .. 
        f.a .. "in the recent weeks." ..
        f.a .. "It seems that being a father eats up A LOT of time." ..
        f.a .. "Recently I am trying to get more time for CraftSim again!" ..
        f.a .. "I am also thinking about adding a patreon." ..
        f.s .. f.r("Warning: ") .. "Specialization Info might be out of date" ..
        f.a .. "for some of the new recipes added with 10.1 until" ..
        f.a .. "it is manually updated" .. 
        f.p .. "Fixed the Profession Gear Stat parsing now using" ..
        f.a .. "a different tooltip property after 10.1" ..
        f.p .. "Added an additional dropdown to the frame pool in" ..
        f.a .. f.g("Simulation Mode") .. " to consider the new" .. 
        f.a .. "optional spark slot in 10.1" ..
        f.p .. "Added data for " .. f.g("new optional reagents") .. " in 10.1" ..
        f.p .. "Added data for " .. f.g("new enchanting recipes") .. " in 10.1" ..
        f.p .. "Game Version Update" ..
        newP("8.5.1") ..
        f.P .. "Optimized the " .. f.bb("Material Cost Optimization") .. f.g(" significantly") ..
        f.a .. "Optimizing high reagent count recipes now takes" .. 
        f.a .. "a few milliseconds instead of 1 to 2 seconds per recipe" ..
        f.s .. "Redesigned the " .. f.bb("Price Details") .. " Module to a list format" ..
        f.a .. "(Thx to " .. f.bb("Elitesparkle") .. " for all those UI suggestions)" ..
        f.s .. "Added Translation Keys for all " .. f.bb("Spezialization Node Names") ..
        f.a .. "Current Translations: English / Italian" ..
        f.a .. "(Thx to " ..f.bb("https://github.com/SirDester")..")" ..
        f.s .. "Restructured the " .. f.bb("Control Panel") .. " to fit the 10.0.7" ..
        f.a .. "Profession Window Size" ..
        f.p .. "Moved the "..f.bb("Simulation Mode").." dropdowns for optional reagents" ..
        f.a .. "to consider the new Profession Window size" ..
        f.p .. "Moved the " .. f.bb("Simulation Mode") .. " checkbox" ..
        f.a .. "to consider the new Profession Window size" ..
        f.p .. "Removed a debug print that may lead to a nil error" ..
        f.p .. f.l("ForgeFinder") .. " Export should now include recipes" ..
        f.a .. "that do not support qualities but support ".. f.bb("Multicraft")
end