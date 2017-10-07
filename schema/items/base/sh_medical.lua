ITEM.name = "Medical Stuff"
ITEM.model = "models/healthvial.mdl"
ITEM.width = 1
ITEM.height = 1
ITEM.desc = "A Medical Stuff"
ITEM.healAmount = 50
ITEM.healSeconds = 10
ITEM.category = "Medical"

local function healPlayer(client, target, amount, seconds, item)
	if (client:Alive() and target:Alive()) then
		hook.Run("OnPlayerHeal", client, target, amount, seconds)

		local id = "nutHeal_"..FrameTime()
		timer.Create(id, 1, seconds, function()
			if (!target:IsValid() or !target:Alive()) then
				timer.Destroy(id)	
			end

			target:SetHealth(math.Clamp(target:Health() + (amount/seconds), 0, target:GetMaxHealth()))
		end)
	end
end

// On player uneqipped the item, Removes a weapon from the player and keep the ammo in the item.
ITEM.functions.use = { -- sorry, for name order.
	name = "Use",
	tip = "useTip",
	icon = "icon16/add.png",
	onRun = function(item)
		local client = item.player
		client:setAction("@healing", 2, function()
			if (client and client:IsValid()) then
				if (!client:Alive()) then return end

				client:EmitSound("items/medshot4.wav", 80, 110)
				client:ScreenFade(1, Color(0, 255, 0, 100), .4, 0)
				healPlayer(client, client, item.healAmount, item.healSeconds, item)
				item:remove()
			end
		end)

		return false
	end,
}

ITEM.functions.usef = { -- sorry, for name order.
	name = "Use Forward",
	tip = "useTip",
	icon = "icon16/arrow_up.png",
	onRun = function(item)
		local client = item.player
		local trace = client:GetEyeTraceNoCursor() -- We don't need cursors.
		local target = trace.Entity

		if (target and target:IsValid()) then
			client.healing = true
			client:EmitSound("npc/combine_soldier/gear"..math.random(3, 4)..".wav", 100, 70)

			client:setAction("@healing", 3)
			client:doStaredAction(target, function()
				local dist = client:GetPos():Distance(target:GetPos())

				if (dist < 128) then
					client:notifyShine("healedPlayer", 5, target:Name())

					client:EmitSound("items/medshot4.wav", 80, 110)
					client:ScreenFade(1, Color(0, 255, 0, 100), .4, 0)
					target:ScreenFade(1, Color(0, 255, 0, 100), .4, 0)

					healPlayer(client, client, item.healAmount, item.healSeconds, item)

					item:remove()
				else
					client:notifyLocalized("tooFar")
				end

				client:EmitSound("npc/barnacle/neck_snap1.wav", 100, 140)
			end, 3, function()
				client:setAction()
				target:setAction()

				client.healing = false
			end)

			target:setAction("@healed", 3)

			return false
		end

		return false
	end,
	onCanRun = function(item)
		if (IsValid(item.entity)) then return false end

		local client = item.player
		if (CLIENT) then client = LocalPlayer() end

		return true
	end
}
