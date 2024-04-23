---@class CraftSim
local CraftSim = select(2, ...)

---@class CraftSim.CONTROL_PANEL
CraftSim.CONTROL_PANEL = {}

local GUTIL = CraftSim.GUTIL

---@class CraftSim.CONTROL_PANEL.FRAME : GGUI.Frame
CraftSim.CONTROL_PANEL.frame = nil

local print = CraftSim.DEBUG:SetDebugPrint(CraftSim.CONST.DEBUG_IDS.CONTROL_PANEL)

function CraftSim.CONTROL_PANEL:ForgeFinderExportAll()
    print("ForgeFinder Export..")

    if not C_TradeSkillUI.IsTradeSkillReady() then
        print("Tradeskill not ready")
        return
    end

    local professionRecipeIDs = C_TradeSkillUI.GetAllRecipeIDs()

    if professionRecipeIDs and #professionRecipeIDs > 0 then
        professionRecipeIDs = GUTIL:Filter(professionRecipeIDs, function(recipeID)
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

            local isDragonIsleRecipe = CraftSim.UTIL:IsDragonflightRecipe(recipeInfo.recipeID)
            if not isDragonIsleRecipe then
                return false
            end

            return true
        end)

        -- do it async

        local currentIndex = 1
        local numRecipes = #professionRecipeIDs
        local data = {}

        print("filtered recipeID: " .. tostring(numRecipes))

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
            print("map recipe: " .. tostring(currentIndex))
            if recipeID then
                CraftSim.DEBUG:StartProfiling("RecipeDataCreation")
                ---@type CraftSim.RecipeData
                local recipeData = CraftSim.RecipeData(recipeID)
                CraftSim.DEBUG:StopProfiling("RecipeDataCreation")

                -- only for recipes that have a result which either has qualities or can multicraft
                if recipeData.resultData.itemsByQuality and #recipeData.resultData.itemsByQuality > 1 and (recipeData.supportsQualities or recipeData.supportsMulticraft) then
                    recipeData:SetEquippedProfessionGearSet()
                    table.insert(data, recipeData)
                end
                currentIndex = currentIndex + 1

                -- update button
                local currentPercent = GUTIL:Round(currentIndex / (numRecipes / 100))

                CraftSim.CONTROL_PANEL.frame.content.exportForgeFinderButton:SetText(CraftSim.LOCAL:GetText(CraftSim
                    .CONST.TEXT.CONTROL_PANEL_FORGEFINDER_EXPORTING) .. " " .. currentPercent .. "%")
                RunNextFrame(mapRecipe)
            else
                -- if finished
                finishExport()
                CraftSim.CONTROL_PANEL.frame.content.exportForgeFinderButton:SetStatus("READY")
                CraftSim.DEBUG:StopProfiling("FORGEFINDER_EXPORT")
            end
        end

        CraftSim.DEBUG:StartProfiling("FORGEFINDER_EXPORT")
        CraftSim.CONTROL_PANEL.frame.content.exportForgeFinderButton:SetText(CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT
            .CONTROL_PANEL_FORGEFINDER_EXPORTING) .. " 0%")
        CraftSim.CONTROL_PANEL.frame.content.exportForgeFinderButton:SetEnabled(false)
        mapRecipe()
    end
end

---@param moduleOption CraftSim.GENERAL_OPTIONS
function CraftSim.CONTROL_PANEL:HandleModuleClose(moduleOption)
    return function()
        CraftSim.DB.OPTIONS:Save(moduleOption, false)
        CraftSim.CONTROL_PANEL.frame.content[moduleOption]:SetChecked(false)
    end
end
