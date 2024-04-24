---@class CraftSim
local CraftSim = select(2, ...)

---@class CraftSim.DEBUG
CraftSim.DEBUG = {}

---@type table<string, number>
CraftSim.DEBUG.profilings = {}
CraftSim.DEBUG.isMute = false

---@class CraftSim.DEBUG.FRAME
CraftSim.DEBUG.frame = nil

local GUTIL = CraftSim.GUTIL

local systemPrint = print

---@param debugID CraftSim.DEBUG_IDS
function CraftSim.DEBUG:SetDebugPrint(debugID)
    local function print(text, recursive, l, level)
        if CraftSim.DEBUG and CraftSim.DEBUG.frame then
            CraftSim.DEBUG:print(text, debugID, recursive, l, level)
        else
            systemPrint(text)
        end
    end

    return print
end

function CraftSim.DEBUG:SystemPrint(text)
    print(text)
end

function CraftSim.DEBUG:InspectTable(t, label)
    if DevTool then
        DevTool:AddData(t, label)
    end
end

function CraftSim.DEBUG:print(debugOutput, debugID, recursive, printLabel, level)
    local debugIDsDB = CraftSim.DB.OPTIONS:Get("DEBUG_IDS")
    if debugIDsDB[debugID] and not CraftSim.DEBUG.isMute then
        if type(debugOutput) == "table" then
            CraftSim.DEBUG:PrintTable(debugOutput, debugID, recursive, level)
        else
            local debugFrame = CraftSim.GGUI:GetFrame(CraftSim.INIT.FRAMES, CraftSim.CONST.FRAMES.DEBUG)
            debugFrame.addDebug(debugOutput, debugID, printLabel)
        end
    end
end

-- for debug purposes
function CraftSim.DEBUG:PrintTable(t, debugID, recursive, level)
    level = level or 0
    local levelString = ""
    for i = 1, level, 1 do
        levelString = levelString .. "-"
    end

    if t.Debug then
        for _, line in pairs(t:Debug()) do
            CraftSim.DEBUG:print(levelString .. tostring(line), debugID, false)
        end
        return
    end

    for k, v in pairs(t) do
        if type(v) == 'function' then
            CraftSim.DEBUG:print(levelString .. tostring(k) .. ": function", debugID, false)
        elseif not recursive or type(v) ~= "table" then
            CraftSim.DEBUG:print(levelString .. tostring(k) .. ": " .. tostring(v), debugID, false)
        elseif type(v) == "table" then
            CraftSim.DEBUG:print(levelString .. tostring(k) .. ": ", debugID, false)
            CraftSim.DEBUG:PrintTable(v, debugID, recursive, level + 1)
        end
    end
end

function CraftSim.DEBUG:CheckSpecNode(nodeID)
    local function print(text, r, l) -- override
        CraftSim.DEBUG:print(text, CraftSim.CONST.DEBUG_IDS.SPECDATA, r, l)
    end
end

---@deprecated
function CraftSim.DEBUG:CompareStatData()
    local function print(text, r, l) -- override
        CraftSim.DEBUG:print(text, CraftSim.CONST.DEBUG_IDS.SPECDATA, r, l)
    end
end

function CraftSim.DEBUG:PrintRecipeIDs(recipeID)
    recipeID = recipeID or CraftSim.INIT.currentRecipeData.recipeID
    local recipeInfo = C_TradeSkillUI.GetRecipeInfo(recipeID)

    if not recipeInfo then
        print("No RecipeInfo found")
        return
    end

    local itemID = nil
    if recipeInfo.isEnchantingRecipe then
        local enchantOutput = CraftSim.ENCHANT_RECIPE_DATA[recipeInfo.recipeID]
        if enchantOutput then
            itemID = CraftSim.ENCHANT_RECIPE_DATA[recipeInfo.recipeID].q1
        else
            print("no output for enchanting recipe found")
            return
        end
    else
        itemID = CraftSim.GUTIL:GetItemIDByLink(recipeInfo.hyperlink)
    end
    local itemName, itemLink, itemQuality, itemLevel, itemMinLevel, itemType, itemSubType,
    itemStackCount, itemEquipLoc, itemTexture, sellPrice, classID, subclassID, bindType,
    expacID, setID, isCraftingReagent
                                      = C_Item.GetItemInfo(itemID)
    ---@diagnostic disable-next-line: missing-parameter
    local data                        = C_TradeSkillUI.GetCategoryInfo(recipeInfo.categoryID)

    print("--")
    print("RecipeID: " .. recipeInfo.recipeID)
    print("ItemLevel: " .. tostring(recipeInfo.itemLevel))
    print("SubTypeID: " .. subclassID)
    print("SubType: " .. itemSubType)
    print("Category: " .. data.name)
    print("ID: " .. recipeInfo.categoryID)
    print("ParentCategoryID: " .. tostring(data.parentCategoryID))
    print("ParentSectionID: " .. tostring(data.parentSectionID))
end

function CraftSim.DEBUG:ProfilingUpdate(label)
    local time = debugprofilestop()
    local diff = time - CraftSim.DEBUG.profilings[label]
    CraftSim.DEBUG:print(label .. ": " .. CraftSim.GUTIL:Round(diff) .. " ms (u)", CraftSim.CONST.DEBUG_IDS.PROFILING)
end

function CraftSim.DEBUG:StartProfiling(label)
    local time = debugprofilestop();
    CraftSim.DEBUG.profilings[label] = time
end

function CraftSim.DEBUG:StopProfiling(label)
    local startTime = CraftSim.DEBUG.profilings[label]
    if not startTime then
        print("Util Profiling Label not found on Stop: " .. tostring(label))
        return
    end
    local time = debugprofilestop()
    local diff = time - startTime
    CraftSim.DEBUG.profilings[label] = nil
    CraftSim.DEBUG:print(label .. ": " .. CraftSim.GUTIL:Round(diff) .. " ms", CraftSim.CONST.DEBUG_IDS.PROFILING)
end

---@deprecated
function CraftSim.DEBUG:GetCacheGlobalsList()
    return {
    }
end
