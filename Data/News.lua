---@class CraftSim
local CraftSim = select(2, ...)

local GUTIL = CraftSim.GUTIL

CraftSim.NEWS = {}

local print = CraftSim.DEBUG:RegisterDebugID("Data.News")

---@param itemMap table<string, ItemMixin>
function CraftSim.NEWS:GET_NEWS(itemMap)
    -- minimize names to make manual formatting easier :p
    local f = GUTIL:GetFormatter()
    local function newP(v) return f.l("\n                                   --- Version " .. v .. " ---\n") end
    local supporterListUpdate = f.p .. f.patreon("Supporter List Update ") ..
        CraftSim.MEDIA:GetAsTextIcon(CraftSim.MEDIA.IMAGES.PIXEL_HEART, 0.15)
    local news = {
        f.bb("                   Hello and thank you for using CraftSim!\n"),
        f.bb("                                 ( You are awesome! )"),
        newP("19.7.3"),
        f.p .. "11.0.7 Data Update",
        newP("19.7.2"),
        f.p .. "Fixed " .. f.bb("QuickBuy") .. " reset on list refresh",
        f.a .. "- Now always starts a new search",
        f.p .. "Locals Update",
        f.a .. "- " .. f.bb("esES") .. " by: " .. f.bb("https://github.com/GarikGangrel"),
        newP("19.7.1"),
        f.p .. f.bb("CraftQueue - Queue Work Orders"),
        f.p .. "- Fixed " .. f.bb("KP Cost") .. " being checked before optimization",
        newP("19.7.0"),
        f.P .. "New Feature: " .. f.g("Quick Buy"),
        f.p .. "- Works only with " .. f.bb("Auctionator Shopping List"),
        f.p .. "- Command: " .. f.l("/craftsim quickbuy"),
        f.p .. "- To be used in 1-Click Macro to buy all items",
        f.p .. "  in the CraftSim CraftQueue Shopping List",
        newP("19.6.3"),
        f.s .. "Fixed " .. f.bb("CraftLog") .. " PvP Item Bug",
        f.s .. "Fixed " .. f.bb("CraftQueue") .. " PvP Item Queueing",
        newP("19.6.2"),
        f.s .. f.bb("Craft Log"),
        f.a .. "- Fixed not updating the graph",
        f.a .. "- Anchored Log and Advanced Log independently",
        f.p .. "Refactored " .. f.grey("Debug ID Creation"),
        newP("19.6.1"),
        f.p .. "Fixed " .. f.bb("Craft Log") .. " not account for salvage crafting cost",
        newP("19.6.0"),
        f.P .. f.e("New Scrollbar Design") .. " for all lists!",
        f.P .. "Refactored " .. f.bb("Craft Results") .. " into " .. f.g("Craft Log"),
        f.a .. "- " .. f.bb("Craft Feed and Result Items") .. " are now separate",
        f.a .. "- New " .. f.g("Advanced Craft Log") .. " Analysis",
        f.a .. "- " .. f.g("Added Option") .. " to toggle new advanced log",
        f.a .. "- " .. f.g("Added Option") .. " to hide default Blizzard Crafting Log",
        f.a .. "- " .. f.g("Added Option") .. " to disable advanced logs to save resources",
        f.a .. "- " .. f.g("Added Option") .. " to automatically show new log on craft",
        f.a .. "- " .. f.l("Temporary Disabled") .. " export feature due to it being reworked",
        f.P .. f.bb("Recipe Scan"),
        f.a .. "- Added favorite icon if recipe is favorite on that character",
        f.a .. "- Added context menu button to toggle recipe as " .. f.l("favorite"),
        f.a .. "- Added context menu button to add recipe to Craft Queue",
        f.P .. f.bb("Craft Queue"),
        f.a .. "- " .. f.g("Queue Work Orders") .. " changed from 1 type to multiple",
        f.a .. "  Now possible to queue multiple work order types in succession",
        f.a .. "- Added 'Auto Show on Recipe Queued' Option (default: true)",
        f.a .. "- Removed Claimed Orders are now also cancelled",
        f.a .. "- UI will now switch to the crafting order on click if possible",
        f.s .. "Refactored the " .. f.bb("Debug Module"),
        f.p .. "Fix for PvP Heraldys in Work Orders",
        f.a .. "-  " .. f.bb("https://github.com/Prejudice182"),
        f.p .. "Locals Update",
        f.a .. "- " .. f.bb("koKR") .. " by: " .. f.bb("https://github.com/grapgrap"),
        newP("19.5.1"),
        f.P .. f.l("Cached Profession Data") .. " is now removed when unlearning",
        f.P .. f.bb("Recipe Scan"),
        f.a .. "Added " .. f.g("Right Click -> Remove") .. " Feature to list of professions",
        f.p .. "Fixed " .. f.bb("Queue First Crafts") .. " not using cheapest reagents",
        f.p .. "Fixed " .. f.bb("Craft Queue Amount") .. " tab button functionality",
        newP("19.5.0"),
        f.P .. f.bb("Craft Queue"),
        f.a .. "- General UI Improvements for the queue list",
        f.a .. "- " .. f.l("Delete Function") .. " moved to context menu",
        f.a .. "- " .. f.l("Edit Function") .. " moved to context menu",
        f.a .. "- Added " .. f.l("Equip Tools") .. " to context menu",
        f.a .. "- Added " .. f.l("Force Equipped Tools") .. " to context menu",
        f.a .. "- Added alternative Mouse Button function for Delete (MBB)",
        f.a .. "- Added Info for Work Order Types",
        f.a .. "- Added option to ignore queue amount reduction on ingenuity",
        f.a .. "- Added option to remove a concentration recipe on craft",
        f.a .. "  if no more concentration is available for it",
        f.a .. "- Fixed " .. f.bb("TSM Sale Rate Threshold") .. " default being 1",
        f.P .. f.bb("Queue Favorites"),
        f.a .. "- Added 'Offset Queue Amount' Option",
        f.a .. "- Added 'Queue Current Main Professions Option'",
        f.P .. f.bb("Queue Work Orders"),
        f.a .. "- Added option to " .. f.g("cap costs of knowledge points"),
        f.p .. "Locals Update",
        f.a .. "- " .. f.bb("ptBR") .. " by: " .. f.bb("https://github.com/cconolly"),
        newP("19.4.2"),
        f.P .. f.bb("Cost Optimization"),
        f.a .. "- You can now right click on any reagent to edit its " .. f.l("Price Override"),
        f.a .. "- Possible " .. f.g("Salvage Reagents") .. " now appear in the list",
        f.P .. f.bb("CustomerHistory"),
        f.a .. "- Moved Customer History Options to context menu",
        f.a .. "- Added option to enable / disable history recording",
        f.a .. "- Customers can now be deleted via context menu (right click)",
        f.p .. "Fixed " .. f.bb("Salvage Recipes") .. " Crafting Costs",
        f.a .. "- Craft Results and Crafting Costs now support additional reagents",
        f.a .. "- Example: Gem Crushing",
        f.a .. "- " .. f.r("Accurate average profit calculation not yet supported!"),
        f.p .. "Fixed " .. f.bb("Queue Work Orders") .. " PvP Recipe Issues",
        f.p .. "Fixed " .. f.bb("Queue First Crafts") .. " Ignore Spark also ignoring PvP Recipes",
        f.p .. "Fixed " .. f.bb("Queue Work Orders") .. " Ignore Spark also ignoring PvP Recipes",
        f.p .. "Fixed " .. f.bb("Auctionator Pricing") .. " Error sometimes occuring on init",
        f.p .. "Fixed " .. f.bb("Alt Recipe Scans") .. " Cached Data Deserialization",
        f.p .. "Specialization Data Update",
        newP("19.4.1"),
        f.p .. "Fixed " .. f.bb("Profession Gear") .. " Ingenuity Recognition",
        f.p .. "Fixed " .. f.bb("CraftQueue") .. " Include Augment Rune Option",
        f.p .. "Fixed " .. f.bb("Recipe Scan") .. " Reagent Allocation Radio Buttons",
        f.p .. "Fixed " .. f.bb("Shopping List Creation") .. " Optional Reagents Count",
        f.p .. "Fixed " .. f.bb("Concentration Tracker") .. " Position Memory",
        f.p .. "Fixed " .. f.bb("Cooldowns Module") .. " Position Memory",
        f.p .. "Removed Workaround Option for 11.0.5",
        f.p .. "Locals Update",
        f.a .. "- " .. f.bb("frFR") .. " by: " .. f.bb("https://github.com/netouss"),
        newP("19.4.0"),
        f.P .. "Overhauled the " .. f.bb("Control Panel"),
        f.a .. "- All of its functionality is now accessible by",
        f.a .. "  a " .. f.bb("new button") .. " on the TOP LEFT of the Crafting UI",
        f.P .. f.bb("Queue Patron Orders") .. " is now " .. f.g("Queue Work Orders"),
        f.a .. "- Type of order can now be switched (Default: Patron Orders)",
        f.P .. "Moved more options to the new option button context menus",
        f.p .. "Specialization Data Update",
    }
    return table.concat(news, "\n")
end

---@param newsText string
function CraftSim.NEWS:GetChecksum(newsText)
    local checksum = 0
    local checkSumBitSize = 256

    -- replace each itemLink with a generic string so there are no differences between characters in the checksum
    -- for _, item in pairs(itemMap) do
    -- end
    newsText = string.gsub(newsText, "|cff%x+|Hitem:.+|h|r", "[LINK]")

    -- Iterate through each character in the string
    for i = 1, #newsText do
        checksum = (checksum + string.byte(newsText, i)) % checkSumBitSize
    end

    -- print("replacing links in newstext:")
    -- print(newsText)

    return checksum
end

---@param newsText string
---@return string | nil newChecksum newChecksum when news should be shown, otherwise nil
function CraftSim.NEWS:IsNewsUpdate(newsText)
    local newChecksum = CraftSim.NEWS:GetChecksum(newsText)
    local oldChecksum = CraftSim.DB.OPTIONS:Get("NEWS_CHECKSUM")
    if newChecksum ~= oldChecksum then
        return newChecksum
    end
    return nil
end

---@param force boolean wether to skip the checksum verification
---@async
function CraftSim.NEWS:ShowNews(force)
    local itemMap = {
        enchantingRod = Item:CreateFromItemID(224116),
    }
    CraftSim.GUTIL:ContinueOnAllItemsLoaded(CraftSim.GUTIL:Map(itemMap, function(i) return i end), function()
        local newsText = CraftSim.NEWS:GET_NEWS(itemMap)
        local newChecksum = CraftSim.NEWS:IsNewsUpdate(newsText)
        if newChecksum == nil and (not force) then
            return
        end

        CraftSim.DB.OPTIONS:Save("NEWS_CHECKSUM", newChecksum)

        local infoFrame = CraftSim.GGUI:GetFrame(CraftSim.INIT.FRAMES, CraftSim.CONST.FRAMES.INFO)
        -- resize
        infoFrame:SetSize(CraftSim.CONST.infoBoxSizeX, CraftSim.CONST.infoBoxSizeY)
        infoFrame.originalX = CraftSim.CONST.infoBoxSizeX
        infoFrame.originalY = CraftSim.CONST.infoBoxSizeY
        infoFrame.showInfo(newsText)
    end)
end
