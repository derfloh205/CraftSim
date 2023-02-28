AddonName, CraftSim = ...

CraftSim.CRAFT_RESULTS.FRAMES = {}

local print = CraftSim.UTIL:SetDebugPrint(CraftSim.CONST.DEBUG_IDS.CRAFT_RESULTS)

function CraftSim.CRAFT_RESULTS.FRAMES:Init()
    local frameNO_WO = CraftSim.FRAME:CreateCraftSimFrame(
        "CraftSimCraftResultsFrame", "CraftSim Crafting Results", 
        ProfessionsFrame.CraftingPage,
        ProfessionsFrame.CraftingPage.CraftingOutputLog, "TOPLEFT", "TOPLEFT", 0, 10, 700, 450, CraftSim.CONST.FRAMES.CRAFT_RESULTS, false, true, "FULLSCREEN", "modulesCraftResults")

    local function createContent(frame)
        -- Tracker

        frame.content.totalProfitAllTitle = CraftSim.FRAME:CreateText("Session Profit", frame.content, frame.content, 
        "TOP", "TOP", 140, -60, nil, nil, {type="H", value="LEFT"})
        frame.content.totalProfitAllValue = CraftSim.FRAME:CreateText(CraftSim.GUTIL:FormatMoney(0, true), frame.content, frame.content.totalProfitAllTitle, 
        "TOPLEFT", "BOTTOMLEFT", 0, -5, nil, nil, {type="H", value="LEFT"})
    

        frame.content.clearButton = CraftSim.GGUI.Button({
            parent=frame.content,anchorParent=frame.content.totalProfitAllTitle, anchorA="TOPLEFT",anchorB="BOTTOMLEFT",
            sizeX=15,sizeY=25,adjustWidth=true,offsetY=-40, label="Reset Data",
            clickCallback=function() 
                frame.content.scrollingMessageFrame:Clear()
                frame.content.craftedItemsFrame.resultFeed:SetText("")
                frame.content.totalProfitAllValue:SetText(CraftSim.GUTIL:FormatMoney(0, true))
                CraftSim.CRAFT_RESULTS:ResetData()
                CraftSim.CRAFT_RESULTS.FRAMES:UpdateRecipeData(CraftSim.MAIN.currentRecipeData.recipeID)
            end
        })

        frame.content.exportButton = CraftSim.GGUI.Button({
            parent=frame.content,anchorParent=frame.content.clearButton.frame,anchorA="TOPLEFT",anchorB="BOTTOMLEFT",
            sizeX=25,sizeY=25,offsetY=-10,adjustWidth=true, label="Export JSON",
            clickCallback=function() 
                local json = CraftSim.CRAFT_RESULTS:ExportJSON()
                CraftSim.UTIL:KethoEditBox_Show(json)
            end
        })

        
        -- craft results

        frame.content.craftsTitle = CraftSim.FRAME:CreateText("Craft Log", frame.content, frame.content, "TOPLEFT", "TOPLEFT", 155, -40)
        
        frame.content.scrollingMessageFrame = CraftSim.FRAME:CreateScrollingMessageFrame(frame.content, frame.content.craftsTitle, 
        "TOPLEFT", "BOTTOMLEFT", -125, -15, 30, 200, 140)
        --

        frame.content.scrollFrame2, frame.content.craftedItemsFrame = CraftSim.FRAME:CreateScrollFrame(frame.content, -230, 20, -350, 20)

        frame.content.craftedItemsTitle = CraftSim.FRAME:CreateText("Crafted Items", frame.content, frame.content.scrollFrame2, "BOTTOM", "TOP", 0, 0)

        frame.content.craftedItemsFrame.resultFeed = CraftSim.FRAME:CreateText("", frame.content.craftedItemsFrame, frame.content.craftedItemsFrame, 
        "TOPLEFT", "TOPLEFT", 10, -10, nil, nil, {type="H", value="LEFT"})

        frame.content.statisticsTitle = CraftSim.FRAME:CreateText("Recipe Statistics", frame.content, frame.content.craftedItemsTitle, "LEFT", "RIGHT", 270, 0)
        frame.content.statisticsText = CraftSim.FRAME:CreateText("Nothing crafted yet!", frame.content, frame.content.statisticsTitle, "TOPLEFT", "BOTTOMLEFT", -70, -10, nil, nil, {type="H", value="LEFT"})
        frame.content.statisticsText:SetWidth(300)
    end

    createContent(frameNO_WO)
    CraftSim.FRAME:EnableHyperLinksForFrameAndChilds(frameNO_WO)
end

function CraftSim.CRAFT_RESULTS.FRAMES:UpdateRecipeData(recipeID)
    local print = CraftSim.UTIL:SetDebugPrint(CraftSim.CONST.DEBUG_IDS.CRAFT_RESULTS)
    print("Update RecipeData: " .. tostring(recipeID))
    -- only update frontend if its the shown recipeID
    if not CraftSim.MAIN.currentRecipeData or CraftSim.MAIN.currentRecipeData.recipeID ~= recipeID then
        return
    end

    local craftResultFrame = CraftSim.FRAME:GetFrame(CraftSim.CONST.FRAMES.CRAFT_RESULTS)

    local craftSessionData = CraftSim.CRAFT_RESULTS.currentSessionData 
    if not craftSessionData then
        print("create new craft session data")
        craftSessionData = CraftSim.CraftSessionData()
        CraftSim.CRAFT_RESULTS.currentSessionData  = craftSessionData
    else
        print("Reuse sessionData")
    end
    local craftRecipeData = craftSessionData:GetCraftRecipeData(recipeID)
    if not craftRecipeData then
        print("create new recipedata")
        craftRecipeData = CraftSim.CraftRecipeData(recipeID)
        table.insert(craftSessionData.craftRecipeData, craftRecipeData)
    else
        print("Reuse recipedata")
        print(craftRecipeData)
    end

    -- statistics
    local statisticsText = ""
    local expectedAverageProfit = CraftSim.GUTIL:FormatMoney(0, true)
    local actualAverageProfit = CraftSim.GUTIL:FormatMoney(0, true)
    if craftRecipeData.numCrafts > 0 then
        expectedAverageProfit = CraftSim.GUTIL:FormatMoney((craftRecipeData.totalExpectedProfit / craftRecipeData.numCrafts) or 0, true)
        actualAverageProfit = CraftSim.GUTIL:FormatMoney((craftRecipeData.totalProfit / craftRecipeData.numCrafts) or 0, true)
    end
    local actualProfit = CraftSim.GUTIL:FormatMoney(craftRecipeData.totalProfit, true)
    statisticsText = statisticsText .. "Crafts: " .. craftRecipeData.numCrafts .. "\n\n"
    
    if CraftSim.MAIN.currentRecipeData.supportsCraftingStats then
        statisticsText = statisticsText .. "Expected Ø Profit: " .. expectedAverageProfit .. "\n"
        statisticsText = statisticsText .. "Real Ø Profit: " .. actualAverageProfit .. "\n"
        statisticsText = statisticsText .. "Real Profit: " .. actualProfit .. "\n\n"
        statisticsText = statisticsText .. "Procs - Real / Expected:\n\n"
        if CraftSim.MAIN.currentRecipeData.supportsInspiration then
            local expectedProcs = tonumber(CraftSim.GUTIL:Round(CraftSim.MAIN.currentRecipeData.professionStats.inspiration:GetPercent(true) * craftRecipeData.numCrafts, 1)) or 0
            if craftRecipeData.numInspiration >= expectedProcs then
                statisticsText = statisticsText .. "Inspiration: " .. CraftSim.GUTIL:ColorizeText(craftRecipeData.numInspiration, CraftSim.GUTIL.COLORS.GREEN) .. " / " .. expectedProcs .. "\n"
            else
                statisticsText = statisticsText .. "Inspiration: " .. CraftSim.GUTIL:ColorizeText(craftRecipeData.numInspiration, CraftSim.GUTIL.COLORS.RED) .. " / " .. expectedProcs .. "\n"
            end
        end
        if CraftSim.MAIN.currentRecipeData.supportsMulticraft then
            local expectedProcs =  tonumber(CraftSim.GUTIL:Round(CraftSim.MAIN.currentRecipeData.professionStats.multicraft:GetPercent(true) * craftRecipeData.numCrafts, 1)) or 0
            if craftRecipeData.numMulticraft >= expectedProcs then
                statisticsText = statisticsText .. "Multicraft: " .. CraftSim.GUTIL:ColorizeText(craftRecipeData.numMulticraft, CraftSim.GUTIL.COLORS.GREEN) .. " / " .. expectedProcs .. "\n"
            else
                statisticsText = statisticsText .. "Multicraft: " .. CraftSim.GUTIL:ColorizeText(craftRecipeData.numMulticraft, CraftSim.GUTIL.COLORS.RED) .. " / " .. expectedProcs .. "\n"
            end
            local averageExtraItems = 0
            local expectedAdditionalItems = 0
            local multicraftExtraItemsFactor = CraftSim.MAIN.currentRecipeData.professionStats.multicraft:GetExtraFactor(true)
    
            local maxExtraItems = (CraftSimOptions.customMulticraftConstant*CraftSim.MAIN.currentRecipeData.baseItemAmount) * multicraftExtraItemsFactor
            expectedAdditionalItems = tonumber(CraftSim.GUTIL:Round((1 + maxExtraItems) / 2, 2)) or 0
    
            averageExtraItems = tonumber(CraftSim.GUTIL:Round(( craftRecipeData.numMulticraft > 0 and (craftRecipeData.numMulticraftExtraItems / craftRecipeData.numMulticraft)) or 0, 2)) or 0
            if averageExtraItems == 0 then
                statisticsText = statisticsText .. "- Ø Extra Items: " .. averageExtraItems .. " / " .. expectedAdditionalItems .. "\n"
            elseif averageExtraItems >= expectedAdditionalItems then
                statisticsText = statisticsText .. "- Ø Extra Items: " .. CraftSim.GUTIL:ColorizeText(averageExtraItems, CraftSim.GUTIL.COLORS.GREEN) .. " / " .. expectedAdditionalItems .. "\n"
            else
                statisticsText = statisticsText .. "- Ø Extra Items: " .. CraftSim.GUTIL:ColorizeText(averageExtraItems, CraftSim.GUTIL.COLORS.RED) .. " / " .. expectedAdditionalItems .. "\n"
            end
        end
        if CraftSim.MAIN.currentRecipeData.supportsResourcefulness then
            local averageSavedCosts = 0
            local expectedAverageSavedCosts = 0
            if craftRecipeData.numCrafts > 0 then
                averageSavedCosts = CraftSim.GUTIL:Round((craftRecipeData.totalSavedCosts / craftRecipeData.numCrafts)/10000) * 10000 --roundToGold
                expectedAverageSavedCosts = CraftSim.GUTIL:Round((craftRecipeData.totalExpectedSavedCosts / craftRecipeData.numCrafts)/10000) * 10000
            end

            if averageSavedCosts == 0 then
                statisticsText = statisticsText .. "Resourcefulness Procs: " .. CraftSim.GUTIL:ColorizeText(craftRecipeData.numResourcefulness, CraftSim.GUTIL.COLORS.GREEN)
            elseif averageSavedCosts >= expectedAverageSavedCosts then
                statisticsText = statisticsText .. "Resourcefulness Procs: " .. CraftSim.GUTIL:ColorizeText(craftRecipeData.numResourcefulness, CraftSim.GUTIL.COLORS.GREEN) .. "\n" ..
                                    "- Ø Saved Costs: " .. CraftSim.GUTIL:ColorizeText(CraftSim.GUTIL:FormatMoney(averageSavedCosts), CraftSim.GUTIL.COLORS.GREEN) .. " / " .. CraftSim.GUTIL:FormatMoney(expectedAverageSavedCosts)
            else
                statisticsText = statisticsText .. "Resourcefulness Procs: " .. CraftSim.GUTIL:ColorizeText(craftRecipeData.numResourcefulness, CraftSim.GUTIL.COLORS.GREEN) .. "\n" ..
                                    "- Ø Saved Costs: " .. CraftSim.GUTIL:ColorizeText(CraftSim.GUTIL:FormatMoney(averageSavedCosts), CraftSim.GUTIL.COLORS.RED) .. " / " .. CraftSim.GUTIL:FormatMoney(expectedAverageSavedCosts)
            end
        end
    else
        statisticsText = statisticsText .. "Profit: " .. actualProfit .. "\n\n"
    end


    craftResultFrame.content.statisticsText:SetText(statisticsText)
end

function CraftSim.CRAFT_RESULTS.FRAMES:UpdateItemList()
    local craftResultFrame = CraftSim.FRAME:GetFrame(CraftSim.CONST.FRAMES.CRAFT_RESULTS)
    -- total items
    local craftResultItems = CraftSim.CRAFT_RESULTS.currentSessionData.totalItems

    -- sort craftedItems by .. rareness?
    craftResultItems = CraftSim.GUTIL:Sort(craftResultItems, function(a, b) 
        return a.item:GetItemQuality() > b.item:GetItemQuality()
    end)

    local craftedItemsText = ""
    for _, craftResultItem in pairs(craftResultItems) do
        craftedItemsText = craftedItemsText .. craftResultItem.quantity .. " x " .. craftResultItem.item:GetItemLink() .. "\n"
    end

    -- add saved reagents
    local savedReagentsText = ""
    if #CraftSim.CRAFT_RESULTS.currentSessionData.totalSavedReagents > 0 then
        savedReagentsText = "\nSaved Reagents:\n"
        for _, savedReagent in pairs(CraftSim.CRAFT_RESULTS.currentSessionData.totalSavedReagents) do
            savedReagentsText = savedReagentsText ..  savedReagent.quantity .. " x " .. savedReagent.item:GetItemLink() .. "\n"
        end
    end
    
    craftResultFrame.content.craftedItemsFrame.resultFeed:SetText(craftedItemsText .. savedReagentsText)
end