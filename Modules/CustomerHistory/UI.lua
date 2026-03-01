---@class CraftSim
local CraftSim = select(2, ...)

local GGUI = CraftSim.GGUI
local GUTIL = CraftSim.GUTIL

---@class CraftSim.CUSTOMER_HISTORY.UI
CraftSim.CUSTOMER_HISTORY.UI = {}

---@type CraftSim.CUSTOMER_HISTORY.FRAME
CraftSim.CUSTOMER_HISTORY.frame = nil

local print = CraftSim.DEBUG:RegisterDebugID("Modules.CustomerHistory.UI")
local f = GUTIL:GetFormatter()

---@param LOCALIZATION_ID CraftSim.LOCALIZATION_IDS
local function L(LOCALIZATION_ID)
    return CraftSim.LOCAL:GetText(LOCALIZATION_ID)
end

function CraftSim.CUSTOMER_HISTORY.UI:Init()
    local sizeX = 1050
    local sizeY = 500
    ---@class CraftSim.CUSTOMER_HISTORY.FRAME : GGUI.Frame
    CraftSim.CUSTOMER_HISTORY.frame = GGUI.Frame({
        parent = ProfessionsFrame,
        anchorParent = ProfessionsFrame,
        sizeX = sizeX,
        sizeY = sizeY,
        frameID = CraftSim.CONST.FRAMES.CUSTOMER_HISTORY,
        title = L(CraftSim.CONST.TEXT.CUSTOMER_HISTORY_TITLE),
        collapseable = true,
        closeable = true,
        moveable = true,
        backdropOptions = CraftSim.CONST.DEFAULT_BACKDROP_OPTIONS,
        onCloseCallback = CraftSim.CONTROL_PANEL:HandleModuleClose("MODULE_CUSTOMER_HISTORY"),
        frameTable = CraftSim.INIT.FRAMES,
        frameConfigTable = CraftSim.DB.OPTIONS:Get("GGUI_CONFIG"),
        frameStrata = CraftSim.CONST.MODULES_FRAME_STRATA,
        raiseOnInteraction = true,
        frameLevel = CraftSim.UTIL:NextFrameLevel()
    })

    local function createContent(frame)
        frame:Hide()

        ---@type GGUI.FrameList.ColumnOption[]
        local columnOptionsCustomerList = {
            {
                label = L(CraftSim.CONST.TEXT.CUSTOMER_HISTORY_CUSTOMER_HEADER),
                width = 150,
            },
            {
                label = L(CraftSim.CONST.TEXT.CUSTOMER_HISTORY_TOTAL_TIP_HEADER),
                width = 100,
            }
        }


        frame.content.customerHistoryOptionsButton = GGUI.Button {
            parent = frame.content,
            anchorPoints = { { anchorParent = frame.title.frame, anchorA = "LEFT", anchorB = "RIGHT", offsetX = 5 } },
            cleanTemplate = true,
            buttonTextureOptions = CraftSim.CONST.BUTTON_TEXTURE_OPTIONS.OPTIONS,
            sizeX = 20, sizeY = 20,
            clickCallback = function(_, _)
                MenuUtil.CreateContextMenu(UIParent, function(ownerRegion, rootDescription)
                    local enabledCB = rootDescription:CreateCheckbox(
                        f.bb("Enable ") .. f.gold("History Recording"),
                        function()
                            return CraftSim.DB.OPTIONS:Get("CUSTOMER_HISTORY_ENABLED")
                        end, function()
                            local value = CraftSim.DB.OPTIONS:Get(
                                "CUSTOMER_HISTORY_ENABLED")
                            CraftSim.DB.OPTIONS:Save("CUSTOMER_HISTORY_ENABLED",
                                not value)
                        end)

                    local patronOrderCB = rootDescription:CreateCheckbox(
                        "Record " .. f.bb("Patron Orders"),
                        function()
                            return CraftSim.DB.OPTIONS:Get("CUSTOMER_HISTORY_RECORD_PATRON_ORDERS")
                        end, function()
                            local value = CraftSim.DB.OPTIONS:Get(
                                "CUSTOMER_HISTORY_RECORD_PATRON_ORDERS")
                            CraftSim.DB.OPTIONS:Save("CUSTOMER_HISTORY_RECORD_PATRON_ORDERS",
                                not value)
                        end)

                    local removeCustomersCategory = rootDescription:CreateButton("Remove Customers")

                    local autoRemovalCategory = removeCustomersCategory:CreateButton("Auto Removal")

                    GUTIL:CreateReuseableMenuUtilContextMenuFrame(autoRemovalCategory, function(frame)
                        frame.label = GGUI.Text {
                            parent = frame,
                            anchorPoints = { { anchorParent = frame, anchorA = "LEFT", anchorB = "LEFT" } },
                            text = L(CraftSim.CONST.TEXT.CUSTOMER_HISTORY_PURGE_DAYS_INPUT_LABEL),
                            justifyOptions = { type = "H", align = "LEFT" },
                        }
                        frame.input = GGUI.NumericInput {
                            parent = frame, anchorParent = frame,
                            sizeX = 30, sizeY = 25, offsetX = 5,
                            anchorA = "RIGHT", anchorB = "RIGHT",
                            initialValue = CraftSim.DB.OPTIONS:Get("CUSTOMER_HISTORY_AUTO_PURGE_INTERVAL"),
                            borderAdjustWidth = 1.32,
                            allowDecimals = true,
                            onNumberValidCallback = function(input)
                                CraftSim.DB.OPTIONS:Save("CUSTOMER_HISTORY_AUTO_PURGE_INTERVAL",
                                    tonumber(input.currentValue))
                            end,
                        }

                        ---@type GGUI.TooltipOptions
                        frame.tooltipOptions = {
                            owner = frame,
                            anchor = "ANCHOR_TOP",
                            text = L(CraftSim.CONST.TEXT.CUSTOMER_HISTORY_PURGE_DAYS_INPUT_TOOLTIP),
                        }

                        GGUI:SetTooltipsByTooltipOptions(frame, frame)
                    end, 200, 25, "CUSTOMER_HISTORY_OPTIONS_AUTO_PURGE_INTERVAL_INPUT")

                    GUTIL:CreateReuseableMenuUtilContextMenuFrame(removeCustomersCategory, function(frame)
                        frame.label = GGUI.Text {
                            parent = frame,
                            anchorPoints = { { anchorParent = frame, anchorA = "LEFT", anchorB = "LEFT" } },
                            text = "Tip Threshold: ",
                            justifyOptions = { type = "H", align = "LEFT" },
                        }
                        frame.input = GGUI.CurrencyInput {
                            parent = frame, anchorParent = frame,
                            sizeX = 100, sizeY = 25, offsetX = 5,
                            anchorA = "RIGHT", anchorB = "RIGHT",
                            borderAdjustWidth = 0.95,
                            debug = true,
                            initialValue = CraftSim.DB.OPTIONS:Get("CUSTOMER_HISTORY_REMOVAL_TIP_THRESHOLD"),
                            tooltipOptions = {
                                owner = frame,
                                anchor = "ANCHOR_TOP",
                                text = f.white("Format: " .. GUTIL:FormatMoney(1000000, false, nil, false, false)),
                            },
                            onValueValidCallback = function()
                                local tipValue = frame.input.total
                                CraftSim.DB.OPTIONS:Save("CUSTOMER_HISTORY_REMOVAL_TIP_THRESHOLD",
                                    tonumber(tipValue))
                            end,
                        }
                    end, 200, 25, "CUSTOMER_HISTORY_OPTIONS_REMOVAL_TIP_THRESHOLD_INPUT")

                    removeCustomersCategory:CreateButton(f.l("Remove below Threshold"), function()
                        CraftSim.CUSTOMER_HISTORY:PurgeCustomers(CraftSim.DB.OPTIONS:Get(
                            "CUSTOMER_HISTORY_REMOVAL_TIP_THRESHOLD"))
                    end)

                    removeCustomersCategory:CreateButton(f.r("Remove All Customers"), function()
                        MenuUtil.CreateContextMenu(UIParent, function(ownerRegion, rootDescription)
                            rootDescription:CreateTitle(f.r("Remove ALL Customer Data?"))
                            rootDescription:CreateButton("Yes", function()
                                CraftSim.CUSTOMER_HISTORY:PurgeCustomers(math.huge)
                            end)
                            rootDescription:CreateButton("No", function() end)
                        end)
                    end)
                end)
            end
        }

        frame.content.customerList = GGUI.FrameList({
            sizeY = 370,
            columnOptions = columnOptionsCustomerList,
            parent = frame.content,
            anchorParent = frame.content,
            anchorA = "TOPLEFT",
            anchorB = "TOPLEFT",
            offsetY = -80,
            offsetX = 30,
            rowHeight = 20,
            showBorder = true,
            rowConstructor = function(columns)
                local customerColumn = columns[1]
                local tipColumn = columns[2]
                local removeColumn = columns[3]

                local rowContentScale = 0.9

                customerColumn.text = GGUI.Text({
                    parent = customerColumn,
                    anchorParent = customerColumn,
                    anchorA = "LEFT",
                    anchorB = "LEFT",
                    offsetX = 2,
                    justifyOptions = { type = "H", align = "LEFT" },
                    text = "",
                    scale = rowContentScale
                })
                tipColumn.text = GGUI.Text({
                    parent = tipColumn,
                    anchorParent = tipColumn,
                    anchorA = "RIGHT",
                    anchorB = "RIGHT",
                    offsetX = -10,
                    justifyOptions = { type = "H", align = "RIGHT" },
                    text = CraftSim.UTIL:FormatMoney(0),
                    scale = rowContentScale
                })
            end,
            selectionOptions = {
                selectionCallback = function(row)
                    local customerHistory = row.customerHistory --[[@as CraftSim.DB.CustomerHistory]]
                    if IsMouseButtonDown("RightButton") then
                        MenuUtil.CreateContextMenu(UIParent, function(ownerRegion, rootDescription)
                            rootDescription:CreateTitle(customerHistory.customer)
                            rootDescription:CreateButton("Delete Customer", function()
                                CraftSim.CUSTOMER_HISTORY:RemoveCustomer(row, customerHistory)
                            end)
                        end)
                    else
                        CraftSim.CUSTOMER_HISTORY.UI:OnCustomerSelected(customerHistory)
                    end
                end
            }
        })


        frame.content.totalAmountLabel = GGUI.Text({
            parent = frame.content,
            anchorParent = frame.content.customerList.frame,
            anchorA = "BOTTOMLEFT",
            anchorB = "BOTTOMLEFT",
            offsetY = -20,
            offsetX = 10,
            text = L(CraftSim.CONST.TEXT.CUSTOMER_HISTORY_TOTAL_AMOUNT),
            scale = 1,
        })

        frame.content.totalAmountText = GGUI.Text({
            parent = frame.content,
            anchorParent = frame.content.customerList.frame,
            anchorA = "BOTTOMRIGHT",
            anchorB = "BOTTOMRIGHT",
            offsetY = -20,
            offsetX = -15,
            text = "-",
            scale = 1,
            justifyOptions = { type = "H", align = "RIGHT" }
        })

        frame.content.customerName = GGUI.Text({
            parent = frame.content,
            anchorParent = frame.content,
            anchorA = "TOP",
            anchorB = "TOP",
            text = "",
            offsetX = 80,
            offsetY = -37,
            scale = 1.5,
        })

        frame.content.whisperButton = GGUI.Button {
            parent = frame.content, anchorParent = frame.content.customerName.frame,
            label = L(CraftSim.CONST.TEXT.CUSTOMER_HISTORY_WHISPER_BUTTON_LABEL), adjustWidth = true,
            anchorA = "LEFT", anchorB = "RIGHT", offsetX = 10,
        }

        local chatMessageColumnWidth = 450

        ---@type GGUI.FrameList.ColumnOption[]
        local columnOptionsChatFrame = {
            {
                label = "", -- Timestamp
                width = 100,
                justifyOptions = { type = "H", align = "RIGHT" }
            },
            {
                label = "", -- Sender
                width = 100,
                justifyOptions = { type = "H", align = "RIGHT" }
            },
            {
                label = "", -- Message
                width = chatMessageColumnWidth,
                justifyOptions = { type = "H", align = "LEFT" }
            }
        }

        frame.content.chatMessageList = GGUI.FrameList({
            parent = frame.content,
            anchorParent = frame.content.customerName.frame,
            anchorA = "TOP",
            anchorB = "BOTTOM",
            offsetY = -8,
            columnOptions = columnOptionsChatFrame,
            showBorder = true,
            rowHeight = 20,
            sizeY = 200,
            rowConstructor = function(columns)
                local timeColumn = columns[1]
                local senderColumn = columns[2]
                local messageColumn = columns[3]

                timeColumn.text = GGUI.Text({
                    parent = timeColumn,
                    anchorParent = timeColumn,
                    anchorA = "RIGHT",
                    anchorB = "RIGHT",
                    justifyOptions = { type = "H", align = "RIGHT" },
                    text = L(CraftSim.CONST.TEXT.CUSTOMER_HISTORY_CHAT_MESSAGE_TIMESTAMP)
                })
                senderColumn.text = GGUI.Text({
                    parent = senderColumn,
                    anchorParent = senderColumn,
                    anchorA = "RIGHT",
                    anchorB = "RIGHT",
                    justifyOptions = { type = "H", align = "RIGHT" },
                    text = L(CraftSim.CONST.TEXT.CUSTOMER_HISTORY_CHAT_MESSAGE_SENDER)
                })
                messageColumn.text = GGUI.Text({
                    parent = messageColumn,
                    anchorParent = messageColumn,
                    anchorA = "TOPLEFT",
                    anchorB = "TOPLEFT",
                    justifyOptions = { type = "HV", alignH = "LEFT", alignV = "CENTER" },
                    text = L(CraftSim.CONST.TEXT.CUSTOMER_HISTORY_CHAT_MESSAGE_MESSAGE),
                    fixedWidth = chatMessageColumnWidth,
                    offsetY = -4.1,
                })

                GGUI:EnableHyperLinksForFrameAndChilds(messageColumn)
            end
        })

        ---@type GGUI.FrameList.ColumnOption[]
        local columnOptionsCraftList = {
            {
                label = L(CraftSim.CONST.TEXT.CUSTOMER_HISTORY_CRAFT_HISTORY_DATE_HEADER), -- Timestamp
                width = 100,
                justifyOptions = { type = "H", align = "LEFT" }
            },
            {
                label = L(CraftSim.CONST.TEXT.CUSTOMER_HISTORY_CRAFT_HISTORY_RESULT_HEADER), -- Result
                width = 250,
                justifyOptions = { type = "H", align = "RIGHT" }
            },
            {
                label = L(CraftSim.CONST.TEXT.CUSTOMER_HISTORY_CRAFT_HISTORY_TIP_HEADER), -- Tip
                width = 100,
                justifyOptions = { type = "H", align = "RIGHT" }
            },
            {
                label = L(CraftSim.CONST.TEXT.CUSTOMER_HISTORY_CRAFT_HISTORY_CUSTOMER_REAGENTS_HEADER),
                width = 150,
                justifyOptions = { type = "H", align = "CENTER" }
            },
            {
                label = L(CraftSim.CONST.TEXT.CUSTOMER_HISTORY_CRAFT_HISTORY_CUSTOMER_NOTE_HEADER), -- Customer Note
                width = 50,
                justifyOptions = { type = "H", align = "CENTER" }
            }
        }

        frame.content.craftList = GGUI.FrameList({
            parent = frame.content,
            anchorParent = frame.content.chatMessageList.frame,
            anchorA = "TOPLEFT",
            anchorB = "BOTTOMLEFT",
            offsetY = -30,
            columnOptions = columnOptionsCraftList,
            showBorder = true,
            rowHeight = 20,
            sizeY = 158,
            rowConstructor = function(columns)
                local timeColumn = columns[1]
                local resultColumn = columns[2]
                local tipColumn = columns[3]
                local reagentColumn = columns[4]
                local noteColumn = columns[5]

                timeColumn.text = GGUI.Text({
                    parent = timeColumn,
                    anchorParent = timeColumn,
                    anchorA = "LEFT",
                    anchorB = "LEFT",
                    justifyOptions = { type = "H", align = "LEFT" },
                    text = L(CraftSim.CONST.TEXT.CUSTOMER_HISTORY_CRAFT_LIST_TIMESTAMP)
                })
                resultColumn.text = GGUI.Text({
                    parent = resultColumn,
                    anchorParent = resultColumn,
                    anchorA = "RIGHT",
                    anchorB = "RIGHT",
                    justifyOptions = { type = "H", align = "LEFT" },
                    text = L(CraftSim.CONST.TEXT.CUSTOMER_HISTORY_CRAFT_LIST_RESULTLINK)
                })
                tipColumn.text = GGUI.Text({
                    parent = tipColumn,
                    anchorParent = tipColumn,
                    anchorA = "RIGHT",
                    anchorB = "RIGHT",
                    justifyOptions = { type = "H", align = "RIGHT" },
                    text = L(CraftSim.CONST.TEXT.CUSTOMER_HISTORY_CRAFT_LIST_TIP),
                })
                reagentColumn.icon = GGUI.HelpIcon({
                    parent = reagentColumn,
                    anchorParent = reagentColumn,
                    text = L(CraftSim.CONST.TEXT
                        .CUSTOMER_HISTORY_CRAFT_LIST_REAGENTS),
                })

                noteColumn.icon = GGUI.HelpIcon {
                    parent = noteColumn, anchorParent = noteColumn, text = L(CraftSim.CONST.TEXT.CUSTOMER_HISTORY_CRAFT_LIST_SOMENOTE),
                }

                GGUI:EnableHyperLinksForFrameAndChilds(resultColumn)
            end
        })
    end

    createContent(CraftSim.CUSTOMER_HISTORY.frame)
end

function CraftSim.CUSTOMER_HISTORY.UI:UpdateDisplay()
    CraftSim.CUSTOMER_HISTORY.UI:UpdateCustomerHistoryList()
end

function CraftSim.CUSTOMER_HISTORY.UI:UpdateCustomerHistoryList()
    local customerList = CraftSim.CUSTOMER_HISTORY.frame.content.customerList --[[@as GGUI.FrameList]]
    customerList:Remove()
    local customerHistoryData = CraftSim.DB.CUSTOMER_HISTORY:GetAll()
    local totalAmount = 0

    for _, customerHistory in pairs(customerHistoryData) do
        if customerHistory.totalTip and customerHistory.totalTip > 0 then
            customerList:Add(
                function(row)
                    local columns = row.columns
                    local customerColumn = columns[1]
                    local tipColumn = columns[2]
                    row.customerHistory = customerHistory
                    customerColumn.text:SetText(customerHistory.customer)
                    tipColumn.text:SetText(CraftSim.UTIL:FormatMoney(customerHistory.totalTip or 0))
                end)

            totalAmount = totalAmount + (customerHistory.totalTip or 0)
        end
    end

    CraftSim.CUSTOMER_HISTORY.frame.content.totalAmountText:SetText(CraftSim.UTIL:FormatMoney(totalAmount))

    customerList:UpdateDisplay(
        function(rowA, rowB)
            if rowA and not rowB then
                return true
            end
            if rowB and not rowA then
                return false
            end
            local totalTipA = rowA.customerHistory.totalTip or 0;
            local totalTipB = rowB.customerHistory.totalTip or 0;
            return totalTipA > totalTipB;
        end)

    if not customerList.selectedRow then
        customerList:SelectRow(1)
    end

    if CraftSim.DB.CUSTOMER_HISTORY:Count() == 0 then
        CraftSim.CUSTOMER_HISTORY.frame.content.customerName:Hide()
        CraftSim.CUSTOMER_HISTORY.frame.content.whisperButton:Hide()
        CraftSim.CUSTOMER_HISTORY.frame.content.craftList:Hide()
        CraftSim.CUSTOMER_HISTORY.frame.content.chatMessageList:Hide()
    else
        CraftSim.CUSTOMER_HISTORY.frame.content.customerName:Show()
        CraftSim.CUSTOMER_HISTORY.frame.content.whisperButton:Show()
        CraftSim.CUSTOMER_HISTORY.frame.content.craftList:Show()
        CraftSim.CUSTOMER_HISTORY.frame.content.chatMessageList:Show()
    end
end

---@param customerHistory CraftSim.DB.CustomerHistory
function CraftSim.CUSTOMER_HISTORY.UI:OnCustomerSelected(customerHistory)
    ---@type GGUI.Text
    local customerName = CraftSim.CUSTOMER_HISTORY.frame.content.customerName
    local fullName = customerHistory.customer .. "-" .. customerHistory.realm
    customerName:SetText(customerHistory.customer .. "-" .. customerHistory.realm)
    CraftSim.CUSTOMER_HISTORY.frame.content.whisperButton.clickCallback = function()
        CraftSim.CUSTOMER_HISTORY:StartWhisper(fullName)
    end

    CraftSim.CUSTOMER_HISTORY.UI:UpdateCustomerChatHistory(customerHistory.customer, customerHistory.chatHistory)
    CraftSim.CUSTOMER_HISTORY.UI:UpdateCustomerCraftHistory(customerHistory.craftHistory)
end

---@param craftHistory CraftSim.DB.CustomerHistory.Craft
function CraftSim.CUSTOMER_HISTORY.UI:UpdateCustomerCraftHistory(craftHistory)
    ---@type GGUI.FrameList
    local craftList = CraftSim.CUSTOMER_HISTORY.frame.content.craftList

    craftList:Remove()

    ---@type CraftSim.DB.CustomerHistory.Craft[]
    local craftsSorted = CraftSim.GUTIL:Sort(craftHistory,
        ---@param craftA CraftSim.DB.CustomerHistory.Craft
        ---@param craftB CraftSim.DB.CustomerHistory.Craft
        function(craftA, craftB)
            return craftA.timestamp > craftB.timestamp
        end)

    for _, craft in pairs(craftsSorted) do
        craftList:Add(function(row)
            local columns = row.columns
            local timeColumn = columns[1]
            local resultColumn = columns[2]
            local tipColumn = columns[3]
            local reagentColumn = columns[4]
            local noteColumn = columns[5]

            timeColumn.text:SetText(CraftSim.CUSTOMER_HISTORY.UI:GetNormalizedDayString(craft.timestamp))

            resultColumn.text:SetText(tostring(craft.itemLink))
            tipColumn.text:SetText(CraftSim.UTIL:FormatMoney(craft.tip, true))

            noteColumn.icon:SetText(craft.customerNotes)
            noteColumn.icon:SetEnabled(#craft.customerNotes > 0)

            local reagentItems = CraftSim.GUTIL:Map(craft.reagents,
                -- Skip currency reagents
                function(r) return r.reagentInfo.reagent.itemID and Item:CreateFromItemID(r.reagentInfo.reagent.itemID) or nil end)
            CraftSim.GUTIL:ContinueOnAllItemsLoaded(reagentItems, function()
                local reagentText = ""
                for _, reagent in pairs(craft.reagents) do
                    if reagent.reagentInfo.reagent.itemID then
                        local item = Item:CreateFromItemID(reagent.reagentInfo.reagent.itemID)
                        local qualityID = CraftSim.GUTIL:GetQualityIDFromLink(item:GetItemLink())
                        local qualityIcon = ""
                        local itemIcon = CraftSim.GUTIL:IconToText(item:GetItemIcon(), 20, 20)
                        if qualityID then
                            qualityIcon = CraftSim.GUTIL:GetQualityIconString(qualityID, 20, 20, 0, 0)
                        end
                        reagentText = reagentText .. itemIcon .. qualityIcon .. " x " .. reagent.reagentInfo.quantity .. "\n"
                    end
                end
                reagentColumn.icon:SetText(reagentText)
            end)
        end)
    end

    craftList:UpdateDisplay()
end

---@param chatHistory CraftSim.DB.CustomerHistory.ChatMessage
function CraftSim.CUSTOMER_HISTORY.UI:UpdateCustomerChatHistory(customer, chatHistory)
    ---@type GGUI.FrameList
    local chatMessageList = CraftSim.CUSTOMER_HISTORY.frame.content.chatMessageList

    chatMessageList:Remove()

    ---@type CraftSim.DB.CustomerHistory.ChatMessage[]
    local chatMessagesReversed = CraftSim.GUTIL:Sort(chatHistory,
        ---@param chatMessageA CraftSim.DB.CustomerHistory.ChatMessage
        ---@param chatMessageB CraftSim.DB.CustomerHistory.ChatMessage
        function(chatMessageA, chatMessageB)
            return chatMessageA.timestamp < chatMessageB.timestamp
        end)

    -- insert headers per day
    ---@type (CraftSim.DB.CustomerHistory.ChatMessage | {day:string})[]
    local chatMessages = {}
    local currentDate = nil
    for _, chatMessage in pairs(chatMessagesReversed) do
        local dayString = CraftSim.CUSTOMER_HISTORY.UI:GetNormalizedDayString(chatMessage.timestamp)
        if currentDate ~= dayString then
            table.insert(chatMessages, {
                day = dayString
            })
            currentDate = dayString
        end
        table.insert(chatMessages, chatMessage)
    end

    for _, chatMessage in pairs(chatMessages) do
        chatMessageList:Add(function(row)
            local columns = row.columns
            local timeColumn = columns[1]
            local senderColumn = columns[2]
            local messageColumn = columns[3]

            if chatMessage.day then
                timeColumn.text:SetText(f.whisper("[" .. chatMessage.day .. "]"))
                senderColumn.text:SetText("")
                messageColumn.text:SetText("")
            else
                timeColumn.text:SetText(f.whisper("[" ..
                    CraftSim.CUSTOMER_HISTORY.UI:GetNormalizedTimeString(chatMessage.timestamp) .. "]"))

                local sender = "[" .. tostring(customer) .. "]: "

                if chatMessage.fromPlayer then
                    sender = L(CraftSim.CONST.TEXT.CUSTOMER_HISTORY_CHAT_MESSAGE_YOU)
                end

                senderColumn.text:SetText(f.whisper(tostring(sender)))
                messageColumn.text:SetText(f.whisper(tostring(chatMessage.content)))
            end

            -- adjust row height
            ---@type Frame
            local rowFrame = row.frame
            ---@type SimpleFontString
            local messageText = messageColumn.text.frame
            local messageHeight = math.max(20, messageText:GetStringHeight())
            rowFrame:SetHeight(messageHeight)
        end)
    end

    chatMessageList:UpdateDisplay()
    RunNextFrame(function()
        chatMessageList:ScrollDown()
    end)
end

---@param timestamp number
---@return string
function CraftSim.CUSTOMER_HISTORY.UI:GetNormalizedDayString(timestamp)
    local date = date("*t", timestamp)
    return string.format("%02d.%02d.%02d", date.day, date.month, date.year)
end

---@param timestamp number
---@return string
function CraftSim.CUSTOMER_HISTORY.UI:GetNormalizedTimeString(timestamp)
    local date = date("*t", timestamp)
    return string.format("%02d:%02d:%02d", date.hour, date.min, date.sec)
end
