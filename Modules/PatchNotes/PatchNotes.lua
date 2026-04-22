---@class CraftSim
local CraftSim = select(2, ...)

local GUTIL = CraftSim.GUTIL
local f = GUTIL:GetFormatter()

---@class CraftSim.PATCH_NOTES : CraftSim.Module
CraftSim.PATCH_NOTES = {}

CraftSim.MODULES:RegisterModule("MODULE_PATCH_NOTES", CraftSim.PATCH_NOTES)

CraftSim.PATCH_NOTES.GITHUB_COLLABS = {
    AVILENE = "https://github.com/avilene",
    CODEPOET = "https://github.com/ergh99",
    NETOUSS = "https://github.com/netouss",
}

local Logger = CraftSim.DEBUG:RegisterLogger("PatchNotes")
local function newP(v) return f.l("\nPatch Notes " .. v .. "\n") end
local function collab(gl) return f.a .. "- Thanks to " .. f.bb(gl) end

---@param itemMap table<string, ItemMixin>
function CraftSim.PATCH_NOTES:GetPatchNotes(itemMap)
    local supporterListUpdate = f.p .. f.patreon("Supporter List Update ") ..
        CraftSim.MEDIA:GetAsTextIcon(CraftSim.MEDIA.IMAGES.PIXEL_HEART, 0.15)
    local patchNotes = {
        f.bb("Hello and thank you for using CraftSim! ( You are awesome! )\n"),
        newP("26.1.5"),
        f.PG .. f.bb("Concentration Tracker"),
        f.a .. "- Show Moxie Count for Character on hover",
        f.p .. "DB2 Data Update for 12.0.5.67088",
        collab(CraftSim.PATCH_NOTES.GITHUB_COLLABS.AVILENE),
        newP("26.1.3"),
        f.PG .. f.bb("Recipe Info"),
        f.a .. "- Added new info option to display: " .. f.g("Profit Per Quality"),
        f.a .. "- Same value like the old price details column",
        f.a .. "  (SellPriceofQuality*(0.95)-CurrentCraftingCosts)",
        f.a .. "- Enabled per default, can be disabled in Module Options",
        f.p .. "Fixed help command lua error",
        newP("26.1.2"),
        f.p .. "Fixed fresh load lua error",
        newP("26.1.1"),
        f.pg .. f.bb("Craft Lists"),
        f.a .. "- When setting a target quality, lower qualities will not queue",
        collab("https://github.com/chris-merritt"),
        f.pg .. "Fixed item amounts in leather moxie bag",
        collab(CraftSim.PATCH_NOTES.GITHUB_COLLABS.AVILENE),
        f.pg .. "Fixed Syndicator Inventory Source Gear Quality recognition",
        f.a .. "- TSM might still struggle",
        f.p .. "Debug Changes",
        f.a .. "Logs are now viewable with the LogSink addon",
        newP("26.1.0"),
        f.PG .. f.g("New Moxie Auto Value Setting"),
        f.a .. "- In CraftQueue -> Work Order Options -> Patron Orders",
        f.a .. "- Either manually or automatically determine moxie value",
        f.a .. "- Automatic will use community data for value calculation",
        f.a .. "- Added tooltips to Moxie Profession Bags to show value",
        collab(CraftSim.PATCH_NOTES.GITHUB_COLLABS.AVILENE),
        f.PG .. f.bb("CraftQueue"),
        f.a .. "- Reworked Queue Craft Lists queuing logic",
        f.a .. "- Added CraftList Restock Option to include alts inventory",
        f.a .. "  (Only works if selected inventory source supports that)",
        f.a .. "- Moved Auto Shopping List Creation to Craft Queue Options",
        f.PG .. f.bb("Recipe Scan"),
        f.a .. "- Inventory Column now uses your configured inventory source",
        f.a .. "- Added option to include alt inventory for column info",
        f.a .. "- Reagent Allocation Option now offers target quality setting",
        f.pg .. f.bb("General"),
        f.a .. "- Added option to show/hide new tutorial buttons",
        newP("26.0.1"),
        f.PG .. f.bb("Craft Queue"),
        f.a .. "- Added option to autoqueue work orders when opening",
        f.a .. "  a profession table for the first time after login",
        f.p .. "Fixed a loading error when Auctionator is not loaded",
        newP("26.0.0"),
        f.PG .. f.g("Outsourced Inventory Tracking to dedicated addons"),
        f.a .. "- For now, " .. f.bb("TSM") .. " and " .. f.bb("Syndicator") .. " are supported",
        f.a .. "- If none of them are loaded, only the current character",
        f.a .. "  will be considered",
        f.PG .. f.bb("Recipe Scan"),
        f.a .. "- Added option to only scan specific craftlists",
        f.a .. "- This will use their individual optimization options",
        f.PG .. f.bb("Customer History"),
        f.a .. "- Removed chat message recording and deleted old msg data",
        f.a .. "- Reason for this are taint and data amount issues",
        f.a .. "- For chat message history refer to dedicated addons like WIM",
        f.PG .. "Added support for blizzard native " .. f.g("Info Help Panels"),
        f.a .. "- First rollout was to craftqueue module",
        f.pg .. f.bb("Craft Lists"),
        f.a .. "- Added tooltips to show their configured options",
        f.a .. "- Added tooltips to show result item",
    }

    return table.concat(patchNotes, "\n")
end

---@param patchNotesText string
function CraftSim.PATCH_NOTES:GetChecksum(patchNotesText)
    local checksum = 0
    local checkSumBitSize = 256

    patchNotesText = string.gsub(patchNotesText, "|cff%x+|Hitem:.+|h|r", "[LINK]")

    for i = 1, #patchNotesText do
        checksum = (checksum + string.byte(patchNotesText, i)) % checkSumBitSize
    end

    return checksum
end

---@param patchNotesText string
---@return string | nil newChecksum
function CraftSim.PATCH_NOTES:IsPatchNotesUpdate(patchNotesText)
    local newChecksum = CraftSim.PATCH_NOTES:GetChecksum(patchNotesText)
    local oldChecksum = CraftSim.DB.OPTIONS:Get(CraftSim.CONST.GENERAL_OPTIONS.PATCH_NOTES_CHECKSUM)

    if newChecksum ~= oldChecksum then
        return newChecksum
    end

    return nil
end

---@param force boolean
---@async
function CraftSim.PATCH_NOTES:ShowPatchNotes(force)
    local itemMap = {
        enchantingRod = Item:CreateFromItemID(224116),
    }

    CraftSim.GUTIL:ContinueOnAllItemsLoaded(CraftSim.GUTIL:Map(itemMap, function(i) return i end), function()
        local patchNotesText = CraftSim.PATCH_NOTES:GetPatchNotes(itemMap)
        local newChecksum = CraftSim.PATCH_NOTES:IsPatchNotesUpdate(patchNotesText)
        if newChecksum == nil and (not force) then
            return
        end

        CraftSim.DB.OPTIONS:Save(CraftSim.CONST.GENERAL_OPTIONS.PATCH_NOTES_CHECKSUM, newChecksum)

        local infoFrame = CraftSim.PATCH_NOTES.frame
        local showInfo = infoFrame and infoFrame.showInfo
        if not infoFrame or type(showInfo) ~= "function" then
            Logger:LogWarning("Patch Notes info frame not initialized")
            return
        end

        infoFrame:SetSize(CraftSim.CONST.infoBoxSizeX, CraftSim.CONST.infoBoxSizeY)
        infoFrame.originalX = CraftSim.CONST.infoBoxSizeX
        infoFrame.originalY = CraftSim.CONST.infoBoxSizeY
        showInfo(patchNotesText)
    end)
end
