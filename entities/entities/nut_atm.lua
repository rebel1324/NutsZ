AddCSLuaFile()

ENT.Type = "anim"
ENT.PrintName = "ATM"
ENT.Author = "Black Tea"
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

		return entity
	end

	function ENT:Initialize()
		self:SetModel("models/props_combine/breenconsole.mdl")
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)

		local physObj = self:GetPhysicsObject()
		if (IsValid(physObj)) then
			physObj:EnableMotion(false)
		end
	end
else
	local gradient = nut.util.getMaterial("vgui/gradient-d")
	local gradient2 = nut.util.getMaterial("vgui/gradient-u")

	STATUS_DEPOSIT = 1
	STATUS_WITHDRAW = 2
	STATUS_INFO = 3
	STATUS_STANBY = 0


	surface.CreateFont("nutNATMFont", {
		font = "Malgun Gothic",
		extended = true,
		size = 40,
		weight = 1000
	})

	surface.CreateFont("nutSubNATMFont", {
		font = "Malgun Gothic",
		extended = true,
		size = 24,
		weight = 500
	})

	surface.CreateFont("nutKeypadFont", {
		font = "Trebuchet MS",
		extended = true,
		size = 25,
		weight = 500
	})

	local text = {
		"deposit", "withdraw", "info"
	}
	local text2 = {
		"reset", "allmoney", "deposit"
	}

	local keypad = {	
		"1", "2", "3",
		"4", "5", "6",
		"7", "8", "9",
		"0", "00", "s",
	}

	local selections = 0
	local goText = ""
	local function renderCode(self, ent, w, h)
		local char = LocalPlayer():getChar()

		if (char) then
			local mx, my = self:mousePos()
			local scale = 1 / self.scale
			local bx, by, color, idxAlpha	

			surface.SetDrawColor(0, 0, 0, 255)
			surface.DrawRect(0, 0, w, h)	

			if (self.hasFocus) then
				self.dorp = math.max(0, self.dorp - FrameTime())

				surface.SetMaterial(gradient)
				surface.SetDrawColor(255, 255, 255, 30)
				surface.DrawTexturedRect(0, 0, w, h)

				selections = 0
				if (self.status == STATUS_STANBY) then
					draw.SimpleText("라크 은행", "nutNATMFont", w/2, scale, color_white, 1, 5)
					draw.SimpleText("언제나 고객을 생각하는 은행", "nutSubNATMFont", w/2, scale*3.5, color_white, 1, 5)

					for i = 1, 3 do
						local sp, sp2 = 12 * scale, 3 * scale
						local bp, bp2 = w/2 - sp/2, scale * 7 + (i-1) * sp2*1.3

						local bool = self:cursorInBox(bp, bp2, sp, sp2)

						if (bool) then
							selections = i
						end

						surface.SetDrawColor(46, 204, 113)
						surface.DrawRect(bp, bp2, sp, sp2)
						surface.SetDrawColor(0, 0, 0, 155)
						surface.SetMaterial((self.IN_USE and bool) and gradient2 or gradient)
						surface.DrawTexturedRect(bp, bp2, sp, sp2)
						surface.SetDrawColor(39, 174, 113)
						surface.DrawOutlinedRect(bp+2.5, bp2+2.5, sp-5, sp2-5)

						draw.SimpleText(L(text[i]), "nutSubNATMFont", bp + sp/2, bp2 + sp2/2 - 2, color_white, 1, 1)
					end
					goText = ""
				elseif (self.status == STATUS_DEPOSIT or self.status == STATUS_WITHDRAW) then
					draw.SimpleText(
						L(self.status == STATUS_DEPOSIT and "myMoney" or "bankMoney")
					, "nutSubNATMFont", scale*1.5, scale, color_white, 3, 5)

					local b1, b2 = w*0.9, scale*2
					local p1, p2 = w/2, scale*4
					surface.SetDrawColor(0, 0, 0, 100)
					surface.DrawRect(p1 - b1/2, p2 - b2/2, b1, b2)
					draw.SimpleText(
						nut.currency.get(
							self.status == STATUS_DEPOSIT and char:getMoney() or char:getReserve()
						)
					, "nutSubNATMFont", p1 - b1/2 + scale * 0.5, p2-2, color_white, 3, 1)

					draw.SimpleText(
						L(self.status == STATUS_DEPOSIT and "depositAmount" or "withdrawAmount")
					, "nutSubNATMFont", scale*1.5, p2 + scale*1.2, color_white, 3, 5)

					p1, p2 = w/2, scale*8.3
					surface.SetDrawColor(0, 0, 0, 100)
					surface.DrawRect(p1 - b1/2, p2 - b2/2, b1, b2)
					draw.SimpleText(nut.currency.get((goText == "" and 0 or goText)) .. (RealTime()%2 >= 1 and "_" or ""), "nutSubNATMFont", p1 - b1/2 + scale * 0.5, p2-2, color_white, 3, 1)
					
					p1, p2 = scale*2.2, scale*11
					local kx, ky = 0, 0
					local kw, kh = scale*2, scale*2
					for k, v in ipairs(keypad) do
						local col = math.ceil(k/3)
						local row = (k%3) 
						
						kx, ky = p1 - kw/2 + (row == 0 and 2 or row - 1) * kw * 1.1, p2 - kh/2 + (col-1) * kh * 1.1
						local bool = self:cursorInBox(kx, ky, kw, kh)

						if (bool) then
							selections = "k" .. k
						end

						surface.SetDrawColor(0, 0, 0, bool and 200 or 100)
						surface.DrawRect(kx, ky, kw, kh)
						draw.SimpleText(v, k == 12 and "nutIconsSmall" or "nutKeypadFont", kx + kw/2 - 1, ky + kh/2 - 2, color_white, 1, 1)
					end

					for i = 1, 3 do
						local sp, sp2 = 9 * scale, 2.5 * scale
						local bp, bp2 = w - sp - scale*1.3, scale * 10.2 + (i-1) * sp2*1.2

						local bool = self:cursorInBox(bp, bp2, sp, sp2)

						if (bool) then
							selections = "b" .. i
						end

						surface.SetDrawColor(46, 204, 113)
						surface.DrawRect(bp, bp2, sp, sp2)
						surface.SetDrawColor(0, 0, 0, 155)
						surface.SetMaterial((self.IN_USE and bool) and gradient2 or gradient)
						surface.DrawTexturedRect(bp, bp2, sp, sp2)
						surface.SetDrawColor(39, 174, 113)
						surface.DrawOutlinedRect(bp+2.5, bp2+2.5, sp-5, sp2-5)

						local btt = text2[i]

						if (i == 3) then
							if (goText == "") then
								btt = "cancel"
							else
								btt = self.status == STATUS_DEPOSIT and "deposit" or "withdraw"
							end
						end

						draw.SimpleText(L(btt), "nutSubNATMFont", bp + sp/2, bp2 + sp2/2 - 2, color_white, 1, 1)
					end
				elseif (self.status == STATUS_INFO) then
					draw.SimpleText(
						L("bankMoney")
					, "nutSubNATMFont", scale*1.5, scale, color_white, 3, 5)
					local b1, b2 = w*0.9, scale*2
					local p1, p2 = w/2, scale*4
					surface.SetDrawColor(0, 0, 0, 100)
					surface.DrawRect(p1 - b1/2, p2 - b2/2, b1, b2)
					draw.SimpleText(
						nut.currency.get(
							char:getReserve()
						)
					, "nutSubNATMFont", p1 - b1/2 + scale * 0.5, p2-2, color_white, 3, 1)

					draw.SimpleText(
						L("profitRate")
					, "nutSubNATMFont", scale*1.5, p2 + scale*1.2, color_white, 3, 5)
					p1, p2 = w/2, scale*8.3
					surface.SetDrawColor(0, 0, 0, 100)
					surface.DrawRect(p1 - b1/2, p2 - b2/2, b1, b2)
					draw.SimpleText(
						(nut.config.get("incomeRate") / 100) .. "%"
					, "nutSubNATMFont", p1 - b1/2 + scale * 0.5, p2-2, color_white, 3, 1)

					draw.SimpleText(
						L("profitAmount")
					, "nutSubNATMFont", scale*1.5, p2 + scale*1.2, color_white, 3, 5)
					p1, p2 = w/2, scale*12.7
					surface.SetDrawColor(0, 0, 0, 100)
					surface.DrawRect(p1 - b1/2, p2 - b2/2, b1, b2)
					draw.SimpleText(
						nut.currency.get(
							math.Round(char:getReserve() * (nut.config.get("incomeRate") / 100))
						)
					, "nutSubNATMFont", p1 - b1/2 + scale * 0.5, p2-2, color_white, 3, 1)
				end

				surface.SetDrawColor(0, 0, 0, 255 * self.dorp)
				surface.DrawRect(0, 0, w, h)	
			else
				self.dorp = 1
				self.status = STATUS_STANBY

				local tx, ty = draw.SimpleText("8", "nutIconsBig", w/2, h/2, color_white, 1, 4)
				tx, ty = draw.SimpleText("LAC BANK", "nutBigFont", w/2, h/2, color_white, 1, 5)
			end
		end
	end

	local donkatsu = false
	local function onMouseClick(self)
		if (self.status == STATUS_STANBY) then
			self.status = selections
		elseif (self.status == STATUS_DEPOSIT or self.status == STATUS_WITHDRAW) then
			selections = tostring(selections)

			if (selections:find("k")) then
				local cursel = tonumber(string.Replace(selections, "k", ""))

				if (cursel != 12) then
					goText = goText .. keypad[cursel]
				else
					goText = goText:sub(1, goText:len() - 1)
				end
			elseif (selections:find("b")) then
				local cursel = tonumber(string.Replace(selections, "b", ""))

				if (cursel == 1) then
					goText = ""
				elseif (cursel == 2) then
					local char = LocalPlayer():getChar()
					goText = tostring(
										math.Round(
												self.status == STATUS_DEPOSIT and char:getMoney() or char:getReserve()
											)
									)
				elseif (cursel == 3) then
					if (goText != "") then
						LocalPlayer():ConCommand(Format("say %s %s", 
							self.status == STATUS_DEPOSIT and "/bankdeposit" or "/bankwithdraw" 
						, goText))
					end

					self.status = STATUS_STANBY
				end
			end
		end
	end

	ENT.modelData = {}
	local MODEL = {}
	MODEL.model = "models/props_combine/combine_smallmonitor001.mdl"
	MODEL.angle = Angle(0, 0, -90)
	MODEL.position = Vector(0, -10, 50)
	MODEL.scale = Vector(1, 1, 1)
	ENT.modelData["screen"] = MODEL

	WORLDEMITTER = WORLDEMITTER or ParticleEmitter(Vector(0, 0, 0))

	function ENT:Initialize()
		-- Creates new Touchable Screen Object for this Entity.
		self.screen = nut.screen.new(25, 20, .07)
		
		-- Initialize some variables for this Touchable Screen Object.
		self.screen.noClipping = false
		self.screen.fadeAlpha = 1
		self.screen.idxAlpha = {}
		self.screen.dorp = 1
		self.screen.entity = self

		-- Make the local "renderCode" function as the Touchable Screen Object's 3D2D Screen Rendering function.
		self.screen.renderCode = renderCode

		-- Make the local "onMouseClick" function as the Touchable Screen Object's Input event.
		self.screen.onMouseClick = onMouseClick

		self.lerp = 0
		self.models = {}
		
		for k, v in pairs(self.modelData) do
			self.models[k] = ClientsideModel(v.model, RENDERGROUP_BOTH )
			self.models[k]:SetColor( v.color or color_white )
			self.models[k]:SetNoDraw(true)

			if (v.material) then
				self.models[k]:SetMaterial( v.material )
			end
		end
	end

	function ENT:OnRemove()
		for k, v in pairs(self.models) do
			if (v and v:IsValid()) then
				v:Remove()
			end
		end
	end

	local gap = 4
	function ENT:DrawTranslucent()
		local drawEntity = self.models["screen"]

		if (drawEntity and drawEntity:IsValid()) then
			local coPos, coAng = drawEntity:GetRenderOrigin(), drawEntity:GetRenderAngles()

			coPos = coPos + self:GetForward() * 2
			coPos = coPos + self:GetRight() * 15
			coPos = coPos + self:GetUp() * 10

			-- Update the Rendering Position and angle of the Touchable Screen Object.
			self.screen.pos = coPos
			self.screen.ang = coAng
			self.screen.ent = self

			-- fuckoff
			self.screen.renderCode = renderCode
			self.screen.onMouseClick = onMouseClick

			local dist = LocalPlayer():GetPos():Distance(self:GetPos())

			if (dist < 512) then
				self.screen:render()
			else
				self.screen.status = 0
			end
		end
	end

	function ENT:Think()
		self.screen:think()
	end

	function ENT:Draw()
		for uid, dat in pairs(self.modelData) do
			local drawEntity = self.models[uid]

			if (drawEntity and drawEntity:IsValid()) then
				local pos, ang = self:GetPos(), self:GetAngles()
				local ang2 = ang

				pos = pos + self:GetForward() * dat.position[1]
				pos = pos + self:GetRight() * dat.position[2]
				pos = pos + self:GetUp() * dat.position[3]

				ang:RotateAroundAxis(self:GetForward(), dat.angle[1])
				ang:RotateAroundAxis(self:GetRight(), dat.angle[2])
				ang:RotateAroundAxis(self:GetUp(), dat.angle[3])

				if (dat.scale) then
					local matrix = Matrix()
					matrix:Scale((dat.scale or Vector( 1, 1, 1 )))
					drawEntity:EnableMatrix("RenderMultiply", matrix)
				end

				drawEntity:SetRenderOrigin( pos )
				drawEntity:SetRenderAngles( ang2 )
				drawEntity:DrawModel()
			end
		end

		self:DrawModel()
	end

	function ENT:OnRemove()
	end
end