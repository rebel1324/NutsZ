hook.Add("BuildHelpMenu", "nutBasicHelp", function(tabs)
	tabs["commands"] = function(node)
		local body = ""

		for k, v in SortedPairs(nut.command.list) do
			local allowed = false

			if (v.adminOnly and !LocalPlayer():IsAdmin()or v.superAdminOnly and !LocalPlayer():IsSuperAdmin()) then
				continue
			end

			if (v.group) then
				if (type(v.group) == "table") then
					for k, v in pairs(v.group) do
						if (LocalPlayer():IsUserGroup(v)) then
							allowed = true

							break
						end
					end
				elseif (LocalPlayer():IsUserGroup(v.group)) then
					return true
				end
			else
				allowed = true
			end

			if (allowed) then
				body = body.."<h2>/"..k.."</h2><strong>Syntax:</strong> <em>"..v.syntax.."</em><br /><br />"
			end
		end

		return body
	end

	tabs["plugins"] = function(node)
		local body = ""

		for k, v in SortedPairsByMemberValue(nut.plugin.list, "name") do
			body = (body..[[
				<p>
					<span style="font-size: 22;"><b>%s</b><br /></span>
					<span style="font-size: smaller;">
					<b>%s</b>: %s<br />
					<b>%s</b>: %s
			]]):format(v.name or "Unknown", L"desc", v.desc or L"noDesc", L"author", v.author)

			if (v.version) then
				body = body.."<br /><b>"..L"version".."</b>: "..v.version
			end

			body = body.."</span></p>"
		end

		return body
	end
end)

-- This hook adds up some new stuffs in F1 Menu.
function SCHEMA:BuildHelpMenu(tabs)
	tabs["홈페이지"] = "http://183.106.89.97:8002/indexutil.html"
	tabs["업데이트 내역"] = "http://183.106.89.97:8002/update.html"
	tabs["모드"] = function(node)
		local body = ""

		for title, text in SortedPairs(self.helps) do
			body = body.."<h1>"..title.."</h1><b>"..text.."</b><br /><br />"
		end

		return body
	end
end

-- This hook loads the fonts
function SCHEMA:LoadFonts(font)
	font = "Consolas"
	surface.CreateFont("nutATMTitleFont", {
		font = font,
		extended = true,
		size = 72,
		weight = 1000
	})
	
	surface.CreateFont("nutATMFont", {
		font = font,
		extended = true,
		size = 36,
		weight = 1000
	})

	surface.CreateFont("nutATMFontBlur", {
		font = font,
		extended = true,
		size = 36,
		blursize = 6,
		weight = 1000
	})

	local font = "Myriad Pro"
	surface.CreateFont("nutGarbageFontSmall", {
		font = font,
		extended = true,
		size = ScreenScale(15),
		weight = 500
	})

	surface.CreateFont("nutGarbageFontIcon", {
		font = "fontello",
		extended = true,
		size = ScreenScale(40),
		weight = 500
	})

	surface.CreateFont("nutJailBig", {
		font = font,
		size = ScreenScale(8),
		extended = true,
		weight = 500
	})

	surface.CreateFont("nutWantedBig", {
		font = font,
		size = ScreenScale(8),
		extended = true,
		weight = 500
	})
end

-- This hook replaces the bar's look.
BAR_HEIGHT = 15
local gradient = nut.util.getMaterial("vgui/gradient-d")
function nut.bar.draw(x, y, w, h, value, color, barInfo)
	nut.util.drawBlurAt(x, y, w, h)

	surface.SetDrawColor(255, 255, 255, 15)
	surface.DrawRect(x, y, w, h)
	surface.DrawOutlinedRect(x, y, w, h)

	local bw = w
	x, y, w, h = x + 2, y + 2, (w - 4) * math.min(value, 1), h - 4

	surface.SetDrawColor(color.r, color.g, color.b, 250)
	surface.DrawRect(x, y, w, h)

	surface.SetDrawColor(0, 0, 0, 150)
	surface.SetMaterial(gradient)
	surface.DrawTexturedRect(x, y, w, h)

	nut.util.drawText(L(barInfo.identifier or "noname"), x + bw/2, y + h/2, ColorAlpha(color_white, color.a), 1, 1, nil, color.a)
end	

function SCHEMA:EntityRemoved(vehicle)
	if (vehicle.loopSound and vehicle.loopSound:IsPlaying()) then
		vehicle.loopSound:Stop()
	end
end

function SCHEMA:ShouldDrawCrosshair()
	local client = LocalPlayer()
	local weapon = client:GetActiveWeapon()

	if (weapon and weapon:IsValid()) then
		local class = weapon:GetClass()
		
		if (class:find("ma85_") or class:find("cw_")) then
			return false
		end
	end
end

function nut.bar.drawAll()
	nut.bar.drawAction()
end

function SCHEMA:HUDPaint()
	local w, h = ScrW(), ScrH()

	for k, v in ipairs(ents.GetAll()) do
		hook.Run("HUDPaintEntity", v, w, h)
	end
end

-- supress shits
list.Set("DesktopWindows", "PlayerEditor", {})

local function addInfoText(text2)
	local template1 = "<font=ChatFont>%s</font>"
	
	chat.AddText(Format(template1, text2))
end

NUT_CVAR_TIPS = CreateClientConVar("nut_tips", 1, true, true)

timer.Create("nutTips", 200, 0 ,function()
	if (!NUT_CVAR_TIPS:GetBool()) then return end

	addInfoText(table.Random(nut.tips))
end)

function SCHEMA:SetupQuickMenu(menu)
	 local button = menu:addCheck(L"toggleTips", function(panel, state)
	 	if (state) then
	 		RunConsoleCommand("nut_tips", "1")
	 	else
	 		RunConsoleCommand("nut_tips", "0")
	 	end
	 end, NUT_CVAR_TIPS:GetBool())

	 menu:addSpacer()
end

local icon = {
	[1] = "R",
	[2] = "Z",
	[3] = "a",
	[4] = "b",
}
function SCHEMA:HUDPaintEntity(entity, w, h)
	local class = entity:GetClass()

	if (class == "nut_beacon") then
		local owner = entity.CPPIGetOwner and entity:CPPIGetOwner() or entity:GetOwner()
		if (!owner or !owner:IsPlayer()) then return end

		local pos = entity:GetPos() + entity:OBBCenter()
		local scr = (pos):ToScreen()
		local dis = pos:Distance(LocalPlayer():GetPos())
		local what = entity:GetDTInt(0)
		local char = owner:getChar()
		local myChar = LocalPlayer():getChar()

		if (char and myChar) then
			local team = nut.class.list[myChar:getClass()].team
			
			if (team and nut.class.list[char:getClass()].team == team) then
				local matrix = Matrix()
				local scale = math.max(1, 1.5 - RealTime()*3%1.5)
				matrix:Translate(Vector(math.Clamp(scr.x - 20*scale, w*.1, w*.9), math.Clamp(scr.y - 20*scale, h*.1, h*.9)))
				matrix:Rotate(Angle(0, 0, 0))
				matrix:Scale(Vector(scale, scale))

				cam.PushModelMatrix(matrix)
					local tx, ty = nut.util.drawText(icon[what], 0, 0, color_white, 3, 5, "nutIconsBig")
					nut.util.drawText(math.Round(dis/10) .. " m", tx/2, 0 + ty*0.9, color_white, 1, 5, "nutSmallFont")
				cam.PopModelMatrix()
			end
		end
	end
end

function SCHEMA:OnChatReceived(client, chatType, text, anonymous)
	return "<noparse>" .. text .. "</noparse>"
end

function SCHEMA:CanPlayerViewInventory()
	if (IsValid(LocalPlayer():getNetVar("searcher"))) then
		return false
	end
end

function SCHEMA:BuildBusinessMenu()
	return false
end

netstream.Hook("searchPly", function(target, index)
	-- 솔직히 이거 뜯어내서 netstream한다면 내가 인정하고 아무말도 안할게
	-- 배포하지만 마라
	local inventory = nut.item.inventories[index]

	if (!inventory) then
		return netstream.Start("searchExit")
	end

	nut.gui.inv1 = vgui.Create("nutInventory")
	nut.gui.inv1:ShowCloseButton(true)
	nut.gui.inv1:setInventory(LocalPlayer():getChar():getInv())
	nut.gui.inv1:viewOnly(true)

	local panel = vgui.Create("nutInventory")
	panel:ShowCloseButton(true)
	panel:SetTitle(target:Name())
	panel:setInventory(inventory)
	panel:MoveLeftOf(nut.gui.inv1, 4)
	panel.OnClose = function(this)
		if (IsValid(nut.gui.inv1) and !IsValid(nut.gui.menu)) then
			nut.gui.inv1:Remove()
		end

		netstream.Start("searchExit")
	end
	panel:viewOnly(true)

	local oldClose = nut.gui.inv1.OnClose
	nut.gui.inv1.OnClose = function()
		if (IsValid(panel) and !IsValid(nut.gui.menu)) then
			panel:Remove()
		end

		netstream.Start("searchExit")
		nut.gui.inv1.OnClose = oldClose
	end

	nut.gui["inv"..index] = panel	
end)


local gasmaskTexture2 = Material("gasmask_fnl")
local gasmaskTexture = Material("shtr_01")
local w, h, gw, gh, margin, move, healthFactor, ft
local nextBreath = CurTime()
local exhale = false
-- Local function for condition.
local function canEffect(client)
	return (client:getChar() and false and !client:ShouldDrawLocalPlayer() and (!nut.gui.char or !nut.gui.char:IsVisible()))
end
shtrPos = {}

-- Gas Mask Think.
function SCHEMA:UpdateAnimation(client)
	local char = client:getChar()
	if (char and client:Alive() and false) then
		healthFactor = math.Clamp(client:Health()/client:GetMaxHealth(), 0, 1)
		if (!client.nextBreath or client.nextBreath < CurTime()) then
			client:EmitSound(!exhale and "gmsk_in.wav" or "gmsk_out.wav", 
			(LocalPlayer() == client and client:ShouldDrawLocalPlayer() or 100 <= 0) and 20 or 50, math.random(90, 100) + 15*(1 - healthFactor))
			client.nextBreath = CurTime() + 1 + healthFactor*.5 + (exhale == true and .5*healthFactor or 0)
			exhale = !exhale
		end
	end
end

-- Local functions for the Visibility of the crack.
function addCrack()
	table.insert(shtrPos, {math.random(0, ScrW()), math.random(0, ScrH()), math.Rand(.9, 2), math.random(0, 360)})
end
local function initCracks(crackNums)
	for i = 1, math.max(crackNums, 1) do
		addCrack()
	end
end
netstream.Hook("mskInit", function(maskHealth)
	if (maskHealth) then
		local crackNums = math.Round((1 - maskHealth/DEFAULT_GASMASK_HEALTH)*6)
		shtrPos = {}
		if (crackNums > 1) then
			initCracks(crackNums)
		end
	end
end)
netstream.Hook("mskAdd", function()
	LocalPlayer():EmitSound("player/bhit_helmet-1.wav")
	addCrack()
end)
function SCHEMA:HUDPaintDefault()
	return false
end

nut.hud = {}

local owner, w, h, ceil, ft, clmp
ceil = math.ceil
clmp = math.Clamp
local aprg, aprg2 = 0, 0
local ohokay = false
function nut.hud.drawDeath()
	owner = LocalPlayer()
	ft = FrameTime()
	w, h = ScrW(), ScrH()

	if (owner:getChar()) then
		if (owner:Alive()) then
			if (aprg != 0) then
				aprg2 = clmp(aprg2 - ft*1.3, 0, 1)
				if (aprg2 == 0) then
					aprg = clmp(aprg - ft*.7, 0, 1)
				end
			end

			if (ohokay) then
				ohokay = false
			end
		else
			if (aprg2 != 1) then
				aprg = clmp(aprg + ft*.5, 0, 1)
				if (aprg == 1) then
					aprg2 = clmp(aprg2 + ft*.4, 0, 1)
				end
			end

			if (!ohokay) then
				surface.PlaySound("you_died.mp3")
				ohokay = true
			end
		end
	end

	if (IsValid(nut.char.gui) and nut.gui.char:IsVisible() or !owner:getChar()) then
		return
	end

	surface.SetDrawColor(0, 0, 0, ceil((aprg^.5) * 255))
	surface.DrawRect(-1, -1, w+2, h+2)
	local tx, ty = nut.util.drawText(L"youreDead", w/2, h/2, ColorAlpha(color_white, aprg2 * 255), 1, 1, "nutDynFontMedium", aprg2 * 255)
end

function nut.hud.mask()
	if (canEffect(LocalPlayer())) then
		w, h = ScrW(), ScrH()
		gw, gh = h/3*4, h
		
		surface.SetMaterial(gasmaskTexture)
		for k, v in ipairs(shtrPos) do
			surface.SetDrawColor(255, 255, 255)
			surface.DrawTexturedRectRotated(v[1], v[2], 512*v[3], 512*v[3], v[4])
		end
		render.UpdateScreenEffectTexture()
		surface.SetMaterial(gasmaskTexture2)
		surface.SetDrawColor(255, 255, 255)
		surface.DrawTexturedRect(w/2 - gw/2, h/2 - gh/2, gw, gh)
		surface.SetDrawColor(0, 0, 0)
		surface.DrawRect(0, 0, w/2 - gw/2, h)
		surface.DrawRect(0, 0, w, h/2 - gh/2)
		surface.DrawRect(0, h/2 + gh/2, w, h/2 - gh/2)
		surface.DrawRect(w/2 + gw/2, 0, w/2 - gw/2, h)
	end
end

function nut.hud.drawAll(postHook)
	if (postHook) then
		nut.hud.drawDeath()
	else
		nut.hud.mask()
	end	
end