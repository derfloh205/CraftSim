AddonName, CraftSim = ...

CraftSim.NEWS = {}

function CraftSim.NEWS:GET_NEWS()
    -- minimize names to make manual formatting easier :p
    local f = CraftSim.UTIL:GetFormatter()
    local function newP(v) return f.l("\n\n                                   --- Version " .. v .. " ---\n") end

    return 
        f.bb("                   Hello and thank you for using CraftSim!\n") .. 
        f.bb("                                 ( You are awesome! )") ..
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