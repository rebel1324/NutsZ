
surface.CreateFont("scoreboard.title", {font = "Malgun Gothic", size = 32, weight = 800, extended = true})
surface.CreateFont("scoreboard.info", {font = "Malgun Gothic", size = 16, weight = 200, extended = true})
surface.CreateFont("scoreboard.player.big", {font = "Malgun Gothic", size = 20, weight = 800, extended = true})
surface.CreateFont("scoreboard.player", {font = "Malgun Gothic", size = 16, weight = 800, extended = true})



-- Change colors here 
local config = {}

-- Enable background blur ?
config.bEnableBlur = true 

-- Background color
config.cBackground = Color(10, 6, 4, 100)

-- Border around the entire scoreboard color
config.cBackgroundOutline = Color(0, 0, 0, 255)

-- Server title color
config.cServerName = color_white

-- 'Rounded' box color
config.cHeader = Color(211, 211, 211, 5)


-- Line under server title
config.cLine = Color(10, 6, 4, 255)

-- Player outline color
config.cPlayerOutline = Color(0, 0, 0, 100)

-- Icons for usergroups
config.mIconGroups = {}
config.mIconGroups["superadmin"] = Material("icon16/star.png")
config.mIconGroups["admin"] = Material("icon16/shield.png")
config.mIconGroups["guest"] = Material("icon16/user.png")
-- I made the scoreboard and released it for free
-- So don't you tell me I don't deserve a little icon :/
-- fuck off
config.mIconGroups["STEAM_0:0:19814083"] = Material("icon16/wrench.png")

-- Return the config table 
function GetScoreboardConfig()
    -- Return this 
    return config
end 
-- DarkRP scoreboard 
-- Coded by AC²

-- Remove these hooks first because FAdmin scoreboard 
hook.Remove("ScoreboardHide", "FAdmin_scoreboard")
hook.Remove("ScoreboardShow", "FAdmin_scoreboard")

-- Remove default scoreboard?
hook.Add("Initialize", "RemoveGamemodeFunctions", function()
    GAMEMODE.ScoreboardShow = nil 
    GAMEMODE.ScoreboardHide = nil
end)

-- Used later
local scoreboard

-- Create the scoreboard
local function CreateScoreboard()
    -- Settings
    local config = GetScoreboardConfig()

    -- Create a DFrame
    scoreboard = vgui.Create("DFrame")
    scoreboard:SetSize(ScrW() - (ScrW() / 2 - 200), ScrH() - 100)
    scoreboard:Center()
    scoreboard:SetTitle("")
    scoreboard:ShowCloseButton(false)
    scoreboard:SetDraggable(false)
    scoreboard:MakePopup()

    -- Since this is static
    local x, y = scoreboard:GetPos()

    -- Paint it
    scoreboard.Paint = function(self, w, h)
        -- Cut off the blur
        render.SetScissorRect(x, y, w + x, h + y, true)

        -- Draw blur
        if (config.bEnableBlur) then
            Derma_DrawBackgroundBlur(self, 0)
        end

        -- Black box
        surface.SetDrawColor(config.cBackground)
        surface.DrawRect(0, 0, w, h)

        -- Outline
        surface.SetDrawColor(config.cBackgroundOutline)
        surface.DrawOutlinedRect(0, 0, w, h)

        -- Header box
        surface.SetDrawColor(config.cHeader)
        surface.DrawRect(10, 10, w - 20, 90)

        -- Header outline
        surface.SetDrawColor(config.cLine)
        surface.DrawOutlinedRect(10, 10, w - 20, 90)

        -- Server name 
        draw.SimpleText(GetHostName(), "scoreboard.title", w / 2, 55, config.cServerName, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

        -- Line under name
        surface.SetDrawColor(config.cLine)
        surface.DrawLine(10, 125, w - 10, 125)

        -- Secondary line
        surface.SetDrawColor(Color(62, 62, 62, 255))
        surface.DrawLine(10, 126, w - 10, 126)

        -- Player names label
        draw.SimpleText("이름", "scoreboard.info", 13, 115, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

        -- Player job label
        draw.SimpleText("직업", "scoreboard.info", w / 2, 115, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

        -- Player rank label
        draw.SimpleText("등급", "scoreboard.info", w - 75, 115, color_white, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)

        -- Player ping label
        draw.SimpleText("핑", "scoreboard.info", w - 23, 115, color_white, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)

        -- Stop
        render.SetScissorRect(0, 0, 0, 0, false)
    end

    -- Scrollpanel
    local scrollpanel = scoreboard:Add("DScrollPanel")
    scrollpanel:SetPos(10, 130)
    scrollpanel:SetSize(scoreboard:GetWide() - 20 + 16, scoreboard:GetTall() - 140)

    -- Hide the scrollbar
    scrollpanel.VBar.Paint = function() end
    scrollpanel.VBar.btnUp.Paint = scrollpanel.VBar.Paint
    scrollpanel.VBar.btnDown.Paint = scrollpanel.VBar.Paint
    scrollpanel.VBar.btnGrip.Paint = scrollpanel.VBar.Paint

    -- Scoreboard update function
    scoreboard.Update = function()
        -- Clear the layout
        scrollpanel:Clear()

        -- Add all players
		local index = 0
        for k, v in pairs(player.GetAll()) do
        	if (!v:getChar()) then continue end
			index = index + 1
            -- Create a DPanel
            local panel = scrollpanel:Add("DPanel")
            panel:SetSize(scrollpanel:GetWide() - 16, 36)
            panel:SetPos(0, index * 37 - 37)

            local avatar = panel:Add("AvatarImage")
            avatar:SetSize(32, 32)
            avatar:SetPos(2, 2)
            avatar:SetPlayer(v)

            -- Paint over it
            avatar.PaintOver = function(self, w, h)
                -- Outline
                surface.SetDrawColor(config.cPlayerOutline)
                surface.DrawOutlinedRect(0, 0, w, h)
            end
        
			 -- Get name, job
			local char = v:getChar()
			local rep, repDiv = char:getRep(), nut.config.get("maxRep", 1500)/SCHEMA.rankLevels
			local name = v:Name()

			
            -- Get the color
			local clr = Color (90,255,90,255)
            local class = v:getChar():getClass()
            local classData = nut.class.list[class] or nut.class.list[1]
			if (char:getRep() == 0) then
					clr = Color (90,255,90,255)
			elseif (char:getRep() > 0) then
					clr = Color (90,90,90+90*char:getRep(),255)
			elseif  (char:getRep() < 0) then
					clr = Color (90+90*char:getRep(),90,90,255)
			end
			
			
		--	classData.color or team.GetColor(v:Team())
		
		
           -- local job = classData.name
			local job = SCHEMA.ranks[math.floor(char:getRep()/repDiv)]
			
            -- Reduces opacity
			clr.a = 100
            local icon = config.mIconGroups[v:GetUserGroup()] or config.mIconGroups.guest

            -- Steamid checks
            if (config.mIconGroups[v:SteamID()]) then
                icon = config.mIconGroups[v:SteamID()]
            end

            -- Paint the DPanel
            panel.Paint = function(self, w, h)
                -- Invalid users up in my scoreboard?
                if not v:IsValid() then
                    -- Remove em and update
                    scoreboard:Update()
                    -- Stop
                    return
                end

                -- Background color
                surface.SetDrawColor(clr)
                surface.DrawRect(0, 0, w, h)

                -- Outline 
                surface.SetDrawColor(config.cPlayerOutline)
                surface.DrawOutlinedRect(0, 0, w, h)

                -- Player name
                draw.SimpleText(name, "scoreboard.player.big", 40, h / 2, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

                -- Player job
                draw.SimpleText(job, "scoreboard.player", w / 2 + 5, h / 2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

                -- Player ping
                surface.SetDrawColor(color_white)
                surface.SetMaterial(icon)
                surface.DrawTexturedRect(w - 75 - 12, h / 2 - 8, 16, 16)

                -- Player ping
                draw.SimpleText(v:Ping(), "scoreboard.player", w - 20, h / 2, color_white, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
            end 
        end
    end

    -- Update when created aswell
    scoreboard:Update()
end 

timer.Simple(1, function()
	function GAMEMODE:ScoreboardShow()
		-- Check if we already created it
		if not (scoreboard == nil) then
			 -- Update
			scoreboard:Update()
			 -- We did, just show it
			scoreboard:SetVisible(true)
		else 
			-- We didn't, create it
			CreateScoreboard()
		end 
	end

	function GAMEMODE:ScoreboardHide()
		-- Should it be invalid for some reason
		if (scoreboard) then
			-- Hide it
			scoreboard:SetVisible(false)
		end
	end
end)