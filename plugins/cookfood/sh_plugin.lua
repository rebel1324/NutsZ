local PLUGIN = PLUGIN
PLUGIN.name = "Cook Food"
PLUGIN.author = "Black Tea"
PLUGIN.desc = "How about getting new foods in NutScript?"
PLUGIN.hungrySeconds = 1100 -- A player can stand up 300 seconds without any foods

COOKLEVEL = {
	[1] = {"조리 안됨", 2, color_white},
	[2] = {"조리 실패", 1, Color(207, 0, 15)},
	[3] = {"조금 요리됨", 3, Color(235, 149, 50)},
	[4] = {"잘 요리됨", 4, Color(103, 128, 159)},
	[5] = {"환상적임", 6, Color(63, 195, 128)},
}
COOKER_MICROWAVE = 1
COOKER_STOVE = 2

nut.util.include("cl_vgui.lua")

local playerMeta = FindMetaTable("Player")
local entityMeta = FindMetaTable("Entity")

function playerMeta:getHunger()
	return (self:getNetVar("hunger")) or 0
end

function playerMeta:getHungerPercent()
	return math.Clamp(((CurTime() - self:getHunger()) / PLUGIN.hungrySeconds), 0 ,1)
end

function playerMeta:addHunger(amount)
	local curHunger = CurTime() - self:getHunger()

	self:setNetVar("hunger", 
		CurTime() - math.Clamp(math.min(curHunger, PLUGIN.hungrySeconds) - amount, 0, PLUGIN.hungrySeconds)
	)
end

function entityMeta:isStove()
	local class = self:GetClass()

	return (class == "nut_stove" or class == "nut_microwave")
end

-- Register HUD Bars.
if (CLIENT) then
	local color = Color(39, 174, 96)

	do
		 nut.bar.add(function()
			return (1 - LocalPlayer():getHungerPercent())
		end, color, nil, "hunger")
	end

	local hungerBar, percent, wave
	function PLUGIN:Think()
		/*hungerBar = hungerBar or nut.bar.get("hunger")
		percent = (1 - LocalPlayer():getHungerPercent())

		if (percent < .33) then -- if hunger is 33%
			wave = math.abs(math.sin(RealTime()*5)*100)

			hungerBar.lifeTime = CurTime() + 1
			hungerBar.color = Color(color.r + wave, color.g - wave, color.b - wave)
		else
			hungerBar.color = color
		end*/
	end

	local timers = {5, 15, 30}

	netstream.Hook("stvOpen", function(entity, index)
		local inventory = nut.item.inventories[index]

		if (IsValid(entity) and inventory and inventory.slots) then
			nut.gui.inv1 = vgui.Create("nutInventory")
			nut.gui.inv1:ShowCloseButton(true)

			local inventory2 = LocalPlayer():getChar():getInv()

			if (inventory2) then
				nut.gui.inv1:setInventory(inventory2)
			end

			local panel = vgui.Create("nutInventory")
			panel:ShowCloseButton(true)
			panel:SetTitle("Cookable Object")
			panel:setInventory(inventory)
			panel:MoveLeftOf(nut.gui.inv1, 4)
			panel.OnClose = function(this)
				if (IsValid(nut.gui.inv1) and !IsValid(nut.gui.menu)) then
					nut.gui.inv1:Remove()
				end

				netstream.Start("invExit")
			end
			
			function nut.gui.inv1:OnClose()
				if (IsValid(panel) and !IsValid(nut.gui.menu)) then
					panel:Remove()
				end

				netstream.Start("invExit")
			end

			local actPanel = vgui.Create("DPanel")
			actPanel:SetDrawOnTop(true)
			actPanel:SetSize(100, panel:GetTall())
			actPanel.Think = function(this)
				if (!panel or !panel:IsValid() or !panel:IsVisible()) then
					this:Remove()

					return
				end

				local x, y = panel:GetPos()
				this:SetPos(x - this:GetWide() - 5, y)
			end

			for k, v in ipairs(timers) do
				local btn = actPanel:Add("DButton")
				btn:Dock(TOP)
				btn:SetText(v .. " Seconds")
				btn:DockMargin(5, 5, 5, 0)

				function btn.DoClick()
					netstream.Start("stvActive", entity, v)
				end
			end

			nut.gui["inv"..index] = panel
		end
	end)
else
	local PLUGIN = PLUGIN

	function PLUGIN:LoadData()
		if (true) then return end
		
		local savedTable = self:getData() or {}

		for k, v in ipairs(savedTable) do
			local stove = ents.Create(v.class)
			stove:SetPos(v.pos)
			stove:SetAngles(v.ang)
			stove:Spawn()
			stove:Activate()
		end
	end
	
	function PLUGIN:SaveData()
		if (true) then return end

		local savedTable = {}

		for k, v in ipairs(ents.GetAll()) do
			if (v:isStove()) then
				table.insert(savedTable, {class = v:GetClass(), pos = v:GetPos(), ang = v:GetAngles()})
			end
		end

		self:setData(savedTable)
	end
	
	function PLUGIN:CharacterPreSave(character)
		local savedHunger = math.Clamp(CurTime() - character.player:getHunger(), 0, PLUGIN.hungrySeconds)
		character:setData("hunger", savedHunger)
	end

	function PLUGIN:PlayerLoadedChar(client, character, lastChar)
		if (character:getData("hunger")) then
			client:setNetVar("hunger", CurTime() - character:getData("hunger"))
		else
			client:setNetVar("hunger", CurTime())
		end
	end

	function PLUGIN:PlayerDeath(client)
		client.refillHunger = true
	end

	function PLUGIN:PlayerSpawn(client)
		if (client.refillHunger) then
			client:setNetVar("hunger", CurTime())
			client.refillHunger = false
		end
	end

	local thinkTime = CurTime()
	function PLUGIN:Think()
		if (thinkTime < CurTime()) then
			for k, v in ipairs(player.GetAll()) do
				local percent = (1 - v:getHungerPercent())

				if (percent <= 0) then
					if (v:Alive() and v:Health() <= 0) then
						v:Kill()
					else
						v:SetHealth(math.Clamp(v:Health() - 1, 0, v:GetMaxHealth()))
					end
				end
			end

			thinkTime = CurTime() + .5
		end
	end
end

FOOD_INSTANT = 1
FOOD_OPENER = 2
FOOD_NEEDCOOK = 3

local foodTable = {}

local ITEM = {}
ITEM.uniqueID = "food_chip"
ITEM.name = "감자칩"
ITEM.desc = "간단하게 배고픔을 해결해주는 감자칩"
ITEM.size = {x = 1, y = 1}
ITEM.type = FOOD_INSTANT
ITEM.feed = {}
ITEM.amount = 1
ITEM.model = "models/warz/consumables/bag_chips.mdl"
foodTable[ITEM.uniqueID] = ITEM

ITEM = {}
ITEM.uniqueID = "food_mre"
ITEM.name = "MRE"
ITEM.desc = "군용 전투식량. 요리를 하면 완전히 채워준다"
ITEM.size = {x = 1, y = 2}
ITEM.type = FOOD_INSTANT
ITEM.cookable = true
ITEM.feed = {}
ITEM.amount = 1
ITEM.model = "models/warz/consumables/bag_mre.mdl"
foodTable[ITEM.uniqueID] = ITEM

ITEM = {}
ITEM.uniqueID = "food_oat"
ITEM.name = "오트밀"
ITEM.desc = "맛이 의심스러운 오트밀"
ITEM.size = {x = 1, y = 1}
ITEM.type = FOOD_INSTANT
ITEM.feed = {}
ITEM.amount = 1
ITEM.model = "models/warz/consumables/bag_oat.mdl"
foodTable[ITEM.uniqueID] = ITEM

ITEM = {}
ITEM.uniqueID = "food_chobar"
ITEM.name = "초콜릿 바"
ITEM.desc = "들고다니기 매우 편리한 초콜릿 바"
ITEM.size = {x = 1, y = 1}
ITEM.type = FOOD_INSTANT
ITEM.feed = {}
ITEM.amount = 1
ITEM.model = "models/warz/consumables/bar_chocolate.mdl"
foodTable[ITEM.uniqueID] = ITEM

ITEM = {}
ITEM.uniqueID = "food_grabar"
ITEM.name = "그래놀라 바"
ITEM.desc = "들고다니기 매우 편리한 초콜릿 바"
ITEM.size = {x = 1, y = 1}
ITEM.type = FOOD_INSTANT
ITEM.feed = {}
ITEM.amount = 1
ITEM.model = "models/warz/consumables/bar_granola.mdl"
foodTable[ITEM.uniqueID] = ITEM

ITEM = {}
ITEM.uniqueID = "food_pascan"
ITEM.name = "파스타 소스 통조림"
ITEM.desc = "파스타 소스가 들어있는 통조림. 통조림 따개가 필요하다."
ITEM.size = {x = 1, y = 1}
ITEM.type = FOOD_OPENER
ITEM.feed = {}
ITEM.amount = 1
ITEM.cookable = true
ITEM.model = "models/warz/consumables/can_pasta.mdl"
foodTable[ITEM.uniqueID] = ITEM

ITEM = {}
ITEM.uniqueID = "food_soupcan"
ITEM.name = "스프 통조림"
ITEM.desc = "스프가 들어있는 통조림. 통조림 따개가 필요하다."
ITEM.size = {x = 1, y = 1}
ITEM.type = FOOD_OPENER
ITEM.feed = {}
ITEM.amount = 1
ITEM.cookable = true
ITEM.model = "models/warz/consumables/can_soup.mdl"
foodTable[ITEM.uniqueID] = ITEM

ITEM = {}
ITEM.uniqueID = "food_hamcan"
ITEM.name = "햄 통조림"
ITEM.desc = "햄이 들어있는 통조림. 통조림 따개가 필요하다."
ITEM.size = {x = 1, y = 1}
ITEM.type = FOOD_OPENER
ITEM.feed = {}
ITEM.amount = 1
ITEM.cookable = true
ITEM.model = "models/warz/consumables/can_spam.mdl"
foodTable[ITEM.uniqueID] = ITEM

ITEM = {}
ITEM.uniqueID = "food_tunacan"
ITEM.name = "참치 캔"
ITEM.desc = "참치가 들어있는 통조림. 통조림 따개가 필요하다."
ITEM.size = {x = 1, y = 1}
ITEM.type = FOOD_OPENER
ITEM.feed = {}
ITEM.amount = 1
ITEM.cookable = true
ITEM.model = "models/warz/consumables/can_tuna.mdl"
foodTable[ITEM.uniqueID] = ITEM

ITEM = {}
ITEM.uniqueID = "food_coco"
ITEM.name = "코코넛 음료"
ITEM.desc = "코코넛 음료가 들어있는 용기."
ITEM.size = {x = 1, y = 1}
ITEM.type = FOOD_INSTANT
ITEM.feed = {}
ITEM.amount = 1
ITEM.model = "models/warz/consumables/coconut_water.mdl"
foodTable[ITEM.uniqueID] = ITEM

ITEM = {}
ITEM.uniqueID = "food_endrink"
ITEM.name = "에너지 드링크"
ITEM.desc = "에너지 드링크가 들어있는 캔"
ITEM.size = {x = 1, y = 1}
ITEM.type = FOOD_INSTANT
ITEM.feed = {}
ITEM.amount = 1
ITEM.model = "models/warz/consumables/energy_drink.mdl"
foodTable[ITEM.uniqueID] = ITEM

ITEM = {}
ITEM.uniqueID = "food_ion"
ITEM.name = "이온 음료"
ITEM.desc = "게토레이가 들어있는 병. 행동력을 많이 채워준다."
ITEM.size = {x = 1, y = 1}
ITEM.type = FOOD_INSTANT
ITEM.feed = {}
ITEM.amount = 1
ITEM.model = "models/warz/consumables/gatorade.mdl"
foodTable[ITEM.uniqueID] = ITEM

ITEM = {}
ITEM.uniqueID = "food_cherry"
ITEM.name = "체리 주스"
ITEM.desc = "체리 주스가 들어있는 용기. 맛이 조금 이상하다."
ITEM.size = {x = 1, y = 1}
ITEM.type = FOOD_INSTANT
ITEM.feed = {}
ITEM.amount = 1
ITEM.model = "models/warz/consumables/juice.mdl"
foodTable[ITEM.uniqueID] = ITEM

ITEM = {}
ITEM.uniqueID = "food_bread"
ITEM.name = "빵"
ITEM.desc = "편의점에서 파는 그것과 같은 빵."
ITEM.size = {x = 1, y = 1}
ITEM.type = FOOD_INSTANT
ITEM.feed = {}
ITEM.amount = 1
ITEM.cookable = true
ITEM.model = "models/warz/consumables/minisaints.mdl"
foodTable[ITEM.uniqueID] = ITEM

ITEM = {}
ITEM.uniqueID = "food_soda"
ITEM.name = "탄산음료"
ITEM.desc = "탄산이 들어있는 음료가 들어잇는 캔."
ITEM.size = {x = 1, y = 1}
ITEM.type = FOOD_INSTANT
ITEM.feed = {}
ITEM.amount = 1
ITEM.model = "models/warz/consumables/soda.mdl"
foodTable[ITEM.uniqueID] = ITEM

ITEM = {}
ITEM.uniqueID = "food_lwater"
ITEM.name = "대형 물병"
ITEM.desc = "많은 물이 들어있는 물병. 여러번 마셔도 될것 같다."
ITEM.size = {x = 1, y = 2}
ITEM.type = FOOD_INSTANT
ITEM.feed = {}
ITEM.amount = 4
ITEM.model = "models/warz/consumables/water_l.mdl"
foodTable[ITEM.uniqueID] = ITEM

ITEM = {}
ITEM.uniqueID = "food_swater"
ITEM.name = "소형 물병"
ITEM.desc = "소량의 물이 들어있는 물병"
ITEM.size = {x = 1, y = 1}
ITEM.type = FOOD_INSTANT
ITEM.feed = {}
ITEM.amount = 1
ITEM.model = "models/warz/consumables/water_s.mdl"
foodTable[ITEM.uniqueID] = ITEM
ITEM = nil

function PLUGIN:PluginLoaded()
	for uid, data in pairs(foodTable) do
		local ITEM = nut.item.register(uid, "base_cookfood", nil, nil, true)
		ITEM.name = data.name
		ITEM.desc = data.desc
		ITEM.model = data.model
		ITEM.price = 100

		if (data.type == FOOD_NEEDCOOK) then
			ITEM.mustCooked = true
		elseif (data.type == FOOD_OPENER) then
			ITEM.require = "can_opener"
		end

		if (data.size) then
			ITEM.width = 1
			ITEM.height = 1
		end

		ITEM.quantity = data.amount or 1
		
		if (data.feed) then
			local fdi = data.feed

			if (fdi.hunger) then
				ITEM.hungerAmount = fdi.hunger
			end

			if (fdi.stamina) then
				ITEM.staminaAmount = fdi.stamina
			end
		end

		if (data.hooks) then
			-- add some hooks, bitches.
		end

		if (data.cookable) then
			ITEM.cookable = true -- don't ask why
		else
			ITEM.cookable = false
		end
	end
end