


---@class GUTIL
local GUTIL = LibStub:NewLibrary("GUTIL", 1)

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

-- to concat lists together (behaviour unpredictable with tables that have strings or not ordered numbers as indices)
function GUTIL:Concat(tableList)
  local finalList = {}
  for _, currentTable in pairs(tableList) do
      for _, item in pairs(currentTable) do
          table.insert(finalList, item)
      end
  end
  return finalList
end

function GUTIL:ToSet(t)
  local set = {}

  for k, v in pairs(t) do
      if not tContains(set, v) then
          table.insert(set, v)
      end
  end

  return set
end

-- options: subTable, isTableList
-- subTable: a subproperty that is a table that is to be mapped instead of the table itself
-- isTableList: if the table only consists of other tables, map each subTable instead
function GUTIL:Map(t, mapFunc, options)
  options = options or {}
  local mapped = {}
  if not options.subTable then
      for k, v in pairs(t) do
          if options.isTableList then
              if type(v) ~= "table" then
                  error("GUTIL.Map: t contains a nontable element")
              end
              for subK, subV in pairs(v) do
                  local mappedValue = mapFunc(subV, subK)
                  if not mappedValue then
                      error("GUTIL.Map: Did you forget to return in mapFunc?")
                  end
                  table.insert(mapped, mappedValue)
              end
          else
              local mappedValue = mapFunc(v, k)
              if mappedValue then
                  table.insert(mapped, mappedValue)
              end
          end
      end
      return mapped
  else
      for k, v in pairs(t) do
          if not v[options.subTable] or type(v[options.subTable]) ~= "table" then
              print("GUTIL.Map: given options.subTable is not existing or no table: " .. tostring(v[options.subTable]))
          else
              for subK, subV in pairs(v[options.subTable]) do
                  local mappedValue = mapFunc(subV, subK)
                  if not mappedValue then
                      error("GUTIL.Map: Did you forget to return in mapFunc?")
                  end
                  table.insert(mapped, mappedValue)
              end
          end
      end
      return mapped
  end
end

function GUTIL:Filter(t, filterFunc)
  local filtered = {}
  for k, v in pairs(t) do
      if filterFunc(v) then
          table.insert(filtered, v)
      end
  end
  return filtered
end

function GUTIL:CreateRegistreeForEvents(events)
  local registree = CreateFrame("Frame", nil)
  registree:SetScript("OnEvent", function(self, event, ...) self[event](self, ...) end)
  for _, event in pairs(events) do
      registree:RegisterEvent(event)
  end
  return registree
end

---Validate if a string is of format 100g50s10c
---@param moneyString string
---@return boolean valid
function GUTIL:ValidateMoneyString(moneyString)
  -- check if the string matches the pattern
  if not string.match(moneyString, "^%d*g?%d*s?%d*c?$") then
      return false
  end

  -- check if the string contains at least one of g, s, or c
  if not string.match(moneyString, "[gsc]") then
      return false
  end

  -- check if the string contains multiple g, s, or c
  if string.match(moneyString, "g.*g") then
      return false
  end
  if string.match(moneyString, "s.*s") then
      return false
  end
  if string.match(moneyString, "c.*c") then
      return false
  end

  -- check if it ends incorrectly
  if string.match(moneyString, "%d$") then
      return false
  end

  -- check if the string contains invalid characters
  if string.match(moneyString, "[^%dgsc]") then
      return false
  end

  -- all checks passed, the string is valid
  return true
end

---Returns the given copper value as gold, silver and copper seperated, as string formated or as numbers
---@param copperValue number
---@param formatString? boolean
---@return string | number
---@return number?
---@return number?
function GUTIL:GetMoneyValuesFromCopper(copperValue, formatString)
    local gold = GUTIL:Round(copperValue/10000)
    local silver = GUTIL:Round(copperValue/100000)
    local copper = GUTIL:Round(copperValue/10000000)

    if not formatString then
        return tonumber(gold) or 0, tonumber(silver) or 0, tonumber(copper) or 0
    else
        return gold .. "g " .. silver .. "s " .. copper .. "c"
    end
end

---Colorizes a Text based on a color in GUTIL.COLORS (hex with alpha prefix)
---@param text string
---@param color string
---@return string colorizedText
function GUTIL:ColorizeText(text, color)
  local startLine = "\124c"
  local endLine = "\124r"
  return startLine .. color .. text .. endLine
end

GUTIL.COLORS = {
  GREEN = "ff00FF00",
  RED = "ffFF0000",
  DARK_BLUE = "ff2596be",
  BRIGHT_BLUE = "ff00ccff",
  LEGENDARY = "ffff8000",
  EPIC = "ffa335ee",
  RARE = "ff0070dd",
  UNCOMMON = "ff1eff00",
  GREY = "ff9d9d9d",
  ARTIFACT = "ffe6cc80",
  GOLD = "fffffc01",
  SILVER = "ffdadada",
  COPPER = "ffc9803c",
  PATREON = "ffff424D",
}

function GUTIL:GetPercentRelativeTo(value, hundredPercentValue)
  local oneP = hundredPercentValue / 100
      local percent = GUTIL:Round(value / oneP, 0)

      if oneP == 0 then
          percent = 0
      end
      return percent
end

function GUTIL:FormatMoney(copperValue, useColor, percentRelativeTo)
  local absValue = abs(copperValue)
  local minusText = ""
  local color = GUTIL.COLORS.GREEN
  local percentageText = ""

  if percentRelativeTo then
      percentageText = " (" .. GUTIL:GetPercentRelativeTo(copperValue, percentRelativeTo) .. "%)"
  end

  if copperValue < 0 then
      minusText = "-"
      color = GUTIL.COLORS.RED
  end

  if useColor then
      return GUTIL:ColorizeText(minusText .. GetCoinTextureString(absValue, 10) .. percentageText, color)
  else
      return minusText .. GetCoinTextureString(absValue, 10) .. percentageText
  end
end

function GUTIL:Round(number, decimals)
  return tonumber((("%%.%df"):format(decimals)):format(number))
end

function GUTIL:GetItemIDByLink(hyperlink)
  local _, _, foundID = string.find(hyperlink, "item:(%d+)")
  return tonumber(foundID)
end

---@param itemList ItemMixin[]
---@param callback function
function GUTIL:ContinueOnAllItemsLoaded(itemList, callback) 
  local itemsToLoad = #itemList
      if itemsToLoad == 0 then
          callback()
      end
  local itemLoaded = function ()
    itemsToLoad = itemsToLoad - 1

    if itemsToLoad <= 0 then
      callback()
    end
  end

  if itemsToLoad >= 1 then
    for _, itemToLoad in pairs(itemList) do
      itemToLoad:ContinueOnItemLoad(itemLoaded)
    end
  end
end

function GUTIL:EquipItemByLink(link)
	for bag=BANK_CONTAINER, NUM_BAG_SLOTS+NUM_BANKBAGSLOTS do
		for slot=1,C_Container.GetContainerNumSlots(bag) do
			local item = C_Container.GetContainerItemLink(bag, slot)
			if item and item == link then
				if CursorHasItem() or CursorHasMoney() or CursorHasSpell() then ClearCursor() end
				C_Container.PickupContainerItem(bag, slot)
				AutoEquipCursorItem()
				return true
			end
		end
	end
end

function GUTIL:isItemSoulbound(itemID)
  return select(14, GetItemInfo(itemID)) == 1
end

--> GGUI or keep here?
function GUTIL:GetQualityIconString(qualityID, sizeX, sizeY, offsetX, offsetY)
  return CreateAtlasMarkup("Professions-Icon-Quality-Tier" .. qualityID, sizeX, sizeY, offsetX, offsetY)
end

function GUTIL:Count(t, func)
  local count = 0
  for _, v in pairs(t) do
      if func and func(v) then
          count = count + 1
      elseif not func then
          count = count + 1
      end
  end

  return count
end

function GUTIL:Sort(t, compFunc)
  local sorted = {}
  for _, item in pairs(t) do
      if sorted[1] == nil then
          table.insert(sorted, item)
      else
          local inserted = false
          for sortedIndex, sortedItem in pairs(sorted) do
              if compFunc(item, sortedItem) then
                  table.insert(sorted, sortedIndex, item)
                  inserted = true
                  break
              end
          end

          if not inserted then
              table.insert(sorted, item)
          end
      end
  end

  return sorted
end

function GUTIL:Fold(t, foldFunction, startAtZero)
  local foldedValue = nil
  if #t < 2 and not startAtZero then
      return t[1]
  elseif #t < 1 and startAtZero then
      return t[0]
  end

  local startIndex = 1
  if startAtZero then
      startIndex = 0
  end
  for index = startIndex, #t, 1 do
      if foldedValue == nil then
          foldedValue = foldFunction(t[startIndex], t[startIndex + 1])
      elseif index < #t then
          foldedValue = foldFunction(foldedValue, t[index+1])
      end
  end

  return foldedValue
end

function GUTIL:IconToText(iconPath, height, width) 
  if not width then
      return "\124T" .. iconPath .. ":" .. height .. "\124t"
  else
      return "\124T" .. iconPath .. ":" .. height .. ":" .. width .. "\124t"
  end
end

function GUTIL:ValidateNumberString(str, min, max, allowDecimals)
  local num = tonumber(str)
  if num == nil then
    return false -- Not a valid number
  end
  if not allowDecimals and num ~= math.floor(num) then
    return false -- Decimals not allowed
  end
  if (min and num < min) or (max and num > max) then
    return false -- Outside specified range
  end
  return true -- Valid number within range
end