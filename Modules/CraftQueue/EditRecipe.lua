---@class CraftSim
local CraftSim = select(2, ...)

local GGUI = CraftSim.GGUI
local GUTIL = CraftSim.GUTIL

local L = CraftSim.LOCAL:GetLocalizer()
local f = GUTIL:GetFormatter()

local Logger = CraftSim.DEBUG:RegisterLogger("CraftQueue.EditRecipe")

---@class CraftSim.CRAFTQ.EditRecipe
---@field editor CraftSim.CRAFTQ.EditRecipeFrame?
CraftSim.CRAFTQ.EditRecipe = CraftSim.CRAFTQ.EditRecipe or {}
---@class CraftSim.CRAFTQ.EditRecipe.UI
CraftSim.CRAFTQ.EditRecipe.UI = {}

function CraftSim.CRAFTQ.EditRecipe:CRAFTQUEUE_EDIT_RECIPE_HOST_READY(parent, anchorParent)
    CraftSim.CRAFTQ.EditRecipe.UI:Init(parent, anchorParent)
end

---@param craftQueueItem CraftSim.CraftQueueItem
function CraftSim.CRAFTQ.EditRecipe:CRAFTQUEUE_EDIT_RECIPE_REQUEST_OPEN(craftQueueItem)
    CraftSim.CRAFTQ.EditRecipe.UI:Open(craftQueueItem)
end

---@param moduleID CraftSim.ModuleID
function CraftSim.CRAFTQ.EditRecipe:CRAFTSIM_MODULE_CLOSED(moduleID)
    if moduleID ~= "MODULE_CRAFT_QUEUE" then
        return
    end
    CraftSim.CRAFTQ.EditRecipe.UI:Hide()
end

GUTIL:RegisterCustomEvents(CraftSim.CRAFTQ.EditRecipe, {
    "CRAFTQUEUE_EDIT_RECIPE_HOST_READY",
    "CRAFTQUEUE_EDIT_RECIPE_REQUEST_OPEN",
    "CRAFTSIM_MODULE_CLOSED",
})

-- Edit popup layering:
-- DIALOG keeps it above queue UI while still allowing MenuUtil context menus/submenus above it.
local CRAFTQ_EDIT_FRAME_STRATA = "DIALOG"
-- Selector popups (ItemSelector selection frames) should sit above edit popup content/backdrop.
local CRAFTQ_EDIT_SELECTOR_STRATA = "FULLSCREEN_DIALOG"
local CRAFTQ_EDIT_SELECTOR_FRAMELEVEL_OFFSET = 20

---@param editRecipeFrame CraftSim.CRAFTQ.EditRecipeFrame
---@param anchorA FramePoint?
---@param anchorB FramePoint?
---@param offsetX number?
---@param offsetY number?
local function BuildEditSelectorFrameOptions(editRecipeFrame, anchorA, anchorB, offsetX, offsetY)
    return {
        backdropOptions = CraftSim.CONST.DEFAULT_BACKDROP_OPTIONS,
        title = L("CRAFT_QUEUE_EDIT_RECIPE_REAGENTS_SELECT_LABEL"),
        anchorA = anchorA,
        anchorB = anchorB,
        offsetX = offsetX,
        offsetY = offsetY,
        frameStrata = CRAFTQ_EDIT_SELECTOR_STRATA,
        frameLevel = (editRecipeFrame.frame and editRecipeFrame.frame:GetFrameLevel() or 0) +
            CRAFTQ_EDIT_SELECTOR_FRAMELEVEL_OFFSET,
    }
end

--- Editor is parented to UIParent; hide it when the queue window hides and on left-click release outside
--- (GGUI `closeOnClickOutside` is off because it ignores ItemSelector popups and MenuUtil menus).
---@param editRecipeFrame CraftSim.CRAFTQ.EditRecipeFrame
local function RegisterEditRecipeFrameAutoHide(editRecipeFrame)
    editRecipeFrame.editOutsideCloseGraceUntil = 0
    editRecipeFrame.editOutsideCloseArmed = false

    local function mouseOverItemSelectorPopups()
        local content = editRecipeFrame.content
        if not content then
            return false
        end
        local lists = {
            content.optionalReagentSelectors,
            content.finishingReagentSelectors,
            content.requiredSelectableReagentSelectors,
            content.professionGearSelectors,
        }
        for _, selectors in ipairs(lists) do
            for _, sel in ipairs(selectors or {}) do
                local sf = sel.selectionFrame
                if sf and sf:IsVisible() and sf.frame and sf.frame:IsMouseOver() then
                    return true
                end
            end
        end
        return false
    end

    local function mouseOverOpenBlizzardMenu()
        if not Menu or not Menu.GetManager then
            return false
        end
        local ok, hover = pcall(function()
            local mgr = Menu.GetManager()
            if not mgr or not mgr.GetOpenMenu then
                return false
            end
            local open = mgr:GetOpenMenu()
            if not open or not open.IsShown or not open:IsShown() then
                return false
            end
            return open.IsMouseOver and open:IsMouseOver() or false
        end)
        return ok and hover or false
    end

    local function isDismissInteractionBlockedByHover()
        local host = editRecipeFrame.frame
        if host and host:IsMouseOver() then
            return true
        end
        if mouseOverItemSelectorPopups() then
            return true
        end
        if mouseOverOpenBlizzardMenu() then
            return true
        end
        local cq = CraftSim.CRAFTQ.frame
        if cq and cq.frame and cq.frame:IsVisible() and cq.frame:IsMouseOver() then
            return true
        end
        return false
    end

    editRecipeFrame.frame:HookScript("OnUpdate", function()
        if not editRecipeFrame:IsVisible() then
            editRecipeFrame.editOutsideCloseArmed = false
            return
        end
        if GetTime() < (editRecipeFrame.editOutsideCloseGraceUntil or 0) then
            return
        end
        if not IsMouseButtonDown("LeftButton") then
            if editRecipeFrame.editOutsideCloseArmed then
                editRecipeFrame:Hide()
                editRecipeFrame.editOutsideCloseArmed = false
            end
            return
        end
        if isDismissInteractionBlockedByHover() then
            editRecipeFrame.editOutsideCloseArmed = false
        else
            editRecipeFrame.editOutsideCloseArmed = true
        end
    end)
end

---@param parent frame
---@param anchorParent Region
---@return CraftSim.CRAFTQ.EditRecipeFrame editRecipeFrame
function CraftSim.CRAFTQ.EditRecipe.UI:Init(parent, anchorParent)
    if CraftSim.CRAFTQ.EditRecipe.editor then
        return CraftSim.CRAFTQ.EditRecipe.editor
    end
    local editFrameX = 600
    local editFrameY = 350
    ---@class CraftSim.CRAFTQ.EditRecipeFrame : GGUI.Frame
    ---@field editOutsideCloseGraceUntil number
    ---@field editOutsideCloseArmed boolean
    local editRecipeFrame = GGUI.Frame {
        parent = parent, anchorParent = anchorParent,
        sizeX = editFrameX, sizeY = editFrameY, backdropOptions = CraftSim.CONST.DEFAULT_BACKDROP_OPTIONS,
        title = L("CRAFT_QUEUE_EDIT_RECIPE_TITLE"),
        frameID = CraftSim.CONST.FRAMES.CRAFT_QUEUE_EDIT_RECIPE,
        -- Keep popup above module UI, but below MenuUtil context menus so submenus are not occluded.
        frameStrata = CRAFTQ_EDIT_FRAME_STRATA,
        frameLevel = CraftSim.UTIL:NextFrameLevel(),
        raiseOnInteraction = true,
        closeable = true,
        -- Opening from a context menu counts as an "outside" click and would close immediately if true.
        closeOnClickOutside = false,
        moveable = true, frameConfigTable = CraftSim.DB.OPTIONS:Get("GGUI_CONFIG"),
    }

    ---@type CraftSim.CraftQueueItem?
    editRecipeFrame.craftQueueItem = nil

    ---@class CraftSim.CRAFTQ.EditRecipeFrame.Content
    editRecipeFrame.content = editRecipeFrame.content

    editRecipeFrame.content.recipeName = GGUI.Text {
        parent = editRecipeFrame.content, anchorParent = editRecipeFrame.title.frame, anchorA = "TOP", anchorB = "BOTTOM",
        text = L("CRAFT_QUEUE_EDIT_RECIPE_NAME_LABEL"), scale = 1.5, offsetY = -10,
    }

    -- required reagent frames (only for quality reagents as the non quality ones are fixed anyway)
    local qIconSize = 15
    local qButtonSize = 20 -- kept for layout reference
    local qButtonSpacingX = 25
    local qButtonBaseOffsetX = 50
    local qButtonBaseOffsetY = -70

    -- required quality reagents list (FrameList-based, shared with SimulationMode)
    local reagentAnchorPoints = {
        {
            anchorParent = editRecipeFrame.content,
            offsetX = qButtonBaseOffsetX,
            offsetY = qButtonBaseOffsetY - 30,
            anchorA = "TOPLEFT",
            anchorB = "TOPLEFT",
        },
    }

    local function setAllReagentsByQuality(qualityID)
        if not editRecipeFrame.craftQueueItem or not editRecipeFrame.craftQueueItem.recipeData then
            return
        end

        local recipeData = editRecipeFrame.craftQueueItem.recipeData
        if recipeData:IsSimplifiedQualityRecipe() and qualityID == 3 then
            return
        end

        recipeData.reagentData:SetReagentsMaxByQuality(qualityID)
        recipeData:Update()
        CraftSim.CRAFTQ.UI:UpdateFrameListByCraftQueue()
        CraftSim.CRAFTQ.EditRecipe.UI:UpdateDisplay(editRecipeFrame.craftQueueItem)
    end

    local function onReagentQuantityChanged(row, columns, qualityIndex)
        if not editRecipeFrame.craftQueueItem or not editRecipeFrame.craftQueueItem.recipeData then
            return
        end

        local recipeData = editRecipeFrame.craftQueueItem.recipeData
        local reagent = row.reagent --[[@as CraftSim.Reagent?]]
        if not reagent then
            return
        end

        local simplified = recipeData:IsSimplifiedQualityRecipe()
        local requiredQuantity = reagent.requiredQuantity

        local qInputs = {}
        qInputs[1] = columns[2].input --[[@as GGUI.NumericInput]]
        qInputs[2] = columns[3].input --[[@as GGUI.NumericInput]]
        local maxIndex = 2
        if not simplified then
            qInputs[3] = columns[4].input --[[@as GGUI.NumericInput]]
            maxIndex = 3
        end

        local function getTotal()
            local total = 0
            for i = 1, maxIndex do
                local input = qInputs[i]
                total = total + (tonumber(input.currentValue) or 0)
            end
            return total
        end

        local total = getTotal()
        if total > requiredQuantity then
            local diff = total - requiredQuantity
            local changedInput = qInputs[qualityIndex]
            local newQuantity = math.max((tonumber(changedInput.currentValue) or 0) - diff, 0)
            changedInput.textInput:SetText(newQuantity)
            changedInput.currentValue = newQuantity
        end

        total = getTotal()

        local requiredText = (simplified and columns[4].text) or columns[5].text --[[@as GGUI.Text]]

        if total == requiredQuantity then
            requiredText:SetColor(GUTIL.COLORS.WHITE)

            -- propagate into reagent items
            reagent.items[1].quantity = qInputs[1].currentValue
            reagent.items[2].quantity = qInputs[2].currentValue
            if not simplified and qInputs[3] then
                reagent.items[3].quantity = qInputs[3].currentValue
            elseif reagent.items[3] then
                reagent.items[3].quantity = 0
            end

            recipeData:Update()
            CraftSim.CRAFTQ.UI:UpdateFrameListByCraftQueue()
            CraftSim.CRAFTQ.EditRecipe.UI:UpdateDisplay(editRecipeFrame.craftQueueItem)
        else
            requiredText:SetColor(GUTIL.COLORS.RED)
        end
    end

    editRecipeFrame.content.reagentList = CraftSim.WIDGETS.ReagentList {
        parent = editRecipeFrame.content,
        anchorPoints = reagentAnchorPoints,
        onHeaderClick = setAllReagentsByQuality,
        onQuantityChanged = onReagentQuantityChanged,
    }

    local oRFrameX = 100
    local oRFrameY = 65
    local optionalReagentsFrame = CreateFrame("frame", nil, editRecipeFrame.content)
    optionalReagentsFrame:SetSize(oRFrameX, oRFrameY)
    optionalReagentsFrame:SetPoint("TOPLEFT", editRecipeFrame.content.reagentList.frame, "TOPRIGHT", 0, 20)

    optionalReagentsFrame.collapse = function()
        optionalReagentsFrame:SetSize(oRFrameX, 0.1)
    end
    optionalReagentsFrame.decollapse = function()
        optionalReagentsFrame:SetSize(oRFrameX, oRFrameY)
    end
    optionalReagentsFrame.SetCollapsed = function(self, collapse)
        if collapse then
            optionalReagentsFrame.collapse()
        else
            optionalReagentsFrame.decollapse()
        end
    end

    editRecipeFrame.content.optionalReagentsFrame = optionalReagentsFrame

    -- optional reagent slots
    editRecipeFrame.content.optionalReagentsTitle = GGUI.Text {
        parent = optionalReagentsFrame, anchorParent = optionalReagentsFrame, anchorA = "TOPLEFT", anchorB = "TOPLEFT",
        text = L("CRAFT_QUEUE_EDIT_RECIPE_OPTIONAL_REAGENTS_LABEL"), justifyOptions = { type = "H", align = "LEFT" }
    }
    ---@class CraftSim.CRAFTQ.EditRecipeFrame.OptionalReagentSelector : GGUI.ItemSelector
    ---@field slot CraftSim.OptionalReagentSlot?

    ---@type CraftSim.CRAFTQ.EditRecipeFrame.OptionalReagentSelector[]
    editRecipeFrame.content.optionalReagentSelectors = {}
    local itemSelectorSizeX = 25
    local itemSelectorSizeY = 25
    local itemSelectorBaseOffsetX = 0
    local itemSelectorBaseOffsetY = -10
    local itemSelectorSpacingX = itemSelectorSizeX + 5
    local function CreateItemSelector(parent, anchorParent, saveTable, onSelectCallback, anchorA, anchorB, offsetX,
                                      offsetY)
        local numSelectors = #saveTable
        table.insert(saveTable, GGUI.ItemSelector {
            parent = parent, anchorParent = anchorParent, anchorA = "TOPLEFT", anchorB = "BOTTOMLEFT",
            offsetX = itemSelectorBaseOffsetX + itemSelectorSpacingX * numSelectors,
            offsetY = itemSelectorBaseOffsetY,
            sizeX = itemSelectorSizeX, sizeY = itemSelectorSizeY,
            selectionFrameOptions = BuildEditSelectorFrameOptions(editRecipeFrame, anchorA, anchorB, offsetX, offsetY),
            emptyIcon = CraftSim.CONST.ATLAS_TEXTURES.TRADESKILL_ICON_ADD, isAtlas = true, onSelectCallback = onSelectCallback
        })
    end

    ---@param itemSelector CraftSim.CRAFTQ.EditRecipeFrame.OptionalReagentSelector
    ---@param selectedItem ItemMixin?
    ---@param selectedCurrencyID number?
    local function OnSelectOptionalReagent(itemSelector, selectedItem, selectedCurrencyID)
        local currentCraftQueueUID = editRecipeFrame.craftQueueItem.recipeData:GetRecipeCraftQueueUID()
        if itemSelector and itemSelector.slot then
            if selectedCurrencyID then
                itemSelector.slot:SetCurrencyReagent(selectedCurrencyID)
            elseif not selectedItem and itemSelector.slot:IsCurrency() then
                itemSelector.slot:SetCurrencyReagent(nil)
            else
                Logger:LogDebug("setting reagent: " .. tostring(selectedItem and selectedItem:GetItemLink()))
                itemSelector.slot:SetReagent((selectedItem and selectedItem:GetItemID()) or nil)
            end
            editRecipeFrame.craftQueueItem.recipeData:Update()

            -- Update craftQueueUID if it has changed
            local newCraftQueueUID = editRecipeFrame.craftQueueItem.recipeData:GetRecipeCraftQueueUID()
            if currentCraftQueueUID ~= newCraftQueueUID then
                -- if there is already another mapping with the same uid, merge the others amount into the current one
                if CraftSim.CRAFTQ.craftQueue.recipeCrafterMap[newCraftQueueUID] then
                    local existingItem = CraftSim.CRAFTQ.craftQueue.recipeCrafterMap[newCraftQueueUID]
                    editRecipeFrame.craftQueueItem.amount = existingItem.amount + editRecipeFrame.craftQueueItem.amount
                    -- remove old item from craftqueue
                    CraftSim.CRAFTQ.craftQueue:Remove(existingItem)
                else
                    -- if not just update the mapping
                    CraftSim.CRAFTQ.craftQueue.recipeCrafterMap[newCraftQueueUID] = editRecipeFrame.craftQueueItem
                    CraftSim.CRAFTQ.craftQueue.recipeCrafterMap[currentCraftQueueUID] = nil
                    editRecipeFrame.craftQueueItem.craftQueueUID = newCraftQueueUID
                end
            end

            CraftSim.CRAFTQ.UI:UpdateFrameListByCraftQueue()
            CraftSim.CRAFTQ.EditRecipe.UI:UpdateDisplay(editRecipeFrame.craftQueueItem)
        end
    end

    local numOptionalReagentSelectors = 3
    for _ = 1, numOptionalReagentSelectors do
        CreateItemSelector(optionalReagentsFrame, editRecipeFrame.content.optionalReagentsTitle.frame,
            editRecipeFrame.content.optionalReagentSelectors, OnSelectOptionalReagent)
    end

    editRecipeFrame.content.finishingReagentsTitle = GGUI.Text {
        parent = editRecipeFrame.content, anchorParent = optionalReagentsFrame, anchorA = "TOPLEFT", anchorB = "BOTTOMLEFT",
        text = L("CRAFT_QUEUE_EDIT_RECIPE_FINISHING_REAGENTS_LABEL"), justifyOptions = { type = "H", align = "LEFT" }
    }

    ---@type CraftSim.CRAFTQ.EditRecipeFrame.OptionalReagentSelector[]
    editRecipeFrame.content.finishingReagentSelectors = {}
    local numFinishingReagentSelectors = 3
    for _ = 1, numFinishingReagentSelectors do
        CreateItemSelector(editRecipeFrame.content, editRecipeFrame.content.finishingReagentsTitle.frame,
            editRecipeFrame.content.finishingReagentSelectors, OnSelectOptionalReagent)
    end

    editRecipeFrame.content.requiredSelectableReagentTitle = GGUI.Text {
        parent = editRecipeFrame.content, anchorParent = optionalReagentsFrame, anchorA = "TOPLEFT", anchorB = "BOTTOMLEFT", offsetY = -65,
        text = L("CRAFT_QUEUE_EDIT_RECIPE_SPARK_LABEL"), justifyOptions = { type = "H", align = "LEFT" }
    }


    ---@type CraftSim.CRAFTQ.EditRecipeFrame.OptionalReagentSelector[]
    editRecipeFrame.content.requiredSelectableReagentSelectors = {}
    CreateItemSelector(editRecipeFrame.content, editRecipeFrame.content.requiredSelectableReagentTitle.frame,
        editRecipeFrame.content.requiredSelectableReagentSelectors, OnSelectOptionalReagent)

    editRecipeFrame.content.professionGearTitle = GGUI.Text {
        parent = editRecipeFrame.content, anchorParent = editRecipeFrame.content.optionalReagentsTitle.frame, anchorA = "LEFT", anchorB = "RIGHT", offsetX = 20,
        text = L("CRAFT_QUEUE_EDIT_RECIPE_PROFESSION_GEAR_LABEL"), justifyOptions = { type = "H", align = "LEFT" }
    }

    ---@class CraftSim.CRAFTQ.EditRecipeFrame.ProfessionGearSelector : GGUI.ItemSelector
    ---@field professionGear CraftSim.ProfessionGear?

    ---@type CraftSim.CRAFTQ.EditRecipeFrame.ProfessionGearSelector[]
    editRecipeFrame.content.professionGearSelectors = {}

    ---@param itemSelector CraftSim.CRAFTQ.EditRecipeFrame.ProfessionGearSelector
    ---@param item ItemMixin?
    local function OnSelectProfessionGear(itemSelector, item)
        Logger:LogDebug("on select professiongear: " .. tostring(item and item:GetItemLink()))
        if itemSelector and itemSelector.professionGear then
            if item then
                Logger:LogDebug("setting gear: " .. tostring(item:GetItemLink()))
                item:ContinueOnItemLoad(function()
                    itemSelector.professionGear:SetItem(item:GetItemLink())
                    editRecipeFrame.craftQueueItem.recipeData.professionGearSet:UpdateProfessionStats()
                    editRecipeFrame.craftQueueItem.recipeData:Update()
                    CraftSim.CRAFTQ.UI:UpdateFrameListByCraftQueue()
                    CraftSim.CRAFTQ.EditRecipe.UI:UpdateDisplay(editRecipeFrame.craftQueueItem)
                end)
            else
                Logger:LogDebug("setting gear to no gear")
                itemSelector.professionGear:SetItem(nil)
                editRecipeFrame.craftQueueItem.recipeData.professionGearSet:UpdateProfessionStats()
                editRecipeFrame.craftQueueItem.recipeData:Update()
                CraftSim.CRAFTQ.UI:UpdateFrameListByCraftQueue()
                CraftSim.CRAFTQ.EditRecipe.UI:UpdateDisplay(editRecipeFrame.craftQueueItem)
            end
        end
    end

    for _ = 1, 3 do
        CreateItemSelector(editRecipeFrame.content, editRecipeFrame.content.professionGearTitle.frame,
            editRecipeFrame.content.professionGearSelectors, OnSelectProfessionGear, "TOPRIGHT", "TOPLEFT", 0, -25)
    end

    editRecipeFrame.content.optimizeProfitButton = GGUI.Button {
        parent = editRecipeFrame.content, anchorParent = editRecipeFrame.content.professionGearTitle.frame, anchorA = "TOPLEFT", anchorB = "BOTTOMLEFT", offsetY = -50,
        label = L("CRAFT_QUEUE_EDIT_RECIPE_OPTIMIZE_PROFIT_BUTTON"), sizeX = 150,
        clickCallback = function(optimizeButton)
            if editRecipeFrame.craftQueueItem and editRecipeFrame.craftQueueItem.recipeData then
                local recipeData                  = editRecipeFrame.craftQueueItem.recipeData
                local OPT_ID                      = CraftSim.CONST.OPTIMIZATION_OPTIONS_IDS.CRAFTQUEUE_EDIT_RECIPE
                local KEYS                        = CraftSim.WIDGETS.OptimizationOptions.OPTION_KEYS
                local FA                          = CraftSim.WIDGETS.OptimizationOptions.FINISHING_REAGENTS_ALGORITHM
                local optimizeProfessionGear      = CraftSim.DB.OPTIMIZATION_OPTIONS:Get(OPT_ID,
                    KEYS.OPTIMIZE_PROFESSION_TOOLS, true)
                local optimizeConcentration       = CraftSim.DB.OPTIMIZATION_OPTIONS:Get(OPT_ID,
                    KEYS.OPTIMIZE_CONCENTRATION, true)
                local optimizeFinishingReagents   = CraftSim.DB.OPTIMIZATION_OPTIONS:Get(OPT_ID,
                    KEYS.OPTIMIZE_FINISHING_REAGENTS, true)
                local finishingAlgorithm          = CraftSim.DB.OPTIMIZATION_OPTIONS:Get(OPT_ID,
                    KEYS.FINISHING_REAGENTS_ALGORITHM, FA.SIMPLE)

                -- Never consider locked finishing slots in Craft Queue, but ALWAYS include soulbound
                -- when optimizing via Craft Queue.
                local includeLockedFinishing      = false
                local includeSoulboundFinishing   = CraftSim.DB.OPTIMIZATION_OPTIONS:Get(OPT_ID,
                    KEYS.INCLUDE_SOULBOUND_FINISHING_REAGENTS, false)
                local onlyHighestQualitySoulbound = CraftSim.DB.OPTIMIZATION_OPTIONS:Get(OPT_ID,
                    KEYS.ONLY_HIGHEST_QUALITY_SOULBOUND_FINISHING_REAGENTS, false)
                local queueAmount                 = editRecipeFrame.craftQueueItem.amount or 1

                local function finalizeOptimize()
                    if includeSoulboundFinishing then
                        -- Ensure selected soulbound finishing reagents can cover the queued amount.
                        recipeData:AdjustSoulboundFinishingForAmount(queueAmount)
                    end
                    CraftSim.CRAFTQ.UI:UpdateFrameListByCraftQueue()
                    CraftSim.CRAFTQ.EditRecipe.UI:UpdateDisplay(editRecipeFrame.craftQueueItem)
                    optimizeButton:SetEnabled(true)
                    optimizeButton:SetText(L("CRAFT_QUEUE_EDIT_RECIPE_OPTIMIZE_PROFIT_BUTTON"))
                end

                local optimizeTopProfit = CraftSim.DB.OPTIMIZATION_OPTIONS:Get(OPT_ID, KEYS
                    .AUTOSELECT_TOP_PROFIT_QUALITY, true)

                optimizeButton:SetEnabled(false)
                recipeData:Optimize {
                    optimizeGear = optimizeProfessionGear,
                    optimizeReagentOptions = { highestProfit = optimizeTopProfit },
                    optimizeConcentration = optimizeConcentration,
                    optimizeConcentrationProgressCallback = function(progress)
                        optimizeButton:SetText(string.format("CON: %.0f%%", progress))
                    end,
                    optimizeFinishingReagentsOptions = optimizeFinishingReagents and {
                        includeLocked = includeLockedFinishing,
                        includeSoulbound = includeSoulboundFinishing,
                        onlyHighestQualitySoulbound = onlyHighestQualitySoulbound,
                        permutationBased = finishingAlgorithm == FA.PERMUTATION,
                        progressUpdateCallback = function(progress)
                            optimizeButton:SetText(string.format("FIN: %.0f%%", progress))
                        end,
                    } or nil,
                    finally = function()
                        finalizeOptimize()
                    end,
                }
            end
        end
    }

    editRecipeFrame.content.optimizeProfitButtonOptions = CraftSim.WIDGETS.OptimizationOptions {
        parent = editRecipeFrame.content,
        anchorPoints = { { anchorParent = editRecipeFrame.content.optimizeProfitButton.frame, anchorA = "LEFT", anchorB = "RIGHT", offsetX = 5 } },
        optimizationOptionsID = CraftSim.CONST.OPTIMIZATION_OPTIONS_IDS.CRAFTQUEUE_EDIT_RECIPE,
        showOptions = {
            AUTOSELECT_TOP_PROFIT_QUALITY                     = true,
            OPTIMIZE_PROFESSION_TOOLS                         = true,
            OPTIMIZE_CONCENTRATION                            = true,
            OPTIMIZE_FINISHING_REAGENTS                       = true,
            INCLUDE_SOULBOUND_FINISHING_REAGENTS              = true,
            ONLY_HIGHEST_QUALITY_SOULBOUND_FINISHING_REAGENTS = true,
            FINISHING_REAGENTS_ALGORITHM                      = true,
        },
        defaults = {
            AUTOSELECT_TOP_PROFIT_QUALITY                     = true,
            OPTIMIZE_PROFESSION_TOOLS                         = true,
            OPTIMIZE_CONCENTRATION                            = true,
            OPTIMIZE_FINISHING_REAGENTS                       = true,
            INCLUDE_SOULBOUND_FINISHING_REAGENTS              = false,
            ONLY_HIGHEST_QUALITY_SOULBOUND_FINISHING_REAGENTS = false,
            FINISHING_REAGENTS_ALGORITHM                      = CraftSim.WIDGETS.OptimizationOptions.FINISHING_REAGENTS_ALGORITHM.SIMPLE,
        },
        recipeDataProvider = function()
            return editRecipeFrame.craftQueueItem and editRecipeFrame.craftQueueItem.recipeData
        end,
    }

    editRecipeFrame.content.resultTitle = GGUI.Text {
        parent = editRecipeFrame.content, anchorParent = editRecipeFrame.content.optimizeProfitButton.frame, anchorA = "TOPLEFT", anchorB = "BOTTOMLEFT",
        offsetY = -40, text = L("CRAFT_QUEUE_EDIT_RECIPE_RESULTS_LABEL"),
    }

    editRecipeFrame.content.concentrationCB = GGUI.Checkbox {
        parent = editRecipeFrame.content, anchorParent = editRecipeFrame.content.resultTitle.frame, anchorA = "BOTTOMLEFT", anchorB = "TOPLEFT",
        offsetY = 5, scale = 2,
        labelOptions = {
            text = GUTIL:IconToText(CraftSim.CONST.CONCENTRATION_ICON, 15, 15) .. L("CRAFT_QUEUE_EDIT_RECIPE_CONCENTRATION_CHECKBOX")
        },
        clickCallback = function(_, checked)
            if editRecipeFrame.craftQueueItem and editRecipeFrame.craftQueueItem.recipeData then
                editRecipeFrame.craftQueueItem.recipeData.concentrating = checked
                editRecipeFrame.craftQueueItem.concentrating = checked
                editRecipeFrame.craftQueueItem.recipeData:Update()
                CraftSim.CRAFTQ.UI:UpdateFrameListByCraftQueue()
                CraftSim.CRAFTQ.EditRecipe.UI:UpdateDisplay(editRecipeFrame.craftQueueItem)
            end
        end
    }
    do
        local cbFrame = editRecipeFrame.content.concentrationCB.frame
        cbFrame:SetScript("OnEnter", function()
            local frame = editRecipeFrame
            local craftQueueItem = frame.craftQueueItem
            if not craftQueueItem or not craftQueueItem.recipeData or not craftQueueItem.recipeData.supportsQualities then return end
            local recipeData = craftQueueItem.recipeData
            local concentrationData = recipeData.concentrationData
            local cost = recipeData.concentrationCost
            if not concentrationData or not cost or cost <= 0 then return end
            if recipeData:IsCrafter() then
                concentrationData:Update()
            end
            local formatMode = CraftSim.DB.OPTIONS:Get("CONCENTRATION_TRACKER_FORMAT_MODE")
            local useUSFormat = formatMode == CraftSim.CONCENTRATION_TRACKER.UI.FORMAT_MODE.AMERICA_MAX_DATE
            if concentrationData:GetCurrentAmount() < cost then
                local estimatedText = concentrationData:GetEstimatedTimeUntilEnoughText(cost, useUSFormat)
                if estimatedText then
                    GameTooltip:SetOwner(cbFrame, "ANCHOR_RIGHT")
                    GameTooltip:ClearLines()
                    GameTooltip:SetText(estimatedText)
                    GameTooltip:Show()
                end
            end
        end)
        cbFrame:SetScript("OnLeave", function()
            GameTooltip:Hide()
        end)
    end

    editRecipeFrame.content.resultList = GGUI.FrameList {
        parent = editRecipeFrame.content, anchorParent = editRecipeFrame.content.resultTitle.frame, anchorA = "TOPLEFT", anchorB = "BOTTOMLEFT",
        hideScrollbar = true, offsetX = -10, sizeY = 100, rowHeight = 30,
        columnOptions = {
            {
                width = 40, -- icon
            },
        },
        rowConstructor = function(columns, row)
            local iconColumn = columns[1]

            ---@type QualityID
            row.qualityID = nil

            iconColumn.icon = GGUI.Icon {
                parent = iconColumn, anchorParent = iconColumn, sizeX = 30, sizeY = 30, anchorA = "LEFT", anchorB = "LEFT", offsetX = 3,
            }
        end
    }

    -- bottom stats block (4 rows, 2 columns), centered near the bottom of the window
    editRecipeFrame.content.statsFrame = CreateFrame("frame", nil, editRecipeFrame.content)
    editRecipeFrame.content.statsFrame:SetSize(320, 80)
    -- center horizontally on the whole content frame, with a fixed vertical offset from the bottom
    editRecipeFrame.content.statsFrame:SetPoint("BOTTOM", editRecipeFrame.content, "BOTTOM", 0, 5)
    local statsFrame = editRecipeFrame.content.statsFrame

    editRecipeFrame.content.craftingCostsTitle = GGUI.Text {
        parent = statsFrame,
        anchorParent = statsFrame,
        anchorA = "TOPLEFT", anchorB = "TOPLEFT",
        justifyOptions = { type = "H", align = "RIGHT" },
        fixedWidth = 150,
        text = L("CRAFT_QUEUE_EDIT_RECIPE_CRAFTING_COSTS_LABEL"),
    }
    editRecipeFrame.content.craftingCostsValue = GGUI.Text {
        parent = statsFrame,
        anchorParent = editRecipeFrame.content.craftingCostsTitle.frame,
        anchorA = "LEFT", anchorB = "RIGHT",
        offsetX = 5, offsetY = 1,
        text = CraftSim.UTIL:FormatMoney(0, true),
        justifyOptions = { type = "H", align = "LEFT" },
        scale = 0.9,
    }
    editRecipeFrame.content.averageProfitTitle = GGUI.Text {
        parent = statsFrame,
        anchorParent = editRecipeFrame.content.craftingCostsTitle.frame,
        anchorA = "TOPLEFT", anchorB = "BOTTOMLEFT",
        offsetY = -7,
        justifyOptions = { type = "H", align = "RIGHT" },
        fixedWidth = 150,
        text = L("CRAFT_QUEUE_EDIT_RECIPE_AVERAGE_PROFIT_LABEL"),
    }
    editRecipeFrame.content.averageProfitValue = GGUI.Text {
        parent = statsFrame,
        anchorParent = editRecipeFrame.content.averageProfitTitle.frame,
        anchorA = "LEFT", anchorB = "RIGHT",
        offsetX = 5, offsetY = 1,
        text = CraftSim.UTIL:FormatMoney(0, true),
        justifyOptions = { type = "H", align = "LEFT" },
        scale = 0.9,
    }
    editRecipeFrame.content.concentrationValueTitle = GGUI.Text {
        parent = statsFrame,
        anchorParent = editRecipeFrame.content.averageProfitTitle.frame,
        anchorA = "TOPLEFT", anchorB = "BOTTOMLEFT",
        offsetY = -7,
        justifyOptions = { type = "H", align = "RIGHT" },
        fixedWidth = 150,
        text = "Concentration Value:",
    }
    editRecipeFrame.content.concentrationValue = GGUI.Text {
        parent = statsFrame,
        anchorParent = editRecipeFrame.content.concentrationValueTitle.frame,
        anchorA = "LEFT", anchorB = "RIGHT",
        offsetX = 5, offsetY = 1,
        text = CraftSim.UTIL:FormatMoney(0, true),
        justifyOptions = { type = "H", align = "LEFT" },
        scale = 0.9,
    }
    editRecipeFrame.content.concentrationDateTitle = GGUI.Text {
        parent = statsFrame,
        anchorParent = editRecipeFrame.content.concentrationValueTitle.frame,
        anchorA = "TOPLEFT", anchorB = "BOTTOMLEFT",
        offsetY = -7,
        justifyOptions = { type = "H", align = "RIGHT" },
        fixedWidth = 150,
        text = string.gsub(CraftSim.LOCAL:GetText("CONCENTRATION_ESTIMATED_TIME_UNTIL"), " %%s", ""),
    }
    editRecipeFrame.content.concentrationDateValue = GGUI.Text {
        parent = statsFrame,
        anchorParent = editRecipeFrame.content.concentrationDateTitle.frame,
        anchorA = "LEFT", anchorB = "RIGHT",
        offsetX = 5, offsetY = 1,
        text = "",
        justifyOptions = { type = "H", align = "LEFT" },
        scale = 0.9,
    }

    RegisterEditRecipeFrameAutoHide(editRecipeFrame)
    editRecipeFrame:Hide()
    CraftSim.CRAFTQ.EditRecipe.editor = editRecipeFrame
    return editRecipeFrame
end

--- Opens the queue recipe editor: ensures the Queue tab is active (edit frame is parented there), refreshes data, then shows and raises the popup.
---@param craftQueueItem CraftSim.CraftQueueItem
function CraftSim.CRAFTQ.EditRecipe.UI:Open(craftQueueItem)
    local cqFrame = CraftSim.CRAFTQ.frame
    if not cqFrame then
        return
    end
    if not cqFrame.content then
        return
    end

    local queueTab = cqFrame.content.queueTab

    local function finishOpen()
        local editRecipeFrame = CraftSim.CRAFTQ.EditRecipe.editor
        if not editRecipeFrame then
            return
        end

        local updateOk = pcall(function()
            CraftSim.CRAFTQ.EditRecipe.UI:UpdateDisplay(craftQueueItem)
        end)
        if not updateOk then
            Logger:LogDebug("CraftQueue.EditRecipe Open: UpdateDisplay failed")
            return
        end

        editRecipeFrame:Show()
        if editRecipeFrame.Raise then
            editRecipeFrame:Raise()
        end
        local host = editRecipeFrame.frame
        if host then
            host:SetToplevel(true)
            host:Raise()
        end
        editRecipeFrame.editOutsideCloseGraceUntil = GetTime() + 0.65
        editRecipeFrame.editOutsideCloseArmed = false
    end

    if queueTab and queueTab.content and queueTab.button and not queueTab.content:IsShown() then
        queueTab.button:Click()
    end
    -- One frame after tab switch / menu close so the dialog is not dismissed or obscured by the same interaction.
    RunNextFrame(finishOpen)
end

---@param craftQueueItem CraftSim.CraftQueueItem
function CraftSim.CRAFTQ.EditRecipe.UI:UpdateDisplay(craftQueueItem)
    ---@type CraftSim.CRAFTQ.EditRecipeFrame?
    local editRecipeFrame = CraftSim.CRAFTQ.EditRecipe.editor
    if not editRecipeFrame then
        return
    end
    local recipeData = craftQueueItem.recipeData
    recipeData.reagentData:RefreshSlotStatus()
    recipeData:RefreshCooldownDataIfProfessionOpen()
    craftQueueItem:CalculateCanCraft()
    editRecipeFrame.craftQueueItem = craftQueueItem
    ---@type CraftSim.CRAFTQ.EditRecipeFrame.Content
    editRecipeFrame.content = editRecipeFrame.content

    editRecipeFrame.content.recipeName:SetText(GUTIL:IconToText(recipeData.recipeIcon, 15, 15) ..
        " " .. recipeData.recipeName .. CraftSim.UTIL:GetRecipeCooldownChargesInlineSuffix(recipeData))
    editRecipeFrame.content.averageProfitValue:SetText(CraftSim.UTIL:FormatMoney(recipeData.averageProfitCached, true,
        recipeData.priceData.craftingCosts))
    local concentrationCostText = ""
    if editRecipeFrame.craftQueueItem.concentrating then
        concentrationCostText = " + " ..
            GUTIL:IconToText(CraftSim.CONST.CONCENTRATION_ICON, 15, 15) ..
            " " .. f.gold(editRecipeFrame.craftQueueItem.recipeData.concentrationCost)
    end

    local craftingCosts
    if recipeData.orderData then
        craftingCosts = recipeData.priceData.craftingCostsNoOrderReagents
    else
        craftingCosts = recipeData.priceData.craftingCosts
    end
    editRecipeFrame.content.craftingCostsValue:SetText(GUTIL:ColorizeText(
        CraftSim.UTIL:FormatMoney(craftingCosts), GUTIL.COLORS.RED) .. concentrationCostText)
    local concentrationValue = recipeData:GetConcentrationValue()
    editRecipeFrame.content.concentrationValue:SetText(CraftSim.UTIL:FormatMoney(concentrationValue, true))
    if recipeData.supportsQualities and recipeData.concentrationData and recipeData.concentrationCost > 0 then
        local concentrationData = recipeData.concentrationData
        if craftQueueItem.isCrafter then
            concentrationData:Update()
        end
        local requiredAmount = recipeData.concentrationCost * craftQueueItem.amount
        local formatMode = CraftSim.DB.OPTIONS:Get("CONCENTRATION_TRACKER_FORMAT_MODE")
        local useUSFormat = formatMode == CraftSim.CONCENTRATION_TRACKER.UI.FORMAT_MODE.AMERICA_MAX_DATE
        if concentrationData:GetCurrentAmount() < requiredAmount then
            editRecipeFrame.content.concentrationDateTitle:SetVisible(true)
            editRecipeFrame.content.concentrationDateValue:SetText(f.bb(concentrationData:GetFormattedDateUntil(
                requiredAmount, useUSFormat)))
            editRecipeFrame.content.concentrationDateValue:SetVisible(true)
        else
            editRecipeFrame.content.concentrationDateTitle:SetVisible(true)
            editRecipeFrame.content.concentrationDateValue:SetText(f.g("Ready"))
            editRecipeFrame.content.concentrationDateValue:SetVisible(true)
        end
    else
        editRecipeFrame.content.concentrationDateTitle:SetVisible(false)
        editRecipeFrame.content.concentrationDateValue:SetVisible(false)
    end

    -- required quality reagents
    if recipeData.hasQualityReagents then
        editRecipeFrame.content.reagentList:Populate(recipeData)
    else
        editRecipeFrame.content.reagentList:Hide()
    end

    -- optionals
    local optionalSelectors = editRecipeFrame.content.optionalReagentSelectors
    editRecipeFrame.content.optionalReagentsFrame:SetCollapsed(#recipeData.reagentData.optionalReagentSlots == 0)
    editRecipeFrame.content.optionalReagentsTitle:SetVisible(#recipeData.reagentData.optionalReagentSlots > 0)
    for selectorIndex, selector in pairs(optionalSelectors) do
        local optionalSlot = recipeData.reagentData.optionalReagentSlots[selectorIndex]
        if optionalSlot then
            selector.slot = optionalSlot
            selector:SetItems(optionalSlot:GetItemSelectorEntries())
            if optionalSlot.activeReagent then
                if optionalSlot.activeReagent:IsCurrency() then
                    selector:SetSelectedCurrency(optionalSlot.activeReagent.currencyID,
                        optionalSlot.activeReagent.qualityID)
                else
                    selector:SetSelectedItem(optionalSlot.activeReagent.item)
                end
            else
                selector:SetSelectedItem(nil)
            end
            selector:Show()
        else
            selector.slot = nil
            selector:SetItems({})
            selector:Hide()
        end
    end

    -- finishing
    local finishingSelectors = editRecipeFrame.content.finishingReagentSelectors
    editRecipeFrame.content.finishingReagentsTitle:SetVisible(#recipeData.reagentData.finishingReagentSlots > 0)
    for selectorIndex, selector in pairs(finishingSelectors) do
        local finishingSlot = recipeData.reagentData.finishingReagentSlots[selectorIndex]
        if finishingSlot then
            selector.slot = finishingSlot
            selector:SetItems(finishingSlot:GetItemSelectorEntries())
            if finishingSlot.activeReagent then
                if finishingSlot.activeReagent:IsCurrency() then
                    selector:SetSelectedCurrency(finishingSlot.activeReagent.currencyID,
                        finishingSlot.activeReagent.qualityID)
                else
                    selector:SetSelectedItem(finishingSlot.activeReagent.item)
                end
            else
                selector:SetSelectedItem(nil)
            end
            selector:Show()
        else
            selector.slot = nil
            selector:SetItems({})
            selector:Hide()
        end
    end

    -- Required Selectable
    local requiredSelectableReagentSelector = editRecipeFrame.content.requiredSelectableReagentSelectors[1]
    editRecipeFrame.content.requiredSelectableReagentTitle:SetVisible(recipeData.reagentData
        :HasRequiredSelectableReagent())
    local requiredSelectableReagentSlot = recipeData.reagentData.requiredSelectableReagentSlot
    if requiredSelectableReagentSlot then
        requiredSelectableReagentSelector.slot = requiredSelectableReagentSlot
        requiredSelectableReagentSelector:SetItems(requiredSelectableReagentSlot:GetItemSelectorEntries())
        if requiredSelectableReagentSlot.activeReagent then
            if requiredSelectableReagentSlot.activeReagent:IsCurrency() then
                requiredSelectableReagentSelector:SetSelectedCurrency(
                    requiredSelectableReagentSlot.activeReagent.currencyID,
                    requiredSelectableReagentSlot.activeReagent.qualityID)
            else
                requiredSelectableReagentSelector:SetSelectedItem(requiredSelectableReagentSlot.activeReagent.item)
            end
        else
            requiredSelectableReagentSelector:SetSelectedItem(nil)
        end
        requiredSelectableReagentSelector:Show()
    else
        requiredSelectableReagentSelector.slot = nil
        requiredSelectableReagentSelector:SetItems({})
        requiredSelectableReagentSelector:Hide()
    end

    local gearSelectors = editRecipeFrame.content.professionGearSelectors
    local professionGearSet = recipeData.professionGearSet
    -- profession gear  1 - gear 1, 2 - gear 2, 3 - tool
    if not recipeData.isCooking then
        gearSelectors[1]:SetSelectedItem(professionGearSet.gear1.item)
        gearSelectors[1].professionGear = professionGearSet.gear1
        gearSelectors[1]:Show()
        gearSelectors[2]:SetSelectedItem(professionGearSet.gear2.item)
        gearSelectors[2].professionGear = professionGearSet.gear2
        gearSelectors[3]:SetSelectedItem(professionGearSet.tool.item)
        gearSelectors[3].professionGear = professionGearSet.tool

        -- fill the selectors with profession items from the players bag but exclude for each selector all items that are selected
        local inventoryGear = CraftSim.TOPGEAR:GetProfessionGearFromInventory(recipeData)
        local equippedGear = CraftSim.ProfessionGearSet(recipeData)
        equippedGear:LoadCurrentEquippedSet()
        local equippedGearList = CraftSim.GUTIL:Filter(equippedGear:GetProfessionGearList(),
            function(gear) return gear and gear.item ~= nil end)
        ---@type CraftSim.ProfessionGear[]
        local allGear = CraftSim.GUTIL:Concat({ inventoryGear, equippedGearList })

        allGear = GUTIL:ToSet(allGear, function(gear)
            local compareLink = gear.item:GetItemLink():gsub("Player.':", "")
            return compareLink
        end)

        local gearSlotItems = GUTIL:Filter(allGear, function(gear)
            local isGearItem = gear.item:GetInventoryType() == Enum.InventoryType.IndexProfessionGearType
            if not isGearItem then
                return false
            end

            if gearSelectors[1].professionGear:Equals(gear) or gearSelectors[2].professionGear:Equals(gear) then
                return false
            end
            return true
        end)
        local toolSlotItems = GUTIL:Filter(allGear, function(gear)
            local isToolItem = gear.item:GetInventoryType() == Enum.InventoryType.IndexProfessionToolType
            if not isToolItem then
                return false
            end

            if gearSelectors[3].professionGear:Equals(gear) then
                return false
            end
            return true
        end)

        gearSelectors[1]:SetItems(GUTIL:Map(gearSlotItems, function(g) return g.item end))
        gearSelectors[2]:SetItems(GUTIL:Map(gearSlotItems, function(g) return g.item end))
        gearSelectors[3]:SetItems(GUTIL:Map(toolSlotItems, function(g) return g.item end))
    else
        gearSelectors[1]:Hide()
        gearSelectors[1].professionGear = nil
        gearSelectors[2]:SetSelectedItem(professionGearSet.gear2.item)
        gearSelectors[2].professionGear = professionGearSet.gear2
        gearSelectors[3]:SetSelectedItem(professionGearSet.tool.item)
        gearSelectors[3].professionGear = professionGearSet.tool

        -- fill the selectors with profession items from the players bag but exclude for each selector all items that are selected
        local inventoryGear = CraftSim.TOPGEAR:GetProfessionGearFromInventory(recipeData)
        local equippedGear = CraftSim.ProfessionGearSet(recipeData)
        equippedGear:LoadCurrentEquippedSet()
        local equippedGearList = CraftSim.GUTIL:Filter(equippedGear:GetProfessionGearList(),
            function(gear) return gear and gear.item ~= nil end)
        local allGear = CraftSim.GUTIL:Concat({ inventoryGear, equippedGearList })

        local gearSlotItems = GUTIL:Filter(allGear, function(gear)
            local isGearItem = gear.item:GetInventoryType() == Enum.InventoryType.IndexProfessionGearType
            if not isGearItem then
                return false
            end

            if gearSelectors[2].professionGear:Equals(gear) then
                return false
            end
            return true
        end)
        local toolSlotItems = GUTIL:Filter(allGear, function(gear)
            local isToolItem = gear.item:GetInventoryType() == Enum.InventoryType.IndexProfessionToolType
            if not isToolItem then
                return false
            end

            if gearSelectors[3].professionGear:Equals(gear) then
                return false
            end
            return true
        end)

        gearSelectors[2]:SetItems(GUTIL:Map(gearSlotItems, function(g) return g.item end))
        gearSelectors[3]:SetItems(GUTIL:Map(toolSlotItems, function(g) return g.item end))
    end

    local resultData = recipeData.resultData

    local resultList = editRecipeFrame.content.resultList --[[@as GGUI.FrameList]]

    resultList:Remove()

    resultList:Add(function(row, columns)
        local iconColumn = columns[1]
        row.qualityID = resultData.expectedQuality --[[@as QualityID]]

        iconColumn.icon:SetItem(resultData.expectedItem)
    end)

    resultList:UpdateDisplay()

    editRecipeFrame.content.concentrationCB:SetVisible(craftQueueItem.recipeData.supportsQualities)

    editRecipeFrame.content.concentrationCB:SetChecked(craftQueueItem.concentrating)
end

function CraftSim.CRAFTQ.EditRecipe.UI:Hide()
    local editRecipeFrame = CraftSim.CRAFTQ.EditRecipe.editor
    if editRecipeFrame and editRecipeFrame:IsVisible() then
        editRecipeFrame:Hide()
    end
end
