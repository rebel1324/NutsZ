ENT.base = "base_brush"
ENT.Type = "brush"

function ENT:Initialize()
	self:SetTrigger(true)
end

function ENT:Touch(client)
    if (!client:IsPlayer()) then return end
    
    -- If player can't join to the safezone, the zone must keep thinking about him
    if (client.keepConsider) then 
        if (client:canEnterSafe()) then
            client:setSafe(true)
            client.keepConsider = nil
        end
    end
end

function ENT:StartTouch(client)
    if (!client:IsPlayer()) then return end
    -- if can't enter to the zone, insert the player in the consider zone.
    if (client:canEnterSafe()) then
        client:setSafe(true)
        netstream.Start(client, "nutAddTimer", "protection", "protectionTime", -1)
        client:setNetVar("protection", nil)
    else    
        client.keepConsider = true
    end
end

function ENT:EndTouch(client)
    if (!client:IsPlayer()) then return end
    
    if (client:isInSafe()) then
        client:setSafe(false)

        client:setNetVar("protection", true)
        netstream.Start(client, "nutAddTimer", "protection", "protectionTime", 8)
        timer.Create(client:getChar():getID() .. "_protection", 8, 1, function()
            client:setNetVar("protection", nil)
        end)
    end
end

-- The brush entity does not need to send it's data to clients. just keep him in the server.
function ENT:UpdateTransmitState()
	return TRANSMIT_NEVER
end