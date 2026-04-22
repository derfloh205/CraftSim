---@class CraftSim
local CraftSim = select(2, ...)
local CraftSimAddonName = select(1, ...)

---@class CraftSim.FRAME
CraftSim.FRAME = {}

local GGUI = CraftSim.GGUI
local GUTIL = CraftSim.GUTIL

CraftSim.FRAME.frames = {}

local Logger = CraftSim.DEBUG:RegisterLogger("Frames")

function CraftSim.FRAME:FormatStatDiffpercentText(statDiff, roundTo, suffix)
    if statDiff == nil then
        statDiff = 0
    end
    local sign = "+"
    if statDiff <= 0 then
        sign = ""
    end
    if suffix == nil then
        suffix = ""
    end
    return sign .. GUTIL:Round(statDiff, roundTo) .. suffix
end

--> in GGUI in gFrame
function CraftSim.FRAME:ToggleFrame(frame, visible)
    if visible then
        frame:Show()
    else
        frame:Hide()
    end
end

function CraftSim.FRAME:RestoreModulePositions()
    local specInfoFrame = GGUI:GetFrame(CraftSim.INIT.FRAMES, CraftSim.CONST.FRAMES.SPEC_INFO)
    local averageProfitFrame = GGUI:GetFrame(CraftSim.INIT.FRAMES, CraftSim.CONST.FRAMES.AVERAGE_PROFIT)
    local averageProfitFrameWO = GGUI:GetFrame(CraftSim.INIT.FRAMES,
        CraftSim.CONST.FRAMES.AVERAGE_PROFIT_WO)
    local topgearFrame = GGUI:GetFrame(CraftSim.INIT.FRAMES, CraftSim.CONST.FRAMES.TOP_GEAR)
    local topgearFrameWO = GGUI:GetFrame(CraftSim.INIT.FRAMES, CraftSim.CONST.FRAMES.TOP_GEAR_WORK_ORDER)
    local reagentOptimizationFrame = GGUI:GetFrame(CraftSim.INIT.FRAMES,
        CraftSim.CONST.FRAMES.REAGENT_OPTIMIZATION)
    local reagentOptimizationFrameWO = GGUI:GetFrame(CraftSim.INIT.FRAMES,
        CraftSim.CONST.FRAMES.REAGENT_OPTIMIZATION_WORK_ORDER)
    local infoFrame = GGUI:GetFrame(CraftSim.INIT.FRAMES, CraftSim.CONST.FRAMES.INFO)

    infoFrame:RestoreSavedConfig(UIParent)
    CraftSim.RECIPE_SCAN.frame:RestoreSavedConfig(ProfessionsFrame)
    CraftSim.CRAFT_LOG.logFrame:RestoreSavedConfig(UIParent)
    CraftSim.CRAFT_LOG.advFrame:RestoreSavedConfig(UIParent)
    CraftSim.CUSTOMER_HISTORY.frame:RestoreSavedConfig(ProfessionsFrame)
    specInfoFrame:RestoreSavedConfig(ProfessionsFrame)
    averageProfitFrame:RestoreSavedConfig(ProfessionsFrame)
    averageProfitFrameWO:RestoreSavedConfig(ProfessionsFrame)
    topgearFrame:RestoreSavedConfig(ProfessionsFrame)
    topgearFrameWO:RestoreSavedConfig(ProfessionsFrame)
    CraftSim.PRICING.frame:RestoreSavedConfig(ProfessionsFrame)
    CraftSim.PRICING.frameWO:RestoreSavedConfig(ProfessionsFrame)
    reagentOptimizationFrame:RestoreSavedConfig(ProfessionsFrame)
    reagentOptimizationFrameWO:RestoreSavedConfig(ProfessionsFrame)
    CraftSim.CRAFTQ.frame:RestoreSavedConfig(ProfessionsFrame)
    local patronRewardValuesFrame = GGUI:GetFrame(CraftSim.INIT.FRAMES,
        CraftSim.CONST.FRAMES.CRAFTQUEUE_PATRON_REWARD_VALUES)
    if patronRewardValuesFrame then
        patronRewardValuesFrame:RestoreSavedConfig(ProfessionsFrame)
    end

    CraftSim.CRAFT_BUFFS.frame:RestoreSavedConfig(ProfessionsFrame.CraftingPage)
    CraftSim.CRAFT_BUFFS.frameWO:RestoreSavedConfig(ProfessionsFrame.OrdersPage.OrderView.OrderDetails.SchematicForm)
    CraftSim.STATISTICS.frameNO_WO:RestoreSavedConfig(ProfessionsFrame.CraftingPage)
    CraftSim.STATISTICS.frameWO:RestoreSavedConfig(ProfessionsFrame.OrdersPage.OrderView.OrderDetails.SchematicForm)
    CraftSim.EXPLANATIONS.frame:RestoreSavedConfig(ProfessionsFrame)
    CraftSim.COOLDOWNS.frame:RestoreSavedConfig(ProfessionsFrame)

    CraftSim.CONCENTRATION_TRACKER.trackerFrame:RestoreSavedConfig(CraftSim.CONCENTRATION_TRACKER.frame.frame)
end

function CraftSim.FRAME:ResetFrames()
    for _, frame in pairs(CraftSim.INIT.FRAMES) do
        Logger:LogDebug(CraftSim.LOCAL:GetText("FRAMES_RESETTING") .. tostring(frame.frameID))
        frame:ResetPosition()
    end
end

--> in GGUI.Text
---@deprecated
function CraftSim.FRAME:CreateText(text, parent, anchorParent, anchorA, anchorB, anchorX, anchorY, scale, font,
                                   justifyData)
    scale = scale or 1
    font = font or "GameFontHighlight"

    local craftSimText = parent:CreateFontString(nil, "OVERLAY", font)
    craftSimText:SetText(text)
    craftSimText:SetPoint(anchorA, anchorParent, anchorB, anchorX, anchorY)
    craftSimText:SetScale(scale)

    if justifyData then
        if justifyData.type == "V" then
            -- retroactive compatible fix for 10.2.7
            justifyData.value = justifyData.value == "CENTER" and "MIDDLE" or justifyData.value
            craftSimText:SetJustifyV(justifyData.value)
        elseif justifyData.type == "H" then
            craftSimText:SetJustifyH(justifyData.value)
        elseif justifyData.type == "HV" then
            craftSimText:SetJustifyH(justifyData.valueH)
            justifyData.valueV = justifyData.valueV == "CENTER" and "MIDDLE" or justifyData.valueV
            craftSimText:SetJustifyV(justifyData.valueV)
        end
    end

    return craftSimText
end

--> in GGUI.TextInput
---@deprecated
function CraftSim.FRAME:CreateInput(name, parent, anchorParent, anchorA, anchorB, offsetX, offsetY, sizeX, sizeY,
                                    initialValue, onTextChangedCallback)
    local numericInput = CreateFrame("EditBox", name, parent, "InputBoxTemplate")
    numericInput:SetPoint(anchorA, anchorParent, anchorB, offsetX, offsetY)
    numericInput:SetSize(sizeX, sizeY)
    numericInput:SetAutoFocus(false) -- dont automatically focus
    numericInput:SetFontObject("ChatFontNormal")
    numericInput:SetText(initialValue)
    numericInput:SetScript("OnEscapePressed", function() numericInput:ClearFocus() end)
    numericInput:SetScript("OnEnterPressed", function() numericInput:ClearFocus() end)
    if onTextChangedCallback then
        numericInput:SetScript("OnTextChanged", onTextChangedCallback)
    end

    return numericInput
end
