WoWcl = { db={} }
function WoWcl.AddData(db)
  WoWcl.db = db
end

----------------------------------------------------------------------------------------------------

local headerNameOnDetail = {
  "|cffffd800나스리아 성채|r |TInterface\\AddOns\\WoWcl\\icons\\roles:14:14:0:0:64:64:38:56:0:18|t", -- 탱
  "|cffffd800나스리아 성채|r |TInterface\\AddOns\\WoWcl\\icons\\roles:14:14:0:0:64:64:19:37:0:18|t", -- 힐
  "|cffffd800나스리아 성채|r |TInterface\\AddOns\\WoWcl\\icons\\roles:14:14:0:0:64:64:0:18:0:18|t",  -- 딜
  "|cffffd800나스리아 성채|r",
}

local encounterCount = 10
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
  --       탱  힐  딜
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
local function dump(tbl, indent)
  if not indent then indent = 0 end
  for k, v in pairs(tbl) do
    formatting = string.rep("  ", indent) .. k .. ": "
    if type(v) == "table" then
      print(formatting)
      tprint(v, indent+1)
    elseif type(v) == 'boolean' then
      print(formatting .. tostring(v))		
    else
      print(formatting .. v)
    end
  end
end

local function binSearch(data, name, startIndex, endIndex)
  local minIndex = startIndex
  local maxIndex = endIndex
  local mid, current

  while minIndex <= maxIndex do
      mid = floor((maxIndex + minIndex) / 2)
      current = data[mid]
      if current == name then
          return mid
      elseif current < name then
          minIndex = mid + 1
      else
          maxIndex = mid - 1
      end
  end
end

local wclLogCache = {}

function WoWcl.Render(tooltip, name, realm, role)
  if not realm then
    realm = GetRealmName()
  end

  local cacheName = name .. "-" .. realm

  local wcl_log = wclLogCache[cacheName]

  local roles

  if not wcl_log then
    local realmData = WoWcl.db.server[realm]
    if not realmData then
      tooltip:AddLine(" ")
      tooltip:AddDoubleLine(headerNameOnDetail[4], "기록 없음", 1, 1, 1, 0.8, 0.8, 0.8)
      tooltip:AddDoubleLine("마지막 업데이트", WoWcl.db.version, 0.8, 0.8, 0.8, 0.8, 0.8, 0.8)
      tooltip:AddLine(" ")
      return
    end

    local posIndex = binSearch(realmData, name, 2, #realmData)
    if not posIndex then
      tooltip:AddLine(" ")
      tooltip:AddDoubleLine(headerNameOnDetail[4], "기록 없음", 1, 1, 1, 0.8, 0.8, 0.8)
      tooltip:AddDoubleLine("마지막 업데이트", WoWcl.db.version, 0.8, 0.8, 0.8, 0.8, 0.8, 0.8)
      tooltip:AddLine(" ")
      return
    end
    posIndex = realmData[1] + posIndex - 2 -- 2 개 빼는 이유 : (lua 배열 인덱스 시작 = 1) and 첫번째 인덱스는 기본 초기위치...

    local posStrIndex = 1 + posIndex * 4
    local scoreStart =  string.byte(string.sub(WoWcl.db.pos, posStrIndex + 0, posStrIndex + 0)) * 16777216 +
                        string.byte(string.sub(WoWcl.db.pos, posStrIndex + 1, posStrIndex + 1)) * 65536 +
                        string.byte(string.sub(WoWcl.db.pos, posStrIndex + 2, posStrIndex + 2)) * 256 +
                        string.byte(string.sub(WoWcl.db.pos, posStrIndex + 3, posStrIndex + 3)) +
                        1

    wcl_log = {}
    wcl_log[1] = string.byte(string.sub(WoWcl.db.score, scoreStart, scoreStart))

    roles = classRoleIndex[wcl_log[1]]

    local scoreEnd = scoreStart + (roles[3] + 1) *  (1 + encounterCount) * 3 * 2

    local wcl_log_index = 2
    for i = scoreStart + 1, scoreEnd, 2 do
      local v = string.byte(string.sub(WoWcl.db.score, i + 0, i + 0)) * 256 +
                string.byte(string.sub(WoWcl.db.score, i + 1, i + 1))

      if v == 0 then
        wcl_log[wcl_log_index] = -1
      else
        wcl_log[wcl_log_index] = (v - 1) / 10.0
      end

      wcl_log_index = wcl_log_index + 1
    end

    wclLogCache[cacheName] = wcl_log
  end

  roles = classRoleIndex[wcl_log[1]]

  tooltip:AddLine(" ")
  if IsShiftKeyDown() or IsControlKeyDown() or IsAltKeyDown() then
    ----------------------------------------------------------------------------------------------------
    if IsShiftKeyDown() and IsControlKeyDown() and IsAltKeyDown() then
      role = -1
    else
      if roles[1] >= 0 and IsShiftKeyDown()   then role = 0 end
      if roles[2] >= 0 and IsControlKeyDown() then role = 1 end
      if roles[3] >= 0 and IsAltKeyDown()     then role = 2 end
    end

    if role == -1 then
      -- 최고 클리어 난이도   탱  힐  딜
      local maxDifficulty = { 1, 1, 1 }
      local scores = {
        { -1, -1, -1, -1 }, -- 탱
        { -1, -1, -1, -1 }, -- 힐
        { -1, -1, -1, -1 }, -- 딜
      }

      scores[1][2] = wcl_log[2 + roles[1] * (1 + encounterCount) * 3 + 0]
      scores[1][3] = wcl_log[2 + roles[1] * (1 + encounterCount) * 3 + 1]
      scores[1][4] = wcl_log[2 + roles[1] * (1 + encounterCount) * 3 + 2]

      scores[2][2] = wcl_log[2 + roles[2] * (1 + encounterCount) * 3 + 0]
      scores[2][3] = wcl_log[2 + roles[2] * (1 + encounterCount) * 3 + 1]
      scores[2][4] = wcl_log[2 + roles[2] * (1 + encounterCount) * 3 + 2]

      scores[3][2] = wcl_log[2 + roles[3] * (1 + encounterCount) * 3 + 0]
      scores[3][3] = wcl_log[2 + roles[3] * (1 + encounterCount) * 3 + 1]
      scores[3][4] = wcl_log[2 + roles[3] * (1 + encounterCount) * 3 + 2]

      if     roles[1] >= 0 and scores[1][3] >= 0 then maxDifficulty[1] = 4
      elseif roles[1] >= 0 and scores[1][2] >= 0 then maxDifficulty[1] = 3
      elseif roles[1] >= 0 and scores[1][1] >= 0 then maxDifficulty[1] = 2
      end

      if     roles[2] >= 0 and scores[2][3] >= 0 then maxDifficulty[2] = 4
      elseif roles[2] >= 0 and scores[2][2] >= 0 then maxDifficulty[2] = 3
      elseif roles[2] >= 0 and scores[2][1] >= 0 then maxDifficulty[2] = 2
      end

      if     roles[3] >= 0 and scores[3][3] >= 0 then maxDifficulty[3] = 4
      elseif roles[3] >= 0 and scores[3][2] >= 0 then maxDifficulty[3] = 3
      elseif roles[3] >= 0 and scores[3][1] >= 0 then maxDifficulty[3] = 2
      end

      -- 탱
      if     maxDifficulty[1] > 1 and maxDifficulty[1] > maxDifficulty[2] and maxDifficulty[1] > maxDifficulty[3] then role = 0 -- 탱
      elseif maxDifficulty[2] > 1 and maxDifficulty[2] > maxDifficulty[1] and maxDifficulty[2] > maxDifficulty[3] then role = 1 -- 힐
      elseif maxDifficulty[3] > 1 and maxDifficulty[3] > maxDifficulty[1] and maxDifficulty[3] > maxDifficulty[2] then role = 2 -- 딜
      else
        -- 가장 점수가 좋은 것
        if     scores[1][maxDifficulty[1]] > scores[2][maxDifficulty[2]] and scores[1][maxDifficulty[1]] > scores[3][maxDifficulty[3]] then role = 0 -- 탱
        elseif scores[2][maxDifficulty[2]] > scores[1][maxDifficulty[1]] and scores[2][maxDifficulty[2]] > scores[3][maxDifficulty[3]] then role = 1 -- 힐
        elseif scores[3][maxDifficulty[3]] > scores[1][maxDifficulty[1]] and scores[3][maxDifficulty[3]] > scores[2][maxDifficulty[2]] then role = 2 -- 딜
        else
          role = 2 -- 딜러엔 실패없음
        end
      end
    end

    local startPos = 2 + roles[1 + role] * (1 + encounterCount) * 3

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
          and headerNameOnDetail[1 + role]
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
  else
    for role = 1, 3 do
      if roles[role] >= 0 then
        local scores = { 
          wcl_log[2 + roles[role] * (1 + encounterCount) * 3 + 0],
          wcl_log[2 + roles[role] * (1 + encounterCount) * 3 + 1],
          wcl_log[2 + roles[role] * (1 + encounterCount) * 3 + 2],
        }
        local scores_text = {
          "- ",
          "- ",
          "- ",
        };

        if scores[1] >= 0 then scores_text[1] = format("%.1f", scores[1]) end;
        if scores[2] >= 0 then scores_text[2] = format("%.1f", scores[2]) end;
        if scores[3] >= 0 then scores_text[3] = format("%.1f", scores[3]) end;

        tooltip:AddDoubleLine(
          headerNameOnDetail[role],
          format(
            "|cff%s%7s|r  |cff%s%7s|r  |cff%s%7s|r",
            getColorHex(scores[1]), scores_text[1],
            getColorHex(scores[2]), scores_text[2],
            getColorHex(scores[3]), scores_text[3]
          ),
          1, 1, 1,
          1, 1, 1
        )
      end
    end
  end
  tooltip:AddDoubleLine("마지막 업데이트", WoWcl.db.version, 0.8, 0.8, 0.8, 0.8, 0.8, 0.8)
  tooltip:AddLine(" ")
end
