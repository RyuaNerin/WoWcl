local addonName, addonTable = ...

local eventframe = CreateFrame("FRAME", addonName.."Events")

local function onEvent(self,event,arg)
  if event == "PLAYER_ENTERING_WORLD" then
    eventframe:UnregisterEvent("PLAYER_ENTERING_WORLD")

    print("|cffffd800WoWcl 를 이용중입니다.|r")
    print("|cffff5555로그 점수는 개인의 공략 이해 및 수행을 나타내주는 지표가 아닙니다.|r")
    print("이슈 문의 : |cffffd800github.com/RyuaNerin/WoWcl|r 혹은 |cffffd800경력직자택경비원-아즈샤라|r")
  end
end

eventframe:RegisterEvent("PLAYER_ENTERING_WORLD")
eventframe:SetScript("OnEvent", onEvent)