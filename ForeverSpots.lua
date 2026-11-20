-- Pint's Dungeon Journal: where the bosses of WoW Forever's new dungeons stand, as map % on the game's own map, from Wowhead's
-- WoW Forever NPC pages (November 19, 2026). { order in the journal's list, name, uiMapID, x%, y% }
-- Only the City of Dalaran so far: Wowhead has no in-dungeon positions yet for the other new dungeons' bosses.
if type(issecretvalue) ~= "function" then return end   -- (WoW Forever only)
PintsJournalForeverSpots = {
	["City of Dalaran"] = {
		{ 1, "Atrexis the Grave Knight", 1416, 15.0, 68.0 },
		{ 2, "Lyn the Ignored", 1416, 21.2, 68.1 },
		{ 3, "Arcane Anomaly", 1416, 18.9, 75.3 },
		{ 4, "Arcanic Enigma", 1416, 20.3, 64.2 },
		{ 5, "Unstable Sentinel", 1416, 17.6, 61.8 },
		{ 6, "Fel Ancient", 1416, 16.4, 67.2 },
		{ 7, "Mana Devourer", 1416, 15.2, 75.8 },
		{ 8, "Shade of the Archmage", 1416, 15.2, 55.9 },
	},
}
