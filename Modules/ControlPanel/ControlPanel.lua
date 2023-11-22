CraftSimAddonName, CraftSim = ...

CraftSim.CONTROL_PANEL = {}

CraftSim.CONTROL_PANEL.frame = nil

local print = CraftSim.UTIL:SetDebugPrint(CraftSim.CONST.DEBUG_IDS.CONTROL_PANEL)

function CraftSim.CONTROL_PANEL:ForgeFinderExportAll()
    print("ForgeFinder Export..")
    
    -- get all dragon flight item producing (and quality supporting?) recipes
    
    -- check current recipeData to fetch the current profession id
    local professionID
    if CraftSim.MAIN.currentRecipeData then
        professionID = CraftSim.MAIN.currentRecipeData.professionData.professionInfo.profession
    end
    
    local professionRecipeIDs = CraftSim.CACHE:GetCacheEntryByVersion(CraftSimRecipeIDs, professionID)
    
    if professionRecipeIDs and #professionRecipeIDs > 0 then
        professionRecipeIDs = CraftSim.GUTIL:Filter(professionRecipeIDs, function (recipeID)
            local recipeInfo = C_TradeSkillUI.GetRecipeInfo(recipeID)
            
            -- needs to have a recipeInfo
            if not recipeInfo then
                return false
            end
            
            -- only include learned recipes
            if not recipeInfo.learned then
                return false
            end

            -- do not include flagged or unflagged dummy recipes
            if recipeInfo.isDummyRecipe or tContains(CraftSim.CONST.BLIZZARD_DUMMY_RECIPES, recipeInfo.recipeID) then
                return false
            end

            -- do not include quest recipes
            if tContains(CraftSim.CONST.QUEST_PLAN_CATEGORY_IDS, recipeInfo.categoryID) then
                return false
            end

            if recipeInfo.isGatheringRecipe and recipeInfo.isSalvageRecipe and recipeInfo.isRecraft then
                return false
            end

            if not recipeInfo.supportsCraftingStats then
                return false
            end

            -- finally check if its a dragon isle recipe

            local recipeCategoryInfo = C_TradeSkillUI.GetCategoryInfo(recipeInfo.categoryID)
            local isDragonIsleRecipe = tContains(CraftSim.CONST.DRAGON_ISLES_CATEGORY_IDS, recipeCategoryInfo.parentCategoryID)
            if not isDragonIsleRecipe then
                return false
            end

            return true
        end)

        -- do it async

        local currentIndex = 1
        local numRecipes = #professionRecipeIDs
        local data = {}

        local function finishExport()
            print("Created " .. #data .. " RecipeData")
            if #data > 0 then
                ---@type CraftSim.JSONBuilder
                local jb = CraftSim.JSONBuilder()
                jb.json = jb.json .. "[\n"
                for index, recipeData in pairs(data) do
                    print("skill: " .. tostring(recipeData.professionStats.skill.value))
                    local recipeJson = recipeData:GetForgeFinderExport(1)
                    if index == #data then
                        jb.json = jb.json .. recipeJson
                    else
                        jb.json = jb.json .. recipeJson .. ",\n"
                    end
                end
                
                jb.json = jb.json .. "\n]"
                CraftSim.UTIL:KethoEditBox_Show(jb.json)
            end
        end

        local function mapRecipe()
            local recipeID = professionRecipeIDs[currentIndex]
            if recipeID then
                ---@type CraftSim.RecipeData
                local recipeData = CraftSim.RecipeData(recipeID)

                -- only for recipes that have a result which either has qualities or can multicraft
                if recipeData.resultData.itemsByQuality and #recipeData.resultData.itemsByQuality > 1 and (recipeData.supportsQualities or recipeData.supportsMulticraft) then
                    recipeData:SetEquippedProfessionGearSet()
                    table.insert(data, recipeData)
                end
                currentIndex = currentIndex + 1
                
                -- update button
                local currentPercent = CraftSim.GUTIL:Round(currentIndex / (numRecipes / 100))

                CraftSim.CONTROL_PANEL.frame.content.exportForgeFinderButton:SetText(CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CONTROL_PANEL_FORGEFINDER_EXPORTING) .. " " .. currentPercent.."%")
                C_Timer.After(0.001, mapRecipe)
            else
                -- if finished
                finishExport()
                CraftSim.CONTROL_PANEL.frame.content.exportForgeFinderButton:SetStatus("READY")
                CraftSim.UTIL:StopProfiling("FORGEFINDER_EXPORT")
            end
        end     

        CraftSim.UTIL:StartProfiling("FORGEFINDER_EXPORT") 
        CraftSim.CONTROL_PANEL.frame.content.exportForgeFinderButton:SetText(CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CONTROL_PANEL_FORGEFINDER_EXPORTING) .. " 0%")
        CraftSim.CONTROL_PANEL.frame.content.exportForgeFinderButton:SetEnabled(false)
        mapRecipe()
    end
end