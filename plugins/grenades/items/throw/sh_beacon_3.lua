ITEM.name = "청색 신호기"
ITEM.throwent = "nut_beacon"
ITEM.throwforce = 650
ITEM.desc = "근처 플레이어에게 위치를 표시해주는 비컨입니다."
ITEM.price = 80

function ITEM:entConfigure(grd)
	grd:SetDTInt(0,3)
end