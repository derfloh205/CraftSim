---@class CraftSim
local CraftSim = select(2, ...)

---@class CraftSim.COST_OPTIMIZATION
CraftSim.COST_OPTIMIZATION = CraftSim.COST_OPTIMIZATION

---@class CraftSim.COST_OPTIMIZATION.UI
CraftSim.COST_OPTIMIZATION.UI = {}

local GGUI = CraftSim.GGUI
local GUTIL = CraftSim.GUTIL

CraftSim.COST_OPTIMIZATION.frame = nil
CraftSim.COST_OPTIMIZATION.frameWO = nil

local print = CraftSim.DEBUG:SetDebugPrint(CraftSim.CONST.DEBUG_IDS.COST_OPTIMIZATION)
local f = CraftSim.GUTIL:GetFormatter()

function CraftSim.COST_OPTIMIZATION.UI:Init()
    local sizeX = 520
    local sizeY = 280
    local offsetX = -5
    local offsetY = -120

    local frameLevel = CraftSim.UTIL:NextFrameLevel()

    CraftSim.COST_OPTIMIZATION.frame = GGUI.Frame({
        parent = ProfessionsFrame.CraftingPage.SchematicForm,
        anchorParent = ProfessionsFrame,
        anchorA = "BOTTOM",
        anchorB = "BOTTOM",
        sizeX = sizeX,
        sizeY = sizeY,
        offsetY = offsetY,
        offsetX = offsetX,
        frameID = CraftSim.CONST.FRAMES.COST_OPTIMIZATION,
        title = CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.COST_OPTIMIZATION_TITLE),
        collapseable = true,
        closeable = true,
        moveable = true,
        backdropOptions = CraftSim.CONST.DEFAULT_BACKDROP_OPTIONS,
        onCloseCallback = CraftSim.CONTROL_PANEL:HandleModuleClose("MODULE_COST_OPTIMIZATION"),
        frameTable = CraftSim.INIT.FRAMES,
        frameConfigTable = CraftSim.DB.OPTIONS:Get("GGUI_CONFIG"),
        frameStrata = CraftSim.CONST.MODULES_FRAME_STRATA,
        raiseOnInteraction = true,
        frameLevel = frameLevel
    })
    CraftSim.COST_OPTIMIZATION.frameWO = GGUI.Frame({
        parent = ProfessionsFrame.OrdersPage.OrderView.OrderDetails.SchematicForm,
        anchorParent = ProfessionsFrame,
        anchorA = "BOTTOM",
        anchorB = "BOTTOM",
        sizeX = sizeX,
        sizeY = sizeY,
        offsetY = offsetY,
        offsetX = offsetX,
        frameID = CraftSim.CONST.FRAMES.COST_OPTIMIZATION_WO,
        title = CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.COST_OPTIMIZATION_TITLE) ..
            " " .. CraftSim.GUTIL:ColorizeText("WO", CraftSim.GUTIL.COLORS.GREY),
        collapseable = true,
        closeable = true,
        moveable = true,
        backdropOptions = CraftSim.CONST.DEFAULT_BACKDROP_OPTIONS,
        onCloseCallback = CraftSim.CONTROL_PANEL:HandleModuleClose("MODULE_COST_OPTIMIZATION"),
        frameTable = CraftSim.INIT.FRAMES,
        frameConfigTable = CraftSim.DB.OPTIONS:Get("GGUI_CONFIG"),
        frameStrata = CraftSim.CONST.MODULES_FRAME_STRATA,
        raiseOnInteraction = true,
        frameLevel = frameLevel
    })

    local function createContent(frame)
        frame.content.reagentCostsTab = GGUI.BlizzardTab {
            buttonOptions = {
                parent = frame.content,
                anchorParent = frame.content,
                label = "Reagent Costs",
                offsetY = -2,
            },
            top = true,
            initialTab = true,
            parent = frame.content, anchorParent = frame.content,
            sizeX = sizeX - 5,
            sizeY = sizeY - 5,
        }

        ---@class CraftSim.COST_OPTIMIZATION.SubRecipeOptionsTab : GGUI.BlizzardTab
        frame.content.subRecipeOptions = GGUI.BlizzardTab {
            buttonOptions = {
                parent = frame.content,
                anchorParent = frame.content.reagentCostsTab.button,
                label = "Sub Recipe Options",
                anchorA = "LEFT", anchorB = "RIGHT",
            },
            top = true,
            parent = frame.content, anchorParent = frame.content,
            sizeX = sizeX - 5,
            sizeY = sizeY - 5,
        }

        self:InitSubRecipeOptions(frame.content.subRecipeOptions)

        local content = frame.content.reagentCostsTab.content

        content.craftingCostsTitle = GGUI.Text({
            parent = content,
            anchorParent = frame.title.frame,
            anchorA = "TOP",
            anchorB = "BOTTOM",
            offsetX = -30,
            offsetY = -15,
            text = CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.COST_OPTIMIZATION_CRAFTING_COSTS),
        })
        content.craftingCostsValue = GGUI.Text({
            parent = content,
            anchorParent = content.craftingCostsTitle.frame,
            anchorA = "LEFT",
            anchorB = "RIGHT",
            text = CraftSim.UTIL:FormatMoney(123456789),
            justifyOptions = { type = "H", align = "LEFT" }
        })

        content.automaticSubRecipeOptimizationCB = GGUI.Checkbox {
            parent = content, anchorParent = content.craftingCostsTitle.frame, anchorA = "TOP", anchorB = "BOTTOM",
            offsetX = -60, offsetY = -5, label = "Sub Recipe Optimization " .. f.bb("(experimental)"),
            tooltip = "If enabled " .. f.l("CraftSim") .. " considers the " .. f.g("optimized crafting costs") .. " of your character and your alts\nif they are able to craft that item.\n\n"
                .. f.r("Might decrease performance a bit due to a lot of additional calculations"),
            initialValue = CraftSim.DB.OPTIONS:Get("COST_OPTIMIZATION_AUTOMATIC_SUB_RECIPE_OPTIMIZATION"),
            clickCallback = function(_, checked)
                CraftSim.DB.OPTIONS:Save("COST_OPTIMIZATION_AUTOMATIC_SUB_RECIPE_OPTIMIZATION", checked)
                CraftSim.INIT:TriggerModulesByRecipeType()
            end
        }

        GGUI.HelpIcon({
            parent = content,
            anchorParent = frame.title.frame,
            anchorA = "LEFT",
            anchorB = "RIGHT",
            offsetX = 5,
            text = CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.COST_OPTIMIZATION_EXPLANATION)
        })


        content.reagentList = GGUI.FrameList({
            parent = content,
            anchorParent = content,
            anchorA = "TOP",
            anchorB = "TOP",
            offsetY = -100,
            sizeY = 150,
            showBorder = true,
            offsetX = -10,
            selectionOptions = {
                hoverRGBA = CraftSim.CONST.FRAME_LIST_SELECTION_COLORS.HOVER_LIGHT_WHITE,
                noSelectionColor = true
            },
            columnOptions = {
                {
                    label = CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.COST_OPTIMIZATION_ITEM_HEADER),
                    width = 40,
                    justifyOptions = { type = "H", align = "CENTER" }
                },
                {
                    label = CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.COST_OPTIMIZATION_AH_PRICE_HEADER),
                    width = 110,
                },
                {
                    label = CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.COST_OPTIMIZATION_OVERRIDE_HEADER),
                    width = 110,
                },
                {
                    label = CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.COST_OPTIMIZATION_CRAFTING_HEADER),
                    width = 110,
                },
                {
                    label = CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.COST_OPTIMIZATION_USED_SOURCE),
                    width = 80,
                    justifyOptions = { type = "H", align = "CENTER" }
                },
            },
            rowConstructor = function(columns)
                ---@class CraftSim.COST_OPTIMIZATION.UI.REAGENT_LIST.ITEM_COLUMN : Frame
                local itemColumn = columns[1]
                ---@class CraftSim.COST_OPTIMIZATION.UI.REAGENT_LIST.AH_COLUMN : Frame
                local ahPriceColumn = columns[2]
                ---@class CraftSim.COST_OPTIMIZATION.UI.REAGENT_LIST.OVERRIDE_COLUMN : Frame
                local overrideColumn = columns[3]
                ---@class CraftSim.COST_OPTIMIZATION.UI.REAGENT_LIST.CRAFTING_COLUMN : Frame
                local craftingCostsColumn = columns[4]
                ---@class CraftSim.COST_OPTIMIZATION.UI.REAGENT_LIST.SOURCE_COLUMN : Frame
                local usedPriceColumn = columns[5]

                itemColumn.itemIcon = GGUI.Icon({
                    parent = itemColumn,
                    anchorParent = itemColumn,
                    sizeX = 25,
                    sizeY = 25,
                    qualityIconScale = 1.4
                })

                ahPriceColumn.text = GGUI.Text({
                    parent = ahPriceColumn,
                    anchorParent = ahPriceColumn,
                    anchorA = "LEFT",
                    anchorB = "LEFT",
                    justifyOptions = { type = "H", align = "LEFT" },
                    text = CraftSim.UTIL:FormatMoney(123456789)
                })
                overrideColumn.text = GGUI.Text({
                    parent = overrideColumn,
                    anchorParent = overrideColumn,
                    anchorA = "LEFT",
                    anchorB = "LEFT",
                    justifyOptions = { type = "H", align = "LEFT" },
                    text = CraftSim.UTIL:FormatMoney(123456789)
                })
                craftingCostsColumn.text = GGUI.Text({
                    parent = craftingCostsColumn,
                    anchorParent = craftingCostsColumn,
                    anchorA = "LEFT",
                    anchorB = "LEFT",
                    justifyOptions = { type = "H", align = "LEFT" },
                    text = f.grey("-")
                })
                usedPriceColumn.text = GGUI.Text({
                    parent = usedPriceColumn,
                    anchorParent = usedPriceColumn,
                    text = CraftSim.GUTIL:ColorizeText("AH", CraftSim.GUTIL.COLORS.GREEN)
                })

                function usedPriceColumn:SetAH()
                    usedPriceColumn.text:SetText(CraftSim.GUTIL:ColorizeText("AH", CraftSim.GUTIL.COLORS.GREEN))
                end

                function usedPriceColumn:SetOverride()
                    usedPriceColumn.text:SetText(CraftSim.GUTIL:ColorizeText("OR", CraftSim.GUTIL.COLORS.LEGENDARY))
                end

                function usedPriceColumn:SetUnknown()
                    usedPriceColumn.text:SetText(CraftSim.GUTIL:ColorizeText("-", CraftSim.GUTIL.COLORS.RED))
                end

                function usedPriceColumn:SetCrafter(crafterUID, profession, needsConcentration)
                    local iconSize = 15
                    local crafterName = f.class(select(1, strsplit("-", crafterUID)),
                        CraftSim.DB.CRAFTER:GetClass(crafterUID))
                    crafterName = GUTIL:IconToText(CraftSim.CONST.PROFESSION_ICONS[profession], iconSize, iconSize) ..
                        crafterName
                    if needsConcentration then
                        crafterName = GUTIL:IconToText(CraftSim.CONST.CONCENTRATION_ICON, iconSize, iconSize) ..
                            crafterName
                    end
                    usedPriceColumn.text:SetText(crafterName)
                end
            end
        })

        GGUI.BlizzardTabSystem { frame.content.reagentCostsTab, frame.content.subRecipeOptions }
    end

    createContent(CraftSim.COST_OPTIMIZATION.frame)
    createContent(CraftSim.COST_OPTIMIZATION.frameWO)
end

---@param subRecipeOptionsTab CraftSim.COST_OPTIMIZATION.SubRecipeOptionsTab
function CraftSim.COST_OPTIMIZATION.UI:InitSubRecipeOptions(subRecipeOptionsTab)
    ---@class CraftSim.COST_OPTIMIZATION.SubRecipeOptionsTab.Content : Frame
    local content = subRecipeOptionsTab.content

    content.maxRecipeDepthSlider = GGUI.Slider {
        parent = content, anchorParent = content, anchorA = "TOP", anchorB = "TOP", offsetY = -30, offsetX = 70,
        label = "Sub Recipe Calculation Depth", minValue = 1, maxValue = 5, initialValue = CraftSim.DB.OPTIONS:Get("COST_OPTIMIZATION_SUB_RECIPE_MAX_DEPTH"),
        lowText = "1", highText = "5", step = 1,
        onValueChangedCallback = function(_, value)
            CraftSim.DB.OPTIONS:Save("COST_OPTIMIZATION_SUB_RECIPE_MAX_DEPTH", value)
            CraftSim.INIT:TriggerModulesByRecipeType() -- to let it calculate the optimizations again
        end
    }

    content.useConcentrationCB = GGUI.Checkbox {
        parent = content, anchorParent = content.maxRecipeDepthSlider.frame, anchorA = "TOPLEFT", anchorB = "BOTTOMLEFT",
        labelOptions = {
            anchorA = "RIGHT", anchorB = "LEFT", text = "Enable Concentration", justifyOptions = { type = "H", align = "RIGHT" },
            offsetX = -7,
        },
        tooltip = "If enabled, " .. f.l("CraftSim") .. " will include reagent qualities even if concentration is necessary.",
        initialValue = CraftSim.DB.OPTIONS:Get("COST_OPTIMIZATION_SUB_RECIPE_INCLUDE_CONCENTRATION"),
        clickCallback = function(_, checked)
            CraftSim.DB.OPTIONS:Save("COST_OPTIMIZATION_SUB_RECIPE_INCLUDE_CONCENTRATION", checked)
            CraftSim.INIT:TriggerModulesByRecipeType()
        end
    }

    content.includeCooldownsCB = GGUI.Checkbox {
        parent = content, anchorParent = content.useConcentrationCB.frame, anchorA = "TOPLEFT", anchorB = "BOTTOMLEFT",
        labelOptions = {
            anchorA = "RIGHT", anchorB = "LEFT", text = "Include Cooldown Recipes", justifyOptions = { type = "H", align = "RIGHT" },
            offsetX = -7,
        },
        tooltip = "If enabled, " .. f.l("CraftSim") .. " will ignore cooldown requirements of recipes when calculating self crafted materials",
        initialValue = CraftSim.DB.OPTIONS:Get("COST_OPTIMIZATION_SUB_RECIPE_INCLUDE_COOLDOWNS"),
        clickCallback = function(_, checked)
            CraftSim.DB.OPTIONS:Save("COST_OPTIMIZATION_SUB_RECIPE_INCLUDE_COOLDOWNS", checked)
            CraftSim.INIT:TriggerModulesByRecipeType()
        end
    }

    ---@class CraftSim.COST_OPTIMIZATION.SubRecipeList : GGUI.FrameList
    content.subRecipeList = GGUI.FrameList {
        columnOptions = {
            {
                label = "", -- recipe names
                width = 160,
            },
            {
                label = "", -- resulting items icons
                width = 70,
            }
        },
        parent = content, anchorParent = content, anchorA = "TOPLEFT", anchorB = "TOPLEFT", offsetY = -100, sizeY = 170, offsetX = 5,
        showBorder = true,
        rowHeight = 20,
        rowConstructor = function(columns, row)
            ---@class CraftSim.COST_OPTIMIZATION.SubRecipeList.Row
            row = row
            ---@class CraftSim.COST_OPTIMIZATION.SubRecipeList.RecipeColumn : Frame
            local recipeColumn = columns[1]

            ---@type CraftSim.ItemRecipeData
            row.subRecipeData = nil

            row.recipeTitle = ""

            recipeColumn.text = GGUI.Text {
                parent = recipeColumn, anchorParent = recipeColumn, justifyOptions = { type = "H", align = "LEFT" },
                anchorA = "LEFT", anchorB = "LEFT",
            }
        end,
        selectionOptions = {
            selectedRGBA = CraftSim.CONST.FRAME_LIST_SELECTION_COLORS.SELECTED_LIGHT_GREEN,
            hoverRGBA = CraftSim.CONST.FRAME_LIST_SELECTION_COLORS.HOVER_LIGHT_GREEN,
            selectionCallback = function(row, userInput)
                CraftSim.COST_OPTIMIZATION.UI:UpdateRecipeOptionsSubRecipeOptions()
            end
        },
    }

    content.recipeTitle = GGUI.Text {
        parent = content, anchorParent = content.subRecipeList.frame, anchorA = "TOPLEFT", anchorB = "TOPRIGHT", offsetX = 40,
    }

    ---@class CraftSim.COST_OPTIMIZATION.SUB_RECIPE_CRAFTER_LIST : GGUI.FrameList
    content.subRecipeCrafterList = GGUI.FrameList {
        parent = content, anchorParent = content.subRecipeList.frame, anchorA = "TOPLEFT", anchorB = "TOPRIGHT", offsetX = 30, offsetY = -40, sizeY = 130,
        columnOptions = {
            {
                label = "Select Recipe Crafter",
                width = 200, -- crafterName
            }
        },
        showBorder = true,
        selectionOptions =
        {
            selectedRGBA = CraftSim.CONST.FRAME_LIST_SELECTION_COLORS.HOVER_LIGHT_GREEN,
            hoverRGBA = CraftSim.CONST.FRAME_LIST_SELECTION_COLORS.HOVER_LIGHT_WHITE,
            selectionCallback =
            ---@param row CraftSim.COST_OPTIMIZATION.SUB_RECIPE_CRAFTER_LIST.Row
            ---@param userInput boolean
                function(row, userInput)
                    if userInput and row.recipeID and row.crafterUID then
                        if not CraftSim.DB.RECIPE_SUB_CRAFTER:IsCrafter(row.recipeID, row.crafterUID) then
                            CraftSim.DB.RECIPE_SUB_CRAFTER:SetCrafter(row.recipeID, row.crafterUID)
                            CraftSim.INIT:TriggerModulesByRecipeType()
                        end
                    end
                end },
        rowConstructor = function(columns, row)
            ---@class CraftSim.COST_OPTIMIZATION.SUB_RECIPE_CRAFTER_LIST.Row : GGUI.FrameList.Row
            row = row
            ---@class CraftSim.COST_OPTIMIZATION.SUB_RECIPE_CRAFTER_LIST.CrafterColumn : Frame
            local crafterColumn = columns[1]

            row.recipeID = nil
            row.crafterUID = nil

            crafterColumn.text = GGUI.Text {
                parent = crafterColumn, anchorParent = crafterColumn, anchorA = "LEFT", anchorB = "LEFT", justifyOptions = { type = "H", align = "LEFT" },
                offsetX = 10,
            }
        end
    }

    -- custom sort

    content.subRecipeCrafterList.SortAndUpdate = function()
        content.subRecipeCrafterList:UpdateDisplay(
        ---@param rowA CraftSim.COST_OPTIMIZATION.SUB_RECIPE_CRAFTER_LIST.Row
        ---@param rowB CraftSim.COST_OPTIMIZATION.SUB_RECIPE_CRAFTER_LIST.Row
            function(rowA, rowB)
                local isCrafterA = CraftSim.DB.RECIPE_SUB_CRAFTER:IsCrafter(rowA.recipeID,
                    rowA.crafterUID)
                local isCrafterB = CraftSim.DB.RECIPE_SUB_CRAFTER:IsCrafter(rowB.recipeID,
                    rowB.crafterUID)

                return isCrafterA and not isCrafterB
            end)
    end
end

---@param recipeData CraftSim.RecipeData
---@param exportMode number
function CraftSim.COST_OPTIMIZATION:UpdateDisplay(recipeData, exportMode)
    local costOptimizationFrame = nil
    if exportMode == CraftSim.CONST.EXPORT_MODE.WORK_ORDER then
        costOptimizationFrame = CraftSim.COST_OPTIMIZATION.frameWO
    else
        costOptimizationFrame = CraftSim.COST_OPTIMIZATION.frame
    end


    local considerSubRecipes = recipeData.subRecipeCostsEnabled
    print("Cost Optimization - Reagent List Update", false, true)
    print("considerSubRecipes: " .. tostring(considerSubRecipes))

    costOptimizationFrame.content.reagentCostsTab.content.craftingCostsValue:SetText(CraftSim.UTIL:FormatMoney(
        recipeData
        .priceData.craftingCosts))

    local reagentList = costOptimizationFrame.content.reagentCostsTab.content.reagentList --[[@as GGUI.FrameList]]
    reagentList:Remove() --[[@as GGUI.FrameList]]

    ---@type ItemMixin[]
    local itemList = {}

    for _, reagent in ipairs(recipeData.reagentData.requiredReagents) do
        for _, reagentItem in pairs(reagent.items) do
            tinsert(itemList, reagentItem.item)
        end
    end

    ---@type CraftSim.OptionalReagent[]
    local possibleOptionals = {}
    local slots = CraftSim.GUTIL:Concat({ recipeData.reagentData.optionalReagentSlots, recipeData.reagentData
        .finishingReagentSlots })
    for _, slot in pairs(slots) do
        possibleOptionals = CraftSim.GUTIL:Concat({ possibleOptionals, slot.possibleReagents })
    end

    for _, optional in ipairs(possibleOptionals) do
        tinsert(itemList, optional.item)
    end

    for _, reagentItemMixin in pairs(itemList) do
        reagentList:Add(function(row, columns)
            local itemColumn = columns[1] --[[@as CraftSim.COST_OPTIMIZATION.UI.REAGENT_LIST.ITEM_COLUMN]]
            local ahColumn = columns[2] --[[@as CraftSim.COST_OPTIMIZATION.UI.REAGENT_LIST.AH_COLUMN]]
            local overrideColumn = columns[3] --[[@as CraftSim.COST_OPTIMIZATION.UI.REAGENT_LIST.OVERRIDE_COLUMN]]
            local craftingColumn = columns[4] --[[@as CraftSim.COST_OPTIMIZATION.UI.REAGENT_LIST.CRAFTING_COLUMN]]
            local sourceColumn = columns[5] --[[@as CraftSim.COST_OPTIMIZATION.UI.REAGENT_LIST.SOURCE_COLUMN]]

            itemColumn.itemIcon:SetItem(reagentItemMixin)
            local tooltip = ""
            local itemID = reagentItemMixin:GetItemID()
            local price, priceInfo = CraftSim.PRICE_SOURCE:GetMinBuyoutByItemID(itemID, true, false, considerSubRecipes)
            ahColumn.text:SetText(CraftSim.UTIL:FormatMoney(priceInfo.ahPrice))
            if priceInfo.noAHPriceFound then
                tooltip = tooltip .. "Auction Buyout: " .. f.grey("-")
                ahColumn.text:SetText(f.grey("-"))
            else
                ahColumn.text:SetText(CraftSim.UTIL:FormatMoney(priceInfo.ahPrice))
                tooltip = tooltip .. "Auction Buyout: " .. CraftSim.UTIL:FormatMoney(priceInfo.ahPrice)
            end
            if priceInfo.isOverride then
                overrideColumn.text:SetText(CraftSim.UTIL:FormatMoney(price))
                tooltip = tooltip .. "\n\nOverride" .. CraftSim.UTIL:FormatMoney(priceInfo.ahPrice) .. "\n"
            else
                overrideColumn.text:SetText(f.grey("-"))
            end

            if priceInfo.isExpectedCost and priceInfo.expectedCostsData then
                craftingColumn.text:SetText(CraftSim.UTIL:FormatMoney(priceInfo.expectedCostsData.expectedCostsPerItem))
                local class = CraftSim.DB.CRAFTER:GetClass(priceInfo.expectedCostsData.crafter)
                local crafterName = f.class(priceInfo.expectedCostsData.crafter, class)
                crafterName = GUTIL:IconToText(CraftSim.CONST.PROFESSION_ICONS[priceInfo.expectedCostsData.profession],
                        13, 13) ..
                    " " .. crafterName
                tooltip = tooltip ..
                    "\n\nCrafting " .. crafterName ..
                    ":" ..
                    "\n- Expected Costs Per Item: " ..
                    CraftSim.UTIL:FormatMoney(priceInfo.expectedCostsData.expectedCostsPerItem)
                if priceInfo.expectedCostsData.concentration then
                    tooltip = tooltip ..
                        "\n- " .. f.gold("Concentration Cost: ") .. priceInfo.expectedCostsData.concentrationCost
                end
            else
                craftingColumn.text:SetText(f.grey("-"))
            end

            if priceInfo.isExpectedCost then
                sourceColumn:SetCrafter(priceInfo.expectedCostsData.crafter, priceInfo.expectedCostsData.profession,
                    priceInfo.expectedCostsData.concentration)
            elseif priceInfo.isAHPrice then
                sourceColumn:SetAH()
            elseif priceInfo.isOverride then
                sourceColumn:SetOverride()
            else
                sourceColumn:SetUnknown()
            end
            row.tooltipOptions = {
                anchor = "ANCHOR_CURSOR",
                owner = row.frame,
                text = f.white(tooltip),
            }
        end)
    end

    reagentList:UpdateDisplay()
    CraftSim.COST_OPTIMIZATION.UI:UpdateRecipeOptionsSubRecipeList(recipeData)
end

---@param recipeData CraftSim.RecipeData
function CraftSim.COST_OPTIMIZATION.UI:UpdateRecipeOptionsSubRecipeList(recipeData)
    local subRecipeOptionsTab = CraftSim.COST_OPTIMIZATION.frame.content
        .subRecipeOptions --[[@as CraftSim.COST_OPTIMIZATION.SubRecipeOptionsTab]]
    local content = subRecipeOptionsTab.content --[[@as CraftSim.COST_OPTIMIZATION.SubRecipeOptionsTab.Content]]
    -- get selected itemID
    local subRecipeList = content.subRecipeList

    local subRecipeCraftingInfos = GUTIL:ToSet(recipeData:GetSubRecipeCraftingInfos(), function(element)
        return element.recipeID
    end)

    -- make sure all possible crafters are listed by only looking at q1 entries
    subRecipeCraftingInfos = GUTIL:Filter(subRecipeCraftingInfos, function(value)
        return value.qualityID == 1
    end)

    subRecipeList:Remove()
    for _, subRecipeCraftingInfo in ipairs(subRecipeCraftingInfos) do
        subRecipeList:Add(
        ---@param row CraftSim.COST_OPTIMIZATION.SubRecipeList.Row
            function(row)
                local columns = row.columns
                local recipeColumn = columns[1] --[[@as CraftSim.COST_OPTIMIZATION.SubRecipeList.RecipeColumn]]
                -- to get general data just take the first crafter to fetch from cache
                local recipeInfo = CraftSim.DB.CRAFTER:GetRecipeInfo(subRecipeCraftingInfo.crafters[1],
                    subRecipeCraftingInfo.recipeID)

                if recipeInfo then
                    row.recipeTitle = GUTIL:IconToText(recipeInfo.icon, 20, 20) .. " " .. recipeInfo.name
                    recipeColumn.text:SetText(row.recipeTitle)
                    row.subRecipeData = subRecipeCraftingInfo
                else
                    recipeColumn.text:SetText(subRecipeCraftingInfo.recipeID)
                end
            end)
    end

    subRecipeList:UpdateDisplay()
    if CraftSim.INIT.currentRecipeID ~= CraftSim.INIT.lastRecipeID then
        -- only auto select new row when switching recipes
        subRecipeList:SelectRow(1)
    end
    CraftSim.COST_OPTIMIZATION.UI:UpdateRecipeOptionsSubRecipeOptions()
end

function CraftSim.COST_OPTIMIZATION.UI:UpdateRecipeOptionsSubRecipeOptions()
    local subRecipeOptionsTab = CraftSim.COST_OPTIMIZATION.frame.content
        .subRecipeOptions --[[@as CraftSim.COST_OPTIMIZATION.SubRecipeOptionsTab]]
    local content = subRecipeOptionsTab.content --[[@as CraftSim.COST_OPTIMIZATION.SubRecipeOptionsTab.Content]]
    -- get selected itemID
    local subReagentList = content.subRecipeList
    local subRecipeCrafterList = content.subRecipeCrafterList

    local selectedRow = subReagentList.selectedRow --[[@as CraftSim.COST_OPTIMIZATION.SubRecipeList.Row]]

    if selectedRow and selectedRow.subRecipeData and #subReagentList.activeRows > 0 then
        local subRecipeData = selectedRow.subRecipeData --[[@as CraftSim.ItemRecipeData]]
        -- update display
        content.recipeTitle:Show()
        subRecipeCrafterList:Show()
        content.recipeTitle:SetText(selectedRow.recipeTitle)

        local itemRecipeData = CraftSim.DB.ITEM_RECIPE:GetAll()

        local recipeSubRecipeInfoList = GUTIL:Filter(itemRecipeData, function(irI)
            return irI.recipeID == subRecipeData.recipeID
        end)

        -- fill with cached crafters and initialize selection and so on

        subRecipeCrafterList:Remove()

        for _, crafterUID in ipairs(subRecipeData.crafters) do
            subRecipeCrafterList:Add(
            ---@param row CraftSim.COST_OPTIMIZATION.SUB_RECIPE_CRAFTER_LIST.Row
                function(row)
                    local columns = row.columns
                    local crafterColumn = columns
                        [1] --[[@as CraftSim.COST_OPTIMIZATION.SUB_RECIPE_CRAFTER_LIST.CrafterColumn]]

                    local crafterClass = CraftSim.DB.CRAFTER:GetClass(crafterUID)
                    local crafterText = f.class(select(1, strsplit("-", crafterUID)), crafterClass) -- name only
                    local fullCrafterText = f.class(crafterUID, crafterClass)
                    crafterColumn.text:SetText(fullCrafterText)

                    local crafterItemRecipeList = GUTIL:Filter(recipeSubRecipeInfoList, function(irI)
                        return tContains(irI.crafters, crafterUID)
                    end)
                    local optimizedItemIDs = {}
                    -- metadata for sorting and other things
                    local crafterRecipeOptimizedCostsDataModifiedList = GUTIL:Map(crafterItemRecipeList, function(irI)
                        tinsert(optimizedItemIDs, Item:CreateFromItemID(irI.itemID))
                        return {
                            itemID = irI.itemID,
                            optimizedCostsData = CraftSim.DB.ITEM_OPTIMIZED_COSTS:Get(irI.itemID, crafterUID)
                        }
                    end)

                    row.crafterUID = crafterUID
                    row.recipeID = subRecipeData.recipeID
                    local tooltipText = ""

                    GUTIL:ContinueOnAllItemsLoaded(optimizedItemIDs, function()
                        if #crafterRecipeOptimizedCostsDataModifiedList > 0 then
                            for _, optimizedCostsDataModified in ipairs(crafterRecipeOptimizedCostsDataModifiedList) do
                                local item = Item:CreateFromItemID(optimizedCostsDataModified.itemID)
                                local optimizedCostData = optimizedCostsDataModified.optimizedCostsData
                                if optimizedCostData then
                                    tooltipText = tooltipText ..
                                        "\n" .. GUTIL:IconToText(item:GetItemIcon(), 20, 20) .. " "
                                        ..
                                        GUTIL:GetQualityIconString(optimizedCostData.qualityID, 20, 20) ..
                                        f.white("\n- Expected Costs Per Item: " ..
                                            CraftSim.UTIL:FormatMoney(optimizedCostData.expectedCostsPerItem))
                                    if optimizedCostData.concentration then
                                        tooltipText = tooltipText ..
                                            f.white("\n- " .. f.gold("Concentration: ") ..
                                                optimizedCostData.concentrationCost) .. "\n"
                                    end
                                end
                            end
                        end

                        row.tooltipOptions = {
                            anchor = "ANCHOR_CURSOR",
                            owner = row.frame,
                            text = crafterText .. tooltipText,
                        }
                    end)
                end)
        end

        subRecipeCrafterList:SortAndUpdate()

        --first row is always crafter row after sort update
        subRecipeCrafterList:SelectRow(1)
    else
        -- hide stuff
        content.recipeTitle:Hide()
        subRecipeCrafterList:Hide()
        subRecipeCrafterList:Remove()
    end
end
