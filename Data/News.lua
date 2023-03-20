AddonName, CraftSim = ...

CraftSim.NEWS = {}

function CraftSim.NEWS:GET_NEWS()
    -- minimize names to make manual formatting easier :p
    local f = CraftSim.UTIL:GetFormatter()
    local function newP(v) return f.l("\n\n                                   --- Version " .. v .. " ---\n") end

    return 
        f.bb("                   Hello and thank you for using CraftSim!\n") .. 
        f.bb("                                 ( You are awesome! )") ..
        newP("8.4.1") ..
        f.s .. "Added functionality support for " .. f.g("zhCN") ..  " localization" ..
        f.a .. "(Thx to " .. f.bb("https://github.com/ak48disk)") ..
        f.p .. "Tweaks to " .. f.bb("Alchemy Specialization Info") .. " for Transmutaion" ..
        f.p .. "Tweaks to " .. f.bb("Jewelcrafting Specialization Info") .. 
        f.a .. "(Thx to " .. f.bb("https://github.com/domi1294)") ..
        newP("8.4.0") ..
        f.P .. f.bb("Tailoring") .. " and " .. f.bb("Inscription") .. " specialization data added." ..
        f.a .. "Many thanks to " .. f.bb("https://github.com/domi1294") ..
        f.p .. "Fixed a bug with " .. f.bb("Craft Data") .. " of optional reagents" ..
        newP("8.3.3") ..
        f.p .. "Fixed " .. f.l("ForgeFinder") .. " Export not including" .. 
        f.a .. "stats from profession gear" ..
        newP("8.3.2") ..
        f.p .. "Hotfix to " .. f.bb("RecipeScan") .. " bug" ..
        f.p .. "Include non quality recipes in " .. f.l("ForgeFinder") .. " Export" ..
        newP("8.3.1") ..
        f.p .. "Fixed the exception for " .. f.bb("Rimefin Tuna - Frosted Rimefin Tuna") .. 
        newP("8.3.0") ..
        f.P .. f.g("Engineering Specialization Data") .. " added!" ..
        f.a .. "(Thx to "..f.bb("https://github.com/domi1294")..")" .. 
        f.s .. "The " .. f.l("ForgeFinder") .. " Export is now independent" ..
        f.a .. "from the " .. f.bb("Recipe Scan") .. " and always exports" ..
        f.a .. "all recipes from your open profession." ..
        f.a .. "It can now be found in the " .. f.bb("Control Panel") ..
        newP("8.2.3") ..
        f.p .. "Smaller tweaks to " .. f.l("ForgeFinder") .. " export" ..
        f.p .. "Fixed " .. f.bb("Top Gear") .. " not showing for Work Orders" ..
        f.p .. "Fixed Jewelcrafting missing 5% inspiration skill from specialization" ..
        newP("8.2.1") ..
        f.P .. f.bb("Craft Data") .. " is now always used if existing and lower" ..
        f.a .. "than current ah price" ..
        f.a .. "Removed the " .. f.bb("Use Craft Data") .. " toggle in price override due" ..
        f.a .. "to redundancy" ..
        f.s .. f.bb("Recipe Scan") .. " now shows the recipeNames wrapped, colorized" ..
        f.a .. "and scaled down a bit" ..
        f.p .. "Added a Cancel button to " .. f.bb("Recipe Scan") ..
        f.a .. "Because some recipes, especially " .. f.e("Life Bound Gear") ..
        f.a .. " for " .. f.bb("Leatherworking").. " decrease performance when" .. 
        f.a .. "optimizing materials due to over 150 required reagents" ..
        f.p .. "Fixed FrameStrata of " .. f.bb("Simulation Mode Details") .. " Frame" ..
        f.p .. "Fixed an error when using CraftSim without a " .. f.bb("Price Source") ..
        f.p .. "Adjusted exported data for the " .. f.l("ForgeFinder") .. " export" ..
        f.a .. f.bb("Note: ") .. "CraftSim already provides this export, although" ..
        f.a .. f.l("ForgeFinder") .. " is still working on it" ..
        newP("8.2.0") ..
        f.P .. f.bb("Recipe Scan") .. " and " .. f.bb("Recipe Export") .. " now offer" ..
        f.a .. "an export than can be used on " .. f.l("www.wowforgefinder.com") ..
        f.s .. f.bb("Recipe Scan: ") .. " redesigned result list, now shows " ..
        f.a .. "total inventory and auction house count of a recipe's items" ..
        f.a .. "AH count is only shown when " .. f.bb("TSM") .. " is loaded." ..
        f.a .. "(It is not necessary to set it as price source)" ..
        f.p .. "Fixed " .. f.bb("Profit Calculation") .. " for recipes that support" .. 
        f.a .. "only inspiration and resourcefulness not considering" ..
        f.a .. "extra inspiration skill from specializations"
end