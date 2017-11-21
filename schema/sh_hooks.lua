-- This hook returns whether player can use bank or not.
function SCHEMA:CanUseBank(client, atmEntity)
	return true
end

-- This hook returns whether character is recognised or not.
function SCHEMA:IsCharRecognised(char, id)
	local character = nut.char.loaded[id]
	local client = character:getPlayer()
	
	if (client and character) then
		local faction = nut.faction.indices[client:Team()]

		if (faction and faction.isPublic) then
			return true
		end
	end
end

-- Restrict Business.
function SCHEMA:CanPlayerUseBusiness(client, id)
	return false
end

function SCHEMA:CanDrive()
	return false
end


-- Shouldn't this belonds to the CLIENTSIDE?
-- Emit Effects.
local flesh = {
	[MAT_FLESH] = 1,
	[MAT_ALIENFLESH] = 0,
	[MAT_BLOODYFLESH] = 1,
	[70] = 1,
}
local metal = {
	[MAT_METAL] = 1,
	[MAT_VENT] = 1,
	[MAT_GRATE] = 1,
}
function SCHEMA:EntityFireBullets(ent, bulletTable)
	local oldCallback = bulletTable.Callback

	bulletTable.Callback = function(client, trace, dmgInfo)
		if (oldCallback) then
			oldCallback(client, trace, dmgInfo)
		end
		
		if (trace) then
			if (flesh[trace.MatType]) then
				local e = EffectData()
				e:SetScale(math.Rand(1.3, 1.65))
				e:SetOrigin(trace.HitPos + VectorRand() * 1)
				util.Effect("btBlood", e)
			elseif (metal[trace.MatType]) then
				local e = EffectData()
				e:SetOrigin(trace.HitPos)
				e:SetNormal(trace.HitNormal)
				e:SetScale(math.Rand(.4, .5))
				e:SetOrigin(trace.HitPos + VectorRand() * 1)
				util.Effect("btMetal", e)
			else
				local e = EffectData()
				e:SetOrigin(trace.HitPos)
				e:SetNormal(trace.HitNormal)
				e:SetScale(math.Rand(.4, .5))
				util.Effect( "btImpact", e )
			end
		end
	end

	return true
end

function SCHEMA:PlayerSpawnProp(client)
	return (client:IsSuperAdmin())
end

function SCHEMA:ShouldWeaponBeRaised()
	return true
end

-- lol test
function SCHEMA:GetSchemaCWDamage(weapon, client)
	local attrib = 0

	if (client and client:IsValid() and client:getChar()) then
		attrib = client:getChar():getAttrib("gunskill", 0)
	end

	local maximum = 0.5
	return 0.5 + math.Clamp(attrib / nut.config.get("maxAttribs", 30) * maximum, 0, maximum)
end

function SCHEMA:GetSchemaCWReloadSpeed(weapon, client)
	local attrib = 0

	if (client and client:IsValid() and client:getChar()) then
		attrib = client:getChar():getAttrib("gunskill", 0)
	end

	local maximum = 1
	return 0.8 + math.Clamp(attrib / nut.config.get("maxAttribs", 30) * maximum, 0, maximum)
end

function SCHEMA:GetSchemaCWRecoil(weapon, client)
	local attrib = 0

	if (client and client:IsValid() and client:getChar()) then
		attrib = client:getChar():getAttrib("gunskill", 0)
	end

	local maximum = .2
	return .75 - math.Clamp(attrib / nut.config.get("maxAttribs", 30) * maximum, 0, maximum)
end

function SCHEMA:recalculateVelocitySensitivity(weapon, client)
	local attrib = 0

	if (client and client:IsValid() and client:getChar()) then
		attrib = client:getChar():getAttrib("gunskill", 0)
	end

	local maximum = 1.5
	return 2 - math.Clamp(attrib / nut.config.get("maxAttribs", 30) * maximum, 0, maximum)
end

function SCHEMA:GetSchemaCWHipSpread(weapon, client)
	local attrib = 0

	if (client and client:IsValid() and client:getChar()) then
		attrib = client:getChar():getAttrib("gunskill", 0)
	end

	local maximum = 1.5
	return 3 - math.Clamp(attrib / nut.config.get("maxAttribs", 30) * maximum, 0, maximum)
end

function SCHEMA:GetSchemaCWMaxSpread(weapon, client)
	local attrib = 0

	if (client and client:IsValid() and client:getChar()) then
		attrib = client:getChar():getAttrib("gunskill", 0)
	end

	local maximum = 1.5
	return 4 - math.Clamp(attrib / nut.config.get("maxAttribs", 30) * maximum, 0, maximum)
end

function SCHEMA:GetSchemaCWAimSpread(weapon, client)
	local attrib = 0

	if (client and client:IsValid() and client:getChar()) then
		attrib = client:getChar():getAttrib("gunskill", 0)
	end

	local maximum = 1.5
	return 3 - math.Clamp(attrib / nut.config.get("maxAttribs", 30) * maximum, 0, maximum)
end

function SCHEMA:GetSchemaCWFirerate(weapon, client)
	local attrib = 0

	if (client and client:IsValid() and client:getChar()) then
		attrib = client:getChar():getAttrib("gunskill", 0)
	end

	local maximum = .1
	return 1.2 - math.Clamp(attrib / nut.config.get("maxAttribs", 30) * maximum, 0, maximum)
end

function SCHEMA:PlayerGetMeleeDamage(client, damage)
	local attrib = 0

	if (client and client:IsValid() and client:getChar()) then
		attrib = client:getChar():getAttrib("meleeskill", 0)
	end

	local maximum = 1.5
	return damage + damage * math.Clamp(attrib / nut.config.get("maxAttribs", 30) * maximum, 0, maximum)
end

function SCHEMA:PlayerGetMeleeDelay(client, delay)
	local attrib = 0

	if (client and client:IsValid() and client:getChar()) then
		attrib = client:getChar():getAttrib("meleeskill", 0)
	end

	local maximum = 0.8
	return delay * 1.5 - delay * math.Clamp(attrib / nut.config.get("maxAttribs", 30) * maximum, 0, maximum)
end

function SCHEMA:PlayerDoMelee(client, hit)
	if (CLIENT) then return end
	
	if (client:getChar()) then
		client:getChar():updateAttrib("str", 0.002)
		client:getChar():updateAttrib("meleeskill", 0.002)
	end
end

function SCHEMA:InitializedSchema()
	if (SERVER) then
		self:ItemSpawnerPayload()
		self:NPCSpawnerPayload()
	end
end

function SCHEMA:PhysgunPickup(client, entity)
	return client:IsSuperAdmin()
end

function SCHEMA:PhysgunFreeze(weapon, phys, entity, client)
	return client:IsSuperAdmin()
end

function SCHEMA:CanTool(client, trace, tool, ENT)
	return client:IsSuperAdmin()
end

function SCHEMA:CanItemBeTransfered(itemObject, curInv, inventory)
	if (!itemObject) then
		if (SERVER) then
			for k, v in ipairs(player.GetAll()) do
				curInv:sync(v, true)
				inventory:sync(v, true)
			end
		end

		if (CLIENT) then
			nut.gui.inv1:Remove()
		end
	end

    if (inventory and curInv) then
		local a = curInv.owner
		local b = inventory.owner

		local owner, newowner

		for k, v in ipairs(player.GetAll()) do
			local char = v:getChar()

			if (char) then
				if (char:getID() == a) then
					owner = v
				elseif (char:getID() == b) then
					newowner = v
				end
			end
		end
		
        if (inventory.vars) then
			if (itemObject and itemObject.isBag) then
				local bag = inventory.vars.isBag

				if (bag) then
					if (SERVER) then
						if (IsValid(owner) and curInv and curInv:getID() != 0) then
							curInv:sync(owner, true)
						end

						if (IsValid(newowner) and inventory and inventory:getID() != 0) then
							inventory:sync(newowner, true)
						end
					end

					return false
				end
			end
        end
    end
end


if (CLIENT) then
	netstream.Hook("openLoot", function(entity, items)
		nut.gui.loot = vgui.Create("nutLoots")
		nut.gui.loot:setItems(entity, items)
	end)

	netstream.Hook("updateLoot", function(entity, items)
		if (nut.gui.loot and nut.gui.loot:IsVisible()) then
		end
	end)

	netstream.Hook("takeLoot", function(name, amount)
		if (nut.gui.loot and nut.gui.loot:IsVisible()) then
			local item = nut.gui.loot.itemPanel[name]

			if (item) then
				item:Update(item.amount)

				if (item.amount <= 0) then
					item:Remove()
				end
			end
		end
	end)
else
	netstream.Hook("lootExit", function(client)
		local entity = client.nutLoot
		entity.looted = nil
		client.nutLoot = nil
	end)

	netstream.Hook("lootUse", function(client, itemID, drop)
		local entity = client.nutLoot
		local itemTable = nut.item.instances[itemID]

		if (itemTable and IsValid(entity)) then
			if (entity:GetPos():Distance(client:GetPos()) > 128) then
				client.nutLoot = nil

				return
			end

			entity.items[itemID] = nil

			if (drop) then
				itemTable:spawn(entity:GetPos() + Vector(0, 0, 16))
			else
				local status, fault = itemTable:transfer(client:getChar():getInv():getID(), nil, nil, client)
		
				if (!status) then
					return client:notifyLocalized("noFit")
				end
			end
				
			hook.Run("OnTakeLootItems", client, itemID)

			if (entity:getItemCount() < 1) then
				entity:GibBreakServer(Vector(0, 0, 0.5))
				entity:Remove()
			end
		end
	end)
end