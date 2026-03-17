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

local print = CraftSim.DEBUG:RegisterDebugID("Data.News")
local function newP(v) return f.l("\nPatch Notes " .. v .. "\n") end
local function collab(gl) return f.a .. "- Thanks to " .. f.bb(gl) end

---@param itemMap table<string, ItemMixin>
function CraftSim.NEWS:GET_NEWS(itemMap)
    
    local supporterListUpdate = f.p .. f.patreon("Supporter List Update ") ..
        CraftSim.MEDIA:GetAsTextIcon(CraftSim.MEDIA.IMAGES.PIXEL_HEART, 0.15)
    local news = {
        f.bb("Hello and thank you for using CraftSim! ( You are awesome! )\n"),
        newP("21.3.3"),
        f.pg .. f.bb("RecipeScan"),
        f.a .. "- Added option to auto switch to active profession scan row",
        f.pg .. f.bb("CraftQueue"),
        f.a .. "- Fixed queuing first crafts adding to already queued recipes",
        f.pg .. f.bb("Simulation Mode"),
        f.a .. "- Fixed visibility and anchoring issues in work order sim ui",
        f.p .. "Fixed error when toggling concentration",

        newP("21.3.2"),
        f.PG .. f.bb("CraftQueue"),
        f.a .. "- Added patron work order filter support for new rewards",
        collab(CraftSim.NEWS.GITHUB_COLLABS.NETOUSS),
        f.PG .. "Fixed Reagent Optimization for 2-Quality Recipes",
        collab("https://github.com/N-Sousa"),
        f.p .. "Internal Code Cleanups regarding Module Structure",
        newP("21.3.1"),
        f.PG .. "Fixed incorrect consideration of legacy profession gear",
        f.p .. "Update DB2 Data: 12.0.1.66384",
        collab(CraftSim.NEWS.GITHUB_COLLABS.AVILENE),
        f.PG .. "Fixed identification of tool enchant stats",
        newP("21.3.0"),
        f.PG .. "Added info elements about the time when a recipe",
        f.a .. " has enough concentration again",
        f.PG .. f.bb("Simulation Mode"),
        f.a .. "- Fixed Optional Currency Reagents",
        f.a .. "- Fixed Reagents List initializing zero quantity",
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
