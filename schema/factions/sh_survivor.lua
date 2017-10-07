-- The 'nice' name of the faction.
FACTION.name = "생존자"
-- This faction is default by the server.
-- This faction does not requires a whitelist.
FACTION.isDefault = true
-- A description used in tooltips in various menus.
FACTION.desc = "생존자입니다."
-- A color to distinguish factions from others, used for stuff such as
-- name color in OOC chat.
FACTION.color = Color(20, 150, 15)
-- The list of models of the citizens.
-- Only default citizen can wear Advanced Citizen Wears and new facemaps.
local CITIZEN_MODELS = {
	"models/player/rebel1324/male_01.mdl",
	"models/player/rebel1324/male_02.mdl",
	"models/player/rebel1324/male_03.mdl",
	"models/player/rebel1324/male_04.mdl",
	"models/player/rebel1324/male_05.mdl",
	"models/player/rebel1324/male_06.mdl",
	"models/player/rebel1324/male_07.mdl",
	"models/player/rebel1324/male_08.mdl",
	"models/player/rebel1324/male_09.mdl",
	"models/player/rebel1324/male_10.mdl",
	"models/player/rebel1324/male_11.mdl",
	
}
FACTION.models = CITIZEN_MODELS
-- The amount of money citizens get.
FACTION.salary = 150
-- FACTION.index is defined when the faction is registered and is just a numeric ID.
-- Here, we create a global variable for easier reference to the ID.
FACTION_SURVIVOR = FACTION.index
