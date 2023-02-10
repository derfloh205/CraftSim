_, CraftSim = ...

---@class CraftSim.NodeData
---@field nodeID number
---@field rank number
---@field nodeName? string
---@field description? string
---@field affectsRecipe boolean
---@field professionStats CraftSim.ProfessionStats
---@field idMapping CraftSim.IDMapping
---@field parentNode? CraftSim.NodeData
---@field nodeRules CraftSim.NodeRule[]
---@field childNodes CraftSim.NodeData[]

CraftSim.NodeData = CraftSim.Object:extend()

---@param recipeData CraftSim.RecipeData
---@param nodeID number
function CraftSim.NodeData:new(recipeData, nodeID)
    self.nodeID = nodeID
    self.professionStats = CraftSim.ProfessionsStats(self.nodeID)


end