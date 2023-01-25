AddonName, CraftSim = ...

CraftSim.CUSTOMER_SERVICE = CraftSim.UTIL:CreateRegistreeForEvents({"CHAT_MSG_WHISPER"})

local print = CraftSim.UTIL:SetDebugPrint(CraftSim.CONST.DEBUG_IDS.CUSTOMER_SERVICE)

function CraftSim.CUSTOMER_SERVICE:HookToHyperlinks()
    hooksecurefunc("ChatFrame_OnHyperlinkShow", function(self, link, text, button)
        print("payload: " .. tostring(link))
    end)
end

function CraftSim.CUSTOMER_SERVICE:CHAT_MSG_WHISPER(text, playerName, 
    languageName, channelName, playerName2, specialFlags, zoneChannelID, 
    channelIndex, channelBaseName, languageID, lineID, guid, bnSenderID, isMobile, isSubtitle, hideSenderInLetterbox, supressRaidIcons)

    --print("Whisper from " .. tostring(playerName))
    --print("Content:\n" .. tostring(text))

    local commands = strsplittable(" ", text)

    local craft = "!craft"

    if commands[1] and commands[1] == craft then
        print("Triggered Command!")

        -- search for first item link in chat message
        -- local itemLink = LinkUtil.ExtractLink(text)
        -- if not itemLink then
        --     print("no link found")
        -- end
        -- local isItemLink = LinkUtil.IsLinkType(itemLink, "item")
        -- if not isItemLink then
        --     print("found a link but no itemlink")
        --     return
        -- end
        local it = string.gmatch(text, "%|H.*%|h")
        local itemString = it()
        if itemString then
            local item = Item:CreateFromItemLink(itemString)
            if item then
                item:ContinueOnItemLoad(function() 
                    print("ItemName: " .. tostring(item:GetItemName()))
                    print("ItemLink: " .. tostring(item:GetItemLink()))
                    print("ItemID: " .. tostring(item:GetItemID()))

                    local recipeInfo = CraftSim.RECIPE_SCAN:GetRecipeInfoByResult(item)

                    if not recipeInfo then
                        SendChatMessage("I cannot craft this!", "WHISPER", nil, playerName)
                        return
                    end
                    local recipeData = CraftSim.DATAEXPORT:exportRecipeData(recipeInfo.recipeID, CraftSim.CONST.EXPORT_MODE.SCAN)
                    if not recipeData then
                        print("Could not create recipeData for customer request")
                        return
                    end
                    local priceData = CraftSim.PRICEDATA:GetPriceData(recipeData, recipeData.recipeType)
                    if not priceData then
                        print("Could not create priceData for customer request")
                        return
                    end
                    local optimizedReagents = CraftSim.REAGENT_OPTIMIZATION:OptimizeReagentsForScannedRecipeData(recipeData, priceData, true) 

                    print("optimized reagents:")
                    print(optimizedReagents, true)

                    recipeData = CraftSim.DATAEXPORT:exportRecipeData(recipeInfo.recipeID, CraftSim.CONST.EXPORT_MODE.SCAN, {scanReagents=optimizedReagents})
                    if not recipeData then
                        print("2 Could not create recipeData for customer request")
                        return
                    end
                    priceData = CraftSim.PRICEDATA:GetPriceData(recipeData, recipeData.recipeType)

                    if not priceData then
                        print("2 Could not create priceData for customer request")
                        return
                    end

                    local function answer(text)
                        SendChatMessage(text, "WHISPER", nil, playerName)
                    end


                    local outputInfo = CraftSim.DATAEXPORT:GetOutputInfoByRecipeData(recipeData)
                    if outputInfo.inspirationCanUpgrade then
                        answer("Highest Craft: " .. outputInfo.inspiration .. " with " .. recipeData.stats.inspiration.percent .. "% Inspiration")
                    else
                        answer("Highest Craft (Guaranteed): " .. outputInfo.expected)
                    end
                    local moneyText = CraftSim.UTIL:GetMoneyValuesFromCopper(priceData.craftingCostPerCraft, true)
                    answer("Crafting Costs: " .. moneyText)

                    local reagentItems = {}
                    for _, reagent in pairs(recipeData.reagents) do
                        for _, itemInfo in pairs(reagent.itemsInfo) do
                            if itemInfo.allocations > 0 then
                                local item = Item:CreateFromItemID(itemInfo.itemID)
                                item.quantity = itemInfo.allocations
                                table.insert(reagentItems, item)
                            end
                        end
                    end

                    CraftSim.UTIL:ContinueOnAllItemsLoaded(reagentItems, function() 
                        for _, item in pairs(reagentItems) do
                            local itemPrice = CraftSim.PRICEDATA:GetMinBuyoutByItemID(item:GetItemID(), true)
                            local moneyText = CraftSim.UTIL:GetMoneyValuesFromCopper(itemPrice*item.quantity, true)
                            answer(item.quantity .. " x " .. item:GetItemLink() .. " = " .. moneyText)
                        end
                    end)
                end)
            end
        end
    end
end


