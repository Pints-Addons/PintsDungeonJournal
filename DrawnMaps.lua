-- Pint's Dungeon Journal: our own drawn maps of dungeons the game has no map of (WoW Forever and Classic Era have none of
-- the Classic dungeons). Each is a plan of the halls drawn for this add-on: the layout from the dungeon maps on Wowhead and
-- Icy Veins, lined up with where the creatures stand (CMaNGOS Classic database), the boss and entrance marks from
-- BossSpots.lua. North is up. Some dungeons have floors above or below the one drawn; their bosses are marked where they
-- stand, over the floor shown.
-- [dungeon] = { texture in Maps\, { { boss number, name, x, y }, ... }, { { label, x, y }, ... }, { A, B, C, D } }
--   x, y: 0-1 across the map; the last table puts you on it: across = A * y + B, down = C * x + D (world position);
--   six numbers instead: across = a * x + b * y + c, down = d * x + e * y + f (a map drawn turned a little)
PintsJournalDrawnMaps = {
	["Upper Blackrock Spire"] = { "UBRS", {}, {},
		{ -0.0000125, -0.0013182, -0.0237310, -0.0013182, 0.0000125, 0.5808509 } },
	["Hall of Thanes"] = { "HallOfThanes", {}, {} },   -- (WoW Forever; no world positions known yet, so no "you" arrow)
	["Ruins of Lordaeron"] = { "RuinsOfLordaeron", {}, {} },   -- (WoW Forever; no world positions known yet)
	["Excavation Site: Wetlands"] = { "ExcavationSite", {}, {} },   -- (WoW Forever; no world positions known yet)
	["The Drowned City"] = { "DrownedCity", {}, {} },   -- (WoW Forever; no world positions known yet)
	["Krol'dok Stronghold"] = { "Kroldok", {}, {} },   -- (WoW Forever; no world positions known yet)
	["Alcaz Prison"] = { "AlcazPrison", {}, {} },   -- (WoW Forever; no world positions known yet)
	["Blackmaw Hold"] = { floors = {   -- (WoW Forever; no world positions known yet)
		{ "Blackmaw1", "1. Blackmaw Grove", {}, {} },
		{ "Blackmaw2", "2. Festering Grotto", {}, {} },
		{ "Blackmaw3", "3. Fallen Grove", {}, {} },
		{ "Blackmaw4", "4. Depths of the Elders", {}, {} },
		{ "Blackmaw5", "5. The Burrow", {}, {} },
		{ "Blackmaw6", "6. Forbidden Magic", {}, {} },
	} },
	["Shaper's Terrace"] = { "ShapersTerrace", {}, {} },   -- (WoW Forever; schematic - no overhead map published yet)
	["Lower Blackrock Spire"] = { floors = {
		{ "LBRS1", "1. Hordemar City", {}, {}, { -0.0000096, -0.0013743, -0.0491427, -0.0013743, 0.0000096, 0.5757469 } },
		{ "LBRS2", "2. Skitterweb", {}, {}, { -0.0000096, -0.0013743, -0.0491427, -0.0013743, 0.0000096, 0.5757469 } },
		{ "LBRS3", "3. Mok'Doom", {}, {}, { -0.0000096, -0.0013743, -0.0491427, -0.0013743, 0.0000096, 0.5757469 } },
		{ "LBRS4", "4. Hall of Blackhand", {}, {}, { -0.0000096, -0.0013743, -0.0491427, -0.0013743, 0.0000096, 0.5757469 } },
		{ "LBRS5", "5. Halycon & Storehouse", {}, {}, { -0.0000096, -0.0013743, -0.0491427, -0.0013743, 0.0000096, 0.5757469 } },
		{ "LBRS6", "6. Chamber of Battle", {}, {}, { -0.0000096, -0.0013743, -0.0491427, -0.0013743, 0.0000096, 0.5757469 } },
	} },
	["Zul'Farrak"] = { "ZulFarrakD", {}, {},
		{ -0.0000120, -0.0007719, 1.3081074, -0.0007719, 0.0000120, 1.7763070 } },
	["Scarlet Monastery: Armory"] = { "SMArmoryD", {}, {},
		{ 0.0000003, -0.0016486, -0.1282718, -0.0016486, -0.0000003, 3.5506754 } },
	["Scarlet Monastery: Graveyard"] = { "SMGraveyardD", {}, {},
		{ -0.0000660, -0.0019619, 3.0633420, -0.0019619, 0.0000660, 3.9394730 } },
	["Scarlet Monastery: Cathedral"] = { "SMCathedralD", {}, {},
		{ 0.0000005, -0.0017642, 2.9459289, -0.0017642, -0.0000005, 2.4066226 } },
	["Blackrock Depths"] = { floors = {
		{ "BRD1", "1. Detention & Highway", {}, {}, { 0.0000028, -0.0008779, 0.3677002, -0.0008779, -0.0000028, 1.0483621 } },
		{ "BRD2", "2. Shadowforge City", {}, {}, { 0.0000025, -0.0007871, 0.1563864, -0.0007871, -0.0000025, 1.4378419 } },
	} },
	["Blackfathom Deeps"] = { "BlackfathomDeeps", {}, {},
		{ -0.0006321, 0.44569, -0.0006321, 0.22666 } },
	["Dire Maul: East"] = { floors = {
		{ "DMEast1", "1. Lower Level", {}, {}, { -0.0000002, -0.0009041, 0.0380431, -0.0009041, 0.0000002, 0.6194447 }, { -200, -20 } },
		{ "DMEast2", "2. Upper Level", {}, {}, { -0.0000002, -0.0009041, 0.0380431, -0.0009041, 0.0000002, 0.6194447 }, { -20, 60 } },
	} },
	["Dire Maul: North"] = { "DMNorthD", {}, {},
		{ -0.0000661, -0.0008031, 0.7440654, -0.0008031, 0.0000661, 0.9822829 } },
	["Dire Maul: West"] = { "DMWestD", {}, {},
		{ -0.0000002, -0.0007456, 0.8222542, -0.0007456, 0.0000002, 0.5468202 } },
	["The Deadmines"] = { floors = {
		{ "Deadmines1", "1. The Mines", {}, {}, { 0.0001287, -0.0015066, -0.2387974, -0.0015066, -0.0001287, 0.2497174 }, { 30, 80 } },
		{ "Deadmines2", "2. Ironclad Cove", {}, {}, { -0.0001012, -0.0019860, -0.9526732, -0.0019860, 0.0001012, 0.3973785 }, { -10, 30 } },
	} },
	["Gnomeregan"] = { "Gnomeregan", {}, {},
		{ -0.0007886, 0.73455, -0.0007886, 0.08735 } },
	["Maraudon"] = { "MaraudonD", {}, {},
		{ 0.0000022, -0.0005052, 0.3710326, -0.0005052, -0.0000022, 0.8354907 } },
	["Ragefire Chasm"] = { "RagefireChasm", {}, {},
		{ -0.0012327, 0.61570, -0.0012327, 0.28042 } },
	["Razorfen Downs"] = { "RazorfenDownsD", {}, {},
		{ -0.0000041, -0.0016344, 1.9363371, -0.0016344, 0.0000041, 4.5565942 } },
	["Razorfen Kraul"] = { "RazorfenKraul", {}, {},
		{ 0.0000558, -0.0013304, 2.6708877, -0.0013304, -0.0000558, 3.3743963 } },
	["Scarlet Monastery: Library"] = { "SMLibraryD", {}, {},
		{ 0.0000125, -0.0027395, -0.3934961, -0.0027395, -0.0000125, 1.0703810 } },
	["Scholomance"] = { "ScholomanceD", {}, {},
		{ -0.0000139, -0.0017160, 0.5934100, -0.0017160, 0.0000139, 0.8036799 } },
	["The Stockade"] = { "Stockade", {}, {},
		{ -0.0025843, 0.49694, -0.0025843, 0.77332 } },
	["Stratholme: Live"] = { start = 1, floors = {
		{ "StratLive", "1. Live Side", {}, {}, { 0.0000055, -0.0011830, -3.3162979, -0.0011830, -0.0000055, 4.7229337 } },
		{ "StratDead", "2. Dead Side", {}, {}, { 0.0000043, -0.0009180, -2.7008734, -0.0009180, -0.0000043, 4.0541802 } },
	} },
	["Stratholme: Undead"] = { start = 2, floors = {
		{ "StratLive", "1. Live Side", {}, {}, { 0.0000055, -0.0011830, -3.3162979, -0.0011830, -0.0000055, 4.7229337 } },
		{ "StratDead", "2. Dead Side", {}, {}, { 0.0000043, -0.0009180, -2.7008734, -0.0009180, -0.0000043, 4.0541802 } },
	} },
	["Sunken Temple"] = { floors = {
		{ "SunkenTemple1", "1. Upper Temple", {}, {}, { 0.0000002, -0.0012779, 0.6216612, -0.0012779, -0.0000002, -0.0774615 }, { -125, -30 } },
		{ "SunkenTemple2", "2. The Pit", {}, {}, { 0.0000002, -0.0012779, 0.6216612, -0.0012779, -0.0000002, -0.0774615 }, { -220, -125 } },
	} },
	["Uldaman"] = { "UldamanD", {}, {},
		{ 0.0000064, -0.0010449, 0.7075193, -0.0010449, -0.0000064, 0.4312309 } },
	["Wailing Caverns"] = { "WailingCaverns", {}, {},
		{ -0.0008638, 0.57186, -0.0008638, 0.44422 } },
	-- Shadowfang Keep, floor by floor: each level redrawn over the layout of Blizzard's floor maps, the bosses and the
	-- courtyard's doors, cells and hearths placed from where they stand in the game (bosses are drawn into the art).
	-- "You" shows on the courtyard level (the only one lined up with the game's positions so far).
	["Shadowfang Keep"] = { floors = {
		{ "SFK1", "1. Courtyard", {}, {}, { -0.0026393, 6.40914, -0.0026393, -0.06412 }, { 60, 93 } },
		{ "SFK2", "2. Upper Floors" },
		{ "SFK3", "3. Stair Tower" },
		{ "SFK7", "4. Wall Walk" },
		{ "SFK4", "5. Fenrus' Den" },
		{ "SFK5", "6. Upper Keep" },
		{ "SFK6", "7. Arugal's Chamber" },
	} },
}
