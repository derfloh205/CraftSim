---@class CraftSim
local CraftSim = select(2, ...)

local GUTIL = CraftSim.GUTIL

local f = GUTIL:GetFormatter()

---@class CraftSim.SUPPORTERS
CraftSim.SUPPORTERS = CraftSim.SUPPORTERS

---@class CraftSim.SUPPORTERS.UI
CraftSim.SUPPORTERS.UI = {}

function CraftSim.SUPPORTERS.UI:Init()
    local sizeX = 600
    local sizeY = 500

    local frameLevel = CraftSim.UTIL:NextFrameLevel()

    local frame = CraftSim.GGUI.Frame({
        parent = ProfessionsFrame,
        anchorParent = UIParent,
        sizeX = sizeX,
        sizeY = sizeY,
        frameID = CraftSim.CONST.FRAMES.SUPPORTERS,
        title = CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CONTROL_PANEL_SUPPORTERS_BUTTON),
        collapseable = true,
        closeable = true,
        moveable = true,
        backdropOptions = CraftSim.CONST.DEFAULT_BACKDROP_OPTIONS,
        frameTable = CraftSim.INIT.FRAMES,
        frameConfigTable = CraftSim.DB.OPTIONS:Get("GGUI_CONFIG"),
        frameStrata = CraftSim.CONST.MODULES_FRAME_STRATA,
        raiseOnInteraction = true,
        frameLevel = frameLevel
    })

    local function createContent(frame)
        frame:Hide()
        frame.content.description = CraftSim.GGUI.Text({
            parent = frame.content,
            anchorParent = frame.content,
            anchorA = "TOP",
            anchorB = "TOP",
            offsetY = -40,
            text =
                CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.SUPPORTERS_DESCRIPTION)
        })

        frame.content.donateBox = CraftSim.FRAME:CreateInput(
            nil, frame.content, frame.content.description.frame, "TOP", "BOTTOM", 0, -40, 250, 30,
            CraftSim.CONST.DISCORD_INVITE_URL, function()
                -- do not let the player remove the link
                frame.content.donateBox:SetText(CraftSim.CONST.DISCORD_INVITE_URL)
            end)
        frame.content.donateBox:SetScale(0.75)
        frame.content.donateBoxLabel = CraftSim.FRAME:CreateText(
            f.patreon(CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.SUPPORTERS_DESCRIPTION_2)), frame.content,
            frame.content.donateBox, "BOTTOM", "TOP", 0, 0, 1)

        frame.content.supportersList = CraftSim.GGUI.FrameList({
            parent = frame.content,
            anchorParent = frame.content.donateBox,
            offsetY = -30,
            anchorA = "TOP",
            anchorB = "BOTTOM",
            sizeY = 350,
            rowHeight = 60,
            showBorder = true,
            columnOptions = {
                {
                    label = CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.SUPPORTERS_DATE),
                    width = 100,
                },
                {
                    label = CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.SUPPORTERS_SUPPORTER),
                    width = 100,
                },
                {
                    label = CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.SUPPORTERS_MESSAGE),
                    width = 300,
                },
            },
            rowConstructor = function(columns)
                local dateColumn = columns[1]
                local nameColumn = columns[2]
                local messageColumn = columns[3]

                ---@type GGUI.Text | GGUI.Widget
                dateColumn.text = CraftSim.GGUI.Text({
                    parent = dateColumn,
                    anchorParent = dateColumn,
                    text = "",
                    justifyOptions = { type = "H", align = "LEFT" },
                    fixedWidth = dateColumn:GetWidth(),
                })
                ---@type GGUI.Text | GGUI.Widget
                nameColumn.text = CraftSim.GGUI.Text({
                    parent = nameColumn,
                    anchorParent = nameColumn,
                    text = "",
                    justifyOptions = { type = "H", align = "LEFT" },
                    fixedWidth = nameColumn:GetWidth(),
                })
                ---@type GGUI.Text | GGUI.Widget
                messageColumn.text = CraftSim.GGUI.Text({
                    parent = messageColumn,
                    anchorParent = messageColumn,
                    text = "",
                    justifyOptions = { type = "H", align = "LEFT" },
                    fixedWidth = messageColumn:GetWidth(),
                })
            end
        })

        table.foreach(CraftSim.SUPPORTERS:GetList(), function(_, supporter)
            frame.content.supportersList:Add(function(row)
                local dateColumn = row.columns[1]
                local nameColumn = row.columns[2]
                local messageColumn = row.columns[3]

                dateColumn.text:SetText(supporter.date)
                nameColumn.text:SetText(supporter.name)
                messageColumn.text:SetText(supporter.message)
            end)
        end)

        frame.content.supportersList:UpdateDisplay()
    end

    createContent(frame)
end
