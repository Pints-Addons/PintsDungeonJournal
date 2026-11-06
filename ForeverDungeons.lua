-- Pint's Dungeon Journal: dungeons new in WoW Forever, from what was published about the Forever beta (boss loot by item id;
-- bosses and drops may still change). Added to the journal like the original dungeons.
-- (The game's map number for these isn't known yet, so they're found by the dungeon's name when you're inside.)
local JD = PintsJournalData
if not JD then return end
local function Add(d) JD.dungeons[#JD.dungeons + 1] = d end
local function Item(id, inv, cls, req, q, name) if not JD.items[id] then JD.items[id] = { inv, cls, req, q, 0, name } end end

Add({ -1001, "Ruins of Lordaeron", "Tirisfal Glades", 15, 22, 0, { "Rath'mael" },
	"Above the Undercity lie the shattered streets of Lordaeron's old capital. Spiders, ghouls, abominations and restless spirits now walk its alleys and market square, and somewhere among the graves the lich Rath'mael gathers the dead.",
	{
		{ "Witherfang", 17, { 271201, 33, 271202, 33, 271203, 33 } },
		{ "The Baron", 17, { 271204, 33, 271205, 33, 271206, 33 } },
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
