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
        newP("17.3.2"),
        f.p .. "Specialization Talent Data Updated",
        newP("17.3.1"),
        f.p .. "Fixed " .. f.bb("CraftQueue Restock Profit Threshold"),
        newP("17.3.0"),
        f.P .. f.bb("Recipe Scan") .. ": " .. f.g("New Feature"),
        f.a ..
        "Press " ..
        CreateAtlasMarkup("NPE_LeftClick", 20, 20, 2) .. " + shift to queue recipe into " .. f.bb("Craft Queue"),
        f.s .. "Updated " .. f.bb("Specialization Data"),
        f.s .. f.bb("CraftQueue ") .. "should now support " .. f.e("Spark Reagents"),
        f.p .. itemMap.enchantingRod:GetItemLink() .. " Concentration Bonus now considered",
        newP("17.2.3"),
        f.p .. "Concentration Tracker character name column adaption",
        newP("17.2.2"),
        f.p .. f.l("ForgeFinder Export") .. " now exports both DF and TWW",
        newP("17.2.0"),
        f.P .. "Added an" .. f.l(" easycraft.io") .. " export",
        f.p .. "Fixed " .. f.bb("Skill Gain Finishing Reagents") .. " adding",
        f.a .. "difficulty instead of skill",
        f.p .. "Updated " .. f.bb("Optional Reagents Data"),
        newP("17.1.11"),
        f.P .. "Added an option to toggle " .. f.bb("Money String Format"),
        f.P .. "Addon options should now correctly open via button",
        f.p .. "Updated zhCN Locals",
        f.a .. "- Thank you " .. f.bb("https://github.com/LvWind"), supporterListUpdate,
        newP("17.1.10"),
        f.p .. f.bb("Concentration Tracker") .. " Tooltip now only lists",
        f.a .. "tracked professions from currently open expansion",
        f.p .. f.bb("Specialization Data Update") .. " for 11.0.2.56313",
        f.p .. "Changed general money format from",
        f.a ..
        GUTIL:FormatMoney(12345678, false, nil, false, true) .. " to " .. GUTIL:FormatMoney(12345678),
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
