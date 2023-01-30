AddonName, CraftSim = ...

CraftSim.CUSTOMER_SERVICE = CraftSim.UTIL:CreateRegistreeForEvents({"CHAT_MSG_WHISPER"})

local print = CraftSim.UTIL:SetDebugPrint(CraftSim.CONST.DEBUG_IDS.CUSTOMER_SERVICE)

function CraftSim.CUSTOMER_SERVICE:InitLinkTransformation()
    print("init link transform")
    ChatFrame_AddMessageEventFilter("CHAT_MSG_WHISPER", CraftSim.CUSTOMER_SERVICE.TransformLink)
    ChatFrame_AddMessageEventFilter("CHAT_MSG_WHISPER_INFORM", CraftSim.CUSTOMER_SERVICE.TransformLink)
end

function CraftSim.CUSTOMER_SERVICE:HookToHyperlinks()
    hooksecurefunc("ChatFrame_OnHyperlinkShow", CraftSim.CUSTOMER_SERVICE.OnPreviewLinkClicked)
end

function CraftSim.CUSTOMER_SERVICE:OnPreviewLinkClicked(payload, text, button)
    print("payload: " .. tostring(payload))
    local splitData = strsplittable(":", payload)
    local senderName = splitData[2]
    local professionID = splitData[3]

    -- -- with or without servername?
    -- local senderServer = strsplittable("-", payload)

    -- if #senderServer > 1 then
    --     -- with server name
    --     senderName = senderS
    -- end

    -- TODO: Send initial request to get possible recipes (id + names) of learned!
    -- TODO: open crafting preview and populate dropdown and other fields
    -- TODO: set some local property to the sendername to continuosly send data to and receive
    -- TODO: if any request fails / times out show some small warning indicator (offline or in loading screen)

    print("Start Preview Session: " .. tostring(senderName) .. " professionID: " .. tostring(professionID))
end

function CraftSim.CUSTOMER_SERVICE:CHAT_MSG_WHISPER(text, playerName, 
    languageName, channelName, playerName2, specialFlags, zoneChannelID, 
    channelIndex, channelBaseName, languageID, lineID, guid, bnSenderID, isMobile, isSubtitle, hideSenderInLetterbox, supressRaidIcons)

    if not CraftSimOptions.customerServiceEnableAutoReply then
        return
    end

    --print("Whisper from " .. tostring(playerName))
    --print("Content:\n" .. tostring(text))

    local commands = strsplittable(" ", text)

    if commands[1] and commands[1] == CraftSimOptions.customerServiceAutoReplyCommand then
        print("Triggered Command!")

        local it = string.gmatch(text, "%|H.*%|h")
        local itemString = it()
        if itemString then
            local item = Item:CreateFromItemLink(itemString)
            if item then
                item:ContinueOnItemLoad(function() 
                    print("ItemName: " .. tostring(item:GetItemName()))
                    print("ItemLink: " .. tostring(item:GetItemLink()))
                    print("ItemID: " .. tostring(item:GetItemID()))

                    local function answer(text)
                        SendChatMessage(text, "WHISPER", nil, playerName)
                    end

                    local recipeInfo = CraftSim.RECIPE_SCAN:GetRecipeInfoByResult(item)

                    if not recipeInfo then
                        answer("I cannot craft this!")
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


                    local outputInfo = CraftSim.DATAEXPORT:GetOutputInfoByRecipeData(recipeData)

                    local craftingCostsFormatted = CraftSim.UTIL:GetMoneyValuesFromCopper(priceData.craftingCostPerCraft, true)

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
                        local detailedCraftingCostText = "\n"
                        for _, item in pairs(reagentItems) do
                            local itemPrice = CraftSim.PRICEDATA:GetMinBuyoutByItemID(item:GetItemID(), true)
                            local moneyText = CraftSim.UTIL:GetMoneyValuesFromCopper(itemPrice*item.quantity, true)
                            -- answer(item.quantity .. " x " .. item:GetItemLink() .. " = " .. moneyText)
                            detailedCraftingCostText = detailedCraftingCostText .. item.quantity .. " x " .. item:GetItemLink() .. " = " .. moneyText .. "\n"
                        end

                        -- replace formattext with values
                        local responseText = CraftSimOptions.customerServiceAutoReplyFormat
                        
                        local inspStat = (recipeData.stats.inspiration and (recipeData.stats.inspiration.percent .. "%%")) or "-"
                        local mcStat = (recipeData.stats.multicraft and (recipeData.stats.multicraft.percent .. "%%")) or "-"
                        local resStat = (recipeData.stats.resourcefulness and (recipeData.stats.resourcefulness.percent .. "%%")) or "-"
                        

                        responseText = string.gsub(responseText or "", "%%gc", outputInfo.expected)
                        responseText = string.gsub(responseText or "", "%%ic", outputInfo.inspiration or "-")

                        responseText = string.gsub(responseText or "", "%%insp", (outputInfo.inspiration and inspStat) or "-")
    
                        responseText = string.gsub(responseText or "", "%%mc", mcStat)
                        responseText = string.gsub(responseText or "", "%%res", resStat)
                        responseText = string.gsub(responseText or "", "%%ccd", detailedCraftingCostText) -- order is important or the %cc of %ccd will be replaced
                        responseText = string.gsub(responseText or "", "%%cc", craftingCostsFormatted)

                        local responseLines = strsplittable("\n", responseText or "")

                        for _, answerLine in pairs(responseLines) do
                            answer(answerLine)
                        end
                    end)
                end)
            end
        end
    end
end

function CraftSim.CUSTOMER_SERVICE:GeneratePreviewInviteLink()
    local recipeData = CraftSim.MAIN.currentRecipeData
    if not recipeData then
        return
    end
    local inviteLink = "CraftSimLivePreview:" .. GetUnitName("player", true) .. ":" .. recipeData.professionID .. ":" .. recipeData.professionInfo.parentProfessionName
    return inviteLink
end

function CraftSim.CUSTOMER_SERVICE:WhisperInvite(whisperTarget)
    local inviteLink = CraftSim.CUSTOMER_SERVICE:GeneratePreviewInviteLink()
    SendChatMessage(inviteLink or "", "WHISPER", nil, whisperTarget)
end

-- On the recipient side, decode the string and transform it into a clickable link
function CraftSim.CUSTOMER_SERVICE:TransformLink(event, message, sender, ...)
    local linkType, data = string.match(message, "(%a+):(.*)")
    if linkType == "CraftSimLivePreview" then
        local professionName = strsplittable(":", data)[3]
        local link = "|cffe6cc80|HCraftSimLivePreview:" .. data .. "|h[CraftSim Live Preview: "..professionName.."]|h|r"
        return false, link, sender, ...
    end
end


