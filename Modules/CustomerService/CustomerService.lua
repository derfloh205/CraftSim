CraftSimAddonName, CraftSim = ...

CraftSim.CUSTOMER_SERVICE = {}
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
    local timeID = CraftSim.GUTIL:Round(debugprofilestop())
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
        addonVersion = GetAddOnMetadata(CraftSimAddonName, "Version"),
    }
    print("SendPreviewRequest " .. tostring(crafter))
    -- print("Payload: ")
    -- print(requestData, true)
    CraftSim.COMM:SendData(PREVIEW_REQUEST_PREFIX, requestData, "WHISPER", crafter)
end

function CraftSim.CUSTOMER_SERVICE.OnPreviewRequest(payload)
    print("OnPreviewRequest: " .. type(payload.previewID), false, true)
    if not tContains(CraftSimOptions.customerServiceActivePreviewIDs, tonumber(payload.previewID)) then
        print("PreviewID not active: " .. tostring(payload.previewID))
        return
    end

    if not CraftSim.UTIL:IsMyVersionHigher(payload.addonVersion) and not versionWarningShowed then
        versionWarningShowed = true
        -- show warning but dont stop
        CraftSim.GGUI:ShowPopup({
            sizeX=400, sizeY=250, title="Newer CraftSim Version Detected",
            text="There is a newer CraftSim Version available: " .. payload.addonVersion,
            acceptButtonLabel="OK", declineButtonLabel="Close",
         })
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
        addonVersion = GetAddOnMetadata(CraftSimAddonName, "Version"),
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
                    local iconAsText = CraftSim.GUTIL:IconToText(recipeInfo.icon, 20)
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
        CraftSim.GGUI:ShowPopup({
            sizeX=400, sizeY=250, title="Newer CraftSim Version Detected",
            text="There is a newer CraftSim Version available: " .. payload.addonVersion,
            acceptButtonLabel="OK", declineButtonLabel="Close",
         })
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
    local previewFrame = CraftSim.GGUI:GetFrame(CraftSim.MAIN.FRAMES, CraftSim.CONST.FRAMES.LIVE_PREVIEW)

    local optionalReagents = nil
    if not isInit then
        -- gather optionalReagents and send back to use
        optionalReagents = {}
        for _, dropdown in pairs(previewFrame.content.optionalDropdowns) do
            table.insert(optionalReagents, dropdown.selectedValue)
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

    upgradeChance = CraftSim.GUTIL:Round(upgradeChance, 2)

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

    payload.reagents = CraftSim.GUTIL:Map(payload.reagents, function(serializedReagent) return CraftSim.Reagent:Deserialize(serializedReagent) end)
    payload.optionalReagents = CraftSim.GUTIL:Map(payload.optionalReagents, function(serializedOptionalReagentSlot) return CraftSim.OptionalReagentSlot:Deserialize(serializedOptionalReagentSlot) end)
    payload.finishingReagents = CraftSim.GUTIL:Map(payload.finishingReagents, function(serializedOptionalReagentSlot) return CraftSim.OptionalReagentSlot:Deserialize(serializedOptionalReagentSlot) end)
    payload.resultData = CraftSim.ResultData:Deserialize(payload.resultData)

    local itemsToLoad = CraftSim.GUTIL:Map(payload.reagents, function(reagent) return reagent.item end)
    table.foreach(CraftSim.GUTIL:Concat({payload.optionalReagents, payload.finishingReagents}), function(_, slot)
        itemsToLoad = CraftSim.GUTIL:Concat({itemsToLoad, CraftSim.GUTIL:Map(slot.possibleReagents, function(optionalReagent) return optionalReagent.item end)})
    end)

    itemsToLoad = CraftSim.GUTIL:Concat({itemsToLoad, payload.resultData.itemsByQuality})

    CraftSim.GUTIL:ContinueOnAllItemsLoaded(itemsToLoad, function ()
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

function CraftSim.CUSTOMER_SERVICE:StartLivePreviewUpdating()
    local previewFrame = CraftSim.GGUI:GetFrame(CraftSim.MAIN.FRAMES, CraftSim.CONST.FRAMES.LIVE_PREVIEW)
    previewFrame.content.StartUpdate()
end

function CraftSim.CUSTOMER_SERVICE:StopLivePreviewUpdating()
    local previewFrame = CraftSim.GGUI:GetFrame(CraftSim.MAIN.FRAMES, CraftSim.CONST.FRAMES.LIVE_PREVIEW)
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

    local craftingCostsFormatted = CraftSim.GUTIL:GetMoneyValuesFromCopper(priceData.craftingCosts, true)

    local detailedCraftingCostText = ""
    local reagentListText = ""
    local optionalReagentListText = ""

    table.foreach(requiredReagents, function (_, reagent)
        table.foreach(reagent.items, function (_, reagentItem)
            if reagentItem.quantity > 0 then
                local itemPrice = (CraftSim.PRICEDATA:GetMinBuyoutByItemID(reagentItem.item:GetItemID(), true) or 0) * reagentItem.quantity
                local itemPriceFormatted = CraftSim.GUTIL:GetMoneyValuesFromCopper(CraftSim.GUTIL:Round(itemPrice*10000)/10000, true)
                detailedCraftingCostText = detailedCraftingCostText .. reagentItem.item:GetItemLink() .. " x " .. reagentItem.quantity .. " (~" .. itemPriceFormatted .. ")" .. "\n"
                reagentListText = reagentListText .. reagentItem.item:GetItemLink() .. " x " .. reagentItem.quantity .. "\n"
            end
        end)
    end)

    table.foreach(optionalReagents, function (_, optionalReagent)
        local itemPrice = (CraftSim.PRICEDATA:GetMinBuyoutByItemID(optionalReagent.item:GetItemID(), true) or 0)
        local itemPriceFormatted = CraftSim.GUTIL:GetMoneyValuesFromCopper(CraftSim.GUTIL:Round(itemPrice*10000)/10000, true)
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

