_, CraftSim = ...

---@class CraftSim.TopGearResult
CraftSim.TopGearResult = CraftSim.Object:extend()

---@param professionGearSet CraftSim.ProfessionGearSet
---@param averageProfit number
---@param relativeProfit number
---@param relativeStats CraftSim.ProfessionStats
---@param expectedQuality number
---@param expectedQualityUpgrade number
function CraftSim.TopGearResult:new(professionGearSet, averageProfit, relativeProfit, relativeStats, expectedQuality, expectedQualityUpgrade)
    self.relativeStats = relativeStats
    self.professionGearSet = professionGearSet
    self.averageProfit = averageProfit
    self.relativeProfit = relativeProfit
    self.expectedQuality = expectedQuality
    self.expectedQualityUpgrade = expectedQualityUpgrade
end

function CraftSim.TopGearResult:Debug()
    local debugLines = {
        "Average Profit: " .. CraftSim.GUTIL:FormatMoney(self.averageProfit, true),
        "Relative Profit: " .. CraftSim.GUTIL:FormatMoney(self.relativeProfit, true),
        "Relative Profit Exact: " .. self.relativeProfit,
        "ExpectedQuality: " .. self.expectedQuality,
        "ExpectedQualityUpgrade: " .. self.expectedQualityUpgrade,
        "Profession Gear Set:"
    }

    debugLines = CraftSim.GUTIL:Concat({debugLines, self.professionGearSet:Debug()})

    table.insert(debugLines, "Relative Stats:")
    debugLines = CraftSim.GUTIL:Concat({debugLines, self.relativeStats:Debug()})
    return debugLines
end