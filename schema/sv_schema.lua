function SCHEMA:UpdateVendors()
	for k, v in ipairs(ents.GetAll()) do
		if (v:IsPlayer()) then
			v:notifyLocalized("vendorUpdated")
		end

		if (v:GetClass() == "nut_vendor") then

			if (v:getNetVar("name") == "암상인") then
				v.currentStock = v.currentStock or 0
				v.currentStock = (v.currentStock + 1) % #WEAPON_STOCKS

				local data = WEAPON_STOCKS[v.currentStock + 1] or WEAPON_STOCKS[1]

				if (data) then
					v:setNetVar("desc", data.desc)
					v.items = {}

					for itemID, stockData in pairs(data.stocks) do
						v.items[itemID] = v.items[itemID] or {}

						v.items[itemID][VENDOR_MODE] = VENDOR_SELLONLY
						v.items[itemID][VENDOR_PRICE] = stockData.price
						v.items[itemID][VENDOR_MAXSTOCK] = stockData.amount
						v.items[itemID][VENDOR_STOCK] = stockData.amount
					end
				else
					print("what the fuck!!!")
				end
			end
		end
	end
end
timer.Create("nutVendorSell", nut.config.get("vendorInterval", 3600), 0, SCHEMA.UpdateVendors)

local whitelist = {
	["Text"] = true,
	["Font"] = true,
	["Type"] = true,
	["FontSize"] = true,
	["OutSize"] = true,
	["AnimSpeed"] = true,
	["Neon"] = true,
	["ColorBack"] = true,
	["ColorText"] = true,
	["ColorOut"] = true,
}
netstream.Hook("nutBingle", function(client, entity, mod, value)
	if (IsValid(entity) and whitelist[mod]) then
		if (entity:CPPIGetOwner() != client and !client:IsAdmin()) then
			return true
		end

		local func = entity["Set" .. mod]

		if (value and type(value) == "table") then
			value = Vector(value.r, value.g, value.b)
		end

		if (func) then	
			func(entity, value)
		end
	end
end)

function saveall()
	for k, v in ipairs(player.GetAll()) do
		local char = v:getChar()
		
		if (char) then
			char:save()
		end
	end
end
