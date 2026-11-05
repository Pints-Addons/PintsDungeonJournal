-- Pints Storybook: the Dungeon Journal. One chapter per dungeon or raid:
--   spread 1 - the lore on the left, the bosses and what each one drops on the right (with a "gear I can use" filter)
--   spread 2 - the chronicle of runs: every run that killed a final boss, with date, time, the company (name, level,
--              class) and the loot you received.
-- Runs are watched from the moment you zone in. A run is written into the chronicle when a final boss dies; anything
-- looted after that (and the rest of the bosses) is added to the same entry until you leave for good.
-- Drop log: every boss corpse you open the loot window on is recorded (what it dropped, out of how many kills), kept
-- separately for Classic Era and WoW Forever, so changed or new Forever loot shows up next to the Classic data.
local ADDON, NS = ...
-- Compatibility: WoW Forever runs on the modern game client, where these older functions moved or were renamed.
local GetItemInfo = GetItemInfo or (C_Item and C_Item.GetItemInfo)
local GetItemIcon = GetItemIcon or (C_Item and C_Item.GetItemIconByID)

local function db() return NS.DB and NS.DB() end
local function CK() return (GetRealmName() or "") .. "." .. ((GetUnitName and GetUnitName("player", false) or UnitName("player")) or "") end
local function Say(msg) print("|cffd4a24cDungeon Journal|r: " .. msg) end

local JD = PintsJournalData
local DUN = JD and JD.dungeons or {}
local ITEMS = JD and JD.items or {}
-- Some dungeons share one map but are separate instances (the Scarlet Monastery and Dire Maul wings). The game reports
-- the same map for each, so the wing is told apart by which bosses die there.
local BYMAP, BOSSIDX, BOSSDUN, BYNAME = {}, {}, {}, {}
for i, d in ipairs(DUN) do
  BYMAP[d[1]] = BYMAP[d[1]] or i
  BYNAME[d[2]] = i
  BOSSDUN[d[1]] = BOSSDUN[d[1]] or {}
  local set = {}
  for _, b in ipairs(d[9]) do set[b[1]] = true; BOSSDUN[d[1]][b[1]] = i end
  BOSSIDX[i] = set
end
-- names in the combat log that stand for a journal entry
-- halves that share ONE instance (a full run can do both): moving on starts a new chronicle entry once the first
-- half's final boss is down, and the loot already won stays with the first half
local SAME_INSTANCE = { [229] = true, [329] = true }
local ALIAS = {
  ["Highlord Mograine"] = "The Four Horsemen", ["Thane Korth'azz"] = "The Four Horsemen",
  ["Lady Blaumeux"] = "The Four Horsemen", ["Sir Zeliek"] = "The Four Horsemen",
  ["Doom'rel"] = "The Seven",
}

---------------------------------------------------------------- saved state
-- db.journal = { usable, allChars, runs = { record, ... }, cur = { [ck] = run in progress }, kills = { [ck] = { [boss] = n } } }
local function J()
  local d = db(); if not d then return end
  d.journal = d.journal or {}
  local j = d.journal
  j.runs = j.runs or {}; j.cur = j.cur or {}; j.kills = j.kills or {}
  if j.usable == nil then j.usable = false end
  if not j.wingsSplit then
    -- runs recorded before the wings had chapters of their own: file them under the wing of their final boss
    for _, rec in ipairs(j.runs) do
      if not BYNAME[rec.dun or ""] then
        local idx = BOSSDUN[rec.map or 0] and BOSSDUN[rec.map][(rec.finals or {})[1] or ""]
        if idx then rec.dun = DUN[idx][2] end
      end
    end
    for _, run in pairs(j.cur) do
      local d = DUN[run.dun or 0]
      if not d or d[1] ~= run.map then run.dun = BYMAP[run.map] end
    end
    j.wingsSplit = true
  end
  return j
end
local function Kills()
  local j = J(); if not j then return {} end
  j.kills[CK()] = j.kills[CK()] or {}
  return j.kills[CK()]
end

---------------------------------------------------------------- who can use what
local WEAPONS = {   -- weapon subclasses each class can learn
  WARRIOR = { 0, 1, 2, 3, 4, 5, 6, 7, 8, 10, 13, 15, 16, 18 },
  PALADIN = { 0, 1, 4, 5, 6, 7, 8 },
  HUNTER  = { 0, 1, 2, 3, 6, 7, 8, 10, 13, 15, 16, 18 },
  ROGUE   = { 2, 3, 4, 7, 13, 15, 16, 18 },
  PRIEST  = { 4, 10, 15, 19 },
  SHAMAN  = { 0, 1, 4, 5, 10, 13, 15 },
  MAGE    = { 7, 10, 15, 19 },
  WARLOCK = { 7, 10, 15, 19 },
  DRUID   = { 4, 5, 10, 13, 15 },
}
local ARMOR = {     -- armour subclasses (mail and plate count even before level 40: that is only a level wait)
  WARRIOR = { 0, 1, 2, 3, 4, 6 }, PALADIN = { 0, 1, 2, 3, 4, 6, 7 }, HUNTER = { 0, 1, 2, 3 }, ROGUE = { 0, 1, 2 },
  PRIEST = { 0, 1 }, SHAMAN = { 0, 1, 2, 3, 6, 9 }, MAGE = { 0, 1 }, WARLOCK = { 0, 1 }, DRUID = { 0, 1, 2, 8 },
}
local canUse
local function BuildCanUse()
  local _, cls, cid = UnitClass("player")
  canUse = { cls = cls, bit = cid and (2 ^ (cid - 1)) or 0, w = {}, a = {} }
  for _, s in ipairs(WEAPONS[cls] or {}) do canUse.w[s] = true end
  canUse.w[14], canUse.w[20] = true, true          -- miscellaneous, fishing poles
  for _, s in ipairs(ARMOR[cls] or {}) do canUse.a[s] = true end
end
-- usable = this class may wear or wield it; a level requirement does not count against it
local function Usable(id)
  local it = ITEMS[id]; if not it then return true end
  if not canUse then BuildCanUse() end
  local mask = it[5]
  if mask and mask > 0 and canUse.bit > 0 and (math.floor(mask / canUse.bit) % 2) == 0 then return false end
  local cls, sub = math.floor(it[2] / 100), it[2] % 100
  if cls == 2 then return canUse.w[sub] == true end
  if cls == 4 then return canUse.a[sub] == true end
  return true
end
NS.JournalUsable = Usable

local SLOT = { [1] = "Head", [2] = "Neck", [3] = "Shoulder", [4] = "Shirt", [5] = "Chest", [6] = "Waist", [7] = "Legs", [8] = "Feet",
  [9] = "Wrist", [10] = "Hands", [11] = "Finger", [12] = "Trinket", [13] = "One-Hand", [14] = "Shield", [15] = "Ranged", [16] = "Back",
  [17] = "Two-Hand", [19] = "Tabard", [20] = "Chest", [21] = "Main Hand", [22] = "Off Hand", [23] = "Held In Off-hand",
  [25] = "Thrown", [26] = "Ranged", [28] = "Relic" }
local WSUB = { [0] = "Axe", [1] = "Axe", [2] = "Bow", [3] = "Gun", [4] = "Mace", [5] = "Mace", [6] = "Polearm", [7] = "Sword", [8] = "Sword",
  [10] = "Staff", [13] = "Fist Weapon", [14] = "", [15] = "Dagger", [16] = "Thrown", [18] = "Crossbow", [19] = "Wand", [20] = "Fishing Pole" }
local ASUB = { [1] = "Cloth", [2] = "Leather", [3] = "Mail", [4] = "Plate", [6] = "", [7] = "Libram", [8] = "Idol", [9] = "Totem" }
local function Kind(it)
  local cls, sub, inv = math.floor(it[2] / 100), it[2] % 100, it[1]
  if cls == 2 then
    local w = WSUB[sub] or ""
    if inv == 17 and w ~= "" and sub ~= 10 and sub ~= 6 then return "Two-Hand " .. w end
    if inv == 15 or inv == 26 or inv == 25 or sub == 10 or sub == 6 then return w end
    return (SLOT[inv] or "") .. (w ~= "" and (" " .. w) or "")
  end
  local a = ASUB[sub]
  if a and a ~= "" and inv ~= 16 then return a .. " " .. (SLOT[inv] or "") end
  return SLOT[inv] or ""
end
-- quality colours deep enough to read on parchment
local QCOL = { [2] = { 0.06, 0.42, 0.04 }, [3] = { 0.02, 0.28, 0.62 }, [4] = { 0.42, 0.12, 0.62 }, [5] = { 0.74, 0.36, 0.00 } }
local LINKQ = { ["1eff00"] = 2, ["0070dd"] = 3, ["a335ee"] = 4, ["ff8000"] = 5 }

---------------------------------------------------------------- drop log
-- db.drops[flavor][mapID] = { name = instance name, bosses = { [creature] = { kills = n, items = { [itemID] = times } } } }
local FLAVOR = ((select(4, GetBuildInfo())) or 0) >= 16000 and "forever" or "classic"
NS.JournalFlavor = FLAVOR
local deadNames, openedCorpse = {}, {}      -- this session: corpse GUID -> name; corpse GUID -> { itemID = true }
local function Drops(mapID)
  local d = db(); if not d then return end
  d.drops = d.drops or {}
  d.drops[FLAVOR] = d.drops[FLAVOR] or {}
  if mapID == nil then return d.drops[FLAVOR] end
  local m = d.drops[FLAVOR][mapID]
  if not m then m = { bosses = {} }; d.drops[FLAVOR][mapID] = m end
  return m
end
NS.JournalDrops = Drops
local function LinkQuality(link)
  local q = select(3, GetItemInfo(link))
  if q then return q end
  local hex = link:match("|c%x%x(%x%x%x%x%x%x)")
  return hex and ({ ["9d9d9d"] = 0, ["ffffff"] = 1, ["1eff00"] = 2, ["0070dd"] = 3, ["a335ee"] = 4, ["ff8000"] = 5 })[hex:lower()] or 1
end
local function OnLootOpened()
  local inInst, kind = IsInInstance()
  if not inInst or (kind ~= "party" and kind ~= "raid") then return end
  if not GetLootSourceInfo then return end
  local instName, _, _, _, _, _, _, mapID = GetInstanceInfo()
  if not mapID then return end
  local known = BYMAP[mapID] ~= nil
  local m
  for slot = 1, (GetNumLootItems() or 0) do
    local link = GetLootSlotLink(slot)
    local id = link and tonumber(link:match("item:(%d+)"))
    if id then
      local src = { GetLootSourceInfo(slot) }
      for k = 1, #src, 2 do
        local guid = src[k]
        local name = guid and deadNames[guid]
        if name and not guid:find("^Player") then
          name = ALIAS[name] or name
          m = m or Drops(mapID)
          m.name = m.name or instName
          local boss = m.bosses[name]
          -- its bosses (from the journal, or any boss encounter the game reports here - that catches new Forever bosses);
          -- in a dungeon the journal doesn't have yet, also anything that drops rare or better
          local enc = m.enc and m.enc[name]
          local track = (known and BOSSDUN[mapID][name]) or enc or (not known and (boss or LinkQuality(link) >= 3))
          if track then
            if not boss then boss = { kills = 0, items = {} }; m.bosses[name] = boss end
            local seen = openedCorpse[guid]
            if not seen then seen = {}; openedCorpse[guid] = seen; boss.kills = boss.kills + 1 end
            if not seen[id] then seen[id] = true; boss.items[id] = (boss.items[id] or 0) + 1 end
          end
        end
      end
    end
  end
  if m and NS.JournalRefresh then NS.JournalRefresh() end
end

---------------------------------------------------------------- run tracking
local function Now() return time() end
local function DungeonHere()
  local inInst, kind = IsInInstance()
  if not inInst or (kind ~= "party" and kind ~= "raid") then return end
  local mapID = select(8, GetInstanceInfo())
  return mapID and BYMAP[mapID], mapID
end
local function Cur() local j = J(); return j and j.cur[CK()] end
local function EndRun(why)
  local j = J(); if j then j.cur[CK()] = nil end
end

local function UnitsInGroup()
  local u = { "player" }
  if IsInRaid and IsInRaid() then
    u = {}
    for i = 1, (GetNumGroupMembers() or 0) do u[#u + 1] = "raid" .. i end
  else
    for i = 1, 4 do if UnitExists("party" .. i) then u[#u + 1] = "party" .. i end end
  end
  return u
end
-- remember everyone you've been grouped with this run (name -> level, class)
local function NoteGroup(run)
  run.seen = run.seen or {}
  for _, unit in ipairs(UnitsInGroup()) do
    local name, realm = UnitName(unit)
    if name and name ~= UNKNOWNOBJECT and name ~= "Unknown" then
      if realm and realm ~= "" then name = name .. "-" .. realm end
      local _, cls = UnitClass(unit)
      local lvl = UnitLevel(unit) or 0
      local s = run.seen[name] or {}
      s[1] = (lvl and lvl > 0) and lvl or s[1] or 0
      s[2] = cls or s[2]
      run.seen[name] = s
    end
  end
end
-- the company standing in the dungeon when the final boss fell
local function Company(run)
  NoteGroup(run)
  local out, me = {}, (GetUnitName and GetUnitName("player", false) or UnitName("player"))
  for _, unit in ipairs(UnitsInGroup()) do
    local name, realm = UnitName(unit)
    if name then
      if realm and realm ~= "" then name = name .. "-" .. realm end
      local s = run.seen[name] or {}
      out[#out + 1] = { name, s[1] or 0, s[2] or "WARRIOR" }
    end
  end
  table.sort(out, function(a, b)
    if (a[1] == me) ~= (b[1] == me) then return a[1] == me end
    return a[1] < b[1]
  end)
  return out
end
local function Copy(t) local o = {}; for i, v in ipairs(t or {}) do o[i] = v end; return o end
-- keep the chronicle entry in step with the run in progress
local function Sync(run)
  local j = J()
  local rec = run.rec and j.runs[run.rec]
  if not rec or rec.id ~= run.id then return end
  rec.bosses, rec.loot = Copy(run.bosses), Copy(run.loot)
end

local function StartRun(idx, mapID)
  local j = J(); if not j then return end
  local run = j.cur[CK()]
  local t = Now()
  if run then
    local away = run.left and (t - run.left) or 0
    -- same dungeon, back from a corpse run or a quick step outside: carry on
    if run.map == mapID and away < 20 * 60 and (t - (run.last or t)) < 3 * 3600 then
      if run.left then run.entered, run.entryLoot = t, #run.loot + 1 end
      run.left = nil; run.last = t; NoteGroup(run); return
    end
  end
  run = { id = t .. "." .. math.random(1000, 9999), map = mapID, dun = idx, start = t, last = t, bosses = {}, loot = {}, seen = {},
    entered = t, entryLoot = 1 }
  NoteGroup(run)
  j.cur[CK()] = run
end

local function OnBossDied(name)
  local run = Cur(); if not run then return end
  name = ALIAS[name] or name
  local idx = BOSSDUN[run.map] and BOSSDUN[run.map][name]
  if not idx then return end
  if idx ~= run.dun then
    if #run.bosses == 0 then
      run.dun = idx                                  -- first boss of the visit tells us which wing this is
    elseif SAME_INSTANCE[run.map] and not run.rec then
      run.dun = idx                                  -- skipped the first half's final boss: carry on as the other half
    elseif SAME_INSTANCE[run.map] then
      local j = J()
      local nr = { id = Now() .. "." .. math.random(1000, 9999), map = run.map, dun = idx, start = Now(), last = Now(),
        bosses = {}, loot = {}, seen = run.seen, entered = Now(), entryLoot = 1 }
      j.cur[CK()] = nr
      run = nr
    else
      -- a boss from another wing: that is a new instance, so a new run. Loot since you walked in goes with it.
      local j = J()
      local nr = { id = Now() .. "." .. math.random(1000, 9999), map = run.map, dun = idx, start = run.entered or Now(), last = Now(),
        bosses = {}, loot = {}, seen = run.seen, entered = run.entered, entryLoot = 1 }
      for k = #run.loot, (run.entryLoot or #run.loot + 1), -1 do table.insert(nr.loot, 1, table.remove(run.loot, k)) end
      Sync(run)
      j.cur[CK()] = nr
      run = nr
    end
  end
  local d = DUN[run.dun]; if not d then return end
  for _, b in ipairs(run.bosses) do if b == name then return end end      -- once per run
  run.bosses[#run.bosses + 1] = name
  run.last = Now()
  local k = Kills(); k[name] = (k[name] or 0) + 1
  local final = false
  for _, f in ipairs(d[7]) do if f == name then final = true end end
  if final then
    local j = J()
    local rec = run.rec and j.runs[run.rec]
    if rec and rec.id == run.id then
      rec.finals = rec.finals or {}; rec.finals[#rec.finals + 1] = name
      rec.done = Now()
    else
      rec = { id = run.id, ck = CK(), map = run.map, dun = d[2], start = run.start, done = Now(), finals = { name },
        company = Company(run), bosses = {}, loot = {} }
      j.runs[#j.runs + 1] = rec
      run.rec = #j.runs
      Say(("%s has fallen - this run of %s is written into your Dungeon Journal."):format(name, d[2]))
    end
  end
  Sync(run)
  if NS.JournalRefresh then NS.JournalRefresh() end
end

local LOOT_PATTERNS
local function LootPatterns()
  LOOT_PATTERNS = {}
  for _, g in ipairs({ "LOOT_ITEM_SELF_MULTIPLE", "LOOT_ITEM_SELF" }) do
    local f = _G[g]
    if type(f) == "string" then
      local p = f:gsub("([%(%)%.%%%+%-%*%?%[%]%^%$])", "%%%1"):gsub("%%%%s", "(.+)"):gsub("%%%%d", "(%%d+)")
      LOOT_PATTERNS[#LOOT_PATTERNS + 1] = "^" .. p .. "$"
    end
  end
  if #LOOT_PATTERNS == 0 then LOOT_PATTERNS = { "^You receive loot: (.+)x(%d+)%.$", "^You receive loot: (.+)%.$" } end
end
local function OnLoot(msg)
  local run = Cur(); if not run or not DungeonHere() then return end
  if not LOOT_PATTERNS then LootPatterns() end
  local link, count
  for _, p in ipairs(LOOT_PATTERNS) do
    link, count = msg:match(p)
    if link then break end
  end
  if not link or not link:find("|Hitem:", 1, true) then return end
  local q = select(3, GetItemInfo(link))
  if not q then local hex = link:match("|cff(%x%x%x%x%x%x)"); q = hex and LINKQ[hex:lower()] or 1 end
  if q < 2 then return end
  run.loot[#run.loot + 1] = (count and tonumber(count) and tonumber(count) > 1) and (link .. "x" .. count) or link
  run.last = Now()
  Sync(run)
  if NS.JournalRefresh then NS.JournalRefresh() end
end

local ev = CreateFrame("Frame")
-- the modern game client (WoW Forever) doesn't let add-ons read the combat log; boss kills there come from ENCOUNTER_END
local NO_COMBAT_LOG = type(issecretvalue) == "function"
for _, e in ipairs({ "PLAYER_ENTERING_WORLD", "ZONE_CHANGED_NEW_AREA", "GROUP_ROSTER_UPDATE", "COMBAT_LOG_EVENT_UNFILTERED",
  "CHAT_MSG_LOOT", "CHAT_MSG_SYSTEM", "UNIT_LEVEL", "LOOT_OPENED", "ENCOUNTER_END" }) do
  if not (NO_COMBAT_LOG and e == "COMBAT_LOG_EVENT_UNFILTERED") then pcall(ev.RegisterEvent, ev, e) end
end
ev:SetScript("OnEvent", function(_, event, a1, ...)
  if not J() then return end
  if event == "COMBAT_LOG_EVENT_UNFILTERED" then
    local _, sub, _, _, _, _, _, destGUID, destName = CombatLogGetCurrentEventInfo()
    if sub == "UNIT_DIED" and destName and destGUID and not destGUID:find("^Player") then
      deadNames[destGUID] = destName
      OnBossDied(destName)
    end
    return
  end
  if event == "LOOT_OPENED" then OnLootOpened(); return end
  if event == "ENCOUNTER_END" then
    -- a boss encounter was won: remember its name for this instance so its corpse's loot is logged
    local encName, _, _, success = ...          -- a1 is the encounter ID
    if success == 1 and encName then
      local instName, _, _, _, _, _, _, mapID = GetInstanceInfo()
      local m = mapID and Drops(mapID)
      if m then m.name = m.name or instName; m.enc = m.enc or {}; m.enc[encName] = true end
    end
    return
  end
  if event == "CHAT_MSG_LOOT" then if a1 then OnLoot(a1) end; return end
  if event == "CHAT_MSG_SYSTEM" then
    -- "<instance> has been reset." - the next visit is a fresh run
    local f = _G.INSTANCE_RESET_SUCCESS
    if a1 and type(f) == "string" and a1:match("^" .. f:gsub("%%s", ".+"):gsub("%.$", "%%.") .. "$") then
      local run = Cur(); if run and run.left then EndRun("reset") end
    end
    return
  end
  local idx, mapID = DungeonHere()
  local run = Cur()
  if event == "PLAYER_ENTERING_WORLD" or event == "ZONE_CHANGED_NEW_AREA" then
    if idx then StartRun(idx, mapID)
    elseif run and not run.left then run.left = Now() end
    if run and run.left and (Now() - run.left) > 3 * 3600 then EndRun("stale") end
  elseif (event == "GROUP_ROSTER_UPDATE" or event == "UNIT_LEVEL") and run and idx then
    NoteGroup(run)
  end
end)

---------------------------------------------------------------- the pages
local L, R
local jIdx, jPage, selRun
local bossRows, itemRows, runRows, mateRows, lootRows = {}, {}, {}, {}, {}

local function Ink(fs, c, a) fs:SetTextColor(c[1], c[2], c[3], a or 1) end
local function When(t, fmt) return ((date(fmt or "%B %d, %Y at %I:%M %p", t):gsub(" 0(%d)", " %1"):gsub("^0(%d)", "%1"))) end

local function DefaultDungeon()
  local here = DungeonHere()
  local run = Cur()
  if here and run and DUN[run.dun] and DUN[run.dun][1] == DUN[here][1] then return run.dun end
  if here then return here end
  local lvl, best = UnitLevel("player") or 1, 1
  for i, d in ipairs(DUN) do if d[6] == 0 and d[4] <= lvl and lvl <= d[5] + 2 then best = i end end
  if lvl >= 60 then best = BYMAP[230] or best end
  return best
end

local function Turn(dir)
  local w = NS.Win()
  if w and SOUNDKIT and SOUNDKIT.IG_ABILITY_PAGE_TURN then PlaySound(SOUNDKIT.IG_ABILITY_PAGE_TURN) end
  NS.Render()
  local leaf = w and ((dir > 0) and w.flipR or w.flipL)
  if leaf then leaf:Play() end
end
function NS.JournalTurn(dir)
  if not jIdx then jIdx = DefaultDungeon() end
  jIdx = ((jIdx - 1 + dir) % #DUN) + 1
  jPage, selRun = 1, nil
  Turn(dir)
end
function NS.JournalFrac() return (jIdx or 1) / math.max(1, #DUN) end
function NS.JournalSpread() return 900 + (jIdx or 1) * 2 + (jPage or 1) end
function NS.JournalReset() jIdx, jPage, selRun = nil, 1, nil end

local function Check(parent, label, get, set, tip)
  local B = NS.Book
  local c = CreateFrame("CheckButton", nil, parent, "UICheckButtonTemplate"); c:SetSize(20, 20)
  c.t = c:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall"); c.t:SetPoint("LEFT", c, "RIGHT", 0, 0); c.t:SetText(label)
  c.t:SetTextColor(B.INK_SOFT[1], B.INK_SOFT[2], B.INK_SOFT[3]); c.t:SetShadowOffset(0, 0)
  c:SetScript("OnClick", function(self) set(self:GetChecked() and true or false); NS.RenderJournal() end)
  c.Sync = function() c:SetChecked(get() and true or false) end
  if tip then
    c:SetScript("OnEnter", function(self) GameTooltip:SetOwner(self, "ANCHOR_RIGHT"); GameTooltip:AddLine(label); GameTooltip:AddLine(tip, 1, 1, 1, true); GameTooltip:Show() end)
    c:SetScript("OnLeave", function() GameTooltip:Hide() end)
  end
  return c
end

local function ItemTip(self)
  if not self.link and not self.id then return end
  GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
  if self.link then GameTooltip:SetHyperlink(self.link:gsub("x%d+$", "")) else GameTooltip:SetHyperlink("item:" .. self.id) end
  if self.chance then GameTooltip:AddLine(("Drop chance: about %d%%"):format(self.chance), 0.8, 0.8, 0.8) end
  if self.seen then GameTooltip:AddLine(self.seen, 0.4, 0.9, 0.4) end
  GameTooltip:Show()
end
local function ItemClick(self)
  local link = self.link and self.link:gsub("x%d+$", "") or (self.id and select(2, GetItemInfo(self.id)))
  if not link then return end
  if IsModifiedClick("CHATLINK") and ChatEdit_InsertLink then ChatEdit_InsertLink(link)
  elseif IsModifiedClick("DRESSUP") and DressUpItemLink then DressUpItemLink(link) end
end

local function BuildPages()
  local win = NS.Win(); local B = NS.Book
  L = CreateFrame("Frame", nil, win.left); L:SetAllPoints(); L:SetFrameLevel(win.left:GetFrameLevel() + 5); L:Hide()
  R = CreateFrame("Frame", nil, win.right); R:SetAllPoints(); R:SetFrameLevel(win.right:GetFrameLevel() + 5); R:Hide()

  -- left page, spread 1: the tale
  local T = CreateFrame("Frame", nil, L); T:SetAllPoints(); L.tale = T
  T.chapter = T:CreateFontString(nil, "OVERLAY", B.F_CHAPTER); T.chapter:SetPoint("TOP", 0, -10); Ink(T.chapter, B.RUBRIC)
  T.cap = T:CreateFontString(nil, "OVERLAY", B.F_CAP); T.cap:SetPoint("TOPLEFT", 20, -18); Ink(T.cap, B.RUBRIC)
  T.gild = B.Gild(T.cap)
  T.title = T:CreateFontString(nil, "OVERLAY", B.F_TITLE); T.title:SetPoint("BOTTOMLEFT", T.cap, "BOTTOMRIGHT", 1, 6)
  T.title:SetPoint("RIGHT", T, "RIGHT", -20, 0); T.title:SetJustifyH("LEFT"); T.title:SetWordWrap(false)
  T.info = T:CreateFontString(nil, "OVERLAY", B.F_SMALL); T.info:SetPoint("TOPLEFT", 24, -74); Ink(T.info, B.INK_SOFT)
  local o = B.Ornament(T); o:SetPoint("TOPLEFT", 16, -90); o:SetPoint("TOPRIGHT", -16, -90)
  T.lore = T:CreateFontString(nil, "OVERLAY", B.F_BODY); T.lore:SetPoint("TOPLEFT", 24, -108); T.lore:SetWidth(B.PAGE_W - 48)
  T.lore:SetJustifyH("LEFT"); T.lore:SetSpacing(4); Ink(T.lore, B.INK)
  T.finalHead = T:CreateFontString(nil, "OVERLAY", B.F_HEAD); T.finalHead:SetPoint("TOPLEFT", T.lore, "BOTTOMLEFT", 0, -18); Ink(T.finalHead, B.RUBRIC)
  T.finals = T:CreateFontString(nil, "OVERLAY", B.F_BODY); T.finals:SetPoint("TOPLEFT", T.finalHead, "BOTTOMLEFT", 2, -4)
  T.finals:SetWidth(B.PAGE_W - 52); T.finals:SetJustifyH("LEFT"); Ink(T.finals, B.INK)
  T.statHead = T:CreateFontString(nil, "OVERLAY", B.F_HEAD); T.statHead:SetPoint("TOPLEFT", T.finals, "BOTTOMLEFT", -2, -18); Ink(T.statHead, B.RUBRIC)
  T.statHead:SetText("Your deeds here")
  T.stats = T:CreateFontString(nil, "OVERLAY", B.F_BODY); T.stats:SetPoint("TOPLEFT", T.statHead, "BOTTOMLEFT", 2, -4)
  T.stats:SetWidth(B.PAGE_W - 52); T.stats:SetJustifyH("LEFT"); T.stats:SetSpacing(3); Ink(T.stats, B.INK)

  -- right page, spread 1: bosses and spoils
  local S = CreateFrame("Frame", nil, R); S:SetAllPoints(); R.spoils = S
  S.title = S:CreateFontString(nil, "OVERLAY", B.F_TITLE); S.title:SetPoint("TOPLEFT", 52, -18); S.title:SetText("Bosses & Spoils")
  S.sub = S:CreateFontString(nil, "OVERLAY", B.F_SMALL); S.sub:SetPoint("TOPLEFT", S.title, "BOTTOMLEFT", 2, -2); Ink(S.sub, B.INK_SOFT)
  S.usable = Check(S, "Only gear I can use", function() return J().usable end, function(v) J().usable = v end,
    "Hides gear your class can never wear or wield. Gear you are only too low a level for stays, with its level in red.")
  S.usable:SetPoint("TOPRIGHT", -150, -24)
  local sf, list = B.Scroller(S, "PintsDJJournalLoot"); sf:SetPoint("TOPLEFT", 52, -70); sf:SetPoint("BOTTOMRIGHT", -20, 30)
  sf.cue:SetPoint("BOTTOMRIGHT", -22, 12); list:SetSize(B.PAGE_W - 72, 1)
  S.sf, S.list = sf, list

  -- left page, spread 2: the chronicle of runs
  local C = CreateFrame("Frame", nil, L); C:SetAllPoints(); L.chron = C
  C.chapter = C:CreateFontString(nil, "OVERLAY", B.F_CHAPTER); C.chapter:SetPoint("TOP", 0, -10); Ink(C.chapter, B.RUBRIC)
  C.title = C:CreateFontString(nil, "OVERLAY", B.F_TITLE); C.title:SetPoint("TOPLEFT", 24, -22); C.title:SetText("Chronicle of Runs")
  C.sub = C:CreateFontString(nil, "OVERLAY", B.F_SMALL); C.sub:SetPoint("TOPLEFT", C.title, "BOTTOMLEFT", 2, -2); Ink(C.sub, B.INK_SOFT)
  C.all = Check(C, "All my characters", function() return J().allChars end, function(v) J().allChars = v; selRun = nil end)
  C.all:SetPoint("TOPRIGHT", -130, -26)
  local o2 = B.Ornament(C); o2:SetPoint("TOPLEFT", 16, -74); o2:SetPoint("TOPRIGHT", -16, -74)
  local sf2, list2 = B.Scroller(C, "PintsDJJournalRuns"); sf2:SetPoint("TOPLEFT", 24, -90); sf2:SetPoint("BOTTOMRIGHT", -20, 64)
  sf2.cue:SetPoint("BOTTOMRIGHT", -22, 46); list2:SetSize(B.PAGE_W - 48, 1)
  C.sf, C.list = sf2, list2
  C.empty = C:CreateFontString(nil, "OVERLAY", B.F_BODY); C.empty:SetPoint("TOPLEFT", 28, -96); C.empty:SetWidth(B.PAGE_W - 60)
  C.empty:SetJustifyH("LEFT"); C.empty:SetSpacing(3); Ink(C.empty, B.INK_SOFT)

  -- right page, spread 2: one run in full
  local Dt = CreateFrame("Frame", nil, R); Dt:SetAllPoints(); R.detail = Dt
  Dt.title = Dt:CreateFontString(nil, "OVERLAY", B.F_HEAD); Dt.title:SetPoint("TOPLEFT", 52, -22); Dt.title:SetPoint("RIGHT", -20, 0)
  Dt.title:SetJustifyH("LEFT"); Ink(Dt.title, B.RUBRIC)
  Dt.sub = Dt:CreateFontString(nil, "OVERLAY", B.F_SMALL); Dt.sub:SetPoint("TOPLEFT", Dt.title, "BOTTOMLEFT", 2, -4); Dt.sub:SetPoint("RIGHT", -20, 0)
  Dt.sub:SetJustifyH("LEFT"); Ink(Dt.sub, B.INK_SOFT)
  local sf3, list3 = B.Scroller(Dt, "PintsDJJournalRun"); sf3:SetPoint("TOPLEFT", 52, -70); sf3:SetPoint("BOTTOMRIGHT", -20, 30)
  sf3.cue:SetPoint("BOTTOMRIGHT", -22, 12); list3:SetSize(B.PAGE_W - 72, 1)
  Dt.sf, Dt.list = sf3, list3
  Dt.empty = Dt:CreateFontString(nil, "OVERLAY", B.F_BODY); Dt.empty:SetPoint("TOPLEFT", 56, -80); Dt.empty:SetWidth(B.PAGE_W - 90)
  Dt.empty:SetJustifyH("LEFT"); Dt.empty:SetSpacing(3); Ink(Dt.empty, B.INK_SOFT)
  -- headings and text lines inside the run's scroll list
  Dt.heads, Dt.texts = {}, {}
end

---------------------------------------------------------------- row factories
local function BossRow(i)
  local r = bossRows[i]; if r then return r end
  local B = NS.Book
  r = CreateFrame("Frame", nil, R.spoils.list); r:SetSize(B.PAGE_W - 76, 26)
  r.line = r:CreateTexture(nil, "ARTWORK"); r.line:SetPoint("BOTTOMLEFT", 0, 2); r.line:SetPoint("BOTTOMRIGHT", 0, 2); r.line:SetHeight(1)
  r.line:SetColorTexture(B.INK_FAINT[1], B.INK_FAINT[2], B.INK_FAINT[3], 0.45)
  r.name = r:CreateFontString(nil, "OVERLAY", B.F_ROW); r.name:SetPoint("BOTTOMLEFT", 0, 5); Ink(r.name, B.INK)
  r.lvl = r:CreateFontString(nil, "OVERLAY", B.F_SMALL); r.lvl:SetPoint("LEFT", r.name, "RIGHT", 6, -1); Ink(r.lvl, B.INK_FAINT)
  r.kills = r:CreateFontString(nil, "OVERLAY", B.F_SMALL); r.kills:SetPoint("BOTTOMRIGHT", -2, 6)
  bossRows[i] = r
  return r
end
local function ItemRow(i, parent, pool)
  local r = pool[i]; if r then r:SetParent(parent); return r end
  local B = NS.Book
  r = CreateFrame("Button", nil, parent); r:SetSize(B.PAGE_W - 76, 20)
  local hl = r:CreateTexture(nil, "HIGHLIGHT"); hl:SetAllPoints(); hl:SetColorTexture(0.45, 0.30, 0.10, 0.12)
  r.icon = r:CreateTexture(nil, "ARTWORK"); r.icon:SetSize(17, 17); r.icon:SetPoint("LEFT", 10, 0)
  r.name = r:CreateFontString(nil, "OVERLAY", B.F_BODY); r.name:SetPoint("LEFT", r.icon, "RIGHT", 5, 0); r.name:SetJustifyH("LEFT")
  r.name:SetWordWrap(false)
  r.right = r:CreateFontString(nil, "OVERLAY", B.F_SMALL); r.right:SetPoint("RIGHT", -2, 0); Ink(r.right, B.INK_SOFT)
  r.name:SetPoint("RIGHT", r.right, "LEFT", -6, 0)
  r:SetScript("OnEnter", ItemTip); r:SetScript("OnLeave", function() GameTooltip:Hide() end)
  r:SetScript("OnClick", ItemClick)
  pool[i] = r
  return r
end
local function RunRow(i)
  local r = runRows[i]; if r then return r end
  local B = NS.Book
  r = CreateFrame("Button", nil, L.chron.list); r:SetSize(B.PAGE_W - 52, 38)
  local hl = r:CreateTexture(nil, "HIGHLIGHT"); hl:SetAllPoints(); hl:SetColorTexture(0.45, 0.30, 0.10, 0.12)
  r.sel = r:CreateTexture(nil, "BORDER"); r.sel:SetAllPoints(); r.sel:SetColorTexture(0.55, 0.35, 0.10, 0.18)
  r.when = r:CreateFontString(nil, "OVERLAY", B.F_ROW); r.when:SetPoint("TOPLEFT", 6, -3); Ink(r.when, B.INK)
  r.num = r:CreateFontString(nil, "OVERLAY", B.F_SMALL); r.num:SetPoint("TOPRIGHT", -6, -5); Ink(r.num, B.INK_FAINT)
  r.info = r:CreateFontString(nil, "OVERLAY", B.F_SMALL); r.info:SetPoint("BOTTOMLEFT", 6, 4); r.info:SetPoint("RIGHT", -6, 0)
  r.info:SetJustifyH("LEFT"); r.info:SetWordWrap(false); Ink(r.info, B.INK_SOFT)
  r:RegisterForClicks("LeftButtonUp", "RightButtonUp")
  r:SetScript("OnClick", function(self, btn)
    if btn == "RightButton" and IsShiftKeyDown() then
      local j = J()
      for k, rec in ipairs(j.runs) do if rec == self.rec then table.remove(j.runs, k); break end end
      for _, run in pairs(j.cur) do run.rec = nil end
      selRun = nil; Say("that run has been struck from the chronicle."); NS.RenderJournal(); return
    end
    selRun = self.rec
    if SOUNDKIT and SOUNDKIT.IG_ABILITY_PAGE_TURN then PlaySound(SOUNDKIT.IG_ABILITY_PAGE_TURN) end
    NS.RenderJournal()
  end)
  r:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT"); GameTooltip:AddLine("Click to read this run")
    GameTooltip:AddLine("Shift-right-click to strike it from the chronicle", 1, 1, 1); GameTooltip:Show()
  end)
  r:SetScript("OnLeave", function() GameTooltip:Hide() end)
  runRows[i] = r
  return r
end
local CLASS_TC = { WARRIOR = { 0, 0.25, 0, 0.25 }, MAGE = { 0.25, 0.49609375, 0, 0.25 }, ROGUE = { 0.49609375, 0.7421875, 0, 0.25 },
  DRUID = { 0.7421875, 0.98828125, 0, 0.25 }, HUNTER = { 0, 0.25, 0.25, 0.5 }, SHAMAN = { 0.25, 0.49609375, 0.25, 0.5 },
  PRIEST = { 0.49609375, 0.7421875, 0.25, 0.5 }, WARLOCK = { 0.7421875, 0.98828125, 0.25, 0.5 }, PALADIN = { 0, 0.25, 0.5, 0.75 } }
local function MateRow(i)
  local r = mateRows[i]; if r then return r end
  local B = NS.Book
  r = CreateFrame("Frame", nil, R.detail.list); r:SetSize((B.PAGE_W - 76) / 2, 34)
  r.icon = r:CreateTexture(nil, "ARTWORK"); r.icon:SetSize(24, 24); r.icon:SetPoint("LEFT", 4, 0)
  r.icon:SetTexture("Interface\\Glues\\CharacterCreate\\UI-CharacterCreate-Classes")
  r.name = r:CreateFontString(nil, "OVERLAY", B.F_ROW); r.name:SetPoint("TOPLEFT", 32, -1); r.name:SetPoint("RIGHT", -2, 0)
  r.name:SetJustifyH("LEFT"); r.name:SetWordWrap(false)
  r.info = r:CreateFontString(nil, "OVERLAY", B.F_SMALL); r.info:SetPoint("BOTTOMLEFT", 32, 2); Ink(r.info, B.INK_SOFT)
  mateRows[i] = r
  return r
end
local function DetailHead(i)
  local D = R.detail
  local f = D.heads[i]; if f then return f end
  local B = NS.Book
  f = D.list:CreateFontString(nil, "OVERLAY", B.F_HEAD); Ink(f, B.RUBRIC)
  D.heads[i] = f
  return f
end
local function DetailText(i)
  local D = R.detail
  local f = D.texts[i]; if f then return f end
  local B = NS.Book
  f = D.list:CreateFontString(nil, "OVERLAY", B.F_BODY); f:SetWidth(B.PAGE_W - 80); f:SetJustifyH("LEFT"); f:SetSpacing(3); Ink(f, B.INK)
  D.texts[i] = f
  return f
end

---------------------------------------------------------------- rendering
local function ShownRuns(d)
  local j, ck, out = J(), CK(), {}
  for _, rec in ipairs(j.runs) do
    if rec.dun == d[2] and (j.allChars or rec.ck == ck) then out[#out + 1] = rec end
  end
  table.sort(out, function(a, b) return (a.done or 0) > (b.done or 0) end)
  return out
end
local function Dur(a, b)
  if not (a and b) or b < a then return "" end
  local m = math.floor((b - a) / 60 + 0.5)
  if m >= 60 then return ("%dh %02dm"):format(math.floor(m / 60), m % 60) end
  return m .. " min"
end
local function ClassName(cls)
  return (LOCALIZED_CLASS_NAMES_MALE and LOCALIZED_CLASS_NAMES_MALE[cls]) or (cls and (cls:sub(1, 1) .. cls:sub(2):lower())) or "?"
end
local function ClassInk(cls)
  local c = RAID_CLASS_COLORS and RAID_CLASS_COLORS[cls]
  if not c then return 0.2, 0.12, 0.05 end
  return c.r * 0.6, c.g * 0.6, c.b * 0.6           -- deepened to read on parchment
end

local function RenderTale(d)
  local B = NS.Book
  local T = L.tale
  local raid = d[6] == 1
  T.chapter:SetText(raid and "~ The Dungeon Journal: Raids ~" or "~ The Dungeon Journal ~")
  local name = d[2]
  local first = B.FirstChar(name)
  T.cap:SetText(first); T.title:SetText(name:sub(#first + 1))
  T.info:SetText((raid and "Raid  -  level 60" or ("Dungeon  -  levels %d to %d"):format(d[4], d[5])) .. "  -  " .. d[3])
  T.lore:SetText(d[8])
  T.finalHead:SetText(#d[7] > 1 and "Its masters" or "Its master")
  T.finals:SetText(table.concat(d[7], ", "))
  -- this character's tally here
  local k = Kills()
  local slain, total = 0, #d[9]
  for _, b in ipairs(d[9]) do if (k[b[1]] or 0) > 0 then slain = slain + 1 end end
  local mine, last = 0, nil
  local ck = CK()
  for _, rec in ipairs(J().runs) do
    if rec.dun == d[2] and rec.ck == ck then mine = mine + 1; if not last or rec.done > last then last = rec.done end end
  end
  local lines = {}
  lines[#lines + 1] = ("Runs completed: |cff7a1a10%d|r%s"):format(mine, last and ("  (last on " .. When(last, "%b %d, %Y") .. ")") or "")
  lines[#lines + 1] = ("Bosses you have slain here: |cff7a1a10%d|r of %d"):format(slain, total)
  local run = Cur()
  if run and run.dun == jIdx and DungeonHere() then
    lines[#lines + 1] = ("|cff1a6a1aYou are in this dungeon now|r - %d boss%s down, %d spoil%s so far."):format(#run.bosses,
      #run.bosses == 1 and "" or "es", #run.loot, #run.loot == 1 and "" or "s")
  end
  T.stats:SetText(table.concat(lines, "\n"))
end

local function RenderSpoils(d)
  local B = NS.Book
  local S = R.spoils
  local j = J()
  S.usable.Sync()
  local k = Kills()
  local lvl = UnitLevel("player") or 1
  local finals = {}
  for _, f in ipairs(d[7]) do finals[f] = true end
  local y, bi, ii, shownItems, hidden = 0, 0, 0, 0, 0
  local obs = (Drops() or {})[d[1]]
  local where = (FLAVOR == "forever") and "in Forever" or "by you"
  local bossList = {}
  for _, b in ipairs(d[9]) do bossList[#bossList + 1] = b end
  if obs then   -- bosses you've looted here that the Classic data doesn't have (new in Forever)
    local listed = {}
    for _, b in ipairs(d[9]) do listed[b[1]] = true end
    for name in pairs(obs.bosses) do
      if not listed[name] and BOSSDUN[d[1]] and not BOSSDUN[d[1]][name] then bossList[#bossList + 1] = { name, "?", {}, new = true } end
    end
  end
  for _, b in ipairs(bossList) do
    bi = bi + 1
    local h = BossRow(bi)
    h:ClearAllPoints(); h:SetPoint("TOPLEFT", 0, -y)
    h.name:SetText(b[1]); Ink(h.name, finals[b[1]] and B.RUBRIC or B.INK)
    h.lvl:SetText(b.new and ("|cff1a6a1anew " .. where .. "|r") or ((finals[b[1]] and "final boss  -  " or "") .. "level " .. b[2]))
    local ob = obs and obs.bosses[b[1]]
    local n = k[b[1]] or 0
    h.kills:SetText(n > 0 and ("|cff1a6a1aslain " .. n .. (n == 1 and " time" or " times") .. "|r") or "|cff8a7050not yet slain|r")
    h:Show()
    y = y + 28
    local any = false
    local loot = b[3]
    for x = 1, #loot, 2 do
      local id, ch = loot[x], loot[x + 1]
      local it = ITEMS[id]
      if it then
        local ok = Usable(id)
        if ok or not j.usable then
          ii = ii + 1; any = true; shownItems = shownItems + 1
          local r = ItemRow(ii, S.list, itemRows)
          r:ClearAllPoints(); r:SetPoint("TOPLEFT", 0, -y)
          r.id, r.link, r.chance, r.seen = id, nil, ch, nil
          r.icon:SetTexture((GetItemIcon and GetItemIcon(id)) or "Interface\\Icons\\INV_Misc_QuestionMark")
          r.icon:SetDesaturated(not ok); r.icon:SetAlpha(ok and 1 or 0.55)
          local c = QCOL[it[4]] or B.INK
          r.name:SetText(it[6] or ("item " .. id)); r.name:SetTextColor(c[1], c[2], c[3], ok and 1 or 0.55)
          local req = it[3] or 0
          local kind = Kind(it)
          local reqTxt = (req > 0) and ((req > lvl) and ("|cffb01010lvl " .. req .. "|r") or ("lvl " .. req)) or ""
          local parts = {}
          if kind ~= "" then parts[#parts + 1] = kind end
          if reqTxt ~= "" then parts[#parts + 1] = reqTxt end
          parts[#parts + 1] = ch .. "%"
          if ob and ob.kills > 0 then
            local n = ob.items[id] or 0
            parts[#parts + 1] = (n > 0 and "|cff1a6a1a" or "|cff8a7050") .. "seen " .. n .. "/" .. ob.kills .. "|r"
            r.seen = ("Seen dropping %s: %d of %d kills you looted"):format(where, n, ob.kills)
          end
          r.right:SetText(table.concat(parts, "  -  "))
          r:Show()
          y = y + 20
        else
          hidden = hidden + 1
        end
      end
    end
    -- items you've seen this boss drop that the Classic data doesn't list
    if ob then
      local inList = {}
      for x = 1, #loot, 2 do inList[loot[x]] = true end
      local extra = {}
      for id, n in pairs(ob.items) do if not inList[id] then extra[#extra + 1] = id end end
      table.sort(extra, function(a, c) return (ob.items[a] or 0) > (ob.items[c] or 0) end)
      for _, id in ipairs(extra) do
        local n = ob.items[id]
        local iname, ilink, iq, _, ireq = GetItemInfo(id)
        local it = ITEMS[id]
        local ok = not it or Usable(id)
        if ok or not j.usable then
          ii = ii + 1; any = true; shownItems = shownItems + 1
          local r = ItemRow(ii, S.list, itemRows)
          r:ClearAllPoints(); r:SetPoint("TOPLEFT", 0, -y)
          r.id, r.link, r.chance = id, ilink, nil
          r.seen = ("New %s - seen dropping in %d of %d kills you looted"):format(where, n, ob.kills)
          r.icon:SetTexture((GetItemIcon and GetItemIcon(id)) or "Interface\\Icons\\INV_Misc_QuestionMark")
          r.icon:SetDesaturated(false); r.icon:SetAlpha(1)
          local c = QCOL[(it and it[4]) or iq or 1] or B.INK
          r.name:SetText((it and it[6]) or iname or ("item " .. id)); r.name:SetTextColor(c[1], c[2], c[3], 1)
          local req = (it and it[3]) or ireq or 0
          local parts = {}
          if it and Kind(it) ~= "" then parts[#parts + 1] = Kind(it) end
          if req > 0 then parts[#parts + 1] = (req > lvl) and ("|cffb01010lvl " .. req .. "|r") or ("lvl " .. req) end
          parts[#parts + 1] = "|cff1a6a1anew  -  seen " .. n .. "/" .. ob.kills .. "|r"
          r.right:SetText(table.concat(parts, "  -  "))
          r:Show()
          y = y + 20
        else
          hidden = hidden + 1
        end
      end
    end
    if not any then
      ii = ii + 1
      local r = ItemRow(ii, S.list, itemRows)
      r:ClearAllPoints(); r:SetPoint("TOPLEFT", 0, -y)
      r.id, r.link, r.chance, r.seen = nil, nil, nil, nil
      r.icon:SetTexture(nil)
      r.name:SetText(#loot > 0 and "Nothing here your class can use" or "No gear of note"); r.name:SetTextColor(B.INK_FAINT[1], B.INK_FAINT[2], B.INK_FAINT[3])
      r.right:SetText("")
      r:Show()
      y = y + 20
    end
    y = y + 8
  end
  for i = bi + 1, #bossRows do bossRows[i]:Hide() end
  for i = ii + 1, #itemRows do itemRows[i]:Hide() end
  S.sub:SetText(("%d bosses  -  %d pieces of gear%s"):format(#bossList, shownItems, hidden > 0 and ("  (" .. hidden .. " hidden)") or ""))
  S.list:SetHeight(math.max(1, y))
  S.sf:SetVerticalScroll(0); S.sf.Update()
end

local function RenderChronicle(d)
  local B = NS.Book
  local C = L.chron
  C.chapter:SetText("~ " .. d[2] .. " ~")
  C.all.Sync()
  local runs = ShownRuns(d)
  C.sub:SetText(#runs == 0 and "No runs recorded yet" or (#runs .. " run" .. (#runs == 1 and "" or "s") .. " to the final boss"))
  local y = 0
  for i, rec in ipairs(runs) do
    local r = RunRow(i)
    r.rec = rec
    r:ClearAllPoints(); r:SetPoint("TOPLEFT", 0, -y)
    r.when:SetText(When(rec.done or rec.start, "%b %d, %Y  -  %I:%M %p"))
    r.num:SetText("#" .. (#runs - i + 1))
    local who = (J().allChars and rec.ck) and (rec.ck:match("%.(.+)$") .. "  -  ") or ""
    local nl = #(rec.loot or {})
    r.info:SetText(("%s%d in the company  -  %d boss%s  -  %d spoil%s%s"):format(who, #(rec.company or {}),
      #(rec.bosses or {}), #(rec.bosses or {}) == 1 and "" or "es", nl, nl == 1 and "" or "s",
      (rec.start and rec.done) and ("  -  " .. Dur(rec.start, rec.done)) or ""))
    r.sel:SetShown(selRun == rec)
    r:Show()
    y = y + 40
  end
  for i = #runs + 1, #runRows do runRows[i]:Hide() end
  C.list:SetHeight(math.max(1, y))
  C.sf.Update()
  C.empty:SetShown(#runs == 0)
  C.empty:SetText("When the final boss of " .. d[2] .. " falls with you there, the run is written here: the date and time, " ..
    "who stood with you (name, level and class) and any gear you looted.")
  if not selRun and runs[1] then selRun = runs[1] end
  return runs
end

local function RenderRun(d)
  local B = NS.Book
  local Dt = R.detail
  local rec = selRun
  for _, f in ipairs(Dt.heads) do f:Hide() end
  for _, f in ipairs(Dt.texts) do f:Hide() end
  if not rec then
    Dt.title:SetText(""); Dt.sub:SetText("")
    for _, r in ipairs(mateRows) do r:Hide() end
    for _, r in ipairs(lootRows) do r:Hide() end
    Dt.empty:SetText("No run to show yet."); Dt.empty:Show()
    Dt.list:SetHeight(1); Dt.sf.Update()
    return
  end
  Dt.empty:Hide()
  Dt.title:SetText(When(rec.done or rec.start, "%A, %B %d, %Y"))
  local sub = {}
  if rec.start then sub[#sub + 1] = "Entered " .. When(rec.start, "%I:%M %p") end
  if rec.done then sub[#sub + 1] = (rec.finals and rec.finals[1] or "the final boss") .. " fell at " .. When(rec.done, "%I:%M %p") end
  local dur = Dur(rec.start, rec.done)
  Dt.sub:SetText(table.concat(sub, "  -  ") .. (dur ~= "" and ("  (" .. dur .. ")") or ""))
  local y, hi, ti = 4, 0, 0
  local function Head(text)
    hi = hi + 1; local f = DetailHead(hi); f:ClearAllPoints(); f:SetPoint("TOPLEFT", 0, -y); f:SetText(text); f:Show(); y = y + 26
  end
  local function Text(text, ink)
    ti = ti + 1; local f = DetailText(ti); f:ClearAllPoints(); f:SetPoint("TOPLEFT", 4, -y); f:SetText(text)
    Ink(f, ink or B.INK); f:Show(); y = y + math.max(16, f:GetStringHeight() or 16) + 6
  end
  -- the company
  local comp = rec.company or {}
  Head("The company")
  local half = (B.PAGE_W - 76) / 2
  for i, m in ipairs(comp) do
    local r = MateRow(i)
    local col, row = (i - 1) % 2, math.floor((i - 1) / 2)
    r:ClearAllPoints(); r:SetPoint("TOPLEFT", col * half, -(y + row * 36))
    local tc = CLASS_TC[m[3]]
    if tc then r.icon:SetTexCoord(tc[1], tc[2], tc[3], tc[4]); r.icon:Show() else r.icon:Hide() end
    r.name:SetText(m[1]); r.name:SetTextColor(ClassInk(m[3]))
    r.info:SetText(("Level %s %s"):format((m[2] and m[2] > 0) and m[2] or "?", ClassName(m[3])))
    r:Show()
  end
  for i = #comp + 1, #mateRows do mateRows[i]:Hide() end
  y = y + math.ceil(#comp / 2) * 36 + 8
  -- bosses slain
  Head("Bosses slain")
  Text(#(rec.bosses or {}) > 0 and table.concat(rec.bosses, ", ") or "-")
  -- spoils
  Head("Your spoils")
  local loot = rec.loot or {}
  if #loot == 0 then Text("Nothing of note came your way this time.", B.INK_SOFT) end
  for i, link in ipairs(loot) do
    local r = ItemRow(i, Dt.list, lootRows)
    r:ClearAllPoints(); r:SetPoint("TOPLEFT", 0, -y)
    local bare, cnt = link:match("^(.-)x(%d+)$"); bare = bare or link
    r.id, r.link, r.chance = nil, link, nil
    local id = tonumber(bare:match("item:(%d+)"))
    r.icon:SetTexture((id and GetItemIcon and GetItemIcon(id)) or "Interface\\Icons\\INV_Misc_QuestionMark")
    r.icon:SetDesaturated(false); r.icon:SetAlpha(1)
    local nm = bare:match("|h%[(.-)%]|h") or "item"
    local hex = bare:match("|cff(%x%x%x%x%x%x)")
    local c = QCOL[hex and LINKQ[hex:lower()] or 0] or B.INK
    r.name:SetText(nm); r.name:SetTextColor(c[1], c[2], c[3], 1)
    local it = id and ITEMS[id]
    r.right:SetText((cnt and ("x" .. cnt .. "  ") or "") .. (it and Kind(it) or ""))
    r:Show()
    y = y + 20
  end
  for i = #loot + 1, #lootRows do lootRows[i]:Hide() end
  Dt.list:SetHeight(math.max(1, y + 8))
  Dt.sf:SetVerticalScroll(0); Dt.sf.Update()
end

-- the book's bottom bar: pick a dungeon, and flip between the lore and the chronicle of runs
function NS.JournalPick(owner)
  local items = { { text = "Dungeons", header = true } }
  for i, d in ipairs(DUN) do if d[6] == 0 then items[#items + 1] = { text = d[2], right = d[4] .. "-" .. d[5], value = i } end end
  items[#items + 1] = { text = "Raids", header = true }
  for i, d in ipairs(DUN) do if d[6] == 1 then items[#items + 1] = { text = d[2], right = "60", value = i } end end
  if NS.ShowMenu then
    NS.ShowMenu(owner, items, function(v)
      if not v then return end
      local dir = (v >= (jIdx or 1)) and 1 or -1
      jIdx, jPage, selRun = v, 1, nil; Turn(dir)
    end)
  end
end
function NS.JournalFlip()
  if jPage == 2 then jPage, selRun = 1, nil; Turn(-1) else jPage, selRun = 2, nil; Turn(1) end
end

function NS.ShowJournalPages(on)
  if on and not L then BuildPages() end
  if L then L:SetShown(on); R:SetShown(on) end
end

function NS.RenderJournal()
  if not JD or #DUN == 0 then return end
  if not L then BuildPages() end
  if not J() then return end
  BuildCanUse()
  if not jIdx then jIdx = DefaultDungeon() end
  jPage = jPage or 1
  local d = DUN[jIdx]
  local w = NS.Win()
  local two = (jPage == 2)
  if w and w.jFlip then w.jFlip:SetText(two and "Lore & spoils" or "Chronicle of runs") end
  L.tale:SetShown(not two); R.spoils:SetShown(not two)
  L.chron:SetShown(two); R.detail:SetShown(two)
  if w and w.pageL then
    w.pageL:SetText("~ " .. (jIdx * 4 - (two and 1 or 3)) .. " ~"); w.pageR:SetText("~ " .. (jIdx * 4 - (two and 0 or 2)) .. " ~")
  end
  if two then
    local runs = RenderChronicle(d)
    local found = false
    for _, r in ipairs(runs) do if r == selRun then found = true end end
    if not found then selRun = runs[1] end
    RenderRun(d)
  else
    RenderTale(d)
    RenderSpoils(d)
  end
end

local pending
function NS.JournalRefresh()
  if pending then return end
  pending = true
  C_Timer.After(0.3, function()
    pending = false
    if L and L:IsVisible() then NS.RenderJournal() end
  end)
end
-- open straight to a dungeon (used by /qb journal while inside one)
function NS.JournalOpenHere()
  if DungeonHere() then jIdx, jPage, selRun = DefaultDungeon(), 1, nil end
end
