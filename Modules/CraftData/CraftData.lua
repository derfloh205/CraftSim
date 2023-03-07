_, CraftSim = ...

local print = CraftSim.UTIL:SetDebugPrint(CraftSim.CONST.DEBUG_IDS.CRAFT_DATA)

---@class CraftSim.CraftDataRecipeSave
---@field activeData? CraftSim.CraftData.Serialized
---@field dataPerCrafter CraftSim.CraftData.Serialized[]

---@type CraftSim.CraftDataRecipeSave[][]
CraftSimCraftData = CraftSimCraftData or {}

CraftSim.CRAFTDATA = {}

local CRAFTDATA_MESSAGE = "CRAFTDATA_MSG"

function CraftSim.CRAFTDATA:Init()
    -- init comm
    CraftSim.COMM:RegisterPrefix(CRAFTDATA_MESSAGE, CraftSim.CRAFTDATA.OnCraftDataReceived)
end

function CraftSim.CRAFTDATA:UpdateCraftData(item)
    local recipeData = CraftSim.MAIN.currentRecipeData

    if recipeData then
        local qualityID = recipeData:GetResultQuality(item)
        if qualityID then -- could be nil if item does not belong to recipe, may happen with bugs
            local expectedCrafts = recipeData.resultData.expectedCraftsByQuality[qualityID]
            local chance = recipeData.resultData.chanceByQuality[qualityID]

            print("save:")
            print("qualityID of result:" .. qualityID)
            print("expectedCraftsByQuality")
            print(recipeData.resultData.expectedCraftsByQuality, true)
            print("chanceByQuality")
            print(recipeData.resultData.chanceByQuality, true)

            ---@type CraftSim.Reagent[]
            local requiredReagents = CraftSim.GUTIL:Map(recipeData.reagentData.requiredReagents, function (reagent)
                return reagent:Copy()
            end)

            for _, reagent in pairs(requiredReagents) do
                if not reagent.hasQuality then
                    reagent.items[1].quantity = reagent.requiredQuantity
                else
                    local totalQuantity = reagent.items[1].quantity + reagent.items[2].quantity + reagent.items[3].quantity
                    
                    if totalQuantity < reagent.requiredQuantity then
                        if totalQuantity == 0 then
                            -- use q2
                            reagent.items[2].quantity = reagent.requiredQuantity
                        else
                            -- use the one thats showing
                            local reagentItem = CraftSim.GUTIL:Find(reagent.items, function (reagentItem)
                                return reagentItem.quantity > 0
                            end)

                            reagentItem.quantity = reagent.requiredQuantity
                        end
                    end
                end
            end
            local optionalReagents = recipeData.reagentData:GetActiveOptionalReagents()

            local crafterName = UnitName("player")
            local crafterClass = select(2, UnitClass("player"))

            if not crafterName then
                return
            end

            local resChance = recipeData.professionStats.resourcefulness:GetPercent(true)
            local resExtraFactor = recipeData.professionStats.resourcefulness:GetExtraFactor(true)
            local avgItemAmount = recipeData.baseItemAmount
            if recipeData.supportsMulticraft then
                local extraItemsMC = select(2, CraftSim.CALC:GetExpectedItemAmountMulticraft(recipeData))
                local mcChance = recipeData.professionStats.multicraft:GetPercent(true)
                local mcUpgradeChance = mcChance*chance
                local avgExtraItemsOnMCUpgrade = mcUpgradeChance*extraItemsMC
                avgItemAmount = recipeData.baseItemAmount + avgExtraItemsOnMCUpgrade
            end

            local craftData = CraftSim.CraftData(expectedCrafts, chance, 
            requiredReagents, optionalReagents, crafterName, 
            crafterClass, resChance, resExtraFactor, avgItemAmount, item:GetItemLink(),
            recipeData.recipeID, recipeData.professionData.professionInfo.profession)

            --- use itemString for key to enable saving data for gear
            local itemString = CraftSim.GUTIL:GetItemStringFromLink(item:GetItemLink())
            -- get player level and specializationID and remove the bonusIDs from the link to make the string unique character wide
            itemString = CraftSim.UTIL:RemoveLevelSpecBonusIDStringFromItemString(itemString)
            if itemString then
                ---@type CraftSim.CraftDataRecipeSave[]
                CraftSimCraftData[recipeData.recipeID] = CraftSimCraftData[recipeData.recipeID] or {}
                ---@type CraftSim.CraftDataRecipeSave
                CraftSimCraftData[recipeData.recipeID][itemString] = CraftSimCraftData[recipeData.recipeID][itemString] or {
                    activeData = nil,
                    dataPerCrafter = {},
                }
                local serializedData = craftData:Serialize()
                CraftSimCraftData[recipeData.recipeID][itemString].activeData = serializedData
                CraftSimCraftData[recipeData.recipeID][itemString].dataPerCrafter[crafterName] = serializedData
            end
        end
    end
end

---@param craftDataMessage CraftSim.CraftData.CraftDataMsg
function CraftSim.CRAFTDATA.OnCraftDataReceived(craftDataMessage)
    print("Receiving Craft Data..")
    local craftDataSerialized = craftDataMessage.craftDataSerialized
    print("crafter: " .. tostring(craftDataSerialized.crafterName))
    print("sender: " .. tostring(craftDataMessage.senderName))

    local targetItem = Item:CreateFromItemLink(craftDataSerialized.itemLink)

    targetItem:ContinueOnItemLoad(function ()
        -- popup that asks to add craft data
        -- first adjust it
        local crafter = C_ClassColor.GetClassColor(craftDataSerialized.crafterClass):WrapTextInColorCode(craftDataSerialized.crafterName)
        local sender = C_ClassColor.GetClassColor(craftDataMessage.senderClass):WrapTextInColorCode(craftDataMessage.senderName)
        StaticPopupDialogs["CRAFT_SIM_ACCEPT_CRAFT_DATA_MESSAGE"].text = 
        sender .. "\nwants to share CraftSim CraftData with you!" ..
        "\nDo you want to add this to your Craft Data for this item?\n" ..
        "Item: " .. targetItem:GetItemLink() .. "\n" ..
        "Crafter: " .. crafter .. "\n" ..
        "Chance: " .. craftDataSerialized.chance
        StaticPopup_Show("CRAFT_SIM_ACCEPT_CRAFT_DATA_MESSAGE", "", "", craftDataSerialized)
    end)

end

---@return CraftSim.CraftData.Serialized? craftDataSerialized
function CraftSim.CRAFTDATA:GetActiveCraftData(item)
    local itemToRecipe = CraftSim.CACHE:GetCacheEntryByGameVersion(CraftSimRecipeMap, "itemToRecipe")
    if itemToRecipe then
        local recipeID = itemToRecipe[item:GetItemID()]
        local itemLink = item:GetItemLink()
        local itemString = CraftSim.GUTIL:GetItemStringFromLink(itemLink)
        itemString = CraftSim.UTIL:RemoveLevelSpecBonusIDStringFromItemString(itemString)
        
        local craftRecipeSave = CraftSimCraftData[recipeID]
        if craftRecipeSave then
            local craftItemData = craftRecipeSave[recipeID][itemString]
            if craftItemData then
                return craftItemData.activeData
            end
        end
    end
end

---@param craftDataSerialized CraftSim.CraftData.Serialized
function CraftSim.CRAFTDATA:AddReceivedCraftData(craftDataSerialized)
    local craftRecipeSaveItems = CraftSimCraftData[craftDataSerialized.recipeID] or {}
    local itemString = CraftSim.GUTIL:GetItemStringFromLink(craftDataSerialized.itemLink) or ""
    itemString = CraftSim.UTIL:RemoveLevelSpecBonusIDStringFromItemString(itemString)
    local craftRecipeSave = craftRecipeSaveItems[itemString] or {
        activeData = nil,
        dataPerCrafter = {}
    }

    craftRecipeSave.dataPerCrafter[craftDataSerialized.crafterName] = craftDataSerialized

    if CraftSim.MAIN.currentRecipeData and CraftSim.MAIN.currentRecipeData.recipeID == craftDataSerialized.recipeID then
            local craftData = CraftSim.CraftData:Deserialize(craftDataSerialized)
            CraftSim.CRAFTDATA.frame.content.dataFrame.dataList:Remove(function (row) return row.crafter == craftData.crafterName end, 1)
            CraftSim.CRAFTDATA.frame.content.dataFrame:AddCraftDataToList(craftData)
    end
end

---@class CraftSim.CraftData.CraftDataMsg
---@field senderName string
---@field senderClass string
---@field craftDataSerialized CraftSim.CraftData.Serialized

function CraftSim.CRAFTDATA:SendCraftData(selectedItem, target)
    local recipeData = CraftSim.MAIN.currentRecipeData
    if not recipeData then
        return
    end

    local activeDataSerialized = CraftSim.CRAFTDATA:GetActiveCraftData(selectedItem)

    if activeDataSerialized then
        ---@type CraftSim.CraftData.CraftDataMsg
        local message = {
            senderName = UnitName("player") or "",
            senderClass = select(2, UnitClass("player")),
            craftDataSerialized = activeDataSerialized,
        }
        CraftSim.COMM:SendData(CRAFTDATA_MESSAGE, message, "WHISPER", target)
    end
end

function CraftSim.CRAFTDATA:DeleteForRecipe()
    local recipeData = CraftSim.MAIN.currentRecipeData

    if recipeData then
        CraftSimCraftData[recipeData.recipeID] = nil
    end
end
function CraftSim.CRAFTDATA:DeleteForItem(item)
    local recipeData = CraftSim.MAIN.currentRecipeData

    if recipeData and recipeData:IsResult(item) then
        if CraftSimCraftData[recipeData.recipeID] then
            local itemString = CraftSim.GUTIL:GetItemStringFromLink(item:GetItemLink()) or ""
            itemString = CraftSim.UTIL:RemoveLevelSpecBonusIDStringFromItemString(itemString)
            CraftSimCraftData[recipeData.recipeID][itemString] = nil
        end
    end
end
function CraftSim.CRAFTDATA:DeleteAll()
    CraftSimCraftData = {}
end