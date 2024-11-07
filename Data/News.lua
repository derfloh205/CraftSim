---@class CraftSim
local CraftSim = select(2, ...)

local GUTIL = CraftSim.GUTIL

CraftSim.NEWS = {}

local print = CraftSim.DEBUG:SetDebugPrint(CraftSim.CONST.DEBUG_IDS.NEWS)

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
        newP("19.4.2"),
        f.p .. "Fixed " .. f.bb("Queue Work Orders") .. " PvP Recipe Issues",
        f.p .. "Fixed " .. f.bb("Queue First Crafts") .. " Ignore Spark also ignoring PvP Recipes",
        f.p .. "Fixed " .. f.bb("Queue Work Orders") .. " Ignore Spark also ignoring PvP Recipes",
        f.p .. "Fixed " .. f.bb("Auctionator Pricing") .. " Error sometimes occuring on init",
        f.p .. "Fixed " .. f.bb("Alt Recipe Scans") .. " Cached Data Deserialization",
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
