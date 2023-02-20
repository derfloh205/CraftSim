AddonName, CraftSim = ...

CraftSim.CUSTOMER_SERVICE = CraftSim.UTIL:CreateRegistreeForEvents({"CHAT_MSG_WHISPER"})
local PREVIEW_REQUEST_PREFIX = "CraftSimReq1"
local PREVIEW_RECIPE_LIST_RESPONSE_PREFIX = "CraftSimRes1"
local PREVIEW_REQUEST_RECIPE_UPDATE = "CraftSimReq2"
local PREVIEW_RECIPE_UPDATE_RESPONSE = "CraftSimRes2"

local print = CraftSim.UTIL:SetDebugPrint(CraftSim.CONST.DEBUG_IDS.CUSTOMER_SERVICE)

local versionWarningShowed = false

function CraftSim.CUSTOMER_SERVICE:Init()
    -- init link filter
    ChatFrame_AddMessageEventFilter("CHAT_MSG_WHISPER", CraftSim.CUSTOMER_SERVICE.TransformLink)
    ChatFrame_AddMessageEventFilter("CHAT_MSG_WHISPER_INFORM", CraftSim.CUSTOMER_SERVICE.TransformLink)
    hooksecurefunc("ChatFrame_OnHyperlinkShow", CraftSim.CUSTOMER_SERVICE.OnPreviewLinkClicked)

    -- init comm
    CraftSim.COMM:RegisterPrefix(PREVIEW_REQUEST_PREFIX, CraftSim.CUSTOMER_SERVICE.OnPreviewRequest)
    CraftSim.COMM:RegisterPrefix(PREVIEW_RECIPE_LIST_RESPONSE_PREFIX, CraftSim.CUSTOMER_SERVICE.OnRecipeListResponse)
    CraftSim.COMM:RegisterPrefix(PREVIEW_REQUEST_RECIPE_UPDATE, CraftSim.CUSTOMER_SERVICE.OnRecipeUpdateRequest)
    CraftSim.COMM:RegisterPrefix(PREVIEW_RECIPE_UPDATE_RESPONSE, CraftSim.CUSTOMER_SERVICE.OnRecipeUpdateResponse)
end

function CraftSim.CUSTOMER_SERVICE:ClearPreviewIDs()
    CraftSimOptions.customerServiceActivePreviewIDs = {}
end

function CraftSim.CUSTOMER_SERVICE:GeneratePreviewInviteLink()
    local recipeData = CraftSim.MAIN.currentRecipeData
    if not recipeData then
        return
    end
    local professionID = recipeData.professionData.professionInfo.profession
    local timeID = CraftSim.UTIL:round(debugprofilestop())
    local inviteLink = "CraftSimLivePreview:" .. GetUnitName("player", true) .. ":" .. professionID .. ":" .. recipeData.professionData.professionInfo.parentProfessionName .. ":" .. timeID
    table.insert(CraftSimOptions.customerServiceActivePreviewIDs, timeID)
    return inviteLink
end

function CraftSim.CUSTOMER_SERVICE:WhisperInvite(whisperTarget)
    local inviteLink = CraftSim.CUSTOMER_SERVICE:GeneratePreviewInviteLink()
    SendChatMessage(inviteLink or "", "WHISPER", nil, whisperTarget)
end

function CraftSim.CUSTOMER_SERVICE:OnPreviewLinkClicked(payload, text, button)
    local splitData = strsplittable(":", payload)
    local header = splitData[1]
    local crafter = splitData[2]
    local professionID = splitData[3]
    local professionName = splitData[4]
    local previewID = splitData[5]

    if header ~= "CraftSimLivePreview" then
        return
    end

    -- TODO: if any request fails / times out show some small warning indicator (offline or in loading screen)

    print("Requesting Live Preview: " .. tostring(crafter) .. " professionID: " .. tostring(professionID))
    print("previewID: " .. tostring(previewID))

    --CraftSim.CUSTOMER_SERVICE.FRAMES:ShowLivePreview()
    CraftSim.CUSTOMER_SERVICE:SendPreviewRequest(crafter, previewID, professionID, professionName)
    CraftSim.CUSTOMER_SERVICE:StartLivePreviewUpdating()
end

function CraftSim.CUSTOMER_SERVICE:SendPreviewRequest(crafter, previewID, professionID, professionName)
    local requestData = {
        previewID = previewID,
        professionID = professionID,
        professionName = professionName,
        customer = GetUnitName("player", true),
        addonVersion = GetAddOnMetadata(AddonName, "Version"),
    }
    print("SendPreviewRequest " .. tostring(crafter))
    -- print("Payload: ")
    -- print(requestData, true)
    CraftSim.COMM:SendData(PREVIEW_REQUEST_PREFIX, requestData, "WHISPER", crafter)
end

function CraftSim.CUSTOMER_SERVICE.OnPreviewRequest(payload)
    print("OnPreviewRequest", false, true)
    if not tContains(CraftSimOptions.customerServiceActivePreviewIDs, payload.previewID) then
        print("PreviewID not active: " .. tostring(payload.previewID))
        return
    end

    if not CraftSim.UTIL:IsMyVersionHigher(payload.addonVersion) and not versionWarningShowed then
        versionWarningShowed = true
        -- show warning but dont stop
        CraftSim.FRAME:ShowWarning("There is a newer CraftSim Version available: " .. payload.addonVersion, "Newer CraftSim Version Detected", true)
    end

    -- otherwise does not work as key
    local professionID = tonumber(payload.professionID)

    -- TODO: CraftSim VersionCheck ?

    print("return recipe data for professionID: " .. tostring(professionID))

    -- return recipelist by name and ids?

    local professionRecipeIDs = CraftSim.RECIPE_SCAN:GetAllRecipeIDsFromCacheByProfessionID(professionID)

    -- map to recipeInfo and filter 
    local response = {
        crafter = GetUnitName("player", true),
        professionName = payload.professionName,
        recipes = {},
        addonVersion = GetAddOnMetadata(AddonName, "Version"),
    }

    for _, recipeID in pairs(professionRecipeIDs) do
        local recipeInfo = C_TradeSkillUI.GetRecipeInfo(recipeID)
        
        if recipeInfo and recipeInfo.learned and recipeInfo.supportsCraftingStats then
            local isQuestRecipe = tContains(CraftSim.CONST.QUEST_PLAN_CATEGORY_IDS, recipeInfo.categoryID)
            if not isQuestRecipe then
                ---@diagnostic disable-next-line: missing-parameter
                local recipeCategoryInfo = C_TradeSkillUI.GetCategoryInfo(recipeInfo.categoryID)
                local isDragonIsleRecipe = tContains(CraftSim.CONST.DRAGON_ISLES_CATEGORY_IDS, recipeCategoryInfo.parentCategoryID)
                local isRelevantItemLevel = recipeInfo.itemLevel > 1 
                if isDragonIsleRecipe and isRelevantItemLevel then
                    local iconAsText = CraftSim.UTIL:IconToText(recipeInfo.icon, 20)
                    response.recipes[recipeCategoryInfo.name] = response.recipes[recipeCategoryInfo.name] or {}
                    table.insert(response.recipes[recipeCategoryInfo.name], {
                        recipeID=recipeID,
                        recipeName= iconAsText .. " " .. recipeInfo.name
                    })
                end
            end
        end
    end

    print("Send To Customer: " .. tostring(payload.customer))
    CraftSim.COMM:SendData(PREVIEW_RECIPE_LIST_RESPONSE_PREFIX, response, "WHISPER", payload.customer)
end

function CraftSim.CUSTOMER_SERVICE.OnRecipeListResponse(payload)
    print("Response received from " .. payload.crafter)

    if not CraftSim.UTIL:IsMyVersionHigher(payload.addonVersion) and not versionWarningShowed then
        versionWarningShowed = true
        -- show warning but dont stop
        CraftSim.FRAME:ShowWarning("There is a newer CraftSim Version available: " .. payload.addonVersion, "Newer CraftSim Version Detected", true)
    end

    if payload.recipes then
        print("Available Recipes: " .. tostring(#payload.recipes))
    else
        print("No recipes received!")
        return
    end

    CraftSim.CUSTOMER_SERVICE.FRAMES:InitLivePreviewSession(payload)
    CraftSim.CUSTOMER_SERVICE:StopLivePreviewUpdating()
end

function CraftSim.CUSTOMER_SERVICE.SendRecipeUpdateRequest(recipeID, isInit)
    local previewFrame = CraftSim.FRAME:GetFrame(CraftSim.CONST.FRAMES.LIVE_PREVIEW)

    local optionalReagents = nil
    if not isInit then
        -- gather optionalReagents and send back to use
        optionalReagents = {}
        for _, dropdown in pairs(previewFrame.content.optionalDropdowns) do
            table.insert(optionalReagents, dropdown.selectedID)
        end
    end

    local highestGuaranteed = previewFrame.content.guaranteeCB:GetChecked()

    
    local requestData = {
        recipeID = recipeID,
        professionID = previewFrame.professionID,
        customer = GetUnitName("player", true),
        isInit = isInit,
        optionalReagents = optionalReagents,
        highestGuaranteed = highestGuaranteed,
    }
    
    print("SendRecipeUpdateRequest", false, true)
    if optionalReagents then
        print("numOptionals: " .. #optionalReagents)
    end
    CraftSim.COMM:SendData(PREVIEW_REQUEST_RECIPE_UPDATE, requestData, "WHISPER", previewFrame.crafter)
    CraftSim.CUSTOMER_SERVICE:StartLivePreviewUpdating()
end

function CraftSim.CUSTOMER_SERVICE.OnRecipeUpdateRequest(payload)
    local recipeID = payload.recipeID
    local customer = payload.customer
    local optimizeInspiration = not payload.highestGuaranteed
    local optionalReagents = payload.optionalReagents

    print("OnRecipeUpdateRequest")

    -- Optimize for highest reachable quality
    local recipeData = CraftSim.RecipeData(recipeID, false)

    if not recipeData then
        return
    end
    if optionalReagents then
        recipeData:SetOptionalReagents(optionalReagents)
    end
    recipeData:OptimizeQuality(optimizeInspiration)

    print("result:")
    print(recipeData.resultData, true)


    -- TODO: make it its own method/function
    local inspPercent = (recipeData.supportsInspiration and recipeData.professionStats.inspiration:GetPercent()) or nil
    local hsvChance, withInspiration = CraftSim.CALC:getHSVChance(recipeData)
    hsvChance = hsvChance / 100
    local upgradeChance = 0
    if hsvChance == 0 and recipeData.supportsInspiration then
        upgradeChance = inspPercent
    elseif recipeData.supportsInspiration then
        if withInspiration then
            local inspChance = inspPercent / 100
            upgradeChance = inspChance * hsvChance * 100
        else
            -- either one upgrades
            local inspChance = inspPercent / 100
            print("inspChance: " .. inspChance)
            print("hsvChance: " .. hsvChance)
            upgradeChance = ((inspChance * hsvChance) + ((1-inspChance) * hsvChance) + (inspChance * (1-hsvChance))) * 100
        end
    end 

    upgradeChance = CraftSim.UTIL:round(upgradeChance, 2)

    -- for now use pricedata from customer (so the crafter cannot scam with price overrides)
    local responseData = {
        recipeID = recipeID,
        recipeIcon = recipeData.recipeIcon,
        supportsQualities = recipeData.supportsQualities,
        upgradeChance = upgradeChance,
        reagents = recipeData.reagentData:SerializeReagents(),
        optionalReagents = recipeData.reagentData:SerializeOptionalReagentSlots(),
        finishingReagents = recipeData.reagentData:SerializeFinishingReagentSlots(),
        resultData = recipeData.resultData:Serialize(),
        isInit = payload.isInit,
    }

    CraftSim.COMM:SendData(PREVIEW_RECIPE_UPDATE_RESPONSE, responseData, "WHISPER", customer)
end

function CraftSim.CUSTOMER_SERVICE.OnRecipeUpdateResponse(payload)
    print("OnRecipeUpdateResponse")

    print("received serialized data, deserialize and continue..")

    payload.reagents = CraftSim.UTIL:Map(payload.reagents, function(serializedReagent) return CraftSim.Reagent:Deserialize(serializedReagent) end)
    payload.optionalReagents = CraftSim.UTIL:Map(payload.optionalReagents, function(serializedOptionalReagentSlot) return CraftSim.OptionalReagentSlot:Deserialize(serializedOptionalReagentSlot) end)
    payload.finishingReagents = CraftSim.UTIL:Map(payload.finishingReagents, function(serializedOptionalReagentSlot) return CraftSim.OptionalReagentSlot:Deserialize(serializedOptionalReagentSlot) end)
    payload.resultData = CraftSim.ResultData:Deserialize(payload.resultData)

    local itemsToLoad = CraftSim.UTIL:Map(payload.reagents, function(reagent) return reagent.item end)
    table.foreach(CraftSim.UTIL:Concat({payload.optionalReagents, payload.finishingReagents}), function(_, slot)
        itemsToLoad = CraftSim.UTIL:Concat({itemsToLoad, CraftSim.UTIL:Map(slot.possibleReagents, function(optionalReagent) return optionalReagent.item end)})
    end)

    itemsToLoad = CraftSim.UTIL:Concat({itemsToLoad, payload.resultData.itemsByQuality})

    CraftSim.UTIL:ContinueOnAllItemsLoaded(itemsToLoad, function ()
        CraftSim.CUSTOMER_SERVICE.FRAMES:UpdateRecipe(payload)
        CraftSim.CUSTOMER_SERVICE:StopLivePreviewUpdating()
    end)

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

-- depricated
function CraftSim.CUSTOMER_SERVICE:CHAT_MSG_WHISPER(text, playerName, 
    languageName, channelName, playerName2, specialFlags, zoneChannelID, 
    channelIndex, channelBaseName, languageID, lineID, guid, bnSenderID, isMobile, isSubtitle, hideSenderInLetterbox, supressRaidIcons)

    if not CraftSimOptions.customerServiceEnableAutoReply then
        return
    end

    local commands = strsplittable(" ", text)

    local function getInfusionItemByIlvlRangeAndRecipeData(ilvl, recipeData)
        ilvl = tonumber(ilvl)

        --TODO check if player can even use infusions yet

        local infusions = false
        local matrix1Included = false
        local matrices = false

        for _, optionalReagents in pairs(recipeData.possibleOptionalReagents) do
            for _, reagent in pairs(optionalReagents) do
                if reagent.itemID == 197921 then
                    infusions = true
                    break
                elseif reagent.itemID == 198048 then
                    matrix1Included = true
                elseif reagent.itemID == 198056 then
                    matrices = true
                end
            end
        end

        if infusions then
            if ilvl >= 408 then
                return 198046 -- conc primal infusion
            elseif ilvl >= 395 then
                return 197921 -- primal infusion
            end
        elseif matrices then
            if ilvl >= 372 then
                return 198059 -- TM IV
            elseif ilvl >= 359 then
                return 198058 -- TM III
            elseif ilvl >= 346 then
                return 198056 -- TM II
            elseif ilvl >= 333 and matrix1Included then
                return 198048 -- TM I
            end
        end
        return nil
    end

    if commands[1] and commands[1] == CraftSimOptions.customerServiceAutoReplyCommand then
        local ilvl = string.match(text, "|r (%d+)")
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

                    local optionalReagents = {}
                    if ilvl then
                        print("Command3: " .. tostring(ilvl))
                        local itemID = getInfusionItemByIlvlRangeAndRecipeData(ilvl, recipeData)
                        if itemID then
                            table.insert(optionalReagents, {
                                itemID = itemID,
                                quantity = 1,
                                dataSlotIndex = 3, -- optional infusions and matrices
                                itemData = CraftSim.DATAEXPORT:GetItemFromCacheByItemID(itemID), -- cause price data needs it
                            })
                        end
                    end

                    recipeData = CraftSim.DATAEXPORT:exportRecipeData(recipeInfo.recipeID, CraftSim.CONST.EXPORT_MODE.SCAN, {scanReagents=optimizedReagents, optionalReagents=optionalReagents})
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

                    for _, reagent in pairs(recipeData.optionalReagents) do
                        local item = Item:CreateFromItemID(reagent.itemID)
                        item.quantity = reagent.quantity
                        table.insert(reagentItems, item)
                    end

                    for _, reagent in pairs(recipeData.finishingReagents) do
                        local item = Item:CreateFromItemID(reagent.itemID)
                        item.quantity = reagent.quantity
                        table.insert(reagentItems, item)
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

function CraftSim.CUSTOMER_SERVICE:StartLivePreviewUpdating()
    local previewFrame = CraftSim.FRAME:GetFrame(CraftSim.CONST.FRAMES.LIVE_PREVIEW)
    previewFrame.content.StartUpdate()
end

function CraftSim.CUSTOMER_SERVICE:StopLivePreviewUpdating()
    local previewFrame = CraftSim.FRAME:GetFrame(CraftSim.CONST.FRAMES.LIVE_PREVIEW)
    previewFrame.content.StopUpdate()
end

function CraftSim.CUSTOMER_SERVICE:WhisperRecipeDetails(whisperTarget)
    local recipeData = CraftSim.MAIN.currentRecipeData

    if not recipeData then
        return
    end

    local resultData = recipeData.resultData
    local priceData = recipeData.priceData
    local professionStats = recipeData.professionStats

    local optionalReagents = recipeData.reagentData:GetActiveOptionalReagents()
    local requiredReagents = recipeData.reagentData.requiredReagents

    -- replace formattext with values
    local responseText = CraftSimOptions.customerServiceRecipeWhisperFormat
                    
    local inspStat = (recipeData.supportsInspiration and (professionStats.inspiration:GetPercent() .. "%%")) or "-"
    local mcStat = (recipeData.supportsMulticraft and (professionStats.multicraft:GetPercent() .. "%%")) or "-"
    local resStat = (recipeData.supportsResourcefulness and (professionStats.resourcefulness:GetPercent() .. "%%")) or "-"

    local craftingCostsFormatted = CraftSim.UTIL:GetMoneyValuesFromCopper(priceData.craftingCosts, true)

    local detailedCraftingCostText = ""
    local reagentListText = ""
    local optionalReagentListText = ""

    table.foreach(requiredReagents, function (_, reagent)
        table.foreach(reagent.items, function (_, reagentItem)
            if reagentItem.quantity > 0 then
                local itemPrice = (CraftSim.PRICEDATA:GetMinBuyoutByItemID(reagentItem.item:GetItemID(), true) or 0) * reagentItem.quantity
                local itemPriceFormatted = CraftSim.UTIL:GetMoneyValuesFromCopper(CraftSim.UTIL:round(itemPrice*10000)/10000, true)
                detailedCraftingCostText = detailedCraftingCostText .. reagentItem.item:GetItemLink() .. " x " .. reagentItem.quantity .. " (~" .. itemPriceFormatted .. ")" .. "\n"
                reagentListText = reagentListText .. reagentItem.item:GetItemLink() .. " x " .. reagentItem.quantity .. "\n"
            end
        end)
    end)

    table.foreach(optionalReagents, function (_, optionalReagent)
        local itemPrice = (CraftSim.PRICEDATA:GetMinBuyoutByItemID(optionalReagent.item:GetItemID(), true) or 0)
        local itemPriceFormatted = CraftSim.UTIL:GetMoneyValuesFromCopper(CraftSim.UTIL:round(itemPrice*10000)/10000, true)
        detailedCraftingCostText = detailedCraftingCostText .. optionalReagent.item:GetItemLink() .. " x 1 (~" .. itemPriceFormatted .. ")" .. "\n"
        optionalReagentListText = optionalReagentListText .. optionalReagent.item:GetItemLink() .. " x 1\n"
    end)

    
    responseText = string.gsub(responseText or "", "%%gc", resultData.expectedItem:GetItemLink())
    responseText = string.gsub(responseText or "", "%%ic", (resultData.canUpgradeInspiration and resultData.expectedItemInspiration:GetItemLink()) or "-")

    responseText = string.gsub(responseText or "", "%%insp", (resultData.canUpgradeInspiration and inspStat) or "-")

    responseText = string.gsub(responseText or "", "%%mc", mcStat)
    responseText = string.gsub(responseText or "", "%%res", resStat)
    responseText = string.gsub(responseText or "", "%%ccd", detailedCraftingCostText) -- order is important or the %cc of %ccd will be replaced
    responseText = string.gsub(responseText or "", "%%cc", craftingCostsFormatted)
    responseText = string.gsub(responseText or "", "%%orl", optionalReagentListText)
    responseText = string.gsub(responseText or "", "%%rl", reagentListText)

    local responseLines = strsplittable("\n", responseText or "")

    local modifiedStatsText = recipeData.professionStatModifiers:GetTooltipText()

    if modifiedStatsText ~= "" then
        local modifiedLines = strsplittable("\n", modifiedStatsText)
        table.insert(responseLines, "Some profession stats were manually increased/decreased:")
        table.foreach(modifiedLines, function (_, line)
            table.insert(responseLines, line)
        end)
    end

    for _, answerLine in pairs(responseLines) do
        SendChatMessage(answerLine, "WHISPER", nil, whisperTarget)
    end

end

