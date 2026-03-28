---@class CraftSim
local CraftSim = select(2, ...)

local GUTIL = CraftSim.GUTIL
local L = CraftSim.UTIL:GetLocalizer()
local f = GUTIL:GetFormatter()

---@class CraftSim.ITEM_TOOLTIPS
CraftSim.ITEM_TOOLTIPS = {}

local tooltipHooked = false

--- Format a unix timestamp as a human-readable date+time string
---@param timestamp number
---@return string
local function FormatTimestamp(timestamp)
    if not timestamp then return "?" end
    local d = date("*t", timestamp)
    if not d then return "?" end
    return string.format("%02d.%02d.%d %02d:%02d", d.day, d.month, d.year, d.hour, d.min)
end

--- Hook GameTooltip to append last crafting cost information for items
function CraftSim.ITEM_TOOLTIPS:HookItemTooltips()
    if tooltipHooked then return end
    tooltipHooked = true

    local function addCraftingCostLine(tooltip)
        local _, itemLink = tooltip:GetItem()
        if not itemLink then return end

        local itemID = select(1, C_Item.GetItemInfoInstant(itemLink))
        if not itemID then return end

        local data
        -- Try quality-specific lookup first (for gear where itemID is shared per quality)
        local qualityID = GUTIL:GetQualityIDFromLink(itemLink)
        if qualityID and qualityID > 0 then
            data = CraftSim.DB.LAST_CRAFTING_COST:GetByItemIDAndQuality(itemID, qualityID)
        end
        -- Fall back to plain itemID lookup (for non-gear / reagents)
        if not data then
            data = CraftSim.DB.LAST_CRAFTING_COST:GetByItemID(itemID)
        end

        if data and data.cost and data.cost > 0 then
            local costText = CraftSim.UTIL:FormatMoney(data.cost, true)
            local timeText = FormatTimestamp(data.timestamp)
            tooltip:AddLine(L("LAST_CRAFTING_COST_TOOLTIP_LABEL") .. costText)
            tooltip:AddLine(L("LAST_CRAFTING_COST_TOOLTIP_UPDATED") .. timeText)
            tooltip:Show()
        end
    end

    GameTooltip:HookScript("OnTooltipSetItem", addCraftingCostLine)

    -- Also hook shopping tooltips if available
    if ShoppingTooltip1 then
        ShoppingTooltip1:HookScript("OnTooltipSetItem", addCraftingCostLine)
    end
    if ShoppingTooltip2 then
        ShoppingTooltip2:HookScript("OnTooltipSetItem", addCraftingCostLine)
    end
end
