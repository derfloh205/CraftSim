addonName, CraftSim = ...

CraftSim.NEWS = {}

function CraftSim.NEWS:GET_NEWS()
    -- minimize names to make manual formatting easier :p
    local b = CraftSim.CONST.COLORS.DARK_BLUE
    local bb = CraftSim.CONST.COLORS.BRIGHT_BLUE
    local g = CraftSim.CONST.COLORS.GREEN
    local r = CraftSim.CONST.COLORS.RED
    local l = CraftSim.CONST.COLORS.LEGENDARY
    local c = function(text, color) 
        return CraftSim.UTIL:ColorizeText(text, color)
    end
    local tunaData = CraftSim.DATAEXPORT:GetItemFromCacheByItemID(199345, true)
    local frostedTunaData = CraftSim.DATAEXPORT:GetItemFromCacheByItemID(200074)
    return 
        c("Hello and thank you for using CraftSim!\n", bb) .. 
        "( Show this window any time with " .. c("/craftsim news", g) .. " )" ..
        c("\n\n\n--- Version 1.7.6 ---", l) ..
        c("\n\nSimulation Mode", bb) .. " now correctly considers costs of\noptional and finishing reagents in crafting costs" .. 
        c("\n\n\n--- Version 1.7.5 ---", l) ..
        c("\n\n\nMax Reagent Skill Contribution", bb) .. " is now 25% of recipe difficulty\nfor everything except recrafts. For those the\n" ..
        "factor will be calculated." ..
        c("\n\n\nMax Reagent Skill %", g) .. " display added in " .. c("Simulation Mode", bb) ..
        c("\n\n\n--- Version 1.7.4 ---", l) ..
        "\n\nMany fixes to the optional/finishing reagents in " .. c("Simulation Mode", g) ..
        "\n\n" .. c("Simulation Mode", g) .. " now correctly shows\nthe OutputItem Links for gear\nconsidering missives, infusions and embellishments" ..
        c("\n\n\n--- Version 1.7 ---", l) ..
        "\n\n" .. c("Skill Increase by Reagents", g) .. " is now calculated\nvia an ingame API workaround" ..
        "\n\n" .. c("Recraft Simulations", bb) .. " are now able to consider\nthe hidden quality modifier" ..
        c("\n\n\n--- Version 1.6.5 ---", l) ..
        "\n\n\n" .. "Added Dropdowns for optional and finishing reagents\nin" .. c(" Simulation Mode", g) .. 
        "\n\nNew Utilities added for" ..
        "\n" .. c("Debug Mode ( /craftsim debug )", g) ..
        "\n\nAdded the " .. c("RECrystallize", bb) .. " addon to possible price source addons" ..
        "\n\nReadjusted the " .. c("Simulation Mode Number Input Width", g) .. "\n to consider numbers with three digits" ..
        "\n\n" .. c("Cost Overview", g) .. " always show all qualities now" ..
        "\n\n" .. c("Disabled most Modules for ", r) .. c("Recrafting", bb) .. 
        "\n" .. " because of wrong reagent skill calculations due to hidden factors" ..
        "\n\n" .. c("Top Profit", bb) .. " Mode for the Top Gear module is now\navailable for all recipes to support price overrides" ..
        "\n\n" .. "Added " .. c("CallbackHandler", bb) .. " dependency to loaded list\nPeople who have " .. 
        c("Ace3", bb) .. " and " .. c("LibCompress", bb) .. " installed manually\nshould now be able to remove them" ..
        c("\n\nFixed Simulation Mode Help Icons", bb) .. " causing error on hover" ..
        "\n\nAuto sort quality itemIDs fetched from\nblizzard to prevent wrong quality orders" .. 
        "\n\n" .. c("Profit Calculation", g) .. " now considers skipping a quality with inspiration" .. 
        c("\n\n\n--- Version 1.6.4.2 ---", l) ..
        "\n\n\nFixed TSM Price Expression for Items\nbeing overwritten by the Material one on reload" ..
        c("\n\n\n--- Version 1.6.4.1 ---", l) ..
        "\n\n" .. c("Profit Calculation", g) .. " V2 implemented" ..
        "\n\nThe " .. c("Explanation Window", g) .. "\nshows some small values and an explanation,\nbut is not yet complete!" .. 
        "\n\n" .. c("Override Crafting Costs Checkbox", g) .. " added" ..
        "\n\n" .. "Various fixes to " .. c("\nExperimental Data from Profession Specializations", g) .. "\nand now turned off per default" ..
        c("\n\n\n--- Version 1.6.2, 1.6.3 ---", l) ..
        "\n\nBugfixes to certain nil errors" ..
        "\n\nFixed error with saving collapsed status of frames" .. 
        "\n\nFixed Material Combination Module trying to show up for noQuality recipes" ..
        "\n\n" .. (tunaData.link or c("Rimefin Tuna", bb)) .. " in cooking recipes\nnow uses " .. (frostedTunaData.link or c("Frosted Rimefin Tuna", bb)) .. " for pricing" ..
        "\n\n" .. c("Cost Overview", g) .. " now shows the actual item links" ..
        c("\n\n\n--- Version 1.6.1 ---", l) ..
        "\n\nVarious fixes to errors popping up for price calculations" .. 
        c("\n\nWARNING: ", r) .. " Recipes with exactly 1 material that has quality\n" ..
        "might still suggest wrong low cost max quality combinations!" ..
        "\n\nThe " .. c("Material Combination Suggestion", r) .. "\nis now disabled for such recipes until this issue is fixed" .. 
        c("\n\n\n--- Version 1.6 ---", l) ..
        c("\n\nOverride Sell Price ", g) .. " is a new feature that lets you override\nthe sell price for each quality on an item\n" .. 
        "even soulbound gear! You can use this to e.g. " .. c("simulate craft order comissions!", g) ..
        c("\n\nExtra Item Boni", g) .. " for Multicraft and Resourcefulness\nfrom specialization nodes should now be considered correctly!\n\n" ..
        "New " .. c("Debug Module", g) .. " was added! Are you curious?\nTry " .. c("/craftsim debug\n\n", g) .. 
        c("WARNING: ", r) .. " Recipes with exactly 1 material that has quality\n" ..
        "might suggest wrong low cost max quality combinations!" ..
        "\n\nA new " .. c("Error Window", r) .. " should now pop up.\nIf CraftSim runs into an error" .. 
        "\n\n--- Version 1.5.7 ---\n\n" ..
        c("Blacksmithing", bb) .. " and " .. c("Alchemy", bb) .. " now get their stats\n" ..
        "from your profession spec tree instead from the UI.\n" .. 
        "This enables some nice new features like a\n" .. c("Specialization" ..
        " Info Breakdown!", g) .. "\n\nHowever, this is still experimental!\n" ..
        "If you want, you can opt out in the options ( /craftsim )\n\n" ..
        "Support for other professions is in progress!\n\n" .. 
        "What else is new?\n\n" .. 
        "The " .. c("Simulation Mode", bb) .. " now also includes a modifier for the\n" .. 
        c("Inspiration Bonus Skill", bb) .. "\nprofession stat"
end