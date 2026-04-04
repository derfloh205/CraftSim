---@class CraftSim
local CraftSim = select(2, ...)

---@class CraftSim.TopGearResult : CraftSim.CraftSimObject
CraftSim.TopGearResult = CraftSim.CraftSimObject:extend()

---@param professionGearSet CraftSim.ProfessionGearSet
---@param averageProfit number
---@param relativeProfit number
---@param relativeStats CraftSim.ProfessionStats
---@param expectedQuality number
---@param expectedQualityUpgrade number
function CraftSim.TopGearResult:new(professionGearSet, averageProfit, relativeProfit, concentrationValue,
                                    relativeConcentrationValue, relativeStats, expectedQuality,
                                    expectedQualityUpgrade)
    self.relativeStats = relativeStats
    self.professionGearSet = professionGearSet
    self.averageProfit = averageProfit
    self.relativeProfit = relativeProfit
    self.concentrationValue = concentrationValue
    self.relativeConcentrationValue = relativeConcentrationValue
    self.expectedQuality = expectedQuality
    self.expectedQualityUpgrade = expectedQualityUpgrade
end

function CraftSim.TopGearResult:Debug()
    local debugLines = {
        "Average Profit: " .. CraftSim.UTIL:FormatMoney(self.averageProfit, true),
        "Relative Profit: " .. CraftSim.UTIL:FormatMoney(self.relativeProfit, true),
        "Relative Profit Exact: " .. self.relativeProfit,
        "ExpectedQuality: " .. self.expectedQuality,
        "ExpectedQualityUpgrade: " .. (self.expectedQualityUpgrade or "none"),
        "Profession Gear Set:"
    }

    debugLines = CraftSim.GUTIL:Concat({ debugLines, self.professionGearSet:Debug() })

    table.insert(debugLines, "Relative Stats:")
    debugLines = CraftSim.GUTIL:Concat({ debugLines, self.relativeStats:Debug() })
    return debugLines
end
