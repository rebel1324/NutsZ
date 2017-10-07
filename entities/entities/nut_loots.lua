AddCSLuaFile()

ENT.Type = "anim"
ENT.PrintName = "Stash"
ENT.Author = "Black Tea"
ENT.Spawnable = true
ENT.AdminOnly = false
ENT.Category = "NutScript"
ENT.RenderGroup 		= RENDERGROUP_BOTH

if (SERVER) then
	function ENT:SpawnFunction(client, trace, className)
		if (!trace.Hit or trace.HitSky) then return end

		local ent = ents.Create(className)
		local pos = trace.HitPos + trace.HitNormal * 50
		ent:SetPos(pos)
		ent:Spawn()
		ent:Activate()

		return ent
	end

	function ENT:Initialize()
		self:SetModel("models/props_c17/SuitCase_Passenger_Physics.mdl")
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetUseType(SIMPLE_USE)
		local physicsObject = self:GetPhysicsObject()

		if (IsValid(physicsObject)) then
			physicsObject:Wake()
		end

		self:setNetVar("delTime", CurTime() + 120)
		
		timer.Simple(120, function()
			if (IsValid(self)) then
				self:Remove()
			end			
		end)
	end

	function ENT:Use(activator)
		if (!self.looted and activator:getChar() and hook.Run("PlayerCanOpenLoot", activator, self) != false) then
			activator.nutLoot = self
			self.looted = activator

			netstream.Start(activator, "openLoot", self, self.items)
		end
	end

	function ENT:OnRemove()
		for k, v in pairs(self.items) do
			local item = nut.item.instances[v.id]

			if (item) then
				item:remove()
			end
		end
	end

	function ENT:setItems(items)
		self.items = items
	end

	function ENT:getItemCount()
		local count = 0

		for k, v in pairs(self.items) do
			count = count + 1
		end

		return count
	end
else
	ENT.DrawEntityInfo = true

	local toScreen = FindMetaTable("Vector").ToScreen
	local colorAlpha = ColorAlpha
	local drawText = nut.util.drawText
	
	local cir = {}
	local cir2= setmetatable({},{__index=function(self,key)
		local t = {}
		self[key]=t
		return t
	end})
	
	local size = 150
	local tempMat = Material("particle/warp1_warp", "alphatest")
	function ENT:Draw()
		local pos, ang = self:GetPos(), self:GetAngles()
		
		self:DrawModel()
		
		pos = pos + self:GetUp()*-10.5
		pos = pos + self:GetForward()*0
		pos = pos + self:GetRight()*4
		
		local delTime = math.max(math.ceil(self:getNetVar("delTime", 0) - CurTime()), 0)

        local ass = delTime < 20 and math.abs(math.sin(RealTime() * 15) * 155) or 200
        local assColor = Color(255, ass + 55, ass + 55)

		local func = function() 
			surface.SetMaterial(tempMat)
			surface.SetDrawColor(0, 0, 0, 200)
			surface.DrawTexturedRect(-size/2, -size/2 - 10, size, size)
	
			nut.util.drawText("k", 0, 0, assColor, 1, 4, "nutIconsBig")
			nut.util.drawText(delTime, 0, -10, assColor, 1, 5, "nutBigFont")
		end
		
		ang:RotateAroundAxis(ang:Forward(), 90)
		cam.Start3D2D(pos, ang, .1)
			func()
		cam.End3D2D()
		
		ang:RotateAroundAxis(ang:Right(), 180)
		pos = pos - self:GetRight()*8
		
		cam.Start3D2D(pos, ang, .1)
			func()
		cam.End3D2D()
	end
	
	function ENT:onDrawEntityInfo(alpha)
		local position = toScreen(self.LocalToWorld(self, self.OBBCenter(self)))
		local x, y = position.x, position.y
		local owner = nut.char.loaded[self.getNetVar(self, "owner", 0)]

		drawText(L"shipment", x, y, colorAlpha(nut.config.get("color"), alpha), 1, 1, nil, alpha * 0.65)

		if (owner) then
			drawText(L("shipmentDesc", owner.getName(owner)), x, y + 16, colorAlpha(color_white, alpha), 1, 1, "nutSmallFont", alpha * 0.65)
		end
	end
end