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
