---@class CraftSim
local CraftSim = select(2, ...)

CraftSim.PRICE_OVERRIDE = {}

local print = CraftSim.DEBUG:RegisterDebugID("Modules.PriceOverride")

---@param overrideDropdownData CraftSim.PRICE_OVERRIDE.overrideDropdownData
function CraftSim.PRICE_OVERRIDE:DeleteOverrideDataByDropdown(recipeID, overrideDropdownData)
    if overrideDropdownData.isResult then
        CraftSim.DB.PRICE_OVERRIDE:DeleteResultOverride(recipeID, overrideDropdownData.qualityID)
    else
        CraftSim.DB.PRICE_OVERRIDE:DeleteGlobalOverride(overrideDropdownData.item:GetItemID())
    end
end

---@param recipeID RecipeID
---@param overrideDropdownData CraftSim.PRICE_OVERRIDE.overrideDropdownData
function CraftSim.PRICE_OVERRIDE:SaveOverrideDataByDropdown(recipeID, overrideDropdownData)
    local exportMode = CraftSim.UTIL:GetExportModeByVisibility()
    local priceOverrideFrame = nil
    if exportMode == CraftSim.CONST.EXPORT_MODE.WORK_ORDER then
        priceOverrideFrame = CraftSim.GGUI:GetFrame(CraftSim.INIT.FRAMES, CraftSim.CONST.FRAMES
            .PRICE_OVERRIDE_WORK_ORDER)
    else
        priceOverrideFrame = CraftSim.GGUI:GetFrame(CraftSim.INIT.FRAMES, CraftSim.CONST.FRAMES.PRICE_OVERRIDE)
    end

    local price = priceOverrideFrame.content.overrideOptions.currencyInputGold.total or 0

    local overrideData = {
        recipeID = recipeID,
        itemID = overrideDropdownData.item:GetItemID(),
        qualityID = overrideDropdownData.qualityID,
        price = price,
    }

    if overrideDropdownData.isResult then
        CraftSim.DB.PRICE_OVERRIDE:SaveResultOverride(overrideData)
    else
        CraftSim.DB.PRICE_OVERRIDE:SaveGlobalOverride(overrideData)
    end
end
