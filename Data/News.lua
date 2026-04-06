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
        newP("23.5.2"),
        f.p .. "Hotfix Recipe Scan Category Filter",
        collab("https://github.com/chris-merritt"),
        newP("23.5.1"),
        f.p .. "Fixed to Recipe Scan Filters",
        collab("https://github.com/chris-merritt"),
        f.p .. "Tooltip Taint fixes",
        collab("https://github.com/whatisboom"),
        newP("23.5.0"),
        f.PG .. f.bb("RecipeScan"),
        f.a .. "- Added " .. f.g("Category") .. " based filters",
        f.a .. "- Selectable in the respective Expansion Filter context menu",
        f.pg .. f.bb("Finishing Reagent Optimization"),
        f.a .. "- Added option to only use the highest valued reagents",
        f.a .. "  when soulbound finishing reagents are included",
        newP("23.4.0"),
        f.PG .. f.bb("CraftQueue"),
        f.a .. "- Added option to enforce shatter usage for crafting",
        f.a .. "- Fixed queue not updating after equipping gear via button",
        f.a .. "- Added option to include Moxie value in patron orders profit",
        collab(CraftSim.NEWS.GITHUB_COLLABS.AVILENE),
        f.pg .. f.bb("Cooldowns"),
        f.a .. "- Improved cooldown list with sorting and blacklist",
        collab(CraftSim.NEWS.GITHUB_COLLABS.AVILENE),
        f.p .. "Fixes to Finishing Reagent Optimization: Permutation based",
        f.a .. "- Now considers not using a reagent correctly",
        newP("23.3.0"),
        f.PG .. f.bb("Finishing Reagent Optimization"),
        f.a .. "- Added an optional " .. f.e("permutation based") .. " optimization algorithm",
        f.a .. "- This optimization is more accurate but also more",
        f.a .. "  performance intensive",
        f.pg .. f.bb("CraftQueue"),
        f.a .. "- Fixed the Ingenuity Offset Option sometimes queueing a recipe",
        f.a .. "  the player has not enough concentration for",
        collab(CraftSim.NEWS.GITHUB_COLLABS.AVILENE),
        f.pg .. f.bb("Profit Calculation"),
        f.a .. "- Fixed set knowledge points cost of first crafts being", 
        f.a .. "  included in the profit",
        collab(CraftSim.NEWS.GITHUB_COLLABS.AVILENE),
        f.p .. "Fixed crafting orders preload",
        newP("23.2.0"),
        f.PG .. f.g("Crafting orders load on first profession open after login"),
        f.PG .. f.bb("CraftQueue"),
        f.a .. "- Merged the " .. f.bb("Status") .. "/" .. f.bb("Tools") .. " column into the " .. f.bb("Craft") .. " button tooltip",
        f.a .. "- Display Cooldown charges inline in the queue",
        f.a .. "- Set gold value for Moxie rewards",
        collab(CraftSim.NEWS.GITHUB_COLLABS.AVILENE),
        f.pg .. f.bb("Fixes"),
        f.a .. "- Midnight concentration fixes",
        f.a .. "- Patron work order tooltip taint",
        newP("23.1.1"),
        f.PG .. f.bb("Collaborations"),
        f.a .. "- Added " .. f.g("Public Orders") .. " to the queueable work order type",
        collab(CraftSim.NEWS.GITHUB_COLLABS.AVILENE),
        f.a .. "- Updates to Korean Localization",
        collab("https://github.com/heartwell0710"),
        newP("23.1.0"),
        f.PG .. f.bb("CraftLists"),
        f.a .. "- " .. f.bb("RecipeScan") .. " integration for " .. f.bb("Craft Lists") .. " added",
        f.a .. "- Fixed Import and Export Functionality",
        f.a .. "- Enhanced and reworked CraftList configuration options",
        f.pg .. f.bb("CraftQueue"),
        f.a .. "- On craftable queued recipes where tools dont match",
        f.a .. " the craft (next) button changes to 'Equip'",
        f.pg .. f.b("Collaborations"),
        f.a .. "- Added Data for Midnight Shared Cooldowns",
        f.a .. "- Enhanced the Quick Access Shatter Button",
        collab(CraftSim.NEWS.GITHUB_COLLABS.AVILENE),
        f.p .. "Tooltip Taint Fixes",
        newP("23.0.3"),
        f.PG .. f.bb("CraftQueue"),
        f.a .. "- New Feature: " .. f.l("Craft Lists"),
        f.a .. "- Replaces " .. f.g("Queue Favorites"),
        f.a .. "- " .. f.bb("Add, Configure and Queue") .. " multiple list of recipes",
        f.a .. "- " .. f.bb("Import and Export") .. " your lists to share them with others",
        f.p .. "Your crafter favorites should have been migrated to a list",
        f.a .. "- If not, its possible to create a list from your favorite list",
        newP("22.0.1"),
        f.PG .. f.bb("CraftQueue"),
        f.a .. "- Added option to choose shatter reagent in quick access",
        collab(CraftSim.NEWS.GITHUB_COLLABS.AVILENE),
        newP("22.0.0"),
        f.PG .. f.r("Saved Variables Optimization"),
        f.PG .. "This led to significant data reduction in your SavedVariables",
        f.a .. "E.g: Data for my 12 Chars was reduced from 80mb -> 7mb",
        f.PG .. f.l("It is recommended to backup your " .. f.bb("Craftsim.lua") .. " file"),
        f.a .. f.l(" in your WTF\\Account\\<AccNr>\\SavedVariables folder"),
        f.a .. f.r("ALL CHARACTER DATA HAS BEEN WIPED"),
        f.a .. "We recommend to login on all alts and scan both professions",
        f.a .. "to rebuild the data with the new optimized format",
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
