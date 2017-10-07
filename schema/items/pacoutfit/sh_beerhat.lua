ITEM.name = "맥주캔 모자"
ITEM.desc = "머리에 쓸수있는 장식품."
ITEM.model = "models/sal/acc/fix/beerhat.mdl"
ITEM.width = 1
ITEM.height = 1
ITEM.outfitCategory = "hat"
function ITEM:onGetDropModel(item) return "models/props_junk/cardboard_box004a.mdl" end
ITEM.price = 150
ITEM.iconCam = {
	ang	= Angle(4.6262593269348, 204.09663391113, 0),
	fov	= 4.3062882137585,
	pos	= Vector(182.01710510254, 81.07160949707, 17.237482070923)
}
ITEM.pacData = {
[1] = {
	["children"] = {
		[1] = {
			["children"] = {
			},
			["self"] = {
				["Skin"] = 1,
				["UniqueID"] = "BEER_MODEL",
				["Position"] = Vector(-3.8090000152588, 0, 0.18299999833107),
				["Size"] = 0.953,
				["Bone"] = "eyes",
				["Model"] = "models/sal/acc/fix/beerhat.mdl",
				["ClassName"] = "model",
			},
		},
	},
	["self"] = {
		["EditorExpand"] = true,
		["UniqueID"] = "BEER_OUTFIT",
		["ClassName"] = "group",
		["Name"] = "내 의상",
		["Description"] = "나에게 파트를 추가하세요!",
	},
},


}