---@class CraftSim
local CraftSim = select(2, ...)

local L = CraftSim.LOCAL:GetLocalizer()
local f = CraftSim.GUTIL:GetFormatter()
local GUTIL = CraftSim.GUTIL

---@class CraftSim.ITEM_TOOLTIPS
CraftSim.ITEM_TOOLTIPS = {}

local tooltipHooked = false

--- Format a unix timestamp as a human-readable date+time string
---@param timestamp number?
---@return string
local function FormatTimestamp(timestamp)
    if not timestamp then return "?" end
    local d = date("*t", timestamp)
    if not d then return "?" end
    return string.format("%02d.%02d.%d %02d:%02d", d.day, d.month, d.year, d.hour, d.min)
end

--- Sorted list of crafter UIDs known for this item (recipe cache + optional last-cost DB).
---@param itemID ItemID
---@param itemLink string?
---@return CrafterUID[]
local function GetRegisteredCrafterUIDsForItem(itemID, itemLink)
    local seen = {}
    ---@type CrafterUID[]
    local ordered = {}

    local function add(uid)
        if uid and not seen[uid] then
            seen[uid] = true
            tinsert(ordered, uid)
        end
    end

    local itemRecipeData = CraftSim.DB.ITEM_RECIPE:Get(itemID)
    if itemRecipeData and itemRecipeData.crafters then
        for _, uid in ipairs(itemRecipeData.crafters) do
            add(uid)
        end
    end

    local lastCostEntries = itemLink and CraftSim.DB.LAST_CRAFTING_COST:GetByItemLink(itemLink)
        or CraftSim.DB.LAST_CRAFTING_COST:GetByItemID(itemID)
    if lastCostEntries then
        for uid, _ in pairs(lastCostEntries) do
            add(uid)
        end
    end

    table.sort(ordered)
    return ordered
end

--- Uses full list for duplicate-name detection; only the first maxShown names are listed.
---@param crafterUIDs CrafterUID[]
---@param maxShown number?
---@param showAllRealms boolean?
---@return string
local function FormatRegisteredCraftersList(crafterUIDs, maxShown, showAllRealms)
    maxShown = math.max(1, math.min(50, math.floor(tonumber(maxShown) or 5)))
    local nameCounts = CraftSim.UTIL:CountCrafterNamesByUIDList(crafterUIDs)
    local limit = math.min(#crafterUIDs, maxShown)
    local parts = {}
    for i = 1, limit do
        local uid = crafterUIDs[i]
        local display = CraftSim.UTIL:FormatCrafterUIDForPeerList(uid, nameCounts, showAllRealms)
        tinsert(parts, CraftSim.UTIL:ColorizeCrafterNameByUID(uid, display))
    end
    local text = table.concat(parts, ", ")
    local more = #crafterUIDs - limit
    if more > 0 then
        text = text .. " " .. f.grey(string.format(L("REGISTERED_CRAFTERS_ITEM_TOOLTIP_MORE"), more))
    end
    return text
end

--- Build list labels that contain a recipe for the given crafters.
--- Character list labels are prefixed with the crafter display name to disambiguate.
---@param recipeID RecipeID?
---@param crafterUIDs CrafterUID[]
---@param showAllRealms boolean?
---@return string[]
local function GetCraftListLabelsForRecipe(recipeID, crafterUIDs, showAllRealms)
    if not recipeID or #crafterUIDs == 0 then
        return {}
    end

    local nameCounts = CraftSim.UTIL:CountCrafterNamesByUIDList(crafterUIDs)
    local seen = {}
    local labels = {}

    for _, uid in ipairs(crafterUIDs) do
        local crafterDisplay = CraftSim.UTIL:FormatCrafterUIDForPeerList(uid, nameCounts, showAllRealms)
        local lists = CraftSim.DB.CRAFT_LISTS:GetAllLists(uid)
        for _, list in ipairs(lists) do
            if GUTIL:Find(list.recipeEntries or {}, function(entry) return entry.recipeID == recipeID end) then
                local label = list.name
                if not list.isGlobal then
                    label = crafterDisplay .. ": " .. label
                end
                if not seen[label] then
                    seen[label] = true
                    tinsert(labels, label)
                end
            end
        end
    end

    table.sort(labels)
    return labels
end

--- Register a TooltipDataProcessor post-call to append CraftSim item information
function CraftSim.ITEM_TOOLTIPS:HookItemTooltips()
    if tooltipHooked then return end
    tooltipHooked = true

    TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Item, function(tooltip, tooltipInfo)
        if not tooltipInfo or not tooltipInfo.id then return end

        local itemID = tooltipInfo.id
        local itemLink = tooltipInfo.hyperlink

        local surplusStorageID = CraftSim.PATRON_MOXIE_SURPLUS:GetVendorSurplusBagStorageCurrencyID(itemID)
        local hadSurplusBagMapping = surplusStorageID ~= nil

        local crafterUID, cost, timestamp
        if itemLink then
            crafterUID, cost, timestamp = CraftSim.DB.LAST_CRAFTING_COST:GetCheapestByItemLink(itemLink)
        else
            crafterUID, cost, timestamp = CraftSim.DB.LAST_CRAFTING_COST:GetCheapestByItemID(itemID)
        end

        local showLastCost = cost and cost > 0
        local registeredUIDs = CraftSim.DB.OPTIONS:Get(CraftSim.CONST.GENERAL_OPTIONS
                .SHOW_REGISTERED_CRAFTERS_ITEM_TOOLTIP)
            and GetRegisteredCrafterUIDsForItem(itemID, itemLink)
            or {}
        local showRegistered = #registeredUIDs > 0
        local showAllRealms = IsShiftKeyDown()

        local itemRecipeData = CraftSim.DB.ITEM_RECIPE:Get(itemID)
        local craftListLabels = showRegistered and GetCraftListLabelsForRecipe(itemRecipeData and itemRecipeData.recipeID, registeredUIDs, showAllRealms) or
            {}
        local showCraftLists = #craftListLabels > 0

        if not showLastCost and not showRegistered and not showCraftLists and not hadSurplusBagMapping then
            return
        end

        tooltip:AddLine(L("LAST_CRAFTING_COST_TOOLTIP_HEADER"))

        if hadSurplusBagMapping and surplusStorageID then
            local totalCopper = CraftSim.PATRON_MOXIE_SURPLUS:GetSurplusTurnInAHValue(surplusStorageID)
            if totalCopper then
                tooltip:AddDoubleLine(f.white(L("PATRON_MOXIE_SURPLUS_BAG_ITEM_TOOLTIP_EXPECTED_VALUE")),
                    CraftSim.UTIL:FormatMoney(totalCopper, true, nil, true))
            else
                tooltip:AddLine(L("CRAFT_QUEUE_PATRON_MOXIE_SURPLUS_NO_DATA_TOOLTIP"), 0.65, 0.65, 0.65, true)
            end
        end

        if hadSurplusBagMapping and (showLastCost or showRegistered) then
            tooltip:AddLine(" ")
        end

        ---@type CrafterUID[]
        local uidsForDupCheck
        if #registeredUIDs > 0 then
            uidsForDupCheck = registeredUIDs
        elseif crafterUID then
            uidsForDupCheck = { crafterUID }
        else
            uidsForDupCheck = {}
        end
        local nameCounts = CraftSim.UTIL:CountCrafterNamesByUIDList(uidsForDupCheck)

        if showLastCost then
            local costText = CraftSim.UTIL:FormatMoney(cost, true)
            local timeText = FormatTimestamp(timestamp)
            tooltip:AddDoubleLine(L("LAST_CRAFTING_COST_TOOLTIP_LABEL"), costText)
            if crafterUID then
                local crafterDisplay = CraftSim.UTIL:FormatCrafterUIDForPeerList(crafterUID, nameCounts, showAllRealms)
                tooltip:AddDoubleLine(L("LAST_CRAFTING_COST_TOOLTIP_CRAFTER"),
                    CraftSim.UTIL:ColorizeCrafterNameByUID(crafterUID, crafterDisplay))
            end
            tooltip:AddDoubleLine(L("LAST_CRAFTING_COST_TOOLTIP_UPDATED"), f.grey(timeText))
        end

        if showRegistered then
            tooltip:AddDoubleLine(L("REGISTERED_CRAFTERS_ITEM_TOOLTIP_LABEL"), FormatRegisteredCraftersList(
                registeredUIDs,
                CraftSim.DB.OPTIONS:Get(CraftSim.CONST.GENERAL_OPTIONS.REGISTERED_CRAFTERS_ITEM_TOOLTIP_MAX),
                showAllRealms))
        end

        if showCraftLists then
            tooltip:AddDoubleLine("Craft Lists", table.concat(craftListLabels, ", "))
        end
    end)
end
