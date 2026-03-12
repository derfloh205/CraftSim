---@class CraftSim
local CraftSim = select(2, ...)

local GUTIL = CraftSim.GUTIL
local f = GUTIL:GetFormatter()

---@class CraftSim.CONCENTRATION_TRACKER
CraftSim.CONCENTRATION_TRACKER = {}

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
