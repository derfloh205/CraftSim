AddonName, CraftSim = ...

CraftSim.NEWS = {}

function CraftSim.NEWS:GET_NEWS()
    -- minimize names to make manual formatting easier :p
    local f = CraftSim.UTIL:GetFormatter()
    local function newP(v) return f.l("\n\n                                   --- Version " .. v .. " ---\n") end

    return 
        f.bb("                   Hello and thank you for using CraftSim!\n") .. 
        f.bb("                                 ( You are awesome! )") ..
        newP("8.9.0") ..
        f.P .. "Thank you " .. f.bb("https://github.com/Kanegasi") .. " for" ..
        f.a .. "adding " .. f.g("Oribos Exchange") .. " to the possible price sources" ..
        f.s .. "Fixed a bug in the " .. f.bb("Knowledge Point Simulator") .. " that" ..
        f.a .. "did not correctly reset a node when subtracting" .. 
        f.a .. "with the -5 Button below 0" ..
        f.s .. f.bb("Profit Calculation") .." for " .. f.bb("Crafting Orders") .. " now correctly considers" ..
        f.a .. "materials that were provided by the customer" ..
        f.p .. "Added the " .. f.bb("Prospecting") .. " Talent Node to" .. f.bb(" Dragon Isles Crushing") ..
        f.a .. "for " .. f.bb("Specialization Info") ..
        newP("8.8.0") ..
        f.s .. "Updates and Fixes to the " .. f.bb("CustomerHistory") .. " Module by" ..
        f.a .. f.bb("https://github.com/Meivyn") .. 
        f.p .. "Supporter List Update" ..
        f.p .. "Bugfix for Specialization Node Info" ..
        f.a .. "regarding the Shadowbelt Clasp Recipe by" ..
        f.a .. f.bb("https://github.com/domi1294")
end