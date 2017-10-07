PLUGIN.name = "Party Extension"
PLUGIN.author = "Black Tea"
PLUGIN.desc = "This plugin allows player to create party and be along with thier teammates."

--[[
    MAJOR SERVER-CLIENT SIDE FUNCTIONS
    NOT VISIBLE FOR PLAYERS/USERS
]]
nut.config.add("groupMax", 4, "그룹의 최대 그룹원을 설정합니다.", nil, {
	data = {min = 1, max = 1500},
	category = "dayz",
})

nut.party = nut.party or {
    --[[
        uniqueID = {
            players = {

            },
            leader = [Player(0) Name],
            name = "Example Party Name",
            desc = "Example Party Description",
            color = "",
        }
    ]]
}
nut.party.list = nut.party.list or {}

function nut.party.request(client, data)
    local bool, reason = hook.Run("CanPlayerCreateParty", client, data)

    if (bool == false) then
        if (reason) then
            client:notifyLocalized(reason, client)
        end

        return
    end

    if (data) then
        nut.party.create(client, data.name, data.desc, data.color or color_white)
    else
        client:notifyLocalized("illegalAccess")
    end
end 

function nut.party.create(client, name, desc, color)
    local partyTable = {
        players = {
            client,
        },
        leader = client,
        name = name,
        desc = desc,
        color = color,
    }

    local index = table.insert(nut.party.list, partyTable)
    nut.party.list[index].uniqueID = index
    hook.Run("OnPlayerBecomeLeader", client, index, true)
end

function nut.party.remove(uniqueID)
    if (nut.party.get(uniqueID)) then
        table.remove(nut.party.list, uniqueID)
    end
end

function nut.party.get(uniqueID)
    return nut.party.list[uniqueID]
end

function nut.party.getPlayers(uniqueID)
    local party = nut.party.get(uniqueID)

    if (party) then
        return party.players
    end
    
    return
end

do
    local meta = FindMetaTable("Player")
    if (SERVER) then
        function meta:setParty(targetParty)
            if (targetParty) then
                if (self:getParty()) then
                    self:notifyLocalized("partyFailed")
                else
                    self:setNetVar("party", targetParty)
                    hook.Run("OnPlayerJoinedParty", self, targetParty)
                end
            else
                if (self:getParty()) then
                    hook.Run("OnPlayerLeftParty", self, self:getNetVar("party"))
                    self:setNetVar("party", nil)
                end
            end
        end
    end

    -- Explodes the party. 
    -- because fuck you, that's why
    function meta:explodeParty()
        if (self:isPartyLeader()) then
            local party = self:getParty()  
            local players = party.players

            for k, v in pairs(players) do
                v:setParty()
            end

            nut.party.remove(party.uniqueID)
            hook.Run("OnPartyExplode", client, party.uniqueID)
        end
    end

    function meta:kickParty(target)
        local party = self:getParty()

        if (party:isPartyLeader()) then
            local char = target:getChar()

            if (char) then
                target:setParty()
                hook.Run("OnPlayerKickedParty", target, client)
            else
                self:notifyLocalized("illegalAccess")
            end
        end 
    end

    function meta:getPartyID()
        local uid = self:getNetVar("party")

        return uid
    end

    function meta:getParty()
        local uid = self:getNetVar("party")

        return nut.party.get(uid)
    end

    function meta:isPartyLeader()
        local party = self:getParty()
        
        if (party and party.leader and party.leader == self) then
            return party.uniqueID    
        end

        return false
    end
end

function PLUGIN:PlayerDisconnected(client)

end

function PLUGIN:ResetVariables(client, signal)
    if (signal == SIGNAL_CHAR) then
        local char = client:getChar()

        if (char) then
            if (client:getParty()) then
                client:setParty()
            end
        end
    end
end

-- return true if party is still exists.
function PLUGIN:OnPlayerLeftParty(client)
    local party = client:getParty()

    if (party) then
        local players = party.players
        local count = table.Count(party.players)

        if (count <= 0) then
            nut.party.remove(party.uniqueID)
            print(Format("Party(%s) is hibernated, removing the party."))

            return false
        end

        if (players) then
            local father = false
            if (client:isPartyLeader()) then
                party.leader = nil
                father = true
            end

            for k, v in pairs(players) do
                players[k] = nil

                if (father) then
                    party.leader = v

                    father = false
                    hook.Run("OnPlayerBecomeLeader", v, party.uniqueID)
                end
            end
        end

        return true
    end

    return false
end

function PLUGIN:OnPlayerJoinedParty(client)
    
end

function PLUGIN:PlayerInitialSpawn(client)
    netstream.Start("nutPartyRequestAll")
end

--[[
    VGUI AND CLIENTSIDE PARTS
    INCLUDES SERVER-CLIENT REQUESTS
]]


if (CLIENT) then
    local PANEL = {}

    function PANEL:Init()

    end

    function PANEL:LoadParties()

    end

    function PANEL:SelectParty()

    end

    vgui.Register("nutPartyFrame", PANEL, "EditablePanel")

    netstream.Hook("nutPartyUpdate", function(uniqueID, data)

    end)

    netstream.Hook("nutPartyRequestAll", function(data)
        
    end)
else
    -- for sync 
    netstream.Hook("nutPartyRequestAll", function(client)
        netstream.Start(client, "nutPartyRequestAll", nut.party.list)
    end)
    -- for partial syncs
    netstream.Hook("nutPartyRequest", function()
    
    end)
end

--[[
    ADD CHAT COMMANDS TO MAKE VGUI WORKS
    THIS COMMANDS SHOULD WORK RIGHT TO MAKE AMERICA GREAT AGAIN asshole
]]

nut.command.add("createParty", {
		syntax = "<string name> [string flags]",
		onRun = function(client, arguments)
        
		end,
        alias = {"파티만들기"},
	}
)

nut.command.add("exitParty", {
		syntax = "<string name> [string flags]",
		onRun = function(client, arguments)
		end,
        alias = {"파티나가기"},
	}
)

nut.command.add("joinParty", {
		syntax = "<string name> [string flags]",
		onRun = function(client, arguments)
		end,
        alias = {"파티입장"},
	}
)
