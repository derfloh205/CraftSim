_, CraftSim = ...

---@class CraftSim.ResultData
---@field recipeData CraftSim.RecipeData
---@field itemsByQuality ItemMixin[]
---@field expectedQuality number
---@field expectedItem? ItemMixin
---@field canUpgradeQuality boolean
---@field expectedItemInspiration? ItemMixin
---@field expectedItemHSV? ItemMixin
---@field expectedItemInspirationHSV? ItemMixin

local print = CraftSim.UTIL:SetDebugPrint(CraftSim.CONST.DEBUG_IDS.EXPORT_V2)

CraftSim.ResultData = CraftSim.Object:extend()

---@param recipeData CraftSim.RecipeData
function CraftSim.ResultData:new(recipeData)
    self.recipeData = recipeData
    self.itemsByQuality = {}
    self.canUpgradeQuality = false
    self.expectedQuality = 1

    self:Update()
end

--TODO
-- update result data by professionstats, reagents, optionalReagents and professionStatMod
-- function CraftSim.ResultData:SimulatedUpdate()

function CraftSim.ResultData:Update()
    local recipeData = self.recipeData

    -- TODO: only need to update possible list for gear as everything else is static
    self.itemsByQuality = {}
    local craftingReagentInfoTbl = recipeData.reagentData:GetCraftingReagentInfoTbl()

    if recipeData.isEnchantingRecipe then
        if not CraftSim.ENCHANT_RECIPE_DATA[recipeData.recipeID] then
            error("CraftSim: Enchant Recipe Missing in Data: " .. recipeData.recipeID .. " Please contact the developer (discord: genju#4210)")
        end
        local itemIDs = {
            CraftSim.ENCHANT_RECIPE_DATA[recipeData.recipeID].q1,
            CraftSim.ENCHANT_RECIPE_DATA[recipeData.recipeID].q2,
            CraftSim.ENCHANT_RECIPE_DATA[recipeData.recipeID].q3,
        }

        for _, itemID in pairs(itemIDs) do
            table.insert(self.itemsByQuality, Item:CreateFromItemID(itemID))
        end
    else -- for no quality it will be one item, for gear it will be the correct link, for all other it will also be the correct items, for no items it will have nil in lists
        
        local itemLinks = CraftSim.DATAEXPORT:GetDifferentQualitiesByCraftingReagentTbl(recipeData.recipeID, craftingReagentInfoTbl, recipeData.allocationItemGUID, recipeData.maxQuality)
    
        for _, itemLink in pairs(itemLinks) do
            table.insert(self.itemsByQuality, Item:CreateFromItemLink(itemLink))
        end
    end

    -- based on stats predict the resulting items if there are any

    if #self.itemsByQuality == 0 then
        print("ResultData: No OutputItems")
        return
    end

    local professionStats = self.recipeData.professionStats
    local updatedOperationInfo = C_TradeSkillUI.GetCraftingOperationInfo(recipeData.recipeID, craftingReagentInfoTbl, self.recipeData.allocationItemGUID)

    if not updatedOperationInfo then
        print("Could not update resultData: No OperationInfo")
        return
    end

    self.expectedQuality = updatedOperationInfo.craftingQuality
    self.expectedItem = self.itemsByQuality[self.expectedQuality]

    if self.expectedQuality == self.recipeData.maxQuality then
        return
    end

    if not recipeData.supportsQualities or not recipeData.supportsInspiration then
        return
    end

    -- TODO: new util function? V2 ?
    local function expectedQualityBySkill(skill, maxQuality, recipeDifficulty)
        local thresholds = CraftSim.AVERAGEPROFIT:GetQualityThresholds(maxQuality, recipeDifficulty, CraftSimOptions.breakPointOffset)
        local expectedQuality = 1

        for _, threshold in pairs(thresholds) do
            if skill >= threshold then
                expectedQuality = expectedQuality + 1
            end
        end

        return expectedQuality
    end

    local skillInspiration = professionStats.skill.value + professionStats.inspiration.extraValue
    local maxHSVSkill = professionStats.recipeDifficulty.value * 0.05
    local skillHSV = professionStats.skill.value + maxHSVSkill
    local skillInspirationHSV = professionStats.skill.value + professionStats.inspiration.extraValue + maxHSVSkill

    local qualityInspiration = expectedQualityBySkill(skillInspiration, recipeData.maxQuality, professionStats.recipeDifficulty.value)
    local qualityHSV = expectedQualityBySkill(skillHSV, recipeData.maxQuality, professionStats.recipeDifficulty.value)
    local qualityInspirationHSV = expectedQualityBySkill(skillInspirationHSV, recipeData.maxQuality, professionStats.recipeDifficulty.value)

    if 
        self.expectedQuality < qualityInspiration or 
        self.expectedQuality < qualityHSV or 
        self.expectedQuality < qualityInspirationHSV
    then
        self.canUpgradeQuality = true
    end

    self.expectedItemInspiration = self.itemsByQuality[qualityInspiration]
    self.expectedItemHSV = self.itemsByQuality[qualityHSV]
    self.expectedItemInspirationHSV = self.itemsByQuality[qualityInspirationHSV]
end

function CraftSim.ResultData:Debug()
    local debugLines = {}
    for q, item in pairs(self.itemsByQuality) do
        table.insert(debugLines, "Possible Result Q" .. q .. " " .. (item:GetItemLink() or item:GetItemID()))
    end
    return CraftSim.UTIL:Concat({debugLines, 
        {
            "expectedQuality: " .. tostring(self.expectedQuality),
            "expectedItem: " .. tostring(self.expectedItem and self.expectedItem:GetItemLink()),
            "canUpgradeQuality: " .. tostring(self.canUpgradeQuality),
            "expectedItemInspiration: " .. tostring(self.expectedItemInspiration and self.expectedItemInspiration:GetItemLink()),
            "expectedItemHSV: " .. tostring(self.expectedItemHSV and self.expectedItemHSV:GetItemLink()),
            "expectedItemInspirationHSV: " .. tostring(self.expectedItemInspirationHSV and self.expectedItemInspirationHSV:GetItemLink()),
        }
    })
end