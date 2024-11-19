---@class CraftSim
local CraftSim = select(2, ...)

---@class CraftSim.COOLDOWNS
CraftSim.COOLDOWNS = CraftSim.COOLDOWNS

---@class CraftSim.COOLDOWNS.UI
CraftSim.COOLDOWNS.UI = {}

---@class CraftSim.COOLDOWNS.FRAME : GGUI.Frame
CraftSim.COOLDOWNS.frame = nil

local GUTIL = CraftSim.GUTIL
local GGUI = CraftSim.GGUI
local L = CraftSim.UTIL:GetLocalizer()
local f = GUTIL:GetFormatter()
local LID = CraftSim.CONST.TEXT

local print = CraftSim.DEBUG:RegisterDebugID("Modules.Cooldowns.UI")

function CraftSim.COOLDOWNS.UI:Init()
    local sizeX = 670
    local sizeY = 220
    local offsetX = 0
    local offsetY = 0

    ---@class CraftSim.COOLDOWNS.FRAME : GGUI.Frame
    CraftSim.COOLDOWNS.frame = GGUI.Frame({
        parent = ProfessionsFrame,
        anchorParent = ProfessionsFrame,
        anchorA = "TOPRIGHT",
        anchorB = "BOTTOMRIGHT",
        sizeX = sizeX,
        sizeY = sizeY,
        offsetY = offsetY,
        offsetX = offsetX,
        frameID = CraftSim.CONST.FRAMES.COOLDOWNS,
        title = L(CraftSim.CONST.TEXT.COOLDOWNS_TITLE),
        collapseable = true,
        closeable = true,
        moveable = true,
        backdropOptions = CraftSim.CONST.DEFAULT_BACKDROP_OPTIONS,
        onCloseCallback = CraftSim.CONTROL_PANEL:HandleModuleClose("MODULE_COOLDOWNS"),
        frameTable = CraftSim.INIT.FRAMES,
        frameConfigTable = CraftSim.DB.OPTIONS:Get("GGUI_CONFIG"),
        frameStrata = CraftSim.CONST.MODULES_FRAME_STRATA,
        raiseOnInteraction = true,
        frameLevel = CraftSim.UTIL:NextFrameLevel()
    })

    ---@class CraftSim.COOLDOWNS.FRAME.CONTENT : Frame
    CraftSim.COOLDOWNS.frame.content = CraftSim.COOLDOWNS.frame.content

    ---@class CraftSim.COOLDOWNS.FRAME.CONTENT : Frame
    local content = CraftSim.COOLDOWNS.frame.content

    content.overviewTab = GGUI.BlizzardTab({
        buttonOptions = {
            parent = content,
            anchorParent = content,
            offsetY = -2,
            label = L(LID.COOLDOWNS_TAB_OVERVIEW),
        },
        parent = content,
        anchorParent = content,
        sizeX = sizeX,
        sizeY = sizeY,
        canBeEnabled = true,
        offsetY = -30,
        initialTab = true,
        top = true,
    })
    content.cooldownOptionsTab = GGUI.BlizzardTab({
        buttonOptions = {
            parent = content,
            anchorParent = content.overviewTab.button,
            anchorA = "LEFT",
            anchorB = "RIGHT",
            label = L(LID.COOLDOWNS_TAB_OPTIONS),
        },
        parent = content,
        anchorParent = content,
        sizeX = sizeX,
        sizeY = sizeY,
        canBeEnabled = true,
        offsetY = -30,
        top = true,
    })
    ---@class CraftSim.COOLDOWNS.UI.OVERVIEW_TAB : GGUI.BlizzardTab
    local overviewTab = content.overviewTab
    ---@class CraftSim.COOLDOWNS.UI.OVERVIEW_TAB.CONTENT : Frame
    overviewTab.content = overviewTab.content

    self:InitalizeOverviewTab(overviewTab)

    ---@class CraftSim.COOLDOWNS.UI.COOLDOWN_OPTIONS_TAB : GGUI.BlizzardTab
    local cooldownOptionsTab = content.cooldownOptionsTab
    ---@class CraftSim.COOLDOWNS.UI.COOLDOWN_OPTIONS_TAB.CONTENT : Frame
    cooldownOptionsTab.content = cooldownOptionsTab.content

    self:InitializeCooldownOptionsTab(cooldownOptionsTab)

    GGUI.BlizzardTabSystem { overviewTab, cooldownOptionsTab }
end

---@param overviewTab CraftSim.COOLDOWNS.UI.OVERVIEW_TAB
function CraftSim.COOLDOWNS.UI:InitalizeOverviewTab(overviewTab)
    local content = overviewTab.content

    content.cooldownList = GGUI.FrameList {
        parent = content, anchorParent = content, anchorA = "TOPLEFT", anchorB = "TOPLEFT", offsetY = -30, offsetX = 20,
        showBorder = true, sizeY = 147, selectionOptions = { noSelectionColor = true, hoverRGBA = CraftSim.CONST.FRAME_LIST_SELECTION_COLORS.HOVER_LIGHT_WHITE },
        columnOptions = {
            {
                label = L(LID.COOLDOWNS_CRAFTER_HEADER),
                width = 150,
            },
            {
                label = L(LID.COOLDOWNS_RECIPE_HEADER),
                width = 150,
            },
            {
                label = L(LID.COOLDOWNS_CHARGES_HEADER),
                width = 70,
                justifyOptions = { type = "H", align = "CENTER" }
            },
            {
                label = L(LID.COOLDOWNS_NEXT_HEADER),
                width = 120,
                justifyOptions = { type = "H", align = "CENTER" }
            },
            {
                label = L(LID.COOLDOWNS_ALL_HEADER),
                width = 120,
            },
        },
        rowConstructor = function(columns, row)
            ---@class CraftSim.COOLDOWNS.CooldownList.Row : GGUI.FrameList.Row
            row = row
            ---@type CraftSim.CooldownData
            row.cooldownData = nil
            row.allchargesFullTimestamp = 0
            ---@class CraftSim.COOLDOWNS.CooldownList.CrafterColumn : Frame
            local crafterColumn = columns[1]
            ---@class CraftSim.COOLDOWNS.CooldownList.RecipeColumn : Frame
            local recipeColumn = columns[2]
            ---@class CraftSim.COOLDOWNS.CooldownList.ChargesColumn : Frame
            local chargesColumn = columns[3]
            ---@class CraftSim.COOLDOWNS.CooldownList.NextColumn : Frame
            local nextColumn = columns[4]
            ---@class CraftSim.COOLDOWNS.CooldownList.AllColumn : Frame
            local allColumn = columns[5]

            crafterColumn.text = GGUI.Text {
                parent = crafterColumn, anchorParent = crafterColumn, justifyOptions = { type = "H", align = "LEFT" },
                anchorA = "LEFT", anchorB = "LEFT",
            }
            recipeColumn.text = GGUI.Text {
                parent = recipeColumn, anchorParent = recipeColumn, justifyOptions = { type = "H", align = "LEFT" },
                anchorA = "LEFT", anchorB = "LEFT", fixedWidth = 150,
            }
            chargesColumn.slash = GGUI.Text {
                parent = chargesColumn, anchorParent = chargesColumn, text = "/"
            }
            chargesColumn.current = GGUI.Text {
                parent = chargesColumn, anchorParent = chargesColumn.slash.frame, justifyOptions = { type = "H", align = "RIGHT" },
                anchorA = "RIGHT", anchorB = "LEFT",
            }
            chargesColumn.max = GGUI.Text {
                parent = chargesColumn, anchorParent = chargesColumn.slash.frame, justifyOptions = { type = "H", align = "LEFT" },
                anchorA = "LEFT", anchorB = "RIGHT",
            }
            chargesColumn.SetCharges = function(self, current, max)
                current = math.min(current, max)
                if current == max and max > 0 then
                    chargesColumn.current:SetText(f.g(current))
                    chargesColumn.max:SetText(f.g(max))
                elseif max > 0 then
                    chargesColumn.current:SetText(f.l(current))
                    chargesColumn.max:SetText(f.l(max))
                else
                    chargesColumn.current:SetText("-")
                    chargesColumn.max:SetText("-")
                end
            end
            nextColumn.text = GGUI.Text {
                parent = nextColumn, anchorParent = nextColumn, fixedWidth = 120,
            }
            allColumn.text = GGUI.Text {
                parent = allColumn, anchorParent = allColumn, justifyOptions = { type = "H", align = "LEFT" },
                anchorA = "LEFT", anchorB = "LEFT",
            }
        end

    }

    content:HookScript("OnShow", function()
        CraftSim.COOLDOWNS:StartTimerUpdate()
    end)
    content:HookScript("OnHide", function()
        CraftSim.COOLDOWNS:StopTimerUpdate()
    end)
end

---@param cooldownOptionsTab CraftSim.COOLDOWNS.UI.COOLDOWN_OPTIONS_TAB
function CraftSim.COOLDOWNS.UI:InitializeCooldownOptionsTab(cooldownOptionsTab)
    local content = cooldownOptionsTab.content

    content.expansionSelector = GGUI.CheckboxSelector {
        savedVariablesTable = CraftSim.DB.OPTIONS:Get("COOLDOWNS_FILTERED_EXPANSIONS"),
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
        parent = content,
        anchorPoints = { { anchorParent = content, anchorA = "TOP", anchorB = "TOP", offsetY = -10 } },
        label = L(LID.COOLDOWNS_EXPANSION_FILTER_BUTTON),
        sizeX = 30, sizeY = 25,
        buttonOptions = {
            parent = content, anchorParent = content,
            anchorA = "TOP", anchorB = "TOP", offsetY = -10,
            label = L(LID.COOLDOWNS_EXPANSION_FILTER_BUTTON),
            adjustWidth = true, sizeX = 20,
        },
        onSelectCallback = function(_, _, _)
            CraftSim.COOLDOWNS.UI:UpdateDisplay()
        end
    }
end

function CraftSim.COOLDOWNS.UI:UpdateDisplay()
    CraftSim.COOLDOWNS.UI:UpdateList()
    CraftSim.COOLDOWNS.UI:UpdateTimers()
end

function CraftSim.COOLDOWNS.UI:UpdateList()
    local cooldownList = CraftSim.COOLDOWNS.frame.content.overviewTab.content.cooldownList

    cooldownList:Remove()

    local crafterCooldownData = CraftSim.DB.CRAFTER:GetCrafterCooldownData()
    local includedExpansionIDs = CraftSim.COOLDOWNS:GetIncludedExpansions()

    for crafterUID, recipeCooldowns in pairs(crafterCooldownData) do
        for serializationID, cooldownDataSerialized in pairs(recipeCooldowns) do
            local cooldownData = CraftSim.CooldownData:Deserialize(cooldownDataSerialized)
            local recipeID = cooldownData.recipeID
            local professionInfo = CraftSim.DB.CRAFTER:GetProfessionInfoForRecipe(crafterUID, recipeID) or
                C_TradeSkillUI.GetProfessionInfoByRecipeID(recipeID)

            local skillLineID = professionInfo.professionID
            local expansionID = CraftSim.UTIL:GetExpansionIDBySkillLineID(skillLineID)

            local expansionIncluded = tContains(includedExpansionIDs, expansionID)

            if expansionIncluded then
                cooldownList:Add(
                ---@param row CraftSim.COOLDOWNS.CooldownList.Row
                    function(row)
                        row.cooldownData = cooldownData
                        local columns = row.columns
                        local crafterColumn = columns[1] --[[@as CraftSim.COOLDOWNS.CooldownList.CrafterColumn]]
                        local recipeColumn = columns[2] --[[@as CraftSim.COOLDOWNS.CooldownList.RecipeColumn]]
                        local chargesColumn = columns[3] --[[@as CraftSim.COOLDOWNS.CooldownList.ChargesColumn]]
                        local nextColumn = columns[4] --[[@as CraftSim.COOLDOWNS.CooldownList.NextColumn]]
                        local allColumn = columns[5] --[[@as CraftSim.COOLDOWNS.CooldownList.AllColumn]]

                        local crafterClass = CraftSim.DB.CRAFTER:GetClass(crafterUID)
                        local crafterName = f.class(select(1, strsplit("-", crafterUID), crafterClass))
                        local tooltipText = f.class(crafterUID, crafterClass)


                        local professionIcon = ""
                        if professionInfo.profession then
                            professionIcon = CraftSim.CONST.PROFESSION_ICONS[professionInfo.profession]
                            professionIcon = GUTIL:IconToText(professionIcon, 20, 20) .. " "
                        end

                        crafterColumn.text:SetText(professionIcon .. crafterName)

                        local recipeInfo = CraftSim.DB.CRAFTER:GetRecipeInfo(crafterUID, recipeID) or
                            C_TradeSkillUI.GetRecipeInfo(recipeID)


                        if cooldownData.sharedCD then
                            recipeColumn.text:SetText(L(CraftSim.CONST.SHARED_PROFESSION_COOLDOWNS
                                [cooldownData.sharedCD]))
                            local recipeListText = ""
                            for _, sharedRecipeID in pairs(CraftSim.CONST.SHARED_PROFESSION_COOLDOWNS_RECIPES[cooldownData.sharedCD]) do
                                local sharedRecipeIDInfo = CraftSim.DB.CRAFTER:GetRecipeInfo(crafterUID, sharedRecipeID) or
                                    C_TradeSkillUI.GetRecipeInfo(sharedRecipeID)

                                if sharedRecipeIDInfo then
                                    recipeListText = recipeListText .. "\n" .. sharedRecipeIDInfo.name
                                end
                            end
                            if #recipeListText > 0 then
                                tooltipText = tooltipText ..
                                    L(CraftSim.CONST.TEXT.COOLDOWNS_RECIPE_LIST_TEXT_TOOLTIP) .. f.white(recipeListText)
                            end
                        else
                            recipeColumn.text:SetText((recipeInfo and recipeInfo.name) or serializationID)
                        end

                        row.tooltipOptions = {
                            text = tooltipText,
                            owner = row.frame,
                            anchor = "ANCHOR_CURSOR",
                        }

                        row.UpdateTimers = function(self)
                            print("Updating Timers for " .. tostring(recipeInfo.name))
                            local cooldownData = self.cooldownData
                            chargesColumn:SetCharges(cooldownData:GetCurrentCharges(), cooldownData.maxCharges)
                            local allFullTS, ready = cooldownData:GetAllChargesFullTimestamp()
                            local cdReady = ready or cooldownData:GetCurrentCharges() >= cooldownData.maxCharges
                            nextColumn.text:SetText(cdReady and f.grey("-") or
                                f.bb(cooldownData:GetFormattedTimerNextCharge()))
                            row.allchargesFullTimestamp = allFullTS
                            if cdReady then
                                allColumn.text:SetText(L(CraftSim.CONST.TEXT.COOLDOWNS_RECIPE_READY))
                            else
                                allColumn.text:SetText(f.g(cooldownData:GetAllChargesFullDateFormatted()))
                            end
                        end

                        row:UpdateTimers()
                    end)
            end
        end
    end

    cooldownList:UpdateDisplay(
    ---@param rowA CraftSim.COOLDOWNS.CooldownList.Row
    ---@param rowB CraftSim.COOLDOWNS.CooldownList.Row
        function(rowA, rowB)
            return rowA.allchargesFullTimestamp < rowB.allchargesFullTimestamp
        end)
end

function CraftSim.COOLDOWNS.UI:UpdateTimers()
    local cooldownList = CraftSim.COOLDOWNS.frame.content.overviewTab.content.cooldownList

    for _, activeRow in pairs(cooldownList.activeRows) do
        activeRow:UpdateTimers()
    end
end
