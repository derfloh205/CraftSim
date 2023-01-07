addonName, CraftSim = ...

CraftSim.NEWS = {}

function CraftSim.NEWS:GET_NEWS()
    -- minimize names to make manual formatting easier :p
    local b = CraftSim.CONST.COLORS.DARK_BLUE
    local g = CraftSim.CONST.COLORS.GREEN
    local r = CraftSim.CONST.COLORS.RED
    local c = function(text, color) 
        return CraftSim.UTIL:ColorizeText(text, color)
    end
    -- make clickable item links!!
    local tunaData = CraftSim.DATAEXPORT:GetItemFromCacheByItemID(199345)
    local frostedTunaData = CraftSim.DATAEXPORT:GetItemFromCacheByItemID(200074)
    return 
        c("Hello and thank you for using CraftSim!\n", b) .. 
        "( Show this window any time with " .. c("/craftsim news", g) .. " )" ..
        "\n\n\n--- Version 1.6.4.2 ---" ..
        "\n\n\nFixed TSM Price Expression for Items\nbeing overwritten by the Material one on reload" ..
        "\n\n\n--- Version 1.6.4.1 ---" ..
        "\n\n" .. c("Profit Calculation", g) .. " V2 implemented" ..
        "\n\nThe " .. c("Explanation Window", g) .. "\nshows some small values and an explanation,\nbut is not yet complete!" .. 
        "\n\n" .. c("Override Crafting Costs Checkbox", g) .. " added" ..
        "\n\n" .. "Various fixes to " .. c("\nExperimental Data from Profession Specializations", g) .. "\nand now turned off per default" ..
        "\n\n\n--- Version 1.6.2, 1.6.3 ---" ..
        "\n\nBugfixes to certain nil errors" ..
        "\n\nFixed error with saving collapsed status of frames" .. 
        "\n\nFixed Material Combination Module trying to show up for noQuality recipes" ..
        "\n\n" .. (tunaData.link or c("Rimefin Tuna", b)) .. " in cooking recipes\nnow uses " .. (frostedTunaData.link or c("Frosted Rimefin Tuna", b)) .. " for pricing" ..
        "\n\n" .. c("Cost Overview", g) .. " now shows the actual item links" ..
        "\n\n\n--- Version 1.6.1 ---" ..
        "\n\nVarious fixes to errors popping up for price calculations" .. 
        c("\n\nWARNING: ", r) .. " Recipes with exactly 1 material that has quality\n" ..
        "might still suggest wrong low cost max quality combinations!" ..
        "\n\nThe " .. c("Material Combination Suggestion", r) .. "\nis now disabled for such recipes until this issue is fixed" .. 
        "\n\n\n--- Version 1.6 ---" ..
        c("\n\nOverride Sell Price ", g) .. " is a new feature that lets you override\nthe sell price for each quality on an item\n" .. 
        "even soulbound gear! You can use this to e.g. " .. c("simulate craft order comissions!", g) ..
        c("\n\nExtra Item Boni", g) .. " for Multicraft and Resourcefulness\nfrom specialization nodes should now be considered correctly!\n\n" ..
        "New " .. c("Debug Module", g) .. " was added! Are you curious?\nTry " .. c("/craftsim debug\n\n", g) .. 
        c("WARNING: ", r) .. " Recipes with exactly 1 material that has quality\n" ..
        "might suggest wrong low cost max quality combinations!" ..
        "\n\nA new " .. c("Error Window", r) .. " should now pop up.\nIf CraftSim runs into an error" .. 
        "\n\n--- Version 1.5.7 ---\n\n" ..
        c("Blacksmithing", b) .. " and " .. c("Alchemy", b) .. " now get their stats\n" ..
        "from your profession spec tree instead from the UI.\n" .. 
        "This enables some nice new features like a\n" .. c("Specialization" ..
        " Info Breakdown!", g) .. "\n\nHowever, this is still experimental!\n" ..
        "If you want, you can opt out in the options ( /craftsim )\n\n" ..
        "Support for other professions is in progress!\n\n" .. 
        "What else is new?\n\n" .. 
        "The " .. c("Simulation Mode", b) .. " now also includes a modifier for the\n" .. 
        c("Inspiration Bonus Skill", b) .. "\nprofession stat"
end