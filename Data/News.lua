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
        newP("17.1.4"),
        f.P .. "Implemented " .. f.g("TWW Craft Buffs"),
        f.p .. "Spec Info Update",
        newP("17.1.2"),
        f.P .. f.g("Sub Recipe Optimization") .. " is back",
        f.a .. "Added a toggle for reagent concentration usage",
        f.p .. "Data Update for " .. f.l("11.0.2.56196"),
        newP("17.1.1"),
        f.P .. f.bb("RecipeScan") .. " now has a " .. f.gold("Concentration ") .. "Toggle",
        f.p .. "Fixed duplicated Tailoring SpecInfo",
        f.p .. "Fixed " .. f.bb("OptionalReagents") .. " difficulty in simulation mode",
        newP("17.0.9"),
        f.p .. "Fixed " .. f.bb("TSM Price Expression ") .. "for Results used for Materials",
        f.p .. "Fixed " .. f.bb("Resourcefulness Extra Item Bonus") .. " being overinflated",
        f.p .. "Thanks for contributing: ",
        f.a .. f.bb("https://github.com/ergh99"),
        newP("17.0.8"),
        f.P .. "Concentration Cost Calc now also working in Retail",
        f.p .. "DB2 Data Update",
        supporterListUpdate,
        newP("17.0.7"),
        f.P .. "Optional Reagents now based on Datamined Data",
        f.P .. "Enchant Mapping now based on Datamined Data",
        f.P .. "Concentration Calculation now based on Datamined Data",
        f.a .. f.r("WARNING: ") .. "Cost Simulation only working in TWW BETA",
        f.P .. "Specialization Info now based on Datamined Data",
        f.P .. f.bb("Statistics Module"),
        f.a .. "Added a Concentration Cost Visualization",
        newP("17.0.6"),
        f.p .. "Fixed Enchanting Specialization Data Bug",
        newP("17.0.5"),
        f.P .. f.l("The War Within") .. " Update",
        f.P .. "Behold! Many updates to come to adapt" .. f.l(" CraftSim"),
        f.P .. "Goodbye " .. f.bb("Inspiration") .. "!",
        f.a .. "Inspiration support replaced with concentration support",
        f.a .. "to the new profession changes!",
        f.P .. f.g("BIG THANKS") .. " to " .. f.bb("Jechett") .. " from the",
        f.a .. f.l("www.wowforgefinder.com") .. " crew for all the",
        f.a .. "help with the specialization data mining!",
        f.P .. f.g("New: Concentration Tracker with Alt-Overview"),
        f.P .. f.b("Craft Results") .. " now includes a craft analyser tab",
        f.s .. "Thanks a lot to contributers:",
        f.a .. f.bb("https://github.com/Williwams"),
        f.a .. f.bb("https://github.com/rowaasr13"),
        f.a .. f.bb("https://github.com/EloMoose"),
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
