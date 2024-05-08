---@class CraftSim
local CraftSim = select(2, ...)

CraftSim.NEWS = {}

local print = CraftSim.DEBUG:SetDebugPrint(CraftSim.CONST.DEBUG_IDS.NEWS)

---@param itemMap table<string, ItemMixin>
function CraftSim.NEWS:GET_NEWS(itemMap)
    -- minimize names to make manual formatting easier :p
    local f = CraftSim.GUTIL:GetFormatter()
    local function newP(v) return f.l("\n                                   --- Version " .. v .. " ---\n") end
    local supporterListUpdate = f.p .. f.patreon("Supporter List Update ") ..
        CraftSim.MEDIA:GetAsTextIcon(CraftSim.MEDIA.IMAGES.PIXEL_HEART, 0.15)
    local news = {
        f.bb("                   Hello and thank you for using CraftSim!\n"),
        f.bb("                                 ( You are awesome! )"),
        newP("16.1.8"),
        f.P .. "Fixed 10.2.7 Bugs",
        f.p .. "Fixed module collapsed content showing on tab switch",
        newP("16.1.7"),
        f.P .. "A lot of internal code optimizations to",
        f.a .. "prepare for TWW testing/updates",
        f.s .. "Added a command to reset craftsim's database",
        f.a .. f.l("'/craftsim resetdb'"),
        f.p .. "Fixed " .. f.bb("Simulation Mode") .. " Crafting Details opacity",
        f.p .. "DB Migration fixes",
        f.p .. f.bb("CraftQueue") .. " unsaved amount now shows a little asterix",
        f.a .. "- Including a tooltip",
        f.p .. "Fixed errors with NPC professions",
        f.p .. "Contribution thanks:",
        f.a .. "- " .. f.bb("https://github.com/rowaasr13"),
        supporterListUpdate,
        newP("16.0.0"),
        f.P .. "Introducing " .. f.bb("Sub Recipes Optimization"),
        f.a .. "- " .. f.l("CraftSim") .. " is now able to optimize and cache",
        f.a .. "  crafting cost details for reagents",
        f.a .. "  " .. f.r("This is still experimental"),
        f.P .. "All modules now are put into the UI front on click",
        f.P .. "Thanks go to " .. f.bb("https://github.com/netouss"),
        f.a .. "for helping with beta testing and more!",
        f.P .. f.g("CraftQueue"),
        f.a .. "- New Recipe Queue Mode: " .. f.bb("Target Mode"),
        f.a .. "- Configure a target item count for a queued recipe",
        f.a .. "- This is default for any automatically queued sub crafts",
        f.a .. "- A minimum craft amount is calculated by CraftSim",
        f.a .. "- But can be adjusted in the " .. f.bb("Restock Options") .. " Tab",
        f.a .. "- Adjusting the craft amount for a queued recipe now",
        f.a .. "  requires ENTER to be pressed to update the queue",
        f.P .. f.g("Cost Details") .. " renamed to " .. f.g("Cost Optimization"),
        f.a .. "- Now shows the lowest expected crafting costs for an item",
        f.a .. "  if you or one of your alts are able to craft it (and its cached)",
        f.a .. "- Subcrafting costs are considered if",
        f.a .. "  you enable it in the module",
        f.a .. "- Now has a " .. f.g("Sub Recipe Options") .. " Tab to configure sub crafts",
        f.P .. f.g("Recipe Scan"),
        f.a .. "- Added a Recipe Scan Option to toggle " .. f.bb("sub crafts"),
        f.a .. "- Current cooldown charges are now shown besides",
        f.a .. "  the recipe name",
        f.a .. "- The alt profession list is now more consistently sorted",
        f.P .. f.g("Average Profit"),
        f.a .. "- Removed Explanation and Statistics Button (-> new modules)",
        f.a .. "- Refactored the profit and stat weight display",
        f.a .. "and added tooltips",
        f.P .. f.g("Explanations"),
        f.a .. "- New Module moved from Average Profit",
        f.P .. f.g("Statistics"),
        f.a .. "- New Module moved from Average Profit",
        f.p .. f.bb("Cooldowns"),
        f.a .. "- Fixed a bug when displaying a cooldown that is fully charged",
        f.p .. f.bb("CraftResults"),
        f.a .. "- Fixed a Typo in the Item Result Log saying 'Profit: :'",
        f.a .. "  instead of 'Saved Reagents:",
        f.p .. "Fixed a bug leading to an error when moving a",
        f.a .. "frame while crafting",
        f.p .. "Russian Translation Update",
        f.a .. "- Thanks to " .. f.bb("https://github.com/SerGlushko"),
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
        chocolate = Item:CreateFromItemID(194902),
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
