---@class CraftSim
local CraftSim = select(2, ...)

local GUTIL = CraftSim.GUTIL
local f = GUTIL:GetFormatter()

---@class CraftSim.SLASH
CraftSim.SLASH = {}

local Logger = CraftSim.DEBUG:RegisterLogger("CraftSim.SLASH")

---@type table<string, fun(self: CraftSim.SLASH, args:table)>
CraftSim.SLASH.commands = {}

function CraftSim.SLASH:Init()
    SLASH_CRAFTSIM1 = "/craftsim"
    SLASH_CRAFTSIM2 = "/crafts"
    SLASH_CRAFTSIM3 = "/simcc"
    SLASH_CRAFTSIM4 = "/cs"
    SLASH_CRAFTSIM5 = "/csim"

    self:InitCommands()

    SlashCmdList["CRAFTSIM"] = function(input)
        if not input then
            return
        end

        -- parse arguments from input, consider itemlinks and quotes
        local command, arguments = GUTIL:ParseSlashCommandInput(input)

        local commandCallback = CraftSim.SLASH.commands[command]
        if commandCallback then
            commandCallback(self, arguments)
            return
        else
            -- open options if any other command or no command is given
            Settings.OpenToCategory(CraftSim.OPTIONS.category:GetID())
        end
    end
end

function CraftSim.SLASH:InitCommands()
    -- based on function name pattern CMD_<command> in the SLASH.CRAFTSIM handler

    for key, value in pairs(CraftSim.SLASH) do
        if type(value) == "function" and strfind(key, "CMD_") == 1 then
            local command = strsub(key, 5)
            self.commands[command] = value
        end
    end
end

-- COMMANDS --
function CraftSim.SLASH:CMD_pricedebug()
    local priceDebug = CraftSim.DB.OPTIONS:Get(CraftSim.CONST.GENERAL_OPTIONS.PRICE_DEBUG)
    priceDebug = not priceDebug
    CraftSim.DB.OPTIONS:Save(CraftSim.CONST.GENERAL_OPTIONS.PRICE_DEBUG, priceDebug)
    print("Craftsim: Toggled price debug mode: " .. tostring(priceDebug))

    if priceDebug then
        CraftSim.PRICE_API = CraftSimNO_PRICE_API
    else
        CraftSim.PRICE_APIS:InitAvailablePriceAPI()
    end
end

function CraftSim.SLASH:CMD_patchnotes()
    CraftSim.PATCH_NOTES:ShowPatchNotes(true)
end

CraftSim.SLASH.CMD_news = CraftSim.SLASH.CMD_patchnotes

function CraftSim.SLASH:CMD_debug()
    CraftSim.DEBUG.frame:Show()
end

function CraftSim.SLASH:CMD_export(args)
    local arg1 = args[1]
    if arg1 == "recipeids" then
        local recipeIDs = CraftSim.UTIL:ExportRecipeIDsForExpacCSV()
        CraftSim.UTIL:ShowTextCopyBox(recipeIDs)
    elseif CraftSim.MODULES.recipeData then
        local json = CraftSim.MODULES.recipeData:GetJSON()
        CraftSim.UTIL:ShowTextCopyBox(json)
    end
end

function CraftSim.SLASH:CMD_openprofession(arg1)
    if ProfessionsFrame:IsVisible() then
        return
    end

    -- get professions for current character
    local crafterUID = CraftSim.UTIL:GetPlayerCrafterUID()
    local professions = CraftSim.DB.CRAFTER:GetProfessions(crafterUID)

    for _, profession in ipairs(professions) do
        local nearFocus = C_TradeSkillUI.IsNearProfessionSpellFocus(profession)
        Logger:LogDebug("Checking profession " .. profession .. " for focus: " .. tostring(nearFocus))
        if nearFocus then
            Logger:LogDebug("Opening profession " .. profession .. " because of focus")
            C_TradeSkillUI.OpenTradeSkill(C_TradeSkillUI.GetProfessionSkillLineID(profession))
            return
        end
    end

    -- fallback to first profession if not stated closest
    if arg1 == "closest" and professions[1] then
        Logger:LogDebug("Opening profession " .. professions[1] .. " as fallback")
        C_TradeSkillUI.OpenTradeSkill(C_TradeSkillUI.GetProfessionSkillLineID(professions[1]))
    end
end

function CraftSim.SLASH:CMD_bruto()
    -- dont do it if mailbox or AH is open
    if MailFrame:IsVisible() or AuctionHouseFrame:IsVisible() then
        return
    end

    local tradersBrutoID = 2265
    local bfaBrutoID = 1039

    Logger:LogDebug("Trying to summon Brutosaur")
    local IsMounted = IsMounted()
    local canSummonTradersBruto = C_MountJournal.GetMountUsabilityByID(tradersBrutoID, true)
    local canSummonBFABruto = C_MountJournal.GetMountUsabilityByID(bfaBrutoID, true)
    Logger:LogDebug("IsMounted: {mounted}, tradersBruto: {tB}, bfaBruto: {bfa}",
        IsMounted, canSummonTradersBruto, canSummonBFABruto)

    if not IsMounted then
        if canSummonTradersBruto then
            Logger:LogDebug("Summoning Traders Bruto")
            C_MountJournal.SummonByID(tradersBrutoID)
        elseif canSummonBFABruto then
            Logger:LogDebug("Summoning BFA Bruto")
            C_MountJournal.SummonByID(bfaBrutoID)
        end
    end
end

function CraftSim.SLASH:CMD_craftqueue(args)
    local arg1 = args[1]
    if arg1 == "craftnext" then
        if ProfessionsFrame:IsVisible() and CraftSim.CRAFTQ.frame.content.queueTab.content.craftNextButton.clickCallback then
            CraftSim.CRAFTQ.frame.content.queueTab.content.craftNextButton.clickCallback()
        end
    elseif arg1 == "queuelists" then
        CraftSim.CRAFT_LISTS:QueueSelectedLists()
    elseif arg1 == "queuefirstcrafts" then
        CraftSim.CRAFTQ:QueueFirstCrafts()
    elseif arg1 == "queueworkorders" then
        CraftSim.CRAFTQ:QueueWorkOrders()
    elseif arg1 == "clear" then
        CraftSim.CRAFTQ:ClearAll()
    elseif arg1 == "createshoppinglist" then
        CraftSim.CRAFTQ:CreateAuctionatorShoppingList()
    end
end

function CraftSim.SLASH:CMD_resetdb()
    if CraftSimDB then
        wipe(CraftSimDB)
    end
    C_UI.Reload()
end

function CraftSim.SLASH:CMD_quickbuy()
    CraftSim.CRAFTQ:AuctionatorQuickBuy()
end

function CraftSim.SLASH:CMD_collectmail()
    if MailFrame:IsVisible() then
        OpenAllMail:StartOpening()
    end
end

function CraftSim.SLASH:CMD_disenchant()
    CraftSim.DISENCHANT.UI:ShowAndLoad()
end

function CraftSim.SLASH:CMD_put(args)
    CraftSim.UTIL:MoveItemIntoBank(args[1], tonumber(args[2]))
end

function CraftSim.SLASH:CMD_get(args)
    CraftSim.UTIL:MoveItemIntoInventory(args[1], tonumber(args[2]))
end

function CraftSim.SLASH:CMD_help()
    local c = f.l("/craftsim ")
    CraftSim.DEBUG:SystemPrint(c .. f.bb("news") .. " - Show the latest patch notes")
    CraftSim.DEBUG:SystemPrint(c ..
        f.bb("debug") .. " - Open the debug window")
    CraftSim.DEBUG:SystemPrint(c ..
        f.bb("export recipeids") ..
        " - Export all recipeIDs of the current expansion in a CSV format in a copy box")
    CraftSim.DEBUG:SystemPrint(c ..
        f.bb("export") .. " - Export the currently visible recipe data as JSON in a copy box")
    CraftSim.DEBUG:SystemPrint(c ..
        f.r("resetdb") .. " - Reset the addon's database and reload the UI")
    CraftSim.DEBUG:SystemPrint(c ..
        f.g("quickbuy") .. " - spam to quickly buy contents of the craftsim shopping list")
    CraftSim.DEBUG:SystemPrint(c ..
        f.bb("disenchant") .. " - Open the disenchanting helper")
    CraftSim.DEBUG:SystemPrint(c ..
        f.bb("bruto") .. " - Summon the Traders bruto mount")
    CraftSim.DEBUG:SystemPrint(c ..
        f.bb("collectmail") .. " - Collect all mail")
    CraftSim.DEBUG:SystemPrint(c ..
        f.bb("openprofession [closest]") ..
        " - Opens the profession window (closest -> only the one where you are standing)")
    CraftSim.DEBUG:SystemPrint(c ..
        f.bb("put <[itemlink]|itemID|searchTerm>") .. " - Move an item into the bank or warbank, if open")
    CraftSim.DEBUG:SystemPrint(c ..
        f.bb("get <[itemlink]|itemID|searchTerm>") ..
        " - Move an item from the bank or warbank into the inventory, if open")
    CraftSim.DEBUG:SystemPrint(c ..
        f.bb(" craftqueue ") .. "[command] - Various commands to interact with the craft queue:")
    CraftSim.DEBUG:SystemPrint(
        f.bb("    craftnext") .. " - Craft next recipe")
    CraftSim.DEBUG:SystemPrint(f.bb("    queuelists") .. " - Queue all selected craft lists in the craft queue")
    CraftSim.DEBUG:SystemPrint(
        f.bb("    queuefirstcrafts") .. " - Queue the first crafts of the last open profession")
    CraftSim.DEBUG:SystemPrint(
        f.bb("    queueworkorders") .. " - Queue work orders for open profession")
    CraftSim.DEBUG:SystemPrint(f.bb("    clear") .. " - Clear all crafts from the craft queue")
    CraftSim.DEBUG:SystemPrint(
        f.bb("    createshoppinglist") .. " - Create an Auctionator shopping list")
end
