ITEM.name = "망토"
ITEM.desc = "간지가 나는 망토입니다."
ITEM.model = "models/props_junk/cardboard_box001a.mdl"
ITEM.width = 1
ITEM.height = 1
ITEM.outfitCategory = "back"
ITEM.price = 150
function ITEM:onGetDropModel(item) return "models/props_junk/cardboard_box004a.mdl" end
ITEM.pacData = {
	[1] = {
		["children"] = {
			[1] = {
				["children"] = {
				},
				["self"] = {
					["Angles"] = Angle(0, 90, 90),
					["UniqueID"] = "3807183611",
					["ClassName"] = "model",
					["Bone"] = "spine 4",
					["Model"] = "models/pac/jiggle/clothing/base_cape_2_gravity.mdl",
					["Material"] = "http://i.imgur.com/MZiXamF.png",
				},
			},
		},
		["self"] = {
			["EditorExpand"] = true,
			["UniqueID"] = "2009185965",
			["ClassName"] = "group",
			["Name"] = "my outfit",
			["Description"] = "add parts to me!",
		},
	},
}