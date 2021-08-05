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

function dumpTable(tbl, indent)
  if not indent then indent = 0 end
  for k, v in pairs(tbl) do
    local formatting = string.rep("  ", indent) .. k .. ": "
    if type(v) == "table" then
      print(formatting)
      dumpTable(v, indent+1)
    elseif type(v) == 'boolean' then
      print(formatting .. tostring(v))
    else
      print(formatting .. v)
    end
  end
end

local UNIT_TOKENS = {
  mouseover = true,
  player = true,
  target = true,
  focus = true,
  pet = true,
  vehicle = true,
}

do
  for i = 1, 40 do
      UNIT_TOKENS["raid" .. i] = true
      UNIT_TOKENS["raidpet" .. i] = true
      UNIT_TOKENS["nameplate" .. i] = true
  end

  for i = 1, 4 do
      UNIT_TOKENS["party" .. i] = true
      UNIT_TOKENS["partypet" .. i] = true
  end

  for i = 1, 5 do
      UNIT_TOKENS["arena" .. i] = true
      UNIT_TOKENS["arenapet" .. i] = true
  end

  for i = 1, MAX_BOSS_FRAMES do
      UNIT_TOKENS["boss" .. i] = true
  end

  for k, _ in pairs(UNIT_TOKENS) do
      UNIT_TOKENS[k .. "target"] = true
  end
end
function IsUnitToken(unit)
  return type(unit) == "string" and UNIT_TOKENS[unit]
end

function IsUnit(arg1, arg2)
  if not arg2 and type(arg1) == "string" and arg1:find("-", nil, true) then
      arg2 = true
  end
  local isUnit = not arg2 or IsUnitToken(arg1)
  return isUnit, isUnit and UnitExists(arg1), isUnit and UnitIsPlayer(arg1)
end


function GetNameRealm(arg1, arg2)
  local unit, name, realm
  local _, unitExists, unitIsPlayer = IsUnit(arg1, arg2)
  if unitExists then
      unit = arg1
      if unitIsPlayer then
          name, realm = UnitName(arg1)
          realm = realm and realm ~= "" and realm or GetNormalizedRealmName()
      end
      return name, realm, unit
  end
  if type(arg1) == "string" then
      if arg1:find("-", nil, true) then
          name, realm = ("-"):split(arg1)
      else
          name = arg1 -- assume this is the name
      end
      if not realm or realm == "" then
          if type(arg2) == "string" and arg2 ~= "" then
              realm = arg2
          else
              realm = GetNormalizedRealmName() -- assume they are on our realm
          end
      end
  end
  return name, realm, unit
end

function GetNameRealmFromPlayerLink(playerLink)
  local linkString, linkText = LinkUtil.SplitLink(playerLink)
  local linkType, linkData = ExtractLinkData(linkString)
  if linkType == "player" then
      return GetNameRealm(linkData)
  end
end