AddonName, CraftSim = ...

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
    local p = "\n" .. CraftSim.UTIL:GetQualityIconAsText(1, 15, 15) .. " "
    local s = "\n" .. CraftSim.UTIL:GetQualityIconAsText(2, 15, 15) .. " "
    local P = "\n" .. CraftSim.UTIL:GetQualityIconAsText(3, 15, 15) .. " "
    local a = "\n     "
    local function newP(v) return c("\n\n                                   --- Version " .. v .. " ---\n", l) end

    return 
        c("                   Hello and thank you for using CraftSim!\n", bb) .. 
        c("                                 ( You are awesome! )", bb) ..
        newP("6.2.3") ..
        P .. "Optional and Finishing Reagents are now available in the " ..
        a .. c("Live Preview", g) .. " and its recipe list is now sorted" ..
        a .. "into categories to reduce the dropdown height" ..
        s .. "Reagent Dropdowns now show a tooltip of" .. 
        a .. "the optional reagent and how many you own" ..
        p .. "Added a small loading text in Live Preview to" ..
        a .. "show that data is currently requested from the crafter" ..
        p .. "Fixed the " .. c("Material Optimization", bb) .. " not considering the" ..
        a .. "skill modifier in simulation mode" ..
        p .. "Postload reagent icons in Material Optimizations" ..
        p .. "Fixed link intercept triggering for all links and not just " ..
        a .. "for the live preview invite link (thx " .. c("https://github.com/comiluv", bb) ..
        p .. "Added partial support for old world recipes for" .. 
        a .. "cost overview and price override" ..
        a .. c("Known Issue: ", r) .. "RecipeScan not working when used while" .. 
        a .. "viewing non dragon flight recipes" ..
        p .. "Fixed resourcefulness and multicraft item boni bug" .. 
        p .. "Fixed Live Preview Crafting Costs" ..
        newP("6.1") ..
        P .. "Auto Reply now can take a third argument <ilvl> to specify the" ..
        a .. "target item level. It checks which infusion or matrix" ..
        a .. "it has to use to reach this itemlevel and then sims the recipe" ..
        a .. "with it in mind" ..
        p .. "Added a command preview to the Auto Reply Tab in the " .. 
        a .. "Customer Service Module to show its syntax" ..
        newP("6.0.1") ..
        p .. "Fixed an error due to the Craft Result statistics display" ..
        p .. "Utilizing ContinueOnItemLoad to lazy load the item links" .. 
        a .. "in the Cost Overview Module" ..
        newP("6.0.0") ..
        P .. "New Module: " .. c("Customer Service", g) ..
        a .. "New Feature: " .. c("Automatic Reply", g) .. " and" ..
        a .. "New Feature: " .. c("Live Crafting Preview", g) ..
        a .. "Send someone who has CraftSim an invite link to browse" ..
        a .. "your recipes and possible results in a live session!" ..
        a .. "For now it has some basic features and always optimizes for" ..
        a .. "Inspiration, but many more features will come :)" ..
        newP("5.5.6") ..
        s .. c("Real / Expected Number of Procs Comparison", g) .. " in Craft Results" ..
        p .. "Fixed Leatherworking Experimental Data not" .. 
        a .. "recognizing some patterns" .. 
        p .. "Owned number of commodities is now shown in" .. 
        a .. "the " .. c("Cost Overview Module", bb) ..
        newP("5.5.5") ..
        p .. "Jewelcrafting Experimental Data fix by " .. c("github.com/SanjoSolutions", bb) ..
        p .. "zhTW Translations added by " .. c("github.com/wxpenpen", bb) ..
        newP("5.5.4") ..
        p .. "The Craft Log of the Craft Results Module now uses" ..
        a .. "the ScrollingMessageFrame template to ensure infinite scrolling" ..
        newP("5.5.3") ..
        p .. "Fixed an error occuring for non experimental data recipes" .. 
        a .. "when parsing spec data" ..
        p .. "Fixed an error occuring when enchanting gear or" ..
        a .. "applying runes or other consumeables" ..
        p .. "itIT Localization Updates by " .. c("Elitesparkle", bb) ..
        p .. c("Known Issue:", r) .. " the craft log in the Craft Results" .. 
        a .. "Module might stop listing crafts after around 100 crafts" .. 
        a .. "However, the results are still correctly updated." .. 
        a .. "This seems to be an issue with the max length of texts" .. 
        a .. "and will be fixed in a future update" ..
        newP("5.5.2") ..
        p .. "Hotfix for RecipeScan" ..
        newP("5.5.1") ..
        p .. "Added an " .. c("Export Recipe Results", g) .. " Button to Crafting Results"
end