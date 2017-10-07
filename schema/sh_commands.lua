nut.command.add("drop", {
	onRun = function(client, arguments)
		local weapon = client:GetActiveWeapon()

		if (IsValid(weapon)) then
			local class = weapon:GetClass()
			local char = client:getChar()

			if (char) then
				local inv = char:getInv()
				local items = inv:getItems()

				for k, v in pairs(items) do
					if (v.isWeapon and v.class == class) then
						local dropFunc = v.functions.drop

						do
							v.player = client

							if (dropFunc.onCanRun and dropFunc.onCanRun(v) == false) then
								--v.player = nil

								continue
							end
					
							local result
							
							if (v.hooks.drop) then
								result = v.hooks.drop(v)
							end
							
							if (result == nil) then
								result = dropFunc.onRun(v)
							end

							if (v.postHooks.drop) then
								v.postHooks.drop(v)
							end
							
							if (result != false) then
								v:remove()
							end

							v.player = nil
						end
					end
				end
			end
		end
	end,
	alias = {"드랍", "버리기"}
})

nut.command.add("stuck", {
	syntax = "<string name>",
	onRun = function(client, arguments)
		if (client:isWanted() or client:isArrested()) then
			return
		end

		if (client.nextStuck and client.nextStuck > CurTime()) then
			client:ChatPrint(Format("%s초 뒤에 사용가능합니다.", math.Round(client.nextStuck - CurTime())))
			return
		end

		client.nextStuck = CurTime() + 300
		client:Spawn()
	end,
	alias = {"자살", "끼임", "꼈음"}
})

nut.command.add("search", {
	onRun = function(client, arguments)
		local char = client:getChar()
		local class = char:getClass()
		local classData = nut.class.list[class]

		if (classData.law) then
			traceData = {}
			traceData.start = client:GetShootPos()
			traceData.endpos = traceData.start + client:GetAimVector() * 256
			traceData.filter = client
			trace = util.TraceLine(traceData)

			local target = trace.Entity
			
			if (IsValid(target)) then
				hook.Run("OnPlayerSearch", client, target)
				
				nut.log.add(client, "search", target)
			end
		else
			client:notifyLocalized("notLaw")
		end
	end,
	alias = {"수색"}
})

nut.command.add("bankdeposit", {
	syntax = "<amount>",
	onRun = function(client, arguments)
		local atmEntity
		for k, v in ipairs(ents.FindInSphere(client:GetPos(), 128)) do
			if (v:isBank()) then
				atmEntity = v
				break
			end
		end

		if (IsValid(atmEntity) and hook.Run("CanUseBank", client, atmEntity)) then
			local amount = tonumber(table.concat(arguments, ""))
			local char = client:getChar()

			if (amount and amount > 0 and char) then
				amount = math.Round(amount)
				if (char:hasMoney(amount)) then
					char:addReserve(amount)
					char:takeMoney(amount)
					client:notify(L("depositMoney", client, nut.currency.get(amount)))
				else
					client:notify(L("cantAfford", client))
				end
			else
				client:notify(L("provideValidNumber", client))
			end
		else
			client:notify(L("tooFar", client))
		end
	end,
	alias = {"입금"}
})

nut.command.add("bankwithdraw", {
	syntax = "<amount>",
	onRun = function(client, arguments)
		local atmEntity
		for k, v in ipairs(ents.FindInSphere(client:GetPos(), 128)) do
			if (v:isBank()) then
				atmEntity = v
				break
			end
		end

		if (IsValid(atmEntity) and hook.Run("CanUseBank", client, atmEntity)) then
			local amount = tonumber(table.concat(arguments, ""))
			local char = client:getChar()

			if (amount and isnumber(amount) and amount > 0 and char) then
				amount = math.Round(tonumber(amount))

				if (char:hasReserve(amount)) then
					char:takeReserve(amount)
					char:giveMoney(amount)
					client:notify(L("withdrawMoney", client, nut.currency.get(amount)))
				else
					client:notify(L("cantAfford", client))
				end
			else
				client:notify(L("provideValidNumber", client))
			end
		else
			client:notify(L("tooFar", client))
		end
	end,
	alias = {"출금"}
})

nut.command.add("additemspawn", {
	adminOnly = true,
	syntax = "",
	onRun = function(client, arguments)
		local char = client:getChar()
		if (!char) then return end

		if (client:IsSuperAdmin()) then
			table.insert(SCHEMA.itemSpawns, client:GetPos())

			return L("crapAdded", client, name)
		end
	end,
})

nut.command.add("removeitemspawn", {
	adminOnly = true,
	syntax = "",
	onRun = function(client, arguments)
		local char = client:getChar()
		if (!char) then return end

		if (client:IsSuperAdmin()) then
			SCHEMA.itemSpawns = {}

			return L("crapReset", client, name)
		end
	end,
})

nut.command.add("resetitemspawn", {
	adminOnly = true,
	syntax = "",
	onRun = function(client, arguments)
		local char = client:getChar()
		if (!char) then return end

		if (client:IsSuperAdmin()) then
			SCHEMA.itemSpawns = {}

			return L("crapReset", client, name)
		end
	end,
})

nut.command.list["sleep"] = nil
nut.command.list["givefallover"] = nil

local translate = "givemoney"
nut.command.list["돈주기"] = nut.command.list[translate]
nut.command.list["give"] = nut.command.list[translate]

local translate = "dropmoney"
nut.command.list["돈버리기"] = nut.command.list[translate]

local translate = "chardesc"
nut.command.list["타이틀"] = nut.command.list[translate]

local translate = "roll"
nut.command.list["주사위"] = nut.command.list[translate]

local translate = "pm"
nut.command.list["귓"] = nut.command.list[translate]
nut.command.list["귓속말"] = nut.command.list[translate]

local translate = "reply"
nut.command.list["답"] = nut.command.list[translate]
nut.command.list["답장"] = nut.command.list[translate]

local translate = "setvoicemail"
nut.command.list["메일"] = nut.command.list[translate]
nut.command.list["편지"] = nut.command.list[translate]

local translate = "charsetmoney"
nut.command.list["돈설정"] = nut.command.list[translate]

local translate = "fallover"
nut.command.list["기절"] = nut.command.list[translate]
nut.command.list["잠"] = nut.command.list[translate]

nut.command.add("password", {
	syntax = "<패스워드>",
	onRun = function(client, arguments)
			-- Get the Vehicle Spawn position.
		traceData = {}
		traceData.start = client:GetShootPos()
		traceData.endpos = traceData.start + client:GetAimVector() * 256
		traceData.filter = client
		trace = util.TraceLine(traceData)

		local target = trace.Entity

		if (target and target:IsValid()) then
			local password = table.concat(arguments, "")
			
			if (password:len() > 4 or !tonumber(password)) then
				client:notifyLocalized("illegalAccess")

				return 
			end

			if (target:GetClass() == "nut_keypad" and password) then
				if (target:CPPIGetOwner() == client) then
					client:notifyLocalized("passwordChanged", password)

					target:SetPassword(password)
				else
					client:notifyLocalized("notOwned")
				end
			end
		end
	end,
	alias = {"비번", "비밀번호"}
})