AddonName, CraftSim = ...

CraftSim.NEWS = {}

function CraftSim.NEWS:GET_NEWS()
    -- minimize names to make manual formatting easier :p
    local f = CraftSim.UTIL:GetFormatter()
    local function newP(v) return f.l("\n\n                                   --- Version " .. v .. " ---\n") end

    return 
        f.bb("                   Hello and thank you for using CraftSim!\n") .. 
        f.bb("                                 ( You are awesome! )") ..
        newP("8.6.0") ..
        f.P .. f.g("10.1 Fixes") ..
        f.s .. "I also want to apologize for not updating a lot in the recent weeks." ..
        f.a .. "It seems that being a father eats up A LOT of time." ..
        f.a .. "Recently I am trying to get more time for CraftSim again!" ..
        f.a .. "I am also thinking about adding a patreon." ..
        f.p .. "Fixed the Profession Gear Stat parsing now using" ..
        f.a .. "a different tooltip property after 10.1" ..
        f.p .. "Added an additional dropdown to the frame pool in " .. f.g("Simulation Mode") ..
        f.a .. "to consider the new optional spark slot in 10.1" ..
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
        f.a .. "that do not support qualities but support ".. f.bb("Multicraft") ..
        newP("8.5.0") ..
        f.P .. "CraftSim now correctly considers the chance to skip a quality" ..
        f.a .. "by " .. f.l("HSV") .. " and " .. f.bb("Inspiration") .. " double proc" ..
        f.P .. "Reworked the " .. f.bb("Statistics") .. " window of the " ..
        f.a .. f.bb("Average Profit") .. " module. It now shows a list" ..
        f.a .. "of chances and expected crafts per quality." .. 
        f.a .. "Furthermore, the " .. f.bb("Recipe Probability Table") .. 
        f.a .. "is now only shown when the window is expanded."
end