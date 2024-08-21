---@class CraftSim
local CraftSim = select(2, ...)

---@class CraftSim.REAGENT_OPTIMIZATION.UI
CraftSim.REAGENT_OPTIMIZATION.UI = {}

local print = CraftSim.DEBUG:SetDebugPrint(CraftSim.CONST.DEBUG_IDS.REAGENT_OPTIMIZATION)

function CraftSim.REAGENT_OPTIMIZATION.UI:Init()
    local sizeX = 310
    local sizeY = 250
    local offsetX = -5
    local offsetY = -125

    local frameLevel = CraftSim.UTIL:NextFrameLevel()

    local frameWO = CraftSim.GGUI.Frame({
        parent = ProfessionsFrame.OrdersPage.OrderView.OrderDetails,
        anchorParent = ProfessionsFrame,
        sizeX = sizeX,
        sizeY = sizeY,
        frameID = CraftSim.CONST.FRAMES.REAGENT_OPTIMIZATION_WORK_ORDER,
        title = CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.REAGENT_OPTIMIZATION_TITLE) ..
            " " .. CraftSim.GUTIL:ColorizeText("WO", CraftSim.GUTIL.COLORS.GREY),
        collapseable = true,
        closeable = true,
        moveable = true,
        anchorA = "BOTTOMLEFT",
        anchorB = "BOTTOMRIGHT",
        offsetX = offsetX,
        offsetY = offsetY,
        backdropOptions = CraftSim.CONST.DEFAULT_BACKDROP_OPTIONS,
        onCloseCallback = CraftSim.CONTROL_PANEL:HandleModuleClose("MODULE_REAGENT_OPTIMIZATION"),
        frameTable = CraftSim.INIT.FRAMES,
        frameConfigTable = CraftSim.DB.OPTIONS:Get("GGUI_CONFIG"),
        frameStrata = CraftSim.CONST.MODULES_FRAME_STRATA,
        raiseOnInteraction = true,
        frameLevel = frameLevel
    })
    local frameNO_WO = CraftSim.GGUI.Frame({
        parent = ProfessionsFrame.CraftingPage.SchematicForm,
        anchorParent = ProfessionsFrame,
        sizeX = sizeX,
        sizeY = sizeY,
        frameID = CraftSim.CONST.FRAMES.REAGENT_OPTIMIZATION,
        title = CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.REAGENT_OPTIMIZATION_TITLE),
        collapseable = true,
        closeable = true,
        moveable = true,
        anchorA = "BOTTOMLEFT",
        anchorB = "BOTTOMRIGHT",
        offsetX = offsetX,
        offsetY = offsetY,
        backdropOptions = CraftSim.CONST.DEFAULT_BACKDROP_OPTIONS,
        onCloseCallback = CraftSim.CONTROL_PANEL:HandleModuleClose("MODULE_REAGENT_OPTIMIZATION"),
        frameTable = CraftSim.INIT.FRAMES,
        frameConfigTable = CraftSim.DB.OPTIONS:Get("GGUI_CONFIG"),
        frameStrata = CraftSim.CONST.MODULES_FRAME_STRATA,
        raiseOnInteraction = true,
        frameLevel = frameLevel
    })

    local function createContent(frame)
        frame.content.qualityText = CraftSim.GGUI.Text {
            parent = frame.content, anchorParent = frame.title.frame, anchorA = "TOP", anchorB = "TOP", offsetY = -25,
            text = CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.MATERIALS_REACHABLE_QUALITY)
        }

        frame.content.qualityIcon = CraftSim.GGUI.QualityIcon({
            parent = frame.content,
            anchorParent = frame.content.qualityText.frame,
            anchorA = "LEFT",
            anchorB = "RIGHT",
            offsetX = 3,
            sizeX = 25,
            sizeY = 25,
        })

        frame.content.allocateButton = CraftSim.GGUI.Button({
            parent = frame.content,
            anchorParent = frame.content.qualityText.frame,
            anchorA = "TOP",
            anchorB = "TOP",
            offsetY = -20,
            label = "Assign",
            sizeX = 15,
            sizeY = 20,
            adjustWidth = true,
        })

        frame.content.allocateText = frame.content:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        frame.content.allocateText:SetPoint("TOP", frame.content.qualityText.frame, "TOP", 0, -20)
        frame.content.allocateText:SetText("")

        frame.content.infoText = frame.content:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        frame.content.infoText:SetPoint("CENTER", frame.content, "CENTER", 0, 0)
        frame.content.infoText.NoCombinationFound = CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.MATERIALS_NO_COMBINATION)
        frame.content.infoText.SameCombination = CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.MATERIALS_BEST_COMBINATION)
        frame.content.infoText:SetText(frame.content.infoText.NoCombinationFound)

        local iconsOffsetY = -25
        local iconsSpacingY = 25

        frame.content.reagentFrames = {}
        frame.content.reagentFrames.rows = {}
        frame.content.reagentFrames.numReagents = 0
        local iconSize = 30
        table.insert(frame.content.reagentFrames.rows,
            CraftSim.REAGENT_OPTIMIZATION.UI:CreateReagentFrame(frame.content, frame.content.allocateButton.frame,
                iconsOffsetY, iconSize))
        table.insert(frame.content.reagentFrames.rows,
            CraftSim.REAGENT_OPTIMIZATION.UI:CreateReagentFrame(frame.content, frame.content.allocateButton.frame,
                iconsOffsetY - iconsSpacingY, iconSize))
        table.insert(frame.content.reagentFrames.rows,
            CraftSim.REAGENT_OPTIMIZATION.UI:CreateReagentFrame(frame.content, frame.content.allocateButton.frame,
                iconsOffsetY - iconsSpacingY * 2, iconSize))
        table.insert(frame.content.reagentFrames.rows,
            CraftSim.REAGENT_OPTIMIZATION.UI:CreateReagentFrame(frame.content, frame.content.allocateButton.frame,
                iconsOffsetY - iconsSpacingY * 3, iconSize))
        table.insert(frame.content.reagentFrames.rows,
            CraftSim.REAGENT_OPTIMIZATION.UI:CreateReagentFrame(frame.content, frame.content.allocateButton.frame,
                iconsOffsetY - iconsSpacingY * 4, iconSize))
        table.insert(frame.content.reagentFrames.rows,
            CraftSim.REAGENT_OPTIMIZATION.UI:CreateReagentFrame(frame.content, frame.content.allocateButton.frame,
                iconsOffsetY - iconsSpacingY * 5, iconSize))

        frame:Hide()
    end

    createContent(frameNO_WO)
    createContent(frameWO)
end

function CraftSim.REAGENT_OPTIMIZATION.UI:CreateReagentFrame(parent, hookFrame, y, iconSize)
    local reagentFrame = CreateFrame("frame", nil, parent)
    reagentFrame:SetSize(parent:GetWidth(), iconSize)
    reagentFrame:SetPoint("TOP", hookFrame, "TOP", 10, y)

    local qualityAmountTextX = 5

    local reagentRowOffsetX = 40
    local reagentIconsOffsetX = 70

    reagentFrame.q1Icon = CraftSim.GGUI.Icon({
        parent = reagentFrame,
        anchorParent = reagentFrame,
        sizeX = 25,
        sizeY = 25,
        anchorA = "LEFT",
        anchorB = "LEFT",
        offsetX = reagentRowOffsetX,
        qualityIconScale = 1.6,
    })
    reagentFrame.q2Icon = CraftSim.GGUI.Icon({
        parent = reagentFrame,
        anchorParent = reagentFrame,
        sizeX = 25,
        sizeY = 25,
        anchorA = "LEFT",
        anchorB = "LEFT",
        offsetX = reagentRowOffsetX + reagentIconsOffsetX,
        qualityIconScale = 1.6,
    })
    reagentFrame.q3Icon = CraftSim.GGUI.Icon({
        parent = reagentFrame,
        anchorParent = reagentFrame,
        sizeX = 25,
        sizeY = 25,
        anchorA = "LEFT",
        anchorB = "LEFT",
        offsetX = reagentRowOffsetX + reagentIconsOffsetX * 2,
        qualityIconScale = 1.6,
    })

    reagentFrame.q1text = reagentFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    reagentFrame.q1text:SetPoint("LEFT", reagentFrame.q1Icon.frame, "RIGHT", qualityAmountTextX, 0)
    reagentFrame.q1text:SetText("x ?")

    reagentFrame.q2text = reagentFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    reagentFrame.q2text:SetPoint("LEFT", reagentFrame.q2Icon.frame, "RIGHT", qualityAmountTextX, 0)
    reagentFrame.q2text:SetText("x ?")

    reagentFrame.q3text = reagentFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    reagentFrame.q3text:SetPoint("LEFT", reagentFrame.q3Icon.frame, "RIGHT", qualityAmountTextX, 0)
    reagentFrame.q3text:SetText("x ?")

    reagentFrame:Hide()
    return reagentFrame
end

---@param recipeData CraftSim.RecipeData
---@param optimizationResult? CraftSim.ReagentOptimizationResult
---@param exportMode number
function CraftSim.REAGENT_OPTIMIZATION.UI:UpdateReagentDisplay(recipeData, optimizationResult, exportMode)
    local materialFrame = nil
    if exportMode == CraftSim.CONST.EXPORT_MODE.WORK_ORDER then
        materialFrame = CraftSim.GGUI:GetFrame(CraftSim.INIT.FRAMES,
            CraftSim.CONST.FRAMES.REAGENT_OPTIMIZATION_WORK_ORDER)
    else
        materialFrame = CraftSim.GGUI:GetFrame(CraftSim.INIT.FRAMES, CraftSim.CONST.FRAMES.REAGENT_OPTIMIZATION)
    end

    local isSameAllocation = false
    if optimizationResult then
        isSameAllocation = optimizationResult:IsAllocated(recipeData)
    end

    if optimizationResult == nil or isSameAllocation then
        materialFrame.content.infoText:Show()
        if isSameAllocation then
            materialFrame.content.infoText:SetText(materialFrame.content.infoText.SameCombination)
        else
            materialFrame.content.infoText:SetText(materialFrame.content.infoText.NoCombinationFound)
        end

        materialFrame.content.qualityIcon:Hide()
        materialFrame.content.qualityText:Hide()
        materialFrame.content.allocateButton:Hide()

        for i = 1, #materialFrame.content.reagentFrames.rows, 1 do
            materialFrame.content.reagentFrames.rows[i]:Hide()
        end

        return
    else
        local hasItems = CraftSim.SIMULATION_MODE.isActive or optimizationResult:HasItems(recipeData:GetCrafterUID())
        materialFrame.content.allocateText:Hide()
        materialFrame.content.infoText:Hide()
        materialFrame.content.qualityIcon:Show()
        materialFrame.content.qualityText:Show()
        materialFrame.content.allocateButton:Show()
        materialFrame.content.allocateButton:SetEnabled(CraftSim.SIMULATION_MODE.isActive)
        if CraftSim.SIMULATION_MODE.isActive then
            materialFrame.content.allocateButton:SetText(CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.MATERIALS_ASSIGN))
            materialFrame.content.allocateButton:SetScript("OnClick", function(self)
                -- uncheck best quality box if checked
                local bestQBox = ProfessionsFrame.CraftingPage.SchematicForm.AllocateBestQualityCheckbox
                if bestQBox:GetChecked() then
                    bestQBox:Click()
                end
                CraftSim.REAGENT_OPTIMIZATION:AssignBestAllocation(optimizationResult)
            end)
        else
            materialFrame.content.allocateText:Show()
            materialFrame.content.allocateButton:Hide()
            if hasItems then
                materialFrame.content.allocateText:SetText(CraftSim.GUTIL:ColorizeText(
                    CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.MATERIALS_AVAILABLE), CraftSim.GUTIL.COLORS.GREEN))
            else
                materialFrame.content.allocateText:SetText(CraftSim.GUTIL:ColorizeText(
                    CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.MATERIALS_MISSING), CraftSim.GUTIL.COLORS.RED))
            end
        end
    end

    if optimizationResult.qualityID and optimizationResult.qualityID > 0 then
        materialFrame.content.qualityIcon:SetQuality(optimizationResult.qualityID)
        materialFrame.content.qualityIcon:Show()
        materialFrame.content.qualityText:SetText(CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.MATERIALS_REACHABLE_QUALITY))
    else
        materialFrame.content.qualityIcon:Hide()
        materialFrame.content.qualityText:SetText(CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.MATERIALS_CHEAPER))
    end
    for frameIndex = 1, #materialFrame.content.reagentFrames.rows, 1 do
        local reagent = optimizationResult.reagents[frameIndex]
        if reagent then
            local q1Item = reagent.items[1]
            local q2Item = reagent.items[2]
            local q3Item = reagent.items[3]

            materialFrame.content.reagentFrames.rows[frameIndex].q1Icon:SetItem(q1Item.item)
            materialFrame.content.reagentFrames.rows[frameIndex].q2Icon:SetItem(q2Item.item)
            materialFrame.content.reagentFrames.rows[frameIndex].q3Icon:SetItem(q3Item.item)

            materialFrame.content.reagentFrames.rows[frameIndex].q1text:SetText(q1Item.quantity)
            materialFrame.content.reagentFrames.rows[frameIndex].q2text:SetText(q2Item.quantity)
            materialFrame.content.reagentFrames.rows[frameIndex].q3text:SetText(q3Item.quantity)

            materialFrame.content.reagentFrames.rows[frameIndex]:Show()
        else
            materialFrame.content.reagentFrames.rows[frameIndex]:Hide()
        end
    end
end
