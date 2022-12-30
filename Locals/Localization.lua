addonName, CraftSim = ...

CraftSim.LOCAL = {}

function CraftSim.LOCAL:Init()
    local currentLocale = GetLocale()
    print("locale: " .. tostring(currentLocale))
    if currentLocale == "enEN" then
        CraftSim.LOCAL.LOCAL = CraftSim.LOCAL_EN
    elseif currentLocale == "deDE" then
        CraftSim.LOCAL.LOCAL = CraftSim.LOCAL_DE
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