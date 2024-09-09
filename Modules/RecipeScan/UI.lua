---@class CraftSim
local CraftSim = select(2, ...)

local GGUI = CraftSim.GGUI
local GUTIL = CraftSim.GUTIL
local L = CraftSim.UTIL:GetLocalizer()
local f = CraftSim.GUTIL:GetFormatter()

---@class CraftSim.RECIPE_SCAN
CraftSim.RECIPE_SCAN = CraftSim.RECIPE_SCAN

---@class CraftSim.RECIPE_SCAN.UI
CraftSim.RECIPE_SCAN.UI = {}

local print = CraftSim.DEBUG:SetDebugPrint(CraftSim.CONST.DEBUG_IDS.RECIPE_SCAN)

--- TODO: Move to debug window as toggle
local debugScannedRecipeIDs = false

function CraftSim.RECIPE_SCAN.UI:Init()
    local frameLevel = CraftSim.UTIL:NextFrameLevel()
    ---@class CraftSim.RECIPE_SCAN.FRAME : GGUI.Frame
    CraftSim.RECIPE_SCAN.frame = GGUI.Frame({
        parent = ProfessionsFrame.CraftingPage.SchematicForm,
        anchorParent = ProfessionsFrame.CraftingPage.SchematicForm,
        sizeX = 1050,
        sizeY = 400,
        frameID = CraftSim.CONST.FRAMES.RECIPE_SCAN,
        collapseable = true,
        closeable = true,
        moveable = true,
        backdropOptions = CraftSim.CONST.DEFAULT_BACKDROP_OPTIONS,
        onCloseCallback = CraftSim.CONTROL_PANEL:HandleModuleClose("MODULE_RECIPE_SCAN"),
        frameTable = CraftSim.INIT.FRAMES,
        frameConfigTable = CraftSim.DB.OPTIONS:Get("GGUI_CONFIG"),
        frameStrata = CraftSim.CONST.MODULES_FRAME_STRATA,
        raiseOnInteraction = true,
        frameLevel = frameLevel
    })

    -- manually create title for offset
    CraftSim.RECIPE_SCAN.frame.title = GGUI.Text {
        parent = CraftSim.RECIPE_SCAN.frame.frame, anchorParent = CraftSim.RECIPE_SCAN.frame.frame,
        offsetX = 100, offsetY = -10, anchorA = "TOP", anchorB = "TOP",
        text = L(CraftSim.CONST.TEXT.RECIPE_SCAN_TITLE),
    }

    ---@class CraftSim.RECIPE_SCAN.FRAME.CONTENT
    CraftSim.RECIPE_SCAN.frame.content = CraftSim.RECIPE_SCAN.frame.content

    local function createContent(frame)
        frame:Hide()

        ---@class CraftSim.RECIPE_SCAN.FRAME.CONTENT : Frame
        frame.content = frame.content

        local tabSizeX, tabSizeY = frame.content:GetSize()

        ---@class CraftSim.RECIPE_SCAN.RECIPE_SCAN_TAB : GGUI.BlizzardTab
        frame.content.recipeScanTab = GGUI.BlizzardTab {
            buttonOptions = {
                label = L(CraftSim.CONST.TEXT.RECIPE_SCAN_TAB_LABEL_SCAN),
                offsetY = -3,
            },
            parent = frame.content, anchorParent = frame.content, initialTab = true,
            sizeX = tabSizeX, sizeY = tabSizeY,
            top = true,
        }

        CraftSim.RECIPE_SCAN.UI:InitRecipeScanTab(frame.content.recipeScanTab)

        ---@class CraftSim.RECIPE_SCAN.SCAN_OPTIONS_TAB : GGUI.BlizzardTab
        frame.content.scanOptionsTab = GGUI.BlizzardTab {
            buttonOptions = {
                label = L(CraftSim.CONST.TEXT.RECIPE_SCAN_TAB_LABEL_OPTIONS),
                anchorA = "LEFT", anchorB = "RIGHT", anchorParent = frame.content.recipeScanTab.button
            },
            parent = frame.content, anchorParent = frame.content,
            sizeX = tabSizeX, sizeY = tabSizeY,
            top = true,
        }

        CraftSim.RECIPE_SCAN.UI:InitScanOptionsTab(frame.content.scanOptionsTab)

        GGUI.BlizzardTabSystem { frame.content.recipeScanTab, frame.content.scanOptionsTab }
    end

    createContent(CraftSim.RECIPE_SCAN.frame)
    GGUI:EnableHyperLinksForFrameAndChilds(CraftSim.RECIPE_SCAN.frame.content)
end

---@param selectedRow CraftSim.RECIPE_SCAN.PROFESSION_LIST.ROW
function CraftSim.RECIPE_SCAN.UI:OnProfessionRowSelected(selectedRow, userInput)
    print("select row: " .. tostring(selectedRow.crafterData.name) .. ": " .. tostring(selectedRow.profession))
    print("userInput: " .. tostring(userInput))
    -- hide all others except me
    for _, row in pairs(selectedRow.activeRows) do
        row.contentFrame:Hide()
    end

    selectedRow.contentFrame:Show()

    CraftSim.RECIPE_SCAN.UI:UpdateProfessionListRowCachedRecipesInfo(selectedRow)
end

---@param selectedRow CraftSim.RECIPE_SCAN.PROFESSION_LIST.ROW
function CraftSim.RECIPE_SCAN.UI:UpdateProfessionListRowCachedRecipesInfo(selectedRow)
    -- update cached recipes value
    local content = selectedRow.content --[[@as CraftSim.RECIPE_SCAN.PROFESSION_LIST.TAB_CONTENT]]
    local cachedRecipeIDs = CraftSim.DB.CRAFTER:GetCachedRecipeIDs(selectedRow.crafterUID, selectedRow.profession)

    if C_TradeSkillUI.IsTradeSkillReady() then
        if selectedRow.crafterProfessionUID ~= CraftSim.RECIPE_SCAN:GetPlayerCrafterProfessionUID() then
            content.cachedRecipesInfoHelpIcon:Show()
            content.cachedRecipesInfo:SetText("(Cached Recipes: " .. tostring(#cachedRecipeIDs) .. ") ")
        else
            content.cachedRecipesInfo:SetText("")
            content.cachedRecipesInfoHelpIcon:Hide()
        end
    else
        print("trade skill not ready")
        content.cachedRecipesInfo:SetText("")
        content.cachedRecipesInfoHelpIcon:Hide()
    end
end

---@param recipeScanTab CraftSim.RECIPE_SCAN.RECIPE_SCAN_TAB
function CraftSim.RECIPE_SCAN.UI:InitRecipeScanTab(recipeScanTab)
    ---@class CraftSim.RECIPE_SCAN.RECIPE_SCAN_TAB
    recipeScanTab = recipeScanTab
    ---@class CraftSim.RECIPE_SCAN.RECIPE_SCAN_TAB.CONTENT : Frame
    local content = recipeScanTab.content

    content.professionList = GGUI.FrameList {
        parent = content, anchorParent = content, anchorA = "TOPLEFT", anchorB = "TOPLEFT", offsetY = -40, offsetX = 5,
        sizeY = 350,
        showBorder = true, selectionOptions = {
        selectionCallback =
        ---@param row CraftSim.RECIPE_SCAN.PROFESSION_LIST.ROW
            function(row, userInput)
                print("in selection callback!")
                CraftSim.RECIPE_SCAN.UI:OnProfessionRowSelected(row, userInput)
                CraftSim.CRAFTQ.UI:UpdateRecipeScanRestockButton(row.currentResults)
            end
    },
        columnOptions = {
            {
                label = "", -- checkbox
                width = 40,
            },
            {
                label = "", -- crafter name + prof icon
                width = 150,
            },
        },
        rowConstructor = function(columns)
            ---@class CraftSim.RECIPE_SCAN.PROFESSION_LIST.CHECKBOX_COLUMN : Frame
            local checkboxColumn = columns[1]
            ---@class CraftSim.RECIPE_SCAN.PROFESSION_LIST.CRAFTER_COLUMN : Frame
            local crafterColumn = columns[2]

            checkboxColumn.checkbox = GGUI.Checkbox {
                parent = checkboxColumn, anchorParent = checkboxColumn,
            }

            crafterColumn.text = GGUI.Text {
                parent = crafterColumn, anchorParent = crafterColumn, anchorA = "LEFT", anchorB = "LEFT",
                justifyOptions = { type = "H", align = "LEFT" }
            }
        end
    }

    content.scanProfessionsButton = GGUI.Button {
        parent = content, anchorParent = content.professionList.frame, anchorA = "BOTTOMLEFT", anchorB = "TOPLEFT",
        adjustWidth = true, sizeX = 15, offsetY = 5, initialStatusID = "Ready",
        label = L(CraftSim.CONST.TEXT.RECIPE_SCAN_SCAN_ALL_BUTTON_READY), clickCallback = function()
        CraftSim.RECIPE_SCAN:ScanProfessions()
    end,
    }

    content.cancelScanProfessionsButton = GGUI.Button {
        parent = content, anchorParent = content.scanProfessionsButton.frame, anchorA = "LEFT", anchorB = "RIGHT",
        label = L(CraftSim.CONST.TEXT.RECIPE_SCAN_SCAN_CANCEL), offsetX = 5, adjustWidth = true, sizeX = 15,
        clickCallback = function()
            CraftSim.RECIPE_SCAN:CancelProfessionScan()
        end
    }
    content.cancelScanProfessionsButton:Hide()

    content.scanProfessionsButton:SetStatusList {
        {
            statusID = "Ready",
            adjustWidth = true,
            sizeX = 15,
            label = L(CraftSim.CONST.TEXT.RECIPE_SCAN_SCAN_ALL_BUTTON_READY),
            enabled = true,
        },
        {
            statusID = "Scanning",
            adjustWidth = true,
            sizeX = 15,
            label = L(CraftSim.CONST.TEXT.RECIPE_SCAN_SCAN_ALL_BUTTON_SCANNING),
            enabled = false,
        },
    }
end

function CraftSim.RECIPE_SCAN.UI:UpdateProfessionList()
    -- for each profession that is cached, create a tabFrame and connect it to the row of the profession
    -- do this only if the profession is not yet added to the list
    local content = CraftSim.RECIPE_SCAN.frame.content.recipeScanTab
        .content --[[@as CraftSim.RECIPE_SCAN.RECIPE_SCAN_TAB.CONTENT]]
    local activeRows = content.professionList.activeRows
    local crafterDBDataMap = CraftSim.DB.CRAFTER:GetAll()
    for crafterUID, crafterDBData in pairs(crafterDBDataMap) do
        local cachedProfessionRecipeIDs = crafterDBData.cachedRecipeIDs or {}
        for profession, _ in pairs(cachedProfessionRecipeIDs) do
            local crafterProfessionUID = CraftSim.RECIPE_SCAN:GetCrafterProfessionUID(crafterUID, profession)
            local alreadyListed = GUTIL:Some(activeRows, function(activeRow)
                return activeRow.crafterProfessionUID == crafterProfessionUID
            end)
            local isGatheringProfession = CraftSim.CONST.GATHERING_PROFESSIONS[profession]
            if not alreadyListed and not isGatheringProfession then
                CraftSim.RECIPE_SCAN.UI:AddProfessionTabRow(crafterUID, profession)
            end
        end
    end


    CraftSim.RECIPE_SCAN.UI:UpdateProfessionListDisplay()
end

function CraftSim.RECIPE_SCAN.UI:UpdateProfessionListDisplay()
    print("update prof list display")
    local content = CraftSim.RECIPE_SCAN.frame.content.recipeScanTab
        .content --[[@as CraftSim.RECIPE_SCAN.RECIPE_SCAN_TAB.CONTENT]]
    local sortCallCounter = 1
    content.professionList:UpdateDisplay(
    ---@param rowA CraftSim.RECIPE_SCAN.PROFESSION_LIST.ROW
    ---@param rowB CraftSim.RECIPE_SCAN.PROFESSION_LIST.ROW
        function(rowA, rowB)
            local playerCrafterUID = CraftSim.UTIL:GetPlayerCrafterUID()
            local playerCrafterProfessionUID = CraftSim.RECIPE_SCAN:GetPlayerCrafterProfessionUID()
            local crafterUIDA = CraftSim.UTIL:GetCrafterUIDFromCrafterData(rowA.crafterData)
            local crafterUIDB = CraftSim.UTIL:GetCrafterUIDFromCrafterData(rowB.crafterData)
            local playerCrafterProfessionUIDA = CraftSim.RECIPE_SCAN:GetCrafterProfessionUID(crafterUIDA, rowA
                .profession)
            local playerCrafterProfessionUIDB = CraftSim.RECIPE_SCAN:GetCrafterProfessionUID(crafterUIDB, rowB
                .profession)

            -- current character and current profession always on top
            if playerCrafterProfessionUIDA == playerCrafterProfessionUID and playerCrafterProfessionUIDB ~= playerCrafterProfessionUID then
                return true
            elseif playerCrafterProfessionUIDA ~= playerCrafterProfessionUID and playerCrafterProfessionUIDB == playerCrafterProfessionUID then
                return false
            end

            -- next prefer current character
            if crafterUIDA == playerCrafterUID and crafterUIDB ~= playerCrafterUID then
                return true
            elseif crafterUIDA ~= playerCrafterUID and crafterUIDB == playerCrafterUID then
                return false
            end

            -- next sort by alphabet
            if crafterUIDA > crafterUIDB then
                return true
            elseif crafterUIDA < crafterUIDB then
                return false
            end

            return false
        end)

    --- since this is only called when first opening or in general opening a profession just select the current profession always
    -- only select if there is nothing selected yet
    local selectedRow = content.professionList.selectedRow --[[@as CraftSim.RECIPE_SCAN.PROFESSION_LIST.ROW]]
    if not selectedRow then
        content.professionList:SelectRow(1)
    else
        CraftSim.RECIPE_SCAN.UI:UpdateProfessionListRowCachedRecipesInfo(selectedRow) --[[@as CraftSim.RECIPE_SCAN.PROFESSION_LIST.ROW]]
    end
end

---@param row CraftSim.RECIPE_SCAN.PROFESSION_LIST.ROW
---@param content Frame
---@return CraftSim.RECIPE_SCAN.PROFESSION_LIST.TAB_CONTENT
function CraftSim.RECIPE_SCAN.UI:CreateProfessionTabContent(row, content)
    ---@class CraftSim.RECIPE_SCAN.PROFESSION_LIST.TAB_CONTENT : Frame
    content = content

    content.recipeTitle = GGUI.Text {
        parent = content, anchorParent = content,
        anchorA = "TOP",
        anchorB = "TOP",
        offsetY = 8,
        sizeX = 15,
        sizeY = 25,
        scale = 1.2,
    }

    content.cachedRecipesInfo = GGUI.Text {
        parent = content, anchorParent = content.recipeTitle.frame, anchorA = "LEFT",
        anchorB = "RIGHT", justifyOptions = { type = "H", align = "LEFT" }, offsetX = 10, scale = 1,
    }

    content.cachedRecipesInfoHelpIcon = GGUI.HelpIcon {
        parent = content, anchorParent = content.cachedRecipesInfo.frame, anchorA = "LEFT", anchorB = "RIGHT",
        scale = 1, offsetX = 2, text = L(CraftSim.CONST.TEXT.RECIPE_SCAN_CACHED_RECIPES_TOOLTIP), offsetY = -1.5,
    }

    content.cachedRecipesInfoHelpIcon:Hide()

    content.scanButton = GGUI.Button({
        parent = content,
        anchorParent = content.recipeTitle.frame,
        label = L(CraftSim.CONST.TEXT.RECIPE_SCAN_SCAN_RECIPIES),
        anchorA = "TOP",
        anchorB = "BOTTOM",
        offsetY = -5,
        sizeX = 15,
        sizeY = 25,
        adjustWidth = true,
        clickCallback = function()
            CraftSim.RECIPE_SCAN:StartScan(row)
        end
    })

    content.cancelScanButton = GGUI.Button({
        parent = content,
        anchorParent = content.scanButton.frame,
        label = L(CraftSim.CONST.TEXT.RECIPE_SCAN_SCAN_CANCEL),
        anchorA = "LEFT",
        anchorB = "RIGHT",
        sizeX = 15,
        sizeY = 25,
        adjustWidth = true,
        clickCallback = function()
            CraftSim.RECIPE_SCAN:EndScan(row)
        end
    })

    content.concentrationToggleCB = GGUI.Checkbox {
        parent = content, anchorParent = content.cancelScanButton.frame, anchorA = "LEFT", anchorB = "RIGHT",
        labelOptions = { text = GUTIL:IconToText(CraftSim.CONST.CONCENTRATION_ICON, 20, 20) .. " Concentration" },
        tooltip = "Toggle Concentration",
        initialValue = CraftSim.DB.OPTIONS:Get("RECIPESCAN_ENABLE_CONCENTRATION"),
        clickCallback = function(_, checked)
            CraftSim.DB.OPTIONS:Save("RECIPESCAN_ENABLE_CONCENTRATION", checked)
        end
    }

    content.resultAmount = GGUI.Text {
        parent = content, anchorParent = content.scanButton.frame, anchorA = "RIGHT", anchorB = "LEFT",
        offsetX = -15, justifyOptions = { type = "H", align = "RIGHT" }, text = "",
    }

    content.cancelScanButton:Hide()

    local columnOptions = {
        {
            --label = L(CraftSim.CONST.TEXT.RECIPE_SCAN_LEARNED_HEADER),
            width = 15,
            justifyOptions = { type = "H", align = "CENTER" }
        },
        {
            label = L(CraftSim.CONST.TEXT.RECIPE_SCAN_RECIPE_HEADER),
            width = 160,
        },
        {
            label = L(CraftSim.CONST.TEXT.RECIPE_SCAN_RESULT_HEADER),
            width = 90,
            justifyOptions = { type = "H", align = "CENTER" }
        },
        {
            label = L(CraftSim.CONST.TEXT.RECIPE_SCAN_CONCENTRATION_VALUE_HEADER),
            width = 100,
        },
        {
            label = L(CraftSim.CONST.TEXT.RECIPE_SCAN_CONCENTRATION_COST_HEADER),
            width = 60,
        },
        {
            label = L(CraftSim.CONST.TEXT.RECIPE_SCAN_AVERAGE_PROFIT_HEADER),
            width = 140,
        },
        {
            label = L(CraftSim.CONST.TEXT.RECIPE_SCAN_TOP_GEAR_HEADER),
            width = 120,
            justifyOptions = { type = "H", align = "CENTER" }
        },
        {
            label = L(CraftSim.CONST.TEXT.RECIPE_SCAN_INV_AH_HEADER),
            width = 80,
            justifyOptions = { type = "H", align = "CENTER" }
        }
    }

    ---@type GGUI.FrameList
    content.resultList = GGUI.FrameList({
        parent = content,
        anchorParent = content.scanButton.frame,
        anchorA = "TOP",
        anchorB = "BOTTOM",
        showBorder = true,
        sizeY = 280,
        offsetX = 15,
        offsetY = -25,
        columnOptions = columnOptions,
        selectionOptions = {
            hoverRGBA = { 1, 1, 1, 0.1 },
            noSelectionColor = true,
            selectionCallback = function(row)
                local recipeData = row.recipeData --[[@as CraftSim.RecipeData]]
                if recipeData then
                    if IsShiftKeyDown() then
                        -- queue into CraftQueue
                        if CraftSim.DB.OPTIONS:Get("RECIPESCAN_ENABLE_CONCENTRATION") then
                            recipeData.concentrating = true
                        end
                        CraftSim.CRAFTQ:AddRecipe({ recipeData = recipeData })
                    else
                        C_TradeSkillUI.OpenRecipe(recipeData.recipeID)
                    end
                end
            end
        },
        rowConstructor = function(columns)
            local learnedColumn = columns[1]
            local recipeColumn = columns[2]
            local expectedResultColumn = columns[3]
            local concentrationValueColumn = columns[4]
            local concentrationCostColumn = columns[5]
            local averageProfitColumn = columns[6]
            local topGearColumn = columns[7]
            local countColumn = columns[8]

            recipeColumn.text = GGUI.Text({
                parent = recipeColumn,
                anchorParent = recipeColumn,
                anchorA = "LEFT",
                anchorB = "LEFT",
                justifyOptions = { type = "H", align = "LEFT" },
                scale = 0.9,
                fixedWidth = recipeColumn:GetWidth(),
                wrap = true,
            })

            local learnedIconSize = 0.08
            local learnedIcon = CraftSim.MEDIA:GetAsTextIcon(CraftSim.MEDIA.IMAGES.TRUE, learnedIconSize)
            local notLearnedIcon = CraftSim.MEDIA:GetAsTextIcon(CraftSim.MEDIA.IMAGES.FALSE, learnedIconSize)

            learnedColumn.text = GGUI.Text({
                parent = learnedColumn,
                anchorParent = learnedColumn,
                justifyOptions = { type = "H", align = "CENTER" },
                offsetY = -1,
                tooltipOptions = {
                    owner = learnedColumn,
                    anchor = "ANCHOR_CURSOR_RIGHT",
                    text = notLearnedIcon .. " .. not learned\n" .. learnedIcon .. " .. learned"
                },
            })

            function learnedColumn:SetLearned(learned)
                if learned then
                    learnedColumn.text:SetText(learnedIcon)
                else
                    learnedColumn.text:SetText(notLearnedIcon)
                end
            end

            local iconSize = 23

            ---@type GGUI.Icon
            expectedResultColumn.itemIcon = GGUI.Icon({
                parent = expectedResultColumn,
                anchorParent = expectedResultColumn,
                sizeX = iconSize,
                sizeY =
                    iconSize,
                qualityIconScale = 1.4,
            })

            ---@type GGUI.Text
            concentrationValueColumn.text = GGUI.Text({
                parent = concentrationValueColumn,
                anchorParent = concentrationValueColumn,
                anchorA = "LEFT",
                anchorB = "LEFT",
                justifyOptions = { type = "H", align = "LEFT" },
            })

            ---@type GGUI.Text
            concentrationCostColumn.text = GGUI.Text({
                parent = concentrationCostColumn,
                anchorParent = concentrationCostColumn,
                anchorA = "LEFT",
                anchorB = "LEFT",
                scale = 0.95,
            })

            averageProfitColumn.text = GGUI.Text({
                parent = averageProfitColumn,
                anchorParent = averageProfitColumn,
                anchorA = "LEFT",
                anchorB = "LEFT",
                scale = 0.95,
            })

            topGearColumn.gear2Icon = GGUI.Icon({
                parent = topGearColumn, anchorParent = topGearColumn, sizeX = iconSize, sizeY = iconSize, qualityIconScale = 1.4,
            })

            topGearColumn.gear1Icon = GGUI.Icon({
                parent = topGearColumn,
                anchorParent = topGearColumn.gear2Icon.frame,
                anchorA = "RIGHT",
                anchorB = "LEFT",
                sizeX =
                    iconSize,
                sizeY = iconSize,
                qualityIconScale = 1.4,
                offsetX = -10,
            })
            topGearColumn.toolIcon = GGUI.Icon({
                parent = topGearColumn,
                anchorParent = topGearColumn.gear2Icon.frame,
                anchorA = "LEFT",
                anchorB = "RIGHT",
                sizeX =
                    iconSize,
                sizeY = iconSize,
                qualityIconScale = 1.4,
                offsetX = 10
            })
            topGearColumn.equippedText = GGUI.Text({
                parent = topGearColumn, anchorParent = topGearColumn
            })

            function topGearColumn.equippedText:SetEquipped()
                topGearColumn.equippedText:SetText(GUTIL:ColorizeText(L(CraftSim.CONST.TEXT.RECIPE_SCAN_EQUIPPED),
                    GUTIL.COLORS.GREEN))
            end

            function topGearColumn.equippedText:SetIrrelevant()
                topGearColumn.equippedText:SetText(GUTIL:ColorizeText("-", GUTIL.COLORS.GREY))
            end

            countColumn.text = GGUI.Text({
                parent = countColumn, anchorParent = countColumn
            })
        end
    })

    GGUI.HelpIcon {
        parent = content, anchorParent = content.resultList.frame, anchorA = "BOTTOMLEFT", anchorB = "TOPLEFT", offsetY = -4, offsetX = 65,
        text = "Press " ..
            CreateAtlasMarkup("NPE_LeftClick", 20, 20, 2) .. " + shift to queue selected recipe into the " .. f.bb("Craft Queue"),
        scale = 1.1,
    }

    return content
end

---@param crafterUID string
---@param profession Enum.Profession
function CraftSim.RECIPE_SCAN.UI:AddProfessionTabRow(crafterUID, profession)
    local content = CraftSim.RECIPE_SCAN.frame.content.recipeScanTab
        .content --[[@as CraftSim.RECIPE_SCAN.RECIPE_SCAN_TAB.CONTENT]]
    content.professionList:Add(function(row)
        ---@class CraftSim.RECIPE_SCAN.PROFESSION_LIST.ROW : GGUI.FrameList.Row
        row = row

        ---@type Enum.Profession
        row.profession = profession
        ---@type string
        row.crafterUID = crafterUID
        ---@type string
        row.crafterProfessionUID = CraftSim.RECIPE_SCAN:GetCrafterProfessionUID(crafterUID, profession)

        ---@type CraftSim.RECIPE_SCAN.PROFESSION_LIST.ROW[]
        row.activeRows = content.professionList.activeRows
        local columns = row.columns
        local checkboxColumn = columns[1] --[[@as CraftSim.RECIPE_SCAN.PROFESSION_LIST.CHECKBOX_COLUMN]]
        ---@type CraftSim.RECIPE_SCAN.PROFESSION_LIST.CRAFTER_COLUMN : Frame
        local crafterColumn = columns[2] --[[@as CraftSim.RECIPE_SCAN.PROFESSION_LIST.CRAFTER_COLUMN]]

        local crafterClass = CraftSim.DB.CRAFTER:GetClass(crafterUID)
        local crafterName, crafterRealm = strsplit("-", crafterUID)
        local coloredCrafterName = f.class(crafterName, crafterClass)
        local professionIconSize = 20
        local professionIcon = GUTIL:IconToText(CraftSim.CONST.PROFESSION_ICONS[row.profession], professionIconSize,
            professionIconSize)
        ---@type GGUI.TooltipOptions
        row.tooltipOptions = {
            text = crafterUID .. ": " .. L(CraftSim.CONST.PROFESSION_LOCALIZATION_IDS[profession]),
            anchor = "ANCHOR_TOP",
            owner = row.frame
        }

        -- todo: add profession icon prefix
        crafterColumn.text:SetText(professionIcon .. " " .. coloredCrafterName)
        ---@type Enum.Profession
        ---@type CraftSim.CrafterData
        row.crafterData = {
            name = crafterName,
            realm = crafterRealm,
            class = crafterClass,
        }

        ---@type CraftSim.RecipeData[]
        row.currentResults = {}

        local crafterProfessionUID = CraftSim.RECIPE_SCAN:GetCrafterProfessionUID(crafterUID, profession)

        local isChecked = CraftSim.DB.OPTIONS:Get("RECIPESCAN_INCLUDED_PROFESSIONS")[crafterProfessionUID]

        checkboxColumn.checkbox:SetChecked(isChecked)

        checkboxColumn.checkbox.clickCallback = function(_, checked)
            local includedProfessions = CraftSim.DB.OPTIONS:Get("RECIPESCAN_INCLUDED_PROFESSIONS")
            includedProfessions[crafterProfessionUID] = checked
        end

        row.contentFrame = GGUI.Frame {
            parent = content, anchorParent = content.professionList.frame, sizeX = 850, sizeY = content.professionList:GetHeight(),
            anchorA = "TOPLEFT", anchorB = "TOPRIGHT", offsetX = -20,
        }
        row.contentFrame.frame:SetFrameStrata(content:GetFrameStrata())
        row.contentFrame.frame:SetFrameLevel(content:GetFrameLevel() + 10)
        row.contentFrame:Hide()

        row.content = CraftSim.RECIPE_SCAN.UI:CreateProfessionTabContent(row, row.contentFrame.content)

        row.content.recipeTitle:SetText(professionIcon .. " " .. coloredCrafterName)
    end)
end

---@param scanOptionsTab CraftSim.RECIPE_SCAN.SCAN_OPTIONS_TAB
function CraftSim.RECIPE_SCAN.UI:InitScanOptionsTab(scanOptionsTab)
    ---@class CraftSim.RECIPE_SCAN.SCAN_OPTIONS_TAB
    scanOptionsTab = scanOptionsTab
    ---@class CraftSim.RECIPE_SCAN.SCAN_OPTIONS_TAB.CONTENT : Frame
    local content = scanOptionsTab.content

    local initialScanModeValue = CraftSim.DB.OPTIONS:Get("RECIPESCAN_SCAN_MODE")
    local initialScanModeLabel = L(CraftSim.RECIPE_SCAN.SCAN_MODES_TRANSLATION_MAP[initialScanModeValue])

    content.scanMode = GGUI.Dropdown({
        parent = content,
        anchorParent = content,
        anchorA = "TOP",
        anchorB = "TOP",
        offsetY = -50,
        width = 170,
        initialValue = initialScanModeValue,
        initialLabel = initialScanModeLabel,
        label = L(CraftSim.CONST.TEXT.RECIPE_SCAN_MODE),
        initialData = GUTIL:Map(CraftSim.RECIPE_SCAN.SCAN_MODES,
            function(scanMode)
                local localizationID = CraftSim.RECIPE_SCAN.SCAN_MODES_TRANSLATION_MAP[scanMode]
                return {
                    label = L(localizationID),
                    value = scanMode
                }
            end),
        clickCallback = function(_, _, value)
            CraftSim.DB.OPTIONS:Save("RECIPESCAN_SCAN_MODE", value)
        end
    })

    local initialSortModeValue = CraftSim.DB.OPTIONS:Get("RECIPESCAN_SORT_MODE")
    local initialSortModeLabel = L(CraftSim.RECIPE_SCAN.SORT_MODES_TRANSLATION_MAP[initialSortModeValue])

    content.sortMode = GGUI.Dropdown({
        parent = content,
        anchorParent = content.scanMode.frame,
        anchorA = "TOP",
        anchorB = "BOTTOM",
        width = 170,
        offsetY = -10,
        initialValue = initialSortModeValue,
        initialLabel = initialSortModeLabel,
        label = L(CraftSim.CONST.TEXT.RECIPE_SCAN_SORT_MODE),
        initialData = GUTIL:Sort(GUTIL:Map(CraftSim.RECIPE_SCAN.SORT_MODES,
            function(sortMode)
                local localizationID = CraftSim.RECIPE_SCAN.SORT_MODES_TRANSLATION_MAP[sortMode]
                return {
                    label = L(localizationID),
                    value = sortMode
                }
            end), function(a, b) -- make the resulting dropdown data table sorted by label alphabetically
            return a.label > b.label
        end),
        clickCallback = function(_, _, value)
            CraftSim.DB.OPTIONS:Save("RECIPESCAN_SORT_MODE", value)
        end
    })

    local checkBoxSpacingY = 0

    content.includeSoulboundCB = GGUI.Checkbox {
        parent = content, anchorParent = content.sortMode.frame, anchorA = "TOP", anchorB = "BOTTOM", offsetY = checkBoxSpacingY, offsetX = -80,
        label = L(CraftSim.CONST.TEXT.RECIPE_SCAN_INCLUDE_SOULBOUND),
        tooltip = L(CraftSim.CONST.TEXT.RECIPE_SCAN_INCLUDE_SOULBOUND_TOOLTIP),
        initialValue = CraftSim.DB.OPTIONS:Get("RECIPESCAN_INCLUDE_SOULBOUND"),
        clickCallback = function(_, checked)
            CraftSim.DB.OPTIONS:Save("RECIPESCAN_INCLUDE_SOULBOUND", checked)
        end
    }

    content.includeNotLearnedCB = GGUI.Checkbox {
        parent = content, anchorParent = content.includeSoulboundCB.frame, anchorA = "TOP", anchorB = "BOTTOM", offsetY = checkBoxSpacingY,
        label = L(CraftSim.CONST.TEXT.RECIPE_SCAN_INCLUDE_NOT_LEARNED),
        tooltip = L(CraftSim.CONST.TEXT.RECIPE_SCAN_INCLUDE_NOT_LEARNED_TOOLTIP),
        initialValue = CraftSim.DB.OPTIONS:Get("RECIPESCAN_INCLUDE_NOT_LEARNED"),
        clickCallback = function(_, checked)
            CraftSim.DB.OPTIONS:Save("RECIPESCAN_INCLUDE_NOT_LEARNED", checked)
        end
    }

    content.includeGearCB = GGUI.Checkbox {
        parent = content, anchorParent = content.includeNotLearnedCB.frame, anchorA = "TOP", anchorB = "BOTTOM", offsetY = checkBoxSpacingY,
        label = L(CraftSim.CONST.TEXT.RECIPE_SCAN_INCLUDE_GEAR),
        tooltip = L(CraftSim.CONST.TEXT.RECIPE_SCAN_INCLUDE_GEAR_TOOLTIP),
        initialValue = CraftSim.DB.OPTIONS:Get("RECIPESCAN_INCLUDE_GEAR"),
        clickCallback = function(_, checked)
            CraftSim.DB.OPTIONS:Save("RECIPESCAN_INCLUDE_GEAR", checked)
        end
    }

    content.onlyFavorites = GGUI.Checkbox {
        parent = content, anchorParent = content.includeGearCB.frame, anchorA = "TOP", anchorB = "BOTTOM", offsetY = checkBoxSpacingY,
        label = L(CraftSim.CONST.TEXT.RECIPE_SCAN_ONLY_FAVORITES_CHECKBOX),
        tooltip = L(CraftSim.CONST.TEXT.RECIPE_SCAN_ONLY_FAVORITES_CHECKBOX_TOOLTIP),
        initialValue = CraftSim.DB.OPTIONS:Get("RECIPESCAN_ONLY_FAVORITES"),
        clickCallback = function(_, checked)
            CraftSim.DB.OPTIONS:Save("RECIPESCAN_ONLY_FAVORITES", checked)
        end
    }

    content.optimizeProfessionToolsCB = GGUI.Checkbox {
        parent = content, anchorParent = content.onlyFavorites.frame, anchorA = "TOP", anchorB = "BOTTOM", offsetY = checkBoxSpacingY - 10,
        label = L(CraftSim.CONST.TEXT.RECIPE_SCAN_OPTIMIZE_TOOLS),
        tooltip = L(CraftSim.CONST.TEXT.RECIPE_SCAN_OPTIMIZE_TOOLS_TOOLTIP) ..
            GUTIL:ColorizeText(L(CraftSim.CONST.TEXT.RECIPE_SCAN_OPTIMIZE_TOOLS_WARNING), GUTIL.COLORS.RED),
        initialValue = CraftSim.DB.OPTIONS:Get("RECIPESCAN_OPTIMIZE_PROFESSION_TOOLS"),
        clickCallback = function(_, checked)
            CraftSim.DB.OPTIONS:Save("RECIPESCAN_OPTIMIZE_PROFESSION_TOOLS", checked)
        end
    }

    -- content.useInsightCB = GGUI.Checkbox {
    --     parent = content, anchorParent = content.optimizeProfessionToolsCB.frame, anchorA = "TOP", anchorB = "BOTTOM", offsetY = checkBoxSpacingY,
    --     label = L(CraftSim.CONST.TEXT.RECIPE_SCAN_USE_INSIGHT_CHECKBOX),
    --     tooltip = L(CraftSim.CONST.TEXT.RECIPE_SCAN_USE_INSIGHT_CHECKBOX_TOOLTIP),
    --     initialValue = CraftSim.DB.OPTIONS:Get("RECIPESCAN_USE_INSIGHT"),
    --     clickCallback = function(_, checked)
    --         CraftSim.DB.OPTIONS:Save("RECIPESCAN_USE_INSIGHT", checked)
    --     end
    -- }

    content.optimizeSubRecipes = GGUI.Checkbox {
        parent = content, anchorParent = content.optimizeProfessionToolsCB.frame, anchorA = "TOP", anchorB = "BOTTOM", offsetY = checkBoxSpacingY,
        label = "Optimize Sub Recipes " .. f.bb("(experimental)"),
        tooltip = "If enabled, " .. f.l("CraftSim") .. " also optimizes crafts of cached reagent recipes of scanned recipes and uses their\n" ..
            f.bb("expected costs") .. " to calculate the crafting costs for the final product.\n\n" .. f.r("Warning: This might reduce scanning performance"),
        initialValue = CraftSim.DB.OPTIONS:Get("RECIPESCAN_OPTIMIZE_SUBRECIPES"),
        clickCallback = function(_, checked)
            CraftSim.DB.OPTIONS:Save("RECIPESCAN_OPTIMIZE_SUBRECIPES", checked)
        end
    }

    content.expansionSelector = GGUI.CheckboxSelector {
        savedVariablesTable = CraftSim.DB.OPTIONS:Get("RECIPESCAN_FILTERED_EXPANSIONS"),
        initialItems = GUTIL:Sort(GUTIL:Map(CraftSim.CONST.EXPANSION_IDS,
            function(expansionID)
                ---@type GGUI.CheckboxSelector.CheckboxItem
                local item = {
                    name = L(CraftSim.CONST.EXPANSION_LOCALIZATION_IDS[expansionID]),
                    savedVariableProperty = expansionID,
                    selectionID = expansionID,
                }
                return item
            end), function(a, b)
            return a.selectionID > b.selectionID
        end),
        selectionFrameOptions = {
            backdropOptions = CraftSim.CONST.DEFAULT_BACKDROP_OPTIONS,
            sizeX = 240, sizeY = 260, anchorA = "LEFT", anchorB = "RIGHT",

        },
        buttonOptions = {
            parent = content, anchorParent = content.optimizeSubRecipes.frame,
            anchorA = "TOPLEFT", anchorB = "BOTTOMLEFT", offsetY = checkBoxSpacingY,
            label = L(CraftSim.CONST.TEXT.RECIPE_SCAN_EXPANSION_FILTER_BUTTON), offsetX = 25,
            adjustWidth = true, sizeX = 20,
        },
    }
end

---@param row CraftSim.RECIPE_SCAN.PROFESSION_LIST.ROW
function CraftSim.RECIPE_SCAN.UI:ResetResults(row)
    local resultList = row.content.resultList
    resultList:Remove()
    row.content.resultAmount:SetText("")
end

---@param row CraftSim.RECIPE_SCAN.PROFESSION_LIST.ROW
---@param recipeData CraftSim.RecipeData
function CraftSim.RECIPE_SCAN.UI:AddRecipe(row, recipeData)
    local resultList = row.content.resultList
    local showProfit = CraftSim.DB.OPTIONS:Get("SHOW_PROFIT_PERCENTAGE")
    if debugScannedRecipeIDs then
        recipeData:DebugInspect("RecipeScan: " .. recipeData.recipeName)
    end
    resultList:Add(
        function(row)
            local columns = row.columns

            local learnedColumn = columns[1]
            local recipeColumn = columns[2]
            local expectedResultColumn = columns[3]
            local concentrationValueColumn = columns[4]
            local concentrationCostColumn = columns[5]
            local averageProfitColumn = columns[6]
            local topGearColumn = columns[7]
            local countColumn = columns[8]

            row.recipeData = recipeData

            local enableConcentration = CraftSim.DB.OPTIONS:Get("RECIPESCAN_ENABLE_CONCENTRATION")

            local recipeRarity = recipeData.resultData.expectedItem:GetItemQualityColor()

            local cooldownInfoText = ""
            local cooldownData = recipeData:GetCooldownDataForRecipeCrafter()
            if cooldownData and cooldownData.isCooldownRecipe then
                local timeIcon = CreateAtlasMarkup(CraftSim.CONST.CRAFT_QUEUE_STATUS_TEXTURES.COOLDOWN.texture, 13, 13)
                local currentCharges = cooldownData:GetCurrentCharges()
                cooldownInfoText = " " .. timeIcon ..
                    "(" .. currentCharges .. "/" .. cooldownData.maxCharges .. ")"
            end

            recipeColumn.text:SetText(recipeRarity.hex .. recipeData.recipeName .. "|r" .. cooldownInfoText)

            learnedColumn:SetLearned(recipeData.learned)

            if enableConcentration then
                expectedResultColumn.itemIcon:SetItem(recipeData.resultData.expectedItemConcentration)
            else
                expectedResultColumn.itemIcon:SetItem(recipeData.resultData.expectedItem)
            end


            local relativeTo = nil
            if showProfit then
                relativeTo = recipeData.priceData.craftingCosts
            end

            local averageProfit = recipeData:GetAverageProfit()
            row.concentrationWeight, row.concentrationProfit = CraftSim.AVERAGEPROFIT:GetConcentrationWeight(recipeData,
                averageProfit)

            if enableConcentration and row.concentrationProfit then
                averageProfit = row.concentrationProfit
            end

            row.averageProfit = averageProfit
            row.relativeProfit = GUTIL:GetPercentRelativeTo(averageProfit, recipeData.priceData.craftingCosts)
            recipeData.resultData:Update() -- switch back
            row.concentrationCost = recipeData.concentrationCost
            concentrationCostColumn.text:SetText(row.concentrationCost)
            concentrationValueColumn.text:SetText(CraftSim.UTIL:FormatMoney(row.concentrationWeight, true))

            averageProfitColumn.text:SetText(CraftSim.UTIL:FormatMoney(averageProfit, true, relativeTo, true))

            if CraftSim.DB.OPTIONS:Get("RECIPESCAN_OPTIMIZE_PROFESSION_TOOLS") then
                if recipeData.professionGearSet:IsEquipped() then
                    topGearColumn.equippedText:Show()
                    topGearColumn.equippedText:SetEquipped()

                    topGearColumn.gear1Icon:Hide()
                    topGearColumn.gear2Icon:Hide()
                    topGearColumn.toolIcon:Hide()
                else
                    topGearColumn.equippedText:Hide()
                    if recipeData.isCooking then
                        topGearColumn.gear1Icon:Hide()
                    else
                        topGearColumn.gear1Icon:SetItem(recipeData.professionGearSet.gear1.item)
                        topGearColumn.gear1Icon:Show()
                    end

                    topGearColumn.gear2Icon:SetItem(recipeData.professionGearSet.gear2.item)
                    topGearColumn.toolIcon:SetItem(recipeData.professionGearSet.tool.item)

                    topGearColumn.gear2Icon:Show()
                    topGearColumn.toolIcon:Show()
                end
            else
                topGearColumn.gear1Icon:Hide()
                topGearColumn.gear2Icon:Hide()
                topGearColumn.toolIcon:Hide()
                topGearColumn.equippedText:Show()
                topGearColumn.equippedText:SetIrrelevant()
            end

            -- for inventory count, count all result items together? For now.. Maybe a user will have a better idea!

            local totalCountInv = 0
            local totalCountAH = nil
            for _, resultItem in pairs(recipeData.resultData.itemsByQuality) do
                -- links are already loaded here
                totalCountInv = totalCountInv + C_Item.GetItemCount(resultItem:GetItemLink(), true, false, true)
                local countAH = CraftSim.PRICE_SOURCE:GetAuctionAmount(resultItem:GetItemLink())

                if countAH then
                    totalCountAH = (totalCountAH or 0) + countAH
                end
            end

            local countText = tostring(totalCountInv)

            if totalCountAH then
                countText = countText .. " / " .. totalCountAH
            end

            countColumn.text:SetText(countText)

            -- show reagents in tooltip when recipe is hovered

            row.tooltipOptions = {
                text = recipeData.reagentData:GetTooltipText(1, recipeData:GetCrafterUID()),
                owner = row.frame,
                anchor = "ANCHOR_CURSOR",
            }
        end)
    resultList:UpdateDisplay()
end
