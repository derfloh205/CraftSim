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

--- Register a TooltipDataProcessor post-call to append last crafting cost information for items
function CraftSim.ITEM_TOOLTIPS:HookItemTooltips()
    if tooltipHooked then return end
    tooltipHooked = true

    TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Item, function(tooltip, tooltipInfo)
        if not tooltipInfo or not tooltipInfo.id then return end

        local itemID = tooltipInfo.id
        local itemLink = tooltipInfo.hyperlink

        -- Try quality-specific lookup first (for gear where itemID is shared per quality)
        local crafterUID, cost, timestamp
        if itemLink then
            local qualityID = GUTIL:GetQualityIDFromLink(itemLink)
            if qualityID and qualityID > 0 then
                crafterUID, cost, timestamp = CraftSim.DB.LAST_CRAFTING_COST:GetCheapestByItemIDAndQuality(itemID, qualityID)
            end
        end
        -- Fall back to plain itemID lookup (for non-gear / reagents)
        if not cost then
            crafterUID, cost, timestamp = CraftSim.DB.LAST_CRAFTING_COST:GetCheapestByItemID(itemID)
        end

        if cost and cost > 0 then
            local costText = CraftSim.UTIL:FormatMoney(cost, true)
            local timeText = FormatTimestamp(timestamp)
            tooltip:AddLine(L("LAST_CRAFTING_COST_TOOLTIP_HEADER"))
            tooltip:AddDoubleLine(L("LAST_CRAFTING_COST_TOOLTIP_LABEL"), costText)
            if crafterUID then
                tooltip:AddDoubleLine(L("LAST_CRAFTING_COST_TOOLTIP_CRAFTER"), f.grey(crafterUID))
            end
            tooltip:AddDoubleLine(L("LAST_CRAFTING_COST_TOOLTIP_UPDATED"), f.grey(timeText))
            tooltip:Show()
        end
    end)
end
