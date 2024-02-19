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
        newP("15.0.14"),
        f.P .. "Introducing " .. f.bb("Sub Recipes Optimization"),
        f.a .. "- " .. f.l("CraftSim") .. " is now able to optimize and cache",
        f.a .. "  crafting cost details for reagents",
        f.a .. "  " .. f.r("This is still experimental"),
        f.P .. f.g("CraftQueue"),
        f.p .. "- New Recipe Queue Mode: " .. f.bb("Target Mode"),
        f.p .. "- Configure a target item count for a queued recipe",
        f.p .. "- This is default for any automatically queued sub crafts",
        f.p .. "- A minimum craft amount is calculated by CraftSim",
        f.a .. "- But can be adjusted per recipe when editing",
        f.a .. "- Adjusting the craft amount for a queued recipe now",
        f.a .. "  requires ENTER to be pressed to update the queue",
        f.P .. f.g("Cost Details") .. " renamed to " .. f.g("Cost Optimization"),
        f.a .. "- Now shows the lowest expected crafting costs for an item",
        f.a .. "  if you or one of your alts are able to craft it (and its cached)",
        f.a .. "- Subcrafting costs are considered if you enable it in the module",
        f.a .. "- Now has a " .. f.g("Sub Recipe Options") .. " Tab to configure sub crafts",
        f.P .. f.g("Recipe Scan"),
        f.a .. "- Added a Recipe Scan Option to toggle " .. f.bb("sub crafts"),
        f.a .. "- Current cooldown charges are now shown besides",
        f.a .. "  the recipe name",
        f.a .. "- The alt profession list is now more consistently sorted",
        f.P .. f.g("Average Profit"),
        f.a .. "- Removed Explanation and Statistics Button (-> new modules)",
        f.a .. "- Refactored the profit and stat weight display and added tooltips",
        f.P .. f.g("Explanations"),
        f.a .. "- New Module moved from Average Profit",
        f.p .. f.bb("Cooldowns"),
        f.a .. "- Fixed a bug when displaying a cooldown that is fully charged",
        f.p .. f.bb("CraftResults"),
        f.a .. "- Fixed a Typo in the Item Result Log saying 'Profit: :'",
        f.a .. "  instead of 'Saved Reagents:",
        f.p .. "Fixed a bug leading to an error when moving a frame while crafting",
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
    local oldChecksum = CraftSimOptions.newsChecksum
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

        print("showing news, old / new cs: " .. tostring(CraftSimOptions.newsChecksum) .. "/" .. tostring(newChecksum))
        CraftSimOptions.newsChecksum = newChecksum

        local infoFrame = CraftSim.GGUI:GetFrame(CraftSim.MAIN.FRAMES, CraftSim.CONST.FRAMES.INFO)
        -- resize
        infoFrame:SetSize(CraftSim.CONST.infoBoxSizeX, CraftSim.CONST.infoBoxSizeY)
        infoFrame.originalX = CraftSim.CONST.infoBoxSizeX
        infoFrame.originalY = CraftSim.CONST.infoBoxSizeY
        infoFrame.showInfo(newsText)
    end)
end
