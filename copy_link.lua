-- Based on https://github.com/RaiderIO/raiderio-addon/blob/master/core.lua

local LibDropDownExtension = LibStub and LibStub:GetLibrary("LibDropDownExtension-1.0", true)

local selectedName, selectedRealm

local unitOptions  = {
  {
    text = "Wcl 웹 페이지 링크 복사",
    func = function()
      local urlencoding = function(str)
        return str:gsub("([^%w ])", function(c) return string.format("%%%02X", string.byte(c)); end):gsub(" ", "+")
      end

      url = format("https://ko.warcraftlogs.com/character/kr/%s/%s", urlencoding(selectedRealm), urlencoding(selectedName))

      ShowCopyDialog(url)
    end
  }
}

local validTypes = {
  ARENAENEMY = true,
  CHAT_ROSTER = true,
  FOCUS = true,
  FRIEND = true,
  GUILD = true,
  GUILD_OFFLINE = true,
  PARTY = true,
  PLAYER = true,
  RAID = true,
  RAID_PLAYER = true,
  SELF = true,
  TARGET = true,
  WORLD_STATE_SCORE = true
}
local function IsValidDropDown(bdropdown)
  return bdropdown == LFGListFrameDropDown or (type(bdropdown.which) == "string" and validTypes[bdropdown.which])
end

local function GetNameRealmForDropDown(bdropdown)
  local unit = bdropdown.unit
  local menuList = bdropdown.menuList
  local quickJoinMember = bdropdown.quickJoinMember
  local quickJoinButton = bdropdown.quickJoinButton
  local clubMemberInfo = bdropdown.clubMemberInfo
  local tempName, tempRealm = bdropdown.name, bdropdown.server
  local name, realm, level
  -- unit
  if not name and UnitExists(unit) then
    if UnitIsPlayer(unit) then
        name, realm = GetNameRealm(unit)
        level = UnitLevel(unit)
    end
    -- if it's not a player it's pointless to check further
    return name, realm, level
  end
  -- lfd
  if not name and menuList then
    for i = 1, #menuList do
      local whisperButton = menuList[i]
      if whisperButton and (whisperButton.text == _G.WHISPER_LEADER or whisperButton.text == _G.WHISPER) then
        name, realm = GetNameRealm(whisperButton.arg1)
        break
      end
    end
  end
  -- quick join
  if not name and (quickJoinMember or quickJoinButton) then
    local memberInfo = quickJoinMember or quickJoinButton.Members[1]
    if memberInfo.playerLink then
      name, realm, level = GetNameRealmFromPlayerLink(memberInfo.playerLink)
    end
  end
  -- dropdown by name and realm
  if not name and tempName then
    name, realm = GetNameRealm(tempName, tempRealm)
    if clubMemberInfo and clubMemberInfo.level and (clubMemberInfo.clubType == Enum.ClubType.Guild or clubMemberInfo.clubType == Enum.ClubType.Character) then
      level = clubMemberInfo.level
    end
  end
  -- if we don't got both we return nothing
  if not name or not realm then
    return
  end
  return name, realm, level
end

local function OnToggle(bdropdown, event, options, level, data)
  if event == "OnShow" then
    if not IsValidDropDown(bdropdown) then
      return
    end

    local level
    selectedName, selectedRealm, level = GetNameRealmForDropDown(bdropdown)
    if not selectedName or not IsMaxLevel(level, true) then
      return
    end
    if not options[1] then
      for i = 1, #unitOptions do
        options[i] = unitOptions[i]
      end
      return true
    end
  elseif event == "OnHide" then
    if options[1] then
      for i = #options, 1, -1 do
        options[i] = nil
      end
      return true
      end
  end
end

LibDropDownExtension:RegisterEvent("OnShow OnHide", OnToggle, 1, dropdown)