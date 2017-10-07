ITEM.name = "스카프"
ITEM.desc = "다른 기능은 없는 스카프입니다."
ITEM.model = "models/sal/acc/fix/scarf01.mdl"
ITEM.width = 1
ITEM.height = 1
ITEM.outfitCategory = "neck"
ITEM.price = 150
function ITEM:onGetDropModel(item) return "models/props_junk/cardboard_box004a.mdl" end
ITEM.iconCam = {
	ang	= Angle(4.9265217781067, 130.36251831055, 0),
	fov	= 6.2679897304623,
	pos	= Vector(119.79470825195, -142.60646057129, 72.885871887207)
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
                    ["UniqueID"] = "SCARF_MODEL",
                    ["Model"] = "models/rebel1324/b_scarf.mdl",
                },
            },
        },
        ["self"] = {
            ["EditorExpand"] = true,
            ["UniqueID"] = "SCARF_PART",
            ["ClassName"] = "group",
            ["Name"] = "my outfit",
            ["Description"] = "add parts to me!",
        },
    },
}