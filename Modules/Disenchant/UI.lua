---@class CraftSim
local CraftSim = select(2, ...)

local GGUI = CraftSim.GGUI
local GUTIL = CraftSim.GUTIL

---@class CraftSim.DISENCHANT.UI
CraftSim.DISENCHANT.UI = {}

---@type CraftSim.DISENCHANT.FRAME
CraftSim.DISENCHANT.frame = nil

local Logger = CraftSim.DEBUG:RegisterLogger("Modules.Disenchant.UI")
local f = GUTIL:GetFormatter()
local L = CraftSim.UTIL:GetLocalizer()

function CraftSim.DISENCHANT.UI:Init()
    local sizeX = 270
    local sizeY = 290
    ---@class CraftSim.DISENCHANT.FRAME : GGUI.Frame
    CraftSim.DISENCHANT.frame = GGUI.Frame({
        parent = UIParent,
        anchorParent = UIParent,
        sizeX = sizeX,
        sizeY = sizeY,
        frameID = CraftSim.CONST.FRAMES.DISENCHANT,
        title = L("DISENCHANT_TITLE"),
        closeable = true,
        moveable = true,
        backdropOptions = CraftSim.CONST.DEFAULT_BACKDROP_OPTIONS,
        frameTable = CraftSim.INIT.FRAMES,
        frameConfigTable = CraftSim.DB.OPTIONS:Get("GGUI_CONFIG"),
        frameStrata = CraftSim.CONST.MODULES_FRAME_STRATA,
        raiseOnInteraction = true,
        frameLevel = CraftSim.UTIL:NextFrameLevel(),
        hide = true,
    })

    ---@class CraftSim.DISENCHANT.FRAME.CONTENT : Frame
    local content = CraftSim.DISENCHANT.frame.content

    content.infoButton = GGUI.HelpIcon {
        parent = content,
        anchorA = "TOPLEFT", anchorB = "TOPLEFT", offsetX = 5, offsetY = -5, anchorParent = content,
        text = L("DISENCHANT_INFO_TOOLTIP"),
    }

    content.optionsButton = CraftSim.WIDGETS.OptionsButton {
        parent = content,
        anchorPoints = {
            { anchorA = "LEFT", anchorB = "RIGHT", offsetX = 5, anchorParent = CraftSim.DISENCHANT.frame.title.frame },
        },
        menu = {
            {
                type = "custom",
                build = function(rootDescription)
                    GUTIL:CreateReuseableMenuUtilContextMenuFrame(rootDescription, function(frame)
                        frame.label = GGUI.Text {
                            parent = frame,
                            anchorParent = frame,
                            anchorA = "LEFT", anchorB = "LEFT",
                            justifyOptions = { align = "LEFT", type = "H" },
                            text = L("DISENCHANT_OPTIONS_MIN_ILVL"),
                        }

                        frame.input = GGUI.NumericInput {
                            parent = frame,
                            anchorParent = frame,
                            anchorA = "RIGHT", anchorB = "RIGHT",
                            offsetX = -5,
                            sizeX = 50,
                            borderAdjustWidth = 1.2,
                            minValue = 0, maxValue = 999,
                            initialValue = CraftSim.DB.OPTIONS:Get("DISENCHANT_MIN_ILVL"),
                            onNumberValidCallback = function(input)
                                CraftSim.DB.OPTIONS:Save("DISENCHANT_MIN_ILVL", input.currentValue)
                                CraftSim.DISENCHANT.UI:UpdateUI()
                            end,
                        }
                    end, 200, 20, "DISENCHANT_OPTIONS_MIN_ILVL_INPUT")
                end
            },
            {
                type = "button",
                label = f.r("Clear Blacklist"),
                onClick = function()
                    CraftSim.DB.OPTIONS:Save("DISENCHANT_BLACKLIST", {})
                    wipe(CraftSim.DISENCHANT.sessionBlacklist)
                    CraftSim.DISENCHANT.UI:UpdateUI()
                end
            }
        },
    }

    content.itemList = GGUI.FrameList {
        sizeY = 195,
        rowHeight = 20,
        showBorder = true,
        parent = content,
        anchorParent = content, anchorA = "TOPLEFT", anchorB = "TOPLEFT", offsetX = 5, offsetY = -55,
        savedVariablesTableLayoutConfig = CraftSim.UTIL:GetFrameListLayoutConfig("DISENCHANT_ITEM_LIST"),
        selectionOptions = {
            hoverRGBA = { 0, 1, 0, 0.1 },

            selectionCallback = function(row, userInput, alreadySelected)
                if userInput and IsMouseButtonDown("MiddleButton") then
                    local itemLink = row.item:GetItemLink()
                    if IsShiftKeyDown() then
                        local blackList = CraftSim.DB.OPTIONS:Get("DISENCHANT_BLACKLIST")
                        blackList[itemLink] = true
                        CraftSim.DB.OPTIONS:Save("DISENCHANT_BLACKLIST", blackList)
                        CraftSim.DEBUG:SystemPrint(f.l("CraftSim Disenchant: ") ..
                            "Permanently blacklisted: " .. itemLink)
                    else
                        CraftSim.DISENCHANT.sessionBlacklist[itemLink] = true
                        CraftSim.DEBUG:SystemPrint(f.l("CraftSim Disenchant: ") ..
                            "Blacklisted for session: " .. itemLink)
                    end
                    CraftSim.DISENCHANT.UI:UpdateUI()
                else
                    CraftSim.DISENCHANT.UI:UpdateDisenchantButton(row.item)
                end
            end
        },
        columnOptions = {
            {
                label = "Item",
                width = 205,
                headerScale = 0.9,
                sortFunc = function(rowA, rowB)
                    return rowA.item:GetItemLink() < rowB.item:GetItemLink()
                end,
                resizable = true,
                resizeCallback = function(itemCol, newWidth)
                    itemCol.text:SetWidth(newWidth)
                end,
                customSortArrowOffsetX = 0,
            },
            {
                label = "#",
                width = 25,
                headerScale = 0.9,
                sortFunc = function(rowA, rowB)
                    return rowA.count > rowB.count
                end,
                resizable = true,
                resizeCallback = function(countCol, newWidth)
                    countCol.text:SetWidth(newWidth)
                end,
                customSortArrowOffsetX = 5
            },
        },
        rowConstructor = function(columns, row)
            local itemCol = columns[1]
            local countCol = columns[2]
            itemCol.text = GGUI.Text {
                parent = itemCol,
                anchorParent = itemCol,
                anchorA = "LEFT", anchorB = "LEFT",
                justifyOptions = { align = "LEFT", type = "H" },
                fixedWidth = itemCol:GetWidth(),
                scale = 0.9,
            }

            countCol.text = GGUI.Text {
                parent = countCol,
                anchorParent = countCol,
                anchorA = "CENTER", anchorB = "CENTER",
                fixedWidth = countCol:GetWidth(),
                scale = 0.9,
            }
        end
    }

    content.disenchantButton = GGUI.Button {
        globalName = "CraftSimDisenchantButton",
        parent = content,
        anchorParent = content,
        anchorA = "BOTTOM", anchorB = "BOTTOM",
        offsetY = 8,
        sizeY = 30,
        label = L("DISENCHANT_BUTTON"),
        adjustWidth = true,
        width = 5,
        macro = true,
        macroText = "",
    }
end

function CraftSim.DISENCHANT.UI:UpdateUI()
    local items, countMap = CraftSim.DISENCHANT:LoadItems()
    local content = CraftSim.DISENCHANT.frame.content --[[@as CraftSim.DISENCHANT.FRAME.CONTENT]]
    content.itemList:Remove()

    GUTIL:ContinueOnAllItemsLoaded(items, function()
        -- filter out any items that are not disenchantable aka are no equipment

        local items = CraftSim.DISENCHANT:FilterItems(items)

        for _, item in ipairs(items) do
            local itemLink = item:GetItemLink()
            content.itemList:Add(function(row, columns)
                local itemCol = columns[1]
                local countCol = columns[2]

                row.item = item
                row.count = countMap[itemLink] or 0

                itemCol.text:SetText(itemLink)
                countCol.text:SetText(row.count)

                row.tooltipOptions = {
                    anchorParent = row.frame,
                    anchor = "ANCHOR_RIGHT",
                    itemLink = itemLink,
                }
            end)
        end

        content.itemList.selectedRow = nil
        content.itemList:UpdateDisplay()
        content.itemList:SelectRow(1)

        self:UpdateDisenchantButton(content.itemList.selectedRow and content.itemList.selectedRow.item)
    end)
end

function CraftSim.DISENCHANT.UI:ShowAndLoad()
    local frame = CraftSim.DISENCHANT.frame
    self:UpdateUI()
    frame:Show()
end

---@param item ItemMixin
function CraftSim.DISENCHANT.UI:UpdateDisenchantButton(item)
    local content = CraftSim.DISENCHANT.frame.content --[[@as CraftSim.DISENCHANT.FRAME.CONTENT]]
    if item then
        local itemLocation = item:GetItemLocation()
        local bag, slot = itemLocation:GetBagAndSlot()
        content.disenchantButton:SetMacroText("/cast Disenchant\n/use " .. bag .. " " .. slot)
        content.disenchantButton:SetEnabled(true)
    else
        content.disenchantButton:SetMacroText("")
        content.disenchantButton:SetEnabled(false)
    end
end
