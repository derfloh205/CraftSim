---@class CraftSim
local CraftSim = select(2, ...)

CraftSim.LOCAL = {}
CraftSim.LOCAL.LOCAL_CLIENT = {}
CraftSim.LOCAL.LOCAL_EN = {}

function CraftSim.LOCAL:Init()
    local currentLocale = GetLocale()
    CraftSim.LOCAL.LOCAL_EN = CraftSim.LOCAL_EN:GetData() -- always load english locals for fallback translations
    if currentLocale == CraftSim.CONST.LOCALES.EN then
        CraftSim.LOCAL.LOCAL_CLIENT = CraftSim.LOCAL.LOCAL_EN
    elseif currentLocale == CraftSim.CONST.LOCALES.DE then
        CraftSim.LOCAL.LOCAL_CLIENT = CraftSim.LOCAL_DE:GetData()
    elseif currentLocale == CraftSim.CONST.LOCALES.IT then
        CraftSim.LOCAL.LOCAL_CLIENT = CraftSim.LOCAL_IT:GetData()
    elseif currentLocale == CraftSim.CONST.LOCALES.RU then
        CraftSim.LOCAL.LOCAL_CLIENT = CraftSim.LOCAL_RU:GetData()
    elseif currentLocale == CraftSim.CONST.LOCALES.PT then
        CraftSim.LOCAL.LOCAL_CLIENT = CraftSim.LOCAL_PT:GetData()
    elseif currentLocale == CraftSim.CONST.LOCALES.ES then
        CraftSim.LOCAL.LOCAL_CLIENT = CraftSim.LOCAL_ES:GetData()
    elseif currentLocale == CraftSim.CONST.LOCALES.FR then
        CraftSim.LOCAL.LOCAL_CLIENT = CraftSim.LOCAL_FR:GetData()
    elseif currentLocale == CraftSim.CONST.LOCALES.MX then
        CraftSim.LOCAL.LOCAL_CLIENT = CraftSim.LOCAL_MX:GetData()
    elseif currentLocale == CraftSim.CONST.LOCALES.KO then
        CraftSim.LOCAL.LOCAL_CLIENT = CraftSim.LOCAL_KO:GetData()
    elseif currentLocale == CraftSim.CONST.LOCALES.TW then
        CraftSim.LOCAL.LOCAL_CLIENT = CraftSim.LOCAL_TW:GetData()
    elseif currentLocale == CraftSim.CONST.LOCALES.CN then
        CraftSim.LOCAL.LOCAL_CLIENT = CraftSim.LOCAL_CN:GetData()
    else
        error("CraftSim Error: Client not supported: " .. tostring(currentLocale))
    end
end

---@param ID CraftSim.LOCALIZATION_IDS
function CraftSim.LOCAL:GetText(ID)
    local localizedText = CraftSim.LOCAL.LOCAL_CLIENT[ID]

    if not localizedText then
        local englishtext = CraftSim.LOCAL.LOCAL_EN[ID]
        return englishtext -- default to english
    else
        return localizedText
    end
end

function CraftSim.LOCAL:TranslateStatName(statName)
    -- translate the variable name to the display name
    if statName == "multicraft" then
        return CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.STAT_MULTICRAFT)
    elseif statName == "resourcefulness" then
        return CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.STAT_RESOURCEFULNESS)
    elseif statName == "craftingspeed" then
        return CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.STAT_CRAFTINGSPEED)
    elseif statName == "skill" then
        return CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.STAT_SKILL)
    elseif statName == "multicraftExtraItemsFactor" then
        return CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.STAT_MULTICRAFT_BONUS)
    elseif statName == "resourcefulnessExtraItemsFactor" then
        return CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.STAT_RESOURCEFULNESS_BONUS)
    elseif statName == "craftingspeedBonusFactor" then
        return CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.STAT_CRAFTINGSPEED_BONUS)
    elseif statName == "phialExperimentationChanceFactor" then
        return CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.STAT_PHIAL_EXPERIMENTATION)
    elseif statName == "potionExperimentationChanceFactor" then
        return CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.STAT_POTION_EXPERIMENTATION)
    end
end
