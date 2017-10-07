SIGNAL_DEATH = 1
SIGNAL_CHAR = 2
SIGNAL_JOB = 3

local function savereserve(char)
	nut.db.updateTable({
		_reserve = char:getReserve()
	}, nil, "reserve", "_charID = "..char:getID())
end

function SCHEMA:OnReserveChanged(char)
	savereserve(char)
end

do
		local MYSQL_CREATE_TABLES = [[
			CREATE TABLE IF NOT EXISTS `nut_reserve` (
				`_charID` int(11) NOT NULL,
				`_reserve` int(11) unsigned DEFAULT NULL,
				PRIMARY KEY (`_charID`)
			);
		]]
		local SQLITE_CREATE_TABLES = [[
			CREATE TABLE IF NOT EXISTS `nut_reserve` (
				`_charID` INTEGER PRIMARY KEY,
				`_reserve` INTEGER
			);
		]]

		function SCHEMA:OnLoadTables()
			if (nut.db.object) then
				nut.db.query(MYSQL_CREATE_TABLES)
			else
				nut.db.query(SQLITE_CREATE_TABLES)
			end
		end

		function SCHEMA:CharacterPreSave(char)
			savereserve(char)
		end

		function SCHEMA:CharacterLoaded(id)
			-- legacy support
			local char = nut.char.loaded[id]
			local legacy = false
			if (char:getData("reserve")) then
				local restore = char:getData("reserve", 0)

				char:setReserve(tonumber(restore))
				char:setData("reserve", nil)
				legacy = true
			end

			nut.db.query("SELECT _reserve FROM nut_reserve WHERE _charID = "..id, function(data)
				if (data and #data > 0) then
					for k, v in ipairs(data) do
						local money = tonumber(v._reserve)

						if (!legacy) then
							char:setReserve(money)
						end
					end
				else
					nut.db.insertTable({
						_reserve = 0,
						_charID = id,
					}, function(data)
						if (!legacy) then
							char:setReserve(0)
						end
					end, "reserve")
				end
			end)
		end

	    function SCHEMA:PreCharDelete(client, char)
	    	nut.db.query("DELETE FROM nut_reserve WHERE _charID = "..char:getID())
	    end

end

function SCHEMA:OnPlayerHeal(client, target, amount, secs, item)
	if (IsValid(target)) then
		local char = target:getChar()

		if (char) then
			if (char:getData("b_leg")) then
				client:notifyShine("fixedLegs")
				char:setData("b_leg", nil)
			end

			if (char:getData("b_bld")) then
				client:notifyShine("fixedBleed")
				char:setData("b_bld", nil)
			end
		end
	end
end

-- This hook restricts oneself from using a weapon that configured by the sh_config.lua file.
function SCHEMA:CanPlayerInteractItem(client, action, item)
	if (IsValid(client:getNetVar("searcher"))) then
		return false
	end

	local char = client:getChar()

	if (action == "drop" or action == "take") then
		return
	end

	local itemTable
	if (type(item) == "Entity") then
		if (IsValid(item)) then
			itemTable = nut.item.instances[item.nutItemID]
		end
	else
		itemTable = nut.item.instances[item]
	end

	if (itemTable and itemTable.isWeapon) then
		local reqattribs = WEAPON_REQSKILLS[itemTable.uniqueID]
		
		if (reqattribs) then
			for k, v in pairs(reqattribs) do
				local attrib = char:getAttrib(k, 0)
				if (attrib < v) then
					client:notify(L("requireAttrib", client, L(nut.attribs.list[k].name, client), attrib, v))

					return false
				end
			end
		end
	end
end

function SCHEMA:PlayerLoadedChar(client, netChar, prevChar)
	if (prevChar) then
		hook.Run("ResetVariables", client, SIGNAL_CHAR)
	end

	local char = client:getChar()
	if (char and char:getData("b_leg")) then
		client:breakLegs()
	end
end

function SCHEMA:OnPlayerDropWeapon(client, item, entity)
	timer.Simple(30, function()
		if (entity and entity:IsValid()) then
			entity:Remove()
		end
	end)
end

local function item2world(inv, item, pos)
	item.invID = 0

	inv:remove(item.id, false, true)
	nut.db.query("UPDATE nut_items SET _invID = 0 WHERE _itemID = "..item.id)

	local ent = item:spawn(pos)	
	
	if (IsValid(ent)) then
		timer.Simple(0, function()
			local phys = ent:GetPhysicsObject()
			
			if (IsValid(phys)) then
				phys:EnableMotion(true)
				phys:Wake()
			end
		end)
	end

	return ent
end

-- This hook enforces death penalty for dead players.
function SCHEMA:PlayerDeath(client, inflicter, attacker)
	local char = client:getChar()

	if (char) then
		-- add reputation on players.
		if (IsValid(attacker) and attacker:IsPlayer()) then
			local atkChar = attacker:getChar()

			if (atkChar) then
				local bandit = char:getRep() < 0
				local repDiff = nut.config.get(bandit and "repKill" or "repSavior", 10)

				netstream.Start(attacker, "nutNeatSounds", !bandit)

				if (!bandit) then
					atkChar:takeRep(repDiff)
				else
					atkChar:addRep(repDiff)
				end
			end
			
			attacker:safePenalty()
		end

		hook.Run("ResetVariables", client, SIGNAL_DEATH)

		-- money penalty
		if (nut.config.get("deathMoney", true)) then
			char:setMoney(0)
		end

		-- weapon penalty
		local inv = char:getInv()
		local items = inv:getItems()
		local dropItems = {}
		local dmgType = 0	

		client:resetParts()

		if (table.Count(items) > 0) then
			for k, v in pairs(items) do
				if (v.isWeapon) then
					if (v:getData("equip")) then
						v:setData("equip", nil)

						local ent = item2world(inv, v, client:GetPos() + Vector(0, 0, 10))
						continue
					end
				end


				if (v:getData("equip")) then
					v:setData("equip", nil)
				end
				if (v:transfer(nil, nil, nil, client, nil, true)) then
					dropItems[v:getID()] = {uid = v.uniqueID, data = v.data}
				end
			end

			loots = ents.Create("nut_loots")
			loots.items = dropItems
			loots:SetPos(client:GetPos() + Vector(0, 0, 10))
			loots:Spawn()
			loots:Activate()
		end
	end
end

-- Don't let them spray thier fucking spray without spraycan
function SCHEMA:PlayerSpray(client)
	return true
end

-- On character is created, Give him some money and items. 
function SCHEMA:OnCharCreated(client, char)
	if (char) then
		local inv = char:getInv()

		if (inv) then
			local stItems = self.startItems or {}
			for _, item in ipairs(stItems) do
				if (item[1] and item[2]) then
					inv:add(item[1], item[2], item[3])
				end
			end
		end

		char:giveMoney(nut.config.get("startMoney", 0))
	end
end

function SCHEMA:KeyPress(client, key)
	if (key == IN_RELOAD and SCHEMA.serious) then
		timer.Create("nutToggleRaise"..client:SteamID(), 1, 1, function()
			if (IsValid(client)) then
				client:toggleWepRaised()
			end
		end)
	elseif (key == IN_USE) then
		local data = {}
			data.start = client:GetShootPos()
			data.endpos = data.start + client:GetAimVector()*96
			data.filter = client
		local entity = util.TraceLine(data).Entity

		
		if (IsValid(entity) and entity:isDoor() or entity:IsPlayer()) then
			hook.Run("PlayerUse", client, entity)
		end
		
		--hook.Run("PlayerUse", client, entity)
	end
end

-- Give Class Loadout.
function SCHEMA:PostPlayerLoadout(client, reload)
	client:AllowFlashlight(true)
end

function SCHEMA:PlayerConnect(name)
	for k, v in ipairs(player.GetAll()) do
		v:ChatPrint(Format("%s님이 서버에 접속하였습니다.", name))
	end
end

function SCHEMA:PlayerDisconnected(client)
	if (IsValid(client.nutRagdoll)) then
		client.nutRagdoll:Remove()
	end

	for k, v in ipairs(player.GetAll()) do
		v:ChatPrint(Format("%s님이 서버에서 나가셨습니다.", client:Name()))
	end
end

function SCHEMA:CanPlayerJoinClass(client, class, classData)
	return false
end

function SCHEMA:OnPlayerJoinClass(client, class, oldclass, silent)
end

function SCHEMA:saveGarbage()
	nut.data.set("itemspawners", self.itemSpawns)
end

function SCHEMA:loadGarbage()
	self.itemSpawns = nut.data.get("itemspawners")
end


function SCHEMA:saveNPCSpawn()
	nut.data.set("npcspawners", self.npcSpawns)
end

function SCHEMA:loadNPCSpawn()
	self.npcSpawns = nut.data.get("npcspawners")
end

function SCHEMA:SaveData()
	self:saveGarbage()
	self:saveNPCSpawn()

	local savedEntities = {}

	for k, v in ipairs(ents.GetAll()) do
		local class = v:GetClass():lower()

		if (class:find("bingle") and v:GetNWBool("fuckoff")) then
			table.insert(savedEntities, {
				class = class, 
				pos = v:GetPos(),
				ang = v:GetAngles(),
				text = v:GetText(),
				font = v:GetFont(),
				type = v:GetType(),
				fontsize = v:GetFontSize(),
				outsize = v:GetOutSize(),
				animspeed = v:GetAnimSpeed(),
				neon = v:GetNeon(),
				colback = v:GetColorBack(),
				coltext = v:GetColorText(),
				colout = v:GetColorOut(),
			})
			
			continue
		end
			
		if (SAVE_ENTS[class]) then
			table.insert(savedEntities, {
				class = class, 
				pos = v:GetPos(),
				ang = v:GetAngles(),
			})
		end
	end

	-- Save Map Entities
	self:setData(savedEntities)
end

function SCHEMA:LoadZones()
	local map = game.GetMap()

	-- gets two vector and gives min and max vector for Vector:WithinAA(min, max)
	local function sortVector(vector1, vector2)
		local minVector = Vector(0, 0, 0)
		local maxVector = Vector(0, 0, 0)
		for i = 1, 3 do
			if (vector1[i] >= vector2[i]) then
				maxVector[i] = vector1[i]
				minVector[i] = vector2[i]
			else
				maxVector[i] = vector2[i]
				minVector[i] = vector1[i]
			end
		end
		return minVector, maxVector
	end

	if (SCHEMA.safeZones and SCHEMA.safeZones[map:lower()]) then
		for k, v in pairs(SCHEMA.safeZones[map:lower()]) do
			local a, b = sortVector(v[1], v[2])

			local newVec = Vector()
			for i = 1, 3 do
				newVec[i] = a[i] - b[i]
			end

			if IsValid(v.ent) then v.ent:Remove() end

			v.ent = ents.Create("nut_safezone")
			v.ent:SetPos(b + newVec/2)
			v.ent:Spawn()
			v.ent:Activate()
			v.ent:SetCollisionBoundsWS(a, b)
			v.ent:SetSolid(SOLID_BBOX)
		end
	end
end

-- Load Data.
function SCHEMA:LoadData()
	self:LoadZones()
	self:loadGarbage()
	self:loadNPCSpawn()
	
	-- Load Map Entities
	local savedEntities = self:getData() or {}
	
	for k, v in ipairs(savedEntities) do
		local ent = ents.Create(v.class)
		ent:SetPos(v.pos)
		ent:SetAngles(v.ang)
		ent:Spawn()
		ent:Activate()

		local phys = ent:GetPhysicsObject()
		phys:Wake()
		phys:EnableMotion()

		if (ent.isNotiboard) then
			ent:GetText(v.text)
			ent:GetFont(v.font)
			ent:GetType(v.type)
			ent:GetFontSize(v.fontsize)
			ent:GetOutSize(v.outsize)
			ent:GetAnimSpeed(v.animspeed)
			ent:GetNeon(v.neon)
			ent:GetColorBack(v.colback)
			ent:GetColorText(v.coltext)
			ent:GetColorOut(v.colout)
			ent:SetNWBool("fuckoff", true)
		end
	end
end

function SCHEMA:PlayerStaminaLost(client)
	local char = client:getChar()
	char:updateAttrib("end", 0.001)
	char:updateAttrib("stm", 0.005)
end

function SCHEMA:PostLoadData()
	self:UpdateVendors()
end

function SCHEMA:CanPlayerAccessDoor(client, door, access)
	return true
end

-- RESTRICTED AS FUCK
local yay = {
	["STEAM_0:0:14562033"] = true,
	["STEAM_0:1:18216292"] = true,
	["STEAM_0:0:19814083"] = true,
}
function SCHEMA:CanPlayerModifyConfig(client)
	local steamid = client:SteamID()

	if (yay[steamid]) then
		return true
	end

	return false
end

function SCHEMA:OnPlayerItemBreak(client, item)
	client:notifyLocalized("itemBroke")
end

function SCHEMA:searchPlayer(client, target)
	if (IsValid(target:getNetVar("searcher")) or IsValid(client.nutSearchTarget)) then
		return false
	end

	if (!target:getChar() or !target:getChar():getInv()) then
		return false
	end

	local inventory = target:getChar():getInv()

	-- Permit the player to move items from their inventory to the target's inventory.
	inventory.oldOnAuthorizeTransfer = inventory.onAuthorizeTransfer
	inventory.onAuthorizeTransfer = function(inventory, client2, oldInventory, item)
		if (IsValid(client2) and client2 == client) then
			return true
		end

		return false
	end
	inventory:sync(client)
	inventory.oldGetReceiver = inventory.getReceiver
	inventory.getReceiver = function(inventory)
		return {client, target}
	end
	inventory.onCheckAccess = function(inventory, client2)
		if (client2 == client) then
			return true
		end
	end

	-- Permit the player to move items from the target's inventory back into their inventory.
	local inventory2 = client:getChar():getInv()
	inventory2.oldOnAuthorizeTransfer = inventory2.onAuthorizeTransfer
	inventory2.onAuthorizeTransfer = function(inventory3, client2, oldInventory, item)
		if (oldInventory == inventory) then
			return true
		end

		return inventory2.oldOnAuthorizeTransfer(inventory3, client2, oldInventory, item)
	end

	-- Show the inventory menu to the searcher.
	netstream.Start(client, "searchPly", target, target:getChar():getInv():getID())

	client.nutSearchTarget = target
	target:setNetVar("searcher", client)

	return true
end

netstream.Hook("searchExit", function(client)
	local target = client.nutSearchTarget

	if (IsValid(target) and target:getNetVar("searcher") == client) then
		local inventory = target:getChar():getInv()
		inventory.onAuthorizeTransfer = inventory.oldOnAuthorizeTransfer
		inventory.oldOnAuthorizeTransfer = nil
		inventory.getReceiver = inventory.oldGetReceiver
		inventory.oldGetReceiver = nil
		inventory.onCheckAccess = nil
			
		local inventory2 = client:getChar():getInv()
		inventory2.onAuthorizeTransfer = inventory2.oldOnAuthorizeTransfer
		inventory2.oldOnAuthorizeTransfer = nil

		target:setNetVar("searcher", nil)
		client.nutSearchTarget = nil
	end
end)

function SCHEMA:OnPlayerSearch(client, target)
	if (IsValid(target) and target:IsPlayer()) then				
		if (target:getChar()) then
			client.searching = true
			client:EmitSound("npc/combine_soldier/gear"..math.random(3, 4)..".wav", 100, 70)

			client:setAction("@searching", 5)
			client:doStaredAction(target, function()
				local dist = client:GetPos():Distance(target:GetPos())

				if (dist < 128) then
					SCHEMA:searchPlayer(client, target)
				else
					client:notifyLocalized("tooFar")
				end

				client:EmitSound("npc/barnacle/neck_snap1.wav", 100, 140)
			end, 5, function()
				client:setAction()
				target:setAction()

				client.searching = false
			end)

			target:setAction("@searched", 5)
		end
	else
		client:notifyLocalized("notValid")
	end
end

function SCHEMA:OnPlayerAFKLong(client)
end

function SCHEMA:CanPlayerUseTie(client)
	return true
end

function SCHEMA:SpawnItemsOnMap(types)
    local data = self.itemLists[types]
    local pos = self.itemSpawns[types]
    if (data and pos) then        
        local atari = {}
        for itemID, chances in pairs(data.items or {}) do
            if (math.Rand(0, 1) <= chances) then
                table.insert(atari, itemID)
            end
        end
        
        do
            local max = data.max or 1
            local cnt = table.Count(pos)
            local rndIdx = {}

            while (table.Count(rndIdx) < math.min(cnt, max)) do
                local rdix = math.random(1, cnt)
                
                if (!table.HasValue(rndIdx, rdix)) then
                    table.insert(rndIdx, rdix)
                end
            end
            
            local delay = 0
            for k, v in ipairs(rndIdx) do
                timer.Simple(delay, function()
                    local spawnPos = pos[v]
					local atari = table.Random(atari)
					local itemTable = nut.item.list[atari]
					if (spawnPos and itemTable) then
						local c = ents.Create("nut_tempitem")
						c:Spawn()
						c:setItem(atari)
						local ca, cb = c:GetCollisionBounds()
						c:SetPos(spawnPos + cb)

						local physObj = c:GetPhysicsObject()

						if (IsValid(physObj)) then
							physObj:EnableMotion(false)
						end

						c:CallOnRemove( "removeindex", function(ccac) 
						end)

						timer.Simple(data.interval - delay, function()
							if (IsValid(c)) then
								c:Remove()
							end
						end)
					end
                end)

                delay = delay + .1
            end
        end
    end
end

function SCHEMA:ItemSpawnerPayload()
	for k, v in pairs(self.itemLists) do
		timer.Create("itemSpawner_" .. k, v.interval, 0, function()
			self:SpawnItemsOnMap(k)
		end)
	end	
end

function SCHEMA:SpawnNPCOnMap(types)
    local data = self.npcLists[types]
    local pos = self.npcSpawns[types]
    if (data and pos) then        
        local atari = {}
        for itemID, chances in pairs(data.items or {}) do
            if (math.Rand(0, 1) <= chances) then
                table.insert(atari, itemID)
            end
        end
        
        do
            local max = data.max or 1
            local cnt = table.Count(pos)
            local rndIdx = {}
            while (table.Count(rndIdx) < math.min(cnt, max)) do
                local rdix = math.random(1, cnt)
                
                if (!table.HasValue(rndIdx, rdix)) then
                    table.insert(rndIdx, rdix)
                end
            end
            
            local delay = 0
            for k, v in ipairs(rndIdx) do
                timer.Simple(delay, function()
                    local spawnPos = pos[v]
                    if (spawnPos) then
                        local c = ents.Create(table.Random(atari))
                        c:Spawn()
						local ca, cb = c:GetCollisionBounds()
                        c:SetPos(spawnPos + cb)
                        timer.Simple(data.interval - delay, function()
                            if (IsValid(c)) then
                                c:Remove()
                            end
                        end)
                    end
                end)
                delay = delay + .1
            end
        end
    end
end

function SCHEMA:NPCSpawnerPayload()
    for k, v in pairs(self.npcLists) do
        timer.Create("npcSpawner_" .. k, v.interval, 0, function()
            self:SpawnNPCOnMap(k)
        end)
    end	
end

function SCHEMA:OnPlayerSafeUpdated(client, bool)
	netstream.Start(client, "nutSafeZone", bool)
end

function SCHEMA:PlayerShouldTakeDamage(client, attacker)
	if (IsValid(attacker) and attacker:IsPlayer() and (attacker:getNetVar("protected") or attacker:isInSafe())) then
		return false
	end

	if (client:getNetVar("protected") or client:isInSafe()) then
		return false
	end
end	

function SCHEMA:ResetVariables(client, signal)
	local char = client:getChar()
	if (signal == SIGNAL_DEATH) then
		-- 모든 상태이상을 초기화
		char:setData("b_inf", nil) -- 감염
		char:setData("b_leg", nil) -- 골절
		char:setData("b_bld", nil) -- 출혈

		-- 모든 페널티를 초기화
		client:resetPenalty()
	end

	if (signal == SIGNAL_DEATH or signal == SIGNAL_CHAR) then
		local inv = char:getInv()
		local items = inv:getItems()

		for _, item in pairs(items) do
			if (item.hasEffect) then
				if (item:getData("equip")) then
					item:setData("equip", nil)

					-- 클라이언트에서 후크는 사라지니까
					-- 일단 데이터를 서버에서 처리한다.
					-- 어쩌면 일단 1차적으로는 필요가 없을지도
					if (item.hooks.EquipUn) then	
						item.hooks.EquipUn(item)
					end
				end
			end
		end
	end
end