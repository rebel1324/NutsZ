local meta = nut.meta.character

-- 창고에 관련된 메타함수
function meta:getReserve()
	return self:getVar("reserve", 0)
end

function meta:setReserve(amount)
	self:setVar("reserve", amount)
	hook.Run("OnReserveChanged", self, amount, true)
end

function meta:addReserve(amount)
	nut.log.add(self:getPlayer(), "reserve", amount)
	self:setVar("reserve", self:getReserve() + amount)
	hook.Run("OnReserveChanged", self, amount)
end

function meta:takeReserve(amount)
	nut.log.add(self:getPlayer(), "reserve", -amount)
	self:setVar("reserve", self:getReserve() - amount)
	hook.Run("OnReserveChanged", self, amount)
end

function meta:hasReserve(amount)
	return (amount > 0 and self:getReserve() >= amount)
end

-- 명성에 관련된 메타함수
function meta:getRep(def)
	return self:getData("rep", def or 0)
end

function meta:setRep(amount)
	self:setData("rep")
	hook.Run("OnRepChanged", self, amount, true)
end

function meta:addRep(amount)
	local max = nut.config.get("maxRep", 1500)
	self:setData("rep", math.max(max, self:getRep(0) + amount))
	hook.Run("OnRepChanged", self, amount)
end

function meta:takeRep(amount)
	local max = nut.config.get("maxRep", 1500)
	self:setData("rep", math.max(-max, self:getRep(0) - amount))
	hook.Run("OnRepChanged", self, amount)
end