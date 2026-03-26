---@class CraftSim
local CraftSim = select(2, ...)

CraftSim.LOCAL_KO = {}

---@return table<CraftSim.LOCALIZATION_IDS, string>
function CraftSim.LOCAL_KO:GetData()
    local f = CraftSim.GUTIL:GetFormatter()
    return {
        -- REQUIRED:
        ["STAT_MULTICRAFT"] = "복수 제작",
        ["STAT_RESOURCEFULNESS"] = "지혜",
        ["STAT_CRAFTINGSPEED"] = "제작 속도",
        ["EQUIP_MATCH_STRING"] = "착용 효과:",
        ["ENCHANTED_MATCH_STRING"] = "마법부여:",
        ["STAT_INGENUITY"] = "독창성",

        -- Details Frame
        ["RECIPE_DIFFICULTY_LABEL"] = "제작 난이도: ",
        ["MULTICRAFT_LABEL"] = "복수 제작: ",
        ["RESOURCEFULNESS_LABEL"] = "지혜: ",
    }
end
