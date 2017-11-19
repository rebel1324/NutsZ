AddCSLuaFile()

ENT.Type = "anim"
ENT.PrintName = "Item"
ENT.Category = "NutScript"
ENT.Spawnable = true
ENT.AdminOnly = false
ENT.RenderGroup = RENDERGROUP_BOTH

if (SERVER) then
	function ENT:SpawnFunction(client, trace, class)
		local entity = ents.Create(class)
		entity:SetPos(trace.HitPos + trace.HitNormal * 20)
		entity:Spawn()
		entity:Activate()

		entity:setItem("spraycan")

		return entity
	end

	function ENT:Initialize()
		self:SetModel("models/props_junk/watermelon01.mdl")
		self:SetUseType(SIMPLE_USE)
		self:SetMoveType(MOVETYPE_NONE)
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetCollisionGroup(COLLISION_GROUP_DEBRIS)

		local physObj = self:GetPhysicsObject()

		if (IsValid(physObj)) then
			physObj:EnableMotion(false)
		end
	end
	
	function ENT:OnTakeDamage(dmginfo)
		local damage = dmginfo:GetDamage()
		self:setHealth(self.health - damage)

		if (self.health < 0 and !self.onbreak) then
			self.onbreak = true
			self:Remove()
		end
	end

	function ENT:setItem(className)
		local itemTable = nut.item.list[className]
        self:setNetVar("uniqueID", className)

		if (itemTable) then
			local model = itemTable.onGetDropModel and itemTable:onGetDropModel(self) or itemTable.model

			self:SetModel(model)
			self:SetSkin(itemTable.skin or 0)
			self:PhysicsInit(SOLID_VPHYSICS)
			self:SetSolid(SOLID_VPHYSICS)

			local physObj = self:GetPhysicsObject()

			if (!IsValid(physObj)) then
				local min, max = Vector(-8, -8, -8), Vector(8, 8, 8)

				self:PhysicsInitBox(min, max)
				self:SetCollisionBounds(min, max)
			end

			if (IsValid(physObj)) then
				physObj:EnableMotion(true)
				physObj:Wake()
			end

			if (itemTable.onEntityCreated) then
				itemTable:onEntityCreated(self)
			end
		end
	end

	function ENT:Use(client)
		local char = client:getChar()
		local inv = char:getInv()

		local addItem, reason = inv:add(self:getNetVar("uniqueID"))
		if (addItem) then
			self:EmitSound("physics/cardboard/cardboard_box_break"..math.random(1, 3)..".wav")
			self:Remove()	
		else
			client:notifyLocalized(reason)
		end
	end
else
	ENT.DrawEntityInfo = true

	local toScreen = FindMetaTable("Vector").ToScreen
	local colorAlpha = ColorAlpha

	function ENT:onDrawEntityInfo(alpha)
		local itemTable = self.getItemTable(self)

		if (itemTable) then
			local oldData = itemTable.data
			itemTable.data = self.getNetVar(self, "data", {})
			itemTable.entity = self

			local position = toScreen(self.LocalToWorld(self, self.OBBCenter(self)))
			local x, y = position.x, position.y
			local description = itemTable.getDesc and itemTable.getDesc(itemTable)

			if (description != self.desc) then
				self.desc = description
				self.lines, self.offset = nut.util.wrapText(description, ScrW() * 0.7, "nutSmallFont")
				self.offset = self.offset * 0.5
			end
			
			nut.util.drawText(L(itemTable.name), x, y, colorAlpha(nut.config.get("color"), alpha), 1, 1, nil, alpha * 0.65)

			local lines = self.lines
			local offset = self.offset

			for i = 1, #lines do
				nut.util.drawText(lines[i], x, y + (i * 16), colorAlpha(color_white, alpha), 1, 1, "nutSmallFont", alpha * 0.65)
			end

			itemTable.entity = nil
			itemTable.data = oldData
		end		
	end

	local mat = Material("trails/laser")
	local mat2 = Material("sprites/glow04_noz.vmt")
	function ENT:DrawTranslucent()
		local itemTable = self:getItemTable()
		
		if (itemTable and itemTable.drawEntity) then
			itemTable:drawEntity(self, itemTable)
		end

		local color = color_white

		if (itemTable and itemTable.isWeapon) then
			color = Color(241, 255, 111)
		end	

		local ob = self:OBBCenter()
		local olen = math.max(ob:Length(), 8)
		local pos, dir, scale = self:GetPos(), Vector(0, 0, 1),32

        pos = pos + self:GetUp() * ob[3]
        pos = pos + self:GetRight() * -ob[2]
        pos = pos + self:GetForward() * ob[1]

		render.SetMaterial( mat )
		render.StartBeam( 3 )
			render.AddBeam( pos, scale, 1, ColorAlpha(color, 128 ) )
			render.AddBeam( pos + dir * olen * 1.5, scale, 1, ColorAlpha(color, 64 ) )
			render.AddBeam( pos + dir * olen * 3, scale, 1, ColorAlpha(color, 0 ) )
		render.EndBeam()

		render.SetMaterial(mat2)
		render.DrawSprite(pos, 12*olen, 2*olen, ColorAlpha(color, 120 ))
		render.DrawSprite(pos, 6*olen, 6*olen, ColorAlpha(color, 120 ))
	end
end

function ENT:getItemTable()
	return nut.item.list[self:getNetVar("uniqueID", "")] or {}
end

function ENT:getData(key, default)
	local data = self:getNetVar("data", {})

	return data[key] or default
end