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
    local timeID = CraftSim.UTIL:round(debugprofilestop())
    local inviteLink = "CraftSimLivePreview:" .. GetUnitName("player", true) .. ":" .. recipeData.professionID .. ":" .. recipeData.professionInfo.parentProfessionName .. ":" .. timeID
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
        if recipeInfo and recipeInfo.learned then
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

    
    local requestData = {
        recipeID = recipeID,
        professionID = previewFrame.professionID,
        customer = GetUnitName("player", true),
        isInit = isInit,
        optionalReagents = optionalReagents,
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
    local professionID = payload.professionID
    local customer = payload.customer

    print("OnRecipeUpdateRequest")

    local optimizedRecipe = CraftSim.CUSTOMER_SERVICE:OptimizeRecipe(recipeID, payload.optionalReagents)

    if not optimizedRecipe then
        return
    end

    local inspPercent = (optimizedRecipe.recipeData.stats.inspiration and optimizedRecipe.recipeData.stats.inspiration.percent) or nil

    -- for now use pricedata from customer (so the crafter cannot scam with price overrides)
    local responseData = {
        recipeID = recipeID,
        recipeIcon = optimizedRecipe.recipeData.recipeIcon,
        inspirationPercent = inspPercent,
        reagents = optimizedRecipe.recipeData.reagents,
        optionalReagents = optimizedRecipe.recipeData.possibleOptionalReagents,
        finishingReagents = optimizedRecipe.recipeData.possibleFinishingReagents,
        outputInfo = optimizedRecipe.outputInfo,
        isInit = payload.isInit,
    }

    CraftSim.COMM:SendData(PREVIEW_RECIPE_UPDATE_RESPONSE, responseData, "WHISPER", customer)
end

function CraftSim.CUSTOMER_SERVICE.OnRecipeUpdateResponse(payload)
    print("OnRecipeUpdateResponse")

    print("received output info")
    print(payload.outputInfo, true)

    CraftSim.CUSTOMER_SERVICE.FRAMES:UpdateRecipe(payload)
    CraftSim.CUSTOMER_SERVICE:StopLivePreviewUpdating()
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

local function getCraftReagentInfoTblEntryFromOptionalsByItemID(recipeData, itemID)
    local optionalReagent = nil
    local finishingReagent = nil

    for _, slot in pairs(recipeData.possibleOptionalReagents) do
        optionalReagent = CraftSim.UTIL:Find(slot, function(r) return r.itemID == itemID end)
        if optionalReagent then
            break
        end
    end
    for _, slot in pairs(recipeData.possibleFinishingReagents) do
        finishingReagent = CraftSim.UTIL:Find(slot, function(r) return r.itemID == itemID end)
        if finishingReagent then
            break
        end
    end

    local reagent = optionalReagent or finishingReagent

    if reagent then
        reagent.quantity = 1
        reagent.itemData = CraftSim.DATAEXPORT:GetItemFromCacheByItemID(itemID)
    end

    return reagent
end

function CraftSim.CUSTOMER_SERVICE:OptimizeRecipe(recipeID, optionalReagents)
    local recipeInfo = C_TradeSkillUI.GetRecipeInfo(recipeID)
    if not recipeInfo then
        print("Could not fetch recipeInfo for recipe: " .. tostring(recipeID))
        return
    end

    local recipeData = nil
    local mappedOptionalReagents = nil
    if optionalReagents and #optionalReagents > 0 then
        -- build them to craftingreagentInfoTbl items
        recipeData = CraftSim.DATAEXPORT:exportRecipeData(recipeInfo.recipeID, CraftSim.CONST.EXPORT_MODE.SCAN)

        mappedOptionalReagents = CraftSim.UTIL:Map(optionalReagents, function(itemID) 
            return getCraftReagentInfoTblEntryFromOptionalsByItemID(recipeData, itemID)
        end)
    end

    print("mapped optionals:", false, true)
    print(mappedOptionalReagents, true)

    local initialOverride = (mappedOptionalReagents and {optionalReagents=mappedOptionalReagents}) or nil
    print("initial override: ", false, true)
    print(initialOverride, true)
    recipeData = CraftSim.DATAEXPORT:exportRecipeData(recipeInfo.recipeID, CraftSim.CONST.EXPORT_MODE.SCAN, initialOverride)
    if not recipeData then
        print("Could not create recipeData for recipe optimization")
        return
    end
    local priceData = CraftSim.PRICEDATA:GetPriceData(recipeData, recipeData.recipeType)
    if not priceData then
        print("Could not create priceData for recipe optimization")
        return
    end
    local optimizedReagents = CraftSim.REAGENT_OPTIMIZATION:OptimizeReagentsForScannedRecipeData(recipeData, priceData, true) 

    recipeData = CraftSim.DATAEXPORT:exportRecipeData(recipeInfo.recipeID, CraftSim.CONST.EXPORT_MODE.SCAN, {scanReagents=optimizedReagents, optionalReagents=mappedOptionalReagents})
    if not recipeData then
        print("2 Could not create recipeData for recipe optimization")
        return
    end
    priceData = CraftSim.PRICEDATA:GetPriceData(recipeData, recipeData.recipeType)

    if not priceData then
        print("2 Could not create priceData for recipe optimization")
        return
    end

    local outputInfo = CraftSim.DATAEXPORT:GetOutputInfoByRecipeData(recipeData)

    return {
        recipeData = recipeData,
        priceData = priceData,
        outputInfo = outputInfo
    }
end

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

