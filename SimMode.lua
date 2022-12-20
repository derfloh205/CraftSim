CraftSimSIMULATION_MODE = {}

CraftSimSIMULATION_MODE.isActive = false
CraftSimSIMULATION_MODE.reagentOverwriteFrame = nil
CraftSimSIMULATION_MODE.recipeData = nil

function CraftSimSIMULATION_MODE:Init()

    CraftSimFRAME:InitSimModeFrames()
end

function CraftSimSIMULATION_MODE:OnInputAllocationChanged()
    if not CraftSimSIMULATION_MODE.recipeData then
        return
    end
    local inputBox = self
    local reagentData = CraftSimSIMULATION_MODE.recipeData.reagents[inputBox.reagentIndex]
    print("quality: " .. tostring(inputBox.qualityID))
    print("reagent: " .. tostring(reagentData.name))

    local inputText = self:GetText()

    -- TODO: prevent user from inputting wrong allocation total quantities..
    reagentData.itemsInfo[inputBox.qualityID].allocations = tonumber(inputText)

    print("reagentdata now set to " .. tostring(CraftSimSIMULATION_MODE.recipeData.reagents[inputBox.reagentIndex].itemsInfo[inputBox.qualityID].allocations))

    CraftSimMAIN:TriggerModulesByRecipeType()
end

function CraftSimSIMULATION_MODE:InitSimModeData(recipeData)
    CraftSimSIMULATION_MODE.recipeData = recipeData
    CraftSimFRAME:UpdateSimModeFrames(recipeData)

    -- TODO: update recipeData based on inputfields !!
    -- Otherwise when switching to sim mode it will only change when editing some material input
end