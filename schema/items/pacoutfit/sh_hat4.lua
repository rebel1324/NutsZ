ITEM.name = "모자"
ITEM.desc = "머리에 쓸수있는 장식품."
ITEM.model = "models/modified/hat03.mdl"
ITEM.width = 1
ITEM.height = 1
ITEM.outfitCategory = "hat"
ITEM.price = 150
function ITEM:onGetDropModel(item) return "models/props_junk/cardboard_box004a.mdl" end
ITEM.iconCam = {
	ang	= Angle(26.713342666626, 220.0083770752, 0),
	fov	= 0.58373658914196,
	pos	= Vector(734.35729980469, 615.53173828125, 482.56359863281)
}

ITEM.pacData = {
[1] = {
	["children"] = {
		[1] = {
			["children"] = {
			},
			["self"] = {                
				["UniqueID"] = "HAT_04_PART",
				["Skin"] = 1,
				["Position"] = Vector(-3.819000005722, 0, 2.1730000972748),
				["Size"] = 0.992,
				["Bone"] = "eyes",
				["Model"] = "models/modified/hat03.mdl",
				["ClassName"] = "model",
			},
		},
	},
	["self"] = {
		["EditorExpand"] = true,
		["UniqueID"] = "HAT_04_OUTFIT",
		["ClassName"] = "group",
	},
},

}