---@class CraftSim
local CraftSim = select(2, ...)

local GUTIL = CraftSim.GUTIL
local f = GUTIL:GetFormatter()

---@class CraftSim.CONCENTRATION_TRACKER : CraftSim.Module
CraftSim.CONCENTRATION_TRACKER = {}

CraftSim.MODULES:RegisterModule("MODULE_CONCENTRATION_TRACKER", CraftSim.CONCENTRATION_TRACKER)

GUTIL:RegisterCustomEvents(CraftSim.CONCENTRATION_TRACKER, {
    "CRAFTSIM_PROFESSION_INITIALIZED",
})

---@type table<number, CraftSim.ConcentrationData>
CraftSim.CONCENTRATION_TRACKER.ConcentrationDataCache = {}

---@param crafterUID CrafterUID
---@param profession Enum.Profession
function CraftSim.CONCENTRATION_TRACKER:BlacklistData(crafterUID, profession)
    local concentrationTrackerBlacklist = CraftSim.DB.OPTIONS:Get("CONCENTRATION_TRACKER_BLACKLIST")
    concentrationTrackerBlacklist[crafterUID] = concentrationTrackerBlacklist[crafterUID] or {}
    tinsert(concentrationTrackerBlacklist[crafterUID], profession)
end

function CraftSim.CONCENTRATION_TRACKER:ClearBlacklist()
    local concentrationTrackerBlacklist = CraftSim.DB.OPTIONS:Get("CONCENTRATION_TRACKER_BLACKLIST")
    wipe(concentrationTrackerBlacklist)
end

---@param crafterUID CrafterUID
---@param profession Enum.Profession?
---@param expansionID CraftSim.EXPANSION_IDS?
function CraftSim.CONCENTRATION_TRACKER:SnapshotMoxieForProfession(crafterUID, profession, expansionID)
    if not profession or not expansionID then
        return
    end
    local moxieCurrencyID = CraftSim.CONST.MOXIE_CURRENCY_ID_BY_PROFESSION[profession]
    if not moxieCurrencyID then
        return
    end
    local info = C_CurrencyInfo.GetCurrencyInfo(moxieCurrencyID)
    local quantity = (info and info.quantity) or 0
    CraftSim.DB.CRAFTER:SaveCrafterMoxieData(crafterUID, profession, expansionID, quantity)
end

---@param crafterUID CrafterUID
---@param profession Enum.Profession
---@param expansionID CraftSim.EXPANSION_IDS
---@return number? quantity nil when unknown for other characters
---@return boolean hasProfessionMoxie false when this profession has no Manu Moxie currency
function CraftSim.CONCENTRATION_TRACKER:GetListRowMoxieQuantity(crafterUID, profession, expansionID)
    local moxieCurrencyID = CraftSim.CONST.MOXIE_CURRENCY_ID_BY_PROFESSION[profession]
    if not moxieCurrencyID then
        return nil, false
    end
    if crafterUID == CraftSim.UTIL:GetPlayerCrafterUID() then
        local info = C_CurrencyInfo.GetCurrencyInfo(moxieCurrencyID)
        local liveQuantity = (info and info.quantity) or 0
        local storedQuantity = CraftSim.DB.CRAFTER:GetCrafterMoxieData(crafterUID, profession, expansionID)
        if storedQuantity ~= liveQuantity then
            CraftSim.DB.CRAFTER:SaveCrafterMoxieData(crafterUID, profession, expansionID, liveQuantity)
        end
        return liveQuantity, true
    end
    return CraftSim.DB.CRAFTER:GetCrafterMoxieData(crafterUID, profession, expansionID), true
end

---@return CraftSim.ConcentrationData?
function CraftSim.CONCENTRATION_TRACKER:GetCurrentConcentrationData()
    local skillLineID = C_TradeSkillUI.GetProfessionChildSkillLineID()

    local expansionID = CraftSim.UTIL:GetExpansionIDBySkillLineID(skillLineID)

    local playerCrafterUID = CraftSim.UTIL:GetPlayerCrafterUID()
    local professionInfo = C_TradeSkillUI.GetProfessionInfoBySkillLineID(skillLineID)
    local profession = professionInfo and professionInfo.profession

    -- if not shown profession's expac dont show
    if not expansionID or expansionID < CraftSim.CONST.EXPANSION_IDS.DRAGONFLIGHT then return end

    local cached = CraftSim.CONCENTRATION_TRACKER.ConcentrationDataCache[skillLineID]
    if cached and cached.currencyID then
        cached:Update()

        -- update the saved db data always
        CraftSim.DB.CRAFTER:SaveCrafterConcentrationData(playerCrafterUID,
            profession,
            CraftSim.UTIL:GetExpansionIDBySkillLineID(skillLineID),
            cached)
        CraftSim.CONCENTRATION_TRACKER:SnapshotMoxieForProfession(playerCrafterUID, profession, expansionID)

        return cached
    end

    local currencyID = C_TradeSkillUI.GetConcentrationCurrencyID(skillLineID)
    local professionInfo = C_TradeSkillUI.GetProfessionInfoBySkillLineID(skillLineID)
    local professionID = professionInfo and professionInfo.profession
    if currencyID and skillLineID > 0 and C_ProfSpecs.SkillLineHasSpecialization(skillLineID)
        and not CraftSim.CONST.GATHERING_PROFESSIONS[professionID] then
        local concentrationData = CraftSim.ConcentrationData(currencyID)
        concentrationData:Update()
        -- save in crafterDB
        CraftSim.DB.CRAFTER:SaveCrafterConcentrationData(playerCrafterUID,
            profession,
            CraftSim.UTIL:GetExpansionIDBySkillLineID(skillLineID),
            concentrationData)
        CraftSim.CONCENTRATION_TRACKER:SnapshotMoxieForProfession(playerCrafterUID, profession, expansionID)
        CraftSim.CONCENTRATION_TRACKER.ConcentrationDataCache[skillLineID] = concentrationData
        return concentrationData
    end

    return nil
end

---@param concentrationData CraftSim.ConcentrationData
---@return string formattedDate
function CraftSim.CONCENTRATION_TRACKER:GetMaxFormatByFormatMode(concentrationData)
    local formatted = concentrationData:GetFormattedDateMax()
    return f.bb(formatted)
end

function CraftSim.CONCENTRATION_TRACKER:CRAFTSIM_PROFESSION_INITIALIZED()
    self.UI:Update()
end
