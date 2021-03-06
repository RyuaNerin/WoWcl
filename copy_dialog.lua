local frame
local title
local button
local editBox

local function Show()
	frame:SetSize(420, 190)
	frame:ClearAllPoints()
	frame:SetPoint("CENTER", frame:GetParent() or UIParent, "CENTER", 0, 0)
	frame:Show()
	editBox:SetFocus()
end

local function Hide()
  editBox:SetScript("OnTextChanged", nil)
	frame:Hide()
end

local function InitFrame()
  frame       = CreateFrame("Frame",       nil, UIParent, BackdropTemplateMixin and "BackdropTemplate")
  button      = CreateFrame("Button",      nil, frame)
  editBox     = CreateFrame("EditBox",     nil, frame)

  --------------------------------------------------

  frame:EnableMouse(true)
  frame:EnableKeyboard(true)
  frame:SetFrameStrata("DIALOG")
  frame:SetBackdrop({
    bgFile = "Interface/DialogFrame/UI-DialogBox-Background",
    tile = true,
    edgeFile = "Interface/DialogFrame/UI-DialogBox-Border",
    edgeSize = 32,
    insets = {
      left = 11,
      right = 12,
      top = 12,
      bottom = 11,
    },
  })

  --------------------------------------------------
  
	title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalHugeBlack")
	title:SetPoint("TOP", 0, -15)
	title:SetTextColor(1, 1, 1, 1)
  title:SetText("Ctrl + C 를 눌러 링크를 복사하세요")
	title:Show()

  --------------------------------------------------

  button:SetSize(128, 24)
  button:SetPoint("BOTTOM", 0, 20)
  button:SetText(OKAY)

  button:SetNormalTexture(button:CreateTexture(nil, nil, "DialogButtonNormalTexture"))
  button:SetPushedTexture(button:CreateTexture(nil, nil, "DialogButtonPushedTexture"))
  button:SetHighlightTexture(button:CreateTexture(nil, nil, "DialogButtonPushedTexture"))

  button:SetNormalFontObject(DialogButtonNormalText)
  button:SetHighlightFontObject(DialogButtonHighlightText)

  button:SetScript("OnClick", function() Hide() end)

  --------------------------------------------------

  editBox:SetPoint("TOP", 5, -45)
  editBox:SetMaxLetters(500)
  editBox:SetSize(370, 90)
  editBox:SetFont(ChatFontNormal:GetFont())
  editBox:SetAutoFocus(true)
  editBox:SetMultiLine(true)
  editBox:SetScript("OnEscapePressed", function() Hide() end)

  local hideQueued = false
  editBox:SetScript("OnKeyDown", function(_, key)
    if (key == "C" or key == "X") and IsControlKeyDown() then
      hideQueued = true
    end
  end)
  editBox:SetScript("OnKeyUp", function(_, key)
    if hideQueued and (key == "C" or key == "X" or key == "LCTRL" or key == "RCTRL") then
      Hide()
    end
  end)
  editBox:Show()
end

--------------------------------------------------

function ShowCopyDialog(text)
  if not frame then
    InitFrame()
  end

	Hide()

	editBox:SetText(text)
	editBox:HighlightText()

  -- readonly
  editBox:SetScript("OnTextChanged", function()
    editBox:SetText(text)
    editBox:HighlightText()
  end)

	Show()
end
