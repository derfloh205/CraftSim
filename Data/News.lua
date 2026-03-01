---@class CraftSim
local CraftSim = select(2, ...)

local GUTIL = CraftSim.GUTIL
local f = GUTIL:GetFormatter()

CraftSim.NEWS = {}

CraftSim.NEWS.GITHUB_COLLABS = {
 AVILENE = "https://github.com/avilene",
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
        newP("21.0.2"),
        f.pg .. "Combat Aura Lua Error Fix",
        f.pg .. "Salvage Hearty Food Bug Fix",
        f.pg .. "Alchemy Research Bug Fix",
        collab("https://github.com/clarklwilliamson"),
        newP("21.0.1"),
        f.p .. "MaxQ2 Recipes: Hotfixed incorrect quality threshold calculation",
        newP("21.0.0 - " .. f.e("Midnight")),
        f.PG .. f.l("Midnight Early Access Updates"),
        f.pg .. f.g("HUGE Thank you to all contributors and supporters"),
        f.a .. "Especially to " .. f.bb("Arlie") .. " and " .. f.bb("CodePoet"),
        f.a .. "for their help with patching CraftSim for Midnight",
        newP("20.4.0"),
        f.p .. f.bb("Recipe Scan"),
        f.a .. "- Added TSM Sale Rate and Profit Margin filters",
        newP("20.3.10"),
        f.p .. "Fixed quality of resulting recipe items all being q1",
        collab("https://github.com/chris-merritt"),
        newP("20.3.9"),
        f.p .. "Migrated CustomerHistory Data Structure",
        newP("20.3.8"),
        f.P .. "Updated Percent Division Factors for Midnight",
        f.s .. "Fixed CraftQueue not recognizing crafts correctly",
        newP("20.3.7"),
        f.p .. "Updated Data for 12.0.0.65560",
        newP("20.3.6"),
        f.P .. "Fixes regarding Midnight Prepatch",
        f.P .. f.r("WARNING: ") .. "The " .. f.bb("Craft Buffs"),
        f.a .. "Module not working due to combat log restrictions",
        newP("20.3.4"),
        f.p .. "Updated Optional Reagent Data for 11.2.7.64704",
        f.p .. "Repaired Data Mining Scripts for Wago Tables",
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
