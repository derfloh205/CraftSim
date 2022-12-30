addonName, CraftSim = ...

CraftSim.LOCAL = {}

function CraftSim.LOCAL:Init()
    -- TODO
    CraftSim.LOCAL.LOCAL = CraftSim.LOCAL_EN
end

function CraftSim.LOCAL:GetText(ID)
    local localizedText = CraftSim.LOCAL.LOCAL:GetData()[ID]

    if not localizedText then
        return CraftSim.LOCAL_EN[ID] -- default to english
    else
        return localizedText
    end
end