AddCSLuaFile()

ENT.Type = "anim"
ENT.PrintName = "Terminal"
ENT.Author = "Black Tea"
ENT.Category = "Nutscript"
ENT.Spawnable = true
ENT.AdminOnly = false
ENT.invType = "terminal"
ENT.RenderGroup = RENDERGROUP_BOTH

local color_green = Color(51,251,51,255)
local color_red = Color(255,0,0,255)

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
		self:SetUseType(SIMPLE_USE)

		local physObj = self:GetPhysicsObject()
		if (IsValid(physObj)) then
			physObj:EnableMotion(false)
		end
	end

	function ENT:setInventory(inventory)
	end

	function ENT:OnRemove()
		self.loopsound:Stop()
	end

	function ENT:Use(client)
		if (self.onUse) then
			self:onUse(client)
		end

		local terminal = client:getNetVar("terminal")
		if (self.user and self.user == client) then
			self.user = nil

			netstream.Start(client, "nutClick", false)
			client:setNetVar("terminal", nil)
		else
			if (!terminal or (terminal and terminal:IsValid())) then
				netstream.Start(client, "nutClick", true)
				client:setNetVar("terminal", self)

				self.user = client
			end
		end
	end

	function ENT:Think()
		if (self.user and self.user:IsValid()) then
			local dist = self.user:GetPos():Distance(self:GetPos())

			if (dist > 80) then
				netstream.Start(self.user, "nutClick", false)
				self.user:setNetVar("terminal", nil)
				self.user = nil
				self.access = nil
			end
		end
	end

	function ENT:OnRemove()
	end

	function ENT:getDisk()
		local item = self:getNetVar("id")
		local itemData = nut.item.instances[item]

		if (!itemData) then
			nut.item.loadItemByID(item, 0, nil) -- try again
			itemData = nut.item.instances[item]
		end

		return itemData
	end

	function ENT:insertDisk(client, disk)
		local char = client:getChar()

		if (char) then
			local inv = char:getInv()

			if (inv) then
				local item = disk or inv:hasItem("disk")

				if (item) then
					self:EmitSound("ambient/machines/combine_terminal_idle1.wav", 60, 200)

					local good, why = item:transfer(nil, nil, nil, client, nil, true)
					if (good) then
						self:setNetVar("id", item.id)
					end
				end
			end
		end
	end

	function ENT:ejectDisk(client, disk)
		local char = client:getChar()

		if (char) then
			local item = self:getNetVar("id")

			if (item) then
				local itemData = nut.item.instances[item]

				if (!itemData) then
					nut.item.loadItemByID(item, 0, nil) -- try again
					itemData = nut.item.instances[item]
				end

				local good = itemData:transfer(char:getInv():getID(), nil, nil, client)
				if (good) then
					self:EmitSound("ambient/machines/combine_terminal_idle1.wav", 60, 200)
					self:setNetVar("id", nil)
				end
			end
		end
	end
else
	local background = Material("models/props_combine/combine_monitorbay_disp")
	local gradient = nut.util.getMaterial("vgui/gradient-d")
	local gradient2 = nut.util.getMaterial("vgui/gradient-u")

	local function ieDisk(screen, entity, index)
		local disk = entity:getNetVar("id")

		if (disk) then
			return "ejectDisk"
		else
			return "insertDisk"
		end
	end

	local function ulTerminal(screen, entity, index)
		local locked = entity:getNetVar("locked")

		if (locked) then
			return "unlockTerminal"
		else
			return "lockTerminal"
		end
	end

	local function funcInsert(screen, entity)
		local client = LocalPlayer()
		local disk = entity:getNetVar("id")

		if (disk) then
			netstream.Start("nutTerminal", TERMINAL_EJECT)
		else
			if (nut.terminal.diskui) then return end
			vgui.Create("nutTerminalDisk")
			--netstream.Start("nutTerminal", TERMINAL_INSERT, 1)
		end
	end

	local function funcDiskRead(screen, entity)
		local client = LocalPlayer()
		local disk = entity:getNetVar("id")

		if (disk) then
			netstream.Start("nutTerminal", TERMINAL_READ)
		end
	end

	local function funcDiskWrite(screen, entity)
		local client = LocalPlayer()
		local disk = entity:getNetVar("id")

		if (disk) then
			netstream.Start("nutTerminal", TERMINAL_WRITEUI)
		end
	end

	local lockedDerma
	local function funcLock(screen, entity)
		local locked = entity:getNetVar("locked")

		if (!locked) then
			lockedDerma = true

			local vote = Derma_StringRequest(
				L("enterPassword"),
				L("enterPassword"),
				0,
				function(a)
					netstream.Start("nutTerminal", TERMINAL_LOCK, a)
				end
			)

			vote.OnRemove = function()
				lockedDerma = false
			end
		else
			netstream.Start("nutTerminal", TERMINAL_UNLOCK, a)
		end
	end

	local commands = {
		{ieDisk, funcInsert, false},
		{"readDisk", funcDiskRead, true},
		{"writeDisk", funcDiskWrite, true},
		{ulTerminal, funcLock, false},
	}

	local function isGUIOn()
		return (
			(nut.terminal.diskui) or
			(nut.terminal.diskui2) or
			donkatsu == true
		)
	end

	local function renderCode(self, ent, w, h)
		local char = LocalPlayer():getChar()

		if (char) then
			local mx, my = self:mousePos()
			local scale = 1 / self.scale
			local bx, by, color, idxAlpha

			surface.SetMaterial(background)
			surface.SetDrawColor(255, 255, 255)
			surface.DrawTexturedRect(0, 0, w+220, h+300)

			surface.SetDrawColor(0, 0, 0, 250)
			surface.DrawRect(0, 0, w, h+1)


			local terminal = LocalPlayer():getNetVar("terminal")
			if (vgui.CursorVisible() and (terminal == self.entity)) then
				self.dorp = math.max(self.dorp - FrameTime(), 0)
				self.pokeGo = nil

				if (self.entity:getNetVar("locked") and !self.access) then
					local tx, ty = draw.SimpleText("P", "nutIconsBig", w/2, h/2 - 45, color_red, 1, 4)
					tx, ty = draw.SimpleText(L"tlocked", "nutBigFont", w/2, h/2 - 15, color_white, 1, 5)

					local sp, sp2 = 8 * scale, 3 * scale
					local bp, bp2 = w/2 - sp/2, h - sp2*1.9

					local bool = self:cursorInBox(bp, bp2, sp, sp2)

					self.pokeGo = bool

					surface.SetDrawColor(46, 204, 113)
					surface.DrawRect(bp, bp2, sp, sp2)
					surface.SetDrawColor(0, 0, 0, 155)
					surface.SetMaterial((self.IN_USE and bool) and gradient2 or gradient)
					surface.DrawTexturedRect(bp, bp2, sp, sp2)
					surface.SetDrawColor(39, 174, 113)
					surface.DrawOutlinedRect(bp+2.5, bp2+2.5, sp-5, sp2-5)

					nut.util.drawText(L"tlogin", bp + sp/2, bp2 + sp2/2 - 3, color_white, 1, 1, "nutMediumFont")
				else
					self.access = true
					self.curSel = -1

					local tx, ty = draw.SimpleText(self.entity.title or L("twelcome", LocalPlayer():UserCPP()), "nutBigFont", w/2, 1 * scale, color_white, 1, 5)

					for i, v in ipairs(commands) do
						local idx = i
						local sp, sp2 = 12 * scale, 3 * scale
						local bp, bp2 = w/2 - sp/2, 0 + sp2*idx + sp*0.06*idx + 10

						local bool = self:cursorInBox(bp, bp2, sp, sp2)

						if (bool) then
							self.pokeGo = i
						end

						surface.SetDrawColor(46, 204, 113)
						surface.DrawRect(bp, bp2, sp, sp2)

						surface.SetDrawColor(0, 0, 0, 155)
						surface.SetMaterial((self.IN_USE and bool) and gradient2 or gradient)
						surface.DrawTexturedRect(bp, bp2, sp, sp2)

						surface.SetDrawColor(39, 174, 113)
						surface.DrawOutlinedRect(bp+2.5, bp2+2.5, sp-5, sp2-5)

						local text = v[1]
						if (type(v[1]) == "function") then
							text = v[1](self, self.entity, i)
						end
						text = L(text)

						nut.util.drawText(text, bp + sp/2, bp2 + sp2/2 - 3, color_white, 1, 1, "nutMediumFont")
					end
				end

				surface.SetDrawColor(0, 0, 0, 250 * self.dorp)
				surface.DrawRect(0, 0, w, h+1)
			else
				self.access = nil
				surface.SetDrawColor(0, 0, 0, 250 * self.dorp)
				surface.DrawRect(0, 0, w, h+1)

				self.dorp = 1

				local tx, ty = draw.RoundedBoxEx(28, w/2 - 29.7, h/2 - 69, 59, 57.6, color_green, true, true, true, true)
				tx, ty = draw.SimpleText(L"ttext", "nutBigFont", w/2, h/2 + 27, color_white, 1, 5)
				tx, ty = draw.SimpleText("F", "nutIconsBig", w/2, h/2 - 15, color_white, 1, 4)
			end
		end
	end

	-- This function called when client clicked(Pressed USE, Primary/Secondary Attack).
	local donkatsu = false
	local function onMouseClick(self)
		if (self.entity:getNetVar("locked") and !self.access) then
			if (self.pokeGo) then
				if (!donkatsu) then
					donkatsu = true

					local vote = Derma_StringRequest(
						L("enterPassword"),
						L("enterPassword"),
						0,
						function(a)
							netstream.Start("nutTerminalPassword", a)
						end
					)

					vote.OnRemove = function()
						donkatsu = false
					end
				end
			end
		else
			local commandData = commands[self.pokeGo]

			if (commandData) then
				if (commandData[2]) then
					commandData[2](self, self.entity)
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
		self.screen = nut.screen.new(100, 100, .3)

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

			self.screen.w, self.screen.h, self.screen.scale = 25, 20, .07

			-- fuckoff
			self.screen.renderCode = renderCode
			self.screen.onMouseClick = onMouseClick

			local dist = LocalPlayer():GetPos():Distance(self:GetPos())

			if (dist < 512) then
				self.screen:render()
			end
		end
	end

	function ENT:Think()
		if (vgui.CursorVisible() and !isGUIOn()) then
			self.screen:think()
		end
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
