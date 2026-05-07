---@class CraftSim
local CraftSim = select(2, ...)

--- Snapshot of player-only inputs for precraft checks (shared across all queue rows for one evaluation pass).
---@class CraftSim.PrecraftUserContext : CraftSim.CraftSimObject
CraftSim.PrecraftUserContext = CraftSim.CraftSimObject:extend()

function CraftSim.PrecraftUserContext:new()
    self.playerCrafterUID = nil ---@type CrafterUID?
    self.playerClassFile = nil ---@type ClassFile?
    self.formConditionMet = true
    self.formFailureReason = nil ---@type string?
    ---@type string?
    self.lastKnownPlayerInputsSignature = nil
end

--- Clear signature so the next Refresh() re-queries APIs (e.g. after shapeshift).
function CraftSim.PrecraftUserContext:Invalidate()
    self.lastKnownPlayerInputsSignature = nil
end

---@param force? boolean When true, skip signature short-circuit (e.g. after Invalidate).
--- Refresh from the live player. No-ops when inputs match the last signature (queue can update often).
function CraftSim.PrecraftUserContext:Refresh(force)
    local uid = CraftSim.UTIL:GetPlayerCrafterUID()
    local classFile = select(2, UnitClass("player"))
    local formToken = ""
    if classFile == "DRUID" then
        formToken = tostring(GetShapeshiftForm())
    end
    local signature = table.concat({ uid, tostring(classFile), formToken }, "\0")

    if not force and self.lastKnownPlayerInputsSignature == signature then
        return
    end
    self.lastKnownPlayerInputsSignature = signature

    self.playerCrafterUID = uid
    self.playerClassFile = classFile

    if classFile ~= "DRUID" then
        self.formConditionMet = true
        self.formFailureReason = nil
        return
    end

    local formID = GetShapeshiftForm()
    self.formConditionMet = formID == 0
    self.formFailureReason = self.formConditionMet and nil or
        (rawget(_G, "ERR_CANT_DO_THAT_WHILE_SHAPESHIFTED") or "Must be in normal form")
end
