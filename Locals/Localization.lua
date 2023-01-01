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
    elseif currentLocale == CraftSim.CONST.LOCALES.ES then
        CraftSim.LOCAL.LOCAL = CraftSim.LOCAL_ES
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