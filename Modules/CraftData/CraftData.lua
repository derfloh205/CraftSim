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

    local f = CraftSim.UTIL:GetFormatter()

    local hasProfession = CraftSim.UTIL:HasProfession(craftDataSerialized.professionID)

    print("received profID: " .. tostring(craftDataSerialized.professionID))

    if not hasProfession then
        CraftSim.UTIL:SystemPrint(f.bb("CraftSim:") .. " Declined CraftData for unlearned profession")
        return
    end

    local targetItem = Item:CreateFromItemLink(craftDataSerialized.itemLink)




    targetItem:ContinueOnItemLoad(function ()
        -- popup that asks to add craft data
        -- first adjust it
        local craftData = CraftSim.CraftData:Deserialize(craftDataSerialized)
        local crafter = C_ClassColor.GetClassColor(craftData.crafterClass):WrapTextInColorCode(craftData.crafterName)
        local sender = C_ClassColor.GetClassColor(craftDataMessage.senderClass):WrapTextInColorCode(craftDataMessage.senderName)
        local formattedChance = CraftSim.GUTIL:Round(craftData.chance*100) .. "%"
        local expectedCosts = CraftSim.GUTIL:FormatMoney(craftData:GetExpectedCosts())
        local expectedCrafts = CraftSim.GUTIL:Round(craftData.expectedCrafts, 1)
        local text = sender .. "\n\nwants to share " .. f.bb("Craft Data") .. " with you!" ..
        "\nDo you want to add this to your Craft Data for this item?\n\n" ..
        "Item: " .. targetItem:GetItemLink() .. "\n" ..
        "Crafter: " .. crafter .. "\n" ..
        "Chance: " .. formattedChance .. "\n" ..
        "Expected Crafts: " .. expectedCrafts .. "\n" ..
        "Expected Costs: " .. expectedCosts

        CraftSim.GGUI:ShowPopup({
            title="Incoming CraftSim Craft Data", 
            text=text, 
            onAccept=function ()
                CraftSim.CRAFTDATA:AddReceivedCraftData(craftDataSerialized)
            end,
            sizeX=400,
            sizeY=210,
        })
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
            local craftItemData = craftRecipeSave[itemString]
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

    CraftSim.CRAFTDATA.FRAMES:UpdateCraftDataList()
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

    CraftSim.CRAFTDATA.FRAMES:UpdateCraftDataList()
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
    
    CraftSim.CRAFTDATA.FRAMES:UpdateCraftDataList()
end
function CraftSim.CRAFTDATA:DeleteAll()
    CraftSimCraftData = {}
    CraftSim.CRAFTDATA.FRAMES:UpdateCraftDataList()
end