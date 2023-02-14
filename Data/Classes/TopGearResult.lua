_, CraftSim = ...

---@class CraftSim.TopGearResult
---@field professionGearSet CraftSim.ProfessionGearSet
---@field averageProfit number
---@field relativeProfit number
---@field expectedQuality number
---@field expectedQualityUpgrade number
---@field relativeStats CraftSim.ProfessionStats

CraftSim.TopGearResult = CraftSim.Object:extend()

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
        "Average Profit: " .. CraftSim.UTIL:FormatMoney(self.averageProfit, true),
        "Relative Profit: " .. CraftSim.UTIL:FormatMoney(self.relativeProfit, true),
        "ExpectedQuality: " .. self.expectedQuality,
        "ExpectedQualityUpgrade: " .. self.expectedQualityUpgrade,
        "Profession Gear Set:"
    }

    debugLines = CraftSim.UTIL:Concat({debugLines, self.professionGearSet:Debug()})

    table.insert(debugLines, "Relative Stats:")
    debugLines = CraftSim.UTIL:Concat({debugLines, self.relativeStats:Debug()})
    return debugLines
end