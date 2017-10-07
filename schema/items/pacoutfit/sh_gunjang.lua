ITEM.name = "군장"
ITEM.desc = "옛날 군인이 쓸법한 군장."
ITEM.model = "models/rebel1324/b_gunjang.mdl"
ITEM.width = 1
ITEM.height = 1
ITEM.outfitCategory = "back"
ITEM.price = 150
function ITEM:onGetDropModel(item) return "models/props_junk/cardboard_box004a.mdl" end
ITEM.iconCam = {
	ang	= Angle(23.640850067139, 219.75483703613, 0),
	fov	= 1.2255404437533,
	pos	= Vector(731.87103271484, 617.03521728516, 470.85153198242)
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
                    ["UniqueID"] = "GUNJANG_MODEL",
                    ["Model"] = "models/rebel1324/b_gunjang.mdl",
                },
            },
        },
        ["self"] = {
            ["EditorExpand"] = true,
            ["UniqueID"] = "GUNJANG_PART",
            ["ClassName"] = "group",
            ["Name"] = "my outfit",
            ["Description"] = "add parts to me!",
        },
    },
}