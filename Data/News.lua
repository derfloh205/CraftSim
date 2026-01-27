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
        newP("20.3.3"),
        f.p .. "Updated Specialization Data for 11.2.5.64502",
        newP("20.3.2"),
        f.p .. "Updated Specialization Data for 11.2.5.63906",
        f.p .. "Customer History: Lower loading performance impact",
        newP("20.3.1"),
        f.s .. "Fixed craft log sometimes not counting crafts",
        f.a .. "when crafting with low frame rate",
        collab("https://github.com/shadowmutant"),
        f.p .. "Added missing recipe data update after stat weight", 
        f.a .. "calculation",
        collab("https://github.com/shadowmutant"),
        f.p .. "Fixed resourcefulness consideration for salvage recipes",
        collab("https://github.com/shadowmutant"),
        newP("20.2.4"),
        f.p .. "Updated Specialization Data for 11.2.5",
        newP("20.2.3"),
        f.p .. "Fixed 'nil' errors for sub recipe optimizations",
        collab(self.GITHUB_COLLABS.AVILENE),
        f.p .. "Updated Specialization Data",
        newP("20.2.2"),
        f.p .. "Fixed caching not considering profession gear",
        f.p .. "Fixed caching returning before concentration data is set",
        f.p .. "Fixed gear cache not clearing before adding new gear",
        newP("20.2.1"),
        f.p .. "Fixed work orders incrementing on new queue scan",
        collab(self.GITHUB_COLLABS.AVILENE),
        newP("20.2.0"),
        f.s .. "Added Option to automatically create an",
        f.a .. "Auctionator Shopping List after finishing",
        f.a .. "a " .. f.bb("Queue Favorites") .. " Scan",
        f.p .. "Added chat window notification upon",
        f.a .. "Shopping List creation",
        newP("20.1.1"),
        f.P .. f.g("Improved Optimization Performance"),
        f.a .. "- by introducing client api response caching",
        collab("https://github.com/thebigjc"),
        newP("20.0.0"),
        f.P .. f.g("Improved Optimization Performance"),
        f.a .. "- for reagent optimization and",
        f.a .. "- and concentration optimization",
        collab("https://github.com/thebigjc"),
        f.p .. "Fixed nil error when using gear optimizations",
        f.a .. "when scanning multiple characters",
        newP("19.9.0"),
        f.P .. f.g("Updated Gear Optimization Logic"),
        f.a .. "Consider empty slots only if not enough gear",
        f.a .. "Prefer highest item level for accessories",
        f.a .. "This drastically speeds up the optimization",
        f.s .. f.bb("Queue Favorites") .. " now also optimizes gear",
        f.p .. "Updated depricated bag and bank slot constants",
        collab("https://github.com/chris-merritt"),
        newP("19.8.9"),
        f.P .. "New option to only queue profitable work orders",
        collab("https://github.com/JH0Ni-github"),
        f.p .. "Bank Event Fix",
        collab("https://github.com/Prejudice182"),
        newP("19.8.8"),
        f.P .. "11.2.0.62417 Data Update",
        f.p .. "Inventory Update Fixes",
        collab(self.GITHUB_COLLABS.AVILENE),
        f.p .. "Spanish Localization Fixes",
        collab("https://github.com/Prejudice182"),
        f.p .. "Craft Buffs detection fix for phials",
        collab("https://github.com/SanjoSolutions"),
        f.p .. "Old World Recipes fixes",
        collab("https://github.com/rowaasr13"),
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
