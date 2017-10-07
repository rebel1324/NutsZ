ITEM.name = "중형 가방"
ITEM.desc = "물건을 담을수 있는 중형 가방."
ITEM.model = "models/rebel1324/b_largebag.mdl"
ITEM.width = 1
ITEM.height = 1
ITEM.outfitCategory = "back"
ITEM.price = 150
function ITEM:onGetDropModel(item) return "models/props_junk/cardboard_box004a.mdl" end
ITEM.iconCam = {
	ang	= Angle(20.322423934937, -110.72882080078, -4.4567834265763e-005),
	fov	= 23.751855014838,
	pos	= Vector(20.480054855347, 61.058376312256, 71.960678100586)
}

ITEM.pacData = {
    [1] = {
        ["children"] = {
            [1] = {
                ["children"] = {
                },
                ["self"] = {
                    ["BoneMerge"] = true,
                    ["ClassName"] = "model",
                    ["UniqueID"] = "LARGEBAG_MODEL",
                    ["Model"] = "models/rebel1324/b_largebag.mdl",
                },
            },
        },
        ["self"] = {
            ["EditorExpand"] = true,
            ["UniqueID"] = "LARGEBAG_PART",
            ["ClassName"] = "group",
            ["Name"] = "my outfit",
            ["Description"] = "add parts to me!",
        },
    },
}