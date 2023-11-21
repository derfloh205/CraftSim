AddonName, CraftSim = ...

CraftSim.NEWS = {}

function CraftSim.NEWS:GET_NEWS()
    -- minimize names to make manual formatting easier :p
    local f = CraftSim.UTIL:GetFormatter()
    local function newP(v) return f.l("\n\n                                   --- Version " .. v .. " ---\n") end

    return 
        f.bb("                   Hello and thank you for using CraftSim!\n") .. 
        f.bb("                                 ( You are awesome! )") ..
        newP("9.0.0") ..
        f.P .. "QOL Update" ..
        f.p .. "Added a checkbox to the " .. f.bb("Recipe Scan") .. " module to " ..
        f.a .. "optionally sort by relative profit instead of gold value" ..
        f.p .. "Added a checkbox to the " .. f.bb("Recipe Scan") .. " module to " ..
        f.a .. "use " ..f.bb("(Lesser) Illustrious Insight") .. " for recipes that" ..
        f.a .. "allow it. Might be adding a feature to toggle any" .. 
        f.a .. "Optional Reagents for scans at some point" .. 
        f.p .. "Added a checkbox to the " .. f.bb("Craft Results") .. " module to" ..
        f.a .. "disable any recording for a potential performance increase" ..
        f.a .. "while crafting" ..
        f.p .. "Automatically highlight all text for results of the " .. f.l("ForgeFinder Export") ..
        newP("8.9.4") ..
        f.p .. "Added " .. f.l("10.2") ..  f.g(" Optional Reagents") ..
        f.a .. "Thanks to " .. f.bb("https://github.com/TheResinger") .. " !" ..
        newP("8.9.3") ..
        f.p .. "Updated enchant recipes for 10.2" ..
        f.p .. "Supporter List Update" ..
        newP("8.9.2") ..
        f.s .. "Expanded the " .. f.bb("Craft Statistics Panel") .." of the " .. f.bb("Average Profit Module") ..
        f.a .. "to now also show " .. f.g("expected costs per item") .. 
        f.a .. "with and without " .. f.g("sell return of lower qualities") ..
        f.p .. "Added a new help icon (?) to explain the statistics table" ..
        f.p .. "Fixed the " .. f.bb("Show Statistics") .. " button not updating its text when" ..
        f.a .. "closing the " .. f.bb("Statistics Module") ..
        f.p .. "Supporter List Update" ..
        newP("8.9.1") ..
        f.P .. "10.1.5 Fix" ..
        f.p .. "Supporter List Update" ..
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
        f.p .. "Added an additional dropdown frame into the" .. 
        f.a .. "frame pool for optional and finishing reagents" ..
        f.a .. "to support the new tailoring pvp gear" ..
        newP("8.8.0") ..
        f.s .. "Updates and Fixes to the " .. f.bb("CustomerHistory") .. " Module by" ..
        f.a .. f.bb("https://github.com/Meivyn") .. 
        f.p .. "Supporter List Update" ..
        f.p .. "Bugfix for Specialization Node Info" ..
        f.a .. "regarding the Shadowbelt Clasp Recipe by" ..
        f.a .. f.bb("https://github.com/domi1294")
end