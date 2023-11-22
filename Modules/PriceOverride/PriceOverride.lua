CraftSimAddonName, CraftSim = ...

CraftSim.PRICE_OVERRIDE = {}

---@class CraftSim.PriceOverride
---@field globalOverrides CraftSim.PriceOverrideData[]
---@field recipeResultOverrides CraftSim.PriceOverrideData[][]

---@type CraftSim.PriceOverride
CraftSimPriceOverridesV2 = CraftSimPriceOverridesV2 or {
    globalOverrides = {}, -- mapped itemID -> data
    recipeResultOverrides = {}, -- mapped recipeID -> resultQualityID -> data
}

---@class CraftSim.PriceOverrideData
---@field recipeID number
---@field itemID number
---@field price number
---@field qualityID? number -- used for result item mappings in a recipe

local print = CraftSim.UTIL:SetDebugPrint(CraftSim.CONST.DEBUG_IDS.PRICE_OVERRIDE)

function CraftSim.PRICE_OVERRIDE:ClearAll()
    CraftSimPriceOverridesV2.globalOverrides = {}
    CraftSimPriceOverridesV2.recipeResultOverrides = {}
end

---@param overrideData CraftSim.PriceOverrideData
function CraftSim.PRICE_OVERRIDE:SetGlobalOverride(overrideData)
    CraftSimPriceOverridesV2.globalOverrides[overrideData.itemID] = overrideData
end

---@param overrideData CraftSim.PriceOverrideData
function CraftSim.PRICE_OVERRIDE:SetResultOverride(overrideData)
    CraftSimPriceOverridesV2.recipeResultOverrides[overrideData.recipeID] = CraftSimPriceOverridesV2.recipeResultOverrides[overrideData.recipeID] or {}
    CraftSimPriceOverridesV2.recipeResultOverrides[overrideData.recipeID][overrideData.qualityID] = overrideData
end

function CraftSim.PRICE_OVERRIDE:RemoveResultOverride(recipeID, qualityID)
    if CraftSimPriceOverridesV2.recipeResultOverrides[recipeID] then
        CraftSimPriceOverridesV2.recipeResultOverrides[recipeID][qualityID] = nil
    end
end

function CraftSim.PRICE_OVERRIDE:RemoveGlobalOverride(itemID)
    CraftSimPriceOverridesV2.globalOverrides[itemID] = nil
end

---@param itemID number
---@return number? price nil when no override exists
function CraftSim.PRICE_OVERRIDE:GetGlobalOverridePrice(itemID) 
    local overrideData = CraftSimPriceOverridesV2.globalOverrides[itemID]

    if overrideData then
        return overrideData.price
    end
end

---@param recipeID number
---@param qualityID number
---@return number? price nil when no override exists
function CraftSim.PRICE_OVERRIDE:GetResultOverridePrice(recipeID, qualityID) 
    local overrideRecipeData = CraftSimPriceOverridesV2.recipeResultOverrides[recipeID]

    if overrideRecipeData then
        local overrideData = overrideRecipeData[qualityID]

        if overrideData then
            return overrideData.price
        end
    end
end

function CraftSim.PRICE_OVERRIDE:GetResultOverride(recipeID, qualityID)
    local overrideRecipeData = CraftSimPriceOverridesV2.recipeResultOverrides[recipeID]

    if overrideRecipeData then
        return overrideRecipeData[qualityID]
    end
end
function CraftSim.PRICE_OVERRIDE:GetGlobalOverride(itemID)
    return CraftSimPriceOverridesV2.globalOverrides[itemID]
end

---@param overrideDropdownData CraftSim.PRICE_OVERRIDE.overrideDropdownData
function CraftSim.PRICE_OVERRIDE:SaveOverrideData(recipeID, overrideDropdownData)
    
    local exportMode = CraftSim.UTIL:GetExportModeByVisibility()
    local priceOverrideFrame = nil
    if exportMode == CraftSim.CONST.EXPORT_MODE.WORK_ORDER then
        priceOverrideFrame = CraftSim.GGUI:GetFrame(CraftSim.MAIN.FRAMES, CraftSim.CONST.FRAMES.PRICE_OVERRIDE_WORK_ORDER)
    else
        priceOverrideFrame = CraftSim.GGUI:GetFrame(CraftSim.MAIN.FRAMES, CraftSim.CONST.FRAMES.PRICE_OVERRIDE)
    end

    local price = priceOverrideFrame.content.overrideOptions.currencyInputGold.total or 0

    local overrideData = {
        recipeID = recipeID,
        itemID = overrideDropdownData.item:GetItemID(),
        qualityID = overrideDropdownData.qualityID,
        price = price,
    }
    
    if overrideDropdownData.isResult then
        CraftSim.PRICE_OVERRIDE:SetResultOverride(overrideData)
    else
        CraftSim.PRICE_OVERRIDE:SetGlobalOverride(overrideData)
    end
end

---@param overrideDropdownData CraftSim.PRICE_OVERRIDE.overrideDropdownData
function CraftSim.PRICE_OVERRIDE:RemoveOverrideData(recipeID, overrideDropdownData)
    if overrideDropdownData.isResult then
        CraftSim.PRICE_OVERRIDE:RemoveResultOverride(recipeID, overrideDropdownData.qualityID)
    else
        CraftSim.PRICE_OVERRIDE:RemoveGlobalOverride(overrideDropdownData.item:GetItemID())
    end
end
