

GGUI_GUTIL = {}

local GUTIL = GGUI_GUTIL

--- CLASSICS insert
local Object = {}
Object.__index = Object

GUTIL.Object = Object

function Object:new()
end

function Object:extend()
  local cls = {}
  for k, v in pairs(self) do
    if k:find("__") == 1 then
      cls[k] = v
    end
  end
  cls.__index = cls
  cls.super = self
  setmetatable(cls, self)
  return cls
end


function Object:implement(...)
  for _, cls in pairs({...}) do
    for k, v in pairs(cls) do
      if self[k] == nil and type(v) == "function" then
        self[k] = v
      end
    end
  end
end


function Object:is(T)
  local mt = getmetatable(self)
  while mt do
    if mt == T then
      return true
    end
    mt = getmetatable(mt)
  end
  return false
end


function Object:__tostring()
  return "Object"
end


function Object:__call(...)
  local obj = setmetatable({}, self)
  obj:new(...)
  return obj
end

--- CLASSICS END

if not GUTIL then return end

---Returns an item string from an item link if found
---@param itemLink string
---@return string? itemString
function GUTIL:GetItemStringFromLink(itemLink)
    return select(3, strfind(itemLink, "|H(.+)|h%["))
end

---Returns the quality of the item based on an item link if the item has a quality
---@param itemLink string
---@return number? qualityID
function GUTIL:GetQualityIDFromLink(itemLink)
    local qualityID = string.match(itemLink, "Quality%-Tier(%d+)")
    return tonumber(qualityID)
end

---Returns the tooltip of an item as one string
---@param itemLink string
---@return string text
function GUTIL:GetItemTooltipText(itemLink)
  local tooltipData = C_TooltipInfo.GetHyperlink(itemLink)

  if not tooltipData then
      return ""
  end

  local tooltipText = ""
  for _, line in pairs(tooltipData.lines) do
      local lineText = ""
      for _, arg in pairs(line.args) do
          if arg.stringVal then
              lineText = lineText .. arg.stringVal
          end
      end
      tooltipText = tooltipText .. lineText .. "\n"
  end

  return tooltipText
end

---Finds the first element in the table where findFunc(element) returns true
---@param t any
---@param findFunc any
---@return any? element
---@return any? key
function GUTIL:Find(t, findFunc)
  for k, v in pairs(t) do
      if findFunc(v) then
          return v, k
      end
  end

  return nil
end