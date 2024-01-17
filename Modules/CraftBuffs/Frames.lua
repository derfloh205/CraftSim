---@class CraftSim
local CraftSim = select(2, ...)

local GUTIL = CraftSim.GUTIL
local GGUI = CraftSim.GGUI

---@class CraftSim.CRAFT_BUFFS
CraftSim.CRAFT_BUFFS = CraftSim.CRAFT_BUFFS

---@class CraftSim.CRAFT_BUFFS.FRAMES
CraftSim.CRAFT_BUFFS.FRAMES = {}

local print = CraftSim.UTIL:SetDebugPrint(CraftSim.CONST.DEBUG_IDS.BUFFDATA)

---@type table<string, boolean>
CraftSim.CRAFT_BUFFS.simulatedBuffs = {}
function CraftSim.CRAFT_BUFFS.FRAMES:Init()
    local sizeX = 330
    local sizeY = 200
    local offsetX = 0
    local offsetY = 0

    ---@class CraftSim.CRAFT_BUFFS.FRAME : GGUI.Frame
    CraftSim.CRAFT_BUFFS.frame = GGUI.Frame({
        parent = ProfessionsFrame.CraftingPage,
        anchorParent = ProfessionsFrame,
        anchorA = "TOPLEFT",
        anchorB = "TOPLEFT",
        sizeX = sizeX,
        sizeY = sizeY,
        offsetY = offsetY,
        offsetX = offsetX,
        frameID = CraftSim.CONST.FRAMES.CRAFT_BUFFS,
        title = CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CRAFT_BUFFS_TITLE),
        collapseable = true,
        closeable = true,
        moveable = true,
        backdropOptions = CraftSim.CONST.DEFAULT_BACKDROP_OPTIONS,
        onCloseCallback = CraftSim.FRAME:HandleModuleClose("modulesCraftBuffs"),
        frameTable = CraftSim.MAIN.FRAMES,
        frameConfigTable = CraftSimGGUIConfig,
    })
    ---@class CraftSim.CRAFT_BUFFS.FRAME: GGUI.Frame
    CraftSim.CRAFT_BUFFS.frameWO = GGUI.Frame({
        parent = ProfessionsFrame.OrdersPage.OrderView.OrderDetails.SchematicForm,
        anchorParent = ProfessionsFrame,
        anchorA = "TOPLEFT",
        anchorB = "TOPLEFT",
        sizeX = sizeX,
        sizeY = sizeY,
        offsetY = offsetY,
        offsetX = offsetX,
        frameID = CraftSim.CONST.FRAMES.CRAFT_BUFFS_WORKORDER,
        title = CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CRAFT_BUFFS_TITLE) ..
            " " .. CraftSim.GUTIL:ColorizeText("WO", CraftSim.GUTIL.COLORS.GREY),
        collapseable = true,
        closeable = true,
        moveable = true,
        backdropOptions = CraftSim.CONST.DEFAULT_BACKDROP_OPTIONS,
        onCloseCallback = CraftSim.FRAME:HandleModuleClose("modulesCraftBuffs"),
        frameTable = CraftSim.MAIN.FRAMES,
        frameConfigTable = CraftSimGGUIConfig,
    })

    local function createContent(frame)
        ---@class CraftSim.CRAFT_BUFFS.FRAME
        frame = frame

        ---@class CraftSim.CRAFT_BUFFS.FRAME.CONTENT: Frame
        frame.content = frame.content

        frame.content.simulateBuffSelector = GGUI.CheckboxSelector {
            buttonOptions = {
                parent = frame.content, anchorParent = frame.title.frame, anchorA = "TOP", anchorB = "BOTTOM", offsetY = -5,
                adjustWidth = true, sizeX = 15, label = CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CRAFT_BUFFS_SIMULATE_BUTTON)
            },
            selectionFrameOptions = {
                backdropOptions = CraftSim.CONST.DEFAULT_BACKDROP_OPTIONS, closeable = true,
                sizeX = 330, anchorA = "BOTTOM", anchorB = "TOP",
            },
            savedVariablesTable = CraftSim.CRAFT_BUFFS.simulatedBuffs,
            onSelectCallback = function()
                CraftSim.MAIN:TriggerModuleUpdate()
            end
        }

        frame.content.simulateBuffSelector:SetEnabled(false)

        frame.content.buffList = GGUI.FrameList {
            parent = frame.content, anchorParent = frame.content.simulateBuffSelector.button.frame, anchorA = "TOP", anchorB = "BOTTOM", sizeY = 127, offsetY = -5, showBorder = true,
            offsetX = -10, selectionOptions = { noSelectionColor = true, hoverRGBA = CraftSim.CONST.JUST_HOVER_FRAMELIST_HOVERRGBA }, rowHeight = 20,
            columnOptions = {
                {
                    label = "", -- Buffstatus
                    width = 30,
                },
                {
                    label = "", -- Buffname
                    width = 250,
                },
            },
            rowConstructor = function(columns)
                ---@class CraftSim.CRAFT_BUFFS.buffList.statusColumn : Frame
                local statusColumn = columns[1]
                ---@class CraftSim.CRAFT_BUFFS.buffList.nameColumn : Frame
                local nameColumn = columns[2]

                statusColumn.active = false

                local spellIconSize = 20
                nameColumn.icon = GGUI.SpellIcon {
                    parent = nameColumn, anchorParent = nameColumn, sizeX = spellIconSize, sizeY = spellIconSize,
                    anchorA = "LEFT", anchorB = "LEFT", offsetX = 0,
                }

                nameColumn.text = GGUI.Text {
                    parent = nameColumn, anchorParent = nameColumn.icon.frame, justifyOptions = { type = "H", align = "LEFT" },
                    anchorA = "LEFT", anchorB = "RIGHT", text = "<buffname>", offsetX = 5,
                }

                local statusIconSize = 15
                statusColumn.texture = GGUI.Texture {
                    parent = statusColumn, anchorParent = statusColumn, sizeX = statusIconSize, sizeY = statusIconSize,
                }

                statusColumn.SetActive = function(self, active)
                    self.active = active
                    if active then
                        statusColumn.texture:SetAtlas(CraftSim.CONST.ATLAS_TEXTURES.CRAFT_BUFF_ACTIVE)
                        nameColumn.icon:Saturate()
                        nameColumn.text:SetColor()
                    else
                        statusColumn.texture:SetAtlas(CraftSim.CONST.ATLAS_TEXTURES.CRAFT_BUFF_NOT_ACTIVE)
                        nameColumn.icon:Desaturate()
                        nameColumn.text:SetColor(GUTIL.COLORS.GREY)
                    end
                end
            end,
        }
    end

    createContent(CraftSim.CRAFT_BUFFS.frame)
    createContent(CraftSim.CRAFT_BUFFS.frameWO)
end

---@type CraftSim.ProfessionStats
local emptyStats = nil
---@param recipeData CraftSim.RecipeData
---@param exportMode CraftSim.EXPORT_MODE
function CraftSim.CRAFT_BUFFS.FRAMES:UpdateDisplay(recipeData, exportMode)
    ---@type CraftSim.CRAFT_BUFFS.FRAME
    local craftbuffsFrame

    if exportMode == CraftSim.CONST.EXPORT_MODE.NON_WORK_ORDER then
        craftbuffsFrame = CraftSim.CRAFT_BUFFS.frame
    else
        craftbuffsFrame = CraftSim.CRAFT_BUFFS.frameWO
    end

    if not craftbuffsFrame then return end

    ---@type CraftSim.CRAFT_BUFFS.FRAME.CONTENT
    local craftBuffsContent = craftbuffsFrame.content

    craftBuffsContent.buffList:Remove()
    craftBuffsContent.simulateBuffSelector:SetItems()

    local buffData = recipeData.buffData

    if not buffData then return end

    for _, buff in pairs(buffData.buffs) do
        craftBuffsContent.buffList:Add(function(row)
            local columns = row.columns

            local statusColumn = columns[1] --[[@as CraftSim.CRAFT_BUFFS.buffList.statusColumn]]
            local nameColumn = columns[2] --[[@as CraftSim.CRAFT_BUFFS.buffList.nameColumn]]

            nameColumn.icon:SetSpell(buff.displayBuffID)
            nameColumn.text:SetText(buff.name)
            statusColumn:SetActive(buff.active)

            if not emptyStats then
                emptyStats = CraftSim.ProfessionStats()
            end
            local currentStats = buff.active and buff.professionStats or emptyStats

            row.tooltipOptions = {
                anchor = "ANCHOR_CURSOR",
                owner = row.frame,
                text = buff.customTooltip or currentStats:GetTooltipText(buff.professionStats)
            }
        end)
    end

    craftBuffsContent.buffList:UpdateDisplay(function(rowA, rowB)
        local activeA = rowA.columns[1].active
        local activeB = rowB.columns[1].active
        if activeA and not activeB then
            return true
        end
        if activeB then
            return false
        end

        return false
    end)

    craftBuffsContent.simulateBuffSelector:SetItems(GUTIL:Map(buffData.buffs, function(buff)
        ---@type GGUI.CheckboxSelector.CheckboxItem
        local checkboxItem = {
            name = buff.name,
            initialValue = buff.active,
            savedVariableProperty = buff:GetUID(),
            selectionID = buff:GetUID(),
        }
        return checkboxItem
    end))
end
