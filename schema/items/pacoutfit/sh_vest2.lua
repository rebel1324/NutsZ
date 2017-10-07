ITEM.name = "대형 군용 전술조끼"
ITEM.desc = "전투에 편의성을 더해주는 조끼."
ITEM.model = "models/rebel1324/b_vest.mdl"
ITEM.width = 1
ITEM.height = 1
ITEM.outfitCategory = "vest"
ITEM.price = 150
function ITEM:onGetDropModel(item) return "models/props_junk/cardboard_box004a.mdl" end
ITEM.iconCam = {
	ang	= Angle(8.7180185317993, 133.14942932129, 0),
	fov	= 9.6155859275972,
	pos	= Vector(126.0258026123, -133.96939086914, 78.547737121582)
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
                    ["UniqueID"] = "NICEVEST_MODEL",
                    ["Model"] = "models/rebel1324/b_vest.mdl",
                },
            },
        },
        ["self"] = {
            ["EditorExpand"] = true,
            ["UniqueID"] = "NICEVEST_PART",
            ["ClassName"] = "group",
            ["Name"] = "my outfit",
            ["Description"] = "add parts to me!",
        },
    },
}