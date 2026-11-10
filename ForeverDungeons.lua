-- Pint's Dungeon Journal: dungeons new in WoW Forever, from what was published about the Forever beta (boss loot by item id;
-- bosses and drops may still change). Added to the journal like the original dungeons.
-- (Where the game's map number isn't known yet - a negative number here - the dungeon is found by its name when you're inside.)
local JD = PintsJournalData
if not JD then return end
-- each one goes in among the original dungeons by level, so the menu and Prev / Next dungeon keep their order
local function Add(d)
	local list = JD.dungeons
	for i, x in ipairs(list) do
		if x[6] == d[6] and x[4] > d[4] then table.insert(list, i, d); return end
		if x[6] > d[6] then table.insert(list, i, d); return end
	end
	list[#list + 1] = d
end
local function Item(id, inv, cls, req, q, name) if not JD.items[id] then JD.items[id] = { inv, cls, req, q, 0, name } end end

Add({ 2999, "Ruins of Lordaeron", "Tirisfal Glades", 15, 22, 0, { "Rath'mael" },
	"Above the Undercity lie the shattered streets of Lordaeron's old capital. Spiders, ghouls, abominations and restless spirits now walk its alleys and market square, and somewhere among the graves the lich Rath'mael gathers the dead.",
	{
		{ "Witherfang", 17, { 271201, 33, 271202, 33, 271203, 33 } },
		{ "The Butcher", 17, { 271204, 33, 271205, 33, 271206, 33 } },
		{ "Viktor the Vile", "?", { 271211, 33, 271212, 33, 271218, 33 } },
		{ "The Abandoned", "?", { 271207, 33, 271208, 33, 271216, 33 } },
		{ "Bjork", "?", { 271209, 33, 271210, 33, 271217, 33 } },
		{ "Rath'mael", "?", { 271213, 33, 271214, 33, 271215, 33 } },
	} })
-- items[id] = { inventoryType, class*100+subclass, requiredLevel, quality, classMask, name }
Item(271201, 6, 403, 15, 3, "Atrophic Girdle")
Item(271202, 9, 402, 15, 3, "Witherbite Bracers")
Item(271203, 17, 210, 15, 3, "Segmented Spider Leg")
Item(271204, 13, 215, 15, 3, "Meathook Slicer")
Item(271205, 5, 403, 15, 3, "Abomination Bones")
Item(271206, 20, 401, 15, 3, "Leftover Abomination Skin")
Item(271211, 8, 403, 17, 3, "Vilewalkers")
Item(271212, 5, 402, 17, 3, "Bloodied Chestwraps")
Item(271218, 13, 207, 17, 3, "Vileblood Scimitar")
Item(271207, 7, 401, 17, 3, "Rotmender's Leggings")
Item(271208, 10, 403, 17, 3, "Grip of Fear")
Item(271216, 21, 204, 17, 3, "Scepter of the Abandoned")
Item(271209, 7, 403, 16, 3, "Bonerust Leggings")
Item(271210, 6, 401, 16, 3, "Tuskwrap Belt")
Item(271217, 17, 201, 16, 3, "Corpse Chopper")
Item(271213, 14, 406, 19, 3, "Mirror of Rath'mael")
Item(271214, 8, 401, 19, 3, "Rotmender's Treads")
Item(271215, 17, 210, 19, 3, "Coldspire Staff")

Add({ -1002, "City of Dalaran", "Alterac Mountains", 28, 35, 0, { "Shade of the Archmage" },
	"Behind its violet dome the city of the Kirin Tor has gone wrong. Unstable magic leaks through the sewers and streets, constructs and anomalies run loose, a fel grove has taken root, and something wearing an archmage's shadow waits at its heart. Reached through the sewer gate on the city's northwest side.",
	{
		{ "Atrexis the Grave Knight", 29, { 273036, 35, 273032, 36, 273033, 29 } },
		{ "Lyn the Ignored", "? (secret)", { 273053, 33, 273054, 33, 273055, 33 } },
		{ "Arcane Anomaly", "?", { 273031, 33, 273034, 33, 273035, 33 } },
		{ "Arcanic Enigma", "?", { 273043, 33, 273044, 33, 273045, 33 } },
		{ "Unstable Sentinel", "?", { 273046, 33, 273047, 33, 273048, 33 } },
		{ "Fel Ancient", "?", { 273037, 33, 273038, 33, 273039, 33 } },
		{ "Mana Devourer", "?", { 273040, 33, 273041, 33, 273042, 33 } },
		{ "Shade of the Archmage", "?", { 273049, 33, 273051, 33, 273052, 33 } },
	} })
Item(273036, 9, 401, 0, 3, "Graveweave Bindings")
Item(273032, 11, 400, 0, 3, "Bonebinder's Signet")
Item(273033, 26, 218, 0, 3, "Gravespike Repeater")
Item(273053, 21, 215, 0, 3, "Tendonscraper Dagger")
Item(273054, 10, 402, 0, 3, "Cartilage Shapers")
Item(273055, 14, 406, 0, 3, "Bonepile Gaze")
Item(273031, 11, 400, 0, 3, "Runemender's Seal")
Item(273034, 10, 401, 0, 3, "Ephemeral Grips")
Item(273035, 5, 403, 0, 3, "Mana-Warped Chain Shirt")
Item(273043, 26, 219, 0, 3, "Wand of Mana Concentration")
Item(273044, 20, 401, 0, 3, "Violet Sorcerer's Robes")
Item(273045, 16, 401, 0, 3, "Drape of Shifting Energy")
Item(273046, 17, 201, 0, 3, "Guardian's Dualblade")
Item(273047, 3, 402, 0, 3, "Unstable Crystalline Shoulderpads")
Item(273048, 7, 403, 0, 3, "Refractory Scaleguards")
Item(273037, 17, 206, 0, 3, "Felbough Arm")
Item(273038, 5, 402, 0, 3, "Garb of Fallen Felbark")
Item(273039, 6, 401, 0, 3, "Blightleaf Rope")
Item(273040, 17, 210, 0, 3, "Spine of the Devourer")
Item(273041, 6, 402, 0, 3, "Slitherwrap Girdle")
Item(273042, 8, 403, 0, 3, "Manascale Treads")
Item(273049, 2, 400, 0, 3, "Archmagister's Faceted Pendant")
Item(273051, 3, 401, 0, 3, "Violet Sorcerer's Mantle")
Item(273052, 23, 400, 0, 3, "Ponderous Orb")

-- The rest of WoW Forever's new dungeons. Loot by item number where it has been published (timesaver.gg, conquestcapped,
-- wowhead); where only the names are known yet, the item has a stand-in number below zero (shown by name, without a
-- tooltip) until the real one is out. Drop chances aren't known for any of them yet.
local nextStandIn = -2001
local function Named(name, inv, cls, req)
	local id = nextStandIn; nextStandIn = nextStandIn - 1
	JD.items[id] = { inv, cls, req or 0, 3, 0, name }
	return id
end

Add({ -1003, "Hall of Thanes", "Ironforge", 13, 18, 0, { "Durgen Dirgehammer" },
	"Deep in the bedrock beneath the Great Forge lie the tombs of Ironforge's ancient thanes. Dark Iron dwarves have broken in to plunder the dead, and the old guardians of the vault have woken. The way in is a web-covered passage in the High Seat, beside King Magni.",
	{
		{ "Faldrim Anvilmar", "?", { 270227, 0, 271096, 0, 271097, 0 } },
		{ "Magmatus", "?", { 270230, 0, 270231, 0, 271095, 0 } },
		{ "Plunder", "?", { 270228, 0, 270229, 0, 271098, 0 } },
		{ "Durgen Dirgehammer", "?", { 270256, 0, 270260, 0, 270261, 0 } },
	} })
Item(270227, 2, 400, 13, 3, "Ephemeral Choker")
Item(271096, 9, 401, 13, 3, "Aetherwisp Bracers")
Item(271097, 16, 401, 13, 3, "Spiritwraith Drape")
Item(270230, 6, 403, 13, 3, "Kindlegem Girdle")
Item(270231, 10, 402, 13, 3, "Flamefist Grips")
Item(271095, 21, 215, 13, 3, "Fang of Magmatus")
Item(270228, 17, 210, 13, 3, "Golemheart Stave")
Item(270229, 8, 403, 13, 3, "Treads of the Protector Golem")
Item(271098, 5, 403, 13, 3, "Golemguard Chest")
Item(270256, 21, 200, 13, 3, "Durgen's Crescent Axe")
Item(270260, 7, 402, 13, 3, "Direhammer Leggings")
Item(270261, 0, 401, 13, 3, "Robes of the Disgraced Thane")

Add({ -1004, "Excavation Site: Wetlands", "Wetlands", 26, 33, 0, { "Relic Guardian" },
	"Past a drowned marsh and a thicket thick with raptors, the Explorers' League dug up something the titans left behind - and the Dragonmaw orcs have taken the dig site for themselves. At its heart an ancient titan device still guards its relic.",
	{
		{ "Saltspine", "?", { 273022, 0, 273023, 0, 273024, 0 } },
		{ "Shadetooth", "?", { 273025, 0, 273026, 0, 273027, 0 } },
		{ "Highland Horror", "? (optional)", {} },
		{ "Relic Guardian", "?", { 273028, 0, 273029, 0, 273030, 0 } },
	} })
Item(273022, 7, 402, 26, 3, "Supple Bellyskin Leggings")
Item(273023, 6, 403, 26, 3, "Saltscale Girdle")
Item(273024, 8, 401, 26, 3, "Glinteye Slippers")
Item(273025, 8, 403, 26, 3, "Raptorclaw Greaves")
Item(273026, 5, 402, 26, 3, "Garb of Florid Feathers")
Item(273027, 23, 400, 26, 3, "Raptor's Gaze")
Item(273028, 3, 403, 28, 3, "Reliquary Mantle")
Item(273029, 26, 203, 28, 3, "Golemsight Long Gun")
Item(273030, 11, 400, 28, 3, "Ring of Power Regulation")

Add({ -1005, "The Drowned City", "Stranglethorn Vale", 35, 40, 0, { "Min'loth the Serpent" },
	"A sunken Gurubashi city - the lost city of I'lalai - has risen from the sea off Stranglethorn's west coast. Naga, undead trolls and the Saltseer pirates whose ship crashed into the ruins all fight over it. The way in is an underwater cavern, Sunken Hollow, west of the Vile Reef.",
	{
		{ "Zul'Alai", 37, { 274600, 0, 274598, 0, 274599, 0 } },
		{ "Var'Taka", 38, { 274602, 0, 274601, 0 } },
		{ "Captain Dreadrise", 38, { 274604, 0, 274605, 0, 274603, 0 } },
		{ "Deathless Marrow", 39, { 274606, 0, 274607, 0 } },
		{ "Primeval Elemental", 38, { 274612, 0, 274611, 0, 274613, 0, 274614, 0, 274615, 0 } },
		{ "Gill", "?", {} },
		{ "Min'loth the Serpent", 40, { 274610, 0, 274608, 0, 274609, 0 } },
	} })
-- (slots from the item names; the game's own tooltip shows the details)
Item(274600, 9, 0, 0, 3, "Berserker Shackles")
Item(274598, 13, 200, 0, 3, "Bloodslash Axe")
Item(274599, 9, 402, 0, 3, "Oathbound Bracers")
Item(274602, 7, 0, 0, 3, "Brinebelly Leggings")
Item(274601, 17, 206, 0, 3, "Harpoon of Command")
Item(274604, 26, 203, 0, 3, "Frosty Blunderbuss")
Item(274605, 6, 0, 0, 3, "Briny Sash")
Item(274603, 13, 207, 0, 3, "Dreadfrost Saber")
Item(274606, 17, 210, 0, 3, "Bloodspine Staff")
Item(274607, 3, 0, 0, 3, "Viscera Spaulders")
Item(274612, 16, 401, 0, 3, "Waterlogged Burial Shroud")
Item(274611, 0, 401, 0, 3, "Robe of the Drowned")
Item(274613, 16, 401, 0, 3, "Priestess Cloak")
Item(274614, 11, 400, 0, 3, "Knucklebone Ring")
Item(274615, 12, 400, 0, 3, "Heart of the Primeval")
Item(274610, 10, 0, 0, 3, "Ritual-Binder's Gloves")
Item(274608, 13, 0, 0, 3, "Maw of Min'loth")
Item(274609, 1, 0, 0, 3, "Serpentbane Crown")

Add({ -1006, "Krol'dok Stronghold", "Riverglades", 40, 45, 0, { "Overlord Mugg" },
	"An ogre fortress on the hill above Sunnyglade, on the north side of the Riverglades, where something is stirring strange magic. The way in is a cave west of the fortress gates.",
	{
		{ "Slavecrusher Grox", "?", { Named("Resistance Breaker Spaulder", 3, 403), 0 } },
		{ "Twilight Commander Zarmok", "?", { Named("Shadowlight Athame", 21, 215), 0 } },
		{ "Bossman Toof", "?", { Named("Big-Belly Belt", 6, 401), 0 } },
		{ "Nar'gurk", "?", { Named("Chain of the Corruptor", 2, 400), 0 } },
		{ "Overlord Mugg", "?", { Named("Emblem of Slamming", 12, 400), 0 } },
	} })

Add({ -1007, "Alcaz Prison", "Dustwallow Marsh", 48, 53, 0, { "The Questioner", "Blazeroar" },
	"A remote island prison off the Dustwallow Marsh coast - long rumoured to have held King Varian Wrynn. The way in is the basement of the great building above the island's dock.",
	{
		{ "Tidemistress Ca'zass", "?", { Named("Cloak of the Tidemistress", 16, 401), 0 } },
		{ "Overseer Wrex", "?", { Named("Wrex's Pinky Ring", 11, 400), 0 } },
		{ "Katerina the Cleaner", "?", { Named("Sentimental Locket", 2, 400), 0 } },
		{ "The Questioner", "?", { Named("Girdle of Extracted Answers", 6, 404), 0 } },
		{ "Blazeroar", "?", {} },
	} })

Add({ -1008, "Blackmaw Hold", "Azshara", 55, 60, 0, { "Varrox Bleakhoof" },
	"A furbolg city in Azshara, built where a gate was meant to lead to Timbermaw Hold. The Blackmaw clan holds it and fights a deep-rooted corruption - said to be larger even than Blackrock Depths. Reached through a furbolg tunnel; the way in itself sits on the Winterspring side.",
	{
		{ "Varrox Bleakhoof", "?", {} },
	} })

Add({ -1009, "Shaper's Terrace", "Un'Goro Crater", 58, 60, 0, { "Bolt", "Cinder", "Snowtalon", "Nanaya" },
	"An ancient titan facility on the hill above Marshal's Refuge, overrun by Un'Goro's dinosaurs and a few of its old constructs. The crater's power crystals can be carried in and used at its consoles.",
	{
		{ "Bolt", "?", {} },
		{ "Cinder", "?", {} },
		{ "Snowtalon", "?", {} },
		{ "Nanaya", "?", {} },
	} })
