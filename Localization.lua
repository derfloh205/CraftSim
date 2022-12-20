CraftSimLOC = {}

function CraftSimLOC:Init()
    -- TODO
    CraftSimLOC.LOCAL = CraftSimLOC_EN
end

function CraftSimLOC:GetText(ID)
    local localizedText = CraftSimLOC.LOCAL:GetData()[ID]

    if not localizedText then
        return CraftSimLOC_EN[ID] -- default to english
    else
        return localizedText
    end
end