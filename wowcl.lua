WoWcl = { db={} }
function WoWcl.AddData(db)
  WoWcl.db = db
end

----------------------------------------------------------------------------------------------------

local encounterCount = 10

local zoneNames = {
  "|cffffd800나스리아 성채 |r|TInterface\\AddOns\\WoWcl\\icons\\roles:14:14:0:0:64:64:38:56:0:18|t", -- 탱
  "|cffffd800나스리아 성채 |r|TInterface\\AddOns\\WoWcl\\icons\\roles:14:14:0:0:64:64:19:37:0:18|t", -- 힐
  "|cffffd800나스리아 성채 |r|TInterface\\AddOns\\WoWcl\\icons\\roles:14:14:0:0:64:64:0:18:0:18|t",  -- 딜
}

local encounterNames = {
  "절규날개",
  "사냥꾼 알티모르",
  "굶주린 파괴자",
  "태양왕의 구원",
  "기술자 자이목스",
  "귀부인 미네르바 다크베인",
  "혈기의 의회",
  "진흙주먹",
  "돌 군단 장군",
  "대영주 데나트리우스",
}

local classRoleIndex = {
  --    탱  힐  딜
  [ 1] = {  0, -1,  1, }, -- 죽기
  [ 2] = {  0,  1,  2, }, -- 드루이드
  [ 3] = { -1, -1,  0, }, -- 사냥꾼
  [ 4] = { -1, -1,  0, }, -- 법사
  [ 5] = {  0,  1,  2, }, -- 수도사
  [ 6] = {  0,  1,  2, }, -- 성기사
  [ 7] = { -1,  0,  1, }, -- 사제
  [ 8] = { -1, -1,  0, }, -- 도적
  [ 9] = { -1,  0,  1, }, -- 주술사
  [10] = { -1, -1,  0, }, -- 흑마법사
  [11] = {  0, -1,  1, }, -- 전사
  [12] = {  0, -1,  1, }, -- 악사
}

local difficultyColorHex = {
  "666666",
  "61ff4d",
  "ff9933",
  "f2e6c0",
}

local function getColorHex(percentage)
  if percentage >= 100 then return "f2e6c0" end
  if percentage >=  99 then return "e67db4" end
  if percentage >=  95 then return "ff9933" end
  if percentage >=  75 then return "c37cf4" end
  if percentage >=  50 then return "4d9bff" end
  if percentage >=  25 then return "61ff4d" end
  if percentage >=   0 then return "aaaaaa" end
                            return "888888"
end

----------------------------------------------------------------------------------------------------

function WoWcl.Render(tooltip, name, realm, role)
  local userName = name
  if not string.find(name, "-") then
    userName = realm
      and name.."-"..realm
      or  name.."-"..GetRealmName()
  end

  local wcl_log = WoWcl.db[userName]
  if wcl_log == nil then
    if IsShiftKeyDown()   then role = 0 end
    if IsControlKeyDown() then role = 1 end
    if IsAltKeyDown()     then role = 2 end

    tooltip:AddLine(" ")
    tooltip:AddDoubleLine(zoneNames[1 + role], "로그 없음", 1, 1, 1, 0.8, 0.8, 0.8)
    tooltip:AddDoubleLine("마지막 업데이트", WoWcl.db[0], 0.8, 0.8, 0.8, 0.8, 0.8, 0.8)
    tooltip:AddLine(" ")
    return
  end

  local roles = classRoleIndex[wcl_log[1]]

  if roles[1] >= 0 and IsShiftKeyDown()   then role = 0 end
  if roles[2] >= 0 and IsControlKeyDown() then role = 1 end
  if roles[3] >= 0 and IsAltKeyDown()     then role = 2 end

  local startPos = 2 + roles[1 + role] * (1 + encounterCount) * 3

  tooltip:AddLine(" ")
  for i = 0, encounterCount do
    local maxDifficulty = 1

    local scores = {
      wcl_log[startPos + i * 3 + 0],
      wcl_log[startPos + i * 3 + 1],
      wcl_log[startPos + i * 3 + 2],
    }
    local scores_text = {
      "- ",
      "- ",
      "- ",
    };

    if scores[1] >= 0 then maxDifficulty = 2; scores_text[1] = format("%.1f", scores[1]) end;
    if scores[2] >= 0 then maxDifficulty = 3; scores_text[2] = format("%.1f", scores[2]) end;
    if scores[3] >= 0 then maxDifficulty = 4; scores_text[3] = format("%.1f", scores[3]) end;

    scores_text[1] = format("%7s", scores_text[1])
    scores_text[2] = format("%7s", scores_text[2])
    scores_text[3] = format("%7s", scores_text[3])

    tooltip:AddDoubleLine(
      (
        i == 0
        and zoneNames[1 + role]
        or  format(
          "|cff%s%s|r",
          difficultyColorHex[maxDifficulty],
          encounterNames[i]
        )
      ),
      format(
        "|cff%s%s|r  |cff%s%s|r  |cff%s%s|r",
        getColorHex(scores[1]), scores_text[1],
        getColorHex(scores[2]), scores_text[2],
        getColorHex(scores[3]), scores_text[3]
      ),
      1, 1, 1,
      1, 1, 1
    )
  end
  tooltip:AddDoubleLine("마지막 업데이트", WoWcl.db[0], 0.8, 0.8, 0.8, 0.8, 0.8, 0.8)
  tooltip:AddLine(" ")
end
