addonName, CraftSim = ...

CraftSim.LOCAL = {}

function CraftSim.LOCAL:Init()
    local currentLocale = GetLocale()
    if currentLocale == CraftSim.CONST.LOCALES.EN then
        CraftSim.LOCAL.LOCAL = CraftSim.LOCAL_EN
    elseif currentLocale == CraftSim.CONST.LOCALES.DE then
        CraftSim.LOCAL.LOCAL = CraftSim.LOCAL_DE
    elseif currentLocale == CraftSim.CONST.LOCALES.IT then
        CraftSim.LOCAL.LOCAL = CraftSim.LOCAL_IT
    elseif currentLocale == CraftSim.CONST.LOCALES.RU then
        CraftSim.LOCAL.LOCAL = CraftSim.LOCAL_RU
    elseif currentLocale == CraftSim.CONST.LOCALES.PT then
        CraftSim.LOCAL.LOCAL = CraftSim.LOCAL_PT
    elseif currentLocale == CraftSim.CONST.LOCALES.ES then
        CraftSim.LOCAL.LOCAL = CraftSim.LOCAL_ES
    elseif currentLocale == CraftSim.CONST.LOCALES.FR then
        CraftSim.LOCAL.LOCAL = CraftSim.LOCAL_FR
    else
        error("CraftSim Error: Client not supported: " .. tostring(currentLocale)) 
    end
end

function CraftSim.LOCAL:GetText(ID)
    local localizedText = CraftSim.LOCAL.LOCAL:GetData()[ID]

    if not localizedText then
        local englishtext = CraftSim.LOCAL_EN:GetData()[ID]
        return englishtext -- default to english
    else
        return localizedText
    end
end

function CraftSim.LOCAL:TranslateStatName(statName)
    -- translate the variable name to the display name
    if statName == "inspiration" then
        return CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.STAT_INSPIRATION)
    elseif statName == "multicraft" then
        return CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.STAT_MULTICRAFT)
    elseif statName == "resourcefulness" then
        return CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.STAT_RESOURCEFULNESS)
    elseif statName == "craftingspeed" then
        return CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.STAT_CRAFTINGSPEED)
    elseif statName == "skill" then
        return CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.STAT_SKILL)
    elseif statName == "multicraftBonusItemsFactor" then
        return CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.STAT_MULTICRAFT_BONUS)
    elseif statName == "resourcefulnessBonusItemsFactor" then
        return CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.STAT_RESOURCEFULNESS_BONUS)
    elseif statName == "craftingspeedBonusFactor" then
        return CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.STAT_CRAFTINGSPEED_BONUS)
    elseif statName == "inspirationBonusSkillFactor" then
        return CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.STAT_INSPIRATION_BONUS)
    elseif statName == "phialExperimentationChanceFactor" then
        return CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.STAT_PHIAL_EXPERIMENTATION)
    elseif statName == "potionExperimentationChanceFactor" then
        return CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.STAT_POTION_EXPERIMENTATION)
    end
end