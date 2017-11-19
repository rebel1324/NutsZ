local PLUGIN = PLUGIN
PLUGIN.name = "Terminal"
PLUGIN.author = "Black Tea"
PLUGIN.desc = "Good stuffs."
PLUGIN.stashData = PLUGIN.stashData or {}

TERMINAL_READ = 1
TERMINAL_WRITE = 2
TERMINAL_LOCK = 3
TERMINAL_UNLOCK = 4
TERMINAL_INSERT = 5
TERMINAL_EJECT = 6
TERMINAL_WRITEUI = 7

nut.util.include("cl_vgui.lua")

nut.item.registerInv("terminal", 2, 2)

nut.terminal = nut.terminal or {}

if (SERVER) then
	function PLUGIN:LoadData()
		local savedTable = self:getData() or {}

		for k, v in ipairs(savedTable) do
			local terminal = ents.Create("nut_terminal")
			terminal:SetPos(v.pos)
			terminal:SetAngles(v.ang)
			terminal:Spawn()
			terminal:Activate()

			local id = v.id
			terminal:setNetVar("id", v.id)

			nut.item.loadItemByID(v.id, 0, nil)
		end
	end

	function PLUGIN:SaveData()
		local savedTable = {}

		for k, v in ipairs(ents.GetAll()) do
			if (v:GetClass() == "nut_terminal") then
				table.insert(savedTable, {
					pos = v:GetPos(),
					ang = v:GetAngles(),
					password = v.password,
					id = v:getNetVar("id"),
				})
			end
		end

		self:setData(savedTable)
	end

	function PLUGIN:PlayerDeath(client)
		netstream.Start(client, "nutClick", false)
		client:setNetVar("terminal", nil)
	end

	netstream.Hook("nutTerminalPassword", function(client, password)
		local terminalEnt = client:getNetVar("terminal")

		if (terminalEnt and terminalEnt:IsValid()) then
			terminalEnt:EmitSound(Format("ambient/machines/keyboard_fast%s_1second.wav", math.random(1, 3)), 100, 150)


			local locked = terminalEnt:getNetVar("locked")

			if (locked) then
				if (terminalEnt.password == password) then
					terminalEnt.access = true
					netstream.Start(client, "nutTerminalUnlock")

					timer.Simple(0.5, function()
						if (terminalEnt and terminalEnt:IsValid()) then
							terminalEnt:EmitSound("hl1/fvox/deeoo.wav", 100, 150)
						end
					end)
				else
					terminalEnt.access = nil

					timer.Simple(0.5, function()
						if (terminalEnt and terminalEnt:IsValid()) then
							terminalEnt:EmitSound("hl1/fvox/buzwarn.wav", 100, 150)
						end
					end)
				end
			end
		end
	end)

	netstream.Hook("nutTerminal", function(client, reqcode, ...)
		local terminalEnt = client:getNetVar("terminal")

		if (terminalEnt and terminalEnt:IsValid()) then
			local data = {...}

			if (reqcode == TERMINAL_READ) then
				local disk = terminalEnt:getDisk()

				if (disk) then
					netstream.Start(client, "nutTerminalData", false, disk:getData("title"), disk:getData("bytes"))
				end
				terminalEnt:EmitSound(Format("ambient/machines/keyboard_fast%s_1second.wav", math.random(1, 3)))
			elseif (reqcode == TERMINAL_WRITEUI) then
				local disk = terminalEnt:getDisk()

				if (disk) then
					netstream.Start(client, "nutTerminalData", true, disk:getData("title"), disk:getData("bytes"))
				end
				terminalEnt:EmitSound(Format("ambient/machines/keyboard_fast%s_1second.wav", math.random(1, 3)))
			elseif (reqcode == TERMINAL_WRITE) then
				local disk = terminalEnt:getDisk()

				disk:setData("title", data[1] or L"tunla")
				disk:setData("bytes", data[2] or "")
			elseif (reqcode == TERMINAL_INSERT) then
				local requestedDisk = nut.item.instances[data[1]]

				terminalEnt:insertDisk(client, requestedDisk)
			elseif (reqcode == TERMINAL_EJECT) then
				terminalEnt:ejectDisk(client)
			elseif (reqcode == TERMINAL_LOCK) then
				local password = data[1]

				terminalEnt.password = password
				terminalEnt:setNetVar("locked", true)
				terminalEnt:EmitSound(Format("ambient/machines/keyboard_fast%s_1second.wav", math.random(1, 3)))
			elseif (reqcode == TERMINAL_UNLOCK) then
				terminalEnt.password = nil
				terminalEnt:setNetVar("locked", nil)
				terminalEnt:EmitSound(Format("ambient/machines/keyboard_fast%s_1second.wav", math.random(1, 3)))
			end
		end
	end)
else
	local viewMate = {}
	function PLUGIN:CalcView(client, origin, angles, fov)
		local terminalEnt = client:getNetVar("terminal")

		if (terminalEnt and terminalEnt:IsValid()) then
			local drawEntity = terminalEnt.models["screen"]

			if (drawEntity and drawEntity:IsValid()) then
				local coPos, coAng = drawEntity:GetRenderOrigin(), drawEntity:GetRenderAngles()

				coPos = coPos + terminalEnt:GetForward() * 2
				coPos = coPos + terminalEnt:GetRight() * 30
				coPos = coPos + terminalEnt:GetUp() * 10

				local ft = FrameTime()
				viewMate.origin = LerpVector(ft * 4, viewMate.origin, coPos)
				viewMate.angles = LerpAngle(ft * 4, viewMate.angles, (coPos - terminalEnt:GetRight() * 1 - coPos):Angle())
				VIEWOVRD = viewMate.origin

				return viewMate
			end
		else
			VIEWOVRD = nil
			viewMate.origin = origin
			viewMate.angles = angles
		end
	end

	function PLUGIN:ShouldDrawCrosshair()
		local client = LocalPlayer()
		local terminalEnt = client:getNetVar("terminal")

		return !(terminalEnt and terminalEnt:IsValid())
	end

	netstream.Hook("nutClick", function(goo)
		gui.EnableScreenClicker(goo)
	end)

	netstream.Hook("nutTerminalUnlock", function(goo)
		local client = LocalPlayer()
		local terminalEnt = client:getNetVar("terminal")

		if (terminalEnt and terminalEnt:IsValid()) then
			terminalEnt.screen.access = true
		end
	end)

	netstream.Hook("nutTerminalData", function(write, title, byte)
		local client = LocalPlayer()
		local terminalEnt = client:getNetVar("terminal")

		if (terminalEnt and terminalEnt:IsValid()) then
			UIINFO = {write, title, byte}
				vgui.Create("nutTerminalData")
			UIINFO = nil
		end
	end)
end
