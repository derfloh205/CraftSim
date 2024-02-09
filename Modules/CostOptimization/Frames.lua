---@class CraftSim
local CraftSim = select(2, ...)

---@class CraftSim.COST_OPTIMIZATION
CraftSim.COST_OPTIMIZATION = CraftSim.COST_OPTIMIZATION

---@class CraftSim.COST_OPTIMIZATION.FRAMES
CraftSim.COST_OPTIMIZATION.FRAMES = {}

local GGUI = CraftSim.GGUI
local GUTIL = CraftSim.GUTIL

CraftSim.COST_OPTIMIZATION.frame = nil
CraftSim.COST_OPTIMIZATION.frameWO = nil

local print = CraftSim.UTIL:SetDebugPrint(CraftSim.CONST.DEBUG_IDS.COST_OPTIMIZATION)
local f = CraftSim.GUTIL:GetFormatter()

function CraftSim.COST_OPTIMIZATION.FRAMES:Init()
    local sizeX = 520
    local sizeY = 280
    local offsetX = -5
    local offsetY = -120

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
        onCloseCallback = CraftSim.FRAME:HandleModuleClose("modulesCostOptimization"),
        frameTable = CraftSim.MAIN.FRAMES,
        frameConfigTable = CraftSimGGUIConfig,
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
        onCloseCallback = CraftSim.FRAME:HandleModuleClose("modulesCostOptimization"),
        frameTable = CraftSim.MAIN.FRAMES,
        frameConfigTable = CraftSimGGUIConfig,
    })

    local function createContent(frame)
        frame.content.reagentCostsTab = GGUI.BlizzardTab {
            buttonOptions = {
                parent = frame.content,
                anchorParent = frame.content,
                label = "Reagent Costs",
            },
            top = true,
            initialTab = true,
            parent = frame.content, anchorParent = frame.content,
            sizeX = sizeX - 5,
            sizeY = sizeY - 5,
        }

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
            text = CraftSim.GUTIL:FormatMoney(123456789),
            justifyOptions = { type = "H", align = "LEFT" }
        })

        content.automaticSubRecipeOptimizationCB = GGUI.Checkbox {
            parent = content, anchorParent = content.craftingCostsTitle.frame, anchorA = "TOP", anchorB = "BOTTOM",
            offsetX = -60, offsetY = -5, label = "Sub Recipe Optimization " .. f.bb("(experimental)"),
            tooltip = "If enabled " .. f.l("CraftSim") .. " considers the " .. f.g("optimized crafting costs") .. " of your character and your alts\nif they are able to craft that item.\n\n"
                .. f.r("Might decrease performance a bit due to a lot of additional calculations"),
            initialValue = CraftSimOptions.costOptimizationAutomaticSubRecipeOptimization,
            clickCallback = function(_, checked)
                CraftSimOptions.costOptimizationAutomaticSubRecipeOptimization = checked
                CraftSim.MAIN:TriggerModulesByRecipeType()
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
                hoverRGBA = CraftSim.CONST.JUST_HOVER_FRAMELIST_HOVERRGBA,
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
                local itemColumn = columns[1]
                local ahPriceColumn = columns[2]
                local overrideColumn = columns[3]
                local craftingCostsColumn = columns[4]
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
                    text = CraftSim.GUTIL:FormatMoney(123456789)
                })
                overrideColumn.text = GGUI.Text({
                    parent = overrideColumn,
                    anchorParent = overrideColumn,
                    anchorA = "LEFT",
                    anchorB = "LEFT",
                    justifyOptions = { type = "H", align = "LEFT" },
                    text = CraftSim.GUTIL:FormatMoney(123456789)
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

                function usedPriceColumn:SetCrafter(crafterUID, profession)
                    local crafterName = strsplit("-", crafterUID)
                    local crafterClass = CraftSimRecipeDataCache.altClassCache[crafterUID]
                    if crafterClass then
                        crafterName = C_ClassColor.GetClassColor(crafterClass):WrapTextInColorCode(crafterName)
                    end
                    crafterName = GUTIL:IconToText(CraftSim.CONST.PROFESSION_ICONS[profession], 15, 15) .. crafterName
                    usedPriceColumn.text:SetText(crafterName)
                end
            end
        })

        GGUI.BlizzardTabSystem { frame.content.reagentCostsTab, frame.content.subRecipeOptions }
    end

    createContent(CraftSim.COST_OPTIMIZATION.frame)
    createContent(CraftSim.COST_OPTIMIZATION.frameWO)
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

    costOptimizationFrame.content.reagentCostsTab.content.craftingCostsValue:SetText(CraftSim.GUTIL:FormatMoney(
        recipeData
        .priceData.craftingCosts))

    local reagentList = costOptimizationFrame.content.reagentCostsTab.content.reagentList --[[@as GGUI.FrameList]]
    reagentList:Remove() --[[@as GGUI.FrameList]]

    for _, reagent in pairs(recipeData.reagentData.requiredReagents) do
        for _, reagentItem in pairs(reagent.items) do
            print("Adding: " .. tostring(reagentItem.item:GetItemLink()))
            reagentList:Add(function(row)
                local tooltip = ""
                row.columns[1].itemIcon:SetItem(reagentItem.item)
                local itemID = reagentItem.item:GetItemID()
                local price, priceInfo = CraftSim.PRICEDATA:GetMinBuyoutByItemID(itemID, true, false, considerSubRecipes)

                if priceInfo.noAHPriceFound then
                    tooltip = tooltip .. "Auction Buyout: " .. f.grey("-")
                    row.columns[2].text:SetText(f.grey("-"))
                else
                    row.columns[2].text:SetText(CraftSim.GUTIL:FormatMoney(priceInfo.ahPrice))
                    tooltip = tooltip .. "Auction Buyout: " .. CraftSim.GUTIL:FormatMoney(priceInfo.ahPrice)
                end
                if priceInfo.isOverride then
                    row.columns[3].text:SetText(CraftSim.GUTIL:FormatMoney(price))
                    tooltip = tooltip .. "\n\nOverride" .. CraftSim.GUTIL:FormatMoney(priceInfo.ahPrice) .. "\n"
                else
                    row.columns[3].text:SetText(f.grey("-"))
                end
                print("Has expectedCostsData: " .. tostring(priceInfo.expectedCostsData ~= nil))
                if priceInfo.expectedCostsData then
                    row.columns[4].text:SetText(CraftSim.GUTIL:FormatMoney(priceInfo.expectedCostsData.expectedCosts))
                    local class = CraftSimRecipeDataCache.altClassCache[priceInfo.expectedCostsData.crafter]
                    local crafterName = priceInfo.expectedCostsData.crafter
                    if class then
                        crafterName = C_ClassColor.GetClassColor(class):WrapTextInColorCode(crafterName)
                    end
                    crafterName = GUTIL:IconToText(
                            CraftSim.CONST.PROFESSION_ICONS[priceInfo.expectedCostsData.profession], 13, 13) ..
                        " " .. crafterName
                    tooltip = tooltip ..
                        "\n\nCrafting " .. crafterName ..
                        ":" ..
                        "\n- Expected Costs per Item: " ..
                        CraftSim.GUTIL:FormatMoney(priceInfo.expectedCostsData.expectedCosts) ..
                        "\n- Expected Crafts per Item: " .. GUTIL:Round(priceInfo.expectedCostsData.expectedCrafts, 1) ..
                        "\n- Expected Chance per Item: " .. priceInfo.expectedCostsData.craftingChance * 100 .. "%"
                else
                    row.columns[4].text:SetText(f.grey("-"))
                end

                if priceInfo.isExpectedCost then
                    row.columns[5]:SetCrafter(priceInfo.expectedCostsData.crafter, priceInfo.expectedCostsData
                        .profession)
                elseif priceInfo.isAHPrice then
                    row.columns[5]:SetAH()
                elseif priceInfo.isOverride then
                    row.columns[5]:SetOverride()
                else
                    row.columns[5]:SetUnknown()
                end
                row.tooltipOptions = {
                    anchor = "ANCHOR_CURSOR",
                    owner = row.frame,
                    text = f.white(tooltip),
                }
            end)
        end
    end

    local possibleOptionals = {}
    local slots = CraftSim.GUTIL:Concat({ recipeData.reagentData.optionalReagentSlots, recipeData.reagentData
        .finishingReagentSlots })
    for _, slot in pairs(slots) do
        possibleOptionals = CraftSim.GUTIL:Concat({ possibleOptionals, slot.possibleReagents })
    end

    for _, optionalReagent in pairs(possibleOptionals) do
        reagentList:Add(function(row)
            row.columns[1].itemIcon:SetItem(optionalReagent.item)
            local tooltip = ""
            local itemID = optionalReagent.item:GetItemID()
            local price, priceInfo = CraftSim.PRICEDATA:GetMinBuyoutByItemID(itemID, true, false, considerSubRecipes)
            row.columns[2].text:SetText(CraftSim.GUTIL:FormatMoney(priceInfo.ahPrice))
            if priceInfo.noAHPriceFound then
                tooltip = tooltip .. "Auction Buyout: " .. f.grey("-")
                row.columns[2].text:SetText(f.grey("-"))
            else
                row.columns[2].text:SetText(CraftSim.GUTIL:FormatMoney(priceInfo.ahPrice))
                tooltip = tooltip .. "Auction Buyout: " .. CraftSim.GUTIL:FormatMoney(priceInfo.ahPrice)
            end
            if priceInfo.isOverride then
                row.columns[3].text:SetText(CraftSim.GUTIL:FormatMoney(price))
                tooltip = tooltip .. "\n\nOverride" .. CraftSim.GUTIL:FormatMoney(priceInfo.ahPrice) .. "\n"
            else
                row.columns[3].text:SetText(f.grey("-"))
            end

            if priceInfo.isExpectedCost and priceInfo.expectedCostsData then
                row.columns[4].text:SetText(CraftSim.GUTIL:FormatMoney(priceInfo.expectedCostsData.expectedCosts))
                local class = CraftSimRecipeDataCache.altClassCache[priceInfo.expectedCostsData.crafter]
                local crafterName = priceInfo.expectedCostsData.crafter
                if class then
                    crafterName = C_ClassColor.GetClassColor(class):WrapTextInColorCode(crafterName)
                end
                crafterName = GUTIL:IconToText(CraftSim.CONST.PROFESSION_ICONS[priceInfo.expectedCostsData.profession],
                        13, 13) ..
                    " " .. crafterName
                tooltip = tooltip ..
                    "\n\nCrafting " .. crafterName ..
                    ":" ..
                    "\n- Expected Costs per Item: " ..
                    CraftSim.GUTIL:FormatMoney(priceInfo.expectedCostsData.expectedCosts) ..
                    "\n- Expected Crafts per Item: " .. GUTIL:Round(priceInfo.expectedCostsData.expectedCrafts, 1) ..
                    "\n- Expected Chance per Item: " .. priceInfo.expectedCostsData.craftingChance * 100 .. "%"
            else
                row.columns[4].text:SetText(f.grey("-"))
            end

            if priceInfo.isExpectedCost then
                row.columns[5]:SetCrafter(priceInfo.expectedCostsData.crafter, priceInfo.expectedCostsData.profession)
            elseif priceInfo.isAHPrice then
                row.columns[5]:SetAH()
            elseif priceInfo.isOverride then
                row.columns[5]:SetOverride()
            else
                row.columns[5]:SetUnknown()
            end
            row.tooltipOptions = {
                anchor = "ANCHOR_CURSOR",
                owner = row.frame,
                text = f.white(tooltip),
            }
        end)
    end

    reagentList:UpdateDisplay()
end
