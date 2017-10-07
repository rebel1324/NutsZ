PLUGIN.name = "퍼크 시스템"
PLUGIN.author = "Black Tea"
PLUGIN.desc = "스케마 내부에서 개쩌는 사람이 될 수 있도록 노력시켜줍니다."

nut.perk = nut.perk or {}
nut.perk.list = {}

do
	if (SERVER) then
		local MYSQL_CREATE_TABLES = [[
			CREATE TABLE IF NOT EXISTS `nut_perks` (
				`_charID` int(11) NOT NULL,
				`_perks` text NOT NULL,
				`_points` int(8) NOT NULL,
				PRIMARY KEY (`_charID`)
			);
		]]
		local SQLITE_CREATE_TABLES = [[
			CREATE TABLE IF NOT EXISTS `nut_perks` (
				`_charID` INTEGER PRIMARY KEY,
				`_perks` TEXT,
				`_points` INTEGER,
			);
		]]

		function PLUGIN:OnLoadTables()
			if (nut.db.object) then
				nut.db.query(MYSQL_CREATE_TABLES)
			else
				nut.db.query(SQLITE_CREATE_TABLES)
			end
		end

        local function savePerks(char)
			local client = char:getPlayer()

            nut.db.updateTable({
                _perks = client:getPerks(),
                _points = client:getPerkPoint()
            }, nil, "perks", "_charID = "..char:getID())
        end

		function PLUGIN:CharacterPreSave(char)
			savePerks(char)
		end

		function PLUGIN:CharacterLoaded(id)
			-- legacy support
			local char = nut.char.loaded[id]
			local client = char:getPlayer()

			nut.db.query("SELECT _perks FROM nut_perks WHERE _charID = "..id, function(data)
				if (data and #data > 0) then
					for k, v in ipairs(data) do
						local data = util.JSONToTable(v._perks or "[]")
                        local points = tonumber(v._points)
                        
                        client:setPerks(data)
                        client:setPerkPoint(points)
					end
				else
					nut.db.insertTable({
						_perks = {},
						_charID = id,
					}, function(data)
						client:setPerks({})
                        client:setPerkPoint(0)
					end, "perks")
				end
			end)
		end

	    function PLUGIN:PreCharDelete(client, char)
            nut.db.query("DELETE FROM nut_perks WHERE _charID = " .. char:getID())
        end
	end
end

local meta = FindMetaTable("Player")

function meta:addPerk()
	local char = self:getChar()
end

function meta:getPerk()
	local char = self:getChar()
    local perks = {}

    return perks
end

function meta:getPerks()
	local char = self:getChar()
    local perks = {}

    return perks
end

function meta:removePerk()
	local char = self:getChar()
end

function meta:resetPerks()
	local char = self:getChar()
end

function meta:setPerks()
end

function meta:setPerkPoint()
	local char = self:getChar()

end

function meta:getPerkPoint()
	local char = self:getChar()
    local point = 0

    return point
end

function meta:addPerkPoint()
	local char = self:getChar()
end

function meta:takePerkPoint()
	local char = self:getChar()
end

function nut.perk.register()
	local char = self:getChar()
end

function nut.perk.get()
	return nut.park.list[uniqueID]
end