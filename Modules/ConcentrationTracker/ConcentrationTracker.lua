---@class CraftSim
local CraftSim = select(2, ...)

---@class CraftSim.CONCENTRATION_TRACKER
CraftSim.CONCENTRATION_TRACKER = {}

---@type table<number, CraftSim.ConcentrationData>
CraftSim.CONCENTRATION_TRACKER.ConcentrationDataCache = {}

---@return CraftSim.ConcentrationData?
function CraftSim.CONCENTRATION_TRACKER:GetCurrentConcentrationData()
    local skillLineID = C_TradeSkillUI.GetProfessionChildSkillLineID()

    local expansionID = CraftSim.UTIL:GetExpansionIDBySkillLineID(skillLineID)

    -- if not shown profession's expac dont show
    if not expansionID or expansionID < CraftSim.CONST.EXPANSION_IDS.DRAGONFLIGHT then return end

    local cached = CraftSim.CONCENTRATION_TRACKER.ConcentrationDataCache[skillLineID]
    if cached and cached.currencyID then
        cached:Update()
        return cached
    end

    local currencyID = C_TradeSkillUI.GetConcentrationCurrencyID(skillLineID)
    if currencyID and skillLineID > 0 and C_ProfSpecs.SkillLineHasSpecialization(skillLineID) then
        local concentrationData = CraftSim.ConcentrationData(currencyID)
        concentrationData:Update()
        -- save in crafterDB
        CraftSim.DB.CRAFTER:SaveCrafterConcentrationData(CraftSim.UTIL:GetPlayerCrafterUID(),
            C_TradeSkillUI.GetProfessionInfoBySkillLineID(skillLineID).profession,
            CraftSim.UTIL:GetExpansionIDBySkillLineID(skillLineID),
            concentrationData)
        CraftSim.CONCENTRATION_TRACKER.ConcentrationDataCache[skillLineID] = concentrationData
        return concentrationData
    end

    return nil
end
