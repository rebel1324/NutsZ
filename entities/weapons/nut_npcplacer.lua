AddCSLuaFile()

if( CLIENT ) then
	SWEP.PrintName = "NPC SPAWN REGISTER";
	SWEP.Slot = 0;
	SWEP.SlotPos = 0;
	SWEP.CLMode = 0
end
SWEP.HoldType = "fists"

SWEP.Category = "Nutscript"
SWEP.Spawnable			= true
SWEP.AdminSpawnable		= true

SWEP.ViewModel = "models/weapons/v_pistol.mdl"
SWEP.WorldModel = "models/weapons/w_pistol.mdl"

SWEP.Primary.Delay			= 0.1
SWEP.Primary.Recoil			= 0	
SWEP.Primary.Damage			= 0
SWEP.Primary.NumShots		= 0
SWEP.Primary.Cone			= 0 	
SWEP.Primary.ClipSize		= -1	
SWEP.Primary.DefaultClip	= -1	
SWEP.Primary.Automatic   	= false	
SWEP.Primary.Ammo         	= "none"
 
SWEP.Secondary.Delay		= 0.1
SWEP.Secondary.Recoil		= 0
SWEP.Secondary.Damage		= 0
SWEP.Secondary.NumShots		= 1
SWEP.Secondary.Cone			= 0
SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic   	= false
SWEP.Secondary.Ammo         = "none"

function SWEP:Initialize()
	self:SetWeaponHoldType("knife")
end

function SWEP:Think()
end

local gridsize = 1
function SWEP:PrimaryAttack()
	if IsFirstTimePredicted() then
        self:EmitSound("weapons/357_fire2.wav")
        
        local trace = self.Owner:GetEyeTraceNoCursor()
        local pos = trace.HitPos
        SCHEMA.npcSpawns = SCHEMA.npcSpawns or {}
        
        local type = self.npcType
        if (!type) then
            for k, v in pairs(SCHEMA.npcLists) do
                type = k
                break
            end
        end

        SCHEMA.npcSpawns[type] = SCHEMA.npcSpawns[type] or {}
        table.insert(SCHEMA.npcSpawns[type], pos)
    end

    self:SetNextPrimaryFire(CurTime() + .05)
    self:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
end

function SWEP:SecondaryAttack()
	if IsFirstTimePredicted() then
        self:EmitSound("weapons/ar1/ar1_dist1.wav")
        

        local dicks = SCHEMA.npcSpawns or {}

        local trace = self.Owner:GetEyeTraceNoCursor()
        local pos2 = trace.HitPos

        SCHEMA.npcSpawns = SCHEMA.npcSpawns or {}
        
        local type = self.npcType
        if (!type) then
            for k, v in pairs(SCHEMA.npcLists) do
                type = k
                break
            end
        end
        
        for type, b in pairs(SCHEMA.npcLists) do
            if (!SCHEMA.npcSpawns[type]) then continue end

            for k, v in pairs(SCHEMA.npcSpawns[type]) do
                local dist = pos2:Distance(v)

                if (dist < 128) then
                    SCHEMA.npcSpawns[type][k] = nil
                end    
            end
        end
    end
    self:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
end

if SERVER then
	function SWEP:Reload()
	end

	function SWEP:Deploy()
         self:SetNextPrimaryFire(CurTime() + 1.5)
        netstream.Start(self.Owner, "nutNPCSpawnSync", SCHEMA.npcSpawns or {})
	end

    netstream.Hook("nutNPCSpawnSync", function(client)
        if (client:IsSuperAdmin()) then
            netstream.Start("nutNPCSpawnSync", SCHEMA.npcSpawns or {})
        else
            client:notifyLocalized("illegalAccess")
        end
    end)   

    netstream.Hook("nutNPCSpawnChange", function(client, change)
        if (!client:IsSuperAdmin()) then return end

        local weapon = client:GetActiveWeapon()
        if (IsValid(weapon)) then
            weapon.npcType = change
        end
    end)
else
    local loadingYouFuck = false
    function SWEP:Deploy()
        if IsFirstTimePredicted() then
            nut.util.notify("현재 서버의 아이템 소환 지점을 불러오고 있습니다.")
            loadingYouFuck = true
        end
    end

    function SWEP:Holster()
        if IsFirstTimePredicted() then
            loadingYouFuck = false
        end
    end

    netstream.Hook("nutNPCSpawnSync", function(data)
        SCHEMA.npcSpawns = data
        nut.util.notify("서버의 아이템 소환 지점을 불러오는데 성공하였습니다.")
        loadingYouFuck = false
    end)   

	local PANEL = {}
	function PANEL:Init()
		self:SetTitle("Set Item Groups")
		self:SetSize(300, 390)
		self:Center()
		self:MakePopup()

		self.menu = self:Add("PanelList")
		self.menu:Dock(FILL)
		self.menu:DockMargin(5, 5, 5, 5)
		self.menu:SetSpacing(2)
		self.menu:SetPadding(2)
		self.menu:EnableVerticalScrollbar()

        self:loadGroups()
	end

    function PANEL:loadGroups()
		for k, v in pairs(SCHEMA.npcLists) do
			local button = self.menu:Add("DButton")
			button:SetText(k)
			self.menu:AddItem(button)

			function button:DoClick()
                local weapon = LocalPlayer():GetActiveWeapon()
                weapon.npcType = k
                netstream.Start("nutNPCSpawnChange", k)
            end
		end
    end
	vgui.Register("nutSpawnerFrame", PANEL, "DFrame")

	function SWEP:Reload()
		if (!self.menuOpen) then
			self.menuOpen = true

			local a = vgui.Create("nutSpawnerFrame")
			timer.Simple(.3, function()
				self.menuOpen = false
			end)
		end
	end

	function SWEP:DrawHUD()
        if (loadingYouFuck) then return false end

		local w, h = ScrW(), ScrH()
		local cury = h/4*3
		local tx, ty = draw.SimpleText("발사 키: 아이템 소환 지점 추가", "nutMediumFont", w/2, cury, color_white, 1, 1)
		cury = cury + ty
		local tx, ty = draw.SimpleText("보조 발사 키: 아이템 소환 지점 제거", "nutMediumFont", w/2, cury, color_white, 1, 1)
		cury = cury + ty
		local tx, ty = draw.SimpleText("빨간색으로 표시된 부분만 제거됨", "nutMediumFont", w/2, cury, color_white, 1, 1)
		cury = cury + ty
		local tx, ty = draw.SimpleText("장전: 메뉴에서 소환 그룹 선택", "nutMediumFont", w/2, cury, color_white, 1, 1)
	
        local dicks = SCHEMA.npcSpawns or {}

        local trace = self.Owner:GetEyeTraceNoCursor()
        local pos2 = trace.HitPos

        for groups, dats in pairs(dicks) do
            for npcType, v in pairs(dats) do
                local a = v:ToScreen()
                local dist = pos2:Distance(v)
                local col = (dist > 128) and color_white or Color(255, 0, 0)
                col = ColorAlpha(col, dist > 512 and 11 or 255)

                surface.SetDrawColor(col)
                surface.DrawRect( a.x, a.y, 2, 2)
                local tx, ty = draw.SimpleText(groups, "nutSmallFont", a.x, a.y - 10, col, 1, 1)
                local tx, ty = draw.SimpleText("소환 지점", "nutSmallFont", a.x, a.y - 10 - ty*0.6, col, 1, 1)
            end
        end
    end
end