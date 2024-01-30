---@class CraftSim
local CraftSim = select(2, ...)

local GGUI = CraftSim.GGUI
local GUTIL = CraftSim.GUTIL
local L = CraftSim.UTIL:GetLocalizer()

---@class CraftSim.RECIPE_SCAN
CraftSim.RECIPE_SCAN = CraftSim.RECIPE_SCAN

---@class CraftSim.RECIPE_SCAN.FRAMES
CraftSim.RECIPE_SCAN.FRAMES = {}

local print = CraftSim.UTIL:SetDebugPrint(CraftSim.CONST.DEBUG_IDS.RECIPE_SCAN)

function CraftSim.RECIPE_SCAN.FRAMES:Init()
    ---@class CraftSim.RECIPE_SCAN.FRAME : GGUI.Frame
    CraftSim.RECIPE_SCAN.frame = GGUI.Frame({
        parent = ProfessionsFrame.CraftingPage.SchematicForm,
        anchorParent = ProfessionsFrame.CraftingPage.SchematicForm,
        sizeX = 1020,
        sizeY = 400,
        frameID = CraftSim.CONST.FRAMES.RECIPE_SCAN,
        --title = L(CraftSim.CONST.TEXT.RECIPE_SCAN_TITLE),
        collapseable = true,
        closeable = true,
        moveable = true,
        frameStrata = "DIALOG",
        backdropOptions = CraftSim.CONST.DEFAULT_BACKDROP_OPTIONS,
        onCloseCallback = CraftSim.FRAME:HandleModuleClose("modulesRecipeScan"),
        frameTable = CraftSim.MAIN.FRAMES,
        frameConfigTable = CraftSimGGUIConfig,
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

        CraftSim.RECIPE_SCAN.FRAMES:InitRecipeScanTab(frame.content.recipeScanTab)

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

        CraftSim.RECIPE_SCAN.FRAMES:InitScanOptionsTab(frame.content.scanOptionsTab)

        GGUI.BlizzardTabSystem { frame.content.recipeScanTab, frame.content.scanOptionsTab }
    end

    createContent(CraftSim.RECIPE_SCAN.frame)
    GGUI:EnableHyperLinksForFrameAndChilds(CraftSim.RECIPE_SCAN.frame.content)
end

---@param selectedRow CraftSim.RECIPE_SCAN.PROFESSION_LIST.ROW
function CraftSim.RECIPE_SCAN.FRAMES:OnProfessionRowSelected(selectedRow, userInput)
    print("select row: " .. tostring(selectedRow.crafterData.name) .. ": " .. tostring(selectedRow.profession))
    print("userInput: " .. tostring(userInput))
    -- hide all others except me
    for _, row in pairs(selectedRow.activeRows) do
        row.contentFrame:Hide()
    end

    selectedRow.contentFrame:Show()

    CraftSim.RECIPE_SCAN.FRAMES:UpdateProfessionListRowCachedRecipesInfo(selectedRow)
end

---@param selectedRow CraftSim.RECIPE_SCAN.PROFESSION_LIST.ROW
function CraftSim.RECIPE_SCAN.FRAMES:UpdateProfessionListRowCachedRecipesInfo(selectedRow)
    -- update cached recipes value
    local content = selectedRow.content --[[@as CraftSim.RECIPE_SCAN.PROFESSION_LIST.TAB_CONTENT]]
    local professions = CraftSimRecipeDataCache.cachedRecipeIDs[selectedRow.crafterUID] or {}
    local recipeIDCache = professions[selectedRow.profession] or {}

    if C_TradeSkillUI.IsTradeSkillReady() then
        if selectedRow.crafterProfessionUID ~= CraftSim.RECIPE_SCAN:GetPlayerCrafterProfessionUID() then
            content.cachedRecipesInfoHelpIcon:Show()
            content.cachedRecipesInfo:SetText("(Cached Recipes: " .. tostring(#recipeIDCache) .. ") ")
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
function CraftSim.RECIPE_SCAN.FRAMES:InitRecipeScanTab(recipeScanTab)
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
                CraftSim.RECIPE_SCAN.FRAMES:OnProfessionRowSelected(row, userInput)
                CraftSim.CRAFTQ.FRAMES:UpdateRecipeScanRestockButton(row.currentResults)
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

function CraftSim.RECIPE_SCAN.FRAMES:UpdateProfessionList()
    -- for each profession that is cached, create a tabFrame and connect it to the row of the profession
    -- do this only if the profession is not yet added to the list
    local content = CraftSim.RECIPE_SCAN.frame.content.recipeScanTab
        .content --[[@as CraftSim.RECIPE_SCAN.RECIPE_SCAN_TAB.CONTENT]]
    local activeRows = content.professionList.activeRows
    for crafterUID, professions in pairs(CraftSimRecipeDataCache.cachedRecipeIDs) do
        for profession, _ in pairs(professions) do
            local crafterProfessionUID = CraftSim.RECIPE_SCAN:GetCrafterProfessionUID(crafterUID, profession)
            local alreadyListed = GUTIL:Some(activeRows, function(activeRow)
                return activeRow.crafterProfessionUID == crafterProfessionUID
            end)
            local isGatheringProfession = CraftSim.CONST.GATHERING_PROFESSIONS[profession]
            if not alreadyListed and not isGatheringProfession then
                CraftSim.RECIPE_SCAN.FRAMES:AddProfessionTabRow(crafterUID, profession)
            end
        end
    end


    CraftSim.RECIPE_SCAN.FRAMES:UpdateProfessionListDisplay()
end

function CraftSim.RECIPE_SCAN.FRAMES:UpdateProfessionListDisplay()
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

            -- always prefer the crafterUID of the player

            if crafterUIDA == playerCrafterUID and crafterUIDB ~= playerCrafterUID then
                return true
            end

            if crafterUIDA ~= playerCrafterUID and crafterUIDB == playerCrafterUID then
                return false
            end

            -- -- if both are the playerCrafterUID, prefer the playerCrafterProfessionUID

            -- if playerCrafterProfessionUIDA == playerCrafterProfessionUID and playerCrafterProfessionUIDB ~= playerCrafterProfessionUID then
            --     return true
            -- end

            -- if playerCrafterProfessionUIDA ~= playerCrafterProfessionUID and playerCrafterProfessionUIDB == playerCrafterProfessionUID then
            --     return false
            -- end

            -- -- if not the player prefer same crafterUID

            -- if crafterUIDA == crafterUIDB then
            --     return true
            -- end


            return false
        end)

    --- since this is only called when first opening or in general opening a profession just select the current profession always
    -- only select if there is nothing selected yet
    local selectedRow = content.professionList.selectedRow --[[@as CraftSim.RECIPE_SCAN.PROFESSION_LIST.ROW]]
    if not selectedRow then
        content.professionList:SelectRow(1)
    else
        CraftSim.RECIPE_SCAN.FRAMES:UpdateProfessionListRowCachedRecipesInfo(selectedRow) --[[@as CraftSim.RECIPE_SCAN.PROFESSION_LIST.ROW]]
    end
end

---@param row CraftSim.RECIPE_SCAN.PROFESSION_LIST.ROW
---@param content Frame
---@return CraftSim.RECIPE_SCAN.PROFESSION_LIST.TAB_CONTENT
function CraftSim.RECIPE_SCAN.FRAMES:CreateProfessionTabContent(row, content)
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

    content.resultAmount = GGUI.Text {
        parent = content, anchorParent = content.scanButton.frame, anchorA = "RIGHT", anchorB = "LEFT",
        offsetX = -15, justifyOptions = { type = "H", align = "RIGHT" }, text = "",
    }

    content.cancelScanButton:Hide()

    local columnOptions = {
        {
            label = L(CraftSim.CONST.TEXT.RECIPE_SCAN_RECIPE_HEADER),
            width = 150,
        },
        {
            label = L(CraftSim.CONST.TEXT.RECIPE_SCAN_LEARNED_HEADER),
            width = 60,
            justifyOptions = { type = "H", align = "CENTER" }
        },
        {
            label = L(CraftSim.CONST.TEXT.RECIPE_SCAN_GUARANTEED_HEADER),
            width = 80,
            justifyOptions = { type = "H", align = "CENTER" }
        },
        {
            label = L(CraftSim.CONST.TEXT.RECIPE_SCAN_HIGHEST_RESULT_HEADER), -- icon + upgrade chance
            width = 110,
            justifyOptions = { type = "H", align = "CENTER" }
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

    ---@type GGUI.FrameList | GGUI.Widget
    content.resultList = GGUI.FrameList({
        parent = content,
        anchorParent = content.scanButton.frame,
        anchorA = "TOP",
        anchorB = "BOTTOM",
        showBorder = true,
        sizeY = 280,
        offsetY = -25,
        columnOptions = columnOptions,
        selectionOptions = {
            hoverRGBA = { 1, 1, 1, 0.1 },
            noSelectionColor = true,
            selectionCallback = function(row)
                local recipeData = row.recipeData --[[@as CraftSim.RecipeData]]
                if recipeData then
                    C_TradeSkillUI.OpenRecipe(recipeData.recipeID)
                end
            end
        },
        rowConstructor = function(columns)
            local recipeColumn = columns[1]
            local learnedColumn = columns[2]
            local expectedResultColumn = columns[3]
            local highestResultColumn = columns[4]
            local averageProfitColumn = columns[5]
            local topGearColumn = columns[6]
            local countColumn = columns[7]

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

            learnedColumn.text = GGUI.Text({
                parent = learnedColumn, anchorParent = learnedColumn, justifyOptions = { type = "H", align = "CENTER" },
            })

            function learnedColumn:SetLearned(learned)
                if learned then
                    learnedColumn.text:SetText(CraftSim.MEDIA:GetAsTextIcon(CraftSim.MEDIA.IMAGES.TRUE, 0.125))
                else
                    learnedColumn.text:SetText(CraftSim.MEDIA:GetAsTextIcon(CraftSim.MEDIA.IMAGES.FALSE, 0.125))
                end
            end

            local iconSize = 23

            ---@type GGUI.Icon | GGUI.Widget
            expectedResultColumn.itemIcon = GGUI.Icon({
                parent = expectedResultColumn,
                anchorParent = expectedResultColumn,
                sizeX = iconSize,
                sizeY =
                    iconSize,
                qualityIconScale = 1.4,
            })

            ---@type GGUI.Icon | GGUI.Widget
            highestResultColumn.itemIcon = GGUI.Icon({
                parent = highestResultColumn,
                anchorParent = highestResultColumn,
                sizeX = iconSize,
                sizeY = iconSize,
                qualityIconScale = 1.4,
                offsetX = -25
            })

            ---@type GGUI.Text | GGUI.Widget
            highestResultColumn.noneText = GGUI.Text({
                parent = highestResultColumn,
                anchorParent = highestResultColumn,
                text = GUTIL:ColorizeText("-",
                    GUTIL.COLORS.GREY)
            })

            ---@type GGUI.Text | GGUI.Widget
            highestResultColumn.chance = GGUI.Text({
                parent = highestResultColumn,
                anchorParent = highestResultColumn.itemIcon.frame,
                anchorA = "LEFT",
                anchorB =
                "RIGHT",
                offsetX = 10,
            })

            ---@type GGUI.Text | GGUI.Widget
            averageProfitColumn.text = GGUI.Text({
                parent = averageProfitColumn, anchorParent = averageProfitColumn, anchorA = "LEFT", anchorB = "LEFT"
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

    return content
end

---@param crafterUID string
---@param profession Enum.Profession
function CraftSim.RECIPE_SCAN.FRAMES:AddProfessionTabRow(crafterUID, profession)
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

        local crafterName, crafterRealm = strsplit("-", crafterUID)
        local crafterNameColored
        local crafterClass = CraftSimRecipeDataCache.altClassCache[crafterUID]
        if crafterClass then
            crafterNameColored = C_ClassColor.GetClassColor(crafterClass):WrapTextInColorCode(crafterName)
        else
            crafterNameColored = crafterName
        end
        local professionIconSize = 20
        local professionIcon = GUTIL:IconToText(CraftSim.CONST.PROFESSION_ICONS[row.profession], professionIconSize,
            professionIconSize)
        ---@type GGUI.FrameList.Row.TooltipOptions
        row.tooltipOptions = {
            text = crafterUID .. ": " .. L(CraftSim.CONST.PROFESSION_LOCALIZATION_IDS[profession]),
            anchor = "ANCHOR_TOP",
            owner = row.frame
        }

        -- todo: add profession icon prefix
        crafterColumn.text:SetText(professionIcon .. " " .. crafterNameColored)
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

        local isChecked = CraftSimOptions.recipeScanIncludedProfessions[crafterProfessionUID]

        checkboxColumn.checkbox:SetChecked(isChecked)

        checkboxColumn.checkbox.clickCallback = function(_, checked)
            CraftSimOptions.recipeScanIncludedProfessions[crafterProfessionUID] = checked
        end

        row.contentFrame = GGUI.Frame {
            parent = content, anchorParent = content.professionList.frame, sizeX = 850, sizeY = content.professionList:GetHeight(),
            anchorA = "TOPLEFT", anchorB = "TOPRIGHT", offsetX = -20,
        }
        row.contentFrame.frame:SetFrameStrata(content:GetFrameStrata())
        row.contentFrame.frame:SetFrameLevel(content:GetFrameLevel() + 10)
        row.contentFrame:Hide()

        row.content = CraftSim.RECIPE_SCAN.FRAMES:CreateProfessionTabContent(row, row.contentFrame.content)

        row.content.recipeTitle:SetText(professionIcon .. " " .. crafterNameColored)
    end)
end

---@param scanOptionsTab CraftSim.RECIPE_SCAN.SCAN_OPTIONS_TAB
function CraftSim.RECIPE_SCAN.FRAMES:InitScanOptionsTab(scanOptionsTab)
    ---@class CraftSim.RECIPE_SCAN.SCAN_OPTIONS_TAB
    scanOptionsTab = scanOptionsTab
    ---@class CraftSim.RECIPE_SCAN.SCAN_OPTIONS_TAB.CONTENT : Frame
    local content = scanOptionsTab.content

    local initialScanModeValue = CraftSimOptions.recipeScanScanMode
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
        clickCallback = function(self, label, value)
            CraftSimOptions.recipeScanScanMode = value
        end
    })

    local checkBoxSpacingY = 0

    content.includeSoulboundCB = GGUI.Checkbox {
        parent = content, anchorParent = content.scanMode.frame, anchorA = "TOP", anchorB = "BOTTOM", offsetY = checkBoxSpacingY, offsetX = -80,
        label = L(CraftSim.CONST.TEXT.RECIPE_SCAN_INCLUDE_SOULBOUND),
        tooltip = L(CraftSim.CONST.TEXT.RECIPE_SCAN_INCLUDE_SOULBOUND_TOOLTIP),
        initialValue = CraftSimOptions.recipeScanIncludeSoulbound,
        clickCallback = function(_, checked) CraftSimOptions.recipeScanIncludeSoulbound = checked end
    }

    content.includeNotLearnedCB = GGUI.Checkbox {
        parent = content, anchorParent = content.includeSoulboundCB.frame, anchorA = "TOP", anchorB = "BOTTOM", offsetY = checkBoxSpacingY,
        label = L(CraftSim.CONST.TEXT.RECIPE_SCAN_INCLUDE_NOT_LEARNED),
        tooltip = L(CraftSim.CONST.TEXT.RECIPE_SCAN_INCLUDE_NOT_LEARNED_TOOLTIP),
        initialValue = CraftSimOptions.recipeScanIncludeNotLearned,
        clickCallback = function(_, checked) CraftSimOptions.recipeScanIncludeNotLearned = checked end
    }

    content.includeGearCB = GGUI.Checkbox {
        parent = content, anchorParent = content.includeNotLearnedCB.frame, anchorA = "TOP", anchorB = "BOTTOM", offsetY = checkBoxSpacingY,
        label = L(CraftSim.CONST.TEXT.RECIPE_SCAN_INCLUDE_GEAR),
        tooltip = L(CraftSim.CONST.TEXT.RECIPE_SCAN_INCLUDE_GEAR_TOOLTIP),
        initialValue = CraftSimOptions.recipeScanIncludeGear,
        clickCallback = function(_, checked) CraftSimOptions.recipeScanIncludeGear = checked end
    }

    content.onlyFavorites = GGUI.Checkbox {
        parent = content, anchorParent = content.includeGearCB.frame, anchorA = "TOP", anchorB = "BOTTOM", offsetY = checkBoxSpacingY,
        label = L(CraftSim.CONST.TEXT.RECIPE_SCAN_ONLY_FAVORITES_CHECKBOX),
        tooltip = L(CraftSim.CONST.TEXT.RECIPE_SCAN_ONLY_FAVORITES_CHECKBOX_TOOLTIP),
        initialValue = CraftSimOptions.recipeScanOnlyFavorites,
        clickCallback = function(_, checked) CraftSimOptions.recipeScanOnlyFavorites = checked end
    }

    content.optimizeProfessionToolsCB = GGUI.Checkbox {
        parent = content, anchorParent = content.onlyFavorites.frame, anchorA = "TOP", anchorB = "BOTTOM", offsetY = checkBoxSpacingY - 10,
        label = L(CraftSim.CONST.TEXT.RECIPE_SCAN_OPTIMIZE_TOOLS),
        tooltip = L(CraftSim.CONST.TEXT.RECIPE_SCAN_OPTIMIZE_TOOLS_TOOLTIP) ..
            GUTIL:ColorizeText(L(CraftSim.CONST.TEXT.RECIPE_SCAN_OPTIMIZE_TOOLS_WARNING), GUTIL.COLORS.RED),
        initialValue = CraftSimOptions.recipeScanOptimizeProfessionTools,
        clickCallback = function(_, checked) CraftSimOptions.recipeScanOptimizeProfessionTools = checked end
    }

    content.sortByProfitMarginCB = GGUI.Checkbox {
        parent = content, anchorParent = content.optimizeProfessionToolsCB.frame, anchorA = "TOP", anchorB = "BOTTOM", offsetY = checkBoxSpacingY,
        label = L(CraftSim.CONST.TEXT.RECIPE_SCAN_SORT_BY_MARGIN),
        tooltip = L(CraftSim.CONST.TEXT.RECIPE_SCAN_SORT_BY_MARGIN_TOOLTIP),
        initialValue = CraftSimOptions.recipeScanSortByProfitMargin,
        clickCallback = function(_, checked) CraftSimOptions.recipeScanSortByProfitMargin = checked end
    }

    content.useInsightCB = GGUI.Checkbox {
        parent = content, anchorParent = content.sortByProfitMarginCB.frame, anchorA = "TOP", anchorB = "BOTTOM", offsetY = checkBoxSpacingY,
        label = L(CraftSim.CONST.TEXT.RECIPE_SCAN_USE_INSIGHT_CHECKBOX),
        tooltip = L(CraftSim.CONST.TEXT.RECIPE_SCAN_USE_INSIGHT_CHECKBOX_TOOLTIP),
        initialValue = CraftSimOptions.recipeScanUseInsight,
        clickCallback = function(_, checked) CraftSimOptions.recipeScanUseInsight = checked end
    }

    content.expansionSelector = GGUI.CheckboxSelector {
        savedVariablesTable = CraftSimOptions.recipeScanFilteredExpansions,
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
            parent = content, anchorParent = content.useInsightCB.frame,
            anchorA = "TOPLEFT", anchorB = "BOTTOMLEFT", offsetY = checkBoxSpacingY,
            label = L(CraftSim.CONST.TEXT.RECIPE_SCAN_EXPANSION_FILTER_BUTTON), offsetX = 20,
            adjustWidth = true, sizeX = 20,
        },
    }
end

---@param row CraftSim.RECIPE_SCAN.PROFESSION_LIST.ROW
function CraftSim.RECIPE_SCAN.FRAMES:ResetResults(row)
    local resultList = row.content.resultList
    resultList:Remove()
    row.content.resultAmount:SetText("")
end

---@param row CraftSim.RECIPE_SCAN.PROFESSION_LIST.ROW
---@param recipeData CraftSim.RecipeData
function CraftSim.RECIPE_SCAN.FRAMES:AddRecipe(row, recipeData)
    local resultList = row.content.resultList
    resultList:Add(
        function(row)
            local columns = row.columns

            local recipeColumn = columns[1]
            local learnedColumn = columns[2]
            local expectedResultColumn = columns[3]
            local highestResultColumn = columns[4]
            local averageProfitColumn = columns[5]
            local topGearColumn = columns[6]
            local countColumn = columns[7]

            row.recipeData = recipeData

            local recipeRarity = recipeData.resultData.expectedItem:GetItemQualityColor()

            recipeColumn.text:SetText(recipeRarity.hex .. recipeData.recipeName .. "|r")

            learnedColumn:SetLearned(recipeData.learned)

            expectedResultColumn.itemIcon:SetItem(recipeData.resultData.expectedItem)

            if recipeData.resultData.canUpgradeQuality then
                highestResultColumn.itemIcon:Show()
                highestResultColumn.chance:Show()
                highestResultColumn.noneText:Hide()
                highestResultColumn.itemIcon:SetItem(recipeData.resultData.expectedItemUpgrade)
                highestResultColumn.chance:SetText(GUTIL:Round(recipeData.resultData.chanceUpgrade * 100, 1) .. "%")
            else
                highestResultColumn.noneText:Show()
                highestResultColumn.itemIcon:Hide()
                highestResultColumn.chance:Hide()
            end
            local averageProfit = recipeData:GetAverageProfit()
            local relativeTo = nil
            if CraftSimOptions.showProfitPercentage then
                relativeTo = recipeData.priceData.craftingCosts
            end
            averageProfitColumn.text:SetText(GUTIL:FormatMoney(averageProfit, true, relativeTo))
            row.averageProfit = averageProfit
            row.relativeProfit = GUTIL:GetPercentRelativeTo(averageProfit, recipeData.priceData.craftingCosts)

            if CraftSimOptions.recipeScanOptimizeProfessionTools then
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
                totalCountInv = totalCountInv + GetItemCount(resultItem:GetItemLink(), true, false, true)
                local countAH = CraftSim.PRICEDATA:GetAuctionAmount(resultItem:GetItemLink())

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
