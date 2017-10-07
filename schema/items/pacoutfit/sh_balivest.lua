ITEM.name = "방탄조끼"
ITEM.desc = "총알을 막을수 있도록 설계된 조끼입니다."
ITEM.model = "models/rebel1324/b_vestarmor.mdl"
function ITEM:onGetDropModel(item) return "models/props_junk/cardboard_box004a.mdl" end
ITEM.width = 1
ITEM.height = 1
ITEM.outfitCategory = "vest"
ITEM.price = 150
ITEM.iconCam = {
	ang	= Angle(24.348821640015, 220.06370544434, 0),
	fov	= 1.539798523202,
	pos	= Vector(734.41784667969, 618.29461669922, 484.25646972656)
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
                    ["UniqueID"] = "BALIVEST_MODEL",
                    ["Model"] = "models/rebel1324/b_vestarmor.mdl",
                },
            },
        },
        ["self"] = {
            ["EditorExpand"] = true,
            ["UniqueID"] = "BALIVEST_PART",
            ["ClassName"] = "group",
            ["Name"] = "my outfit",
            ["Description"] = "add parts to me!",
        },
    },
}