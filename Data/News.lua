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
        newP("19.8.2"),
        f.p .. f.bb("CraftBuffs"),
        f.a .. "Fixed Ignition Buff Base Stats",
        f.a .. "- Thanks to " .. f.bb("https://github.com/avilene"),
        newP("19.8.1"),
        f.p .. f.bb("CraftBuffs"),
        f.a .. "Updated Weaver's Buffs",
        f.a .. "- Thanks to " .. f.bb("https://github.com/avilene"),
        newP("19.8.0"),
        f.P .. f.bb("CraftQueue") .. " - " .. f.g("Queue Work Orders"),
        f.a .. "- Added support for a custom " .. f.bb("Reagent Bag Value"),
        f.p .. "Fixed " .. f.bb("CraftLog") .. " lua error for pvp items",
        newP("19.7.5"),
        f.p .. "Fixed " .. f.bb("Reagent Optimization") .. " for non quality recipes",
        f.p .. "Fixed " .. f.bb("RestockAmount") .. " for TSM Expression allowing 0",
        f.a .. "Thanks to " .. f.bb("https://github.com/chris-merritt"),
        f.p .. "Fixed " .. f.bb("QuickBuy") .. " for lists longer than 20 items",
        f.a .. "Thanks to " .. f.bb("https://github.com/syspro86"),
        newP("19.7.4"),
        f.p .. "11.0.7.58533 Data Update",
        newP("19.7.3"),
        f.p .. "11.0.7.58238 Data Update",
        newP("19.7.2"),
        f.p .. "Fixed " .. f.bb("QuickBuy") .. " reset on list refresh",
        f.a .. "- Now always starts a new search",
        f.p .. "Locals Update",
        f.a .. "- " .. f.bb("esES") .. " by: " .. f.bb("https://github.com/GarikGangrel")
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
