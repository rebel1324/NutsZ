ITEM.name = "방탄조끼"
ITEM.desc = "방탄조끼입니다. 입으면 총탄으로부터의 데미지가 크게 감소합니다."
ITEM.model = "models/weapons/armor/armor.mdl"
ITEM.price = 1500
ITEM.width = 1
ITEM.height = 1
ITEM.category = "Equipment"
ITEM.isEquipment = true
ITEM.partCategory = "vest"

ITEM.defaultHealth = 200
-- ITEM CODE
function ITEM:onInstanced(index, x, y, item)
	item:setData("health", item.defaultHealth)
end

-- Inventory drawing
if (CLIENT) then
	function ITEM:paintOver(item, w, h)
		if (item:getData("equip")) then
			surface.SetDrawColor(110, 255, 110, 100)
			surface.DrawRect(w - 14, h - 14, 8, 8)
		end

			local def = item.defaultHealth
			local health = item:getData("health", def)/def*100
			local color = Color(255, health*255, health*255)
			nut.util.drawText(Format("%d", health) .. "%", 4, h - 3, color, 0, 4, "nutSmallFont")
	end
end

-- On item is dropped, Remove a weapon from the player and keep the ammo in the item.
ITEM:hook("drop", function(item)
	if (item:getData("equip")) then
		item:setData("equip", nil)
	end
end)

-- On player uneqipped the item, Removes a weapon from the player and keep the ammo in the item.
ITEM.functions.EquipUn = { -- sorry, for name order.
	name = "Unequip",
	tip = "equipTip",
	icon = "icon16/cross.png",
	onRun = function(item)
		item.player:EmitSound("items/ammo_pickup.wav", 80)

		item:setData("equip", nil)
		
		return false
	end,
	onCanRun = function(item)
		return (!IsValid(item.entity) and item:getData("equip") == true)
	end
}

-- On player eqipped the item, Gives a weapon to player and load the ammo data from the item.
ITEM.functions.Equip = {
	name = "Equip",
	tip = "equipTip",
	icon = "icon16/tick.png",
	onRun = function(item)
		local client = item.player
		local items = client:getChar():getInv():getItems()

		for k, v in pairs(items) do
			if (v.id != item.id) then
				local itemTable = nut.item.instances[v.id]

				if (itemTable.isEquipment and itemTable.partCategory == item.partCategory and itemTable:getData("equip")) then
					client:notifyLocalized("samePart")

					return false
				end
			end
		end
		
		item.player:EmitSound("items/ammo_pickup.wav", 80)
		item:setData("equip", true)
		return false
	end,
	onCanRun = function(item)
		return (!IsValid(item.entity) and item:getData("equip") != true)
	end
}

function ITEM:onCanBeTransfered(oldInventory, newInventory)
	if (newInventory and self:getData("equip")) then
		return false
	end

	return true
end