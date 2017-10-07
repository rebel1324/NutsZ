PLUGIN.name = "이펙트"
PLUGIN.author = "Black Tea"
PLUGIN.desc = "여러가지 이펙트를 넣습니다."

NUT_CVAR_EFFECTS = CreateClientConVar("nut_fpeffects", 0, true, true)

local langkey = "english"
do
	local langTable = {
		toggleEffects = "Toggle First Person Effects",
	}

	table.Merge(nut.lang.stored[langkey], langTable)
end

if (CLIENT) then
	local playerMeta = FindMetaTable("Player")
	function playerMeta:CanAddEffects()
		local entity = Entity(self:getLocalVar("ragdoll", 0))
		local ragdoll = self:GetRagdollEntity()

		if ((nut.gui.char and !nut.gui.char:IsVisible()) and
			NUT_CVAR_EFFECTS:GetBool() and
			!self:ShouldDrawLocalPlayer() and
			IsValid(self) and
			self:getChar() and
			!self:getNetVar("actAng") and
			!IsValid(entity) and
			LocalPlayer():Alive()
			) then
			return true
		end
	end

	local vel
	local sin = math.sin
	local cos = math.cos
	local curStep, rest, bobFactor = 0, 0, 0
	local newAng = Angle()
	local view = {}
	local clmp = math.Clamp
	function PLUGIN:CalcView(client, origin, angles, fov)
		if (client:CanAddEffects()) then
			ft = FrameTime()

			if (client:OnGround()) then
				bobFactor = clmp(bobFactor + ft*4, 0, 1)
			else
				bobFactor = clmp(bobFactor - ft*2, 0, 1)
			end

			vel = clmp(owner:GetVelocity():Length2D()/owner:GetWalkSpeed(), 0, 1.5)
			rest = 1 - clmp(owner:GetVelocity():Length2D()/40, 0, 1)
			curStep = curStep + (vel/math.pi)*(ft*2)
			
			newAng.p = angles.p + sin(curStep*15) * vel *.6* bobFactor + sin(RealTime()) * rest * bobFactor
			newAng.y = angles.y + cos(curStep*7.5) * vel *.8* bobFactor + cos(RealTime()*.5) * rest * .5 * bobFactor
			newAng.r = angles.r

	 		view = {}
			view.origin = origin
			view.angles = newAng
			return view
		end
	end

	function PLUGIN:SetupQuickMenu(menu)
		 local button = menu:addCheck(L"toggleEffects", function(panel, state)
		 	if (state) then
		 		RunConsoleCommand("nut_fpeffects", "1")
		 	else
		 		RunConsoleCommand("nut_fpeffects", "0")
		 	end
		 end, NUT_CVAR_EFFECTS:GetBool())

		 menu:addSpacer()
	end
end