function ExecuteWidgetHandler(object, handler, ...)
  if type(object) ~= "table" or type(object.GetScript) ~= "function" then
    return false
  end
  local func = object:GetScript(handler)
  if type(func) ~= "function" then
    return
  end
  if not pcall(func, object, ...) then
    return false
  end
  return true
end

function SetOwnerSafely(object, owner, anchor, offsetX, offsetY)
  if type(object) ~= "table" or type(object.GetOwner) ~= "function" then
    return
  end
  local currentOwner = object:GetOwner()
  if not currentOwner then
    object:SetOwner(owner, anchor, offsetX, offsetY)
    return true, false, true
  end
  offsetX, offsetY = offsetX or 0, offsetY or 0
  local currentAnchor, currentOffsetX, currentOffsetY = object:GetAnchorType()
  currentOffsetX, currentOffsetY = currentOffsetX or 0, currentOffsetY or 0
  if currentAnchor ~= anchor or (currentOffsetX ~= offsetX and abs(currentOffsetX - offsetX) > 0.01) or (currentOffsetY ~= offsetY and abs(currentOffsetY - offsetY) > 0.01) then
    object:SetOwner(owner, anchor, offsetX, offsetY)
    return true, true, true
  end
  return false, true, currentOwner == owner
end

function IsMaxLevel(level, fallback)
  if level and type(level) == "number" then
    return level >= 60
  end
  return fallback
end

function ExecuteWidgetHandler(object, handler, ...)
  if type(object) ~= "table" or type(object.GetScript) ~= "function" then
    return false
  end
  local func = object:GetScript(handler)
  if type(func) ~= "function" then
    return
  end
  if not pcall(func, object, ...) then
    return false
  end
  return true
end

function SetOwnerSafely(object, owner, anchor, offsetX, offsetY)
  if type(object) ~= "table" or type(object.GetOwner) ~= "function" then
    return
  end
  local currentOwner = object:GetOwner()
  if not currentOwner then
    object:SetOwner(owner, anchor, offsetX, offsetY)
    return true, false, true
  end
  offsetX, offsetY = offsetX or 0, offsetY or 0
  local currentAnchor, currentOffsetX, currentOffsetY = object:GetAnchorType()
  currentOffsetX, currentOffsetY = currentOffsetX or 0, currentOffsetY or 0
  if currentAnchor ~= anchor or (currentOffsetX ~= offsetX and abs(currentOffsetX - offsetX) > 0.01) or (currentOffsetY ~= offsetY and abs(currentOffsetY - offsetY) > 0.01) then
    object:SetOwner(owner, anchor, offsetX, offsetY)
    return true, true, true
  end
  return false, true, currentOwner == owner
end

function IsMaxLevel(level, fallback)
  if level and type(level) == "number" then
    return level >= 60
  end
  return fallback
end

function IsUnitMaxLevel(unit, fallback)
  if unit and UnitExists(unit) and UnitIsPlayer(unit) then
    return IsMaxLevel(UnitLevel(unit), fallback)
  end
  return fallback
end

---@type TooltipStates<table, TooltipState>
local tooltipStates = {}

function GetTooltipState(tooltip)
  ---@type TooltipState
  local state = tooltipStates[tooltip]
  if not state then
    state = {}
    tooltipStates[tooltip] = state
  end
  return state
end

function ClearTooltip(tooltip)
  local state = GetTooltipState(tooltip)
  table.wipe(state)
end

function HideTooltip(tooltip)
  ClearTooltip(tooltip)
  tooltip:Hide()
end

function SetOwnerSafely(object, owner, anchor, offsetX, offsetY)
  if type(object) ~= "table" or type(object.GetOwner) ~= "function" then
    return
  end
  local currentOwner = object:GetOwner()
  if not currentOwner then
    object:SetOwner(owner, anchor, offsetX, offsetY)
    return true, false, true
  end
  offsetX, offsetY = offsetX or 0, offsetY or 0
  local currentAnchor, currentOffsetX, currentOffsetY = object:GetAnchorType()
  currentOffsetX, currentOffsetY = currentOffsetX or 0, currentOffsetY or 0
  if currentAnchor ~= anchor or (currentOffsetX ~= offsetX and abs(currentOffsetX - offsetX) > 0.01) or (currentOffsetY ~= offsetY and abs(currentOffsetY - offsetY) > 0.01) then
    object:SetOwner(owner, anchor, offsetX, offsetY)
    return true, true, true
  end
  return false, true, currentOwner == owner
end

