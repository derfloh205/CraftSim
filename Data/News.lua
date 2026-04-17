---@class CraftSim
local CraftSim = select(2, ...)

local GUTIL = CraftSim.GUTIL
local f = GUTIL:GetFormatter()

CraftSim.NEWS = {}

CraftSim.NEWS.GITHUB_COLLABS = {
    AVILENE = "https://github.com/avilene",
    CODEPOET = "https://github.com/ergh99",
    NETOUSS = "https://github.com/netouss",
}

local Logger = CraftSim.DEBUG:RegisterLogger("News")
local function newP(v) return f.l("\nPatch Notes " .. v .. "\n") end
local function collab(gl) return f.a .. "- Thanks to " .. f.bb(gl) end

---@param itemMap table<string, ItemMixin>
function CraftSim.NEWS:GET_NEWS(itemMap)
    local supporterListUpdate = f.p .. f.patreon("Supporter List Update ") ..
        CraftSim.MEDIA:GetAsTextIcon(CraftSim.MEDIA.IMAGES.PIXEL_HEART, 0.15)
    local news = {
        f.bb("Hello and thank you for using CraftSim! ( You are awesome! )\n"),
        newP("26.0.1"),
        f.PG .. f.bb("Craft Queue"),
        f.a .. "- Added option to autoqueue work orders when opening",
        f.a .. "  a profession table for the first time after login",
        f.p .. "Fixed a loading error when Auctionator is not loaded",
        newP("26.0.0"),
        f.PG .. f.g("Outsourced Inventory Tracking to dedicated addons"),
        f.a .. "- For now, " .. f.bb("TSM") .. " and " .. f.bb("Syndicator") .. " are supported",
        f.a .. "- If none of them are loaded, only the current character",
        f.a .. "  will be considered",
        f.PG .. f.bb("Recipe Scan"),
        f.a .. "- Added option to only scan specific craftlists",
        f.a .. "- This will use their individual optimization options",
        f.PG .. f.bb("Customer History"),
        f.a .. "- Removed chat message recording and deleted old msg data",
        f.a .. "- Reason for this are taint and data amount issues",
        f.a .. "- For chat message history refer to dedicated addons like WIM",
        f.PG .. "Added support for blizzard native " .. f.g("Info Help Panels"),
        f.a .. "- First rollout was to craftqueue module",
        f.pg .. f.bb("Craft Lists"),
        f.a .. "- Added tooltips to show their configured options",
        f.a .. "- Added tooltips to show result item",
        collab(CraftSim.NEWS.GITHUB_COLLABS.AVILENE),
        f.p .. "Added nil checks for recipe scan to prevent lua errors",
        collab(CraftSim.NEWS.GITHUB_COLLABS.NETOUSS),
        f.p .. "UI Design Updates",
        newP("25.1.0"),
        f.PG .. f.bb("Average Profit -> Recipe Info"),
        f.a .. "- Module renamed",
        f.a .. "- Now provides the option to toggle multiple different",
        f.a .. "  info rows for a quick overview of your most important data",
        f.p .. "Profession stats handling updated",
        f.p .. "Internal code optimizations",
        collab(CraftSim.NEWS.GITHUB_COLLABS.AVILENE),
        newP("25.0.0"),
        f.PG .. f.g("New Disenchant Module"),
        f.a .. "- Basic disenchanting helper to mass disenchant",
        f.a .. "- Works with items in inventory, bank and warbank",
        f.a .. "- Use " .. f.l("/craftsim disenchant") .. " to open",
        newP("24.0.2"),
        f.p .. "Fixed lua error in craftqueue",
        collab(CraftSim.NEWS.GITHUB_COLLABS.AVILENE),
        f.p .. "Fixed queue amount issues when queueing craft lists",
        newP("24.0.0"),
        f.PG .. f.bb("Cost Optimization, Price Details, Price Overrides") .. f.l(" merged"),
        f.a .. "- Now called the " .. f.g("Pricing") .. " module",
        f.a .. "- Now also shows average crafting costs per item",
        f.a .. "  taking profession stats into account",
        f.PG .. f.g("Overhauled Addon Options Page"),
        f.a .. "- Now uses standardized blizzard options elements",
        collab(CraftSim.NEWS.GITHUB_COLLABS.AVILENE),
        f.pg .. f.bb("CraftQueue"),
        f.a .. "- Craft Lists can now set a max restock value per recipe",
        f.a .. "- Added option to take existing inventory into account",
        collab(CraftSim.NEWS.GITHUB_COLLABS.AVILENE),
        f.PG .. f.bb("Profession Gear"),
        f.a .. "- Equip process improved",
        f.pg .. f.g("New Slash Commands Added"),
        f.a .. "- Type " .. f.bb("/craftsim help") .. " to view",
        f.p .. "Taint Issue Fixes",
        f.p .. "Condition guards added regarding research recipes",
        f.p .. "Specialization Data Update for Engineering Build 12.0.1.66838",
        newP("23.5.2"),
        f.PG .. f.bb("Tooltips"),
        f.a .. "- New Tooltip Options to display crafter characters",
        f.a .. "  on Item Tooltips",
        collab(CraftSim.NEWS.GITHUB_COLLABS.AVILENE),
        f.p .. "Hotfix Recipe Scan Category Filter",
        collab("https://github.com/chris-merritt"),
        newP("23.5.1"),
        f.p .. "Fixed to Recipe Scan Filters",
        collab("https://github.com/chris-merritt"),
        f.p .. "Tooltip Taint fixes",
        collab("https://github.com/whatisboom"),
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

    -- Logger:LogDebug("replacing links in newstext:")
    -- Logger:LogDebug(newsText)

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
