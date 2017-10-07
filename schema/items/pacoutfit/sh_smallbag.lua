ITEM.name = "소형 가방"
ITEM.desc = "물건을 담을수 있는 소형 가방."
ITEM.model = "models/rebel1324/b_usbag.mdl"
ITEM.width = 1
ITEM.height = 1
ITEM.outfitCategory = "back"
ITEM.price = 150
function ITEM:onGetDropModel(item) return "models/props_junk/cardboard_box004a.mdl" end
ITEM.iconCam = {
	ang	= Angle(18.994283676147, -21.182300567627, -9.9905118986499e-005),
	fov	= 29.486411154823,
	pos	= Vector(-61.059139251709, 20.480285644531, 71.955352783203)
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
                    ["UniqueID"] = "USBAG_MODEL",
                    ["Model"] = "models/rebel1324/b_usbag.mdl",
                },
            },
        },
        ["self"] = {
            ["EditorExpand"] = true,
            ["UniqueID"] = "USBAG_PART",
            ["ClassName"] = "group",
            ["Name"] = "my outfit",
            ["Description"] = "add parts to me!",
        },
    },
}