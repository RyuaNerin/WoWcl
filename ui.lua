----------------------------------------------------------------------------------------------------
-- 유닛

do
  local function OnTooltipSetUnit(self)
    if InCombatLockdown() then
      return
    end
    local _, unit = self:GetUnit()
    if not unit or not UnitIsPlayer(unit) then
      return
    end
    if IsUnitMaxLevel(unit) then
      local name, realm = UnitName(unit)
      local role = UnitGroupRolesAssigned(unit)

      if     role == "TANK"    then role = 0
      elseif role == "HEALER"  then role = 1
      elseif role == "DAMAGER" then role = 2
      else                          role = 2
      end

      WoWcl.Render(self, name, realm, role)
    end
  end

  local function OnTooltipCleared(self)
    ClearTooltip(self)
  end

  local function OnHide(self)
    HideTooltip(self)
  end

  GameTooltip:HookScript("OnTooltipSetUnit", OnTooltipSetUnit)
  GameTooltip:HookScript("OnTooltipCleared", OnTooltipCleared)
  GameTooltip:HookScript("OnHide", OnHide)
end

----------------------------------------------------------------------------------------------------
-- 파티찾기

do
  CreateFrame("GameTooltip", "WoWclLFGTooltip", nil, "GameTooltipTemplate")

  local currentResult = {}
  local hooked = {}

  local OnEnter
  local OnLeave

  local function SetSearchEntry(tooltip, resultID, autoAcceptOption)
    local entry = C_LFGList.GetSearchResultInfo(resultID)
    if not entry or not entry.leaderName then
      table.wipe(currentResult)
      return
    end
    currentResult.activityID = entry.activityID
    currentResult.leaderName = entry.leaderName

    WoWcl.Render(tooltip, currentResult.leaderName, nil, 1)
  end

  local function HookApplicantButtons(buttons)
    for _, button in pairs(buttons) do
      if not hooked[button] then
        hooked[button] = true
        button:HookScript("OnEnter", OnEnter)
        button:HookScript("OnLeave", OnLeave)
      end
    end
  end

  function OnEnter(self)
    local entry = C_LFGList.GetActiveEntryInfo()
    if entry then
      currentResult.activityID = entry.activityID
    end
    if not currentResult.activityID then
      return
    end
    if self.applicantID and self.Members then
      HookApplicantButtons(self.Members)
    elseif self.memberIdx then
      local fullName, _, _, _, _, tank, healer, damage = C_LFGList.GetApplicantMemberInfo(self:GetParent().applicantID, self.memberIdx)
      if not fullName then
        return false
      end

      local role = tank and 0 or (healer and 1 or 2)

      local ownerSet, ownerExisted, ownerSetSame = SetOwnerSafely(WoWclLFGTooltip, self, "ANCHOR_NONE", 0, 0)
      if ownerSet and not ownerExisted and ownerSetSame then
        WoWclLFGTooltip:Hide()
      end

      WoWcl.Render(WoWclLFGTooltip, fullName, nil, role)
      WoWclLFGTooltip:Show()
    end
  end

  function OnLeave(self)
    WoWclLFGTooltip:Hide()
  end

  hooksecurefunc("LFGListUtil_SetSearchEntryTooltip", SetSearchEntry)
  for i = 1, 10 do
    local button = _G["LFGListSearchPanelScrollFrameButton" .. i]
    button:HookScript("OnLeave", OnLeave)
  end

  for i = 1, 14 do
    local button = _G["LFGListApplicationViewerScrollFrameButton" .. i]
    button:HookScript("OnEnter", OnEnter)
    button:HookScript("OnLeave", OnLeave)
  end

  do
    local f = _G.LFGListFrame.ApplicationViewer.UnempoweredCover
    f:EnableMouse(false)
    f:EnableMouseWheel(false)
    f:SetToplevel(false)
  end
end

----------------------------------------------------------------------------------------------------
-- 길드
-- TODO

--[[
do
  local function OnEnter(self)
    if not self.guildIndex then
      return
    end
    local fullName, _, _, level = GetGuildRosterInfo(self.guildIndex)
    if not fullName or not IsMaxLevel(level) then
      return
    end
    local ownerSet, ownerExisted, ownerSetSame = SetOwnerSafely(GameTooltip, self, "ANCHOR_TOPLEFT", 0, 0)
    if ownerSet and not ownerExisted and ownerSetSame then
      GameTooltip:Hide()
    end
    Render(GameTooltip, fullName)
  end
  
  local function OnLeave(self)
    if not self.guildIndex then
      return
    end
    GameTooltip:Hide()
  end
  
  local function OnScroll()
    GameTooltip:Hide()
    ExecuteWidgetHandler(GetMouseFocus(), "OnEnter")
  end
  
  for i = 1, #GuildRosterContainer.buttons do
    print('GuildRosterContainer', i)
    local button = GuildRosterContainer.buttons[i]
    button:HookScript("OnEnter", OnEnter)
    button:HookScript("OnLeave", OnLeave)
  end
  hooksecurefunc(GuildRosterContainer, "update", OnScroll)
end

]]