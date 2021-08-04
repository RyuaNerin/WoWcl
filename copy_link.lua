local contextMenuFrame = CreateFrame("Frame")

local CopyWclLink = "COPY_WCL_LINK"
UnitPopupButtons[CopyWclLink] = {
  text = "Wcl 웹 페이지 링크 복사",
  --dist = -1,
  func = function(arg)
    name, realm = UnitName("target")
    if realm == nil then
      realm = GetRealmName()
    end

    local urlencoding = function(str)
      return str:gsub("([^%w ])", function(c) return string.format("%%%02X", string.byte(c)); end):gsub(" ", "+")
    end

    url = format("https://ko.warcraftlogs.com/character/kr/%s/%s", urlencoding(realm), urlencoding(name))

    ShowCopyDialog(url)
  end
}

contextMenuFrame:RegisterEvent("UNIT_TARGET")
contextMenuFrame:SetScript(
  "OnEvent",
  function(frame, event, unit, arg1)
    print('event :', event)
    print('unit :', unit)
    print('arg1 :', arg1)
    print('UnitIsPlayer("target") :', UnitIsPlayer("target"))
    if UnitIsPlayer("target") then
      local added = false
      for i = 1, #UnitPopupMenus["PLAYER"] do
        if UnitPopupMenus["PLAYER"][i] == CopyWclLink then
          added = true
          break
        end
      end

      if not added then
        tinsert(UnitPopupMenus["PLAYER"], #UnitPopupMenus["PLAYER"] - 1, CopyWclLink)
      end
    end
  end
)

hooksecurefunc(
  "UnitPopup_ShowMenu",
  function(dropdownMenu, which, unit, name, userData, ...)
    for i = 1, UIDROPDOWNMENU_MAXBUTTONS do
      local button = _G["DropDownList" .. UIDROPDOWNMENU_MENU_LEVEL .. "Button" .. i];

      if button.value then
        local action = UnitPopupButtons[button.value]
        if action then
          button.func = action.func
          button.arg1 = userData
        end
      end
    end
  end
)