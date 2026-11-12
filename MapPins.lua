-- Pint's Dungeon Journal: a dungeon (or raid) icon on the world map at every entrance - zone maps and continents -
-- for the original dungeons and WoW Forever's new ones. Hover for the dungeons there and their levels.
-- Ctrl-click: open it in the journal (Ctrl-Shift-click: point the arrow there). A plain click still zooms the map.
--   Entrances: built in (Classic positions); on WoW Forever also the ones the game knows; and any you walk into
--   yourself is remembered (so a new dungeon without a built-in spot gets its icon after your first visit).
local ADDON, NS = ...
local JD = PintsJournalData
local QB = _G.PintsDungeonJournal

-- { uiMapID, x, y, { dungeon names }, approx }   (zone map positions; names as in the journal)
local ENTRANCES = {
	{ 1454, 51.8, 49.6, { "Ragefire Chasm" } },
	{ 1413, 46.0, 36.4, { "Wailing Caverns" } },
	{ 1436, 42.6, 71.9, { "The Deadmines" } },
	{ 1421, 44.8, 67.8, { "Shadowfang Keep" } },
	{ 1440, 14.2, 14.0, { "Blackfathom Deeps" } },
	{ 1453, 50.5, 66.3, { "The Stockade" }, true },
	{ 1426, 24.3, 39.7, { "Gnomeregan" } },
	{ 1413, 42.3, 89.9, { "Razorfen Kraul" } },
	{ 1420, 82.6, 33.8, { "Scarlet Monastery: Graveyard", "Scarlet Monastery: Library", "Scarlet Monastery: Armory", "Scarlet Monastery: Cathedral" } },
	{ 1413, 49.0, 93.9, { "Razorfen Downs" } },
	{ 1418, 42.9, 13.0, { "Uldaman" } },
	{ 1446, 38.7, 20.1, { "Zul'Farrak" } },
	{ 1443, 29.1, 62.6, { "Maraudon" } },
	{ 1435, 69.8, 53.5, { "Sunken Temple" } },
	{ 1428, 29.4, 38.3, { "Blackrock Depths", "Lower Blackrock Spire", "Upper Blackrock Spire", "Molten Core", "Blackwing Lair" } },
	{ 1427, 35.0, 84.0, { "Blackrock Depths", "Lower Blackrock Spire", "Upper Blackrock Spire", "Molten Core", "Blackwing Lair" } },
	{ 1444, 59.0, 44.8, { "Dire Maul: East", "Dire Maul: West", "Dire Maul: North" } },
	{ 1422, 69.7, 73.2, { "Scholomance" } },
	{ 1423, 31.2, 15.6, { "Stratholme: Live" } },
	{ 1423, 47.9, 23.9, { "Stratholme: Undead" } },
	{ 1434, 53.9, 17.6, { "Zul'Gurub" } },
	{ 1445, 52.6, 76.8, { "Onyxia's Lair" } },
	{ 1451, 36.5, 93.9, { "Ruins of Ahn'Qiraj" }, true },
	{ 1451, 28.6, 92.4, { "Temple of Ahn'Qiraj" }, true },
	{ 1423, 39.9, 25.9, { "Naxxramas" }, true },
	-- WoW Forever's new dungeons (best known spots; your own first visit replaces these)
	{ 1420, 61.7, 70.4, { "Ruins of Lordaeron" }, true },
	{ 1416, 19.0, 64.0, { "City of Dalaran" }, true },
	{ 1437, 38.0, 50.5, { "Excavation Site: Wetlands" }, true },
	{ 1434, 21.4, 27.9, { "The Drowned City" }, true },        -- (underwater past the Vile Reef, by a large tablet)
}

local function DB() local d = NS.DB and NS.DB(); return d end
local BYNAME = {}
for i, d in ipairs(JD and JD.dungeons or {}) do BYNAME[d[2]] = i end

-- every entrance: built in, then the game's own (WoW Forever), then the ones you've walked into (those win)
local function All()
	local out, seen = {}, {}
	local learned = DB() and DB().entrances or {}
	for name, e in pairs(learned) do
		out[#out + 1] = { e[1], e[2], e[3], { name } }
		seen[name] = true
	end
	for _, e in ipairs(ENTRANCES) do
		local names = {}
		for _, n in ipairs(e[4]) do if not seen[n] then names[#names + 1] = n end end
		if #names > 0 then out[#out + 1] = { e[1], e[2], e[3], names, e[5] } end
	end
	return out
end

-- the game's own entrances for a map (WoW Forever), for dungeons the journal knows that have no spot yet
local function GameEntrances(mapID, have)
	local out = {}
	if not (C_EncounterJournal and C_EncounterJournal.GetDungeonEntrancesForMap) then return out end
	local ok, list = pcall(C_EncounterJournal.GetDungeonEntrancesForMap, mapID)
	if not ok or type(list) ~= "table" then return out end
	for _, e in ipairs(list) do
		local name, pos = e.name, e.position
		if type(name) == "string" and pos and not have[name] then
			local x, y = pos:GetXY()
			out[#out + 1] = { mapID, x * 100, y * 100, { name } }
		end
	end
	return out
end

---------------------------------------------------------------- the pins
PintsDJDungeonPinMixin = CreateFromMixins and MapCanvasPinMixin and CreateFromMixins(MapCanvasPinMixin) or {}
function PintsDJDungeonPinMixin:SetPassThroughButtons() end
function PintsDJDungeonPinMixin:SetPropagateMouseClicks() end
function PintsDJDungeonPinMixin:OnLoad()
	if self.UseFrameLevelType then pcall(self.UseFrameLevelType, self, "PIN_FRAME_LEVEL_DUNGEON_ENTRANCE") end
	if self.SetScalingLimits then pcall(self.SetScalingLimits, self, 1, 0.9, 1.3) end
end
local function Raid(names)
	for _, n in ipairs(names) do local i = BYNAME[n]; if not (i and JD.dungeons[i][6] == 1) then return false end end
	return true
end
function PintsDJDungeonPinMixin:OnAcquired(e, x, y, small)
	self.e = e
	self:SetPosition(x, y)
	local s = small and 19 or 26
	self:SetSize(s, s)
	if not self.icon then self.icon = self:CreateTexture(nil, "ARTWORK"); self.icon:SetAllPoints() end
	-- (a dark outline behind the icon, so it stands out on the map)
	if not self.edge then
		self.edge = self:CreateTexture(nil, "BACKGROUND")
		self.edge:SetPoint("TOPLEFT", -3, 3); self.edge:SetPoint("BOTTOMRIGHT", 3, -3)
	end
	local raid = Raid(e[4])
	local ok = self.icon.SetAtlas and pcall(self.icon.SetAtlas, self.icon, raid and "Raid" or "Dungeon")
	if not ok or not self.icon:GetAtlas() then
		self.icon:SetTexture(raid and "Interface\\Icons\\INV_Misc_Head_Dragon_Black" or "Interface\\Icons\\INV_Misc_Bone_HumanSkull_01")
		self.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
		self.edge:SetColorTexture(0, 0, 0, 0.9)
	else
		self.edge:SetAtlas(raid and "Raid" or "Dungeon"); self.edge:SetVertexColor(0, 0, 0, 0.85)
	end
	self:SetScript("OnEnter", self.OnMouseEnter); self:SetScript("OnLeave", self.OnMouseLeave)
	self:SetScript("OnMouseUp", function(pin, button) pin:OnClick(button) end)
	-- clicks only while Ctrl is held: a plain click on the map stays the game's own (zooming), with no add-on in the way
	if self.SetMouseClickEnabled then self:SetMouseMotionEnabled(true); self:SetMouseClickEnabled(IsControlKeyDown() and true or false) end
end
function PintsDJDungeonPinMixin:OnMouseEnter()
	local e = self.e
	if not e then return end
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
	local me = UnitLevel("player") or 1
	for _, n in ipairs(e[4]) do
		local i = BYNAME[n]
		local d = i and JD.dungeons[i]
		if d then
			local lo, hi = d[4], d[5]
			local c = (me < lo - 2 and { 1, 0.2, 0.2 }) or (me < lo and { 1, 0.5, 0.25 }) or (me <= hi and { 1, 0.82, 0 }) or { 0.25, 0.75, 0.25 }
			GameTooltip:AddDoubleLine(n .. (d[6] == 1 and "  |cffa0a0a0(raid)|r" or ""), lo == hi and tostring(lo) or (lo .. "-" .. hi), c[1], c[2], c[3], c[1], c[2], c[3])
		else
			GameTooltip:AddLine(n, 1, 0.82, 0)
		end
	end
	if e[5] then GameTooltip:AddLine("Entrance spot approximate - walk in once and it's remembered exactly", 0.6, 0.6, 0.6, true) end
	GameTooltip:AddLine("Ctrl-click: open in the journal   Ctrl-Shift-click: point the way", 0.5, 0.8, 1, true)
	GameTooltip:Show()
end
function PintsDJDungeonPinMixin:OnMouseLeave() GameTooltip:Hide() end
function PintsDJDungeonPinMixin:OnClick(button)
	local e = self.e
	if not (e and IsControlKeyDown()) then return end
	if IsShiftKeyDown() then
		local cont, wx, wy = NS.MapToWorld and NS.MapToWorld(e[1], e[2], e[3])
		local QBk = _G.PintsQuestBook
		local arrow = NS.ArrowTo or (QBk and QBk.ArrowTo)
		if cont and arrow then arrow(cont, wx, wy, e[4][1])
		else print(("|cffd4a24cDungeon Journal|r: %s - entrance at %.1f, %.1f."):format(e[4][1], e[2], e[3])) end
		return
	end
	local i = BYNAME[e[4][1]]
	if i and NS.JournalOpenTo then NS.JournalOpenTo(i) end
end

---------------------------------------------------------------- where an entrance shows on a bigger map
local rects = {}
local function RectOn(zone, top)
	local key = zone .. ">" .. top
	if rects[key] == nil then
		rects[key] = false
		if C_Map and C_Map.GetMapRectOnMap then
			local ok, a, b, c, d = pcall(C_Map.GetMapRectOnMap, zone, top)
			if ok and a and b and c and d and b > a and d > c then rects[key] = { a, b, c, d } end
		end
	end
	return rects[key] or nil
end

local Provider
local function Build()
	if Provider or not (MapCanvasDataProviderMixin and WorldMapFrame and WorldMapFrame.AddDataProvider) then return end
	Provider = CreateFromMixins(MapCanvasDataProviderMixin)
	function Provider:RemoveAllData() self:GetMap():RemoveAllPinsByTemplate("PintsDJDungeonPinTemplate") end
	function Provider:RefreshAllData()
		self:RemoveAllData()
		local d = DB()
		if d and d.dungeonPins == false then return end
		local map = self:GetMap()
		local mapID = map:GetMapID()
		local info = mapID and C_Map.GetMapInfo(mapID)
		if not info then return end
		local list = All()
		local have = {}
		for _, e in ipairs(list) do for _, n in ipairs(e[4]) do have[n] = true end end
		for _, e in ipairs(GameEntrances(mapID, have)) do list[#list + 1] = e end
		local small = (info.mapType or 3) <= 2
		for _, e in ipairs(list) do
			if e[1] == mapID then
				map:AcquirePin("PintsDJDungeonPinTemplate", e, e[2] / 100, e[3] / 100, false)
			else
				local r = RectOn(e[1], mapID)
				if r then
					local x, y = r[1] + (r[2] - r[1]) * e[2] / 100, r[3] + (r[4] - r[3]) * e[3] / 100
					if x >= 0 and x <= 1 and y >= 0 and y <= 1 then map:AcquirePin("PintsDJDungeonPinTemplate", e, x, y, small) end
				end
			end
		end
	end
	WorldMapFrame:AddDataProvider(Provider)
end
function NS.RefreshDungeonPins() if Provider and WorldMapFrame:IsShown() then Provider:RefreshAllData() end end

-- Ctrl down or up: the icons start or stop taking clicks
do
	local cf = CreateFrame("Frame")
	cf:RegisterEvent("MODIFIER_STATE_CHANGED")
	cf:SetScript("OnEvent", function(_, _, key)
		if key ~= "LCTRL" and key ~= "RCTRL" then return end
		if not (WorldMapFrame and WorldMapFrame:IsShown() and WorldMapFrame.EnumeratePinsByTemplate) then return end
		local on = IsControlKeyDown() and true or false
		for pin in WorldMapFrame:EnumeratePinsByTemplate("PintsDJDungeonPinTemplate") do
			if pin.SetMouseClickEnabled then pin:SetMouseClickEnabled(on) end
		end
	end)
end

---------------------------------------------------------------- learning entrances: where you were just before you went in
local last            -- { uiMapID, x, y, time } outdoors
local function Sample()
	if IsInInstance and IsInInstance() then return end
	local m = C_Map and C_Map.GetBestMapForUnit and C_Map.GetBestMapForUnit("player")
	if not m or (issecretvalue and issecretvalue(m)) then return end
	local ok, pos = pcall(C_Map.GetPlayerMapPosition, m, "player")
	if not ok or not pos then return end
	local x, y = pos:GetXY()
	if not x or (issecretvalue and (issecretvalue(x) or issecretvalue(y))) or x <= 0 then return end
	-- (a zone map, not a city's inner map or a cave)
	local info = C_Map.GetMapInfo(m)
	while info and info.mapType and info.mapType > 3 and info.parentMapID and info.parentMapID > 0 do
		local px, py
		local r = RectOn(m, info.parentMapID)
		if not r then break end
		px, py = r[1] + (r[2] - r[1]) * x, r[3] + (r[4] - r[3]) * y
		m, x, y = info.parentMapID, px, py
		info = C_Map.GetMapInfo(m)
	end
	last = { m, x * 100, y * 100, GetTime() }
end
local ticker = CreateFrame("Frame")
local acc = 0
ticker:SetScript("OnUpdate", function(_, el) acc = acc + el; if acc >= 2 then acc = 0; pcall(Sample) end end)
local ev = CreateFrame("Frame")
ev:RegisterEvent("PLAYER_ENTERING_WORLD"); ev:RegisterEvent("PLAYER_LOGIN")
ev:SetScript("OnEvent", function(_, e)
	if e == "PLAYER_LOGIN" then Build(); return end
	local inside, kind = IsInInstance()
	if not inside or (kind ~= "party" and kind ~= "raid") or not last or GetTime() - last[4] > 90 then return end
	local name, _, _, _, _, _, _, instID = GetInstanceInfo()
	local hit
	if not (issecretvalue and issecretvalue(name)) then
		for i, d in ipairs(JD.dungeons) do
			if d[1] == instID or d[2] == name or (type(name) == "string" and d[2]:find(name, 1, true)) then hit = d[2]; break end
		end
		hit = hit or name
	end
	local d = DB()
	if hit and d then
		d.entrances = d.entrances or {}
		if not d.entrances[hit] then
			d.entrances[hit] = { last[1], math.floor(last[2] * 10 + 0.5) / 10, math.floor(last[3] * 10 + 0.5) / 10 }
			print(("|cffd4a24cDungeon Journal|r: remembered the entrance to %s - it's on your map now."):format(hit))
		end
	end
end)
