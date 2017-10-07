local meta = FindMetaTable("Player")

-- serious rp turned up
meta.oldRaised = meta.isWepRaised
function meta:isWepRaised()
	if (self:isInSafe()) then
		return false
	else
		return true
	end
end

function meta:isProtected()
	local char = self:getChar()

	if (char) then
		local inv = char:getInv():getItems()

		if (inv) then
			for k, v in pairs(inv) do
				if (v.uniqueID == "vest" and v:getData("equip")) then
					return 0.2, "vest"
				end
			end

		 	local class = char:getClass()
		 	local classData = nut.class.list[class]
		 	
		 	if (classData) then
		 		if (classData.law) then
		 			return 0.1, "class"
		 		end
		 	end
		 end
 	end

 	return 0
end

function meta:setSafe(bool)
	self:setNetVar("safezone", bool)
	hook.Run("OnPlayerSafeUpdated", self, bool)
end

function meta:isInSafe()
	return self:getNetVar("safezone", false)
end

function meta:safePenalty()
	local time, mul = nut.config.get("safePenalty", 100), nut.config.get("safePenaltyMul", 2)
	local char = self:getChar()
	
	if (char) then
		local rep, repMax = char:getRep(), nut.config.get("maxRep", 1500)
		local rate = rep/repMax * -1
		local penTime = (time + time * rate * mul)
		self:setNetVar("penalty", CurTime() + penTime)
		netstream.Start(self, "nutAddTimer", "penalty", "penaltyTime", penTime)
	end
end

function meta:resetPenalty()
	local char = self:getChar()
	
	if (char) then
		self:setNetVar("penalty", nil)
		netstream.Start(self, "nutAddTimer", "penalty", "penaltyTime", -1)
	end
end

function meta:canEnterSafe()
	local bool, reason = hook.Run("CanPlayerEnterSafeZone", self)

	-- this is custom shit that related with other stuffs.
	if (bool == false) then
		return false
	end

	-- this is default shit
	local penalty = self:getNetVar("penalty")

	-- If the penalty cooldown is still a thing for him
	-- don't let him join to the safe zone.	
	if (penalty and penalty > CurTime()) then
		return false
	end

	return true
end

-- 현재 캐릭터의 명성 레벨을 return한다.
function meta:getRepLevel()
	local char = self:getChar()

	if (char) then
		return (char:getRep() / nut.config.get("maxRep", 1500) / SCHEMA.rankLevels)
	end

	return "error"
end

function meta:notifyShine(text, time, ...)
    netstream.Start(self, "nutShineText", text, time, ...)
end

function meta:breakLegs()
	local char = self:getChar()
	local id = char:getID()
	local kay = "legThink" .. id

	timer.Create(kay, 0.5, 0, function()
		if (!IsValid(self) or id != self:getChar():getID() or !char:getData("b_leg")) then
			timer.Remove(kay)
			return
		end

		if (!self:IsProne()) then
			self:ConCommand("prone")
		end
	end)
end