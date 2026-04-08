---@class CraftSim
local CraftSim = select(2, ...)

local L = CraftSim.UTIL:GetLocalizer()
local f = CraftSim.GUTIL:GetFormatter()

---@class CraftSim.ITEM_TOOLTIPS
CraftSim.ITEM_TOOLTIPS = {}

local tooltipHooked = false

--- Player name cannot contain '-'; realm may. Returns nil if not a "Name-Realm" UID.
---@param crafterUID CrafterUID
---@return string? name
---@return string? realm
local function ParseCrafterNameRealm(crafterUID)
    local pos = string.find(crafterUID, "-", 1, true)
    if not pos or pos < 2 then
        return nil
    end
    local name = string.sub(crafterUID, 1, pos - 1)
    local realm = string.sub(crafterUID, pos + 1)
    if realm == "" then
        return nil
    end
    return name, realm
end

--- How many times each character name appears (case-insensitive), for "Name-Realm" UIDs only.
---@param crafterUIDs CrafterUID[]
---@return table<string, number> lowerNameToCount
local function CountCrafterNames(crafterUIDs)
    ---@type table<string, number>
    local counts = {}
    for _, uid in ipairs(crafterUIDs) do
        local name = ParseCrafterNameRealm(uid)
        if name then
            local key = string.lower(name)
            counts[key] = (counts[key] or 0) + 1
        end
    end
    return counts
end

--- Name only if unique in the list; "Name-Realm" (full realm) when the same name appears on multiple characters.
---@param crafterUID CrafterUID
---@param nameCounts table<string, number>
---@return string
local function CrafterUIDToDisplayForList(crafterUID, nameCounts)
    local name, realm = ParseCrafterNameRealm(crafterUID)
    if not name or not realm then
        return crafterUID
    end
    local key = string.lower(name)
    if (nameCounts[key] or 0) <= 1 then
        return name
    end
    return name .. "-" .. realm
end

---@param crafterUID CrafterUID
---@param displayText string
---@return string
local function ColorizeCrafterByUID(crafterUID, displayText)
    local crafterClass = CraftSim.DB.CRAFTER:GetClass(crafterUID)
    if crafterClass then
        return C_ClassColor.GetClassColor(crafterClass):WrapTextInColorCode(displayText)
    end
    return f.grey(displayText)
end

--- Format a unix timestamp as a human-readable date+time string
---@param timestamp number
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
---@return string
local function FormatRegisteredCraftersList(crafterUIDs, maxShown)
    maxShown = math.max(1, math.min(50, math.floor(tonumber(maxShown) or 5)))
    local nameCounts = CountCrafterNames(crafterUIDs)
    local limit = math.min(#crafterUIDs, maxShown)
    local parts = {}
    for i = 1, limit do
        local uid = crafterUIDs[i]
        local display = CrafterUIDToDisplayForList(uid, nameCounts)
        tinsert(parts, ColorizeCrafterByUID(uid, display))
    end
    local text = table.concat(parts, ", ")
    local more = #crafterUIDs - limit
    if more > 0 then
        text = text .. " " .. f.grey(string.format(L("REGISTERED_CRAFTERS_ITEM_TOOLTIP_MORE"), more))
    end
    return text
end

--- Register a TooltipDataProcessor post-call to append CraftSim item information
function CraftSim.ITEM_TOOLTIPS:HookItemTooltips()
    if tooltipHooked then return end
    tooltipHooked = true

    TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Item, function(tooltip, tooltipInfo)
        if not tooltipInfo or not tooltipInfo.id then return end

        local itemID = tooltipInfo.id
        local itemLink = tooltipInfo.hyperlink

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

        if not showLastCost and not showRegistered then
            return
        end

        tooltip:AddLine(L("LAST_CRAFTING_COST_TOOLTIP_HEADER"))

        if showLastCost then
            local costText = CraftSim.UTIL:FormatMoney(cost, true)
            local timeText = FormatTimestamp(timestamp)
            tooltip:AddDoubleLine(L("LAST_CRAFTING_COST_TOOLTIP_LABEL"), costText)
            if crafterUID then
                tooltip:AddDoubleLine(L("LAST_CRAFTING_COST_TOOLTIP_CRAFTER"),
                    ColorizeCrafterByUID(crafterUID, crafterUID))
            end
            tooltip:AddDoubleLine(L("LAST_CRAFTING_COST_TOOLTIP_UPDATED"), f.grey(timeText))
        end

        if showRegistered then
            tooltip:AddDoubleLine(L("REGISTERED_CRAFTERS_ITEM_TOOLTIP_LABEL"), FormatRegisteredCraftersList(
                registeredUIDs,
                CraftSim.DB.OPTIONS:Get(CraftSim.CONST.GENERAL_OPTIONS.REGISTERED_CRAFTERS_ITEM_TOOLTIP_MAX)))
        end
    end)
end
