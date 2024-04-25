---@class CraftSim
local CraftSim = select(2, ...)

CraftSim.PRICEDATA = {}

CraftSim.PRICEDATA.noPriceDataLinks = {}

CraftSim.PRICEDATA.overrideResultProfits = {} -- mapped by qualityID
CraftSim.PRICEDATA.overrideCraftingCosts = nil

local print = CraftSim.DEBUG:SetDebugPrint(CraftSim.CONST.DEBUG_IDS.PRICEDATA)

---@class CraftSim.PriceData.PriceInfo
---@field ahPrice number
---@field priceOverride? number
---@field isAHPrice boolean
---@field noAHPriceFound boolean
---@field isOverride boolean
---@field noPriceSource boolean
---@field isExpectedCost boolean
---@field expectedCostsData? CraftSim.ExpectedCraftingCostsData

---Wrapper for Price Source addons price fetch by itemID
---@param itemID ItemID
---@param isReagent? boolean Use TSM Expression for materials
---@param considerSubCrafts? boolean
---@return number usedPrice
---@return CraftSim.PriceData.PriceInfo priceInfo
function CraftSim.PRICEDATA:GetMinBuyoutByItemID(itemID, isReagent, forceAHPrice, considerSubCrafts)
    local ahPrice = CraftSim.PRICE_API:GetMinBuyoutByItemID(itemID, isReagent)
    ---@type CraftSim.PriceData.PriceInfo
    local priceInfo = {
        ahPrice = ahPrice or 0,
        noAHPriceFound = ahPrice == nil,
        isOverride = false,
        noPriceSource = false,
        isAHPrice = false,
        isExpectedCost = false,
    }

    if forceAHPrice then
        priceInfo.isAHPrice = true
        return priceInfo.ahPrice, priceInfo
    end
    -- check for overrides
    if isReagent then
        local priceOverrideData = CraftSim.DB.PRICE_OVERRIDE:GetGlobalOverride(itemID)
        if priceOverrideData then
            priceInfo.isOverride = true
            return priceOverrideData.price, priceInfo
        end

        if considerSubCrafts then
            -- get costs from set crafter
            local itemRecipeData = CraftSim.DB.ITEM_RECIPE:Get(itemID)
            -- only use if set crafter exists, has cached optimized costs and can even craft that item with a chance higher than 0
            if itemRecipeData then
                local recipeCrafter = CraftSim.DB.RECIPE_SUB_CRAFTER:GetCrafter(itemRecipeData
                    .recipeID)
                if recipeCrafter then
                    local allowCooldown = CraftSim.DB.OPTIONS:Get("COST_OPTIMIZATION_SUB_RECIPE_INCLUDE_COOLDOWNS") or
                        not CraftSim.DB.CRAFTER:IsRecipeCooldownRecipe(recipeCrafter, itemRecipeData.recipeID)
                    if allowCooldown then
                        local itemOptimizedCostsData = CraftSim.DB.ITEM_OPTIMIZED_COSTS:Get(itemID,
                            recipeCrafter)
                        if itemOptimizedCostsData and itemOptimizedCostsData.craftingChanceMin > 0 then
                            priceInfo.expectedCostsData = itemOptimizedCostsData
                            -- only set as used price if its lower then ah price or no ah price for this item exists
                            if priceInfo.noAHPriceFound or itemOptimizedCostsData.expectedCostsMin < priceInfo.ahPrice then
                                priceInfo.isExpectedCost = true
                                return itemOptimizedCostsData.expectedCostsMin, priceInfo
                            end
                        end
                    end
                end
            end
        end
    end

    if not CraftSim.PRICE_APIS.available then
        priceInfo.noPriceSource = true
        return 0, priceInfo
    end

    priceInfo.isAHPrice = true
    return priceInfo.ahPrice, priceInfo
end

function CraftSim.PRICEDATA:GetMinBuyoutByItemLink(itemLink, isReagent)
    if not CraftSim.PRICE_APIS.available then
        return 0
    end

    local minbuyout = CraftSim.PRICE_API:GetMinBuyoutByItemLink(itemLink, isReagent)
    if minbuyout == nil then
        if CraftSim.PRICEDATA.noPriceDataLinks[itemLink] == nil then
            -- not beautiful but hey, easy map
            CraftSim.PRICEDATA.noPriceDataLinks[itemLink] = itemLink
        end
        minbuyout = 0
    end
    return minbuyout
end

--- returns the amount of the item the player has in the AH or nil if no price source addon is loaded that can fetch this for us
---@param idOrLink? number | string
---@return number? auctionAmount
function CraftSim.PRICEDATA:GetAuctionAmount(idOrLink)
    if C_AddOns.IsAddOnLoaded(CraftSimTSM.name) then
        return CraftSimTSM:GetAuctionAmount(idOrLink)
    else
        return
    end
end
