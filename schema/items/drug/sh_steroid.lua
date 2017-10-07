ITEM.name = "스테로이드"
ITEM.model = "models/props_lab/jar01b.mdl"
ITEM.desc = "이것만 먹으면 모두의 대가리를 박살낼 수 있다."
ITEM.duration = 100
ITEM.price = 200
ITEM.attribBoosts = {
	["str"] = 5,
	["meleeskill"] = 5,
}

ITEM:hook("_use", function(item)
	item.player:EmitSound("items/battery_pickup.wav")
	item.player:ScreenFade(1, Color(255, 255, 255, 255), 3, 0)
end)
