---@class CraftSim
local CraftSim = select(2, ...)

local GUTIL = CraftSim.GUTIL

---@class CraftSim.OnCraftData : CraftSim.CraftSimObject
---@overload fun(options: CraftSim.OnCraftData.Options): CraftSim.OnCraftData
CraftSim.OnCraftData = CraftSim.CraftSimObject:extend()

local print = CraftSim.DEBUG:RegisterDebugID("Classes.OnCraftData")

---@class CraftSim.OnCraftData.Options
---@field recipeID RecipeID
---@field amount number
---@field recipeLevel number?
---@field craftingReagentInfoTbl CraftingReagentInfo[]?
---@field itemTargetLocation ItemLocationMixin?
---@field itemGUID string? for recrafts
---@field isEnchant boolean?
---@field isRecraft boolean?
---@field orderData CraftingOrderInfo?
---@field concentrating boolean?
---@field callerData table

---@param options CraftSim.OnCraftData.Options
function CraftSim.OnCraftData:new(options)
    self.recipeID = options.recipeID
    self.amount = options.amount or 1
    self.recipeLevel = options.recipeLevel
    self.craftingReagentInfoTbl = options.craftingReagentInfoTbl or {}
    self.itemTargetLocation = options.itemTargetLocation
    self.itemGUID = options.itemGUID
    self.isEnchant = options.isEnchant
    self.isRecraft = options.isRecraft
    self.orderData = options.orderData
    self.concentrating = options.concentrating
    --- for debug
    self.callerData = options.callerData
end

---@return CraftSim.RecipeData
function CraftSim.OnCraftData:CreateRecipeData()
    local recipeData = CraftSim.RecipeData({
        recipeID = self.recipeID,
        orderData = self.orderData,
        isRecraft = self.isRecraft,
    })

    recipeData:SetNonQualityReagentsMax()
    recipeData:SetReagentsByCraftingReagentInfoTbl(self.craftingReagentInfoTbl)

    recipeData:SetEquippedProfessionGearSet()

    recipeData.concentrating = self.concentrating

    if recipeData.isSalvageRecipe then
        -- itemTargetLocation HAS to be set
        local item = Item:CreateFromItemLocation(self.itemTargetLocation)
        --CraftSim.DEBUG:InspectTable(item or {}, "salvage - itemTargetLocation item")
        if item then
            recipeData:SetSalvageItem(item:GetItemID())
        end
    end

    if recipeData.isRecraft then
        recipeData.allocationItemGUID = self.itemGUID
    end

    recipeData:Update()

    return recipeData
end
