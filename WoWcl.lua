WoWcl = { zoneList={}, db={} }
function WoWcl.AddData(db, zone)
  if not WoWcl.db[zone] then
    WoWcl.zoneList[#WoWcl.zoneList + 1] = zone
    table.sort(WoWcl.zoneList, function(a, b) return a > b end)
  end

  WoWcl.db[zone] = db
end

----------------------------------------------------------------------------------------------------

local headerNameOnDetail = {
  "|cffffd800%s|r |TInterface\\AddOns\\WoWcl\\icons\\roles:14:14:0:0:64:64:38:56:0:18|t", -- 탱
  "|cffffd800%s|r |TInterface\\AddOns\\WoWcl\\icons\\roles:14:14:0:0:64:64:19:37:0:18|t", -- 힐
  "|cffffd800%s|r |TInterface\\AddOns\\WoWcl\\icons\\roles:14:14:0:0:64:64:0:18:0:18|t",  -- 딜
  "|cffffd800%s|r",
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

local function toInt(data, index, length)
  local k = string.byte(string.sub(data, 1, 1))
  local v = 0
  local value = 0
  local p = 1

  for i = length - 1, 0, -1 do
    v = string.byte(string.sub(data, 1 + index + i, 1 + index + i)) + (256 - k)
    if v >= 256 then
      v = v - 256
    end

    value = value + v * p
    p = p * 256
  end

  return value
end

local function getScoreText(scores)
  local function fmt(v)
    return format(
      "|cff%s%7s|r",
      getColorHex(v),
      v < 0 and "-----" or format("%.1f", v)
    )
  end

  return format("%s   %s   %s", fmt(scores[1]), fmt(scores[2]), fmt(scores[3]))
end

----------------------------------------------------------------------------------------------------

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

function WoWcl.RenderZone(tooltip, name, realm, role, zone)
  local db = WoWcl.db[zone]

  local cacheName = name .. "-" .. realm

  if not wclLogCache[zone] then
    wclLogCache[zone] = {}
  end

  local wclLog = wclLogCache[zone][cacheName]

  local roles

  if not wclLog then
    local realmData = db.server[realm]
    if not realmData then
      tooltip:AddDoubleLine(format(headerNameOnDetail[4], db.zoneName), "기록 없음", 1, 1, 1, 0.8, 0.8, 0.8)
      return
    end

    local posIndex = binSearch(realmData, name, 2, #realmData)
    if not posIndex then
      tooltip:AddDoubleLine(format(headerNameOnDetail[4], db.zoneName), "기록 없음", 1, 1, 1, 0.8, 0.8, 0.8)
      return
    end
    posIndex = realmData[1] + posIndex - 2 -- 2 개 빼는 이유 : (lua 배열 인덱스 시작 = 1) and 첫번째 인덱스는 기본 초기위치...

    local scoreStart = 1 + toInt(db.pos, 1 + posIndex * 3, 3)

    wclLog = {}
    wclLog[1] = toInt(db.score, scoreStart, 1)

    roles = classRoleIndex[wclLog[1]]

    local scoreEnd = scoreStart + (roles[3] + 1) * (1 + db.encounterCount) * 3 * 2

    local wclLogIndex = 2
    for i = scoreStart + 1, scoreEnd, 2 do
      local v = toInt(db.score, i, 2)

      if v == 0 then
        wclLog[wclLogIndex] = -1
      else
        wclLog[wclLogIndex] = (v - 1) / 10.0
      end

      wclLogIndex = wclLogIndex + 1
    end

    wclLogCache[cacheName] = wclLog
  end

  roles = classRoleIndex[wclLog[1]]

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

      scores[1][2] = wclLog[2 + roles[1] * (1 + db.encounterCount) * 3 + 0]
      scores[1][3] = wclLog[2 + roles[1] * (1 + db.encounterCount) * 3 + 1]
      scores[1][4] = wclLog[2 + roles[1] * (1 + db.encounterCount) * 3 + 2]

      scores[2][2] = wclLog[2 + roles[2] * (1 + db.encounterCount) * 3 + 0]
      scores[2][3] = wclLog[2 + roles[2] * (1 + db.encounterCount) * 3 + 1]
      scores[2][4] = wclLog[2 + roles[2] * (1 + db.encounterCount) * 3 + 2]

      scores[3][2] = wclLog[2 + roles[3] * (1 + db.encounterCount) * 3 + 0]
      scores[3][3] = wclLog[2 + roles[3] * (1 + db.encounterCount) * 3 + 1]
      scores[3][4] = wclLog[2 + roles[3] * (1 + db.encounterCount) * 3 + 2]

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

    local startPos = 2 + roles[1 + role] * (1 + db.encounterCount) * 3

    for i = 0, db.encounterCount do
      local maxDifficulty = 1

      local scores = {
        wclLog[startPos + i * 3 + 0],
        wclLog[startPos + i * 3 + 1],
        wclLog[startPos + i * 3 + 2],
      }

      if scores[1] >= 0 then maxDifficulty = 2 end;
      if scores[2] >= 0 then maxDifficulty = 3 end;
      if scores[3] >= 0 then maxDifficulty = 4 end;

      tooltip:AddDoubleLine(
        (
          i == 0
          and format(headerNameOnDetail[1 + role], db.zoneName)
          or  format(
            "|cff%s%s|r",
            difficultyColorHex[maxDifficulty],
            db.encounterNames[i]
          )
        ),
        getScoreText(scores),
        1, 1, 1,
        1, 1, 1
      )
    end
  else
    for role = 1, 3 do
      if roles[role] >= 0 then
        local scores = { 
          wclLog[2 + roles[role] * (1 + db.encounterCount) * 3 + 0],
          wclLog[2 + roles[role] * (1 + db.encounterCount) * 3 + 1],
          wclLog[2 + roles[role] * (1 + db.encounterCount) * 3 + 2],
        }

        tooltip:AddDoubleLine(
          format(headerNameOnDetail[role], db.zoneName),
          getScoreText(scores),
          1, 1, 1,
          1, 1, 1
        )
      end
    end
  end
end

function WoWcl.Render(tooltip, name, realm, role)
  if not realm then
    realm = GetRealmName()
  end

  if not WoWcl.db then
    return
  end

  tooltip:AddLine(" ")
  for i, zone in pairs(WoWcl.zoneList) do
    WoWcl.RenderZone(tooltip, name, realm, role, zone)
    tooltip:AddLine(" ")
  end
  tooltip:AddDoubleLine("마지막 업데이트", WoWcl.db[WoWcl.zoneList[1]].version, 0.8, 0.8, 0.8, 0.8, 0.8, 0.8)
  tooltip:AddLine(" ")

  if name == "경력직자택경비원" and realm == "아즈샤라" then
    tooltip:AddDoubleLine(" ", "|cffF0A30AWoWcl 문의는 귓속말로!|r")
    tooltip:AddLine(" ")
  end
end
