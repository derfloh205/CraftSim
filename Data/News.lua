AddonName, CraftSim = ...

CraftSim.NEWS = {}

function CraftSim.NEWS:GET_NEWS()
    -- minimize names to make manual formatting easier :p
    local f = CraftSim.UTIL:GetFormatter()
    local function newP(v) return f.l("\n\n                                   --- Version " .. v .. " ---\n") end

    return 
        f.bb("                   Hello and thank you for using CraftSim!\n") .. 
        f.bb("                                 ( You are awesome! )") ..
        newP("8.5.1") ..
        f.s .. "Added Translation Keys for all " .. f.bb("Spezialization Node Names") ..
        f.s .. "Restructured the " .. f.bb("Control Panel") .. " to fit the 10.0.7" ..
        f.a .. "Profession Window Size" ..
        f.a .. "Current Translations: English / Italian" ..
        f.a .. "(Thx to " ..f.bb("https://github.com/SirDester")..")" ..
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