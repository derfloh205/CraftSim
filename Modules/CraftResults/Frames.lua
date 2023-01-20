AddonName, CraftSim = ...

CraftSim.CRAFT_RESULTS.FRAMES = {}

function CraftSim.CRAFT_RESULTS.FRAMES:Init()
    local frameNO_WO = CraftSim.FRAME:CreateCraftSimFrame(
        "CraftSimCraftResultsFrame", "CraftSim Crafting Results", 
        ProfessionsFrame.CraftingPage,
        ProfessionsFrame.CraftingPage.CraftingOutputLog, "TOPLEFT", "TOPLEFT", 0, 10, 500, 350, CraftSim.CONST.FRAMES.CRAFT_RESULTS, false, true, "FULLSCREEN", "modulesCraftResults")

    local function createContent(frame)
        -- Tracker
        frame.content.totalProfitPerRecipe = {}
        frame.content.totalProfitAll = 0

        
        frame.content.totalProfitAllTitle = CraftSim.FRAME:CreateText("Session Profit", frame.content, frame.content, 
        "TOP", "TOP", 100, -60, nil, nil, {type="H", value="LEFT"})
        frame.content.totalProfitAllValue = CraftSim.FRAME:CreateText(CraftSim.UTIL:FormatMoney(0, true), frame.content, frame.content.totalProfitAllTitle, 
        "TOPLEFT", "BOTTOMLEFT", 0, -5, nil, nil, {type="H", value="LEFT"})
        
        frame.content.totalProfitPerRecipeTitle = CraftSim.FRAME:CreateText("Session Profit For Recipe", frame.content, frame.content.totalProfitAllValue, 
        "TOPLEFT", "BOTTOMLEFT", 0, -10, nil, nil, {type="H", value="LEFT"})
        frame.content.totalProfitPerRecipeValue = CraftSim.FRAME:CreateText(CraftSim.UTIL:FormatMoney(0, true), frame.content, frame.content.totalProfitPerRecipeTitle, 
        "TOPLEFT", "BOTTOMLEFT", 0, -5, nil, nil, {type="H", value="LEFT"})

        frame.content.clearButton = CraftSim.FRAME:CreateButton("Reset Data", frame.content, frame.content.totalProfitPerRecipeValue, "TOPLEFT", "BOTTOMLEFT", 
        0, -20, 15, 25, true, function() 
            frame.content.totalProfitPerRecipe = {}
            frame.content.totalProfitAll = 0
            frame.content.resultFrame.resultFeed:SetText("")
            frame.content.totalProfitPerRecipeValue:SetText(CraftSim.UTIL:FormatMoney(0, true))
            frame.content.totalProfitAllValue:SetText(CraftSim.UTIL:FormatMoney(0, true))
        end)

        frame.content.ResetForRecipe = function(recipeID)
            local currentProfitForRecipe = frame.content.totalProfitPerRecipe[recipeID] or 0
            frame.content.totalProfitPerRecipeValue:SetText(CraftSim.UTIL:FormatMoney(currentProfitForRecipe, true))
        end

        frame.content.AddProfit = function(addValue, recipeID) 
            if not recipeID then
                frame.content.totalProfitAll = frame.content.totalProfitAll + addValue
                frame.content.totalProfitAllValue:SetText(CraftSim.UTIL:FormatMoney(frame.content.totalProfitAll, true))
            else
                if not frame.content.totalProfitPerRecipe[recipeID] then
                    frame.content.totalProfitPerRecipe[recipeID] = addValue
                else
                    frame.content.totalProfitPerRecipe[recipeID] = frame.content.totalProfitPerRecipe[recipeID] + addValue
                end
                frame.content.totalProfitPerRecipeValue:SetText(CraftSim.UTIL:FormatMoney(frame.content.totalProfitPerRecipe[recipeID], true))
            end
        end
        -- scrollframe
        frame.content.scrollFrame = CreateFrame("ScrollFrame", nil, frame.content, "UIPanelScrollFrameTemplate")
        frame.content.scrollFrame.scrollChild = CreateFrame("frame")
        local scrollFrame = frame.content.scrollFrame
        local scrollChild = scrollFrame.scrollChild
        scrollFrame:SetSize(frame.content:GetWidth() , frame.content:GetHeight())
        scrollFrame:SetPoint("TOP", frame.content, "TOP", 0, -50)
        scrollFrame:SetPoint("LEFT", frame.content, "LEFT", 20, 0)
        scrollFrame:SetPoint("RIGHT", frame.content, "RIGHT", -250, 0)
        scrollFrame:SetPoint("BOTTOM", frame.content, "BOTTOM", 0, 20)
        scrollFrame:SetScrollChild(scrollFrame.scrollChild)
        scrollChild:SetWidth(scrollFrame:GetWidth())
        scrollChild:SetHeight(1) -- ??

        frame.content.resultFrame = scrollChild

        -- always scroll down on new craft
        frame.content.scrollFrame:HookScript("OnScrollRangeChanged", function() 
            frame.content.scrollFrame:SetVerticalScroll(frame.content.scrollFrame:GetVerticalScrollRange())
        end)

        frame.content.resultFrame.resultFeed = CraftSim.FRAME:CreateText("", frame.content.resultFrame, frame.content.resultFrame, 
            "TOPLEFT", "TOPLEFT", 10, -20, nil, nil, {type="H", value="LEFT"})
            frame.content.resultFrame.resultFeed:SetWidth(frame.content.resultFrame:GetWidth() - 5)
        frame.content.resultFrame.resultFeed:SetText("")
    end

    createContent(frameNO_WO)
    CraftSim.FRAME:EnableHyperLinksForFrameAndChilds(frameNO_WO)
end
