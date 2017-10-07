PLUGIN.name = "능력치 시스템"
PLUGIN.author = "Black Tea"
PLUGIN.desc = "스킬트리를 찍을 수 있습니다."

function PLUGIN:RegisterPerks()
end

local PLAYER = getmetatable("Player")

function PLAYER:getPoints(amount)
end

function PLAYER:setPoints(amount)
end

function PLAYER:addPoints(amount)
end

function PLAYER:takePoints(amount)
end

function PLAYER:setPerk(uniqueID, amount)
end

function PLAYER:addPerk(uniqueID, amount)
end

function PLAYER:removePerk(uniqueID, amount)
end