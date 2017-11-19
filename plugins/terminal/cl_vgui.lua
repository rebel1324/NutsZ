	local PANEL = {}

	function PANEL:Init()
		if (nut.terminal.diskui2 and nut.terminal.diskui2:IsVisible()) then
			nut.terminal.diskui2:Remove()
			nut.terminal.diskui2 = nil
		end

		self:SetSize(600, 400)	
		self:MakePopup()
		self:Center()
		self:SetTitle("Terminal Data")


		self.controls = self:Add("DPanel")
		self.controls:Dock(BOTTOM)
		self.controls:SetTall(30)
		self.controls:DockMargin(0, 5, 0, 0)

		self.title = self:Add("DTextEntry")
		self.title:Dock(TOP)
		self.title:SetMultiline(true)
		self.title:SetEditable(false)
		self.title:DockMargin(0, 0, 0, 3)

		self.contents = self:Add("DTextEntry")
		self.contents:Dock(FILL)
		self.contents:SetMultiline(true)
		self.contents:SetEditable(false)

		self.confirm = self.controls:Add("DButton")
		self.confirm:Dock(RIGHT)
		self.confirm:SetDisabled(true)
		self.confirm:SetText(L("tfinish"))

		self.controls.Paint = function(this, w, h)
			local text = self.contents:GetValue()
			draw.SimpleText(Format(L("tbyte", string.len(text)), "DermaDefault", 10, h/2, color_white, TEXT_ALIGN_LEFT, 1))
		end

		self.confirm.DoClick = function(this)
			local text = self.title:GetValue()
			local text2 = self.contents:GetValue()
			netstream.Start("nutTerminal", TERMINAL_WRITE, text, text2)
			self:Close()
		end

		if (UIINFO[1] == true) then
			self.title:SetEditable(true)
			self.contents:SetEditable(true)
			self.confirm:SetDisabled(false)
		else
			self.title:SetEditable(false)
			self.contents:SetEditable(false)
			self.confirm:SetDisabled(true)
		end

		self.title:SetValue(UIINFO[2] or L"tunla")
		self.contents:SetValue(UIINFO[3] or "")

		nut.terminal.diskui2 = self
	end

	function PANEL:OnRemove()
		nut.terminal.diskui2 = nil
	end


	vgui.Register("nutTerminalData", PANEL, "DFrame")
	
	local PANEL = {}

	function PANEL:Init()
		if (nut.terminal.diskui and nut.terminal.diskui:IsVisible()) then
			nut.terminal.diskui:Remove()
			nut.terminal.diskui = nil
		end

		self:SetSize(500, 450)
		self:SetTitle(L"terminalDiskMenu")
		self:Center()
		self:MakePopup()

        self.list = vgui.Create("DPanelList", self)
        self.list:Dock(FILL)
        self.list:EnableVerticalScrollbar()
        self.list:SetSpacing(5)
        self.list:SetPadding(5)

        self.diskPanels = {}

		self:updateDisks()

		nut.terminal.diskui = self
	end

	function PANEL:OnRemove()
		nut.terminal.diskui = nil
	end

	function PANEL:updateDisks()
		local client = LocalPlayer()
		local char = client:getChar()
		local inv = char:getInv()
		local disks = inv:getItemsByUniqueID("disk")

		for k, v in ipairs(disks) do
			local panel = vgui.Create("nutDiskPanel", self.list)
			panel:setDisk(v)
			table.insert(self.diskPanels, panel)

			self.list:AddItem(panel)
		end
	end

	vgui.Register("nutTerminalDisk", PANEL, "DFrame") -- Disk Insert Selection


	local PANEL = {}
    function PANEL:Init()
        self:SetTall(64)
        
        local function assignClick(panel)   
            panel.OnMousePressed = function()
                self.pressing = -1
                self:onClick()
            end
            panel.OnMouseReleased = function()
                if (self.pressing) then
                    self.pressing = nil
                end
            end
        end

        self.icon = self:Add("SpawnIcon")
        self.icon:SetSize(64, 64)
        self.icon:InvalidateLayout(true)
        self.icon:Dock(LEFT)
        self.icon.PaintOver = function(this, w, h)
        end
        assignClick(self.icon) 

        self.label = self:Add("DLabel")
        self.label:Dock(FILL)
        self.label:SetMouseInputEnabled(true)
        self.label:SetCursor("hand")
        self.label:SetExpensiveShadow(1, Color(0, 0, 60))
        self.label:SetContentAlignment(5)
        self.label:SetFont("nutMediumFont")
        assignClick(self.label) 
    end

    function PANEL:onClick()
    	netstream.Start("nutTerminal", TERMINAL_INSERT, self.disk.id)
		nut.terminal.diskui:Remove()
    end

    function PANEL:setDisk(data)
		local title = data:getData("title") or L"tunla"
		
        if (data.model) then
            self.icon:SetModel(data.model)
        else
            self.icon:SetModel("models/Items/battery.mdl")
        end
        
        self.label:SetText(title)
        self.disk = data
    end
	vgui.Register("nutDiskPanel", PANEL, "DPanel")